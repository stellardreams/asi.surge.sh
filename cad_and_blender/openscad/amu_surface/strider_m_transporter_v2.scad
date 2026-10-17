// strider_m_transporter_v2.scad -- STRIDER-M Surface Transporter (v2.0)
//
// Version Control & Engineering Audit:
// - Version: v2.0
// - Tracked Under: Task-01 / Task-02 (Issues #82 & #98 Offshoot)
// - Informed by Gemini Flash-Lite High-Fidelity Cinematic Render 02 (docs/assets/macrogrid_renders/cora_transfer_render02.mp4)
// - Retains v1.0 baseline in `strider_m_transporter_v1.scad` without destructive overwrite.
//
// New Engineering Subsystems in v2.0:
// 1. Deployable Polar Stabilizing Outriggers (4x corner telescoping hydraulic arms with wide articulated snow pads):
//    - Parameter `outriggers_deployed`: 0.0 (fully recessed into chassis armor for transit) to 1.0 (fully extended & locked to ground for crane/arm lifting ops).
//    - Prevents vehicle tip-over and ground sinkage during high polar wind gusts (55 m/s) and heavy turbine blade rigging.
// 2. Deck Transit Park-Mode Latch Cradle:
//    - Dedicated recessed rear deck cradle with motorized dual lock-clamps.
//    - Mechanically captures and locks the folded 7-DoF CORA-M forearm during high-speed transit across jagged sastrugi snowdrifts.
// 3. Broader Arm Mounting Rim / Turret Base Flange:
//    - Expanded docking collar flange (DOCK_COLLAR_R enlarged from 0.55 to 0.68) with 8x high-tensile locking dogs and dual concentric seals.
//
// Units: OpenSCAD model units (Scale compatible with AMU-Surface: 1 unit ~ 71.4 mm)

$fn = 32;

// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------
ROVER_L         = 7.4;   // Overall length (slightly extended frame)
ROVER_W         = 5.0;   // Overall width (widened stance for lateral stability)
CHASSIS_H       = 1.2;   // Ground clearance / chassis height

TRACK_W         = 1.25;  // Extra-wide low-ground-pressure continuous track ("snowshoe")
TRACK_L         = 7.0;   // Track length
TRACK_H         = 1.4;   // Track height
GROUSER_COUNT   = 24;    // Deep traction grousers per track

DECK_L          = 5.6;
DECK_W          = 3.4;
DECK_H          = 0.35;

// v2 Enhanced Mounting Rim
DOCK_COLLAR_R   = 0.68;  // Broadened mounting rim (v1 was 0.55)
DOCK_COLLAR_H   = 0.28;

// Articulation & Deployment Variables
outriggers_deployed = 0.0; // [0.0 : 0.1 : 1.0] - 0.0 = recessed, 1.0 = deployed to ground
park_mode_locked    = 1;   // 1 = Rear arm transit cradle clamped, 0 = open
dock_locked         = 1;   // 1 = CORA-M arm base locked into turret dock, 0 = open cradle

// Colors
COL_ARMOR_DARK  = [0.18, 0.20, 0.22];
COL_TRACK_STEEL = [0.28, 0.29, 0.31];
COL_GROUSER_GOLD= [0.85, 0.68, 0.25];
COL_DECK_ORANGE = [0.88, 0.42, 0.12];
COL_CHROME      = [0.75, 0.77, 0.80];
COL_POWER_BLUE  = [0.15, 0.45, 0.85];
COL_HYDRAULIC   = [0.25, 0.27, 0.30];

// -----------------------------------------------------------------------------
// Modules
// -----------------------------------------------------------------------------

module continuous_crawler_track_v2() {
    // Continuous wide rubber-metal composite track loop
    color(COL_TRACK_STEEL) {
        difference() {
            hull() {
                translate([-(TRACK_L/2 - TRACK_H/2), 0, 0])
                    rotate([90, 0, 0]) cylinder(h=TRACK_W, r=TRACK_H/2, center=true);
                translate([(TRACK_L/2 - TRACK_H/2), 0, 0])
                    rotate([90, 0, 0]) cylinder(h=TRACK_W, r=TRACK_H/2, center=true);
            }
            // Cutout for road wheels
            hull() {
                translate([-(TRACK_L/2 - TRACK_H/2), 0, 0])
                    rotate([90, 0, 0]) cylinder(h=TRACK_W - 0.22, r=TRACK_H/2 - 0.22, center=true);
                translate([(TRACK_L/2 - TRACK_H/2), 0, 0])
                    rotate([90, 0, 0]) cylinder(h=TRACK_W - 0.22, r=TRACK_H/2 - 0.22, center=true);
            }
        }
    }

    // Heavy-duty snowshoe grousers / ice-cleats across perimeter
    color(COL_GROUSER_GOLD) {
        step = (TRACK_L - TRACK_H) / (GROUSER_COUNT / 2 - 2);
        // Bottom ground-contact grousers
        for (gx = [-(TRACK_L/2 - TRACK_H/2) : step : (TRACK_L/2 - TRACK_H/2)]) {
            translate([gx, 0, -TRACK_H/2])
                cube([0.15, TRACK_W + 0.06, 0.11], center=true);
        }
        // Top return grousers
        for (gx = [-(TRACK_L/2 - TRACK_H/2) : step : (TRACK_L/2 - TRACK_H/2)]) {
            translate([gx, 0, TRACK_H/2])
                cube([0.15, TRACK_W + 0.06, 0.11], center=true);
        }
    }

    // Heavy road wheels and drive sprockets
    color(COL_CHROME) {
        for (end_x = [-(TRACK_L/2 - TRACK_H/2), (TRACK_L/2 - TRACK_H/2)]) {
            translate([end_x, 0, 0])
                rotate([90, 0, 0]) cylinder(h=TRACK_W - 0.1, r=TRACK_H/2 - 0.18, center=true, $fn=24);
        }
        // 6x Dual bogie load wheels (strengthened for v2 heavy payloads)
        for (bx = [-2.0 : 0.8 : 2.0]) {
            translate([bx, 0, -0.22])
                rotate([90, 0, 0]) cylinder(h=TRACK_W - 0.15, r=0.42, center=true, $fn=20);
        }
    }
}

// Subsystem 1: Deployable Polar Stabilizing Outriggers
module stabilizing_outrigger(sign_x=1, sign_y=1, deploy=0.0) {
    // deploy: 0.0 = stowed recessed flush against track sponson, 1.0 = fully extended laterally and down to snowline
    ext_y = deploy * 1.35; // Extends out past track edge
    ext_z = deploy * 0.75; // Lowers to permafrost contact

    // Sponson structural mount fixed outside crawler assembly
    color(COL_ARMOR_DARK) {
        cube([0.70, 0.35, 0.50], center=true);
    }

    // Telescoping outrigger leg & wide articulated polar snow footpad
    translate([0, sign_y * ext_y, -ext_z]) {
        // Horizontal telescoping boom
        color(COL_HYDRAULIC) {
            rotate([0, 90, 0])
                cylinder(h=0.55, r=0.14, center=true);
            // Angled reinforcement strut
            if (deploy > 0.05) {
                translate([0, -sign_y * ext_y/2, ext_z/2])
                    rotate([-sign_y * 28, 0, 0])
                        cylinder(h=ext_y * 1.08 + 0.1, r=0.09, center=true);
            }
        }
        // Articulated ground footpad
        translate([0, 0, -0.25]) {
            color(COL_CHROME) {
                sphere(r=0.12);
                translate([0, 0, -0.06])
                    cylinder(h=0.08, r=0.45, center=true);
            }
            color(COL_GROUSER_GOLD) {
                for (a = [0 : 60 : 300]) {
                    rotate([0, 0, a])
                        translate([0.32, 0, -0.11])
                            cylinder(h=0.06, r=0.045, center=true);
                }
            }
        }
    }
}

// Subsystem 2: Transit Park-Mode Latch Cradle
module transit_park_cradle(locked=1) {
    // Cradle base seated on rear deck
    translate([-1.6, 0, CHASSIS_H + DECK_H]) {
        // Deep U-shaped urethane/composite saddle block
        color([0.22, 0.24, 0.26]) {
            difference() {
                translate([0, 0, 0.22])
                    cube([0.70, 1.10, 0.44], center=true);
                // Transverse saddle cavity matching CORA-M forearm diameter
                translate([0, 0, 0.32])
                    rotate([0, 90, 0])
                        cylinder(h=0.75, r=0.32, center=true);
            }
        }

        // Heavy-duty motorized clamping jaws
        clamp_ang = locked ? 0 : -45; // 0 = clamped tightly over arm, -45 = open jaws
        for (side = [-1, 1]) {
            translate([0, side * 0.42, 0.38]) {
                rotate([side * clamp_ang, 0, 0]) {
                    // Arm bracket
                    color(COL_GROUSER_GOLD) {
                        translate([0, side * 0.12, 0.08])
                            cube([0.45, 0.24, 0.10], center=true);
                    }
                    // Protective contact cushion pad
                    color([0.1, 0.1, 0.1]) {
                        translate([0, side * 0.04, 0.02])
                            cube([0.40, 0.08, 0.06], center=true);
                    }
                }
                // Hinge pin & servo actuator
                color(COL_CHROME) {
                    rotate([0, 90, 0])
                        cylinder(h=0.50, r=0.06, center=true);
                }
            }
        }
    }
}

module rover_chassis_and_deck_v2() {
    // Armored central hull
    color(COL_ARMOR_DARK) {
        translate([0, 0, CHASSIS_H/2 - 0.1])
            cube([ROVER_L - 1.2, ROVER_W - 2*TRACK_W + 0.3, CHASSIS_H], center=true);
        // Front sloped glacis / heavy debris shield
        translate([ROVER_L/2 - 0.55, 0, CHASSIS_H/2 - 0.08])
            rotate([0, 32, 0])
                cube([0.85, ROVER_W - 2*TRACK_W + 0.2, 0.42], center=true);
    }

    // High-visibility utility deck with modular mounting grid
    color(COL_DECK_ORANGE) {
        translate([0, 0, CHASSIS_H + DECK_H/2 - 0.1])
            cube([DECK_L, DECK_W, DECK_H], center=true);
        // Perimeter tie-down rail
        for (dy = [-DECK_W/2 + 0.12, DECK_W/2 - 0.12]) {
            translate([0, dy, CHASSIS_H + DECK_H + 0.08])
                rotate([0, 90, 0]) cylinder(h=DECK_L - 0.2, r=0.045, center=true);
        }
    }

    // Internal Heated Power Reservoir (Solid-State Batteries / Cryo Fuel Cell)
    color(COL_POWER_BLUE) {
        translate([-0.6, 0, CHASSIS_H/2 + 0.1])
            cube([2.2, DECK_W - 0.7, CHASSIS_H - 0.3], center=true);
    }

    // Subsystem 3: Enhanced Broad-Rim Turret Docking Station for CORA-M Arm
    translate([1.0, 0, CHASSIS_H + DECK_H]) {
        // Broad outer alignment flange ring
        color(COL_CHROME) {
            cylinder(h=DOCK_COLLAR_H, r=DOCK_COLLAR_R, center=true);
            // Thickened mounting rim lip (informed by render 02)
            translate([0, 0, DOCK_COLLAR_H/2])
                cylinder(h=0.10, r=DOCK_COLLAR_R + 0.18, center=true);
        }
        // 8x Symmetrical locking dog latches (hardened high-torque retention)
        color([0.2, 0.2, 0.2]) {
            for (ang = [0 : 45 : 315]) {
                rotate([0, 0, ang])
                    translate([DOCK_COLLAR_R - 0.04, 0, DOCK_COLLAR_H/2 + 0.05])
                        cube([0.16, 0.18, 0.12], center=true);
            }
        }
        // Dual concentric conductive power & high-bandwidth optical umbilical interface
        color(COL_POWER_BLUE) {
            translate([0, 0, DOCK_COLLAR_H/2 + 0.01])
                cylinder(h=0.05, r=DOCK_COLLAR_R * 0.60, center=true, $fn=24);
        }
        color(COL_GROUSER_GOLD) {
            translate([0, 0, DOCK_COLLAR_H/2 + 0.02])
                cylinder(h=0.06, r=DOCK_COLLAR_R * 0.25, center=true, $fn=16);
        }
    }

    // Integrated Transit Park-Mode Cradle
    transit_park_cradle(locked=park_mode_locked);

    // Tool magazine & spare pin cassette rack
    color([0.3, 0.35, 0.4]) {
        translate([-2.5, 0, CHASSIS_H + DECK_H + 0.25]) {
            cube([0.7, 1.8, 0.5], center=true);
            for (py = [-0.6 : 0.3 : 0.6]) {
                translate([0, py, 0.26])
                    color("Gold") cylinder(h=0.15, r=0.08, center=true);
            }
        }
    }
}

module strider_m_v2_full() {
    // Center chassis & deck with v2 outriggers & park cradle
    rover_chassis_and_deck_v2();

    // Port & Starboard wide continuous crawler tracks
    for (ty = [-(ROVER_W/2 - TRACK_W/2), (ROVER_W/2 - TRACK_W/2)]) {
        translate([0, ty, TRACK_H/2])
            continuous_crawler_track_v2();
    }

    // 4x Sponson housings for Deployable Stabilizing Outriggers (mounted exterior to tracks)
    for (sx = [-2.2, 2.2]) {
        for (sy = [-1, 1]) {
            translate([sx, sy * (ROVER_W/2 + 0.05), CHASSIS_H/2 + 0.05])
                stabilizing_outrigger(sign_x=(sx>0?1:-1), sign_y=sy, deploy=outriggers_deployed);
        }
    }
}

// -----------------------------------------------------------------------------
// Top-Level Assembly
// -----------------------------------------------------------------------------
strider_m_v2_full();
