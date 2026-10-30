// Wind v2.0 Package 1: Foundation & Arctic Ground Interface
// Parametric 3D Model for Container Reaction Footing, Corner Castings,
// Permafrost Ground Sleeper Pads, Helical Anchor Tie-Downs, and Mast Trunnion.
//
// Units: millimeters (OpenSCAD standard)

$fn = 32;

// --- Key Dimensions ---
// Standard 20 ft ISO Shipping Container (Exterior)
L_CONT = 6058; // Length
W_CONT = 2438; // Width
H_CONT = 2591; // Height

// Structural corner posts and rails
RAIL_THICK = 160;
POST_SIZE  = 180;
WALL_THICK = 3.0; // Corrugated sheet nominal

// Permafrost timber / composite thermal isolation sleepers
SLEEPER_W = 600;
SLEEPER_L = 1200;
SLEEPER_H = 200;

// Corner Castings (ISO 1161 nominal 178 x 162 x 118 mm)
CC_L = 178;
CC_W = 162;
CC_H = 118;

// Mast Base Hinge Trunnion (Mounted to container roof/corner)
TRUNNION_PIN_DIA = 90;
TRUNNION_EAR_THICK = 40;
TRUNNION_BASE_L = 800;
TRUNNION_BASE_W = 600;
TRUNNION_HEIGHT = 450;

// Helical Anchor Simulation
ANCHOR_ROD_DIA = 45;
ANCHOR_HELIX_DIA = 250;
ANCHOR_LENGTH = 3000;
ANCHOR_ANGLE = 45; // deg into permafrost

// Visualization Flags
SHOW_CONTAINER   = true;
SHOW_SLEEPERS    = true;
SHOW_ANCHORS     = true;
SHOW_TRUNNION    = true;
SHOW_WINCH_SKID  = true;

// --- Modules ---

// Standard ISO 1161 Corner Casting (simplified)
module iso_corner_casting() {
    color([0.35, 0.38, 0.42])
    difference() {
        cube([CC_L, CC_W, CC_H], center = true);
        // Standard aperture slots (front and side)
        rotate([0, 90, 0]) cylinder(d = 65, h = CC_L + 10, center = true);
        rotate([90, 0, 0]) cylinder(d = 65, h = CC_W + 10, center = true);
        cylinder(d = 75, h = CC_H + 10, center = true);
    }
}

// Thermal Isolation Sleeper (Permafrost Cribbing Pad)
module permafrost_sleeper_pad() {
    color([0.55, 0.35, 0.20]) // Treated timber / composite
    cube([SLEEPER_L, SLEEPER_W, SLEEPER_H], center = true);
}

// Helical Ground Anchor (Penetrating downward into permafrost)
module helical_ground_anchor() {
    color([0.85, 0.25, 0.25]) // High-visibility safety red
    union() {
        // Top eyelet connection atop sleeper
        rotate([90, 0, 0])
            difference() {
                cylinder(d = 120, h = 40, center = true);
                cylinder(d = 60, h = 50, center = true);
            }
        // Tension tie-down rod extending DOWNWARDS into frozen soil
        translate([0, 0, -ANCHOR_LENGTH])
            cylinder(d = ANCHOR_ROD_DIA, h = ANCHOR_LENGTH);
        // Helical screw flights
        translate([0, 0, -ANCHOR_LENGTH * 0.5])
            cylinder(d = ANCHOR_HELIX_DIA, h = 20, center = true);
        translate([0, 0, -ANCHOR_LENGTH * 0.8])
            cylinder(d = ANCHOR_HELIX_DIA, h = 20, center = true);
    }
}

// 20 ft ISO Container Structure
module container_20ft() {
    // Structural steel frame (Subdued Industrial Grey/Navy)
    color([0.22, 0.32, 0.45]) {
        // Bottom longitudinal rails
        translate([0,  W_CONT/2 - RAIL_THICK/2, RAIL_THICK/2])
            cube([L_CONT, RAIL_THICK, RAIL_THICK], center = true);
        translate([0, -W_CONT/2 + RAIL_THICK/2, RAIL_THICK/2])
            cube([L_CONT, RAIL_THICK, RAIL_THICK], center = true);

        // Top longitudinal rails
        translate([0,  W_CONT/2 - RAIL_THICK/2, H_CONT - RAIL_THICK/2])
            cube([L_CONT, RAIL_THICK, RAIL_THICK], center = true);
        translate([0, -W_CONT/2 + RAIL_THICK/2, H_CONT - RAIL_THICK/2])
            cube([L_CONT, RAIL_THICK, RAIL_THICK], center = true);

        // Bottom cross members
        translate([ L_CONT/2 - RAIL_THICK/2, 0, RAIL_THICK/2])
            cube([RAIL_THICK, W_CONT, RAIL_THICK], center = true);
        translate([-L_CONT/2 + RAIL_THICK/2, 0, RAIL_THICK/2])
            cube([RAIL_THICK, W_CONT, RAIL_THICK], center = true);

        // Top cross members
        translate([ L_CONT/2 - RAIL_THICK/2, 0, H_CONT - RAIL_THICK/2])
            cube([RAIL_THICK, W_CONT, RAIL_THICK], center = true);
        translate([-L_CONT/2 + RAIL_THICK/2, 0, H_CONT - RAIL_THICK/2])
            cube([RAIL_THICK, W_CONT, RAIL_THICK], center = true);

        // 4 Corner Posts
        for (dx = [-1, 1]) {
            for (dy = [-1, 1]) {
                translate([dx * (L_CONT/2 - POST_SIZE/2), dy * (W_CONT/2 - POST_SIZE/2), H_CONT/2])
                    cube([POST_SIZE, POST_SIZE, H_CONT], center = true);
            }
        }
    }

    // Corrugated Cladding Panels (Semi-translucent white/steel)
    color([0.80, 0.83, 0.88, 0.75]) {
        // Side walls
        for (dy = [-1, 1]) {
            translate([0, dy * (W_CONT/2 - WALL_THICK/2), H_CONT/2])
                cube([L_CONT - POST_SIZE*2, WALL_THICK, H_CONT - RAIL_THICK*2], center = true);
        }
        // End walls
        for (dx = [-1, 1]) {
            translate([dx * (L_CONT/2 - WALL_THICK/2), 0, H_CONT/2])
                cube([WALL_THICK, W_CONT - POST_SIZE*2, H_CONT - RAIL_THICK*2], center = true);
        }
        // Roof plate
        translate([0, 0, H_CONT - WALL_THICK/2])
            cube([L_CONT - RAIL_THICK*2, W_CONT - RAIL_THICK*2, WALL_THICK], center = true);
    }

    // 8 Standard Corner Castings
    for (dx = [-1, 1]) {
        for (dy = [-1, 1]) {
            // Bottom castings
            translate([dx * (L_CONT/2 - CC_L/2), dy * (W_CONT/2 - CC_W/2), CC_H/2])
                iso_corner_casting();
            // Top castings
            translate([dx * (L_CONT/2 - CC_L/2), dy * (W_CONT/2 - CC_W/2), H_CONT - CC_H/2])
                iso_corner_casting();
        }
    }
}

// Mast Base Hinge Trunnion Assembly
module mast_base_trunnion_assembly() {
    color([0.85, 0.55, 0.15]) // Heavy Equipment Yellow/Orange
    union() {
        // Heavy baseplate bolted across container corner header
        cube([TRUNNION_BASE_L, TRUNNION_BASE_W, 35], center = true);

        // Vertical hinge brackets (Dual clevis ears)
        for (dy = [-180, 180]) {
            translate([0, dy, TRUNNION_HEIGHT/2])
                difference() {
                    cube([TRUNNION_BASE_L * 0.6, TRUNNION_EAR_THICK, TRUNNION_HEIGHT], center = true);
                    // Pivot pin bore
                    translate([0, 0, TRUNNION_HEIGHT/2 - 80])
                        rotate([90, 0, 0])
                            cylinder(d = TRUNNION_PIN_DIA, h = TRUNNION_EAR_THICK + 10, center = true);
                }
        }

        // Heavy High-Strength Pivot Pin
        translate([0, 0, TRUNNION_HEIGHT - 80])
            rotate([90, 0, 0])
                color([0.2, 0.2, 0.2])
                cylinder(d = TRUNNION_PIN_DIA - 2, h = 480, center = true);
    }
}

// Integrated Electric/Manual Winch Skid atop container
module erection_winch_skid() {
    color([0.3, 0.3, 0.3])
    translate([-1500, 0, H_CONT + 150]) {
        // Skid frame
        cube([1000, 800, 80], center = true);
        // Winch Drum
        translate([0, 0, 180])
            rotate([0, 90, 0])
                cylinder(d = 280, h = 600, center = true);
        // Motor drive unit
        translate([0, 350, 180])
            cube([350, 250, 250], center = true);
    }
}

// --- Main Assembly ---
module wind_v2_foundation_assembly() {
    // 1. Ground Permafrost Sleepers (elevating container above active layer)
    if (SHOW_SLEEPERS) {
        for (dx = [-1, 1]) {
            for (dy = [-1, 1]) {
                translate([dx * (L_CONT/2 - SLEEPER_L/2), dy * (W_CONT/2 - SLEEPER_W/2), -SLEEPER_H/2])
                    permafrost_sleeper_pad();
            }
        }
    }

    // 2. 20 ft ISO Container Structure
    if (SHOW_CONTAINER) {
        container_20ft();
    }

    // 3. Helical Ground Anchors (Diagonal pullout ties into frozen subgrade)
    if (SHOW_ANCHORS) {
        for (dx = [-1, 1]) {
            for (dy = [-1, 1]) {
                translate([dx * (L_CONT/2), dy * (W_CONT/2), 0])
                    rotate([dy * ANCHOR_ANGLE, -dx * ANCHOR_ANGLE, 0])
                        helical_ground_anchor();
            }
        }
    }

    // 4. Mast Base Hinge Trunnion (Positioned on container roof corner)
    if (SHOW_TRUNNION) {
        translate([L_CONT/2 - TRUNNION_BASE_L/2 - 100, 0, H_CONT + 35/2])
            mast_base_trunnion_assembly();
    }

    // 5. Erection Winch Skid
    if (SHOW_WINCH_SKID) {
        erection_winch_skid();
    }
}

// Render root
wind_v2_foundation_assembly();
