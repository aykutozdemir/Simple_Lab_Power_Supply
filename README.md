### Simple Lab Power Supply (4-Channel)

A compact four-channel bench power supply project with dedicated controller, protection, and current-sensing boards, plus a printable enclosure and front panel components. Repository: [`aykutozdemir/Simple_Lab_Power_Supply`](https://github.com/aykutozdemir/Simple_Lab_Power_Supply).

### Features
- **Four independent channels**: adjustable and monitorable per-channel output
- **Dedicated protection**: over-current/short-circuit protection board
- **Current sensing**: separate current sensor design for precise measurement
- **Printable enclosure**: parametric SCAD and exported STLs for all case parts
- **Fabrication-ready**: gerbers, BOMs, PDFs, and 3D previews included

### Repository layout
- `Controller/`: KiCad project for the main control PCB
  - `generated/gerbers/`: fabrication files
  - `generated/bom/`: BOM in CSV/HTML/PDF
  - `generated/pdf/`: PCB and schematic PDFs
  - `generated/3d/`: 3D renders and board STEP/STL
- `Protection/`: KiCad project for the protection PCB
  - `generated/` mirrors the structure above
- `Current_Sensor/`: KiCad project for the current sensor
- `3D/`: mechanical assets and enclosure
  - `exports/`: printable panels and enclosure parts (`front.stl`, `back.stl`, `left.stl`, `right.stl`, `top.stl`, `bottom.stl`, `mid.stl`)
  - subfolders for off-the-shelf or custom components (banana jacks, fan, sockets, switches, knobs, etc.)

### Quick start
1) Open electronics in KiCad (KiCad 7+ recommended):
   - `Controller/Controller.kicad_pro`
   - `Protection/Protection.kicad_pro`
   - `Current_Sensor/Current_Sensor.kicad_pro`
2) Fabrication files:
   - Controller gerbers: `Controller/generated/gerbers/`
   - Protection gerbers: `Protection/generated/gerbers/`
   - BOMs: `Controller/generated/bom/Controller_bom.*`, `Protection/generated/bom/Protection_bom.*`
   - PDFs (schematic/PCB): see `generated/pdf/`
3) Enclosure and front panel:
   - Print from `3D/exports/*.stl`
   - Optional components located in subfolders (e.g., `3D/banana/banana.stl`, `3D/pot/pot.stl`, `3D/fan/fan.stl`)

### 3D printing guidance
- Material: PLA or PETG (PETG recommended for heat resistance)
- Layer height: 0.2 mm (typ.)
- Infill: 15–25% grid/gyroid for panels; 35–50% for brackets
- Walls: 3–4 perimeters; 4–6 top/bottom layers
- Orientation: print panels flat; brackets with load-bearing axis aligned; check STL previews in `3D/exports/`

### Front panel notes
- Displays and meters mount to the `front.stl` panel. Matching cutouts are modeled in the exported panel.
- Banana connectors: use `3D/banana/banana.stl`. In the assembled view, place two banana connectors per multimeter, horizontally below the displays, visible from front. Front panel hole x-offsets at ±12 mm and z at `box_height*4/6 - multimeter_height/2 - 25`. Place connectors at y slightly in front of the front panel (e.g., `box_depth + 1`) and rotate `[-90, 0, 0]` for insertion alignment [[memory:6634135]].

### Electrical overview
- Controller board manages channel outputs, measurement, and user interface.
- Protection board implements fast over-current/short protection and isolation where needed.
- Current sensor board provides per-channel current measurement with appropriate scaling.
- See the comprehensive PDFs in `Controller/generated/pdf/` and `Protection/generated/pdf/` for signal names and interfaces.

### Fabrication and assembly
1) Order PCBs using the gerbers in each project’s `generated/gerbers/` directory.
2) Source parts from the BOMs (`generated/bom/`). Check packages/footprints against PDFs.
3) Solder SMD/TH components as per schematics.
4) Test each board independently before system integration.
5) Assemble enclosure:
   - Dry-fit `front`, `back`, `left`, `right`, `top`, `bottom`, and `mid` panels.
   - Install switches, sockets, fuses, fan, pots/knobs, and banana jacks.
   - Route wiring according to schematics; keep high-current and low-noise paths separated.

### Safety
- Mains voltages and high currents can be hazardous. Verify isolation, fusing, and protective earth where applicable.
- Use appropriate gauge wiring, strain relief, and insulation. Validate thermal performance under load.

### Contributing
- Issues and pull requests are welcome on GitHub: `https://github.com/aykutozdemir/Simple_Lab_Power_Supply`.
- For changes that affect the enclosure, export updated STLs to `3D/exports/` and include screenshots/renders.
- For PCB edits, regenerate `generated/` assets (BOM, PDFs, gerbers) so reviewers can diff artifacts.

### License
No license file is included yet. If you intend to reuse or distribute, please open an issue to clarify licensing, or add a `LICENSE` file.

### Credits
Design and repository maintained by Aykut Ozdemir. See the GitHub repository for history and updates: [`Simple_Lab_Power_Supply`](https://github.com/aykutozdemir/Simple_Lab_Power_Supply).