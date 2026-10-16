// strider_m_operator_v1.scad -- STRYDER-Arctic Fleet: Non-Autonomous / Human-Controlled Unit (v1.0)
//
// Version Control & Engineering Audit:
// - Version: v1.0
// - Tracked Under: Issue #97 (Parent #81, Cross-ref #82, #88)
// - Operational Classification: Non-Autonomous Unit (Manned Arctic Scout / Zero-Crush Safety Cell)
//   Utilized for safe crew transport, tactical field recon, environmental sensor monitoring, and emergency response.
//   *CRUSH HAZARD ZEROED*: Industrial crane completely removed from operator platform to eliminate all personnel drop/crush risk.
//
// Key Subsystems & Design Features (from Arctic Fleet Classification Schematic):
// 1. Visible Operator Cockpit & Safety Cell (NASCAR-Style Full Roll Cage):
//    - Heavy-duty high-tensile tubular steel roll cage (ROPS/FOPS - Roll-Over & Falling Object Protection)
//      fully encasing the human operator from overhead, lateral impact, and falling terrain/ice.
//    - Overhead steel canopy / deflector shield providing overhead weather and impact protection.
//    - Human-scale operator saddle seat, handlebar steering controls, and direct operator feedback HUD/display.
//    - Manual control bank and heated glove grips protected inside the armored safety cell.
// 2. Safe Crew Gear Trunk & Life-Support Equipment Locker:
//    - Rear chassis deck outfitted with an enclosed composite equipment locker, dual waterproof access lids,
//      and strapped modular emergency packs (first aid, survival kits, and backup field power batteries).
//    - ZERO heavy overhead machinery or articulating booms above or near the human operator.
// 3. Four Independent Arctic Crawler Bogies:
//    - Identical high-traction triangular bogies with gold ice grousers and chrome road wheels.
// 4. Ruggedized Field Maintenance Sponsons & Driving Lights:
//    - Dual forward floodlights and chassis-mounted recovery winches.
//
// Units: OpenSCAD model units

$fn = 32;

// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------
ROVER_L         = 6.8;
ROVER_W         = 4.4;
CHASSIS_H       = 1.1;

BOGIE_L         = 2.8;
BOGIE_W         = 0.95;
BOGIE_H         = 1.45;
GROUSER_COUNT   = 18;

// Colors
COL_ARCTIC_ORANGE   = [0.88, 0.40, 0.10]; // High-vis Arctic safety orange
COL_CHASSIS_DARK    = [0.18, 0.20, 0.22];
COL_TRACK_STEEL     = [0.28, 0.29, 0.31];
COL_GROUSER_GOLD    = [0.85, 0.68, 0.25];
COL_WHEEL_CHROME    = [0.75, 0.77, 0.80];
COL_SEAT_LEATHER    = [0.12, 0.13, 0.14];
COL_HANDLEBAR_STEEL = [0.82, 0.84, 0.86];
COL_BOOM_ORANGE     = [0.88, 0.40, 0.10];
COL_BOOM_DARK       = [0.22, 0.24, 0.26];
COL_HYDRAULIC_RAM   = [0.88, 0.90, 0.92];
COL_MICRO_WIND_UNIT = [0.65, 0.68, 0.72]; // Cast aluminium housing (Assy P/N: 12845)

// -----------------------------------------------------------------------------
// Subsystem 1: High-Traction Triangular Track Bogies
// -----------------------------------------------------------------------------

module triangular_track_bogie() {
    color(COL_TRACK_STEEL) {
        difference() {
            hull() {
                translate([0, 0, BOGIE_H/2 - 0.22])
                    rotate([90, 0, 0]) cylinder(h=BOGIE_W, r=0.48, center=true);
                translate([BOGIE_L/2 - 0.45, 0, -BOGIE_H/2 + 0.35])
                    rotate([90, 0, 0]) cylinder(h=BOGIE_W, r=0.38, center=true);
                translate([-BOGIE_L/2 + 0.45, 0, -BOGIE_H/2 + 0.35])
                    rotate([90, 0, 0]) cylinder(h=BOGIE_W, r=0.38, center=true);
            }
            hull() {
                translate([0, 0, BOGIE_H/2 - 0.22])
                    rotate([90, 0, 0]) cylinder(h=BOGIE_W + 0.1, r=0.34, center=true);
                translate([BOGIE_L/2 - 0.45, 0, -BOGIE_H/2 + 0.35])
                    rotate([90, 0, 0]) cylinder(h=BOGIE_W + 0.1, r=0.24, center=true);
                translate([-BOGIE_L/2 + 0.45, 0, -BOGIE_H/2 + 0.35])
                    rotate([90, 0, 0]) cylinder(h=BOGIE_W + 0.1, r=0.24, center=true);
            }
        }
    }

    color(COL_GROUSER_GOLD) {
        step = (BOGIE_L - 0.9) / 7;
        for (gx = [-BOGIE_L/2 + 0.45 : step : BOGIE_L/2 - 0.45]) {
            translate([gx, 0, -BOGIE_H/2])
                cube([0.14, BOGIE_W + 0.08, 0.08], center=true);
        }
    }

    color(COL_WHEEL_CHROME) {
        translate([0, 0, BOGIE_H/2 - 0.22])
            rotate([90, 0, 0]) cylinder(h=BOGIE_W - 0.12, r=0.40, center=true, $fn=24);
        for (ix = [-BOGIE_L/2 + 0.45, BOGIE_L/2 - 0.45]) {
            translate([ix, 0, -BOGIE_H/2 + 0.35])
                rotate([90, 0, 0]) cylinder(h=BOGIE_W - 0.12, r=0.32, center=true, $fn=20);
        }
        for (rx = [-0.45, 0.45]) {
            translate([rx, 0, -BOGIE_H/2 + 0.32])
                rotate([90, 0, 0]) cylinder(h=BOGIE_W - 0.15, r=0.28, center=true, $fn=18);
        }
    }
}

function sgn(v) = v >= 0 ? 1 : -1;

// -----------------------------------------------------------------------------
// Subsystem 2: Human Operator Cockpit & Controls
// -----------------------------------------------------------------------------

module operator_cockpit() {
    // Sculpted ATV Center Body with Deep Saddle Well
    color(COL_ARCTIC_ORANGE) {
        // Front Cowling
        translate([ROVER_L/2 - 1.4, 0, CHASSIS_H + 0.35]) {
            hull() {
                translate([0.8, 0, -0.1]) cube([0.6, 1.7, 0.5], center=true);
                translate([-0.6, 0, 0.2]) cube([1.4, 1.9, 0.7], center=true);
            }
        }
        // Fenders over 4 bogies
        for (fx = [-1.8, 1.8]) {
            for (fy = [-ROVER_W/2 + BOGIE_W/2, ROVER_W/2 - BOGIE_W/2]) {
                translate([fx, fy, CHASSIS_H + 0.45]) {
                    cube([BOGIE_L + 0.3, BOGIE_W + 0.2, 0.15], center=true);
                    translate([sgn(fx)*(BOGIE_L/2 + 0.15), 0, -0.15])
                        rotate([0, sgn(fx)*25, 0]) cube([0.25, BOGIE_W + 0.18, 0.12], center=true);
                }
            }
        }
    }

    // Heavy-Duty Arctic Operator Saddle Seat
    translate([-0.2, 0, CHASSIS_H + 0.55]) {
        color(COL_SEAT_LEATHER) {
            // Contoured seat cushion
            cube([1.4, 0.75, 0.25], center=true);
            // Raised lumbar backrest
            translate([-0.6, 0, 0.35])
                rotate([0, -15, 0]) cube([0.22, 0.70, 0.55], center=true);
        }
    }

    // Steering Column, Handlebars & Direct Operator HUD
    // Positioned safely inside the NASCAR roll cage cell (A-pillars at X = 0.65, seat at X = -0.2)
    translate([0.35, 0, CHASSIS_H + 0.75]) {
        // Steering post
        color(COL_BOOM_DARK) {
            rotate([0, 18, 0]) cylinder(h=0.75, r=0.07, center=true);
        }
        // Handlebars (Width = 0.95m, well within the 1.5m wide safety cell cage)
        translate([0.10, 0, 0.38]) {
            color(COL_HANDLEBAR_STEEL) {
                rotate([90, 0, 0]) cylinder(h=0.95, r=0.04, center=true);
                // Rubber handgrips
                for (gy = [-0.48, 0.48]) {
                    translate([0, gy, 0]) rotate([90, 0, 0])
                        cylinder(h=0.20, r=0.055, center=true);
                }
            }
            // Direct Operator Feedback HUD & Instrument Console
            color(COL_BOOM_DARK) {
                translate([0.06, 0, 0.12]) rotate([0, -30, 0]) {
                    cube([0.18, 0.40, 0.20], center=true);
                    // Active digital display screen
                    color([0.15, 0.85, 0.35]) translate([0.09, 0, 0])
                        cube([0.02, 0.32, 0.15], center=true);
                }
            }
        }
    }

    // Manual Hydraulic & Field Override Controls
    // Located internally on starboard side within the safety cell (Y = 0.42 < 0.75 cage limit)
    translate([0.15, 0.42, CHASSIS_H + 0.62]) {
        color(COL_BOOM_DARK) {
            cube([0.45, 0.22, 0.18], center=true);
            // 4x Hydraulic override levers
            for (lx = [-0.14, -0.05, 0.05, 0.14]) {
                translate([lx, 0, 0.15]) rotate([12, 0, 0]) {
                    color(COL_HANDLEBAR_STEEL) cylinder(h=0.18, r=0.018, center=true);
                    color("Red") translate([0, 0, 0.10]) sphere(r=0.03);
                }
            }
        }
    }
}


// -----------------------------------------------------------------------------
// Subsystem 2b: NASCAR-Style Tubular Steel Roll Cage & Safety Cell (ROPS/FOPS)
// -----------------------------------------------------------------------------

COL_CAGE_STEEL      = [0.16, 0.18, 0.20]; // High-tensile DOM seamless structural tubing
COL_CANOPY_SHIELD   = [0.22, 0.25, 0.28]; // Armored overhead deflection plate

module nascar_operator_safety_cell() {
    // 1. Armored Deflection Bulkhead (Solid wall separating crane turret from operator)
    translate([-1.05, 0, CHASSIS_H + 0.85]) {
        color(COL_CANOPY_SHIELD) {
            // Thick vertical steel firewall / blast & crush bulkhead
            cube([0.18, 1.6, 1.4], center=true);
            // Angled deflector lip at top
            translate([0.12, 0, 0.72]) rotate([0, 35, 0])
                cube([0.25, 1.62, 0.12], center=true);
        }
    }

    // 2. NASCAR-Style Tubular Space-Frame Roll Cage
    color(COL_CAGE_STEEL) {
        // Main A-Pillar Hoops (Front of cockpit)
        for (sy = [-0.75, 0.75]) {
            // Front uprights
            translate([0.65, sy, CHASSIS_H + 0.95])
                rotate([0, 18, 0]) cylinder(h=1.5, r=0.065, center=true);
            // Rear B-Pillar uprights (at the firewall bulkhead)
            translate([-1.0, sy, CHASSIS_H + 0.95])
                cylinder(h=1.5, r=0.075, center=true);
            // Lower chassis sill bar
            translate([-0.18, sy, CHASSIS_H + 0.35])
                rotate([0, 90, 0]) cylinder(h=1.65, r=0.06, center=true);
            // Mid door impact intrusion bar (NASCAR ladder bar)
            translate([-0.18, sy, CHASSIS_H + 0.75])
                rotate([0, 90, 0]) cylinder(h=1.65, r=0.06, center=true);
            // Diagonal side bracing
            translate([-0.18, sy, CHASSIS_H + 0.95])
                rotate([0, 42, 0]) cylinder(h=1.85, r=0.05, center=true);
        }

        // Overhead Roof Halo / Roll Hoop
        translate([-0.18, 0, CHASSIS_H + 1.68]) {
            // Lateral side roof bars
            for (sy = [-0.75, 0.75]) {
                translate([0, sy, 0]) rotate([0, 90, 0])
                    cylinder(h=1.65, r=0.065, center=true);
            }
            // Front and rear cross-spanners
            for (rx = [-0.8, 0.8]) {
                translate([rx, 0, 0]) rotate([90, 0, 0])
                    cylinder(h=1.5, r=0.065, center=true);
            }
            // Diagonal overhead roof gusset brace
            rotate([0, 0, 40]) cube([0.08, 1.8, 0.08], center=true);
        }

        // Front Windscreen Protection Mesh / Brow Bars
        translate([0.72, 0, CHASSIS_H + 1.25]) {
            rotate([0, 18, 0]) {
                for (gy = [-0.5, 0, 0.5]) {
                    translate([0, gy, 0]) cylinder(h=0.8, r=0.035, center=true);
                }
            }
        }
    }

    // 3. Heavy Armored Overhead Deflector Shield (Protects against falling crane loads)
    translate([-0.20, 0, CHASSIS_H + 1.72]) {
        color(COL_CANOPY_SHIELD) {
            cube([1.75, 1.55, 0.08], center=true);
            // Longitudinal stiffener ribs across roof plate
            for (ry = [-0.5, 0, 0.5]) {
                translate([0, ry, 0.06])
                    cube([1.72, 0.06, 0.08], center=true);
            }
        }
    }
}

// -----------------------------------------------------------------------------
// Subsystem 3: Safe Crew Gear Trunk & Life-Support Equipment Locker
// (Zero heavy overhead machinery -- completely eliminated crush/drop hazard)
// -----------------------------------------------------------------------------

COL_EXPEDITION_BOX  = [0.22, 0.24, 0.26];
COL_EXPEDITION_LID  = [0.88, 0.40, 0.10]; // High-vis Arctic safety orange latch/lid

module expedition_crew_gear_trunk() {
    // Heavy reinforced low-profile composite cargo trunk on rear deck
    translate([-1.85, 0, CHASSIS_H + 0.35]) {
        color(COL_EXPEDITION_BOX) {
            cube([1.9, 1.65, 0.65], center=true);
            // Tie-down side rails
            for (ty = [-0.85, 0.85]) {
                translate([0, ty, 0.25])
                    cube([1.8, 0.06, 0.12], center=true);
            }
        }
        // Hinged dual waterproof access lids
        color(COL_EXPEDITION_LID) {
            for (lx = [-0.48, 0.48]) {
                translate([lx, 0, 0.35])
                    cube([0.88, 1.58, 0.08], center=true);
            }
        }
        // Modular survival/first-aid pelican cases strapped to top rack
        translate([0, 0, 0.52]) {
            color([0.82, 0.22, 0.15]) // Red emergency case
                translate([-0.45, -0.35, 0]) cube([0.55, 0.55, 0.24], center=true);
            color([0.75, 0.65, 0.25]) // Tan survival kit
                translate([-0.45, 0.35, 0]) cube([0.55, 0.55, 0.24], center=true);
            color([0.25, 0.55, 0.85]) // Blue field battery pack
                translate([0.45, 0, 0]) cube([0.65, 0.95, 0.22], center=true);
        }
    }
}

// -----------------------------------------------------------------------------
// Complete Non-Autonomous Stryder Assembly (Zero-Crush Manned Arctic Scout)
// -----------------------------------------------------------------------------

module strider_m_operator_v1() {
    // Armored main chassis
    color(COL_CHASSIS_DARK) {
        translate([0, 0, CHASSIS_H/2 - 0.05])
            cube([ROVER_L - 1.2, 1.8, CHASSIS_H], center=true);
        // Heavy front brush guard
        translate([ROVER_L/2 - 0.2, 0, CHASSIS_H/2 + 0.1]) {
            cube([0.35, 2.2, 0.8], center=true);
            for (by = [-1.0, 1.0]) {
                translate([0, by, 0]) cube([0.45, 0.2, 0.9], center=true);
            }
        }
        // Front LED Driving Lights
        color([0.95, 0.95, 0.85]) {
            for (ly = [-0.85, 0.85]) {
                translate([ROVER_L/2 - 0.1, ly, CHASSIS_H/2 + 0.3])
                    cube([0.15, 0.25, 0.25], center=true);
            }
        }
    }

    // 1. Visible Operator Cockpit & Controls
    operator_cockpit();

    // 1b. NASCAR-Style Full Roll Cage & Overhead Deflection Shield (Safety Cell)
    nascar_operator_safety_cell();

    // 2. Safe Crew Gear Trunk & Life-Support Equipment Locker (Zero heavy machinery)
    expedition_crew_gear_trunk();

    // 3. Four Independent High-Traction Triangular Bogies
    for (bx = [-1.8, 1.8]) {
        for (by = [-ROVER_W/2 + BOGIE_W/2, ROVER_W/2 - BOGIE_W/2]) {
            translate([bx, by, BOGIE_H/2])
                triangular_track_bogie();
        }
    }
}

// Top-Level Assembly
strider_m_operator_v1();

