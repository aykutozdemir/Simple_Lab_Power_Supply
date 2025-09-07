// Power Supply Box Design
// Dimensions: 34cm width x 9cm height x 20cm depth
// Complete assembly with all components and cutouts

// Import finger joint library
use <fingerjoint.scad>;

// Box dimensions
box_width = 340;  // 34cm
box_height = 100;  // 10cm  
box_depth = 200;  // 20cm
wall_thickness = 5; // 5mm wall thickness

// Finger joint parameters
finger_width = 10; // Width of each finger

// Use the triangular corner module
use <tri_corner/triangle_corner.scad>;

// Import L bracket module
use <bracket/l_bracket.scad>;

// Potentiometer parameters
pot_hole_diameter = 10;
pot_vertical_gap = 30;

// Rocker switch parameters (single mount)
rocker_cutout_w = 12;    // panel cutout width (mm)
rocker_cutout_h = 30;    // panel cutout height (mm)
rocker_body_depth = 20;  // body depth into the box (mm)
use_rocker_stl = true;  // set true if you add an STL at rocker_stl_path
rocker_stl_path = "switch/Tekli-Montaj_Shrinkwrap_1.stl"; // expected STL path if available
rocker_front_offset = 0.5; // small protrusion beyond panel front (mm)

// Multimeter dimensions
multimeter_width = 46;
multimeter_height = 27;
multimeter_depth = 20;

// Internal PSU (rectangular prism) and standoffs
psu_length = 215;   // along X (mm)
psu_width  = 115;   // along Y (mm)
psu_height = 50;    // along Z (mm)
standoff_height = 3; // 0.5 cm standoff height (mm)
standoff_radius = 5;  // standoff outer radius (mm)
// Mounting hole pattern relative to PSU local origin (0,0 at PSU min X/Y corner)
// Four mount points uniformly 32.5 mm from each edge
psu_hole_margin_x = 32.5; // distance from PSU X edges to hole centers (mm)
psu_hole_margin_y = 32.5; // distance from PSU Y edges to hole centers (mm)
// Clearance radius for M4 screw
m4_clearance_r = 2.2;   // ~4.4 mm diameter

// Rear socket cutout (for socket/Shapes011.stl)
rear_socket_cutout_w = 27; // mm (adjust as needed)
rear_socket_cutout_h = 31; // mm (adjust as needed)
rear_socket_mount_hole_d = 3.5; // mm diameter for mounting screws
rear_socket_mount_spacing = 36; // mm spacing between mounting holes

// Mid-shelf parameters (inner layer over PSU)
mid_shelf_standoff_height = 58;      // 7 cm standoffs
mid_shelf_standoff_diameter = 3;     // 3 mm standoff diameter
mid_shelf_plate_thickness = 5;       // 5 mm plate
mid_shelf_margin_from_psu = -5;       // mm distance of standoffs from PSU edges
mid_shelf_wall_clearance = 1.0;      // clearance from inner walls
mid_shelf_plate_margin_x = 25;        // plate margin around PSU in X
mid_shelf_plate_margin_y = 10;        // plate margin around PSU in Y
mid_shelf_mount_hole_d = 3.2;        // mounting hole diameter (M3 clearance)
mid_shelf_honey_border = 10;         // honeycomb border offset from plate edges (mm)

// Layout width for front-panel features (kept constant when box_width changes)
layout_width = 300;
layout_offset_x = (box_width - layout_width) / 2;
units_offset_x = 10; // offset for unit elements (multimeters and their components)

// Calculate spacing for 4 multimeters within the fixed layout width
total_multimeters_width = 4 * multimeter_width;
spacing = (layout_width - total_multimeters_width) / 5 - 3;

// Front-panel feature offsets (for consistency)
banana_offset_x = 12;   // symmetric banana jack offset from x0
banana_offset_z = 2;    // banana jack vertical offset from jack line
toggle_offset_x = -27;  // toggle switch x offset from x0
led_offset_x = 3;       // LED x offset from x0
led_offset_z = 15;      // LED vertical offset above the jack line
front_vert_offset = 3;  // global vertical lift for front units (mm)
// Banana STL alignment corrections (due to STL origin)
banana_stl_dx_left = 3;   // mm adjustment for left connector
banana_stl_dx_right = 3;  // mm adjustment for right connector
// Fuse hole under banana jacks (per unit)
fuse_hole_d = 12;        // diameter (mm)
fuse_hole_offset_z = 10; // distance below fuse hole

// 80mm fan mounting parameters
fan_hole_pitch = 71.5;       // distance between opposite screw centers (mm)
fan_mount_hole_d = 4.3;      // screw clearance diameter (mm) for M4
left_fan_center_y = box_depth - 70; // left side intake center along depth (mm)
right_fan_center_y = 70;            // right side exhaust center along depth (mm)
fan_center_z = box_height / 2;        // vertical center (mm)
fan_grill_radius = 38;              // grill radius (mm) around fan center
honeycomb_cell = 7;                 // across-flats size of hex cells (mm)
honeycomb_strut = 1.8;              // wall thickness between cells (mm)

// ---------- PARAMETRE GRUPLARI: TUREVLER/ORTAK TUREVLER ----------
// On Panel Birim Yardimcilari (ekran, banana, toggle, LED)
function unit_x_abs(i) = layout_offset_x + (spacing + i * (multimeter_width + spacing) + multimeter_width/2) + units_offset_x;
jack_line_z = (box_height*3/6 + front_vert_offset)/2;
banana_hole_center_z = jack_line_z + banana_offset_z + 5;
toggle_center_z = jack_line_z;
led_center_z = jack_line_z + led_offset_z + 5;

// Rocker ve USB/U1E merkezleri (cutout merkezleri)
rocker_center_x = box_width - layout_offset_x - 5;
rocker_center_z = box_height * 2/5 + 5;
usb_center_x = box_width - layout_offset_x - 17;
usb_center_z = box_height * 2/5 - 24;
u1e_center_x = box_width - layout_offset_x - 93;
u1e_center_z = box_height * 2/5 - 27.7;

// Arka priz merkezi (cutout merkezi)
rear_socket_center_x = 30;
rear_socket_center_z = box_height/2;

// Potansiyometre merkezleri (ekran 1'e gore)
leftmost_screen_center_x = layout_offset_x + spacing + multimeter_width/2 + units_offset_x;
pot_center_z_base = box_height*2/6 + multimeter_height/2 + front_vert_offset;
pot1_center_x = leftmost_screen_center_x - 40; // 40mm left of leftmost screen
pot2_center_x = leftmost_screen_center_x - 50; // 50mm left of leftmost screen
pot1_center_z = pot_center_z_base + pot_vertical_gap/2;
pot2_center_z = pot_center_z_base - pot_vertical_gap/2;

// STL yerlesim kalibrasyonlari (mevcut geometriyi bozmaz)
multimeter_stl_center_z = (box_height - multimeter_height*4/6) + front_vert_offset; // mevcut deger
banana_stl_y = box_depth - 3;
toggle_stl_y = box_depth - 7;
led_front_unit_stl_y = box_depth - 18;
rocker_stl_offset_x = - rocker_cutout_w / 2 + 6;
rocker_stl_offset_y = - wall_thickness + rocker_front_offset - 14;
rocker_stl_offset_z = - rocker_cutout_h / 2 + 15;

// XL4016 dizilim parametreleri (ortak kullanim)
xl4016_spacing_x = 80; // spacing between XL4016 modules
xl4016_spacing_y = 60; // spacing between XL4016 modules
xl4016_start_x = (box_width - xl4016_spacing_x) / 2 - 50; // center the grid
xl4016_start_y = (box_depth - xl4016_spacing_y) / 2 + 2;  // center the grid

// Controller karti konum ve montaj deligi parametreleri (orta raf)
controller_board_size = 100; // 10cm x 10cm controller board
controller_pos_x = box_width/2 - 57;
controller_pos_y = xl4016_start_y + xl4016_spacing_y/2 + controller_board_size / 2 + 31.5;
controller_hole_d = 3.2;       // M3 clearance
controller_hole_inset = 5;     // kenardan iceri mesafe

// Mid-shelf honeycomb keepouts (to avoid under components)
controller_keepout_margin = 8; // mm margin around controller mounting hole bounding box
// Note: controller keepout will be derived from mounting holes + margin
xl4016_keepout_w = 70;  // mm (adjust to your module)
xl4016_keepout_d = 45;  // mm (adjust to your module)

// Front Panel Layout with Cutouts
module front_panel_layout() {
    // 4 Ammeter holes
    for(i = [0:3]) {
        x_pos = spacing + i * (multimeter_width + spacing) + multimeter_width/2;
        z_pos = box_height*3/6 + front_vert_offset;
        x0 = unit_x_abs(i);
        
        // Main ammeter cutout - larger for better visibility
        translate([x0 - multimeter_width/2, -1, z_pos + 5])
        cube([multimeter_width, wall_thickness + 2, multimeter_height]);
                
        // 8mm holes for banana jacks (symmetric) below each multimeter
        // Right jack hole
        rotate([0, 0, 0])
        translate([x0 + banana_offset_x + banana_stl_dx_right, -1, banana_hole_center_z])
        rotate([-90, 0, 0])
        cylinder(h = wall_thickness + 2, r = 4, $fn=60);

        // Left jack hole (aligned to STL with banana_stl_dx_left)
        rotate([0, 0, 0])
        translate([x0 - banana_offset_x + banana_stl_dx_left, -1, banana_hole_center_z])
        rotate([-90, 0, 0])
        cylinder(h = wall_thickness + 2, r = 4, $fn=60);

        // Fuse hole 12mm (vertically aligned with LED)
        // X matches LED (x0 + led_offset_x), Z is below jack line by fuse_hole_offset_z
        rotate([0, 0, 0])
        translate([x0 + led_offset_x, -1, toggle_center_z - fuse_hole_offset_z])
        rotate([-90, 0, 0])
        cylinder(h = wall_thickness + 2, r = fuse_hole_d/2, $fn=60);

        // Toggle switch hole (12.2 mm) to the right of banana jacks
        rotate([0, 0, 0])
        translate([x0 + toggle_offset_x, -1, toggle_center_z])
        rotate([-90, 0, 0])
        cylinder(h = wall_thickness + 2, r = 12.2/2, $fn=60);

        // LED hole (8 mm) above the toggle switch
        rotate([0, 0, 0])
        translate([x0 + led_offset_x, -1, led_center_z])
        rotate([-90, 0, 0])
        cylinder(h = wall_thickness + 2, r = 8/2, $fn=60);
    }

    // Rocker switch cutout at far left margin
    rocker_x = rocker_center_x; // center of left 20mm margin, moved 5mm right
    rocker_z = rocker_center_z;  // center vertically + 5mm yukarı
    translate([rocker_x - rocker_cutout_w/2, -1, rocker_z - rocker_cutout_h/2])
    cube([rocker_cutout_w, wall_thickness + 2, rocker_cutout_h]);
    
    // LED hole above rocker switch
    rotate([0, 0, 0])
    translate([rocker_x, -1, rocker_z + rocker_cutout_h/2 + 10])
    rotate([-90, 0, 0])
    cylinder(h = wall_thickness + 2, r = 8/2, $fn=60);
    
    // Dual USB cutout (HW691 - both sockets and PCB) - standalone position
    usb_x = usb_center_x; // Fixed position, independent of rocker
    usb_z = usb_center_z; // Fixed Z position (eski konum)
    usb_cutout_w = 32.5; // Wider for HW691 PCB and sockets
    usb_cutout_h = 8.5; // Taller for HW691 PCB and sockets
    translate([usb_x - usb_cutout_w/2, -1, usb_z - usb_cutout_h/2])
    cube([usb_cutout_w, wall_thickness + 2, usb_cutout_h]);
    
    // U1E PCB cutout (PCB thickness + USB-C port) - standalone position
    u1e_x = u1e_center_x; // 71mm left of dual USB (fixed relative to USB)
    u1e_z = u1e_center_z; // Fixed Z position relative to USB
    u1e_pcb_w = 20.5; // PCB width
    u1e_pcb_h = 2; // PCB height (includes USB-C port)
    
    // PCB cutout (full width)
    translate([u1e_x - u1e_pcb_w/2, -1, u1e_z - u1e_pcb_h/2])
    cube([u1e_pcb_w, wall_thickness + 2, u1e_pcb_h]);
    
    // USB-C port cutout (smaller than PCB, only for the port)
    usbc_w = 9; // USB-C port width
    usbc_h = 3.8; // USB-C port height
    translate([u1e_x - usbc_w/2, -1, u1e_z + u1e_pcb_h/2- 1])
    cube([usbc_w, wall_thickness + 2, usbc_h]);
        
    // Top right mounting hole
    translate([usb_x + usb_cutout_w/2 - 3, -1, usb_z + usb_cutout_h/2 - 3])
    rotate([-90, 0, 0])
    color("pink") cylinder(h = wall_thickness + 2, d = 2.5, $fn=60);
    
    // Bottom left mounting hole
    translate([usb_x - usb_cutout_w/2 + 3, -1, usb_z - usb_cutout_h/2 + 3])
    rotate([-90, 0, 0])
    color("pink") cylinder(h = wall_thickness + 2, d = 2.5, $fn=60);
    
    // Bottom right mounting hole
    translate([usb_x + usb_cutout_w/2 - 3, -1, usb_z - usb_cutout_h/2 + 3])
    rotate([-90, 0, 0])
    color("pink") cylinder(h = wall_thickness + 2, d = 2.5, $fn=60);
               
    // Potentiometer holes relative to leftmost screen
    leftmost_screen_x = leftmost_screen_center_x;
    pot1_x = pot1_center_x; // 40mm to the left of leftmost screen (centered)
    pot2_x = pot2_center_x; // 50mm to the left of leftmost screen (diagonal)
    pot_center_z = pot_center_z_base;
    pot_z1 = pot2_center_z; // lower
    pot_z2 = pot1_center_z; // upper

    // Upper pot hole (centered to the left of screen)
    rotate([0, 0, 0])
    translate([pot1_x, -1, pot_z2])
    rotate([-90, 0, 0])
    cylinder(h = wall_thickness + 2, r = pot_hole_diameter/2, $fn=60);

    // Lower pot hole (diagonal to the left of screen)
    rotate([0, 0, 0])
    translate([pot2_x, -1, pot_z1])
    rotate([-90, 0, 0])
    cylinder(h = wall_thickness + 2, r = pot_hole_diameter/2, $fn=60);
    
    // Corner mounting holes for corner brackets (M3 clearance)
    // Front panel corners - 13mm from edges
    translate([13, -1, 13]) rotate([-90, 0, 0]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    translate([box_width - 13, -1, 13]) rotate([-90, 0, 0]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    translate([13, -1, box_height - 13]) rotate([-90, 0, 0]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    translate([box_width - 13, -1, box_height - 13]) rotate([-90, 0, 0]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    
    // L bracket mounting holes for front panel
    // Front panel L bracket vertical leg holes (at box_width*1/3-21 and box_width*2/3-38, box_depth - wall_thickness)
    translate([box_width*1/3-17, -1, wall_thickness + 10])
    rotate([-90, 0, 0])
    color("pink") cylinder(h = wall_thickness + 2, d = 3.2, $fn=60);
    
    translate([box_width*2/3+32, -1, wall_thickness + 10])
    rotate([-90, 0, 0])
    color("pink") cylinder(h = wall_thickness + 2, d = 3.2, $fn=60);
}

// Back Panel Layout with Cutouts
module back_panel_layout() {
    // Rear socket rectangular cutout (aligned to assembled placement center)
    rear_x = 30;
    rear_z = box_height/2;
    translate([rear_x - rear_socket_cutout_w/2, -1, rear_z - rear_socket_cutout_h/2])
    cube([rear_socket_cutout_w, wall_thickness + 2, rear_socket_cutout_h]);
    
    // Rear socket mounting holes: 3.5mm diameter, 36mm apart horizontally
    translate([rear_x - rear_socket_mount_spacing / 2, -1, rear_z])
    rotate([-90, 0, 0])
    color("pink") cylinder(h = wall_thickness + 2, r = rear_socket_mount_hole_d/2, $fn=60);
    
    translate([rear_x + rear_socket_mount_spacing / 2, -1, rear_z])
    rotate([-90, 0, 0])
    color("pink") cylinder(h = wall_thickness + 2, r = rear_socket_mount_hole_d/2, $fn=60);
       
    // Corner mounting holes for corner brackets (M3 clearance)
    // Back panel corners - 13mm from edges
    translate([13, -1, 13]) rotate([-90, 0, 0]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    translate([box_width - 13, -1, 13]) rotate([-90, 0, 0]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    translate([13, -1, box_height - 13]) rotate([-90, 0, 0]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    translate([box_width - 13, -1, box_height - 13]) rotate([-90, 0, 0]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    
    // L bracket mounting holes for back panel
    // Back panel L bracket vertical leg holes (at box_width*1/3 and box_width*2/3, wall_thickness)
    translate([box_width*1/3-10, -1, wall_thickness + 10])
    rotate([-90, 0, 0])
    color("pink") cylinder(h = wall_thickness + 2, d = 3.2, $fn=60);
    
    translate([box_width*2/3, -1, wall_thickness + 10])
    rotate([-90, 0, 0])
    color("pink") cylinder(h = wall_thickness + 2, d = 3.2, $fn=60);
    
    // Protection circuit mounting holes (4 circuits x 4 holes each = 16 holes total)
    // Use the same parameters as in assembled_box
    protection_spacing_x = 68; // spacing between protection circuits
    protection_start_x = (box_width - 3 * protection_spacing_x) / 2 - 95; // center the row (same as assembled_box)
    protection_y = wall_thickness; // against back panel
    protection_z_offset_x = 0; // X offset adjustment - kart merkezi 100x100 kaymış
    protection_z_offset_y = 106.5; // Y offset adjustment - kart merkezi 100x100 kaymış
    protection_z_offset_z = 0; // Z offset adjustment
    protection_mount_hole_d = 3.2; // M3 clearance hole diameter
    
    // Protection circuit 1 (leftmost) mounting holes
    translate([protection_start_x, protection_y, box_height/2])
    rotate([-90, 0, 0])
    translate([protection_z_offset_x, protection_z_offset_y, protection_z_offset_z]) {
        translate([81, -142.5, -wall_thickness-2]) 
        color("pink") cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([81, -70, -wall_thickness-2]) 
        color("pink") cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([139, -142.5, -wall_thickness-2]) 
        color("pink") cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([139, -70, -wall_thickness-2]) 
        color("pink") cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
    }
    
    // Protection circuit 2 (second from left) mounting holes
    translate([protection_start_x + protection_spacing_x, protection_y, box_height/2])
    rotate([-90, 0, 0])
    translate([protection_z_offset_x, protection_z_offset_y, protection_z_offset_z]) {
        translate([81, -142.5, -wall_thickness-2]) 
        color("pink") cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([81, -70, -wall_thickness-2]) 
        color("pink") cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([139, -142.5, -wall_thickness-2]) 
        color("pink") cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([139, -70, -wall_thickness-2]) 
        color("pink") cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
    }
    
    // Protection circuit 3 (second from right) mounting holes
    translate([protection_start_x + 2 * protection_spacing_x, protection_y, box_height/2])
    rotate([-90, 0, 0])
    translate([protection_z_offset_x, protection_z_offset_y, protection_z_offset_z]) {
        translate([81, -142.5, -wall_thickness-2]) 
        color("pink") cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([81, -70, -wall_thickness-2]) 
        color("pink") cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([139, -142.5, -wall_thickness-2]) 
        color("pink") cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([139, -70, -wall_thickness-2]) 
        color("pink") cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
    }
    
    // Protection circuit 4 (rightmost) mounting holes
    translate([protection_start_x + 3 * protection_spacing_x, protection_y, box_height/2])
    rotate([-90, 0, 0])
    translate([protection_z_offset_x, protection_z_offset_y, protection_z_offset_z]) {
        translate([81, -142.5, -wall_thickness-2]) 
        color("pink") cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([81, -70, -wall_thickness-2]) 
        color("pink") cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([139, -142.5, -wall_thickness-2]) 
        color("pink") cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([139, -70, -wall_thickness-2]) 
        color("pink") cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
    }
}

// Left Side Panel Layout with Cutouts
module left_side_layout() {
    // 80mm fan mounting holes (left intake)
    fy = left_fan_center_y;
    fz = fan_center_z;
    for (dx = [-fan_hole_pitch/2, fan_hole_pitch/2]) {
        for (dz = [-fan_hole_pitch/2, fan_hole_pitch/2]) {
            translate([-1, fy + dx, fz + dz])
            rotate([0, 90, 0])
            color("pink") cylinder(h = wall_thickness + 2, r = fan_mount_hole_d/2, $fn=60);
        }
    }
    
    // Honeycomb grill cutout around fan
    for (iy = [-fan_grill_radius:honeycomb_cell:fan_grill_radius]) {
        for (iz = [-fan_grill_radius:honeycomb_cell:fan_grill_radius]) {
            cx = fy + iy + (abs(floor((iz+1000)/honeycomb_cell)) % 2 == 0 ? 0 : honeycomb_cell/2);
            cz = fz + iz;
            if ((iy*iy + iz*iz) <= fan_grill_radius*fan_grill_radius) {
                translate([-1, cx, cz])
                rotate([0, 90, 0])
                cylinder(h = wall_thickness + 2, r = (honeycomb_cell - honeycomb_strut)/2, $fn=60);
            }
        }
    }
    

    
    // Corner mounting holes for corner brackets (M3 clearance)
    // Left side corners - 13mm from edges
    translate([-1, 13, 13]) rotate([0, 90, 0]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    translate([-1, 13, box_height - 13]) rotate([0, 90, 0]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    translate([-1, box_depth - 13, 13]) rotate([0, 90, 0]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    translate([-1, box_depth - 13, box_height - 13]) rotate([0, 90, 0]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    
    // L bracket mounting holes for left side panel
    // Left side L bracket vertical leg hole (at box_depth/2-25, wall_thickness)
    translate([-1, box_depth/2-20, wall_thickness + 10])
    rotate([0, 90, 0])
    color("pink") cylinder(h = wall_thickness + 2, d = 3.2, $fn=60);
}

// Right Side Panel Layout with Cutouts
module right_side_layout() {
    // 80mm fan mounting holes (right exhaust)
    fy = right_fan_center_y;
    fz = fan_center_z;
    for (dx = [-fan_hole_pitch/2, fan_hole_pitch/2]) {
        for (dz = [-fan_hole_pitch/2, fan_hole_pitch/2]) {
            translate([-1, fy + dx, fz + dz])
            rotate([0, 90, 0])
            cylinder(h = wall_thickness + 2, r = fan_mount_hole_d/2, $fn=60);
        }
    }
    
    // Honeycomb grill cutout around fan
    for (iy = [-fan_grill_radius:honeycomb_cell:fan_grill_radius]) {
        for (iz = [-fan_grill_radius:honeycomb_cell:fan_grill_radius]) {
            cx = fy + iy + (abs(floor((iz+1000)/honeycomb_cell)) % 2 == 0 ? 0 : honeycomb_cell/2);
            cz = fz + iz;
            if ((iy*iy + iz*iz) <= fan_grill_radius*fan_grill_radius) {
                translate([-1, cx, cz])
                rotate([0, 90, 0])
                cylinder(h = wall_thickness + 2, r = (honeycomb_cell - honeycomb_strut)/2, $fn=60);
            }
        }
    }
    

    
    // Corner mounting holes for corner brackets (M3 clearance)
    // Right side corners - 13mm from edges
    translate([-1, 13, 13]) rotate([0, 90, 0]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    translate([-1, 13, box_height - 13]) rotate([0, 90, 0]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    translate([-1, box_depth - 13, 13]) rotate([0, 90, 0]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    translate([-1, box_depth - 13, box_height - 13]) rotate([0, 90, 0]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    
    // L bracket mounting holes for right side panel
    // Right side L bracket vertical leg hole (at box_depth/2+25, wall_thickness)
    translate([-1, box_depth/2+20, wall_thickness + 10])
    rotate([0, 90, 0])
    color("pink") cylinder(h = wall_thickness + 2, d = 3.2, $fn=60);
}

// Top Panel Layout with Cutouts
module top_panel_layout() {

    
    // Corner mounting holes for corner brackets (M3 clearance)
    // Top corners - 13mm from edges
    translate([13, 13, -1]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    translate([box_width - 13, 13, -1]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    translate([13, box_depth - 13, -1]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    translate([box_width - 13, box_depth - 13, -1]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
}

// Bottom Panel Layout with Cutouts
module bottom_panel_layout() {

    
    // Corner mounting holes for corner brackets (M3 clearance)
    // Bottom corners - 13mm from edges
    translate([13, 13, -1]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    translate([box_width - 13, 13, -1]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    translate([13, box_depth - 13, -1]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    translate([box_width - 13, box_depth - 13, -1]) color("pink") cylinder(h=wall_thickness + 2, d=3.2, $fn=60);
    
    // L bracket mounting holes for bottom panel
    // Left side L bracket horizontal leg hole (at box_depth/2-25, wall_thickness)
    translate([wall_thickness + 10, box_depth/2-20, -1])
    color("pink") cylinder(h = wall_thickness + 2, d = 3.2, $fn=60);
    
    // Right side L bracket horizontal leg hole (at box_depth/2+25, wall_thickness)
    translate([wall_thickness + box_width - 20, box_depth/2+20, -1])
    color("pink") cylinder(h = wall_thickness + 2, d = 3.2, $fn=60);
    
    // Front panel L bracket horizontal leg holes (at box_width*1/3-21 and box_width*2/3-38, box_depth - wall_thickness)
    translate([box_width*1/3-17, box_depth - wall_thickness - 10, -1])
    color("pink") cylinder(h = wall_thickness + 2, d = 3.2, $fn=60);
    
    translate([box_width*2/3+32, box_depth - wall_thickness - 10, -1])
    color("pink") cylinder(h = wall_thickness + 2, d = 3.2, $fn=60);
    
    // Back panel L bracket horizontal leg holes (at box_width*1/3 and box_width*2/3, wall_thickness)
    translate([box_width*1/3 - 10, wall_thickness + 10, -1])
    color("pink") cylinder(h = wall_thickness + 2, d = 3.2, $fn=60);
    
    translate([box_width*2/3, wall_thickness + 10, -1])
    color("pink") cylinder(h = wall_thickness + 2, d = 3.2, $fn=60);
    
    // Foot mounting holes (4x 8mm diameter, 40mm from corners)
    // Front left foot hole
    translate([40, 40, -1]) color("pink") cylinder(h=wall_thickness + 2, d=8, $fn=60);
    
    // Front right foot hole
    translate([box_width - 40, 40, -1]) color("pink") cylinder(h=wall_thickness + 2, d=8, $fn=60);
    
    // Back left foot hole
    translate([40, box_depth - 40, -1]) color("pink") cylinder(h=wall_thickness + 2, d=8, $fn=60);
    
    // Back right foot hole
    translate([box_width - 40, box_depth - 40, -1]) color("pink") cylinder(h=wall_thickness + 2, d=8, $fn=60);
    
    // Mid-shelf mounting holes (6x M3 clearance)
    psu_origin_x_1 = (box_width - psu_length) / 2;
    psu_origin_y_1 = (box_depth - psu_width) / 2;
    x_positions = [
        psu_origin_x_1 + psu_length * 0.15,
        psu_origin_x_1 + psu_length * 0.50,
        psu_origin_x_1 + psu_length * 0.85
    ];
    y_side0 = psu_origin_y_1 + mid_shelf_margin_from_psu;
    y_side1 = psu_origin_y_1 + psu_width - mid_shelf_margin_from_psu;
    standoff_pts = [
        [x_positions[0], y_side0], [x_positions[1], y_side0], [x_positions[2], y_side0],
        [x_positions[0], y_side1], [x_positions[1], y_side1], [x_positions[2], y_side1]
    ];
    
    for (p = standoff_pts) {
        translate([p[0], p[1], -0.1])
        color("pink") cylinder(h = wall_thickness + 0.2, r = mid_shelf_mount_hole_d/2, $fn=60);
    }
    
    // PSU mounting holes (4x M4 clearance)
    psu_origin_x_2 = (box_width - psu_length) / 2;
    psu_origin_y_2 = (box_depth - psu_width) / 2;
    psu_hole_positions = [
        [psu_origin_x_2 + psu_hole_margin_x, psu_origin_y_2 + psu_hole_margin_y],
        [psu_origin_x_2 + psu_length - psu_hole_margin_x, psu_origin_y_2 + psu_hole_margin_y],
        [psu_origin_x_2 + psu_hole_margin_x, psu_origin_y_2 + psu_width - psu_hole_margin_y],
        [psu_origin_x_2 + psu_length - psu_hole_margin_x, psu_origin_y_2 + psu_width - psu_hole_margin_y]
    ];
    
    for (p = psu_hole_positions) {
        translate([p[0], p[1], -0.1])
        color("pink") cylinder(h = wall_thickness + 0.2, r = m4_clearance_r, $fn=60);
    }
}

// PSU block and standoffs (mounted on bottom panel)
module psu_with_standoffs() {
    // Place PSU centered in the box footprint
    psu_origin_x = (box_width - psu_length) / 2;
    psu_origin_y = (box_depth - psu_width) / 2;
    psu_origin_z = wall_thickness + standoff_height;

    // Standoff positions at M4 holes (four corners with margins)
    hole_positions = [
        [psu_origin_x + psu_hole_margin_x, psu_origin_y + psu_hole_margin_y],
        [psu_origin_x + psu_length - psu_hole_margin_x, psu_origin_y + psu_hole_margin_y],
        [psu_origin_x + psu_hole_margin_x, psu_origin_y + psu_width - psu_hole_margin_y],
        [psu_origin_x + psu_length - psu_hole_margin_x, psu_origin_y + psu_width - psu_hole_margin_y]
    ];

    // Standoffs with M4 clearance
    for (p = hole_positions) {
        translate([p[0], p[1], wall_thickness])
        difference() {
            cylinder(h = standoff_height, r = standoff_radius, $fn=60);
            translate([0, 0, -0.1]) cylinder(h = standoff_height + 0.2, r = m4_clearance_r, $fn=60);
        }
    }

    // PSU rectangular prism
    translate([psu_origin_x, psu_origin_y, psu_origin_z])
    color("silver") cube([psu_length, psu_width, psu_height]);
}

// Mid-shelf with 6 standoffs around PSU footprint
module mid_shelf_over_psu(show_standoffs = true) {
    psu_origin_x = (box_width - psu_length) / 2;
    psu_origin_y = (box_depth - psu_width) / 2;
    // Standoffs should start on bottom panel and reach the shelf
    base_z = wall_thickness;                                 // start at bottom panel top
    shelf_z = base_z + mid_shelf_standoff_height;            // top of standoffs / shelf bottom

    // Six standoff positions along PSU long edges (3 per long side)
    // Long edges are along X direction at Y = psu_origin_y and psu_origin_y + psu_width
    x_positions = [
        psu_origin_x + psu_length * 0.15,
        psu_origin_x + psu_length * 0.50,
        psu_origin_x + psu_length * 0.85
    ];
    y_side0 = psu_origin_y + mid_shelf_margin_from_psu;              // may be outside if negative
    y_side1 = psu_origin_y + psu_width - mid_shelf_margin_from_psu;  // mirrored offset
    standoff_pts = [
        [x_positions[0], y_side0], [x_positions[1], y_side0], [x_positions[2], y_side0],
        [x_positions[0], y_side1], [x_positions[1], y_side1], [x_positions[2], y_side1]
    ];

    // Standoffs (solid posts from bottom up)
    if (show_standoffs) {
        color("lightblue")
        for (p = standoff_pts) {
            translate([p[0], p[1], base_z])
            cylinder(h = mid_shelf_standoff_height, r = mid_shelf_standoff_diameter/2, $fn=60);
            // Holes in bottom panel for bolts (clearance)
            translate([p[0], p[1], -0.1])
            cylinder(h = wall_thickness + 0.2, r = mid_shelf_mount_hole_d/2, $fn=60);
        }
    }

    // Compact plate: only around PSU with small margins
    plate_x = psu_origin_x - mid_shelf_plate_margin_x;
    plate_y = psu_origin_y - mid_shelf_plate_margin_y;
    plate_w = psu_length + 2*mid_shelf_plate_margin_x;
    plate_d = psu_width + 2*mid_shelf_plate_margin_y;
    translate([plate_x, plate_y, shelf_z])
    color("lightblue", alpha=0.8)
    difference() {
        cube([plate_w, plate_d, mid_shelf_plate_thickness]);
        // Through holes in plate aligned with standoffs
        for (p = standoff_pts) {
            translate([p[0] - plate_x, p[1] - plate_y, -0.1])
            cylinder(h = mid_shelf_plate_thickness + 0.2, r = mid_shelf_mount_hole_d/2, $fn=60);
        }
        // Controller board mounting holes (custom-aligned positions)
        cdx = controller_board_size/2 - controller_hole_inset;
        controller_holes = [
            [controller_pos_x - cdx + 133.3, controller_pos_y - cdx - 83],
            [controller_pos_x + cdx + 136.7, controller_pos_y - cdx - 82.8],
            [controller_pos_x - cdx + 133.3, controller_pos_y + cdx - 80],
            [controller_pos_x + cdx + 137, controller_pos_y + cdx - 80]
        ];
        for (hp = controller_holes) {
            translate([hp[0] - plate_x, hp[1] - plate_y, -0.1])
            color("pink") cylinder(h = mid_shelf_plate_thickness + 0.2, d = controller_hole_d, $fn=60);
        }

        // XL4016 module mounting holes (4 modules x 4 holes)
        module_centers = [
            [xl4016_start_x, xl4016_start_y],
            [xl4016_start_x + xl4016_spacing_x, xl4016_start_y],
            [xl4016_start_x, xl4016_start_y + xl4016_spacing_y],
            [xl4016_start_x + xl4016_spacing_x, xl4016_start_y + xl4016_spacing_y]
        ];
        for (mc = module_centers) {
            for (o = xl4016_hole_offsets) {
                translate([mc[0] + o[0] - plate_x, mc[1] + o[1] - plate_y, -0.1])
                color("pink") cylinder(h = mid_shelf_plate_thickness + 0.2, d = xl4016_hole_d, $fn=60);
            }
        }

        // Derive controller keepout from hole bounding box + margin
        c0 = controller_holes[0];
        c1 = controller_holes[1];
        c2 = controller_holes[2];
        c3 = controller_holes[3];
        ctrl_min_x = min(c0[0], c1[0], c2[0], c3[0]) - controller_keepout_margin;
        ctrl_max_x = max(c0[0], c1[0], c2[0], c3[0]) + controller_keepout_margin;
        ctrl_min_y = min(c0[1], c1[1], c2[1], c3[1]) - controller_keepout_margin;
        ctrl_max_y = max(c0[1], c1[1], c2[1], c3[1]) + controller_keepout_margin;

        // Honeycomb ventilation on mid-shelf (excluding keepout rectangles)
        hx0 = mid_shelf_honey_border;
        hy0 = mid_shelf_honey_border;
        hx1 = plate_w - mid_shelf_honey_border;
        hy1 = plate_d - mid_shelf_honey_border;
        for (ix = [hx0:honeycomb_cell:hx1]) {
            for (iy = [hy0:honeycomb_cell:hy1]) {
                ox = ((floor((iy - hy0)/honeycomb_cell)) % 2 == 0) ? 0 : honeycomb_cell/2;
                px = ix + ox;
                py = iy;
                // Convert to global XY for keepout checks
                gx = plate_x + px;
                gy = plate_y + py;
                // Keepouts under controller and XL4016 modules
                inside_controller = (gx >= ctrl_min_x) && (gx <= ctrl_max_x) && (gy >= ctrl_min_y) && (gy <= ctrl_max_y);
                inside_xl1 = (abs(gx - xl4016_start_x) <= xl4016_keepout_w/2) && (abs(gy - xl4016_start_y) <= xl4016_keepout_d/2);
                inside_xl2 = (abs(gx - (xl4016_start_x + xl4016_spacing_x)) <= xl4016_keepout_w/2) && (abs(gy - xl4016_start_y) <= xl4016_keepout_d/2);
                inside_xl3 = (abs(gx - xl4016_start_x) <= xl4016_keepout_w/2) && (abs(gy - (xl4016_start_y + xl4016_spacing_y)) <= xl4016_keepout_d/2);
                inside_xl4 = (abs(gx - (xl4016_start_x + xl4016_spacing_x)) <= xl4016_keepout_w/2) && (abs(gy - (xl4016_start_y + xl4016_spacing_y)) <= xl4016_keepout_d/2);
                if (px > hx0 && px < hx1 && py > hy0 && py < hy1 && !inside_controller && !inside_xl1 && !inside_xl2 && !inside_xl3 && !inside_xl4) {
                    translate([px, py, -0.1])
                    cylinder(h = mid_shelf_plate_thickness + 0.2, r = (honeycomb_cell - honeycomb_strut)/2, $fn=60);
                }
            }
        }
    }

    // (visual markers removed)
}

// Front panel with highlighted ammeter holes
module front_panel_with_highlighted_ammeters() {
    difference() {
        // Main panel
        color("lightgray")
        cube([box_width, wall_thickness, box_height]);
        
        // Highlight ammeter holes in red
        color("red")
        for(i = [0:3]) {
            x_pos = spacing + i * (multimeter_width + spacing) + multimeter_width/2;
            z_pos = box_height/2;
            
            translate([x_pos - multimeter_width/2, -1, z_pos - multimeter_height/2])
            cube([multimeter_width, wall_thickness + 2, multimeter_height]);
        }
    }
}

// Import STL multimeter
module imported_multimeter() {
    import("multimeter/v & a metr.stl", convexity=10);
}

// Import banana connector
module banana_connector() {
    import("banana/banana.stl", convexity=10);
}

// Import toggle switch
module toggle_switch() {
    import("switch/E-TEN 1021 On_Off Toggle Switch v7.stl", convexity=10);
}

// Import 5mm LED indicator
module led_indicator() {
    import("led/TC-R9-107 5mm v3.stl", convexity=10);
}

// Import potentiometer
module pot_component() {
    import("pot/pot.stl", convexity=10);
}

// Import knob for potentiometer
module knob_component() {
    import("pot/Knob.stl", convexity=10);
}

// Rocker switch component or placeholder
module rocker_switch_component() {
    if (use_rocker_stl) {
        import(rocker_stl_path, convexity=10);
    } 
}

// Back panel socket (Shapes011)
module rear_socket() {
    import("socket/Shapes011.stl", convexity=10);
}

// 80mm fan STL
module fan_component() {
    import("fan/fan.stl", convexity=10);
}

// Fuse holder STL
module fuse_holder_component() {
    import("fuse/KLS5-258 (FH-B02), Fuse holder 5,2х20.stl", convexity=10);
}

// Dual USB STL
module dual_usb_component() {
    import("usb/Dual USB A charger fini v004.stl", convexity=10);
}

// U1E STL
module u1e_component() {
    import("usb/u1e.stl", convexity=10);
}

// Import STL protection circuit
module protection_circuit() {
    import("circuit/Protection_full.stl", convexity=10);
}

// Import STL controller circuit
module controller_circuit() {
    //import("circuit/Controller_full.stl", convexity=10);
}

// Import STL XL4016 buck converter
module xl4016_converter() {
    import("circuit/XL4016E1 8A Buck Converter.stl", convexity=10);
}

// XL4016 montaj delikleri (modul bazli noktasina gore yerel ofsetler)
xl4016_hole_d = 3.2; // M3 clearance
// Varsayilan tahmini ofsetler (lutfen kartin gercek deliklerine gore guncelleyiniz)
xl4016_hole_offsets = [
    [-29.5, -13.5],
    [ 29.5, -13.5],
    [-29.5,  13.5],
    [ 29.5,  13.5]
];


// Assembly view (all panels together with components)
module assembled_box(show_midshelf_only = false) {
    if (!show_midshelf_only) {
        // Front panel
        translate([0, box_depth - wall_thickness, 0])
        front_panel_layout();
        
        // Front panel text
        front_panel_text();
        
        // Back panel
        translate([0, 0, 0])
        back_panel_layout();
        
        // Back panel socket placement (centered)
        translate([30, 0, box_height / 2])
        rotate([0, 0, 0])
        rear_socket();
        
        // Left side
        translate([0, 0, 0])
        left_side_layout();
        
        // Right side
        translate([box_width - wall_thickness, 0, 0])
        right_side_layout();
        
        // Top panel
        translate([0, 0, box_height - wall_thickness])
        top_panel_layout();
        
        // Bottom panel
        translate([0, 0, 0])
        bottom_panel_layout();
    
        // Add 4 STL multimeters to front panel
        for(i = [0:3]) {
            // Center of each multimeter cutout (matches front_panel logic)
            x_center = spacing + i * (multimeter_width + spacing) + multimeter_width/2;
            x_abs = unit_x_abs(i);
            // Place multimeter STL
            translate([x_abs, box_depth + wall_thickness - multimeter_depth + 13, multimeter_stl_center_z])
            rotate([-90, 0, 0])
            translate([-multimeter_width/2, 0, -multimeter_height/2])
            imported_multimeter();

            // Banana jacks aligned to 8mm holes on front panel
            banana_jack_z = banana_hole_center_z; // matches front_panel's z_pos/2 + offset + 5mm
            // Left banana connector (align to hole; adjust STL origin)
            translate([x_abs - banana_offset_x + banana_stl_dx_left, banana_stl_y, banana_jack_z])
            rotate([-90, 0, 90])
            banana_connector();
            // Right banana connector (align to hole; adjust STL origin)
            translate([x_abs + banana_offset_x + banana_stl_dx_right, banana_stl_y, banana_jack_z])
            rotate([-90, 0, 90])
            banana_connector();

            // Toggle switch STL aligned with toggle hole (x_center - 25, original jack_z)
            jack_z = toggle_center_z; // original position without offset
            translate([x_abs - 27, toggle_stl_y, jack_z])
            rotate([90, 0, 180])
            toggle_switch();
            
            // LED STL aligned with LED hole (x_center + 3, jack_z + 15)
            translate([x_abs + 3, led_front_unit_stl_y, led_center_z])
            rotate([-90, 0, 0])
            led_indicator();
        }

        // Fuse holders aligned to fuse holes (one per unit)
        for(i = [0:3]) {
            x_center = spacing + i * (multimeter_width + spacing) + multimeter_width/2;
            x_abs = unit_x_abs(i);
            // Fuse hole center matches LED X and is below jack line by fuse_hole_offset_z
            jack_z = toggle_center_z;
            translate([x_abs + led_offset_x, box_depth + 5, jack_z - fuse_hole_offset_z])
            rotate([-90, 0, 0])
            fuse_holder_component();
        }

        // Place two potentiometers relative to the leftmost screen
        leftmost_screen_x = leftmost_screen_center_x;
        pot1_x_abs = pot1_center_x; // 40mm to the left of leftmost screen (centered)
        pot2_x_abs = pot2_center_x; // 50mm to the left of leftmost screen (diagonal)
        pot_center_z = pot_center_z_base;
        pot_z1 = pot2_center_z;
        pot_z2 = pot1_center_z;

        // Upper pot (centered to the left of screen)
        translate([pot1_x_abs, box_depth - 6, pot_z2])
        rotate([-90, 0, 0])
        pot_component();

        // Lower pot (diagonal to the left of screen)
        translate([pot2_x_abs, box_depth - 6, pot_z1])
        rotate([-90, 0, 0])
        pot_component();

        // Knobs on potentiometers (slightly in front of the panel)
        // Upper knob (centered)
        translate([pot1_x_abs, box_depth + 5, pot_z2])
        rotate([-90, 0, 0])
        knob_component();

        // Lower knob (diagonal)
        translate([pot2_x_abs, box_depth + 5, pot_z1])
        rotate([-90, 0, 0])
        knob_component();

        // Rocker switch at far left margin (align STL to cutout)
        rocker_x_abs = rocker_center_x; // same X as cutout center, moved 5mm right
        rocker_z_abs = rocker_center_z;       // same Z as cutout center + 5mm yukarı
        translate([rocker_x_abs + rocker_stl_offset_x, box_depth + rocker_stl_offset_y, rocker_z_abs + rocker_stl_offset_z])
        rotate([0, 0, 0])
        rocker_switch_component();

        // LED above rocker switch (aligned with front-panel hole)
        translate([rocker_x_abs, led_front_unit_stl_y, rocker_z_abs + rocker_cutout_h/2 + 10])
        rotate([-90, 0, 0])
        led_indicator();
        
        // Dual USB (aligned with front-panel cutout) - standalone position
        rotate([0, 0, 180])
        translate([-3248.2, -1963, 19])
        color("orange")
        dual_usb_component();
        
        // U1E component - standalone position
        u1e_x_abs = u1e_center_x; // 71mm to the left of dual USB (same as front panel)
        u1e_z_abs = 12; // Same Z position as front panel
        translate([u1e_x_abs, box_depth - 15, u1e_z_abs + 1])
        rotate([0, 0, 0])
        color("orange")
        u1e_component();
       
        // Fans on side panels (placed inside)
        // Left intake fan
        translate([wall_thickness + 13, left_fan_center_y, fan_center_z])
        rotate([0, 90, 0])
        fan_component();
        // Right exhaust fan
        translate([box_width - wall_thickness - 13, right_fan_center_y, fan_center_z])
        rotate([0, -90, 0])
        fan_component();

        // PSU on 10mm standoffs at bottom panel
        psu_with_standoffs();
    }

    // Mid-shelf over PSU
    mid_shelf_over_psu(show_standoffs = !show_midshelf_only);
    
    // If showing midshelf only, don't render other components
    if (!show_midshelf_only) {
        // Circuit components on mid-shelf
        // Calculate shelf height
        shelf_z = wall_thickness + mid_shelf_standoff_height + mid_shelf_plate_thickness;
    
    // Protection circuit positioning parameters
    protection_spacing_x = 68; // spacing between protection circuits
    protection_start_x = (box_width - 3 * protection_spacing_x) / 2 - 95; // center the row
    protection_y = wall_thickness; // against back panel
    protection_z_offset_x = 0; // X offset adjustment - kart merkezi 100x100 kaymış
    protection_z_offset_y = 106.5; // Y offset adjustment - kart merkezi 100x100 kaymış
    protection_z_offset_z = 0; // Z offset adjustment
    
    // Protection circuit standoffs and mounting holes parameters
    protection_standoff_height = 5; // 5mm standoffs
    protection_standoff_diameter = 6; // standoff diameter
    protection_mount_hole_d = 3.2; // M3 clearance hole diameter
    protection_standoff_offset = 15; // distance from circuit edge to standoff center
    
    // Protection circuit 1 (leftmost) with standoffs
    translate([protection_start_x, protection_y, box_height/2])
    rotate([-90, 0, 0])
    translate([protection_z_offset_x, protection_z_offset_y, protection_z_offset_z]) {
        // Standoffs (4x) - positioned at real mounting hole locations
        color("silver")
        translate([81, -142.5, 0]) cylinder(h = protection_standoff_height, r = protection_standoff_diameter/2, $fn=60);
        translate([81, -70, 0]) cylinder(h = protection_standoff_height, r = protection_standoff_diameter/2, $fn=60);
        translate([139, -142.5, 0]) cylinder(h = protection_standoff_height, r = protection_standoff_diameter/2, $fn=60);
        translate([139, -70, 0]) cylinder(h = protection_standoff_height, r = protection_standoff_diameter/2, $fn=60);
        
        // Mounting holes in back panel (4x)
        color("red")
        translate([81, -142.5, -wall_thickness-2]) cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([81, -70, -wall_thickness-2]) cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([139, -142.5, -wall_thickness-2]) cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([139, -70, -wall_thickness-2]) cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        
        // Protection circuit
        color("green")
        translate([0, 0, protection_standoff_height])
        protection_circuit();
    }
    
    // Protection circuit 2 (second from left) with standoffs
    translate([protection_start_x + protection_spacing_x, protection_y, box_height/2])
    rotate([-90, 0, 0])
    translate([protection_z_offset_x, protection_z_offset_y, protection_z_offset_z]) {
        // Standoffs (4x) - positioned at real mounting hole locations
        color("silver")
        translate([81, -142.5, 0]) cylinder(h = protection_standoff_height, r = protection_standoff_diameter/2, $fn=60);
        translate([81, -70, 0]) cylinder(h = protection_standoff_height, r = protection_standoff_diameter/2, $fn=60);
        translate([139, -142.5, 0]) cylinder(h = protection_standoff_height, r = protection_standoff_diameter/2, $fn=60);
        translate([139, -70, 0]) cylinder(h = protection_standoff_height, r = protection_standoff_diameter/2, $fn=60);
        
        // Mounting holes in back panel (4x)
        color("red")
        translate([81, -142.5, -wall_thickness-2]) cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([81, -70, -wall_thickness-2]) cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([139, -142.5, -wall_thickness-2]) cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([139, -70, -wall_thickness-2]) cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        
        // Protection circuit
        color("green")
        translate([0, 0, protection_standoff_height])
        protection_circuit();
    }
    
    // Protection circuit 3 (second from right) with standoffs
    translate([protection_start_x + 2 * protection_spacing_x, protection_y, box_height/2])
    rotate([-90, 0, 0])
    translate([protection_z_offset_x, protection_z_offset_y, protection_z_offset_z]) {
        // Standoffs (4x) - positioned at real mounting hole locations
        color("silver")
        translate([81, -142.5, 0]) cylinder(h = protection_standoff_height, r = protection_standoff_diameter/2, $fn=60);
        translate([81, -70, 0]) cylinder(h = protection_standoff_height, r = protection_standoff_diameter/2, $fn=60);
        translate([139, -142.5, 0]) cylinder(h = protection_standoff_height, r = protection_standoff_diameter/2, $fn=60);
        translate([139, -70, 0]) cylinder(h = protection_standoff_height, r = protection_standoff_diameter/2, $fn=60);
        
        // Mounting holes in back panel (4x)
        color("red")
        translate([81, -142.5, -wall_thickness-2]) cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([81, -70, -wall_thickness-2]) cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([139, -142.5, -wall_thickness-2]) cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([139, -70, -wall_thickness-2]) cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        
        // Protection circuit
        color("green")
        translate([0, 0, protection_standoff_height])
        protection_circuit();
    }
    
    // Protection circuit 4 (rightmost) with standoffs
    translate([protection_start_x + 3 * protection_spacing_x, protection_y, box_height/2])
    rotate([-90, 0, 0])
    translate([protection_z_offset_x, protection_z_offset_y, protection_z_offset_z]) {
        // Standoffs (4x) - positioned at real mounting hole locations
        color("silver")
        translate([81, -142.5, 0]) cylinder(h = protection_standoff_height, r = protection_standoff_diameter/2, $fn=60);
        translate([81, -70, 0]) cylinder(h = protection_standoff_height, r = protection_standoff_diameter/2, $fn=60);
        translate([139, -142.5, 0]) cylinder(h = protection_standoff_height, r = protection_standoff_diameter/2, $fn=60);
        translate([139, -70, 0]) cylinder(h = protection_standoff_height, r = protection_standoff_diameter/2, $fn=60);
        
        // Mounting holes in back panel (4x)
        color("red")
        translate([81, -142.5, -wall_thickness-2]) cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([81, -70, -wall_thickness-2]) cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([139, -142.5, -wall_thickness-2]) cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        translate([139, -70, -wall_thickness-2]) cylinder(h = wall_thickness + 2, r = protection_mount_hole_d/2, $fn=60);
        
        // Protection circuit
        color("green")
        translate([0, 0, protection_standoff_height])
        protection_circuit();
    }
    
    // 1 Controller circuit on mid-shelf with 3mm standoffs
    controller_standoff_height = 3; // 3mm standoffs
    
    // Controller circuit positioned on mid-shelf using shared params
    translate([controller_pos_x, controller_pos_y, shelf_z])
    rotate([0, 0, 0])
    color("blue")
    controller_circuit();
    
    // 4 XL4016 buck converters on mid-shelf
    // Position them in a 2x2 grid, centered on the shelf
    xl4016_spacing_x = 80; // spacing between XL4016 modules
    xl4016_spacing_y = 60; // spacing between XL4016 modules
    xl4016_start_x = (box_width - xl4016_spacing_x) / 2 - 50; // center the grid
    xl4016_start_y = (box_depth - xl4016_spacing_y) / 2 + 2; // center the grid
    
    // XL4016 module 1 (top-left)
    translate([xl4016_start_x, xl4016_start_y, shelf_z])
    rotate([90, 0, 0])
    color("orange")
    xl4016_converter();
    
    // XL4016 module 2 (top-right)
    translate([xl4016_start_x + xl4016_spacing_x, xl4016_start_y, shelf_z])
    rotate([90, 0, 0])
    color("orange")
    xl4016_converter();
    
    // XL4016 module 3 (bottom-left)
    translate([xl4016_start_x, xl4016_start_y + xl4016_spacing_y, shelf_z])
    rotate([90, 0, 0])
    color("orange")
    xl4016_converter();
    
    // XL4016 module 4 (bottom-right)
    translate([xl4016_start_x + xl4016_spacing_x, xl4016_start_y + xl4016_spacing_y, shelf_z])
    rotate([90, 0, 0])
    color("orange")
    xl4016_converter();

    // Corner brackets at all 8 corners of the box
    // Bottom corners
    translate([wall_thickness, wall_thickness, wall_thickness])
    color("orange")
    triangle_corner(0, 0, 0);
    
    translate([box_width - wall_thickness, wall_thickness, wall_thickness])
    color("orange")
    triangle_corner(0, 0, 90);
    
    translate([wall_thickness, box_depth - wall_thickness, wall_thickness])
    color("orange")
    triangle_corner(0, 0, -90);
    
    translate([box_width - wall_thickness, box_depth - wall_thickness, wall_thickness])
    color("orange")
    triangle_corner(90, -90, 0);
    
    // Top corners
    translate([wall_thickness, wall_thickness, box_height - wall_thickness])
    color("orange")
    triangle_corner(0, 90, 0);
    
    translate([box_width - wall_thickness, wall_thickness, box_height - wall_thickness])
    color("orange")
    triangle_corner(-90, 90, 0);
    
    translate([wall_thickness, box_depth - wall_thickness, box_height - wall_thickness])
    color("orange")
    triangle_corner(180, 0, 0);
    
    translate([box_width - wall_thickness, box_depth - wall_thickness, box_height - wall_thickness])
    color("orange")
    triangle_corner(0, -180, 90);
    
    // L brackets for strengthening connections
    // 1 L bracket for each side panel (left and right) - connecting bottom and side
    // Left side L bracket - connects bottom panel and left side panel
    translate([wall_thickness, box_depth/2-25, wall_thickness])
    rotate([0, 0, 0])
    color("silver")
    l_bracket();
    
    // Right side L bracket - connects bottom panel and right side panel  
    translate([box_width - wall_thickness, box_depth/2+25, wall_thickness])
    rotate([0, 0, 180])
    color("silver")
    l_bracket();
    
    // 2 L brackets for front panel - connects bottom panel and front panel
    translate([box_width*1/3 - 22, box_depth - wall_thickness, wall_thickness])
    rotate([180, 180, 90])
    color("silver")
    l_bracket();
    
    translate([box_width*2/3 + 27, box_depth - wall_thickness, wall_thickness])
    rotate([180, 180, 90])
    color("silver")
    l_bracket();
    
    // 2 L brackets for back panel - connects bottom panel and back panel
    translate([box_width*1/3 - 5, wall_thickness, wall_thickness])
    rotate([0, 0, 90])
    color("silver")
    l_bracket();
    
    translate([box_width*2/3 + 5, wall_thickness, wall_thickness])
    rotate([0, 0, 90])
    color("silver")
    l_bracket();
    }
}

// 3D Finger Joint Box visualization with face control
module finger_joint_box_3d(showTop = true, showBottom = true, showFront = true, 
                           showBack = true, showLeft = true, showRight = true) {
    // Generate 3D visualization of the finger joint box
    // This shows how the box will look when assembled
    // Positioned to match the existing assembled box location
    
    xDim = box_width;
    yDim = box_depth;
    zDim = box_height;
    finger = finger_width;
    material = wall_thickness;
    text = false;
    
    // Position the finger joint box to match the existing assembled box
    // The assembled box is positioned at origin (0,0,0)
    // The finger joint library centers the box by default, so we need to adjust
    translate([xDim/2, yDim/2, zDim/2])
    color("lightgray")  // Professional lab equipment grey color
    3Dlayout(xDim = xDim, 
             yDim = yDim, 
             zDim = zDim, 
             finger = finger, 
             material = material,
             text = text,
             showTop = showTop,
             showBottom = showBottom,
             showFront = showFront,
             showBack = showBack,
             showLeft = showLeft,
             showRight = showRight);
}

// Finger joint box WITH cutouts and face control
module finger_joint_box_with_cutouts(showTop = true, showBottom = true, showFront = true, 
                                     showBack = true, showLeft = true, showRight = true) {
    difference() {
        // Base finger joint box structure with face control
        finger_joint_box_3d(showTop = showTop, showBottom = showBottom, 
                           showFront = showFront, showBack = showBack, 
                           showLeft = showLeft, showRight = showRight);
        
        // All the cutouts from the layout modules
        // Front panel cutouts (only if front is shown)
        if (showFront) {
            translate([0, box_depth - wall_thickness, 0])
            front_panel_layout();
        }
        
        // Back panel cutouts (only if back is shown)
        if (showBack) {
            translate([0, 0, 0])
            back_panel_layout();
        }
        
        // Left side cutouts (only if left is shown)
        if (showLeft) {
            translate([0, 0, 0])
            left_side_layout();
        }
        
        // Right side cutouts (only if right is shown)
        if (showRight) {
            translate([box_width - wall_thickness, 0, 0])
            right_side_layout();
        }
        
        // Top panel cutouts (only if top is shown)
        if (showTop) {
            translate([0, 0, box_height - wall_thickness])
            top_panel_layout();
        }
        
        // Bottom panel cutouts (only if bottom is shown)
        if (showBottom) {
            translate([0, 0, 0])
            bottom_panel_layout();
        }
    }
}
// ---------- Panel helpers (2D exports) ----------
// Usage:
//   // 1) Comment out the 3D top-level call:
//   // finger_joint_box_with_cutouts(...);
//
//   // 2) Export ONE panel at a time (F6 -> Export DXF/SVG):
//   panel_2d("front");   // or "back","left","right","top","bottom"

module panel_2d(side="front") {
    // Simple piece number mapping (avoid OpenSCAD for loop issues)
    piece_num = (side == "bottom") ? 0 :
               (side == "top") ? 1 :
               (side == "back") ? 2 :
               (side == "right") ? 3 :
               (side == "front") ? 4 :
               (side == "left") ? 5 : -1;
    
    echo(str("panel_2d: side=", side, " piece_num=", piece_num));
    
    if (piece_num == -1) {
        echo(str("panel_2d: unknown side = ", side));
    } else {
        // Use fingerjoint library for the panel with finger joints
        difference() {
            2Dlayout(xDim = box_width, 
                     yDim = box_depth, 
                     zDim = box_height, 
                     finger = finger_width, 
                     material = wall_thickness,
                     piece = piece_num);
            
            // Apply appropriate cutouts based on side
            if (side == "front") {
                projection() {
                    rotate([90, 0, 0])
                    translate([0, 0, box_depth - wall_thickness])
                    front_panel_layout();
                }
            }
            else if (side == "back") {
                projection() {
                    rotate([90, 0, 0])
                    back_panel_layout();
                }
            }
            else if (side == "left") {
                projection() {
                    rotate([0, 90, 0])
                    left_side_layout();
                }
            }
            else if (side == "right") {
                projection() {
                    rotate([0, -90, 0])
                    translate([-box_width + wall_thickness, 0, 0])
                    right_side_layout();
                }
            }
            else if (side == "top") {
                projection() {
                    translate([0, 0, box_height - wall_thickness])
                    top_panel_layout();
                }
            }
            else if (side == "bottom") {
                projection() {
                    bottom_panel_layout();
                }
            }
        }
    }
}

// ========== GÖRÜNÜM SEÇENEKLERİ ==========
// Aşağıdaki satırlardan birini aktif ederek farklı görünümler elde edebilirsiniz

// 1. Tüm bileşenlerle birlikte monte edilmiş kutu
//assembled_box();

// 1a. Sadece midshelf tablası (kesiklerle birlikte)
//assembled_box(show_midshelf_only = true);

// 2. Sadece finger joint yapısı (tüm kenarlar)
//finger_joint_box_3d();

// 3. Cutout'larla birlikte finger joint kutusu (tüm kenarlar)
//finger_joint_box_with_cutouts();

// ========== KENAR BAZLI GÖRÜNÜMLER ==========

// 4. İç görünüm için üst kapalı (üst yüzey gizli)
//finger_joint_box_with_cutouts(showTop = false);

// 5. Ön panel odaklı görünüm (sadece ön)
//finger_joint_box_with_cutouts(showBack = false, showLeft = false, showRight = false, showTop = false, showBottom = false);

// 6. Arka panel odaklı görünüm (sadece arka ve alt)
//finger_joint_box_with_cutouts(showFront = false, showLeft = false, showRight = false, showTop = false, showBottom = false);

finger_joint_box_with_cutouts(showFront = true, showLeft = false, showRight = false, showTop = false, showBack = false, showBottom = false);

// 7. Yan paneller odaklı görünüm (sadece yan paneller ve alt)
//finger_joint_box_with_cutouts(showFront = false, showBack = false, showTop = false);

// 8. Alt panel odaklı görünüm (sadece alt)
//finger_joint_box_with_cutouts(showTop = false, showFront = false, showBack = false, showLeft = false, showRight = false);

// 9. Eksik üst ve ön - iç görünüm
//finger_joint_box_with_cutouts(showTop = false, showFront = false);

// 10. Sadece iskelet yapısı (kenar çizgileri için)
//finger_joint_box_3d(showTop = false, showBottom = false);

