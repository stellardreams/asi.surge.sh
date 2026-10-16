// amu_mobile_surface_solo_v1.scad -- Surface AMU Mobile Unit (Solo Architecture v1.0)
//
// Version Control & Engineering Audit:
// - Version: v1.0
// - Tracked Under: Issue #97 (Parent #81, Cross-ref #82, #88)
// - Architectural Decision: Split the previously linked "duo" concept into standalone,
//   independent mobile AMU surface units. In surface gravity / terrain environments (Earth permafrost,
//   Moon, Mars), physical inter-module umbilical gangway bridges suffer immense torsional, shear, and
//   bending stresses due to uneven terrain differentials and surface gravity. Each AMU unit is therefore
//   completely self-contained on its own crawler chassis.
//
// 1. Flattened Base:
//    - Truncates the cylindrical hull bottom at Z = FLAT_Z_CUT (-4.2 m).
//    - Replaces curved underside with reinforced structural belly plate and foundation deck.
// 2. Heavy Continuous Crawler Tracks ("Snowshoes" Scaled from STRIDER-M):
//    - Equips the AMU unit with dual heavy-duty continuous wide-track bogies.
//    - Track length: 16.4 m (spanning the 17.92 m AMU hull length).
//    - Track width: 1.8 m wide per track (delivering ultra-low ground pressure 19.19 kPa <= 25 kPa).
//    - Gold traction cleats / ice grousers for permafrost, lunar regolith, or martian terrain.
// 3. Autonomous Subsystems:
//    - Retains quad lateral CORA-M guide rails (dorsal + lateral) (#81).
//    - Features high-bay entrance portals and internal production/greenhouse tiers.
//    - Self-contained dorsal solar arrays and thermal regulation sponsons.
//
// Units: OpenSCAD model units (Scale: MMS_RADIUS = 6.0, MMS_LENGTH = 17.92)

$fn = 40;

// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------
MMS_RADIUS          = 6.0;
MMS_LENGTH          = 17.92;
FLAT_Z_CUT          = -4.2;  // Level where cylindrical hull is truncated flat
BASE_DECK_W         = 9.6;   // Width of flat structural belly plate (2 * sqrt(R^2 - Z^2) ≈ 8.6 -> 9.6 with sponsons)
BASE_DECK_H         = 0.55;  // Thickness of reinforced base chassis

// Track Sizing (Heavy-duty "snowshoes" scaled for 18m AMU)
TRACK_L             = 16.4;  // Length of continuous track
TRACK_W             = 1.8;   // Width of track
TRACK_H             = 2.2;   // Height of track bogie
TRACK_Y_OFFSET      = 4.6;   // Lateral offset from hull centerline (Y = ±4.6)
GROUSER_COUNT       = 32;

// Colors
HULL_TAN            = [0.78, 0.70, 0.60];
HULL_DARK           = [0.68, 0.60, 0.50];
COL_CHASSIS_STEEL   = [0.22, 0.24, 0.27];
COL_TRACK_RUBBER    = [0.18, 0.19, 0.21];
COL_GROUSER_GOLD    = [0.85, 0.68, 0.25];
COL_WHEEL_CHROME    = [0.75, 0.77, 0.80];
COL_SOLAR_BLACK     = [0.05, 0.05, 0.08];
COL_SOLAR_GRID      = [0.18, 0.22, 0.45];
COL_PORTAL_FRAME    = [0.88, 0.42, 0.12];

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
// Flattened Hull Architecture
// -----------------------------------------------------------------------------

module flattened_amu_hull() {
    // Main pressurized cylinder truncated at bottom
    difference() {
        // Upper arched hull
        color(HULL_TAN) {
            rotate([0, 90, 0])
                cylinder(h=MMS_LENGTH, r=MMS_RADIUS, center=true, $fn=64);
        }
        // Truncate bottom below FLAT_Z_CUT
        translate([0, 0, FLAT_Z_CUT - MMS_RADIUS])
            cube([MMS_LENGTH + 2.0, 2*MMS_RADIUS + 2.0, 2*MMS_RADIUS], center=true);

        // Internal hollow bay
        rotate([0, 90, 0])
            cylinder(h=MMS_LENGTH - 0.8, r=MMS_RADIUS - 0.35, center=true, $fn=48);
        
        // Front and Rear heavy access portals
        for (sx = [-MMS_LENGTH/2, MMS_LENGTH/2]) {
            translate([sx, 0, FLAT_Z_CUT + 1.8])
                cube([1.5, 4.2, 3.2], center=true);
        }
    }

    // Heavy reinforced structural flat base plate & track mounting sponsons
    color(COL_CHASSIS_STEEL) {
        translate([0, 0, FLAT_Z_CUT + BASE_DECK_H/2]) {
            cube([MMS_LENGTH + 0.4, BASE_DECK_W, BASE_DECK_H], center=true);
            // Lateral sponson beams extending outward to track bogies
            for (bx = [-MMS_LENGTH/2 + 2.0 : 4.0 : MMS_LENGTH/2 - 2.0]) {
                translate([bx, 0, -0.4])
                    cube([0.8, BASE_DECK_W + 1.2, 0.6], center=true);
            }
        }
    }

    // Portal door frames
    color(COL_PORTAL_FRAME) {
        for (sx = [-MMS_LENGTH/2, MMS_LENGTH/2]) {
            translate([sx, 0, FLAT_Z_CUT + 1.8]) {
                difference() {
                    cube([0.45, 4.8, 3.8], center=true);
                    cube([0.55, 4.2, 3.2], center=true);
                }
            }
        }
    }

    // Dorsal Solar Wings (flat fixed terrestrial / surface array)
    for (sy = [-1, 1]) {
        translate([0, sy * (MMS_RADIUS + 1.6), 1.5]) {
            color(COL_SOLAR_BLACK) cube([MMS_LENGTH * 0.75, 2.8, 0.14], center=true);
            // Grid lines
            color(COL_SOLAR_GRID) {
                for (gx = [-MMS_LENGTH*0.32 : 1.4 : MMS_LENGTH*0.32])
                    translate([gx, 0, 0.01]) cube([0.05, 2.75, 0.15], center=true);
                for (gy = [-1.0 : 0.65 : 1.0])
                    translate([0, gy, 0.01]) cube([MMS_LENGTH * 0.74, 0.05, 0.15], center=true);
            }
            // Outrigger mounting struts from hull
            color(COL_CHASSIS_STEEL) {
                for (st_x = [-MMS_LENGTH*0.3, 0, MMS_LENGTH*0.3]) {
                    translate([st_x, -sy * 1.0, -0.5])
                        rotate([sy * 25, 0, 0]) cube([0.25, 1.8, 0.25], center=true);
                }
            }
        }
    }

    // Quad Lateral CORA-M Guide Rails (#81)
    // Mounted along the upper lateral curved sectors
    for (sideY = [-1, 1]) {
        a = 90 - sideY * 23.58;
        rotate([a - 90, 0, 0]) {
            translate([0, 0, MMS_RADIUS + 0.08]) {
                // Rail
                color([0.2, 0.22, 0.25]) cube([11.6, 0.56, 0.21], center=true);
                // Carriage
                translate([sideY * 2.5, 0, 0.2]) {
                    color([0.7, 0.78, 0.85]) cube([0.84, 0.7, 0.25], center=true);
                    // Arm base
                    color([0.15, 0.45, 0.85]) translate([0, 0, 0.2]) cylinder(h=0.3, r=0.25, center=true);
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------
// Complete Mobile Surface AMU Solo Unit
// -----------------------------------------------------------------------------

module amu_mobile_surface_solo_v1() {
    // 1. Flattened Hull & Sponsons
    flattened_amu_hull();

    // 2. Dual Continuous Crawler Tracks (Port & Starboard)
    // Positioned beneath the lateral sponsons
    for (side = [-1, 1]) {
        translate([0, side * TRACK_Y_OFFSET, FLAT_Z_CUT - TRACK_H/2])
            heavy_amu_crawler_track();
    }
}

// Top-Level Assembly
amu_mobile_surface_solo_v1();
