// strider_m_operator_v1.scad -- STRYDER-Arctic Fleet: Non-Autonomous / Human-Controlled Unit (v1.0)
//
// Version Control & Engineering Audit:
// - Version: v1.0
// - Tracked Under: Issue #97 (Parent #81, Cross-ref #82, #88)
// - Operational Classification: Non-Autonomous Unit (Human-Controlled Operation / Micro-Installer)
//   Utilized for complex assisted maneuvers, precision field repairs, and tactile micro-wind installation.
//
// Key Subsystems & Design Features (from Arctic Fleet Classification Schematic):
// 1. Visible Operator Cockpit & Safety Cell (NASCAR-Style Full Roll Cage):
//    - Heavy-duty high-tensile tubular steel roll cage (ROPS/FOPS - Roll-Over & Falling Object Protection)
//      fully encasing the human operator from overhead, lateral impact, and falling loads.
//    - Overhead steel canopy / deflector shield completely protecting the operator against accidental crane drop.
//    - Human-scale operator saddle seat, handlebar steering controls, and direct operator feedback HUD/display.
//    - Manual hydraulic override control lever rack protected inside the armored safety cell.
// 2. Separate Isolated Crane Module & Kinematic Barrier:
//    - Articulating micro-installer crane boom is mounted on a structurally isolated rear turret pedestal
//      behind a solid armored deflection bulkhead wall separating the crane envelope from the operator.
// 2. Heavy Articulating Micro-Installer Crane Boom:
//    - 3-segment hydraulic boom arm with heavy base turret, elbow actuator, and rotating wrist.
//    - Hydraulic grapple claw end-effector holding/installing a Modular Micro-Wind Unit (Type A, Assy P/N: 12845).
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
    translate([0.9, 0, CHASSIS_H + 0.75]) {
        // Steering post
        color(COL_BOOM_DARK) {
            rotate([0, 22, 0]) cylinder(h=0.8, r=0.08, center=true);
        }
        // Handlebars
        translate([0.15, 0, 0.42]) {
            color(COL_HANDLEBAR_STEEL) {
                rotate([90, 0, 0]) cylinder(h=1.1, r=0.04, center=true);
                // Rubber handgrips
                for (gy = [-0.55, 0.55]) {
                    translate([0, gy, 0]) rotate([90, 0, 0])
                        cylinder(h=0.22, r=0.06, center=true);
                }
            }
            // Direct Operator Feedback HUD & Instrument Console
            color(COL_BOOM_DARK) {
                translate([0.08, 0, 0.12]) rotate([0, -35, 0]) {
                    cube([0.18, 0.42, 0.22], center=true);
                    // Active digital display screen
                    color([0.15, 0.85, 0.35]) translate([0.09, 0, 0])
                        cube([0.02, 0.34, 0.16], center=true);
                }
            }
        }
    }

    // Manual Hydraulic Override Controls (Bank of lever joysticks on starboard flank)
    translate([0.1, 0.75, CHASSIS_H + 0.55]) {
        color(COL_BOOM_DARK) {
            cube([0.5, 0.28, 0.2], center=true);
            // 4x Hydraulic override levers
            for (lx = [-0.15, -0.05, 0.05, 0.15]) {
                translate([lx, 0, 0.18]) rotate([15, 0, 0]) {
                    color(COL_HANDLEBAR_STEEL) cylinder(h=0.22, r=0.02, center=true);
                    color("Red") translate([0, 0, 0.12]) sphere(r=0.035);
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
// Subsystem 3: Articulating Micro-Installer Crane Boom & Modular Wind Unit
// -----------------------------------------------------------------------------

module micro_installer_crane_arm() {
    // Base Turret on Rear Chassis Deck
    translate([-1.8, 0, CHASSIS_H + 0.35]) {
        color(COL_BOOM_DARK) {
            cylinder(h=0.45, r=0.65, center=true, $fn=32);
            // Turret bearing ring
            translate([0, 0, 0.25])
                cylinder(h=0.15, r=0.55, center=true, $fn=32);
        }

        // Lower Mast / Shoulder Segment (Leaning backwards/upward matching schematic)
        translate([0, 0, 0.45]) rotate([0, -25, 0]) {
            color(COL_BOOM_ORANGE) {
                translate([0, 0, 1.2])
                    cube([0.45, 0.55, 2.4], center=true);
            }
            // Shoulder Hydraulic Ram
            translate([-0.3, 0, 0.6]) rotate([0, 15, 0]) {
                color(COL_BOOM_DARK) cylinder(h=1.2, r=0.12, center=true);
                color(COL_HYDRAULIC_RAM) translate([0, 0, 0.6])
                    cylinder(h=0.8, r=0.07, center=true);
            }

            // Elbow Joint & Upper Jib Arm (Reaching forward horizontally towards rear/side payload)
            translate([0, 0, 2.4]) rotate([0, 105, 0]) {
                color(COL_BOOM_ORANGE) {
                    translate([0, 0, 1.3])
                        cube([0.38, 0.45, 2.6], center=true);
                }
                // Elbow actuator
                translate([0.25, 0, 0.8]) rotate([0, -15, 0]) {
                    color(COL_BOOM_DARK) cylinder(h=1.0, r=0.10, center=true);
                    color(COL_HYDRAULIC_RAM) translate([0, 0, 0.5])
                        cylinder(h=0.6, r=0.06, center=true);
                }

                // Rotating Wrist & Heavy Hydraulic Grapple Claw
                translate([0, 0, 2.6]) rotate([0, -80, 0]) {
                    color(COL_BOOM_DARK) {
                        cylinder(h=0.35, r=0.25, center=true);
                        translate([0, 0, 0.25]) cube([0.45, 0.45, 0.15], center=true);
                    }
                    // Hydraulic Grapple Jaws
                    color(COL_CHASSIS_DARK) {
                        for (jy = [-0.22, 0.22]) {
                            translate([0, jy, 0.45]) rotate([0, 0, jy > 0 ? -25 : 25])
                                cube([0.15, 0.12, 0.45], center=true);
                        }
                    }

                    // Modular Micro-Wind Unit (Type A, Assy P/N: 12845, Serial: 0001-A)
                    translate([0, 0, 1.05]) {
                        color(COL_MICRO_WIND_UNIT) {
                            cube([1.4, 0.95, 0.85], center=true);
                            translate([0.72, 0, 0]) rotate([0, 90, 0])
                                cylinder(h=0.25, r=0.35, center=true, $fn=28);
                        }
                        color([0.2, 0.2, 0.25]) {
                            translate([0, 0.49, 0])
                                cube([1.1, 0.04, 0.55], center=true);
                        }
                    }
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------
// Complete Non-Autonomous Stryder Assembly
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

    // 2. Structurally Isolated Articulating Micro-Installer Crane Boom (Rear-Mounted behind Bulkhead)
    micro_installer_crane_arm();

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
