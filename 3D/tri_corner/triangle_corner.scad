// Triangular Corner Bracket Module
// This module creates a corner bracket that can be placed at box corners
// Parameters:
//   rotation_x, rotation_y, rotation_z: rotation angles for proper orientation

module triangle_corner(rotation_x=0, rotation_y=0, rotation_z=0) {
    rotate([rotation_x, rotation_y, rotation_z]) {
        group() {
            // x-y plane triangle
            difference() {
                linear_extrude(height=3) polygon(points=[[0,0],[20,0],[0,20]]);
                translate([8,8,-1]) cylinder(h=5, d=3);
            }

            // y-z plane triangle (rotated 90 degrees around x-axis)
            difference() {
                translate([0,3,0]) rotate([90,0,0]) linear_extrude(height=3) polygon(points=[[0,0],[20,0],[0,20]]);
                translate([8,3,8]) rotate([90,0,0]) cylinder(h=5, d=3);
            }

            // x-z plane triangle (rotated 90 degrees around y-axis)
            difference() {
                translate([3,0,0]) rotate([0,-90,0]) linear_extrude(height=3) polygon(points=[[0,0],[20,0],[0,20]]);
                translate([3,8,8]) rotate([0,-90,0]) cylinder(h=5, d=3);
            }
        }
    }
}
