// amu_mobile_surface_duo.scad -- Dual AMU Surface Architecture with Flattened Base & Continuous Tracks
//
// Adapts the two legacy AMUs (Autonomous Manufacturing Units) from orbital configuration
// to heavy mobile surface exploration / manufacturing platforms:
// 1. Flattened Base:
//    - Truncates the cylindrical hull bottom at Z = -MMS_RADIUS + FLAT_TRUNCATE (e.g. Z = -5.0)
//    - Replaces the curved underside with a heavy reinforced structural belly plate and foundation deck.
// 2. Heavy Continuous Crawler Tracks ("Snowshoes"):
//    - Equips each AMU with dual heavy-duty continuous wide-track bogies scaled from STRIDER-M.
//    - Track length: 16.5 m (spanning the 17.92 m AMU hull length).
//    - Track width: 1.8 m wide per track (delivering ultra-low ground pressure across 120+ tonnes).
//    - Gold traction cleats / ice grousers for permafrost, lunar regolith, or martian terrain.
// 3. Dual Architecture & Articulation:
//    - Retains quad lateral CORA-M guide rails (dorsal + lateral) across both AMUs (#81).
//    - Preserves central umbilical/logistics spine bridge connecting the two mobile AMUs.
//    - Features high-bay entrance portals and internal production/greenhouse tiers.
//
// Units: OpenSCAD model units (Scale: MMS_RADIUS = 6.0, MMS_LENGTH = 17.92)
// Tracked under Issue #97 / #81 (Child to #81, cross-ref #82)

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

// Inter-AMU connection
SPINE_LENGTH        = 24.0;
AMU_SEPARATION      = 28.0;

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
// Complete Mobile Surface AMU Unit
// -----------------------------------------------------------------------------

module mobile_surface_amu_unit() {
    // 1. Flattened Hull & Sponsons
    flattened_amu_hull();

    // 2. Dual Continuous Crawler Tracks (Port & Starboard)
    // Positioned beneath the lateral sponsons
    for (side = [-1, 1]) {
        translate([0, side * TRACK_Y_OFFSET, FLAT_Z_CUT - TRACK_H/2])
            heavy_amu_crawler_track();
    }
}

// -----------------------------------------------------------------------------
// Articulated Inter-AMU Logistics Bridge
// -----------------------------------------------------------------------------

module inter_amu_articulated_bridge() {
    // Heavy telescoping gangway & power/slurry umbilical bridge connecting the two mobile AMUs
    color([0.3, 0.32, 0.35]) {
        // Central telescoping box beam
        translate([0, 0, FLAT_Z_CUT + 1.2]) {
            cube([AMU_SEPARATION - MMS_LENGTH - 1.2, 2.4, 1.8], center=true);
            // Flexible rubber bellows / accordion seals at joints
            for (bx = [-(AMU_SEPARATION - MMS_LENGTH)/2 + 0.8, (AMU_SEPARATION - MMS_LENGTH)/2 - 0.8]) {
                translate([bx, 0, 0])
                    color([0.15, 0.15, 0.15]) cube([1.2, 2.6, 2.0], center=true);
            }
        }
        // Heavy umbilical cabling & cryogenic pipes
        for (dy = [-1.4, 1.4]) {
            translate([0, dy, FLAT_Z_CUT + 0.4])
                rotate([0, 90, 0]) cylinder(h=AMU_SEPARATION - MMS_LENGTH + 0.5, r=0.18, center=true);
        }
    }
}

// -----------------------------------------------------------------------------
// Top-Level Assembly: Dual Mobile AMUs on Tracks
// -----------------------------------------------------------------------------

module dual_mobile_surface_amu_system() {
    // Lead Mobile AMU Unit (Manufacturing / Foundry / Power Core)
    translate([AMU_SEPARATION/2, 0, 0])
        mobile_surface_amu_unit();

    // Trail Mobile AMU Unit (Greenhouse / Habitation / Workshop)
    translate([-AMU_SEPARATION/2, 0, 0])
        mobile_surface_amu_unit();

    // Articulated Inter-AMU Logistics Bridge
    inter_amu_articulated_bridge();
}

dual_mobile_surface_amu_system();
