// strider_m_transporter.scad -- STRIDER-M Surface Transport & Robotic Installation Deployment Rover
//
// Repurposed from the heavy mining vehicle architecture (asi.surge.sh/img/portfolio/effort/mining.png).
// Equipped with low-ground-pressure continuous wide crawler tracks ("heavy-duty snowshoes" / tundra grousers / regolith treads)
// for traversing permafrost, lunar regolith, or martian terrain without ground subsidence or disruption.
//
// Key Subsystems:
// 1. Dual Heavy-Duty Wide Continuous Crawler Bogies (Low ground pressure <= 25 kPa)
// 2. Ruggedized Vehicle Center Frame with Heated Battery/Fuel-Cell Power Reservoir
// 3. Automated Latch Collar Docking Station (receives CORA-M 7-DoF robotic arm from AMU ceiling rail)
// 4. Conductive Power & Data Umbilical Coupling for uninterrupted field operations
// 5. Automated Payload Deck for Wind Turbine components / tool magazines
//
// Units: OpenSCAD model units (Scale compatible with AMU-Surface: 1 unit ~ 71.4 mm; or mm scale)
// Tracked under Issue #97 (Parent #81, Cross-ref #82, #88)

$fn = 32;

// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------
ROVER_L         = 7.2;   // Overall length
ROVER_W         = 4.6;   // Overall width
CHASSIS_H       = 1.2;   // Ground clearance / chassis height

TRACK_W         = 1.2;   // Extra-wide low-ground-pressure continuous track ("snowshoe")
TRACK_L         = 6.8;   // Track length
TRACK_H         = 1.4;   // Track height
GROUSER_COUNT   = 22;    // Deep traction grousers per track

DECK_L          = 5.4;
DECK_W          = 3.2;
DECK_H          = 0.35;

DOCK_COLLAR_R   = 0.55;  // Latch collar for CORA-M arm mounting
DOCK_COLLAR_H   = 0.25;

// Articulation variables
dock_locked     = 1;     // 1 = CORA-M arm locked into rover dock, 0 = open cradle
cable_deployed  = 1;     // 1 = Umbilical power cable plugged into AMU-Surface / wind station

// Colors
COL_ARMOR_DARK  = [0.18, 0.20, 0.22];
COL_TRACK_STEEL = [0.28, 0.29, 0.31];
COL_GROUSER_GOLD= [0.85, 0.68, 0.25];
COL_DECK_ORANGE = [0.88, 0.42, 0.12];
COL_CHROME      = [0.75, 0.77, 0.80];
COL_POWER_BLUE  = [0.15, 0.45, 0.85];

// -----------------------------------------------------------------------------
// Modules
// -----------------------------------------------------------------------------

module continuous_crawler_track() {
    // Continuous wide rubber-metal composite track loop
    color(COL_TRACK_STEEL) {
        difference() {
            // Rounded rectangular track profile
            hull() {
                translate([-(TRACK_L/2 - TRACK_H/2), 0, 0])
                    rotate([90, 0, 0]) cylinder(h=TRACK_W, r=TRACK_H/2, center=true);
                translate([(TRACK_L/2 - TRACK_H/2), 0, 0])
                    rotate([90, 0, 0]) cylinder(h=TRACK_W, r=TRACK_H/2, center=true);
            }
            // Cutout for road wheels
            hull() {
                translate([-(TRACK_L/2 - TRACK_H/2), 0, 0])
                    rotate([90, 0, 0]) cylinder(h=TRACK_W - 0.2, r=TRACK_H/2 - 0.22, center=true);
                translate([(TRACK_L/2 - TRACK_H/2), 0, 0])
                    rotate([90, 0, 0]) cylinder(h=TRACK_W - 0.2, r=TRACK_H/2 - 0.22, center=true);
            }
        }
    }

    // Heavy-duty snowshoe grousers / ice-cleats across perimeter
    color(COL_GROUSER_GOLD) {
        step = (TRACK_L - TRACK_H) / (GROUSER_COUNT / 2 - 2);
        // Bottom ground-contact grousers
        for (gx = [-(TRACK_L/2 - TRACK_H/2) : step : (TRACK_L/2 - TRACK_H/2)]) {
            translate([gx, 0, -TRACK_H/2])
                cube([0.14, TRACK_W + 0.05, 0.10], center=true);
        }
        // Top return grousers
        for (gx = [-(TRACK_L/2 - TRACK_H/2) : step : (TRACK_L/2 - TRACK_H/2)]) {
            translate([gx, 0, TRACK_H/2])
                cube([0.14, TRACK_W + 0.05, 0.10], center=true);
        }
    }

    // Heavy road wheels and drive sprockets
    color(COL_CHROME) {
        // Front drive sprocket & rear idler
        for (end_x = [-(TRACK_L/2 - TRACK_H/2), (TRACK_L/2 - TRACK_H/2)]) {
            translate([end_x, 0, 0])
                rotate([90, 0, 0]) cylinder(h=TRACK_W - 0.1, r=TRACK_H/2 - 0.18, center=true, $fn=24);
        }
        // 5x Dual bogie load wheels
        for (bx = [-1.6 : 0.8 : 1.6]) {
            translate([bx, 0, -0.22])
                rotate([90, 0, 0]) cylinder(h=TRACK_W - 0.15, r=0.42, center=true, $fn=20);
        }
    }
}

module rover_chassis_and_deck() {
    // Rugged armored central hull
    color(COL_ARMOR_DARK) {
        translate([0, 0, CHASSIS_H/2 - 0.1])
            cube([ROVER_L - 1.2, ROVER_W - 2*TRACK_W + 0.2, CHASSIS_H], center=true);
        // Front sloped glacis / debris shield
        translate([ROVER_L/2 - 0.6, 0, CHASSIS_H/2 - 0.1])
            rotate([0, 35, 0])
                cube([0.8, ROVER_W - 2*TRACK_W + 0.1, 0.4], center=true);
    }

    // High-visibility utility deck with modular mounting grid
    color(COL_DECK_ORANGE) {
        translate([0, 0, CHASSIS_H + DECK_H/2 - 0.1])
            cube([DECK_L, DECK_W, DECK_H], center=true);
        // Perimeter tie-down rail
        for (dy = [-DECK_W/2 + 0.1, DECK_W/2 - 0.1]) {
            translate([0, dy, CHASSIS_H + DECK_H + 0.08])
                rotate([0, 90, 0]) cylinder(h=DECK_L - 0.2, r=0.04, center=true);
        }
    }

    // Internal Heated Power Reservoir (Solid-State Batteries / Cryo Fuel Cell)
    color(COL_POWER_BLUE) {
        translate([-1.2, 0, CHASSIS_H/2 + 0.1])
            cube([2.0, DECK_W - 0.6, CHASSIS_H - 0.3], center=true);
    }

    // Autonomous Latch Collar Docking Station for CORA-M Arm
    translate([0.8, 0, CHASSIS_H + DECK_H]) {
        // Outer alignment ring
        color(COL_CHROME) {
            cylinder(h=DOCK_COLLAR_H, r=DOCK_COLLAR_R, center=true);
            translate([0, 0, DOCK_COLLAR_H/2])
                cylinder(h=0.08, r=DOCK_COLLAR_R + 0.12, center=true);
        }
        // 4x Locking cam latches
        color([0.2, 0.2, 0.2]) {
            for (ang = [0, 90, 180, 270]) {
                rotate([0, 0, ang])
                    translate([DOCK_COLLAR_R - 0.06, 0, DOCK_COLLAR_H/2 + 0.04])
                        cube([0.14, 0.22, 0.10], center=true);
            }
        }
        // Conductive circular umbilical socket (high-power transfer & fiber optic comms)
        color(COL_POWER_BLUE) {
            translate([0, 0, DOCK_COLLAR_H/2 + 0.01])
                cylinder(h=0.04, r=DOCK_COLLAR_R * 0.55, center=true, $fn=16);
        }
    }

    // Tool magazine & spare pin cassette rack
    color([0.3, 0.35, 0.4]) {
        translate([-2.0, 0, CHASSIS_H + DECK_H + 0.25]) {
            cube([0.8, 1.8, 0.5], center=true);
            // Sockets for titanium shear pins & torque sockets
            for (py = [-0.6 : 0.3 : 0.6]) {
                translate([0, py, 0.26])
                    color("Gold") cylinder(h=0.15, r=0.08, center=true);
            }
        }
    }
}

module strider_m_full() {
    // Center chassis & deck
    rover_chassis_and_deck();

    // Port & Starboard wide continuous tracks
    for (ty = [-(ROVER_W/2 - TRACK_W/2), (ROVER_W/2 - TRACK_W/2)]) {
        translate([0, ty, TRACK_H/2])
            continuous_crawler_track();
    }
}

// -----------------------------------------------------------------------------
// Top-Level Assembly
// -----------------------------------------------------------------------------
strider_m_full();
