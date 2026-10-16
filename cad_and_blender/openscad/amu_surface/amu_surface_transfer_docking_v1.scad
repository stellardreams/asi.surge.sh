// amu_surface_transfer_docking_v1.scad -- Ceiling-to-Rover CORA-M Arm Transfer Simulation (v1.0)
//
// Version Control & Engineering Audit:
// - Version: v1.0
// - Tracked Under: Issue #97 (Parent #81, Cross-ref #82, #88)
// - Architectural Dependency & Maintenance Rule:
//   Source geometry is defined in `amu_surface_habitat_v1.scad` (vault shelter, apex ceiling rail at Z=5.15 m)
//   and `strider_m_transporter_v1.scad` (chassis height, latch collar dock at X=0.8 m, Z=1.55 m).
//   Whenever `amu_surface_habitat_v1.scad` or `strider_m_transporter_v1.scad` is revised, this file
//   must be updated in lockstep to maintain kinematic mating alignment and phase continuity.
// - Design Rectification (golden_calipers_off fix):
//   Replaced legacy offset caliper cubes with canonical symmetric end-effector calipers matching
//   `amu_CORA-M-arm-opencode_v1.scad`. The caliper jaws now symmetrically sandwich the wrist center axis
//   with dynamic clamping gap `_APAS_caliper_gap` scaled precisely with arm dimension parameter `s`.
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

$fn = 32;

use <amu_surface_habitat_v1.scad>
use <strider_m_transporter_v1.scad>

// -----------------------------------------------------------------------------
// Parameters & Kinematic Phases
// -----------------------------------------------------------------------------
t_override = undef;
anim_t = is_undef(t_override) ? $t : t_override;

s = 0.010; // Scaled so arm length (120*s = 1.2 m) fits rover deck perfectly

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
// Canonical caliper gap: starts open (14*s), clamps down during dock (3*s)
_APAS_caliper_gap = (14 - 11 * _t_dock);

// Helper for arm segments
module arm_seg(len, r1, r2, col) {
    color(col) {
        cylinder(h=len, r1=r1, r2=r2, center=false, $fn=24);
        sphere(r=r1, $fn=16);
        translate([0, 0, len]) sphere(r=r2, $fn=16);
    }
}

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
            arm_seg(120*s, 16*s, 12*s, "WhiteSmoke");
            
            // Elbow Joint & Dual Arm Split
            translate([0, 0, 120*s]) rotate([0, -25 + 30 * _t_dock, 0]) {
                arm_seg(25*s, 12*s, 12*s, "CadetBlue");
                
                // Y-shaped dual branches (Monkey Y)
                for (branch = [-1, 1]) {
                    translate([0, 0, 25*s]) rotate([branch * 22, 0, 0]) {
                        arm_seg(100*s, 12*s, 10*s, "WhiteSmoke");
                        
                        // Wrist articulation
                        translate([0, 0, 100*s]) {
                            arm_seg(20*s, 10*s, 10*s, "CadetBlue");
                            translate([0, 0, 20*s]) {
                                arm_seg(15*s, 10*s, 8*s, "LightGray");
                                
                                // Canonical Gold End-Effector Calipers
                                translate([0, 0, 15*s]) {
                                    color("Gold") {
                                        // Caliper tool hub
                                        cylinder(h=10*s, r1=8*s, r2=4*s, center=false, $fn=24);
                                        // Symmetrically centered caliper grasping jaws
                                        translate([-(_APAS_caliper_gap/2 + 2)*s, -3*s, 10*s])
                                            cube([2*s, 6*s, 12*s]);
                                        translate([(_APAS_caliper_gap/2)*s, -3*s, 10*s])
                                            cube([2*s, 6*s, 12*s]);
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
    // Overhead carriage riding along top of ceiling gantry rail
    color([0.33, 0.35, 0.40]) {
        translate([rail_pos_x, 0, 5.38]) {
            // Carriage saddle riding above rail
            cube([0.9, 0.85, 0.18], center=true);
            // Side guide rollers gripping rail flanges
            for (gy = [-0.38, 0.38]) {
                translate([0, gy, -0.15]) cube([0.8, 0.10, 0.22], center=true);
            }
            // Under-slung swivel turret coupling
            translate([0, 0, -0.32])
                cylinder(h=0.18, r=0.28, center=true);
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
