// strider_m_transporter_v2.scad -- STRIDER-M Surface Transporter (v2.0)
//
// Version Control & Engineering Audit:
// - Version: v2.0
// - Tracked Under: Issue #100 (Child of #98, Grandparent #82)
// - Informed by Gemini Flash-Lite High-Fidelity Cinematic Render 02 (docs/assets/macrogrid_renders/cora_transfer_render02.mp4)
// - Visual Blueprint: Precisely matches the render 02 screenshot provided by @genidma in #100.
//
// Specific Engineering Architecture:
// 1. Heavy Knee-Jointed A-Frame Outrigger Trusses ("Spider Outriggers"):
//    - High clevis pivot on track fender armor.
//    - Upper boom sweeps outward and down toward the ground at ~35-45 degrees.
//    - Knee joint knuckle articulates lower leg down to snowline at a shallower angle.
//    - Hydraulic cylinder ram mounted on the top edge of the upper boom pushing the knee joint.
//    - Flat rectangular heavy polar footpad shoes resting firmly on the ground.
// 2. Front Bull-Bar Brush Guard & Crash Cage with X-brace and recovery shackles.
// 3. Wide Continuous Crawler Bogies with Grousers.
// 4. Amber Hazard Warning Beacons & Work Lights.
// 5. Deck Transit Park-Mode Cradle & Broadened 8-Lug Turret Dock.

$fn = 32;

// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------
ROVER_L         = 7.6;   // Overall length
ROVER_W         = 4.8;   // Track-to-track width
CHASSIS_H       = 1.15;  // Ground clearance / chassis height

TRACK_W         = 1.25;  // Low-ground-pressure continuous track
TRACK_L         = 7.0;   // Track length
TRACK_H         = 1.35;  // Track height
GROUSER_COUNT   = 24;    // Traction grousers per track

DECK_L          = 5.6;
DECK_W          = 3.4;
DECK_H          = 0.35;

// Mounting Rim
DOCK_COLLAR_R   = 0.68;
DOCK_COLLAR_H   = 0.28;

// Articulation & Deployment Variables
outriggers_deployed = 0.0; // [0.0 : 0.1 : 1.0] - 0.0 = stowed along fender, 1.0 = deployed to ground
park_mode_locked    = 1;   // 1 = Rear arm transit cradle clamped, 0 = open
dock_locked         = 1;   // 1 = CORA-M arm base locked into turret dock

// Colors
COL_ARMOR_DARK  = [0.18, 0.20, 0.22];
COL_TRACK_STEEL = [0.26, 0.27, 0.29];
COL_GROUSER_GOLD= [0.85, 0.68, 0.25];
COL_DECK_ORANGE = [0.88, 0.42, 0.12];
COL_CHROME      = [0.80, 0.82, 0.85];
COL_HYDRAULIC   = [0.68, 0.72, 0.76]; // Silver hydraulic cylinder barrel
COL_RAM_CHROME  = [0.92, 0.94, 0.96]; // Polished chrome piston
COL_AMBER_LIGHT = [1.00, 0.65, 0.05];
COL_HEADLIGHT   = [0.95, 0.98, 1.00];
COL_POWER_BLUE  = [0.15, 0.45, 0.85];

// -----------------------------------------------------------------------------
// Modules
// -----------------------------------------------------------------------------

module continuous_crawler_track_v2() {
    color(COL_TRACK_STEEL) {
        difference() {
            hull() {
                translate([-(TRACK_L/2 - TRACK_H/2), 0, 0])
                    rotate([90, 0, 0]) cylinder(h=TRACK_W, r=TRACK_H/2, center=true);
                translate([(TRACK_L/2 - TRACK_H/2), 0, 0])
                    rotate([90, 0, 0]) cylinder(h=TRACK_W, r=TRACK_H/2, center=true);
            }
            hull() {
                translate([-(TRACK_L/2 - TRACK_H/2), 0, 0])
                    rotate([90, 0, 0]) cylinder(h=TRACK_W - 0.24, r=TRACK_H/2 - 0.22, center=true);
                translate([(TRACK_L/2 - TRACK_H/2), 0, 0])
                    rotate([90, 0, 0]) cylinder(h=TRACK_W - 0.24, r=TRACK_H/2 - 0.22, center=true);
            }
        }
    }

    color(COL_GROUSER_GOLD) {
        step = (TRACK_L - TRACK_H) / (GROUSER_COUNT / 2 - 2);
        for (gx = [-(TRACK_L/2 - TRACK_H/2) : step : (TRACK_L/2 - TRACK_H/2)]) {
            translate([gx, 0, -TRACK_H/2])
                cube([0.16, TRACK_W + 0.06, 0.11], center=true);
            translate([gx, 0, TRACK_H/2])
                cube([0.16, TRACK_W + 0.06, 0.11], center=true);
        }
    }

    color(COL_CHROME) {
        for (end_x = [-(TRACK_L/2 - TRACK_H/2), (TRACK_L/2 - TRACK_H/2)]) {
            translate([end_x, 0, 0])
                rotate([90, 0, 0]) cylinder(h=TRACK_W - 0.1, r=TRACK_H/2 - 0.16, center=true, $fn=24);
        }
        for (bx = [-2.0 : 0.8 : 2.0]) {
            translate([bx, 0, -0.24])
                rotate([90, 0, 0]) cylinder(h=TRACK_W - 0.15, r=0.40, center=true, $fn=20);
        }
    }
}

// Subsystem 1: A-Frame Knee-Joint Outrigger Truss (Matching Screenshot Exactly)
module a_frame_knee_outrigger(sign_x=1, sign_y=1, deploy=0.0) {
    // deploy: 0.0 = stowed flush along track fender; 1.0 = deployed down & out to ground
    // Splay down angles matching screenshot:
    // Upper boom descends outward at ~35 degrees
    boom_ang = (1 - deploy) * 80 + deploy * 35;
    // Lower leg articulates down to ground at ~22 degrees
    knee_ang = (1 - deploy) * 85 + deploy * 22;

    // 1. High Fender Pivot Clevis Bracket
    color(COL_ARMOR_DARK) {
        rotate([0, 90, 0]) cylinder(h=0.42, r=0.16, center=true);
        translate([0, -sign_y * 0.10, -0.08])
            cube([0.38, 0.22, 0.24], center=true);
    }

    // 2. Upper Boom Arm (sweeps outward and downward)
    rotate([-sign_y * boom_ang, 0, 0]) {
        color(COL_ARMOR_DARK) {
            translate([0, sign_y * 0.95, 0])
                cube([0.26, 1.9, 0.24], center=true);
            // Detail cutouts
            for (cy = [0.4 : 0.45 : 1.5]) {
                translate([0, sign_y * cy, 0])
                    rotate([0, 90, 0]) cylinder(h=0.28, r=0.065, center=true);
            }
        }

        // Hydraulic Cylinder mounted on upper boom pushing knee knuckle
        translate([0, sign_y * 0.40, 0.18]) {
            rotate([-sign_y * 8, 0, 0]) {
                // Silver Cylinder Barrel
                color(COL_HYDRAULIC) {
                    rotate([-sign_y * 90, 0, 0])
                        cylinder(h=1.05, r=0.11, center=false);
                    // Blue collar ring matching render screenshot
                    translate([0, sign_y * 0.90, 0])
                        color([0.15, 0.55, 0.65])
                            rotate([90, 0, 0]) cylinder(h=0.08, r=0.12, center=true);
                }
                // Polished Chrome Piston Rod
                color(COL_RAM_CHROME) {
                    translate([0, sign_y * 1.05, 0])
                        rotate([-sign_y * 90, 0, 0])
                            cylinder(h=0.40 + deploy * 0.45, r=0.07, center=false);
                }
            }
        }

        // 3. Knee Knuckle Pivot
        translate([0, sign_y * 1.9, 0]) {
            color(COL_CHROME) {
                rotate([0, 90, 0]) cylinder(h=0.34, r=0.15, center=true);
            }

            // 4. Lower Diagonal Leg continuing down to Ground
            rotate([-sign_y * knee_ang, 0, 0]) {
                color(COL_ARMOR_DARK) {
                    translate([0, sign_y * 0.90, 0])
                        cube([0.22, 1.8, 0.20], center=true);
                }

                // 5. Broad Articulated Heavy-Duty Polar Footpad Shoe
                translate([0, sign_y * 1.80, 0]) {
                    color(COL_CHROME) {
                        rotate([0, 90, 0]) cylinder(h=0.28, r=0.10, center=true);
                    }
                    // Flat wide rectangular snow shoe footpad resting horizontally on ground
                    rotate([sign_y * (boom_ang + knee_ang), 0, 0]) {
                        color([0.14, 0.15, 0.16]) {
                            translate([0, 0, -0.08])
                                cube([0.65, 1.25, 0.14], center=true);
                        }
                        // Golden permafrost biting cleats
                        color(COL_GROUSER_GOLD) {
                            for (fx = [-0.22, 0, 0.22]) {
                                translate([fx, 0, -0.16])
                                    cube([0.08, 1.20, 0.08], center=true);
                            }
                        }
                    }
                }
            }
        }
    }
}

// Subsystem 2: Front Bull-Bar Brush Guard & Crash Cage
module front_bull_bar_cage() {
    translate([ROVER_L/2 - 0.25, 0, CHASSIS_H/2 + 0.15]) {
        color(COL_ARMOR_DARK) {
            translate([0.45, 0, 0.35])
                rotate([90, 0, 0]) cylinder(h=ROVER_W - 2*TRACK_W + 0.3, r=0.07, center=true);
            translate([0.45, 0, -0.25])
                rotate([90, 0, 0]) cylinder(h=ROVER_W - 2*TRACK_W + 0.3, r=0.07, center=true);
            for (uy = [-0.85, 0.85]) {
                translate([0.45, uy, 0.05])
                    cylinder(h=0.65, r=0.07, center=true);
                translate([0.22, uy, 0.05])
                    rotate([0, 45, 0])
                        cylinder(h=0.65, r=0.06, center=true);
            }
            translate([0.44, 0, 0.05]) {
                rotate([0, 0, 32]) cube([0.06, 1.4, 0.06], center=true);
                rotate([0, 0, -32]) cube([0.06, 1.4, 0.06], center=true);
            }
        }
        color(COL_GROUSER_GOLD) {
            for (sy = [-0.45, 0.45]) {
                translate([0.52, sy, -0.25])
                    rotate([0, 90, 0])
                        cylinder(h=0.12, r=0.10, center=true);
            }
        }
        color(COL_HEADLIGHT) {
            for (ly = [-1.15, 1.15]) {
                translate([0.42, ly, 0.35])
                    cube([0.12, 0.25, 0.18], center=true);
            }
        }
    }
}

// Subsystem 3: Transit Park-Mode Latch Cradle
module transit_park_cradle(locked=1) {
    translate([-1.6, 0, CHASSIS_H + DECK_H]) {
        color([0.22, 0.24, 0.26]) {
            difference() {
                translate([0, 0, 0.22])
                    cube([0.70, 1.10, 0.44], center=true);
                translate([0, 0, 0.32])
                    rotate([0, 90, 0])
                        cylinder(h=0.75, r=0.32, center=true);
            }
        }
        clamp_ang = locked ? 0 : -45;
        for (side = [-1, 1]) {
            translate([0, side * 0.42, 0.38]) {
                rotate([side * clamp_ang, 0, 0]) {
                    color(COL_GROUSER_GOLD) {
                        translate([0, side * 0.12, 0.08])
                            cube([0.45, 0.24, 0.10], center=true);
                    }
                    color([0.1, 0.1, 0.1]) {
                        translate([0, side * 0.04, 0.02])
                            cube([0.40, 0.08, 0.06], center=true);
                    }
                }
                color(COL_CHROME) {
                    rotate([0, 90, 0])
                        cylinder(h=0.50, r=0.06, center=true);
                }
            }
        }
    }
}

module rover_chassis_and_deck_v2() {
    color(COL_ARMOR_DARK) {
        translate([0, 0, CHASSIS_H/2 - 0.1])
            cube([ROVER_L - 1.2, ROVER_W - 2*TRACK_W + 0.3, CHASSIS_H], center=true);
        translate([ROVER_L/2 - 0.55, 0, CHASSIS_H/2 - 0.08])
            rotate([0, 32, 0])
                cube([0.85, ROVER_W - 2*TRACK_W + 0.2, 0.42], center=true);

        for (fy = [-1, 1]) {
            translate([0, fy * (ROVER_W/2 + 0.05), CHASSIS_H + 0.15])
                cube([ROVER_L - 0.6, 0.45, 0.22], center=true);
        }
    }

    front_bull_bar_cage();

    color(COL_DECK_ORANGE) {
        translate([0, 0, CHASSIS_H + DECK_H/2 - 0.1])
            cube([DECK_L, DECK_W, DECK_H], center=true);
        for (dy = [-DECK_W/2 + 0.12, DECK_W/2 - 0.12]) {
            translate([0, dy, CHASSIS_H + DECK_H + 0.08])
                rotate([0, 90, 0]) cylinder(h=DECK_L - 0.2, r=0.045, center=true);
        }
    }

    // Amber Hazard Warning Strobes
    color(COL_AMBER_LIGHT) {
        for (bx = [-DECK_L/2 + 0.4, DECK_L/2 - 0.4]) {
            for (by = [-DECK_W/2 - 0.1, DECK_W/2 + 0.1]) {
                translate([bx, by, CHASSIS_H + DECK_H + 0.22]) {
                    cylinder(h=0.18, r=0.10, center=true, $fn=16);
                    translate([0, 0, -0.12])
                        color(COL_ARMOR_DARK) cylinder(h=0.08, r=0.12, center=true);
                }
            }
        }
    }

    // Enhanced Broad-Rim Turret Docking Station for CORA-M Arm
    translate([1.0, 0, CHASSIS_H + DECK_H]) {
        color(COL_CHROME) {
            cylinder(h=DOCK_COLLAR_H, r=DOCK_COLLAR_R, center=true);
            translate([0, 0, DOCK_COLLAR_H/2])
                cylinder(h=0.10, r=DOCK_COLLAR_R + 0.18, center=true);
        }
        color([0.2, 0.2, 0.2]) {
            for (ang = [0 : 45 : 315]) {
                rotate([0, 0, ang])
                    translate([DOCK_COLLAR_R - 0.04, 0, DOCK_COLLAR_H/2 + 0.05])
                        cube([0.16, 0.18, 0.12], center=true);
            }
        }
        color(COL_POWER_BLUE) {
            translate([0, 0, DOCK_COLLAR_H/2 + 0.01])
                cylinder(h=0.05, r=DOCK_COLLAR_R * 0.60, center=true, $fn=24);
        }
        color(COL_GROUSER_GOLD) {
            translate([0, 0, DOCK_COLLAR_H/2 + 0.02])
                cylinder(h=0.06, r=DOCK_COLLAR_R * 0.25, center=true, $fn=16);
        }
    }

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
    rover_chassis_and_deck_v2();

    for (ty = [-(ROVER_W/2 - TRACK_W/2), (ROVER_W/2 - TRACK_W/2)]) {
        translate([0, ty, TRACK_H/2])
            continuous_crawler_track_v2();
    }

    // 4x Knee-Jointed A-Frame Spider Outriggers mounted high at the track fenders
    for (sx = [-2.1, 2.1]) {
        for (sy = [-1, 1]) {
            translate([sx, sy * (ROVER_W/2 + 0.05), CHASSIS_H + 0.15])
                a_frame_knee_outrigger(sign_x=(sx>0?1:-1), sign_y=sy, deploy=outriggers_deployed);
        }
    }
}

strider_m_v2_full();
