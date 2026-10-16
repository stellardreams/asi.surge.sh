// strider_m_autonomous_v1_1.scad -- STRYDER-Arctic Autonomous Heavy Hauler (v1.1 - Minimalist Sled Hauler Spec)
//
// Version Control & Engineering Audit:
// - Version: v1.1
// - Tracked Under: Issue #97 (Parent #81, Cross-ref #82, #88)
// - Operational Role: Surface Overland Heavy Hauling & Swarm Expedition Logistics
//   Categorically deployed for autonomous cargo hauling, modular equipment transport,
//   and pulling heavy sledged payloads across arctic sea ice, snowpack, permafrost, and lunar/martian regolith.
//
// Key Subsystems & Design Features (from Arctic Field Expedition Photographs):
// 1. Sleek Monocoque Low-Profile Aerodynamic Hull (https://www.merriam-webster.com/dictionary/monocoque):
//    - Seamless bronze/metallic copper thermal skin with smooth integrated mudguards.
//    - Low center-of-gravity flatbed deck with rear solar trickle charging array.
// 2. Integrated Sensor Suite & Autonomous Avionics:
//    - Flush forward-dorsal puck LiDAR dome with multi-color perimeter status ring (Green/Yellow/Red).
//    - Elevated transverse multi-camera perception bar (optical lenses, thermal sensors, digital telemetry screen).
// 3. Heavy Four-Bogie Triangular Track Drive:
//    - 4x independent high-traction triangular crawler bogies with wide rubber-steel composite treads,
//      heavy dual idlers, and quad road-wheel dampening banks.
// 4. Heavy Arctic Sled Tow Hitch & Articulated Drawbar:
//    - Reinforced pintle tow hitch at rear chassis center.
//    - Articulated structural tow bar connecting directly to the heavy cargo sled.
// 5. High-Capacity Arctic Expeditions Sled (Hauler Payload):
//    - Heavy insulated sled skid with reinforced steel runners.
//    - Strapped modular expedition payload: pelican flight cases, high-pressure composite gas cylinders,
//      scientific crates, and compact robotic field arm module.
//
// Units: OpenSCAD model units

$fn = 32;

// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------
ROVER_L         = 6.2;
ROVER_W         = 4.6;
DECK_H          = 0.95;
GROUND_CLEAR    = 0.55;

BOGIE_L         = 2.8;
BOGIE_W         = 1.1;
BOGIE_H         = 1.45;

SLED_L          = 4.6;
SLED_W          = 2.6;
SLED_H          = 0.85;

// Colors
COL_COPPER_BODY     = [0.78, 0.46, 0.32]; // Metallic warm copper / arctic bronze
COL_CHASSIS_DARK    = [0.18, 0.20, 0.22];
COL_TRACK_RUBBER    = [0.22, 0.23, 0.25];
COL_TRACK_CLEAT     = [0.35, 0.37, 0.40];
COL_WHEEL_CHROME    = [0.75, 0.77, 0.80];
COL_LIDAR_BLACK     = [0.12, 0.13, 0.15];
COL_STATUS_GREEN    = [0.20, 0.90, 0.35];
COL_STATUS_YELLOW   = [0.95, 0.80, 0.15];
COL_STATUS_RED      = [0.90, 0.20, 0.15];
COL_CAMERA_BAR      = [0.72, 0.42, 0.30];
COL_LENS_CYAN       = [0.10, 0.65, 0.75];
COL_SOLAR_NAVY      = [0.10, 0.14, 0.28];
COL_SLED_HULL       = [0.75, 0.77, 0.76]; // Arctic weathered composite
COL_SLED_RUNNER     = [0.30, 0.32, 0.35];
COL_STRAP_OLIVE     = [0.38, 0.42, 0.28];

// -----------------------------------------------------------------------------
// Subsystem 1: High-Traction Triangular Track Bogies
// -----------------------------------------------------------------------------

module triangular_hauler_bogie() {
    // Continuous wide crawler loop
    color(COL_TRACK_RUBBER) {
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

    // Heavy transverse traction cleats / grousers
    color(COL_TRACK_CLEAT) {
        step = (BOGIE_L - 0.8) / 8;
        for (gx = [-BOGIE_L/2 + 0.4 : step : BOGIE_L/2 - 0.4]) {
            translate([gx, 0, -BOGIE_H/2])
                cube([0.16, BOGIE_W + 0.06, 0.08], center=true);
        }
    }

    // Road wheels and drive sprockets
    color(COL_WHEEL_CHROME) {
        // Top drive hub
        translate([0, 0, BOGIE_H/2 - 0.22])
            rotate([90, 0, 0]) cylinder(h=BOGIE_W - 0.12, r=0.40, center=true, $fn=24);
        // Front & rear idlers
        for (ix = [-BOGIE_L/2 + 0.45, BOGIE_L/2 - 0.45]) {
            translate([ix, 0, -BOGIE_H/2 + 0.35])
                rotate([90, 0, 0]) cylinder(h=BOGIE_W - 0.12, r=0.32, center=true, $fn=20);
        }
        // 4x Dual bogie road wheels
        for (rx = [-0.6, -0.2, 0.2, 0.6]) {
            translate([rx, 0, -BOGIE_H/2 + 0.32])
                rotate([90, 0, 0]) cylinder(h=BOGIE_W - 0.15, r=0.26, center=true, $fn=18);
        }
    }
}

// -----------------------------------------------------------------------------
// Subsystem 2: Streamlined Rover Monocoque Body
// -----------------------------------------------------------------------------

module streamlined_rover_hull() {
    // Main sculptured metallic copper deck
    color(COL_COPPER_BODY) {
        hull() {
            // Front blunt nose
            translate([ROVER_L/2 - 0.4, 0, GROUND_CLEAR + 0.35])
                cube([0.8, 2.0, 0.55], center=true);
            // Mid body
            translate([0, 0, GROUND_CLEAR + 0.45])
                cube([ROVER_L - 1.2, 2.4, 0.65], center=true);
            // Rear flat deck
            translate([-ROVER_L/2 + 0.4, 0, GROUND_CLEAR + 0.42])
                cube([0.8, 2.3, 0.55], center=true);
        }

        // Integrated continuous side mudguards over track bogies
        for (sy = [-ROVER_W/2 + BOGIE_W/2, ROVER_W/2 - BOGIE_W/2]) {
            translate([0, sy, GROUND_CLEAR + 0.62]) {
                hull() {
                    translate([1.6, 0, 0]) cube([BOGIE_L - 0.4, BOGIE_W + 0.22, 0.12], center=true);
                    translate([-1.6, 0, 0]) cube([BOGIE_L - 0.4, BOGIE_W + 0.22, 0.12], center=true);
                }
            }
        }
    }

    // Rear Solar Trickle Charging Panel
    color(COL_SOLAR_NAVY) {
        translate([-ROVER_L/2 + 0.9, 0, GROUND_CLEAR + 0.77])
            cube([1.4, 1.8, 0.04], center=true);
    }

    // Flush Forward-Dorsal LiDAR Puck with Status Light Ring
    translate([1.1, 0, GROUND_CLEAR + 0.75]) {
        // Pedestal base
        color(COL_COPPER_BODY)
            cylinder(h=0.15, r=0.65, center=true, $fn=32);
        // Status light ring (Red/Yellow/Green multi-spectral indicator)
        translate([0, 0, 0.08]) {
            color(COL_STATUS_GREEN) rotate([0, 0, 30])
                cube([0.15, 1.15, 0.05], center=true);
            color(COL_STATUS_YELLOW) rotate([0, 0, -30])
                cube([0.15, 1.15, 0.05], center=true);
        }
        // Black LiDAR rotating sensor puck
        color(COL_LIDAR_BLACK) translate([0, 0, 0.22])
            cylinder(h=0.25, r=0.52, center=true, $fn=32);
    }

    // Elevated Transverse Camera / Perception Sensor Bar (Dorsal Aft)
    translate([-0.6, 0, GROUND_CLEAR + 0.95]) {
        // Main sensor bar housing
        color(COL_CAMERA_BAR) {
            cube([0.55, 1.8, 0.42], center=true);
            // 4x Top cylindrical cooling fins / heat sinks
            for (cy = [-0.6, -0.2, 0.2, 0.6]) {
                translate([0, cy, 0.24]) cylinder(h=0.10, r=0.12, center=true);
            }
        }
        // Multi-Camera Optical Lenses & Telemetry Screen
        translate([0.28, 0, 0]) {
            // Central digital diagnostic display screen
            color([0.12, 0.15, 0.20])
                cube([0.02, 0.55, 0.25], center=true);
            // Dual left optical stereo cameras
            color(COL_LENS_CYAN) {
                translate([0, -0.62, 0]) rotate([0, 90, 0]) cylinder(h=0.04, r=0.12, center=true);
                translate([0, -0.38, 0]) rotate([0, 90, 0]) cylinder(h=0.04, r=0.09, center=true);
            }
            // Dual right optical stereo cameras
            color(COL_LENS_CYAN) {
                translate([0, 0.62, 0]) rotate([0, 90, 0]) cylinder(h=0.04, r=0.12, center=true);
                translate([0, 0.38, 0]) rotate([0, 90, 0]) cylinder(h=0.04, r=0.09, center=true);
            }
        }
    }

    // Heavy Rear Tow Pintle & Drawbar Coupling
    translate([-ROVER_L/2, 0, GROUND_CLEAR + 0.35]) {
        color(COL_CHASSIS_DARK) {
            cube([0.35, 0.6, 0.4], center=true);
            // Tow pin
            translate([-0.15, 0, 0]) cylinder(h=0.45, r=0.08, center=true);
        }
    }
}

// -----------------------------------------------------------------------------
// Subsystem 3: Heavy Arctic Cargo Sled & Expedition Payload
// -----------------------------------------------------------------------------

module arctic_cargo_sled() {
    // Tow Drawbar linking Rover to Sled
    color(COL_CHASSIS_DARK) {
        translate([1.2, 0, 0.45]) {
            rotate([0, -8, 0]) cube([2.2, 0.14, 0.12], center=true);
            // Hitch swivel rings
            translate([1.1, 0, 0.12]) rotate([90, 0, 0])
                cylinder(h=0.12, r=0.15, center=true);
            translate([-1.1, 0, -0.12]) rotate([90, 0, 0])
                cylinder(h=0.12, r=0.15, center=true);
        }
    }

    // Main Weathered Sled Body / Tub
    color(COL_SLED_HULL) {
        translate([0, 0, 0.45]) {
            difference() {
                // Outer tub with curved front bow
                hull() {
                    translate([SLED_L/2 - 0.4, 0, 0.15]) rotate([0, -35, 0])
                        cube([0.5, SLED_W, SLED_H], center=true);
                    translate([0, 0, 0])
                        cube([SLED_L - 0.8, SLED_W, SLED_H], center=true);
                    translate([-SLED_L/2 + 0.3, 0, 0])
                        cube([0.6, SLED_W, SLED_H], center=true);
                }
                // Cargo cargo cavity
                translate([0, 0, 0.15])
                    cube([SLED_L - 0.4, SLED_W - 0.35, SLED_H], center=true);
            }
        }
    }

    // Low-Friction Steel Skid Runners (Under Sled Base)
    color(COL_SLED_RUNNER) {
        for (ry = [-SLED_W/2 + 0.25, SLED_W/2 - 0.25]) {
            translate([0, ry, 0.06]) {
                hull() {
                    translate([SLED_L/2 - 0.2, 0, 0.15]) rotate([0, -45, 0])
                        cube([0.3, 0.22, 0.12], center=true);
                    translate([0, 0, 0])
                        cube([SLED_L - 0.4, 0.22, 0.12], center=true);
                }
            }
        }
    }

    // Strapped Expedition Cargo Payload (Hauling on Snow/Ice):
    // 1. Blue Hard-Shell Expedition Storage Cases
    color([0.20, 0.42, 0.65]) {
        translate([-0.6, 0.45, 0.95]) cube([1.8, 1.0, 0.85], center=true);
        translate([0.6, -0.55, 0.75]) cube([1.4, 0.75, 0.55], center=true);
    }

    // 2. High-Visibility Orange Field Equipment Crates
    color([0.88, 0.45, 0.15]) {
        translate([-0.8, -0.45, 0.75]) cube([1.6, 0.85, 0.55], center=true);
    }

    // 3. Pressurized Cryogenic / Gas Cylinders in Transport Rack
    color([0.80, 0.82, 0.85]) {
        for (cy = [-0.15, 0.15]) {
            translate([0.5, cy, 1.15]) rotate([0, 90, 0])
                cylinder(h=2.2, r=0.18, center=true, $fn=24);
        }
    }

    // 4. Compact Field Robotic Arm Manipulator Module (Stowed on Sled)
    translate([-1.6, 0.35, 1.0]) {
        color(COL_CHASSIS_DARK) {
            cube([0.7, 0.6, 0.5], center=true);
            // Arm linkage segments stowed
            translate([0, 0, 0.35]) rotate([0, 35, 0])
                cube([0.15, 0.18, 0.6], center=true);
        }
        color(COL_WHEEL_CHROME) {
            translate([0.1, 0, 0.65]) sphere(r=0.12);
        }
    }

    // 5. Heavy-Duty Cargo Retention Ratchet Straps
    color(COL_STRAP_OLIVE) {
        for (sx = [-1.4, -0.2, 1.0]) {
            translate([sx, 0, 0.95])
                cube([0.08, SLED_W + 0.05, 1.1], center=true);
        }
    }
}

// -----------------------------------------------------------------------------
// Complete Autonomous Sled Hauler Assembly
// -----------------------------------------------------------------------------

module strider_m_autonomous_v1_1() {
    // 1. Minimalist Autonomous Rover Unit
    streamlined_rover_hull();

    // 2. Four Independent High-Traction Triangular Bogies
    for (bx = [-1.7, 1.7]) {
        for (by = [-ROVER_W/2 + BOGIE_W/2, ROVER_W/2 - BOGIE_W/2]) {
            translate([bx, by, BOGIE_H/2])
                triangular_hauler_bogie();
        }
    }

    // 3. Heavy Arctic Cargo Sled (Being Hauled Behind Rover on Ice/Snow)
    translate([-ROVER_L/2 - SLED_L/2 - 1.2, 0, 0])
        arctic_cargo_sled();
}

// Top-Level Assembly
strider_m_autonomous_v1_1();
