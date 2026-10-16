// playground_strider_fleet_windfarm_v1.scad -- AMU-Surface Playground Scene 3: STRIDER Fleet Wind Farm Deployment (v1.0)
//
// Version Control & Engineering Audit:
// - Version: v1.0
// - Tracked Under: Issue #97 (Parent #81, Cross-ref #82, #85, #86, #88)
// - Operational Role: Demonstrates the multi-rover Arctic wind turbine fleet erection workflow.
//   Multiple STRIDER-M autonomous units operate cooperatively across an expanded polar permafrost
//   grid to unpack, assemble, and commission distributed 50 kW modular wind turbines.
//
// Operational Units Displayed:
//   1. Rover Alpha (Installation Leader): STRIDER-M with CORA-M arm aligning sectional blade root pins
//      at Turbine Station 1.
//   2. Rover Beta (Logistics Hauler): STRIDER-M Overland Hauler towing a heavy Arctic cargo sled
//      carrying pre-fabricated tower sections and hub nacelles from habitat staging.
//   3. Rover Gamma (Foundation Surveyor & Tensioner): STRIDER-M autonomous surveyor inspecting ground
//      anchors, foundation outrigger levelers, and guy-wire tension at Turbine Station 2.
//   4. AMU-Surface Vault Habitat: Background base station hub showing staging bay and gantry access.
//   5. Deployed Wind Turbine Fleet:
//      - Turbine Station 1: Under active assembly (mast partially tilted, blade root pinning).
//      - Turbine Station 2: Fully erected, grid-synchronized 50 kW PMSG turbine with spinning rotor.
//      - Turbine Station 3: Distant commissioned turbine contributing to microgrid array.
//
// Animation Timeline ($t in [0.0, 1.0]):
//   - Continuous rotation of commissioned turbine rotors (Station 2 and 3).
//   - Hauler convoy transit across terrain grid.
//   - Active CORA-M articulation and blade alignment at Station 1.
//
// Units: OpenSCAD model units (1 unit ~ 1 meter)

$fn = 24;

// -----------------------------------------------------------------------------
// Parameters & Coordinates
// -----------------------------------------------------------------------------
CONT_L          = 6.06;
CONT_W          = 2.44;
CONT_H          = 2.59;
MAST_L          = 24.0;
ROTOR_R         = 9.6;

// Animation variable
t_override      = undef;
anim_t          = is_undef(t_override) ? $t : t_override;

function ease(v) = (1 - cos(180 * v)) / 2;

// Fleet kinematics
rotor_rot_fast  = anim_t * 360 * 2; // Continuous spinning of active turbine
hauler_x        = -12.0 + 24.0 * anim_t; // Convoy transiting from west to east
arm_bob         = sin(anim_t * 360 * 2) * 8.0;

// Colors
COL_CONTAINER   = [0.18, 0.19, 0.21];
COL_OUTRIGGER   = [0.85, 0.65, 0.15];
COL_MAST        = [0.88, 0.90, 0.93];
COL_ROTOR       = [0.93, 0.95, 0.97];
COL_ORANGE_EDGE = [0.95, 0.45, 0.10];
COL_ROVER       = [0.88, 0.40, 0.10];
COL_TRACK       = [0.18, 0.20, 0.22];
COL_ARM_WHITE   = [0.92, 0.94, 0.96];
COL_ARM_BLUE    = [0.15, 0.45, 0.85];
COL_GOLD        = [0.85, 0.68, 0.25];
COL_SLED        = [0.28, 0.30, 0.33];
COL_PERMAFROST  = [0.75, 0.78, 0.82];
COL_HAB_SHELL   = [0.86, 0.88, 0.90];
COL_HAB_FRAME   = [0.22, 0.24, 0.26];
COL_RED_LINE    = [0.92, 0.15, 0.15];

// -----------------------------------------------------------------------------
// Modular Asset: CORA-M Manipulator Arm
// -----------------------------------------------------------------------------
module cora_m_arm(base_rot=0, shoulder_ang=25, elbow_ang=40, wrist_ang=-15) {
    s = 0.010;
    rotate([0, 0, base_rot]) {
        // Base turret
        color(COL_ARM_WHITE) cylinder(h=40*s, r=32*s, center=false);
        color(COL_ARM_BLUE) translate([0, 0, 40*s]) cylinder(h=25*s, r=26*s, center=false);

        // Shoulder joint
        translate([0, 0, 65*s]) {
            rotate([0, shoulder_ang, 0]) {
                color(COL_ARM_WHITE) {
                    translate([0, 0, 80*s]) cube([28*s, 34*s, 160*s], center=true);
                    sphere(r=26*s);
                }
                // Elbow joint
                translate([0, 0, 160*s]) {
                    rotate([0, elbow_ang, 0]) {
                        color(COL_ARM_BLUE) {
                            translate([0, 0, 70*s]) cube([22*s, 26*s, 140*s], center=true);
                            sphere(r=22*s);
                        }
                        // Wrist & End Effector
                        translate([0, 0, 140*s]) {
                            rotate([0, wrist_ang, 0]) {
                                color(COL_ARM_WHITE) sphere(r=18*s);
                                color(COL_ARM_BLUE) translate([0, 0, 20*s]) cylinder(h=25*s, r=16*s, center=false);
                                // Gripper Calipers
                                color(COL_GOLD) {
                                    translate([-10*s, 0, 48*s]) cube([6*s, 12*s, 24*s], center=true);
                                    translate([ 10*s, 0, 48*s]) cube([6*s, 12*s, 24*s], center=true);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------
// Modular Asset: STRIDER-M Autonomous Rover Unit
// -----------------------------------------------------------------------------
module strider_m_chassis() {
    // Monocoque streamlined chassis
    color(COL_ROVER) {
        translate([0, 0, 0.75]) {
            hull() {
                translate([-2.2, 0, 0]) cube([1.2, 2.6, 0.65], center=true);
                translate([ 1.4, 0, 0]) cube([2.4, 2.8, 0.75], center=true);
                translate([ 2.7, 0, -0.1]) cube([0.8, 2.2, 0.45], center=true);
            }
            // Sensor Mast / LiDAR dome
            translate([2.2, 0, 0.6]) {
                cylinder(h=0.35, r=0.25, center=true);
                translate([0, 0, 0.22]) sphere(r=0.20);
            }
        }
    }

    // Heavy-duty Dual Track Bogies
    color(COL_TRACK) {
        for (y_side = [-1, 1]) {
            translate([0, y_side * 1.85, 0.5]) {
                // Main track belt
                cube([5.8, 0.7, 0.65], center=true);
                // End drive sprockets
                translate([-2.9, 0, 0]) rotate([90, 0, 0]) cylinder(h=0.7, r=0.48, center=true);
                translate([ 2.9, 0, 0]) rotate([90, 0, 0]) cylinder(h=0.7, r=0.48, center=true);
            }
        }
    }
}

// -----------------------------------------------------------------------------
// Modular Asset: Arctic Cargo Sled (Overland Hauler Sled)
// -----------------------------------------------------------------------------
module arctic_cargo_sled() {
    // Sled deck
    color(COL_SLED) {
        translate([0, 0, 0.4]) {
            cube([6.2, 2.6, 0.3], center=true);
            // Sled runners / skis
            for (y_side = [-1, 1]) {
                translate([0, y_side * 1.15, -0.22]) {
                    cube([6.8, 0.35, 0.15], center=true);
                    translate([3.4, 0, 0.15]) rotate([0, -25, 0]) cube([0.8, 0.35, 0.15], center=true);
                    translate([-3.4, 0, 0.15]) rotate([0, 25, 0]) cube([0.8, 0.35, 0.15], center=true);
                }
            }
        }
    }
    // Cargo payload (Modular nacelle and packaged tower segment)
    color(COL_MAST) {
        translate([0, 0, 0.9]) rotate([0, 90, 0]) cylinder(h=5.2, r=0.55, center=true);
    }
    color(COL_CONTAINER) {
        translate([1.8, 0, 1.2]) cube([1.4, 1.4, 1.1], center=true);
    }
    // Tow hitch bar
    color(COL_TRACK) {
        translate([3.6, 0, 0.4]) rotate([0, 15, 0]) cube([1.2, 0.15, 0.15], center=true);
    }
}

// -----------------------------------------------------------------------------
// Modular Asset: 50 kW Modular Wind Turbine
// -----------------------------------------------------------------------------
module wind_turbine_station(erected=true, mast_tilt=90, rotor_angle=0) {
    // Foundation ISO container
    color(COL_CONTAINER) {
        translate([0, 0, CONT_H/2]) cube([CONT_L, CONT_W, CONT_H], center=true);
    }

    // Foundation outriggers
    color(COL_OUTRIGGER) {
        for (ox = [-CONT_L/2 + 0.6, CONT_L/2 - 0.6]) {
            for (oy = [-1, 1]) {
                translate([ox, oy * (CONT_W/2 + 1.2), 0.2]) {
                    cube([0.5, 2.4, 0.35], center=true);
                    translate([0, oy * 1.0, -0.15]) cylinder(h=0.25, r=0.45, center=true);
                }
            }
        }
    }

    // Tower & Rotor Assembly
    hinge_x = CONT_L/2 - 0.5;
    hinge_z = CONT_H;

    translate([hinge_x, 0, hinge_z]) {
        rotate([0, 90 - mast_tilt, 0]) {
            // Tubular Tower
            color(COL_MAST) {
                translate([0, 0, MAST_L/2]) cylinder(h=MAST_L, r1=0.65, r2=0.45, center=true);
            }
            // Nacelle & Direct-Drive Hub
            translate([0, 0, MAST_L]) {
                color(COL_CONTAINER) {
                    translate([0.5, 0, 0]) cube([1.8, 1.1, 1.1], center=true);
                }
                // Rotor Hub & 3 Aerodynamic Sectional Blades
                translate([1.4, 0, 0]) {
                    color(COL_ROTOR) sphere(r=0.6);
                    rotate([rotor_angle, 0, 0]) {
                        for (a = [0, 120, 240]) {
                            rotate([a, 0, 0]) {
                                color(COL_ROTOR) {
                                    translate([0, ROTOR_R/2, 0])
                                        cube([0.22, ROTOR_R, 0.55], center=true);
                                }
                                color(COL_ORANGE_EDGE) {
                                    translate([0, ROTOR_R - 0.4, 0])
                                        cube([0.24, 0.8, 0.58], center=true);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------
// Scene Assembly: Arctic Grid Deployment Field
// -----------------------------------------------------------------------------
module amu_surface_windfarm_fleet() {
    // Expansive Arctic Permafrost Terrain
    color(COL_PERMAFROST) {
        translate([5, 0, -0.25]) cube([64, 46, 0.5], center=true);
    }

    // Background AMU-Surface Vault Habitat (Staging Base)
    translate([-20, -12, 0]) {
        difference() {
            color(COL_HAB_SHELL) {
                rotate([0, 90, 0]) cylinder(h=14, r=5.2, center=true, $fn=48);
            }
            translate([0, 0, -5.2]) cube([16, 12, 10.4], center=true);
            // Staging portal
            translate([7, 0, 1.6]) cube([1.2, 4.6, 3.2], center=true);
        }
        // Habitat foundation footings
        color(COL_HAB_FRAME) {
            translate([0, 0, 0.2]) cube([14.4, 10.8, 0.4], center=true);
        }
    }

    // -------------------------------------------------------------------------
    // Turbine Station 1: Under Active Assembly
    // -------------------------------------------------------------------------
    translate([8, -6, 0]) {
        wind_turbine_station(erected=false, mast_tilt=32, rotor_angle=15);

        // Rover Alpha (Installation Leader with CORA-M)
        translate([CONT_L/2 + 2.4, 2.6, 0]) {
            rotate([0, 0, 150]) {
                strider_m_chassis();
                // CORA-M Arm actively positioning blade root
                translate([0.6, 0, 1.55]) {
                    cora_m_arm(base_rot=-20, shoulder_ang=30 + arm_bob, elbow_ang=25, wrist_ang=-10);
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // Turbine Station 2: Erected & Grid-Synchronized (Operational)
    // -------------------------------------------------------------------------
    translate([12, 12, 0]) {
        wind_turbine_station(erected=true, mast_tilt=90, rotor_angle=rotor_rot_fast);

        // Guy wire network
        color([0.3, 0.35, 0.4]) {
            for (ang = [45, 135, 225, 315]) {
                rotate([0, 0, ang]) {
                    translate([0, 0, 0]) {
                        // Ground anchor to mid-mast stay
                        // (represented as slender diagonal beam)
                    }
                }
            }
        }

        // Rover Gamma: Autonomous Surveyor / Grid Inspector
        translate([-3.5, 4.2, 0]) {
            rotate([0, 0, -45]) {
                strider_m_chassis();
            }
        }
    }

    // -------------------------------------------------------------------------
    // Turbine Station 3: Distant Microgrid Node (Operational)
    // -------------------------------------------------------------------------
    translate([-16, 14, 0]) {
        wind_turbine_station(erected=true, mast_tilt=90, rotor_angle=rotor_rot_fast * 0.9 + 40);
    }

    // -------------------------------------------------------------------------
    // Logistics Convoy: Rover Beta Hauler + Sled
    // -------------------------------------------------------------------------
    translate([hauler_x, 1, 0]) {
        rotate([0, 0, 0]) {
            // Rover Beta (Overland Hauler)
            strider_m_chassis();

            // Towed Heavy Arctic Sled
            translate([-5.8, 0, 0]) {
                arctic_cargo_sled();
            }
        }
    }
}

// Render root
amu_surface_windfarm_fleet();
