// amu_surface_habitat_v1.scad -- AMU-Surface Base Habitat & Overhead Ceiling Gantry Architecture (v1.0)
//
// Version Control & Engineering Audit:
// - Version: v1.0
// - Tracked Under: Issue #97 (Parent #81, Cross-ref #82, #88)
// - Architectural Source Authority: This file defines the canonical spatial geometry
//   and coordinate frames for the AMU-Surface vault shelter, apex ceiling gantry rail
//   (CEILING_Z = HAB_R - 0.35 = 5.15 m), and high-bay staging portal (PORTAL_W = 5.2 m, PORTAL_H = 3.2 m).
// - Downstream Interface Maintenance Rule:
//   Every time this file is updated (e.g. changing HAB_R, CEILING_Z, or portal dimensions),
//   downstream kinematic files that include it (specifically `amu_surface_transfer_docking_v1.scad`)
//   MUST be updated and re-verified in lockstep to maintain kinematic mate alignment.
//
// Adapts the cylindrical AMU structure (asi.surge.sh/img/portfolio/amu/amu-orbiting-greenhouses.png)
// to planetary and remote permafrost surfaces (Moon, Mars, Arctic).
//
// Key Subsystems:
// 1. Vaulted structural shell / arched foundation module with reinforced ground footing pads.
// 2. High-bay staging area with end-wall automated clamshell airlock/deployment portal for rovers.
// 3. Overhead Ceiling Gantry Rail running along the vault apex (servicing internal seed/production bays).
// 4. Staging Bay Transfer Lock where STRIDER-M backs in under the ceiling rail to receive the CORA-M arm.
// 5. Umbilical power coupling mast for surface grid / wind turbine interconnection.
//
// Units: OpenSCAD model units (compatible with STRIDER-M and CORA-M)

$fn = 36;

// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------
HAB_L           = 18.0;  // Length of surface habitat
HAB_R           = 5.5;   // Radius of vaulted hull
HAB_FLOOR_Y     = 8.0;   // Usable internal floor width
HAB_WALL_T      = 0.28;  // Insulated structural shell thickness

PORTAL_W        = 5.2;   // Rover portal width (clears STRIDER-M 4.6 m width)
PORTAL_H        = 3.2;   // Rover portal height

CEILING_RAIL_L  = 16.8;  // Overhead rail span
CEILING_RAIL_W  = 0.60;
CEILING_RAIL_H  = 0.25;
CEILING_Z       = HAB_R - 0.35; // Apex ceiling height

// Viewing Mode: 0 = Cutaway interior view, 1 = Full exterior shelter
hab_view_mode   = 0;

// Colors
COL_SHELL_EXT   = [0.85, 0.86, 0.88];
COL_SHELL_INT   = [0.24, 0.26, 0.30];
COL_FOUNDATION  = [0.35, 0.38, 0.42];
COL_RAIL_STEEL  = [0.72, 0.74, 0.78];
COL_PORTAL_GOLD = [0.85, 0.68, 0.25];
COL_BAY_GREEN   = [0.25, 0.65, 0.35];

// -----------------------------------------------------------------------------
// Modules
// -----------------------------------------------------------------------------

module surface_foundation_footings() {
    // Heavy reinforced foundation beams & thermal siphon permafrost / regolith piles
    color(COL_FOUNDATION) {
        // Lateral footing beams
        for (fy = [-HAB_R - 0.4, HAB_R + 0.4]) {
            translate([0, fy, -0.4])
                cube([HAB_L + 1.2, 1.2, 0.8], center=true);
            // Foundation ground anchor stakes
            for (fx = [-HAB_L/2 : 3.0 : HAB_L/2]) {
                translate([fx, fy, -1.0])
                    cylinder(h=1.2, r=0.22, center=true);
            }
        }
        // Main insulated structural floor slab
        translate([0, 0, -0.15])
            cube([HAB_L, HAB_FLOOR_Y, 0.30], center=true);
    }
}

module vaulted_habitat_shell(cutaway = true) {
    // Arched pressurized vault with multi-layer radiation & micrometeorite insulation
    difference() {
        // Outer cylindrical arch
        color(COL_SHELL_EXT) {
            rotate([0, 90, 0])
                cylinder(h=HAB_L, r=HAB_R, center=true);
        }
        // Inner hollow living & production envelope
        rotate([0, 90, 0])
            cylinder(h=HAB_L - 0.8, r=HAB_R - HAB_WALL_T, center=true);
        
        // Truncate below ground floor level
        translate([0, 0, -HAB_R])
            cube([HAB_L + 2, 2*HAB_R + 2, 2*HAB_R], center=true);
        
        // Rover deployment portal cutout at +X end
        translate([HAB_L/2 - 0.5, 0, PORTAL_H/2])
            cube([2.0, PORTAL_W, PORTAL_H], center=true);

        // Cutaway slice for interior visualization when enabled (cut off -Y side to reveal interior)
        if (cutaway) {
            translate([0, -(HAB_R/2 + 0.1), HAB_R/2])
                cube([HAB_L + 4, HAB_R + 2, HAB_R + 2], center=true);
        }
    }

    // Portal door frame & reinforced blast threshold
    color(COL_PORTAL_GOLD) {
        translate([HAB_L/2, 0, PORTAL_H/2]) {
            difference() {
                cube([0.5, PORTAL_W + 0.6, PORTAL_H + 0.6], center=true);
                cube([0.6, PORTAL_W, PORTAL_H], center=true);
            }
        }
    }
}

module overhead_ceiling_gantry_rail() {
    // Longitudinal overhead gantry beam along the vault apex
    color(COL_RAIL_STEEL) {
        translate([0, 0, CEILING_Z]) {
            // Main I-beam runner
            cube([CEILING_RAIL_L, CEILING_RAIL_W, CEILING_RAIL_H], center=true);
            // Twin precision hardened linear guide tracks
            for (ry = [-CEILING_RAIL_W/2 + 0.08, CEILING_RAIL_W/2 - 0.08]) {
                translate([0, ry, -CEILING_RAIL_H/2 - 0.05])
                    rotate([0, 90, 0]) cylinder(h=CEILING_RAIL_L, r=0.04, center=true);
            }
        }
    }

    // Overhead structural support ribs anchored to vault hull
    color([0.45, 0.48, 0.52]) {
        for (rx = [-HAB_L/2 + 2.0 : 2.5 : HAB_L/2 - 2.0]) {
            translate([rx, 0, CEILING_Z + 0.25])
                cube([0.22, 1.4, 0.45], center=true);
        }
    }
}

module internal_production_and_staging_bays() {
    // Staging and greenhouse / manufacturing tiers along the port wall
    color(COL_BAY_GREEN) {
        for (bx = [-HAB_L/2 + 2.5 : 2.8 : 0]) {
            translate([bx, -HAB_FLOOR_Y/2 + 0.8, 0.8]) {
                // Tiered plant / equipment racks
                cube([2.2, 1.4, 1.6], center=true);
                // Overhead LED grow / inspection arrays
                translate([0, 0, 1.0])
                    color("Gold") cube([2.0, 1.2, 0.08], center=true);
            }
        }
    }

    // High-bay rover staging & transfer pad at the airlock (+X quadrant)
    color([0.28, 0.30, 0.35]) {
        translate([HAB_L/4, 0, 0.02]) {
            cube([HAB_L/2 - 0.5, PORTAL_W - 0.2, 0.04], center=true);
            // Yellow high-visibility alignment guide stripes
            color("Gold") {
                for (gy = [-(PORTAL_W/2 - 0.4), (PORTAL_W/2 - 0.4)]) {
                    translate([0, gy, 0.03])
                        cube([HAB_L/2 - 1.0, 0.15, 0.01], center=true);
                }
            }
        }
    }
}

module amu_surface_habitat_full(cutaway = true) {
    surface_foundation_footings();
    vaulted_habitat_shell(cutaway);
    overhead_ceiling_gantry_rail();
    internal_production_and_staging_bays();
}

// -----------------------------------------------------------------------------
// Top-Level Assembly
// -----------------------------------------------------------------------------
amu_surface_habitat_full();
