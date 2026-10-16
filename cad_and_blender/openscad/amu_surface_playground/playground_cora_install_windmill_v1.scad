// playground_cora_install_windmill_v1.scad -- AMU-Surface Playground Scene 2: CORA-M Installing Windmill (v1.0)
//
// Version Control & Engineering Audit:
// - Version: v1.0
// - Tracked Under: Issue #97 (Parent #81, Cross-ref #82, #85, #86, #88)
// - Operational Role: Demonstrates the field erection kinematics of the 50 kW containerized
//   Arctic wind turbine. Mounted on the STRIDER-M transporter deck, the 7-DoF CORA-M dual-arm
//   manipulator extracts sectional composite blades from the 20 ft ISO container foundation,
//   aligns root bolt circles, fastens shear pins to the direct-drive PMSG hub, and monitors
//   gin-pole A-frame winch line rigging during mast tilt-up.
//
// Animation Timeline ($t in [0.0, 1.0]):
//   0.00 -> 0.35: CORA-M reaches into container storage bay, dual calipers grip sectional blade
//   0.35 -> 0.70: Arm lifts and sweeps blade up to direct-drive PMSG hub, aligning root pins
//   0.70 -> 1.00: Root pins engage hub; mast tilts upright via gin-pole and south container winch
//
// Units: OpenSCAD model units (1 unit ~ 1 meter)

$fn = 32;

// -----------------------------------------------------------------------------
// Parameters & Geometry
// -----------------------------------------------------------------------------
CONT_L          = 6.06;  // 20 ft ISO container length
CONT_W          = 2.44;  // 20 ft ISO container width
CONT_H          = 2.59;  // 20 ft ISO container height

MAST_L          = 24.0;  // 24 m tower height
GIN_L           = 7.0;   // 7 m gin-pole A-frame

// Animation variable
t_override      = undef;
anim_t          = is_undef(t_override) ? $t : t_override;

function ease(v) = (1 - cos(180 * v)) / 2;

_t_reach = (anim_t < 0.35) ? ease(anim_t / 0.35) : 1.0;
_t_lift  = (anim_t < 0.35) ? 0.0 :
           (anim_t < 0.70) ? ease((anim_t - 0.35) / 0.35) : 1.0;
_t_tilt  = (anim_t < 0.70) ? 0.0 :
           ease((anim_t - 0.70) / 0.30);

// Dynamic mast tilt (tilts from 20 deg to 45 deg upright during blade assembly)
tilt_deg = 20 + 25 * _t_tilt;

// Arm articulation angles
arm_yaw   = -30 + 55 * _t_lift;
arm_pitch = -10 + 45 * _t_reach - 20 * _t_lift;
elbow_ang = 40 - 25 * _t_lift;

// Blade position (gripped and carried by arm)
blade_x = -1.2 + 2.2 * _t_lift;
blade_z = 1.4 + 1.8 * _t_lift;

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
COL_WINCH       = [0.30, 0.32, 0.35];
COL_FRAME       = [0.22, 0.24, 0.26];
COL_THERMAL_PAD = [0.35, 0.37, 0.40]; // DimGray
COL_STEEL_GREY  = [0.65, 0.68, 0.72]; // Metallic steel
COL_STRUT_DARK  = [0.20, 0.28, 0.30]; // DarkSlateGray
COL_PERMAFROST  = [0.75, 0.78, 0.82];

// -----------------------------------------------------------------------------
// Subsystem 1: Containerized Foundation & Mast Assembly
// -----------------------------------------------------------------------------
module wind_turbine_foundation_and_mast() {
    // Terrain base
    color(COL_PERMAFROST) {
        translate([4, 0, -0.2])
            cube([28, 22, 0.4], center=true);
    }

    // 5. Thermal Break Footing Pad underneath main cuboid base
    color(COL_THERMAL_PAD) {
        translate([0, 0, 0.05])
            cube([CONT_L + 0.2, CONT_W + 0.2, 0.10], center=true);
    }

    // 20 ft ISO Container Foundation
    color(COL_CONTAINER) {
        translate([0, 0, CONT_H/2 + 0.10])
            cube([CONT_L, CONT_W, CONT_H], center=true);
    }

    // 1. Symmetrical Outriggers (4 symmetrical feet: 2 front +X, 2 rear -X)
    // 2. Ice-Screw Anchor Pins with top hex flange and shaft extending below z=0
    // 5. Thermal Break Footing Pads underneath each of the 4 circular pads
    color(COL_OUTRIGGER) {
        for (ox = [-CONT_L/2 + 0.6, CONT_L/2 - 0.6]) {
            for (oy = [-1, 1]) {
                translate([ox, oy * (CONT_W/2 + 1.2), 0.2]) {
                    // Outrigger structural box beam
                    cube([0.5, 2.4, 0.35], center=true);
                    
                    // Circular footpad
                    translate([0, oy * 1.0, -0.15]) {
                        cylinder(h=0.25, r=0.45, center=true);

                        // 5. Thermal insulation pad underneath circular footpad
                        color(COL_THERMAL_PAD)
                            translate([0, 0, -0.18])
                                cylinder(h=0.10, r=0.48, center=true);

                        // 2. Ice-Screw Anchor Pin: vertical metallic grey cylinder with hex flange
                        color(COL_STEEL_GREY) {
                            // Top hexagonal flange resting flush on upper face
                            translate([0, 0, 0.14])
                                cylinder(h=0.06, r=0.18, center=true, $fn=6);
                            // Driven ice anchor shaft extending below z = 0
                            translate([0, 0, -0.25])
                                cylinder(h=0.85, r=0.06, center=true, $fn=16);
                        }
                    }
                }
            }
        }
    }

    // South Roof Winch Hoist
    color(COL_WINCH) {
        translate([-CONT_L/2 + 0.8, 0, CONT_H + 0.10 + 0.3]) {
            cube([0.9, 0.8, 0.4], center=true);
            translate([0, 0, 0.22]) rotate([90, 0, 0])
                cylinder(h=0.6, r=0.18, center=true);
        }
    }

    // Tilting Mast & Gin-Pole
    mast_r      = 0.26;
    trunnion_x  = CONT_L/2 - 0.8;
    trunnion_z  = CONT_H + 0.10 + 0.2;

    // 4. Triangulated Bracing Struts (mounting blocks on top deck to trunnion base)
    color(COL_STRUT_DARK) {
        // Strut 1: angled toward center (-X)
        hull() {
            translate([trunnion_x, 0, trunnion_z + mast_r * 2.5]) sphere(r=mast_r * 0.35);
            translate([trunnion_x - 1.8, 0, CONT_H + 0.10 + 0.1]) sphere(r=mast_r * 0.35);
        }
        // Strut 2: angled toward front-left corner (+Y)
        hull() {
            translate([trunnion_x, 0, trunnion_z + mast_r * 2.5]) sphere(r=mast_r * 0.35);
            translate([trunnion_x + 0.4, CONT_W/2 - 0.25, CONT_H + 0.10 + 0.1]) sphere(r=mast_r * 0.35);
        }
        // Strut 3: angled toward front-right corner (-Y)
        hull() {
            translate([trunnion_x, 0, trunnion_z + mast_r * 2.5]) sphere(r=mast_r * 0.35);
            translate([trunnion_x + 0.4, -CONT_W/2 + 0.25, CONT_H + 0.10 + 0.1]) sphere(r=mast_r * 0.35);
        }
        // Mounting anchor blocks on top deck
        translate([trunnion_x - 1.8, 0, CONT_H + 0.10 + 0.1]) cube([0.35, 0.35, 0.2], center=true);
        translate([trunnion_x + 0.4, CONT_W/2 - 0.25, CONT_H + 0.10 + 0.1]) cube([0.35, 0.35, 0.2], center=true);
        translate([trunnion_x + 0.4, -CONT_W/2 + 0.25, CONT_H + 0.10 + 0.1]) cube([0.35, 0.35, 0.2], center=true);
    }

    translate([trunnion_x, 0, trunnion_z]) {
        rotate([0, tilt_deg, 0]) {
            // 3. Reinforced Mast Trunnion Collar (r = mast_r * 1.45, h = mast_r * 3.5)
            color(COL_FRAME) {
                cylinder(h=mast_r * 3.5, r=mast_r * 1.45, center=false, $fn=32);
                // Vertical rectangular clevis plates
                for (side = [-1, 1]) {
                    translate([0, side * (mast_r * 1.45 + 0.05), (mast_r * 3.5)/2])
                        cube([mast_r * 2.2, 0.08, mast_r * 3.2], center=true);
                }
            }
            // Mechanical lock pin engaged by CORA arm (color Red/Orange)
            color("Red") {
                translate([0, 0, (mast_r * 3.5)/2])
                    rotate([90, 0, 0])
                        cylinder(h=mast_r * 3.8, r=0.06, center=true);
            }

            // 24m Tubular Mast
            color(COL_MAST) {
                cylinder(h=MAST_L, r=mast_r, center=false, $fn=24);
                for (fl = [4.8, 9.6, 14.4, 19.2]) {
                    translate([0, 0, fl]) cylinder(h=0.12, r=0.32, center=true);
                }
            }

            // Direct-Drive PMSG Nacelle & Rotor Hub at Mast Top
            translate([0, 0, MAST_L]) {
                color(COL_CONTAINER) {
                    rotate([0, 90, 0]) cylinder(h=1.8, r=0.55, center=true);
                }
                // Central rotor nose cone
                color(COL_ROTOR) {
                    translate([1.0, 0, 0]) rotate([0, 90, 0])
                        cylinder(h=0.65, r1=0.48, r2=0.15, center=false);
                }
                // Pre-assembled blade 1 (vertical upward)
                rotate([0, 0, 0]) {
                    translate([0.9, 0, 0]) rotate([0, -90, 0]) {
                        color(COL_ROTOR) cylinder(h=6.5, r1=0.22, r2=0.08, center=false);
                        color(COL_ORANGE_EDGE)
                            translate([0, 0.08, 3.25]) cube([0.04, 0.08, 6.5], center=true);
                    }
                }
                // Pre-assembled blade 2 (angled downward)
                rotate([120, 0, 0]) {
                    translate([0.9, 0, 0]) rotate([0, -90, 0]) {
                        color(COL_ROTOR) cylinder(h=6.5, r1=0.22, r2=0.08, center=false);
                        color(COL_ORANGE_EDGE)
                            translate([0, 0.08, 3.25]) cube([0.04, 0.08, 6.5], center=true);
                    }
                }
            }

            // Rigid A-Frame Gin-Pole (Fixed perpendicular to mast)
            color(COL_OUTRIGGER) {
                rotate([0, -90, 0]) {
                    for (side = [-0.6, 0.6]) {
                        translate([0, side, 0])
                            cylinder(h=GIN_L, r1=0.10, r2=0.06, center=false);
                    }
                    translate([0, 0, GIN_L])
                        rotate([90, 0, 0]) cylinder(h=1.2, r=0.08, center=true);
                }
            }
        }
    }

    // Active Hoist Rigging Cables
    gin_tip_x = trunnion_x + GIN_L * sin(tilt_deg - 90);
    gin_tip_z = trunnion_z + GIN_L * cos(tilt_deg - 90);
    winch_x   = -CONT_L/2 + 0.8;
    winch_z   = CONT_H + 0.55;

    // Red Motorized Winch Cable
    color([0.85, 0.2, 0.2]) {
        hull() {
            translate([winch_x, 0, winch_z]) sphere(r=0.035);
            translate([gin_tip_x, 0, gin_tip_z]) sphere(r=0.035);
        }
    }

    // Dark High-Strength Backstays (Gin apex to Mast at 14m)
    stay_x = trunnion_x + 14.0 * sin(tilt_deg);
    stay_z = trunnion_z + 14.0 * cos(tilt_deg);
    color([0.15, 0.15, 0.15]) {
        for (dy = [-0.3, 0.3]) {
            hull() {
                translate([gin_tip_x, dy, gin_tip_z]) sphere(r=0.025);
                translate([stay_x, dy, stay_z]) sphere(r=0.025);
            }
        }
    }
}

// -----------------------------------------------------------------------------
// Subsystem 2: STRIDER-M with Mounted CORA-M Arm
// -----------------------------------------------------------------------------
module strider_m_erection_crew() {
    translate([1.8, 3.6, 0]) {
        // Rover chassis
        color(COL_ROVER) {
            translate([0, 0, 0.75])
                cube([4.6, 1.6, 0.8], center=true);
            translate([0, 0, 1.2])
                cube([4.4, 1.9, 0.12], center=true);
        }

        // Tracks
        color(COL_TRACK) {
            for (ty = [-1.4, 1.4]) {
                translate([0, ty, 0.55])
                    cube([4.8, 0.8, 1.1], center=true);
            }
        }

        // CORA-M Arm Base
        translate([0.5, 0, 1.3]) {
            color(COL_FRAME) cylinder(h=0.18, r=0.48, center=true);

            // Shoulder Turret with Yaw
            rotate([0, 0, arm_yaw]) {
                color("CadetBlue") cylinder(h=0.35, r=0.38, center=true);

                // Shoulder Pitch Joint
                translate([0, 0, 0.22]) rotate([0, arm_pitch, 0]) {
                    color(COL_ARM_WHITE) {
                        cylinder(h=1.5, r1=0.18, r2=0.13, center=false);
                        sphere(r=0.18);
                        translate([0, 0, 1.5]) sphere(r=0.13);
                    }

                    // Elbow Joint & Dual Arm Articulation
                    translate([0, 0, 1.5]) rotate([0, elbow_ang, 0]) {
                        color("CadetBlue") {
                            cylinder(h=0.3, r=0.13, center=false);
                            sphere(r=0.13);
                        }

                        for (branch = [-1, 1]) {
                            translate([0, 0, 0.3]) rotate([branch * 22, 0, 0]) {
                                color(COL_ARM_WHITE) {
                                    cylinder(h=1.2, r1=0.13, r2=0.09, center=false);
                                    translate([0, 0, 1.2]) sphere(r=0.09);
                                }
                                // Wrist & Golden Calipers
                                translate([0, 0, 1.2]) {
                                    color("CadetBlue") cylinder(h=0.22, r=0.09, center=false);
                                    translate([0, 0, 0.22]) {
                                        color(COL_GOLD) {
                                            cylinder(h=0.12, r1=0.08, r2=0.04, center=false);
                                            translate([-0.06, -0.03, 0.12]) cube([0.03, 0.06, 0.16]);
                                            translate([0.03, -0.03, 0.12]) cube([0.03, 0.06, 0.16]);
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
}

// -----------------------------------------------------------------------------
// Subsystem 3: Sectional Composite Blade Segment Being Installed
// -----------------------------------------------------------------------------
module blade_segment_under_installation() {
    translate([blade_x, 2.5, blade_z]) {
        rotate([15, -25 + 30 * _t_lift, 45]) {
            color(COL_ROTOR) {
                // 1.71m modular blade segment
                cylinder(h=1.71, r1=0.24, r2=0.18, center=true);
            }
            color(COL_ORANGE_EDGE) {
                translate([0, 0.10, 0]) cube([0.04, 0.08, 1.71], center=true);
            }
            // Titanium shear pin root flange
            color(COL_GOLD) {
                translate([0, 0, -0.88]) {
                    cylinder(h=0.08, r=0.26, center=true);
                    for (rot = [0 : 60 : 300]) rotate([0, 0, rot])
                        translate([0.20, 0, -0.06]) cylinder(h=0.12, r=0.02, center=true);
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------
// Top-Level Scene Assembly
// -----------------------------------------------------------------------------
module playground_scene_2() {
    wind_turbine_foundation_and_mast();
    strider_m_erection_crew();
    blade_segment_under_installation();
}

playground_scene_2();
