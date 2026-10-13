// Wind v2.0 Package 2: Mast Structure & Tilt-Up Erection Kinematics
// Parametric 3D Model for Modular Mast Sections, Gin-Pole A-Frame,
// Winch Rigging Line, Guy-Wire Cables, and Tilt-Up Erection Animation.
//
// Units: millimeters (OpenSCAD standard)

$fn = 32;

// --- Key Dimensions ---
// Elevation tilt angle of the mast:
// 0   = Horizontal assembly atop/alongside container
// 45  = Mid-elevation lift transition
// 90  = Fully upright, vertical locked position
tilt_angle = 45; // [0:90]

// Container & Foundation dimensions (from Package 1)
L_CONT = 6058;
W_CONT = 2438;
H_CONT = 2591;

// Mast Dimensions
HUB_HEIGHT   = 24000; // 24 m
NUM_SECTIONS = 5;
L_SEC        = HUB_HEIGHT / NUM_SECTIONS; // 4800 mm (< 5890 mm container internal length)
MAST_OD      = 500;   // 500 mm OD
MAST_WALL    = 8;     // 8 mm wall
FLANGE_OD    = 660;
FLANGE_THICK = 35;

// Gin-Pole (A-Frame) Dimensions
L_GIN_POLE   = 7000;  // 7.0 m
GIN_LEG_OD   = 219;   // 219 mm structural pipe
GIN_SPREAD_W = 1800;  // Base spread between A-frame legs

// Nacelle & Rotor Tophead Simulation
NACELLE_L    = 2800;
NACELLE_W    = 1200;
NACELLE_H    = 1400;
ROTOR_DIA    = 26000; // 26 m rotor diameter

// Winch location (atop container)
WINCH_X = -4500;
WINCH_Z = H_CONT + 150;

// Visualization Flags
SHOW_CONTAINER_BASE = true;
SHOW_MODULAR_MAST   = true;
SHOW_GIN_POLE       = true;
SHOW_WINCH_CABLE    = true;
SHOW_GUY_WIRES      = true;
SHOW_NACELLE_HEAD   = true;

// --- Modules ---

// Modular Mast Section (Flanged joint)
module modular_mast_section(index = 0) {
    color([0.88, 0.90, 0.93]) {
        // Main tubular steel shell
        difference() {
            cylinder(d = MAST_OD, h = L_SEC);
            translate([0, 0, -1])
                cylinder(d = MAST_OD - 2*MAST_WALL, h = L_SEC + 2);
        }
        // Bottom flange
        difference() {
            cylinder(d = FLANGE_OD, h = FLANGE_THICK);
            translate([0, 0, -1])
                cylinder(d = MAST_OD - 2*MAST_WALL, h = FLANGE_THICK + 2);
        }
        // Top flange
        translate([0, 0, L_SEC - FLANGE_THICK])
            difference() {
                cylinder(d = FLANGE_OD, h = FLANGE_THICK);
                translate([0, 0, -1])
                    cylinder(d = MAST_OD - 2*MAST_WALL, h = FLANGE_THICK + 2);
            }
        // Bolting visual ring
        for (i = [0:11]) {
            rotate([0, 0, i * 30])
                translate([(MAST_OD + FLANGE_OD)/4, 0, FLANGE_THICK/2])
                    color([0.2, 0.2, 0.2])
                    cylinder(d = 24, h = FLANGE_THICK + 10, center = true);
        }
    }
}

// Complete 24 m Modular Mast Assembly
module full_modular_mast() {
    for (s = [0:NUM_SECTIONS-1]) {
        translate([0, 0, s * L_SEC])
            modular_mast_section(s);
    }
}

// Gin-Pole A-Frame Structure (Rigid 90 deg relative to mast)
module gin_pole_a_frame() {
    color([0.85, 0.55, 0.15]) { // High-visibility industrial yellow
        // Two legs tapering to an apex
        for (dy = [-1, 1]) {
            hull() {
                // Foot pivot at trunnion
                translate([0, dy * (GIN_SPREAD_W/2), 0])
                    sphere(d = GIN_LEG_OD);
                // Apex sheave block at L_GIN_POLE
                translate([0, 0, L_GIN_POLE])
                    sphere(d = GIN_LEG_OD);
            }
        }
        // Cross bracing spreader beam
        translate([0, 0, L_GIN_POLE * 0.45])
            rotate([90, 0, 0])
                cylinder(d = 140, h = GIN_SPREAD_W * 0.65, center = true);

        // Apex Snatch Block / Sheave Cluster
        translate([0, 0, L_GIN_POLE])
            difference() {
                cube([350, 400, 450], center = true);
                rotate([90, 0, 0]) cylinder(d = 260, h = 420, center = true);
            }
    }
}

// Simulated Direct-Drive Nacelle & Feathered Rotor at Mast Head
module nacelle_and_rotor_head() {
    translate([0, 0, HUB_HEIGHT]) {
        // Nacelle housing
        color([0.3, 0.35, 0.4])
        translate([NACELLE_L * 0.2, 0, NACELLE_H/2])
            cube([NACELLE_L, NACELLE_W, NACELLE_H], center = true);

        // Direct-drive generator ring
        color([0.2, 0.2, 0.2])
        translate([NACELLE_L * 0.55, 0, NACELLE_H/2])
            rotate([0, 90, 0])
                cylinder(d = 1600, h = 600, center = true);

        // Rotor Hub
        color([0.85, 0.3, 0.2])
        translate([NACELLE_L * 0.75, 0, NACELLE_H/2])
            rotate([0, 90, 0])
                cylinder(d = 900, h = 500, center = true);

        // 3 Feathered Blades (Simulated in storm parked orientation)
        for (b = [0, 120, 240]) {
            translate([NACELLE_L * 0.75, 0, NACELLE_H/2])
                rotate([b, 0, 0])
                    translate([0, 0, ROTOR_DIA/4])
                        color([0.92, 0.94, 0.96, 0.85])
                        // Feathered chord parallel to wind
                        cube([180, 700, ROTOR_DIA/2], center = true);
        }
    }
}

// Winch Line & Backstay Cable Connections
module rigging_cables(theta) {
    theta_rad = theta * PI / 180;
    // Gin tip coordinates in container reference frame
    // Mast base pivot is at (0, 0, H_CONT + 35)
    p_base_z = H_CONT + 35;

    // Gin pole is at (theta + 90) degrees
    phi_rad = (theta + 90) * PI / 180;
    gin_tip_x = -L_GIN_POLE * sin(theta_rad); // X goes negative as gin pole leans back
    gin_tip_z = p_base_z + L_GIN_POLE * cos(theta_rad);

    // 1. Winch Hoist Cable (From winch drum to gin pole apex)
    color([0.8, 0.2, 0.2]) // Safety Red
    hull() {
        translate([WINCH_X, 0, WINCH_Z]) sphere(d = 30);
        translate([gin_tip_x, 0, gin_tip_z]) sphere(d = 30);
    }

    // 2. High-Strength Backstay Cables (From gin pole apex to mast at mid/upper sections)
    // Connects to mast at H = 14 m
    h_stay = 14000;
    stay_x = h_stay * cos(theta_rad);
    stay_z = p_base_z + h_stay * sin(theta_rad);

    color([0.15, 0.15, 0.15]) // Heavy Wire Rope
    for (dy = [-500, 500]) {
        hull() {
            translate([gin_tip_x, 0, gin_tip_z]) sphere(d = 25);
            translate([stay_x, dy, stay_z]) sphere(d = 25);
        }
    }
}

// Guy-Wire Rigging (Stabilizes mast when near vertical)
module guy_wire_system(theta) {
    if (theta >= 45) {
        theta_rad = theta * PI / 180;
        p_base_z = H_CONT + 35;
        // Guy attachment collar at H = 18 m
        h_guy = 18000;
        gx = h_guy * cos(theta_rad);
        gz = p_base_z + h_guy * sin(theta_rad);

        // Ground anchor tie-off radius (18 m)
        r_anchor = 18000;
        color([0.3, 0.5, 0.8, 0.6]) {
            for (ang = [45, 135, 225, 315]) {
                hull() {
                    translate([gx, 0, gz]) sphere(d = 20);
                    translate([r_anchor * cos(ang), r_anchor * sin(ang), 0]) sphere(d = 35);
                }
            }
        }
    }
}

// Container & Foundation Base (from Package 1)
module container_foundation_subassembly() {
    // Container body
    color([0.22, 0.32, 0.45, 0.8])
    translate([-L_CONT/2 + 500, 0, H_CONT/2])
        cube([L_CONT, W_CONT, H_CONT], center = true);

    // Mast Base Trunnion Clevis
    color([0.85, 0.55, 0.15])
    translate([0, 0, H_CONT + 35/2])
        cube([800, 600, 35], center = true);

    // Winch unit
    color([0.3, 0.3, 0.3])
    translate([WINCH_X, 0, WINCH_Z])
        cube([900, 700, 400], center = true);
}

// --- Main Assembly with Parametric Tilt Angle ---
module wind_v2_mast_erection_assembly() {
    // 1. Fixed Container Foundation
    if (SHOW_CONTAINER_BASE) {
        container_foundation_subassembly();
    }

    // 2. Rotating Mast & Gin-Pole Subassembly
    translate([0, 0, H_CONT + 35]) {
        // Rotating about Y-axis by (90 - tilt_angle)
        // At tilt_angle = 90 (upright): rotation is 0°
        // At tilt_angle = 0 (horizontal): rotation is 90° down along X-axis
        rotate([0, 90 - tilt_angle, 0]) {
            // Modular Tower
            if (SHOW_MODULAR_MAST) {
                full_modular_mast();
            }

            // Direct-Drive Nacelle & Rotor Tophead
            if (SHOW_NACELLE_HEAD) {
                nacelle_and_rotor_head();
            }

            // Gin-Pole A-Frame (Fixed rigidly at 90 deg to mast)
            if (SHOW_GIN_POLE) {
                rotate([0, -90, 0]) // 90° perpendicular lever
                    gin_pole_a_frame();
            }
        }
    }

    // 3. Dynamic Rigging & Winch Cables
    if (SHOW_WINCH_CABLE) {
        rigging_cables(tilt_angle);
    }

    // 4. Guy-Wire Stabilization
    if (SHOW_GUY_WIRES) {
        guy_wire_system(tilt_angle);
    }
}

// Render root
wind_v2_mast_erection_assembly();
