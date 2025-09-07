#!/usr/bin/env python3
import argparse
import json
import os
import re
import sys
import textwrap
from collections import defaultdict
from datetime import datetime


DEFAULT_LIB_DIR = \
    "/home/aykut/.wine/drive_c/Program Files (x86)/VeeCAD/Library"


COMPONENT_HEADER_RE = re.compile(
    r"^\s*\(\s*/(?P<uuid>[0-9A-Fa-f\-]+)\s+"
    r"(?P<footprint>\S+)\s+"
    r"(?P<ref>\S+)\s+"
    r"(?P<value>.*)$",
    re.IGNORECASE,
)


def read_text(path: str) -> str:
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def write_text(path: str, content: str) -> None:
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)


def backup_file(path: str) -> str:
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = f"{path}.{timestamp}.bak"
    with open(path, "rb") as src, open(backup_path, "wb") as dst:
        dst.write(src.read())
    return backup_path


def _extract_json_block(text: str) -> str | None:
    start = text.find("{")
    end = text.rfind("}")
    if start == -1 or end == -1 or end <= start:
        return None
    return text[start:end + 1]


def _collect_pin_names_from_obj(obj, pin_names: set[str]):
    if isinstance(obj, dict):
        if "Pin" in obj and isinstance(obj["Pin"], str):
            pin_names.add(obj["Pin"].strip())
        for v in obj.values():
            _collect_pin_names_from_obj(v, pin_names)
    elif isinstance(obj, list):
        for v in obj:
            _collect_pin_names_from_obj(v, pin_names)


def _infer_sizes_from_name(outline_name: str) -> dict:
    """Infer human-friendly size info from common naming conventions.
    Returns dict with optional keys: pitch_mm, diameter_mm, body_label, size_label.
    """
    info: dict[str, object] = {}
    name = outline_name.upper()
    # CAPR<diameter>_<pitch> e.g., CAPR10_5, CAPR15_7.5
    m = re.match(r"^CAPR([0-9]+(?:\.[0-9]+)?)_([0-9]+(?:\.[0-9]+)?)$", name)
    if m:
        try:
            diameter = float(m.group(1))
            pitch = float(m.group(2))
            info["diameter_mm"] = diameter
            info["pitch_mm"] = pitch
            info["size_label"] = f"D={diameter:g}mm, P={pitch:g}mm"
            return info
        except Exception:
            pass
    # CAPR<diameter>_<pitch> variants like CAPR2.5_5 already handled.
    # BOXx_y: unknown units; treat as body variants
    if name.startswith("BOX"):
        info["body_label"] = name
        return info
    return info


def scan_veecad_outlines(lib_dir: str):
    """
    Scan .per files for outline names. Returns:
      - outlines: dict[name] -> set of source .per relative paths
      - outlines_by_file: dict[per_rel] -> set of names
    """
    outlines: dict[str, dict] = {}
    outlines_by_file: dict[str, set[str]] = defaultdict(set)
    if not os.path.isdir(lib_dir):
        raise FileNotFoundError(f"VeeCAD library directory not found: {lib_dir}")

    for root, _dirs, files in os.walk(lib_dir):
        for fn in files:
            if not fn.lower().endswith(".per"):
                continue
            per_path = os.path.join(root, fn)
            text = None
            try:
                text = read_text(per_path)
            except Exception:
                continue

            rel = os.path.relpath(per_path, lib_dir)

            # Prefer parsing JSON block for accurate pin info
            block = _extract_json_block(text)
            parsed = None
            if block:
                try:
                    parsed = json.loads(block)
                except Exception:
                    parsed = None
            if parsed and isinstance(parsed, dict):
                # Two possible containers: CelledOutlines and/or Outlines
                for container_key in ("CelledOutlines", "Outlines"):
                    arr = parsed.get(container_key)
                    if not isinstance(arr, list):
                        continue
                    for outline_obj in arr:
                        if not isinstance(outline_obj, dict):
                            continue
                        name = outline_obj.get("Name")
                        if not isinstance(name, str) or not name.strip():
                            continue
                        name = name.strip()
                        pin_names: set[str] = set()
                        # Common field is "Rows" in CelledOutlines. But just recursively scan.
                        _collect_pin_names_from_obj(outline_obj, pin_names)
                        if name not in outlines:
                            outlines[name] = {
                                "files": set(),
                                "pin_names": set(),
                                "pin_count": 0,
                            }
                        outlines[name]["files"].add(rel)
                        outlines[name]["pin_names"].update(pin_names)
                        outlines[name]["pin_count"] = max(outlines[name]["pin_count"], len(outline_obj.get("PinNames", pin_names)))
                        # Attach inferred sizes
                        sizes = _infer_sizes_from_name(name)
                        if sizes:
                            outlines[name].setdefault("sizes", {}).update(sizes)
                        outlines_by_file[rel].add(name)
                continue

            # Fallback text-based VeeCAD .per parser
            # Recognize outline blocks under [Outlines]/[LeadedOutlines]/[RadialOutlines]/[CustomOutlines]
            lines = text.splitlines()
            in_outline_section = False
            current_name = None
            current_pins = set()
            def commit_current():
                nonlocal current_name, current_pins
                if not current_name:
                    return
                name = current_name
                if name not in outlines:
                    outlines[name] = {
                        "files": set(),
                        "pin_names": set(),
                        "pin_count": 0,
                        "sizes": {},
                    }
                outlines[name]["files"].add(rel)
                outlines[name]["pin_names"].update(current_pins)
                outlines[name]["pin_count"] = max(outlines[name]["pin_count"], len(current_pins))
                sizes = _infer_sizes_from_name(name)
                if sizes:
                    outlines[name]["sizes"].update(sizes)
                outlines_by_file[rel].add(name)
                current_name = None
                current_pins = set()

            for raw in lines:
                line = raw.strip()
                if not line:
                    continue
                if line.startswith("[") and line.endswith("]"):
                    # Section switch
                    section = line[1:-1].strip().lower()
                    if section in {"outlines", "leadedoutlines", "radialoutlines", "customoutlines"}:
                        in_outline_section = True
                        # Commit any dangling outline on section switch
                        commit_current()
                        continue
                    else:
                        # Other sections like Components: stop outline parsing
                        if in_outline_section:
                            commit_current()
                        in_outline_section = False
                        continue
                if not in_outline_section:
                    continue
                # Start of outline definition: Name,number
                if current_name is None:
                    m = re.match(r"^([A-Za-z0-9_]+)\s*,\s*\d+\s*$", line)
                    if m:
                        current_name = m.group(1)
                        current_pins = set()
                    continue
                # Inside an outline block
                if line.lower() == "end":
                    commit_current()
                    continue
                if line.lower().startswith("pin,"):
                    # Pin,<id>,x,y
                    parts = [p.strip() for p in line.split(",")]
                    if len(parts) >= 2:
                        pin_id = parts[1]
                        if pin_id:
                            current_pins.add(pin_id)

    # Finalize pin_count from pin_names
    for info in outlines.values():
        if info["pin_count"] == 0 and info["pin_names"]:
            info["pin_count"] = len(info["pin_names"])
    return outlines, outlines_by_file


def parse_netlist_headers(lines):
    """
    Parse lines, yielding dicts for component header lines with token spans.
    Keeps original line text and indices to allow precise in-place token replacement.
    """
    headers = []
    for idx, line in enumerate(lines):
        m = COMPONENT_HEADER_RE.match(line)
        if not m:
            continue
        # Capture spans so we can preserve spacing
        footprint_span = m.span("footprint")
        headers.append({
            "line_index": idx,
            "line": line,
            "uuid": m.group("uuid"),
            "footprint": m.group("footprint"),
            "ref": m.group("ref"),
            "value": m.group("value"),
            "footprint_span": footprint_span,
        })
    return headers


def compute_component_pin_counts(headers, lines):
    """
    Determine pin count per component by counting subsequent pad lines until the closing ')'.
    Assumes header at line i, with following lines like '  (    1 Net-... )' until a lone ')' line.
    """
    pin_counts = {}
    for h in headers:
        idx = h["line_index"]
        count = 0
        j = idx + 1
        while j < len(lines):
            line = lines[j]
            if line.strip() == ')':
                break
            # A pad line looks like: (    1 Net-... )
            if line.lstrip().startswith('('):
                # Count only lines that start with '(' and contain a pin number as first token
                # Quick heuristic: after '(', there is whitespace then a number
                m = re.match(r"^\s*\(\s*([0-9A-Za-z]+)\b", line)
                if m:
                    count += 1
            j += 1
        pin_counts[h["ref"]] = count
    return pin_counts


def group_by_current_footprint(headers):
    grouping = defaultdict(list)
    for h in headers:
        grouping[h["footprint"]].append(h)
    return grouping


def print_compact_list(items, max_items=30):
    for i, item in enumerate(items[:max_items], start=1):
        print(f"  {i:2d}) {item}")
    if len(items) > max_items:
        print(f"  ... and {len(items) - max_items} more")


def pick_outline_interactive(current_fp, refs, outlines_dict, outlines_by_file, preferred_files, required_pin_count: int | None):
    names = sorted(outlines_dict.keys(), key=lambda s: (s.lower()))

    # Candidate generation
    candidates = []
    lower = current_fp.lower()
    if current_fp in outlines_dict:
        candidates = [current_fp]
    else:
        # Prefer names containing the token
        candidates = [n for n in names if lower in n.lower()]

        # If no candidates, prefer outlines from preferred library files
        if not candidates and preferred_files:
            preferred_names = []
            for rel in preferred_files:
                preferred_names.extend(sorted(outlines_by_file.get(rel, [])))
            # Dedup while keeping order
            seen = set()
            tmp = []
            for n in preferred_names:
                if n not in seen:
                    seen.add(n)
                    tmp.append(n)
            candidates = tmp

        # Fallback to offering some common shapes
        if not candidates:
            common_prefixes = ["DIP", "SIP", "TO", "AX", "CAP", "LED", "RES", "HDR"]
            for p in common_prefixes:
                candidates.extend([n for n in names if n.upper().startswith(p)])
            # Deduplicate
            seen = set()
            dedup = []
            for n in candidates:
                if n not in seen:
                    seen.add(n)
                    dedup.append(n)
            candidates = dedup

    # Filter by pin count if requested and known
    if required_pin_count is not None:
        filtered = []
        for n in candidates:
            info = outlines_dict.get(n)
            pin_count = 0
            if isinstance(info, dict):
                pin_count = info.get("pin_count", 0)
            if pin_count == 0 or pin_count == required_pin_count:
                filtered.append(n)
        candidates = filtered if filtered else candidates

    print()
    print(f"Footprint: {current_fp}")
    print(f"  Used by refs (examples): {', '.join(refs[:8])}{'...' if len(refs) > 8 else ''}")
    if required_pin_count is not None:
        print(f"  Required pins: {required_pin_count}")

    if not candidates:
        print("No matching outlines found. You can enter a custom outline name or '?'")
    else:
        print("Choose one of the following outlines (enter number).")
        # Show pin counts and inferred sizes next to names
        annotated = []
        for n in candidates:
            info = outlines_dict.get(n)
            pc = 0
            size = ""
            if isinstance(info, dict):
                pc = info.get("pin_count", 0)
                sizes = info.get("sizes") or {}
                if sizes.get("size_label"):
                    size = sizes["size_label"]
                elif sizes.get("pitch_mm") or sizes.get("diameter_mm"):
                    pitch = sizes.get("pitch_mm")
                    dia = sizes.get("diameter_mm")
                    parts = []
                    if dia:
                        parts.append(f"D={dia:g}mm")
                    if pitch:
                        parts.append(f"P={pitch:g}mm")
                    if parts:
                        size = ", ".join(parts)
            suffix = []
            if pc:
                suffix.append(f"{pc} pins")
            if size:
                suffix.append(size)
            label = f"{n} ({'; '.join(suffix)})" if suffix else f"{n}"
            annotated.append(label)
        print_compact_list(annotated, max_items=40)

    while True:
        raw = input("Enter selection [number], 0=keep original, *=list all, /=filter, or type name: ").strip()
        if raw == "0":
            return None  # keep original
        if raw == "*":
            print("All outlines:")
            print_compact_list(names, max_items=200)
            continue
        if raw.startswith("/"):
            q = raw[1:].strip().lower()
            filtered = [n for n in names if q in n.lower()]
            if not filtered:
                print("No matches.")
            else:
                # Annotate
                annotated = []
                for n in filtered:
                    info = outlines_dict.get(n)
                    pc = 0
                    size = ""
                    if isinstance(info, dict):
                        pc = info.get("pin_count", 0)
                        sizes = info.get("sizes") or {}
                        if sizes.get("size_label"):
                            size = sizes["size_label"]
                        elif sizes.get("pitch_mm") or sizes.get("diameter_mm"):
                            pitch = sizes.get("pitch_mm")
                            dia = sizes.get("diameter_mm")
                            parts = []
                            if dia:
                                parts.append(f"D={dia:g}mm")
                            if pitch:
                                parts.append(f"P={pitch:g}mm")
                            if parts:
                                size = ", ".join(parts)
                    suffix = []
                    if pc:
                        suffix.append(f"{pc} pins")
                    if size:
                        suffix.append(size)
                    label = f"{n} ({'; '.join(suffix)})" if suffix else f"{n}"
                    annotated.append(label)
                print("Filtered:")
                print_compact_list(annotated, max_items=80)
            continue
        if raw.isdigit():
            sel = int(raw)
            if 1 <= sel <= len(candidates):
                return candidates[sel - 1]
            print("Invalid number.")
            continue
        if raw:
            # User typed a name. Accept as-is if it exists, or accept custom.
            if raw in outlines_dict:
                return raw
            confirm = input(f"Outline '{raw}' not in library. Use anyway? [y/N]: ").strip().lower()
            if confirm == "y":
                return raw
        else:
            # Empty input, re-prompt
            continue


def choose_preferred_lib_files_for_refs(ref_examples, lib_dir, outlines_by_file):
    preferred = []
    if any(r.upper().startswith("C") for r in ref_examples):
        # Capacitor libraries
        for rel in outlines_by_file.keys():
            if "capacitor" in rel.lower():
                preferred.append(rel)
    if any(r.upper().startswith("U") for r in ref_examples):
        for rel in outlines_by_file.keys():
            if os.path.basename(rel).lower().startswith("v_standard"):
                preferred.append(rel)
    if any(r.upper().startswith("R") for r in ref_examples):
        for rel in outlines_by_file.keys():
            if os.path.basename(rel).lower().startswith("v_standard"):
                preferred.append(rel)
    if any(r.upper().startswith("J") for r in ref_examples):
        # Headers/connectors likely in standard as well
        for rel in outlines_by_file.keys():
            base = os.path.basename(rel).lower()
            if base.startswith("v_standard") or "header" in base:
                preferred.append(rel)
    # Deduplicate keeping order
    seen = set()
    ordered = []
    for r in preferred:
        if r not in seen:
            seen.add(r)
            ordered.append(r)
    return ordered


def auto_map_outline(current_fp: str, outlines: dict) -> str | None:
    fp_lower = current_fp.lower()
    # DIP packages
    m = re.search(r"dip[-_ ]?(\d+)", fp_lower)
    if m:
        name = f"DIP{m.group(1)}"
        if name in outlines:
            return name
    # TO-92
    if re.search(r"to[-_ ]?92", fp_lower):
        if "TO92" in outlines:
            return "TO92"
    # PinHeaders and JST 1xN -> SIPN
    m = re.search(r"1x(\d+)", fp_lower)
    if m:
        try:
            count = int(m.group(1))
        except ValueError:
            count = None
        name = f"SIP{count}" if count is not None else f"SIP{m.group(1)}"
        if name in outlines:
            return name
    # Bourns 3296 -> SIP3
    if "3296" in fp_lower and "SIP3" in outlines:
        return "SIP3"
    # Generic 2-pin passive footprints
    if fp_lower.startswith("resistor_tht:") or fp_lower.startswith("capacitor_tht:"):
        for candidate in ("AX2_1", "AX2_2", "AX2_1N"):
            if candidate in outlines:
                return candidate
    return None


def build_mapping_interactive(current_fp_to_headers, outlines, outlines_by_file, assume_if_exact=True, keep_unknowns=False, auto_map=False, ref_to_pin_count: dict | None = None):
    mapping = {}
    for current_fp, hdrs in sorted(current_fp_to_headers.items(), key=lambda kv: kv[0].lower()):
        refs = [h["ref"] for h in hdrs]
        if assume_if_exact and current_fp in outlines:
            print(f"Exact outline found for '{current_fp}', using as-is.")
            mapping[current_fp] = current_fp
            continue
        if auto_map:
            auto = auto_map_outline(current_fp, outlines)
            if auto:
                print(f"Auto-mapped '{current_fp}' -> '{auto}'.")
                mapping[current_fp] = auto
                continue
        if keep_unknowns:
            # Non-interactive mode for unknowns: keep original footprint
            print(f"No exact outline for '{current_fp}', keeping original (non-interactive).")
            mapping[current_fp] = current_fp
            continue
        preferred_files = choose_preferred_lib_files_for_refs(refs, DEFAULT_LIB_DIR, outlines_by_file)
        required_pins = None
        if ref_to_pin_count:
            # Use the max pins among refs sharing this fp
            required_pins = max((ref_to_pin_count.get(r) or 0) for r in refs) or None
        selected = pick_outline_interactive(current_fp, refs, outlines, outlines_by_file, preferred_files, required_pins)
        if selected is None:
            # Keep as-is
            mapping[current_fp] = current_fp
        else:
            mapping[current_fp] = selected
    return mapping


def apply_mapping(lines, headers, mapping, dry_run=False):
    updated_lines = list(lines)
    changes = []
    for h in headers:
        original_fp = h["footprint"]
        new_fp = mapping.get(original_fp, original_fp)
        if new_fp == original_fp:
            continue
        idx = h["line_index"]
        line = updated_lines[idx]
        start, end = h["footprint_span"]
        new_line = line[:start] + new_fp + line[end:]
        changes.append((idx, line.rstrip("\n"), new_line.rstrip("\n")))
        updated_lines[idx] = new_line

    if dry_run:
        print("\nPlanned changes (line_number: old -> new):")
        for idx, old, new in changes:
            print(f"  {idx+1}: {old}")
            print(f"      -> {new}")
    return updated_lines, changes


def main():
    parser = argparse.ArgumentParser(
        description="Map KiCad netlist footprints to VeeCAD outlines (interactive)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent(
            f"""
            Notes:
              - Parses only component header lines of Eeschema legacy netlist (Version 1.1 style).
              - Rewrites only the footprint token on those lines, preserving spaces.
              - Library scanned from: {DEFAULT_LIB_DIR}

            Interactive commands when choosing outlines:
              - 0 : keep original footprint
              - * : list all outlines
              - /text : filter outlines by substring
              - <number> : choose from displayed candidates
              - <name> : type a custom outline name (accepts non-library names after confirmation)
            """
        ),
    )
    parser.add_argument("-i", "--input", required=True, help="Path to KiCad netlist file")
    parser.add_argument("-o", "--output", help="Output path (default: overwrite input)")
    parser.add_argument("--lib-dir", default=DEFAULT_LIB_DIR, help="VeeCAD library directory")
    parser.add_argument("--dry-run", action="store_true", help="Show changes without writing")
    parser.add_argument("--no-backup", action="store_true", help="Do not create backup when overwriting input")
    parser.add_argument("--no-auto-exact", action="store_true", help="Do not auto-accept exact outline matches; ask instead")
    parser.add_argument("--keep-unknown", action="store_true", help="Do not prompt for unknown outlines; keep original footprints")
    parser.add_argument("--auto-map", action="store_true", help="Attempt automatic mapping from common KiCad names to VeeCAD outlines")
    args = parser.parse_args()

    netlist_path = os.path.abspath(args.input)
    output_path = os.path.abspath(args.output) if args.output else netlist_path

    print(f"Reading netlist: {netlist_path}")
    text = read_text(netlist_path)
    lines = text.splitlines(keepends=True)

    headers = parse_netlist_headers(lines)
    if not headers:
        print("No component headers found. Is this an Eeschema legacy netlist?")
        sys.exit(1)
    current_fp_to_headers = group_by_current_footprint(headers)
    ref_to_pin_count = compute_component_pin_counts(headers, lines)

    print(f"Found {len(headers)} components with {len(current_fp_to_headers)} unique footprints.")

    print(f"Scanning VeeCAD libraries under: {args.lib_dir}")
    outlines, outlines_by_file = scan_veecad_outlines(args.lib_dir)
    print(f"Found {len(outlines)} unique outlines across {len(outlines_by_file)} library files.")

    mapping = build_mapping_interactive(
        current_fp_to_headers,
        outlines,
        outlines_by_file,
        assume_if_exact=not args.no_auto_exact,
        keep_unknowns=args.keep_unknown,
        auto_map=args.auto_map,
        ref_to_pin_count=ref_to_pin_count,
    )

    updated_lines, changes = apply_mapping(lines, headers, mapping, dry_run=args.dry_run)

    if args.dry_run:
        print("\nDry run completed. No files written.")
        return

    # If output equals input, create backup unless suppressed
    if output_path == netlist_path and not args.no_backup:
        b = backup_file(netlist_path)
        print(f"Backup created: {b}")

    write_text(output_path, "".join(updated_lines))
    print(f"Wrote updated netlist: {output_path}")
    print(f"Changed {len(changes)} component header lines.")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nAborted by user.")
        sys.exit(130)


