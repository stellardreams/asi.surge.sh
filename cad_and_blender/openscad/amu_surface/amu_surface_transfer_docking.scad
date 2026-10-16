// amu_surface_transfer_docking.scad -- Ceiling-to-Rover CORA-M Arm Transfer Simulation
//
// Models the autonomous sequence where the CORA-M 7-DoF robotic manipulator hops
// from the AMU-Surface ceiling gantry rail down to the STRIDER-M transporter deck:
//
// Transfer Mechanics:
// 1. STRIDER-M rover reverses into the AMU-Surface airlock staging pad directly under ceiling gantry.
// 2. CORA-M overhead carriage rolls along the ceiling I-beam rail to the transfer lock position.
// 3. Lower mechanical locking collar on rover deck mates with the CORA-M arm base.
// 4. Conductive umbilical contacts engage; primary power switches to STRIDER-M power reservoir.
// 5. Overhead ceiling gantry carriage releases latch; CORA-M arm is now mobile on STRIDER-M!
//
// Dynamic Animation Variable:
// $t in [0.0, 1.0]:
//   0.00 -> 0.30: CORA-M on ceiling rail traverses toward rover staging bay
//   0.30 -> 0.50: Arm base lowers / mates with STRIDER-M deck locking collar
//   0.50 -> 0.65: Docking locks engage, conductive umbilical plugs in, ceiling clamp disengages
//   0.65 -> 1.00: STRIDER-M rolls out through the portal carrying the mounted CORA-M arm
//
// Units: OpenSCAD model units
// Tracked under Issue #97 (Parent #81, Cross-ref #82, #88)

$fn = 32;

use <amu_surface_habitat.scad>
use <strider_m_transporter.scad>

// -----------------------------------------------------------------------------
// Parameters & Kinematic Phases
// -----------------------------------------------------------------------------
t_override = undef;
anim_t = is_undef(t_override) ? $t : t_override;

s = 0.014 * 6.5; // Scale factor for CORA-M arm to match surface vehicle proportions

// Kinematic timeline anim_t:
// Phase 1: Ceiling rail traverse (X: -2.0 -> 4.5)
_t_traverse = (anim_t < 0.30) ? (1 - cos(180 * anim_t / 0.30)) / 2 : 1.0;
// Phase 2: Vertical docking engagement (Z: 4.8 -> 1.85)
_t_dock = (anim_t < 0.30) ? 0.0 :
          (anim_t < 0.50) ? (1 - cos(180 * (anim_t - 0.30) / 0.20)) / 2 : 1.0;
// Phase 3: Rover roll-out through portal (X: 3.8 -> 11.5)
_t_rollout = (anim_t < 0.65) ? 0.0 :
             (1 - cos(180 * (anim_t - 0.65) / 0.35)) / 2;

// Positions
rail_pos_x  = -2.0 + 6.6 * _t_traverse; // traverses to X = 4.6
rover_pos_x = 3.80 + 7.50 * _t_rollout; // at rest X = 3.80, so collar at X = 3.80 + 0.8 = 4.60!
arm_base_z  = 4.80 - 3.25 * _t_dock;   // Lowers from ceiling rail (4.80) to rover dock collar (1.55)

// Joint articulation during transfer
j_pitch     = -15 + 25 * _t_dock;
caliper_gap = (_t_dock > 0.5) ? 6 * s : 14 * s;

// -----------------------------------------------------------------------------
// Sub-Modules
// -----------------------------------------------------------------------------

module cora_m_arm_assembly() {
    // 7-DoF Dual-Arm Manipulator with Standardized Docking Base
    // Standardized Cam-Lock Mounting Base
    color([0.22, 0.24, 0.28]) {
        cylinder(h=0.18, r=0.48, center=true);
        // Conductive circular umbilical mating plate
        color([0.15, 0.45, 0.85])
            translate([0, 0, -0.09]) cylinder(h=0.03, r=0.30, center=true);
    }

    // Shoulder Turret (Yaw rotation)
    translate([0, 0, 0.12]) {
        color("CadetBlue") cylinder(h=0.35, r=0.38, center=true);
        
        // Shoulder Pitch Joint
        translate([0, 0, 0.22]) rotate([0, j_pitch, 0]) {
            color("WhiteSmoke") {
                cylinder(h=1.2, r1=0.22, r2=0.18, center=false);
                sphere(r=0.22);
                translate([0, 0, 1.2]) sphere(r=0.18);
            }
            
            // Elbow Joint & Dual Arm Split
            translate([0, 0, 1.2]) rotate([0, -25 + 30 * _t_dock, 0]) {
                color("CadetBlue") cylinder(h=0.30, r=0.18, center=true);
                
                // Y-shaped dual branches
                for (branch = [-1, 1]) {
                    rotate([branch * 22, 0, 0]) {
                        translate([0, 0, 0.15]) {
                            color("WhiteSmoke") cylinder(h=1.0, r1=0.16, r2=0.12, center=false);
                            // Wrist & Gold Calipers
                            translate([0, 0, 1.0]) {
                                color("CadetBlue") sphere(r=0.14);
                                translate([0, 0, 0.12]) rotate([0, 20, 0]) {
                                    color("Gold") {
                                        cylinder(h=0.20, r1=0.12, r2=0.06, center=false);
                                        // End-effector grasping calipers
                                        translate([-(caliper_gap/2 + 0.05), 0, 0.20])
                                            cube([0.04, 0.10, 0.22]);
                                        translate([(caliper_gap/2), 0, 0.20])
                                            cube([0.04, 0.10, 0.22]);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

module overhead_transfer_trolley() {
    // Overhead carriage on ceiling gantry rail
    color([0.33, 0.35, 0.40]) {
        translate([rail_pos_x, 0, 5.15]) {
            cube([0.9, 0.8, 0.25], center=true);
            // Telescoping hoist / docking release clamp
            translate([0, 0, -0.20])
                cylinder(h=0.25, r=0.28, center=true);
        }
    }
}

// -----------------------------------------------------------------------------
// Top-Level Transfer Assembly
// -----------------------------------------------------------------------------
module transfer_simulation_scene() {
    // 1. AMU-Surface Habitat Shelter (Cutaway interior mode)
    amu_surface_habitat_full();

    // 2. STRIDER-M Transporter on Staging Pad
    translate([rover_pos_x, 0, 0])
        strider_m_full();

    // 3. Overhead Ceiling Gantry Trolley
    overhead_transfer_trolley();

    // 4. CORA-M Arm Assembly (Transitioning between ceiling trolley and rover deck)
    // If before rollout complete, arm follows transfer kinematics; once locked on rover, rides rover
    arm_x = (_t_dock >= 1.0) ? (rover_pos_x + 0.8) : rail_pos_x;
    translate([arm_x, 0, arm_base_z])
        cora_m_arm_assembly();
}

transfer_simulation_scene();
