// amu_mobile_surface_solo_v2_1.scad -- Surface AMU Mobile Unit (Solo Architecture v2.1 - Heavy Aerial Rigging & Modular Pod Interface)
//
// Version Control & Engineering Audit:
// - Version: v2.1
// - Tracked Under: Issue #97 (Parent #81, Cross-ref #82, #88)
// - Heavy Aerial Transport & Rigging Specifications:
//   1. Tandem Heavy-Lift Cargo Sling Harness & Spreader Beams:
//      - Dual-point forward and aft tandem hoist bridle shackles integrated into the dorsal spine truss.
//      - Rated for multi-point external cargo sling suspension and dynamic aerodynamic stabilization in flight.
//   2. Modular Transport Pod ISO Pad-Eyes & Corner Hardpoints:
//      - Quad heavy-duty forged corner lift lugs along the chassis perimeter deck (Y = ±4.8m, X = ±7.8m).
//      - Standardized external aerial recovery hooks and tag-line winching eyes for rapid ground release.
//   3. Retained Subsystems from v2.0:
//      - A36 Structural steel exoskeleton truss cage and diagrid torsional cross-braces.
//      - Arctic Air Handling Unit (AHU), intake elbow duct, and multi-stage filtration.
//      - Heavy industrial vault end portals with radial dog-lock bars and hydraulic pistons.
//      - Redundant dorsal sensor network and continuous crawler track bogies.
// - Subsystems & Features from High-Fidelity Arctic Schematic:
//   1. External Exo-Skeleton Truss Cage:
//      - A36 Structural steel tubular reinforcement ribs and diagrid cross-bracing framing the arched cylinder.
//      - Diagrid "X" Struts Dual Rationale: (a) Optical anti-whiteout fiducials for approaching aerial/ground vehicles;
//        (b) Structural triangulation resisting torsional/shear racking under crawler terrain differentials.
//      - Longitudinal dorsal spine truss and lateral load-distribution stringers.
//   2. Arctic Air Handling Unit (AHU) & HVAC Filtration Pack:
//      - Reconfigured Arctic Air Handling Unit mounted laterally with modular radiator grille.
//      - Industrial intake/exhaust fans and high-capacity centrifugal blowers.
//      - Upstream Arctic filter housings and large-bore insulated flexible intake elbow ducting.
//      - Side exhaust manifold and maintenance access doors.
//   3. Heavy Vault-Style Hermetic End Portal:
//      - Integrated heavy airtight perimeter sealing frame.
//      - Radial locking dog bars and central mechanical lock wheel hub.
//      - Dual high-pressure hydraulic/pneumatic actuating cylinders & pistons.
//      - Industrial reinforced door hinges with heavy bearing blocks.
//   4. Redundant Sensor Pods & Avionics:
//      - Dual redundant sensor pods along dorsal spine truss (cameras, multi-point thermal probes, LiDAR).
//      - Perimeter portal sensor pods for ingress/egress automated alignment.
//   5. Heavy Continuous Crawler Chassis & Multi-Stage Intake:
//      - Reinforced base chassis with truncated hull (Z = -4.2 m) and 16.4m x 1.8m continuous tracks.
//      - Multi-stage low-level intake system with replaceable filter elements.
//
// Units: OpenSCAD model units (Scale: MMS_RADIUS = 6.0, MMS_LENGTH = 17.92)

$fn = 40;

function sgn(v) = v >= 0 ? 1 : -1;

// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------
MMS_RADIUS          = 6.0;
MMS_LENGTH          = 17.92;
FLAT_Z_CUT          = -4.2;  // Level where cylindrical hull is truncated flat
BASE_DECK_W         = 9.6;   // Width of flat structural belly plate
BASE_DECK_H         = 0.55;  // Thickness of reinforced base chassis

// Track Sizing (Heavy-duty "snowshoes" scaled for 18m AMU)
TRACK_L             = 16.4;  // Length of continuous track
TRACK_W             = 1.8;   // Width of track
TRACK_H             = 2.2;   // Height of track bogie
TRACK_Y_OFFSET      = 4.6;   // Lateral offset from hull centerline (Y = ±4.6)
GROUSER_COUNT       = 32;

// Colors
HULL_WHITE          = [0.92, 0.93, 0.94];
HULL_TRIM_GREY      = [0.70, 0.72, 0.75];
COL_EXO_STEEL       = [0.15, 0.16, 0.18]; // A36 Dark Structural Steel
COL_CHASSIS_STEEL   = [0.22, 0.24, 0.27];
COL_TRACK_RUBBER    = [0.18, 0.19, 0.21];
COL_GROUSER_GOLD    = [0.85, 0.68, 0.25];
COL_WHEEL_CHROME    = [0.75, 0.77, 0.80];
COL_DUCT_BLACK      = [0.12, 0.13, 0.14];
COL_DUCT_COLLAR     = [0.65, 0.68, 0.72];
COL_HVAC_HOUSING    = [0.20, 0.22, 0.24];
COL_VAULT_FRAME     = [0.85, 0.87, 0.90];
COL_VAULT_DOOR      = [0.25, 0.27, 0.30];
COL_HYDRAULIC_ROD   = [0.88, 0.90, 0.92];
COL_SENSOR_BODY     = [0.82, 0.84, 0.86];
COL_SENSOR_LENS     = [0.10, 0.65, 0.75]; // Cyan / Emerald optical sensor glass
COL_INDICATOR_GREEN = [0.20, 0.85, 0.30];

// -----------------------------------------------------------------------------
// Track Modules
// -----------------------------------------------------------------------------

module heavy_amu_crawler_track() {
    // Continuous wide rubber-steel composite crawler loop
    color(COL_TRACK_RUBBER) {
        difference() {
            hull() {
                translate([-(TRACK_L/2 - TRACK_H/2), 0, 0])
                    rotate([90, 0, 0]) cylinder(h=TRACK_W, r=TRACK_H/2, center=true);
                translate([(TRACK_L/2 - TRACK_H/2), 0, 0])
                    rotate([90, 0, 0]) cylinder(h=TRACK_W, r=TRACK_H/2, center=true);
            }
            hull() {
                translate([-(TRACK_L/2 - TRACK_H/2), 0, 0])
                    rotate([90, 0, 0]) cylinder(h=TRACK_W - 0.25, r=TRACK_H/2 - 0.35, center=true);
                translate([(TRACK_L/2 - TRACK_H/2), 0, 0])
                    rotate([90, 0, 0]) cylinder(h=TRACK_W - 0.25, r=TRACK_H/2 - 0.35, center=true);
            }
        }
    }

    // Heavy-duty permafrost/regolith cleats & ice grousers
    color(COL_GROUSER_GOLD) {
        step = (TRACK_L - TRACK_H) / (GROUSER_COUNT / 2 - 2);
        // Bottom ground-contact cleats
        for (gx = [-(TRACK_L/2 - TRACK_H/2) : step : (TRACK_L/2 - TRACK_H/2)]) {
            translate([gx, 0, -TRACK_H/2])
                cube([0.22, TRACK_W + 0.10, 0.15], center=true);
        }
        // Top return cleats
        for (gx = [-(TRACK_L/2 - TRACK_H/2) : step : (TRACK_L/2 - TRACK_H/2)]) {
            translate([gx, 0, TRACK_H/2])
                cube([0.22, TRACK_W + 0.10, 0.15], center=true);
        }
    }

    // Road wheels and drive sprockets
    color(COL_WHEEL_CHROME) {
        // Front drive sprocket & rear idler
        for (ex = [-(TRACK_L/2 - TRACK_H/2), (TRACK_L/2 - TRACK_H/2)]) {
            translate([ex, 0, 0])
                rotate([90, 0, 0]) cylinder(h=TRACK_W - 0.15, r=TRACK_H/2 - 0.25, center=true, $fn=28);
        }
        // 8x Dual load road wheels
        for (wx = [-(TRACK_L/2 - 2.2) : (TRACK_L - 4.4)/7 : (TRACK_L/2 - 2.2)]) {
            translate([wx, 0, -0.32])
                rotate([90, 0, 0]) cylinder(h=TRACK_W - 0.2, r=0.65, center=true, $fn=24);
        }
    }
}

// -----------------------------------------------------------------------------
// Subsystem 1: A36 Steel Structural Exoskeleton Truss Cage
// -----------------------------------------------------------------------------

module exo_truss_arch(rx) {
    // Structural perimeter arch framing the cylindrical hull
    translate([rx, 0, 0]) {
        difference() {
            rotate([0, 90, 0]) {
                difference() {
                    cylinder(h=0.28, r=MMS_RADIUS + 0.35, center=true, $fn=64);
                    cylinder(h=0.35, r=MMS_RADIUS + 0.05, center=true, $fn=64);
                }
            }
            // Truncate cleanly below base deck in global Z (FLAT_Z_CUT)
            translate([0, 0, FLAT_Z_CUT - (MMS_RADIUS + 1.0)])
                cube([1.0, 2*(MMS_RADIUS + 2.0), 2*(MMS_RADIUS + 1.0)], center=true);
        }
    }
}

module exo_truss_cage() {
    color(COL_EXO_STEEL) {
        // Transverse Reinforcement Ribs (Full circular arches conforming to hull)
        for (rx = [-MMS_LENGTH/2 + 0.2, -MMS_LENGTH/4, 0, MMS_LENGTH/4, MMS_LENGTH/2 - 0.2]) {
            exo_truss_arch(rx);
        }

        // Longitudinal Dorsal Spine Truss (Top Spine)
        translate([0, 0, MMS_RADIUS + 0.35]) {
            for (sy = [-0.75, 0.75]) {
                translate([0, sy, 0])
                    cube([MMS_LENGTH + 0.2, 0.22, 0.22], center=true);
                translate([0, sy, 0.55])
                    cube([MMS_LENGTH + 0.2, 0.18, 0.18], center=true);
                for (px = [-MMS_LENGTH/2 + 0.4 : 1.4 : MMS_LENGTH/2 - 0.4]) {
                    translate([px, sy, 0.27])
                        cube([0.14, 0.14, 0.55], center=true);
                }
            }
            for (px = [-MMS_LENGTH/2 + 1.1 : 2.8 : MMS_LENGTH/2 - 1.1]) {
                translate([px, 0, 0.27]) rotate([0, 0, 35])
                    cube([0.12, 1.6, 0.12], center=true);
                translate([px, 0, 0.27]) rotate([0, 0, -35])
                    cube([0.12, 1.6, 0.12], center=true);
            }
        }

        // Conformal Diagrid Cross-Bracing Struts (Conforming to curved hull radius)
        // Diagrid Hull Cross-Braces ("X" Patterns) Dual-Purpose Rationale:
        // 1. Optical Anti-Whiteout & Fiducial Grid: In extreme Arctic blizzard or whiteout
        //    conditions, high-contrast dark steel markings provide essential visual landmarks
        //    and feature tracking for approaching cargo drones, landers, and automated rovers.
        // 2. Structural Torsional & Shear Rigidity: While circular hoops resist hoop stress,
        //    the diagonal "X" triangulation stiffens the 18m hull against twisting (torsion)
        //    and racking forces caused by uneven terrain differentials under crawler tracks.
        for (side = [-1, 1]) {
            for (bx = [-MMS_LENGTH/2 + 2.2 : 4.4 : MMS_LENGTH/2 - 2.2]) {
                for (ang = [25 : 25 : 75]) {
                    ay = side * (MMS_RADIUS + 0.12) * cos(ang);
                    az = (MMS_RADIUS + 0.12) * sin(ang);
                    // Tangent rotation to hug the hull surface
                    translate([bx, ay, az])
                        rotate([side * (ang - 90), 0, 0])
                        rotate([0, 0, 35])
                            cube([3.2, 0.14, 0.14], center=true);
                    translate([bx, ay, az])
                        rotate([side * (ang - 90), 0, 0])
                        rotate([0, 0, -35])
                            cube([3.2, 0.14, 0.14], center=true);
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------
// Subsystem 2: Arctic Air Handling Unit (AHU), Ducts & Manifolds
// -----------------------------------------------------------------------------

module arctic_ahu_pack() {
    // Upper Arctic HVAC Rooftop Box (North/Dorsal offset)
    translate([-1.2, 2.2, MMS_RADIUS - 0.2]) {
        // Main AHU insulated housing
        color(COL_HVAC_HOUSING) {
            cube([4.8, 2.2, 1.3], center=true);
            // Radiator grill louvers
            for (gx = [-2.1 : 0.42 : 2.1]) {
                translate([gx, 1.12, 0])
                    cube([0.18, 0.08, 1.1], center=true);
            }
        }
        // Top Rooftop Extractor Fan Shroud & Impeller
        translate([0, 0, 0.72]) {
            color(COL_HVAC_HOUSING)
                cylinder(h=0.22, r=0.85, center=true, $fn=32);
            color(COL_EXO_STEEL) {
                difference() {
                    cylinder(h=0.26, r=0.80, center=true, $fn=32);
                    cylinder(h=0.30, r=0.72, center=true, $fn=32);
                }
                for (rot = [0, 45, 90, 135]) rotate([0, 0, rot])
                    cube([1.5, 0.08, 0.28], center=true);
            }
        }
    }

    // Flexible High-Bore Arctic Intake Conduit / Elbow Duct
    color(COL_DUCT_BLACK) {
        translate([-1.2, 3.8, MMS_RADIUS - 0.4])
            rotate([0, 90, 0]) cylinder(h=1.8, r=0.62, center=true, $fn=32);
        
        translate([-1.2, 4.4, MMS_RADIUS - 1.2])
            rotate([35, 0, 0]) cylinder(h=1.6, r=0.60, center=true, $fn=32);

        translate([-1.2, 5.2, MMS_RADIUS - 2.8])
            rotate([70, 0, 0]) cylinder(h=2.2, r=0.58, center=true, $fn=32);
    }

    // Duct Reinforcement Rings / Clamps
    color(COL_DUCT_COLLAR) {
        translate([-1.2, 3.8, MMS_RADIUS - 0.4])
            rotate([0, 90, 0]) cylinder(h=0.15, r=0.68, center=true, $fn=32);
        translate([-1.2, 4.4, MMS_RADIUS - 1.2])
            rotate([35, 0, 0]) cylinder(h=0.15, r=0.66, center=true, $fn=32);
        translate([-1.2, 5.2, MMS_RADIUS - 2.8])
            rotate([70, 0, 0]) cylinder(h=0.15, r=0.64, center=true, $fn=32);
    }

    // Lateral Air Handling Manifold & Centrifugal Blower Unit (Port Flank)
    translate([-1.2, 5.35, -0.6]) {
        color(COL_HVAC_HOUSING) {
            cube([2.6, 1.2, 2.0], center=true);
            translate([0, 0.62, 0])
                cube([2.2, 0.06, 1.6], center=true);
        }
        // Industrial Axial Fan Housing (Intake/Exhaust)
        translate([-0.6, 0.65, 0.2]) {
            color(COL_EXO_STEEL) {
                rotate([90, 0, 0]) cylinder(h=0.22, r=0.55, center=true, $fn=32);
                for (a = [0, 60, 120]) rotate([90, 0, a])
                    cube([1.0, 0.08, 0.25], center=true);
            }
        }
        // Auxiliary Top Booster Fan
        translate([0.5, 0, 1.1]) {
            color(COL_HVAC_HOUSING)
                cylinder(h=0.24, r=0.52, center=true, $fn=28);
            color(COL_EXO_STEEL) {
                for (a = [0, 45, 90, 135]) rotate([0, 0, a])
                    cube([0.95, 0.06, 0.28], center=true);
            }
        }
    }

    // Side Multi-Stage Air Intake Box & Exhaust Manifold (Lower Flank)
    translate([2.4, 4.9, -2.8]) {
        color(COL_HVAC_HOUSING) {
            cube([3.6, 0.9, 0.9], center=true);
            for (cx = [-1.4 : 0.7 : 1.4]) {
                translate([cx, 0.48, 0])
                    cube([0.15, 0.08, 0.75], center=true);
            }
        }
        color(COL_DUCT_BLACK) {
            translate([-1.8, 0, 0]) rotate([0, 90, 0])
                cylinder(h=0.6, r=0.28, center=true, $fn=24);
            translate([1.8, 0, 0]) rotate([0, 90, 0])
                cylinder(h=0.6, r=0.28, center=true, $fn=24);
        }
    }

    // Decommissioned Base Intake Sponson / Lower Manifold
    translate([0, 4.95, -3.85]) {
        color(COL_CHASSIS_STEEL) {
            cube([8.2, 0.7, 0.55], center=true);
            for (ix = [-3.0, 0, 3.0]) {
                translate([ix, 0.38, 0])
                    cube([1.2, 0.08, 0.38], center=true);
            }
        }
    }
}

// -----------------------------------------------------------------------------
// Subsystem 3: Heavy Vault-Style Hermetic End Portal
// -----------------------------------------------------------------------------

module vault_hatch_door(x_pos, facing_dir) {
    // Scaled tall vault door matching the illustration
    translate([x_pos, 0, -0.5]) {
        rotate([0, 0, facing_dir == 1 ? 0 : 180]) {
            // Main Heavy Door Perimeter Frame with Airtight Gasket
            color(COL_VAULT_FRAME) {
                difference() {
                    cube([0.55, 4.6, 5.8], center=true);
                    cube([0.65, 3.6, 4.8], center=true);
                }
                // Exterior bevel flange
                translate([0.22, 0, 0])
                    difference() {
                        cube([0.15, 5.0, 6.2], center=true);
                        cube([0.25, 3.8, 5.0], center=true);
                    }
            }

            // Massive Vault Hatch Leaf
            color(COL_VAULT_DOOR) {
                translate([0.15, 0, 0])
                    cube([0.28, 3.5, 4.7], center=true);
            }

            // Central Mechanical Locking Hub & Radial Dog Bars
            translate([0.32, 0, 0]) {
                color(COL_EXO_STEEL) {
                    rotate([0, 90, 0])
                        cylinder(h=0.22, r=0.55, center=true, $fn=32);
                    cube([0.26, 0.65, 0.65], center=true);
                }
                // Complex radial lock bars exactly as in diagram
                color(COL_EXO_STEEL) {
                    // Horizontal locking bars
                    cube([0.18, 3.4, 0.20], center=true);
                    // Vertical locking bars
                    cube([0.18, 0.20, 4.5], center=true);
                    // Diagonal cross-locking bars
                    rotate([48, 0, 0]) cube([0.16, 4.6, 0.16], center=true);
                    rotate([-48, 0, 0]) cube([0.16, 4.6, 0.16], center=true);
                }
            }

            // Dual Complex Actuating Pistons (Hydraulic / Pneumatic)
            for (py = [-1.55, 1.55]) {
                translate([0.35, py, 0]) {
                    color(COL_EXO_STEEL) {
                        cylinder(h=2.2, r=0.20, center=true, $fn=24);
                    }
                    color(COL_HYDRAULIC_ROD) {
                        translate([0, 0, 1.2])
                            cylinder(h=1.0, r=0.12, center=true, $fn=24);
                    }
                    color(COL_VAULT_FRAME) {
                        translate([0, 0, -1.15]) cube([0.26, 0.32, 0.26], center=true);
                        translate([0, 0, 1.75]) cube([0.26, 0.32, 0.26], center=true);
                    }
                }
            }

            // Heavy Industrial Bearing Hinges
            for (hy = [-1.75, 1.75]) {
                for (hz = [-1.8, 1.8]) {
                    translate([0.28, hy, hz]) {
                        color(COL_VAULT_FRAME) {
                            rotate([0, 90, 0])
                                cylinder(h=0.42, r=0.30, center=true, $fn=24);
                        }
                    }
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------
// Subsystem 4: Redundant Sensor Pods & Avionics Mast
// -----------------------------------------------------------------------------

module sensor_pod_assembly() {
    color(COL_SENSOR_BODY) {
        cube([0.55, 0.55, 0.42], center=true);
        translate([0, 0, -0.25])
            cylinder(h=0.15, r=0.24, center=true, $fn=24);
    }
    color(COL_SENSOR_LENS) {
        translate([0.28, 0.12, 0.05])
            rotate([0, 90, 0]) cylinder(h=0.08, r=0.11, center=true, $fn=20);
        translate([0.28, -0.12, 0.05])
            rotate([0, 90, 0]) cylinder(h=0.08, r=0.08, center=true, $fn=20);
    }
    translate([0, 0, 0.32]) {
        color(COL_SENSOR_BODY)
            cylinder(h=0.22, r=0.22, center=true, $fn=28);
        color(COL_INDICATOR_GREEN)
            translate([0, 0, 0.12])
                cylinder(h=0.05, r=0.14, center=true, $fn=20);
    }
}

module dorsal_sensor_network() {
    for (px = [-MMS_LENGTH/2 + 2.4, MMS_LENGTH/2 - 2.4]) {
        for (py = [-0.75, 0.75]) {
            translate([px, py, MMS_RADIUS + 0.98])
                sensor_pod_assembly();
        }
    }

    for (sx = [-MMS_LENGTH/2 - 0.15, MMS_LENGTH/2 + 0.15]) {
        translate([sx, 0, 2.7]) {
            rotate([0, 0, sx > 0 ? 0 : 180])
                scale([0.8, 0.8, 0.8])
                    sensor_pod_assembly();
        }
    }
}

// -----------------------------------------------------------------------------
// Flattened Hull Architecture (Base Cylinder & Chassis)
// -----------------------------------------------------------------------------

module flattened_amu_hull() {
    difference() {
        color(HULL_WHITE) {
            rotate([0, 90, 0])
                cylinder(h=MMS_LENGTH, r=MMS_RADIUS, center=true, $fn=64);
        }
        translate([0, 0, FLAT_Z_CUT - MMS_RADIUS])
            cube([MMS_LENGTH + 2.0, 2*MMS_RADIUS + 2.0, 2*MMS_RADIUS], center=true);

        rotate([0, 90, 0])
            cylinder(h=MMS_LENGTH - 0.8, r=MMS_RADIUS - 0.35, center=true, $fn=48);
        
        for (sx = [-MMS_LENGTH/2, MMS_LENGTH/2]) {
            translate([sx, 0, FLAT_Z_CUT + 2.0])
                cube([1.5, 4.2, 3.4], center=true);
        }
    }

    color(COL_CHASSIS_STEEL) {
        translate([0, 0, FLAT_Z_CUT + BASE_DECK_H/2]) {
            cube([MMS_LENGTH + 0.4, BASE_DECK_W, BASE_DECK_H], center=true);
            for (bx = [-MMS_LENGTH/2 + 2.0 : 4.0 : MMS_LENGTH/2 - 2.0]) {
                translate([bx, 0, -0.4])
                    cube([0.8, BASE_DECK_W + 1.2, 0.6], center=true);
            }
        }
    }

    vault_hatch_door(MMS_LENGTH/2 + 0.05, 1);
    vault_hatch_door(-MMS_LENGTH/2 - 0.05, -1);

    for (sideY = [-1, 1]) {
        a = 90 - sideY * 23.58;
        rotate([a - 90, 0, 0]) {
            translate([0, 0, MMS_RADIUS + 0.08]) {
                color([0.2, 0.22, 0.25]) cube([11.6, 0.56, 0.21], center=true);
                translate([sideY * 2.5, 0, 0.2]) {
                    color([0.7, 0.78, 0.85]) cube([0.84, 0.7, 0.25], center=true);
                    color([0.15, 0.45, 0.85]) translate([0, 0, 0.2]) cylinder(h=0.3, r=0.25, center=true);
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------
// Complete Mobile Surface AMU Solo Unit v2.0
// -----------------------------------------------------------------------------


// -----------------------------------------------------------------------------
// Subsystem 5: Tandem Heavy-Lift Aerial Cargo Sling & Hoist Rigging (v2.1)
// -----------------------------------------------------------------------------

COL_SLING_YELLOW    = [0.92, 0.75, 0.12]; // High-visibility rigging yellow
COL_SHACKLE_STEEL   = [0.35, 0.38, 0.42];

module tandem_aerial_hoist_rigging() {
    // 1. Dual Dorsal Spreader Beams & Tandem Hoist Shackles (Forward & Aft Spine)
    for (hx = [-MMS_LENGTH*0.28, MMS_LENGTH*0.28]) {
        translate([hx, 0, MMS_RADIUS + 0.95]) {
            // Heavy transverse spreader beam across spine box truss
            color(COL_EXO_STEEL) {
                cube([0.55, 2.4, 0.28], center=true);
            }
            // Dual heavy-duty swivel hoist shackles / pad-eyes
            for (sy = [-0.95, 0.95]) {
                translate([0, sy, 0.24]) {
                    color(COL_SLING_YELLOW) {
                        // Forged master lift ring
                        difference() {
                            cylinder(h=0.18, r=0.28, center=true, $fn=24);
                            cylinder(h=0.25, r=0.16, center=true, $fn=24);
                        }
                    }
                    // Clevis pin mounting block
                    color(COL_SHACKLE_STEEL) {
                        translate([0, 0, -0.15])
                            cube([0.28, 0.22, 0.20], center=true);
                    }
                }
            }
        }
    }

    // 2. Quad Perimeter Chassis Sling Pad-Eyes & Corner Lift Hooks
    // Positioned at the 4 primary structural corners of the reinforced base chassis deck
    for (cx = [-MMS_LENGTH/2 + 1.2, MMS_LENGTH/2 - 1.2]) {
        for (cy = [-BASE_DECK_W/2 + 0.1, BASE_DECK_W/2 - 0.1]) {
            translate([cx, cy, FLAT_Z_CUT + BASE_DECK_H + 0.12]) {
                // Forged anchor pad-eye welded to chassis flange
                color(COL_SHACKLE_STEEL) {
                    cube([0.45, 0.35, 0.25], center=true);
                }
                // High-visibility swivel lift ring
                color(COL_SLING_YELLOW) {
                    translate([0, sgn(cy)*0.12, 0.22]) rotate([90, 0, 0]) {
                        difference() {
                            cylinder(h=0.12, r=0.22, center=true, $fn=20);
                            cylinder(h=0.16, r=0.12, center=true, $fn=20);
                        }
                    }
                }
            }
        }
    }
}

module amu_mobile_surface_solo_v2_1() {
    // 1. Flattened Hull, Chassis & Vault End Portals
    flattened_amu_hull();

    // 2. A36 Steel Exo-Skeleton Truss Cage & Conformal Diagrid Bracing
    exo_truss_cage();

    // 3. Arctic Air Handling Unit & Ducting Network
    arctic_ahu_pack();

    // 4. Redundant Sensor Pod Network & Avionics
    dorsal_sensor_network();

    // 5. Tandem Heavy-Lift Aerial Cargo Sling & Hoist Rigging (v2.1)
    tandem_aerial_hoist_rigging();

    // 6. Dual Continuous Crawler Tracks (Port & Starboard)
    for (side = [-1, 1]) {
        translate([0, side * TRACK_Y_OFFSET, FLAT_Z_CUT - TRACK_H/2])
            heavy_amu_crawler_track();
    }
}

// Top-Level Assembly
amu_mobile_surface_solo_v2_1();


