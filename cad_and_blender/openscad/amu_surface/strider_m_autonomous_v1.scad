// strider_m_autonomous_v1.scad -- STRYDER-Arctic Fleet: Autonomous Unit (v1.0)
//
// Version Control & Engineering Audit:
// - Version: v1.0
// - Tracked Under: Issue #97 (Parent #81, Cross-ref #82, #88)
// - Operational Classification: Autonomous Unit (AI-Driven Mission Control)
//   Deployed for swarm logistics, remote installation, and unattended micro-wind unit staging.
//
// Key Subsystems & Design Features (from Arctic Fleet Classification Schematic):
// 1. Complete Removal of Operator Controls:
//    - Smooth sculpted cowl / ATV chassis deck; zero seat, handlebars, or manual levers.
// 2. AI Logistics and Navigation Module:
//    - Front perception hood with integrated stereo vision, obstacle avoidance sensors,
//      and ruggedized computational bus.
// 3. Multiple-Redundant Sensor Array:
//    - Dorsal sensor pod (elevated cube housing with rotating LiDAR dome, dual forward cameras).
// 4. Modular Cargo Staging Deck:
//    - Rear cargo bay formatted with stacked modular micro-wind units (Assy P/N: 12845).
// 5. Heavy Continuous Arctic Crawler Tracks:
//    - 4x independent triangular track bogies with gold ice grousers and exposed chrome road wheels.
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
COL_SENSOR_HOUSING  = [0.22, 0.24, 0.26];
COL_SENSOR_LENS     = [0.10, 0.65, 0.75]; // Cyan optical glass
COL_LIDAR_DOME      = [0.15, 0.15, 0.18];
COL_CARGO_CRATE     = [0.75, 0.42, 0.15];
COL_CRATE_FRAME     = [0.25, 0.27, 0.30];

// -----------------------------------------------------------------------------
// Subsystem 1: High-Traction Triangular Track Bogies
// -----------------------------------------------------------------------------

module triangular_track_bogie() {
    // Continuous rubber-steel composite belt around 3 sprockets
    color(COL_TRACK_STEEL) {
        difference() {
            hull() {
                // Top drive wheel
                translate([0, 0, BOGIE_H/2 - 0.22])
                    rotate([90, 0, 0]) cylinder(h=BOGIE_W, r=0.48, center=true);
                // Front idler
                translate([BOGIE_L/2 - 0.45, 0, -BOGIE_H/2 + 0.35])
                    rotate([90, 0, 0]) cylinder(h=BOGIE_W, r=0.38, center=true);
                // Rear idler
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

    // Deep ice-grousers across ground contact perimeter
    color(COL_GROUSER_GOLD) {
        step = (BOGIE_L - 0.9) / 7;
        for (gx = [-BOGIE_L/2 + 0.45 : step : BOGIE_L/2 - 0.45]) {
            translate([gx, 0, -BOGIE_H/2])
                cube([0.14, BOGIE_W + 0.08, 0.08], center=true);
        }
    }

    // Exposed Wheels & Hubs
    color(COL_WHEEL_CHROME) {
        // Top drive hub
        translate([0, 0, BOGIE_H/2 - 0.22])
            rotate([90, 0, 0]) cylinder(h=BOGIE_W - 0.12, r=0.40, center=true, $fn=24);
        // Front & rear idlers
        for (ix = [-BOGIE_L/2 + 0.45, BOGIE_L/2 - 0.45]) {
            translate([ix, 0, -BOGIE_H/2 + 0.35])
                rotate([90, 0, 0]) cylinder(h=BOGIE_W - 0.12, r=0.32, center=true, $fn=20);
        }
        // Dual mid road wheels
        for (rx = [-0.45, 0.45]) {
            translate([rx, 0, -BOGIE_H/2 + 0.32])
                rotate([90, 0, 0]) cylinder(h=BOGIE_W - 0.15, r=0.28, center=true, $fn=18);
        }
    }
}

// -----------------------------------------------------------------------------
// Subsystem 2: Autonomous AI Chassis & Nose Module
// -----------------------------------------------------------------------------

module autonomous_chassis() {
    // Armored main belly and chassis core
    color(COL_CHASSIS_DARK) {
        translate([0, 0, CHASSIS_H/2 - 0.05])
            cube([ROVER_L - 1.2, 1.8, CHASSIS_H], center=true);
        // Heavy front brush guard / debris bumper
        translate([ROVER_L/2 - 0.2, 0, CHASSIS_H/2 + 0.1]) {
            cube([0.35, 2.2, 0.8], center=true);
            for (by = [-1.0, 1.0]) {
                translate([0, by, 0]) cube([0.45, 0.2, 0.9], center=true);
            }
        }
    }

    // Sculpted ATV-Style Body Cowling (High-vis safety orange)
    color(COL_ARCTIC_ORANGE) {
        // Front Hood & Radiator Cowl
        translate([ROVER_L/2 - 1.4, 0, CHASSIS_H + 0.35]) {
            hull() {
                translate([0.8, 0, -0.1]) cube([0.6, 1.7, 0.5], center=true);
                translate([-0.6, 0, 0.2]) cube([1.4, 1.9, 0.7], center=true);
            }
        }
        // Smooth enclosed cockpit shell (replaces operator seat)
        translate([0, 0, CHASSIS_H + 0.55]) {
            hull() {
                translate([0.8, 0, 0]) cube([1.2, 1.8, 0.6], center=true);
                translate([-1.0, 0, -0.1]) cube([1.8, 1.7, 0.5], center=true);
            }
        }
        // Arched ATV wheel well fenders over each of the 4 track bogies
        for (fx = [-1.8, 1.8]) {
            for (fy = [-ROVER_W/2 + BOGIE_W/2, ROVER_W/2 - BOGIE_W/2]) {
                translate([fx, fy, CHASSIS_H + 0.45]) {
                    rotate([0, 0, 0])
                        cube([BOGIE_L + 0.3, BOGIE_W + 0.2, 0.15], center=true);
                    // Angled mudflap lips
                    translate([sgn(fx)*(BOGIE_L/2 + 0.15), 0, -0.15])
                        rotate([0, sgn(fx)*25, 0]) cube([0.25, BOGIE_W + 0.18, 0.12], center=true);
                }
            }
        }
    }

    // Front Autonomous AI Navigation & Perception Sensor
    translate([ROVER_L/2 - 0.65, 0, CHASSIS_H + 0.75]) {
        color(COL_SENSOR_HOUSING) {
            cube([0.55, 0.85, 0.38], center=true);
            translate([0.15, 0, 0.15]) cube([0.3, 0.90, 0.08], center=true);
        }
        color(COL_SENSOR_LENS) {
            translate([0.28, -0.25, 0]) rotate([0, 90, 0])
                cylinder(h=0.06, r=0.09, center=true);
            translate([0.28, 0.25, 0]) rotate([0, 90, 0])
                cylinder(h=0.06, r=0.09, center=true);
            translate([0.28, 0, 0]) cube([0.05, 0.25, 0.08], center=true);
        }
    }

    // Multiple-Redundant Sensor Array (Elevated Dorsal Mast)
    translate([0.3, 0, CHASSIS_H + 1.1]) {
        color(COL_SENSOR_HOUSING) {
            cube([0.7, 0.7, 0.45], center=true);
            translate([0, 0, 0.3])
                cylinder(h=0.25, r=0.25, center=true);
        }
        // Rotating 360-degree LiDAR Dome
        color(COL_LIDAR_DOME) {
            translate([0, 0, 0.5])
                cylinder(h=0.20, r=0.24, center=true);
        }
        // Dual forward-looking vision cameras
        color(COL_SENSOR_LENS) {
            translate([0.36, -0.18, 0.05]) rotate([0, 90, 0])
                cylinder(h=0.06, r=0.07, center=true);
            translate([0.36, 0.18, 0.05]) rotate([0, 90, 0])
                cylinder(h=0.06, r=0.07, center=true);
        }
    }
}

function sgn(v) = v >= 0 ? 1 : -1;

// -----------------------------------------------------------------------------
// Subsystem 3: Modular Unit Staging (Autonomous Mission Cargo Deck)
// -----------------------------------------------------------------------------

module modular_micro_wind_cargo_crate(cx, cy, cz) {
    translate([cx, cy, cz]) {
        color(COL_CARGO_CRATE) {
            cube([1.2, 0.95, 0.85], center=true);
        }
        color(COL_CRATE_FRAME) {
            translate([0.61, 0, 0])
                cube([0.04, 0.75, 0.65], center=true);
            translate([-0.61, 0, 0])
                cube([0.04, 0.75, 0.65], center=true);
            for (px = [-0.58, 0.58]) {
                for (py = [-0.45, 0.45]) {
                    translate([px, py, 0])
                        cube([0.08, 0.08, 0.88], center=true);
                }
            }
            translate([0, 0, 0.45])
                cube([0.3, 0.3, 0.08], center=true);
        }
    }
}

module autonomous_cargo_staging() {
    // Rear utility rack deck
    color(COL_CHASSIS_DARK) {
        translate([-1.8, 0, CHASSIS_H + 0.45])
            cube([2.2, 1.8, 0.12], center=true);
        // Perimeter cargo retention rails
        for (ry = [-0.9, 0.9]) {
            translate([-1.8, ry, CHASSIS_H + 0.65])
                cube([2.1, 0.08, 0.35], center=true);
        }
    }

    // Staged Modular Micro-Wind Units (Assy P/N: 12845 Type A)
    modular_micro_wind_cargo_crate(-1.2, -0.5, CHASSIS_H + 0.95);
    modular_micro_wind_cargo_crate(-1.2, 0.5, CHASSIS_H + 0.95);
    modular_micro_wind_cargo_crate(-2.3, -0.5, CHASSIS_H + 0.95);
    modular_micro_wind_cargo_crate(-2.3, 0.5, CHASSIS_H + 0.95);
}

// -----------------------------------------------------------------------------
// Complete Autonomous Stryder Assembly
// -----------------------------------------------------------------------------

module strider_m_autonomous_v1() {
    autonomous_chassis();
    autonomous_cargo_staging();

    for (bx = [-1.8, 1.8]) {
        for (by = [-ROVER_W/2 + BOGIE_W/2, ROVER_W/2 - BOGIE_W/2]) {
            translate([bx, by, BOGIE_H/2])
                triangular_track_bogie();
        }
    }
}

// Top-Level Assembly
strider_m_autonomous_v1();
