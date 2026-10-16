// playground_arm_exit_and_mount_v1.scad -- AMU-Surface Playground Scene 1: Arm Exit & Rover Mount (v1.0)
//
// Version Control & Engineering Audit:
// - Version: v1.0
// - Tracked Under: Issue #97 (Parent #81, Cross-ref #82, #85, #86, #88)
// - Operational Role: Demonstrates the 4-phase physical transfer sequence of the 7-DoF CORA-M
//   manipulator transitioning from the vaulted habitat apex ceiling gantry rail (Z = 5.15 m),
//   lowering through the portal onto the STRIDER-M chassis cam-collar dock (Z = 1.55 m),
//   locking conductive umbilical contacts, and rolling out onto the extreme polar terrain.
//
// Animation Timeline ($t in [0.0, 1.0]):
//   0.00 -> 0.25: Rail traverse along apex gantry toward portal
//   0.25 -> 0.45: Arm descends, aligns docking base, and engages rover mechanical cam-collar
//   0.45 -> 0.60: Electrical & control umbilical handshake; ceiling trolley clamp disengages
//   0.60 -> 1.00: STRIDER-M drives out through the portal onto the Arctic permafrost terrain
//
// Units: OpenSCAD model units (1 unit ~ 1 meter)

$fn = 32;

// Geometry parameters
HAB_L           = 18.0;
HAB_R           = 5.5;
PORTAL_W        = 5.2;
PORTAL_H        = 3.2;
CEILING_Z       = HAB_R - 0.35; // 5.15 m

ROVER_L         = 6.8;
ROVER_W         = 4.4;
CHASSIS_H       = 1.1;

// Animation variable
t_override      = undef;
anim_t          = is_undef(t_override) ? $t : t_override;

// Kinematic easing functions
function ease(v) = (1 - cos(180 * v)) / 2;

_t_traverse = (anim_t < 0.25) ? ease(anim_t / 0.25) : 1.0;
_t_dock     = (anim_t < 0.25) ? 0.0 :
              (anim_t < 0.45) ? ease((anim_t - 0.25) / 0.20) : 1.0;
_t_release  = (anim_t < 0.45) ? 0.0 :
              (anim_t < 0.60) ? ease((anim_t - 0.45) / 0.15) : 1.0;
_t_rollout  = (anim_t < 0.60) ? 0.0 :
              ease((anim_t - 0.60) / 0.40);

// Dynamic positions
rail_x      = -4.0 + 8.5 * _t_traverse;  // Traverses from interior X=-4 to staging lock X=4.5
rover_x     = 3.7 + 9.5 * _t_rollout;    // Rover starts under portal, rolls out to X=13.2
arm_z       = CEILING_Z - 0.35 - 3.25 * _t_dock; // Lowers from ceiling (4.8m) to rover dock (1.55m)
arm_x       = (_t_dock >= 1.0) ? (rover_x + 0.8) : rail_x;

arm_pitch   = -20 + 35 * _t_dock;
caliper_gap = (14 - 11 * _t_dock); // Clamps down as it locks onto rover

s = 0.010; // Arm scaling parameter

// Colors
COL_HULL        = [0.88, 0.90, 0.92];
COL_FRAME       = [0.22, 0.24, 0.26];
COL_ROVER       = [0.88, 0.40, 0.10];
COL_TRACK       = [0.18, 0.20, 0.22];
COL_ARM_WHITE   = [0.92, 0.94, 0.96];
COL_ARM_BLUE    = [0.15, 0.45, 0.85];
COL_GOLD        = [0.85, 0.68, 0.25];
COL_PERMAFROST  = [0.75, 0.78, 0.82];

// -----------------------------------------------------------------------------
// Subsystem 1: AMU-Surface Vault Habitat (Cutaway Architecture)
// -----------------------------------------------------------------------------
module amu_surface_vault_cutaway() {
    // Terrain base
    color(COL_PERMAFROST) {
        translate([5, 0, -0.2])
            cube([36, 24, 0.4], center=true);
    }

    // Vaulted Arched Shell (Cutaway to reveal interior)
    difference() {
        color(COL_HULL) {
            rotate([0, 90, 0])
                cylinder(h=HAB_L, r=HAB_R, center=true, $fn=64);
        }
        // Hollow interior
        rotate([0, 90, 0])
            cylinder(h=HAB_L - 0.6, r=HAB_R - 0.32, center=true, $fn=64);
        // Cutaway front-half for viewing inside
        translate([0, -HAB_R, 0])
            cube([HAB_L + 2, 2*HAB_R, 2*HAB_R + 2], center=true);
        // Ground cut
        translate([0, 0, -HAB_R])
            cube([HAB_L + 2, 2*HAB_R + 2, 2*HAB_R], center=true);
        // Rover portal opening on East wall (+X)
        translate([HAB_L/2, 0, PORTAL_H/2])
            cube([1.5, PORTAL_W, PORTAL_H + 0.2], center=true);
    }

    // Interior Apex Ceiling Gantry Rail
    color(COL_FRAME) {
        translate([0, 0, CEILING_Z]) {
            // I-Beam top flange
            cube([HAB_L - 0.8, 0.55, 0.08], center=true);
            // I-Beam vertical web
            translate([0, 0, -0.12])
                cube([HAB_L - 0.8, 0.12, 0.24], center=true);
            // I-Beam bottom rolling flange
            translate([0, 0, -0.24])
                cube([HAB_L - 0.8, 0.55, 0.08], center=true);
        }
        // Portal arch frame
        translate([HAB_L/2 - 0.1, 0, PORTAL_H/2]) {
            difference() {
                cube([0.35, PORTAL_W + 0.8, PORTAL_H + 0.8], center=true);
                cube([0.45, PORTAL_W, PORTAL_H], center=true);
            }
        }
    }
}

// -----------------------------------------------------------------------------
// Subsystem 2: STRIDER-M Rover on Field Surface
// -----------------------------------------------------------------------------
module strider_m_rover(rx) {
    translate([rx, 0, 0]) {
        // Main armored chassis
        color(COL_ROVER) {
            translate([0, 0, CHASSIS_H/2 + 0.2])
                cube([ROVER_L - 1.2, 1.8, CHASSIS_H], center=true);
            // Flatbed utility deck
            translate([-0.5, 0, CHASSIS_H + 0.22])
                cube([ROVER_L - 1.4, 2.2, 0.12], center=true);
        }

        // Standardized Cam-Lock Docking Collar
        translate([0.8, 0, CHASSIS_H + 0.28]) {
            color(COL_FRAME) {
                cylinder(h=0.18, r=0.55, center=true);
                translate([0, 0, 0.08])
                    cylinder(h=0.10, r=0.48, center=true);
            }
            // Conductive umbilical receiver contacts
            color(COL_ARM_BLUE)
                translate([0, 0, 0.12]) cylinder(h=0.04, r=0.32, center=true);
        }

        // 4x Independent Triangular Track Bogies
        for (bx = [-1.8, 1.8]) {
            for (by = [-ROVER_W/2 + 0.45, ROVER_W/2 - 0.45]) {
                translate([bx, by, 0.72]) {
                    color(COL_TRACK) {
                        hull() {
                            translate([0, 0, 0.5]) rotate([90, 0, 0]) cylinder(h=0.85, r=0.35, center=true);
                            translate([0.9, 0, -0.3]) rotate([90, 0, 0]) cylinder(h=0.85, r=0.32, center=true);
                            translate([-0.9, 0, -0.3]) rotate([90, 0, 0]) cylinder(h=0.85, r=0.32, center=true);
                        }
                    }
                    color(COL_GOLD) {
                        for (gx = [-0.8 : 0.4 : 0.8]) {
                            translate([gx, 0, -0.62]) cube([0.12, 0.95, 0.08], center=true);
                        }
                    }
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------
// Subsystem 3: CORA-M 7-DoF Manipulator & Trolley
// -----------------------------------------------------------------------------
module cora_m_robot_arm() {
    // Docking Base Plate
    color(COL_FRAME) {
        cylinder(h=0.18, r=0.48, center=true);
        color(COL_ARM_BLUE)
            translate([0, 0, -0.09]) cylinder(h=0.04, r=0.30, center=true);
    }

    // Shoulder Turret
    translate([0, 0, 0.12]) {
        color("CadetBlue") cylinder(h=0.35, r=0.38, center=true);

        // Shoulder Pitch Joint & Upper Boom
        translate([0, 0, 0.22]) rotate([0, arm_pitch, 0]) {
            color(COL_ARM_WHITE) {
                cylinder(h=1.2, r1=0.16, r2=0.12, center=false);
                sphere(r=0.16);
                translate([0, 0, 1.2]) sphere(r=0.12);
            }

            // Elbow Joint & Dual Arm Split
            translate([0, 0, 1.2]) rotate([0, -35 + 40 * _t_dock, 0]) {
                color("CadetBlue") {
                    cylinder(h=0.25, r=0.12, center=false);
                    sphere(r=0.12);
                }

                // Dual Y-Branches
                for (branch = [-1, 1]) {
                    translate([0, 0, 0.25]) rotate([branch * 20, 0, 0]) {
                        color(COL_ARM_WHITE) {
                            cylinder(h=1.0, r1=0.12, r2=0.09, center=false);
                            translate([0, 0, 1.0]) sphere(r=0.09);
                        }
                        // Wrist Joint & Calipers
                        translate([0, 0, 1.0]) {
                            color("CadetBlue") cylinder(h=0.20, r=0.09, center=false);
                            translate([0, 0, 0.20]) {
                                color(COL_GOLD) {
                                    cylinder(h=0.10, r1=0.08, r2=0.04, center=false);
                                    // Symmetrically centered golden calipers
                                    translate([-(caliper_gap/2 + 2)*s, -3*s, 0.10])
                                        cube([2*s, 6*s, 14*s]);
                                    translate([(caliper_gap/2)*s, -3*s, 0.10])
                                        cube([2*s, 6*s, 14*s]);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

module ceiling_gantry_trolley(tx) {
    // Overhead carriage riding along top of ceiling gantry rail
    color(COL_FRAME) {
        translate([tx, 0, CEILING_Z - 0.22]) {
            cube([0.9, 0.85, 0.14], center=true);
            for (gy = [-0.38, 0.38]) {
                translate([0, gy, 0.08]) cube([0.8, 0.08, 0.18], center=true);
            }
            // Retractable hoist coupler
            translate([0, 0, -0.15])
                cylinder(h=0.18, r=0.26, center=true);
        }
    }
}

// -----------------------------------------------------------------------------
// Scene Assembly
// -----------------------------------------------------------------------------
module playground_scene_1() {
    amu_surface_vault_cutaway();
    strider_m_rover(rover_x);
    ceiling_gantry_trolley(rail_x);

    translate([arm_x, 0, arm_z])
        cora_m_robot_arm();
}

playground_scene_1();
