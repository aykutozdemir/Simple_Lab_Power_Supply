// Params (unchanged)
bracket_length = 20;
bracket_thickness = 3;
bracket_width = 10;
hole_diameter = 3.2;
hole_distance = 10;
$fn = 64;  // smoother circles

module l_bracket() {
    difference() {
        union() {
            // Vertical leg (x=thickness, y=width, z=length)
            cube([bracket_thickness, bracket_width, bracket_length]);
            // Horizontal leg (x=length, y=width, z=thickness)
            cube([bracket_length, bracket_width, bracket_thickness]);
        }

        // Hole in vertical leg: axis should be X -> rotate cylinder 90° around Y
        translate([bracket_thickness/2, bracket_width/2, hole_distance])
            rotate([0,90,0])
                cylinder(h = bracket_thickness + 2, d = hole_diameter, center = true);

        // Hole in horizontal leg: axis is Z already, so no rotate needed
        translate([hole_distance, bracket_width/2, bracket_thickness/2])
            cylinder(h = bracket_thickness + 2, d = hole_diameter, center = true);
    }
}

l_bracket();
