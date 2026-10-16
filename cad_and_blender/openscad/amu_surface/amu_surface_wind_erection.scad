// amu_surface_wind_erection.scad -- Autonomous Field Wind Erection by STRIDER-M & CORA-M
//
// Models the complete autonomous field erection scenario:
// 1. 20 ft ISO Container foundation footing situated on permafrost/regolith with extended outriggers.
// 2. STRIDER-M Transporter positioned alongside the container with CORA-M dual-arm manipulator mounted on its deck.
// 3. Robotic Manipulator Operations:
//    - CORA-M dual arms reach into the container storage racks, extracting 1.71 m sectional blade segments.
//    - CORA-M sets titanium shear pins and torques structural joints into the 50 kW direct-drive PMSG hub.
//    - Conductive umbilical power link connects STRIDER-M to the container's microgrid AFE power bus.
// 4. Gin-Pole A-Frame and winch line rigged for autonomous tilt-up mast erection.
//
// Units: OpenSCAD model units (scaled consistently: 1 unit ~ 1 meter)
// Tracked under Issue #97 (Parent #81, Cross-ref #82, #85, #86, #88)

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

// Erection Angle (0 = horizontal assembly, 35 = lifting, 90 = upright)
tilt_deg        = 25;

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
COL_ARM_BLUE    = [0.15, 0.45, 0.85];

// -----------------------------------------------------------------------------
// Modules
// -----------------------------------------------------------------------------

module wind_container_foundation() {
    // 20 ft ISO Container Footing (matte dark charcoal for solar gain)
    color(COL_CONTAINER) {
        translate([0, 0, CONT_H/2])
            cube([CONT_L, CONT_W, CONT_H], center=true);
    }
    
    // 4x Extended heavy foundation outriggers with helical permafrost screw pads
    color(COL_OUTRIGGER) {
        for (ox = [-CONT_L/2 + 0.6, CONT_L/2 - 0.6]) {
            for (oy = [-1, 1]) {
                translate([ox, oy * (CONT_W/2 + 1.2), 0.2]) {
                    // Outrigger structural box beam
                    cube([0.5, 2.4, 0.35], center=true);
                    // Ground anchor screw bearing pad
                    translate([0, oy * 1.0, -0.15])
                        cylinder(h=0.25, r=0.45, center=true);
                }
            }
        }
    }

    // Hinged Mast Base Trunnion atop container roof
    color([0.35, 0.38, 0.42]) {
        translate([CONT_L/2 - 0.8, 0, CONT_H + 0.2]) {
            cube([0.8, 1.2, 0.4], center=true);
            // Trunnion pivot pin
            rotate([90, 0, 0])
                cylinder(h=1.4, r=0.12, center=true);
        }
    }

    // A-Frame Gin-Pole for tilt-up winching
    color([0.85, 0.35, 0.15]) {
        translate([CONT_L/2 - 0.8, 0, CONT_H + 0.2]) {
            rotate([0, -(tilt_deg + 45), 0]) {
                for (gy = [-0.5, 0.5]) {
                    hull() {
                        translate([0, gy, 0]) sphere(r=0.08);
                        translate([7.0, 0, 0]) sphere(r=0.08);
                    }
                }
            }
        }
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

    // Heavy-duty flexible conductive umbilical line to container microgrid bay
    color(COL_ARM_BLUE) {
        hull() {
            translate([-ROVER_L/2 + 0.2, 0, TRACK_H + 0.1]) sphere(r=0.08);
            translate([-ROVER_L/2 - 1.2, 1.5, 0.1]) sphere(r=0.08);
        }
    }
}

module tilting_mast_and_rotor() {
    // Mast pivoted at Trunnion (CONT_L/2 - 0.8, 0, CONT_H + 0.2)
    translate([CONT_L/2 - 0.8, 0, CONT_H + 0.2]) {
        rotate([0, -tilt_deg, 0]) {
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
        }
    }
}

// -----------------------------------------------------------------------------
// Top-Level Field Erection Assembly
// -----------------------------------------------------------------------------
module field_erection_scene() {
    // 1. Container Foundation Footing on Permafrost
    wind_container_foundation();

    // 2. Tilting Mast & Sectional Rotor
    tilting_mast_and_rotor();

    // 3. Mobile STRIDER-M with Mounted CORA-M Arm Assembling Blades
    translate([CONT_L/2 - 0.5, CONT_W/2 + 2.4, 0])
        rotate([0, 0, -20])
            strider_m_ground_unit();
}

field_erection_scene();
