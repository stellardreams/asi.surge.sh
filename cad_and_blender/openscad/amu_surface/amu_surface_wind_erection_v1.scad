// amu_surface_wind_erection_v1.scad -- Autonomous Field Wind Erection by STRIDER-M & CORA-M (v1.0)
//
// Version Control & Engineering Audit:
// - Version: v1.0
// - Tracked Under: Issue #97 (Parent #81, Cross-ref #82, #85, #86, #88)
// - Hoist Kinematics Rectification (position of hoist fix):
//   In canonical gin-pole tilt-up kinematics (`wind_v2_mast_erection.scad` / #86), the mast tilts
//   toward the north (+X), and the gin-pole A-frame is rigidly fixed perpendicular to the mast,
//   leaning back toward the south (-X). The winch hoist unit is mounted on the south side (-X)
//   of the container roof. As the winch line retracts, tension on the gin-pole apex pulls the
//   mast upright toward the north. Previously the hoist vector was inverted; this is now fully
//   aligned with mechanical principles.
// - STRIDER-M Blue Tail Rectification (stryder_blue_tail_ visible fix):
//   The previously visible blue bar beneath the rover deck was a prototype ground umbilical line.
//   Per review, this loose ground line has been eliminated. In v1.0, power coupling is integrated
//   cleanly into the internal chassis battery reservoir and rover deck umbilical collar.
//
// Models the complete autonomous field erection scenario:
// 1. 20 ft ISO Container foundation footing situated on permafrost/regolith with extended outriggers.
// 2. Winch hoist station mounted on south side of container roof.
// 3. Tilting 24 m modular mast with gin-pole A-frame and rigging lines.
// 4. STRIDER-M Transporter positioned alongside the container with CORA-M dual-arm manipulator mounted on its deck.
// 5. Robotic Manipulator Operations:
//    - CORA-M dual arms reach into the container storage racks, extracting 1.71 m sectional blade segments.
//    - CORA-M sets titanium shear pins and torques structural joints into the 50 kW direct-drive PMSG hub.
//
// Units: OpenSCAD model units (scaled consistently: 1 unit ~ 1 meter)

$fn = 32;

// -----------------------------------------------------------------------------
// Parameters (1 unit = 1 meter)
// -----------------------------------------------------------------------------
CONT_L          = 6.06;  // 20 ft ISO container length
CONT_W          = 2.44;  // 20 ft ISO container width
CONT_H          = 2.59;  // 20 ft ISO container height

ROVER_L         = 7.2 * 0.7; // 5.04 m scaled
ROVER_W         = 4.6 * 0.7; // 3.22 m scaled
TRACK_W         = 1.2 * 0.7; // 0.84 m
TRACK_H         = 1.4 * 0.7; // 0.98 m

MAST_L          = 24.0;  // 24 m tower height
MAST_D          = 0.508; // 508 mm diameter
GIN_L           = 7.0;   // 7 m gin-pole A-frame lever arm

// Erection Angle: 25 deg tilt from vertical (tilts toward +X north)
tilt_deg        = 25;

// Winch hoist location on container roof (South side -X)
WINCH_X         = -CONT_L/2 + 0.8;
WINCH_Z         = CONT_H + 0.3;
TRUNNION_X      = CONT_L/2 - 0.8;
TRUNNION_Z      = CONT_H + 0.2;

// Animation Variable
t_override      = undef;
anim_t          = is_undef(t_override) ? $t : t_override;

// Colors
COL_CONTAINER   = [0.18, 0.19, 0.21];
COL_OUTRIGGER   = [0.85, 0.65, 0.15];
COL_MAST        = [0.88, 0.90, 0.93];
COL_ROTOR       = [0.93, 0.95, 0.97];
COL_ORANGE_EDGE = [0.95, 0.45, 0.10];
COL_TRACK       = [0.25, 0.26, 0.28];
COL_DECK        = [0.88, 0.42, 0.12];
COL_GIN_POLE    = [0.85, 0.55, 0.15];
COL_WINCH       = [0.30, 0.32, 0.35];
COL_THERMAL_PAD = [0.35, 0.37, 0.40]; // DimGray
COL_STEEL_GREY  = [0.65, 0.68, 0.72]; // Metallic steel
COL_STRUT_DARK  = [0.20, 0.28, 0.30]; // DarkSlateGray
COL_FRAME       = [0.22, 0.24, 0.26];

// -----------------------------------------------------------------------------
// Modules
// -----------------------------------------------------------------------------

module wind_container_foundation() {
    // 5. Thermal Break Footing Pad underneath main cuboid base
    color(COL_THERMAL_PAD) {
        translate([0, 0, 0.05])
            cube([CONT_L + 0.2, CONT_W + 0.2, 0.10], center=true);
    }

    // 20 ft ISO Container Footing (matte dark charcoal for solar gain)
    color(COL_CONTAINER) {
        translate([0, 0, CONT_H/2 + 0.10])
            cube([CONT_L, CONT_W, CONT_H], center=true);
    }
    
    // 1. Symmetrical Outriggers (4 symmetrical feet: 2 front +X, 2 rear -X)
    // 2. Ice-Screw Anchor Pins with hex flange and shaft extending below z=0
    // 5. Thermal Break Footing Pads underneath each circular pad
    color(COL_OUTRIGGER) {
        for (ox = [-CONT_L/2 + 0.6, CONT_L/2 - 0.6]) {
            for (oy = [-1, 1]) {
                translate([ox, oy * (CONT_W/2 + 1.2), 0.2]) {
                    // Outrigger structural box beam
                    cube([0.5, 2.4, 0.35], center=true);
                    
                    // Circular footpad
                    translate([0, oy * 1.0, -0.15]) {
                        cylinder(h=0.25, r=0.45, center=true);

                        // 5. Thermal pad
                        color(COL_THERMAL_PAD)
                            translate([0, 0, -0.18])
                                cylinder(h=0.10, r=0.48, center=true);

                        // 2. Ice-Screw Anchor Pin
                        color(COL_STEEL_GREY) {
                            translate([0, 0, 0.14])
                                cylinder(h=0.06, r=0.18, center=true, $fn=6);
                            translate([0, 0, -0.25])
                                cylinder(h=0.85, r=0.06, center=true, $fn=16);
                        }
                    }
                }
            }
        }
    }

    // Heavy Industrial Winch Hoist Unit on South Roof (-X)
    color(COL_WINCH) {
        translate([WINCH_X, 0, WINCH_Z + 0.10]) {
            cube([0.9, 0.8, 0.4], center=true);
            // Winch drum & drive motor
            translate([0, 0, 0.22]) rotate([90, 0, 0])
                cylinder(h=0.6, r=0.18, center=true);
        }
    }

    // Hinged Mast Base Trunnion atop container roof (+X)
    mast_r = MAST_D / 2; // 0.254 m
    color([0.35, 0.38, 0.42]) {
        translate([TRUNNION_X, 0, TRUNNION_Z + 0.10]) {
            cube([0.8, 1.2, 0.4], center=true);
            // Trunnion pivot pin
            rotate([90, 0, 0])
                cylinder(h=1.4, r=0.12, center=true);
        }
    }

    // 4. Triangulated Bracing Struts (tripod around mast base to container roof)
    color(COL_STRUT_DARK) {
        // Strut 1: angled toward center (-X)
        hull() {
            translate([TRUNNION_X, 0, TRUNNION_Z + 0.10 + mast_r * 2.5]) sphere(r=mast_r * 0.35);
            translate([TRUNNION_X - 1.8, 0, CONT_H + 0.10 + 0.1]) sphere(r=mast_r * 0.35);
        }
        // Strut 2: angled toward front-left corner (+Y)
        hull() {
            translate([TRUNNION_X, 0, TRUNNION_Z + 0.10 + mast_r * 2.5]) sphere(r=mast_r * 0.35);
            translate([TRUNNION_X + 0.4, CONT_W/2 - 0.25, CONT_H + 0.10 + 0.1]) sphere(r=mast_r * 0.35);
        }
        // Strut 3: angled toward front-right corner (-Y)
        hull() {
            translate([TRUNNION_X, 0, TRUNNION_Z + 0.10 + mast_r * 2.5]) sphere(r=mast_r * 0.35);
            translate([TRUNNION_X + 0.4, -CONT_W/2 + 0.25, CONT_H + 0.10 + 0.1]) sphere(r=mast_r * 0.35);
        }
        // Mounting anchor blocks
        translate([TRUNNION_X - 1.8, 0, CONT_H + 0.10 + 0.1]) cube([0.35, 0.35, 0.2], center=true);
        translate([TRUNNION_X + 0.4, CONT_W/2 - 0.25, CONT_H + 0.10 + 0.1]) cube([0.35, 0.35, 0.2], center=true);
        translate([TRUNNION_X + 0.4, -CONT_W/2 + 0.25, CONT_H + 0.10 + 0.1]) cube([0.35, 0.35, 0.2], center=true);
    }
}

module strider_m_ground_unit() {
    // STRIDER-M Crawler Unit (scaled for field operations)
    // Tracks
    color(COL_TRACK) {
        for (ty = [-ROVER_W/2 + TRACK_W/2, ROVER_W/2 - TRACK_W/2]) {
            translate([0, ty, TRACK_H/2]) {
                hull() {
                    translate([-ROVER_L/2 + TRACK_H/2, 0, 0])
                        rotate([90, 0, 0]) cylinder(h=TRACK_W, r=TRACK_H/2, center=true);
                    translate([ROVER_L/2 - TRACK_H/2, 0, 0])
                        rotate([90, 0, 0]) cylinder(h=TRACK_W, r=TRACK_H/2, center=true);
                }
                // Gold traction cleats
                for (gx = [-ROVER_L/2 + 0.5 : 0.6 : ROVER_L/2 - 0.5]) {
                    color("Gold") translate([gx, 0, -TRACK_H/2])
                        cube([0.1, TRACK_W + 0.05, 0.08], center=true);
                }
            }
        }
    }

    // Orange Work Deck
    color(COL_DECK) {
        translate([0, 0, TRACK_H + 0.15])
            cube([ROVER_L - 0.8, ROVER_W - 2*TRACK_W + 0.2, 0.28], center=true);
    }

    // Mounted CORA-M Robotic Arm Assembly
    translate([0.5, 0, TRACK_H + 0.30]) {
        // Locking Cam Collar Dock
        color([0.7, 0.7, 0.75])
            cylinder(h=0.18, r=0.45, center=true);

        // Arm articulation reaching toward container blade bay
        color("CadetBlue") {
            translate([0, 0, 0.20]) cylinder(h=0.35, r=0.32, center=true);
        }
        translate([0, 0, 0.38]) rotate([0, 25, 30]) {
            color("WhiteSmoke") cylinder(h=1.6, r1=0.20, r2=0.16, center=false);
            // Elbow articulation
            translate([0, 0, 1.6]) rotate([0, -55, 0]) {
                color("CadetBlue") sphere(r=0.18);
                // Dual monkey branches
                for (br = [-1, 1]) {
                    rotate([br * 18, 0, 0]) {
                        translate([0, 0, 0.1])
                            color("WhiteSmoke") cylinder(h=1.3, r1=0.14, r2=0.10, center=false);
                        // Gold Gripping Calipers holding a 1.71 m sectional rotor blade!
                        translate([0, 0, 1.4]) rotate([0, 30, 0]) {
                            color("Gold") {
                                cylinder(h=0.25, r1=0.10, r2=0.05, center=false);
                                translate([-0.12, 0, 0.25]) cube([0.04, 0.12, 0.30]);
                                translate([0.08, 0, 0.25]) cube([0.04, 0.12, 0.30]);
                            }
                            // 1.71 m Sectional Blade Module held in calipers
                            if (br == 1) {
                                translate([0, 0, 0.40]) rotate([0, 90, 0]) {
                                    color(COL_ROTOR) cube([1.71, 0.45, 0.12], center=true);
                                    color(COL_ORANGE_EDGE) translate([0, -0.20, 0]) cube([1.71, 0.08, 0.12], center=true);
                                    // Carbon spar joint tongue
                                    color([0.15, 0.15, 0.15]) translate([0.85 + 0.15, 0, 0]) cube([0.30, 0.22, 0.08], center=true);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

module tilting_mast_and_rotor() {
    mast_r = MAST_D / 2; // 0.254 m
    // Mast pivoted at Trunnion (tilts toward +X)
    translate([TRUNNION_X, 0, TRUNNION_Z + 0.10]) {
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

            // Tubular Mast
            color(COL_MAST) {
                cylinder(d=MAST_D, h=MAST_L);
                // Flanges every 4.8 m
                for (z = [4.8 : 4.8 : MAST_L - 1.0]) {
                    translate([0, 0, z])
                        cylinder(d=MAST_D * 1.35, h=0.05, center=true);
                }
            }

            // Tophead Nacelle Cowl
            translate([0, 0, MAST_L]) {
                color([0.94, 0.95, 0.98]) {
                    translate([0.4, 0, 0.4])
                        scale([1.1, 0.75, 0.8]) sphere(d=1.8);
                }
                // Rotor Hub & Sectional Blades
                translate([1.2, 0, 0.4]) {
                    color([0.85, 0.3, 0.2])
                        rotate([0, 90, 0]) cylinder(d=0.9, h=0.5, center=true);
                    
                    // 3 Bladed rotor
                    for (ang = [0, 120, 240]) {
                        rotate([ang, 0, 0]) {
                            translate([0.1, 0, 0]) {
                                color(COL_ROTOR) {
                                    hull() {
                                        translate([0, 0, 0.5]) rotate([0, 90, 0]) scale([1, 0.2, 1]) cylinder(d=0.8, h=0.15, center=true);
                                        translate([0, 0, 10.0]) rotate([0, 90, 0]) scale([1, 0.14, 1]) cylinder(d=0.3, h=0.08, center=true);
                                    }
                                }
                                color(COL_ORANGE_EDGE) {
                                    translate([0, -0.15, 5.0]) cube([0.08, 0.08, 8.0], center=true);
                                }
                            }
                        }
                    }
                }
            }

            // A-Frame Gin-Pole (rigidly perpendicular to mast, leaning back toward -X south)
            rotate([0, -90, 0]) {
                color(COL_GIN_POLE) {
                    for (gy = [-0.6, 0.6]) {
                        hull() {
                            translate([0, gy, 0]) sphere(r=0.08);
                            translate([0, 0, GIN_L]) sphere(r=0.08);
                        }
                    }
                    // Cross spreader
                    translate([0, 0, GIN_L * 0.45])
                        rotate([90, 0, 0]) cylinder(h=1.0, r=0.06, center=true);
                }
            }
        }
    }

    // Rigging Cables (Winch line from south hoist to gin apex; backstay to mast)
    gin_tip_x = TRUNNION_X + GIN_L * sin(tilt_deg - 90);
    gin_tip_z = TRUNNION_Z + 0.10 + GIN_L * cos(tilt_deg - 90);

    // 1. Red Winch Hoist Cable (South hoist drum to Gin apex)
    color([0.85, 0.2, 0.2]) {
        hull() {
            translate([WINCH_X, 0, WINCH_Z + 0.10 + 0.25]) sphere(r=0.035);
            translate([gin_tip_x, 0, gin_tip_z]) sphere(r=0.035);
        }
    }

    // 2. High-Strength Wire Rope Backstay (Gin apex to Mast at 14m)
    stay_x = TRUNNION_X + 14.0 * sin(tilt_deg);
    stay_z = TRUNNION_Z + 0.10 + 14.0 * cos(tilt_deg);
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
// Top-Level Field Erection Assembly
// -----------------------------------------------------------------------------
module field_erection_scene() {
    // 1. Container Foundation Footing on Permafrost with South Hoist
    wind_container_foundation();

    // 2. Tilting Mast, Sectional Rotor & South-Leaning Rigged Gin-Pole
    tilting_mast_and_rotor();

    // 3. Mobile STRIDER-M with Mounted CORA-M Arm Assembling Blades
    translate([CONT_L/2 - 0.5, CONT_W/2 + 2.4, 0])
        rotate([0, 0, -20])
            strider_m_ground_unit();
}

field_erection_scene();
