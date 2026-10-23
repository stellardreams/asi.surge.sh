// amu_manna_machine_envelope_v1.scad -- 🏺 The New Manna Machine (Automated Earthen Bio-Habitat)
//
// Engineering & CAD Specifications:
// - Version: v1.0
// - Tracked Under: Issue #119 (Parent Umbrella #118, Master SIT #63)
// - Architectural Plan Authority: plans/plan-earthen-bio-habitats.md
//
// Integrated Systems:
// 1. Outer Heavy Thermal Mass Shell:
//    - 450-600 mm continuous slip-form rammed earth (Form Earth technology)
//    - Unstabilized in-situ subsoil / quarry overburden (zero Portland cement)
//    - Cv ≈ 1.8-2.0 MJ/m³K thermal ballast (-40°C Arctic permafrost / +45°C Equatorial heat)
// 2. Catenary Adobe Vault & Buttresses:
//    - Self-supporting inverted catenary profile printed via RepRap-kinematic gantry/delta (Shangrila-VHP #45)
//    - Integrated external buttresses for lateral earth-pressure stabilization
// 3. Inner Biosecure AMU Polyculture Sanctum:
//    - Controlled-environment vertical aeroponic / hydroponic towers
//    - High-bay portal clearing STRIDER-M transporter (PORTAL_W = 5.2 m, PORTAL_H = 3.2 m)
//    - Overhead ceiling gantry rail interfacing CORA-M 7-DoF manipulator for dual crop/wall maintenance
//    - Explicit exclusion of insect farming per plans/SPACE_FLOURISHING_FRAMEWORK.md
//
// Viewing Modes:
//   view_mode = 0 : Longitudinal Cutaway (revealing internal AMU polyculture sanctum)
//   view_mode = 1 : Full Enclosed Bio-Habitat Envelope
//   view_mode = 2 : Rammed Earth Shell & Catenary Vault Only (Civil Construction Phase)

$fn = 48;

// -----------------------------------------------------------------------------
// Global Parameters
// -----------------------------------------------------------------------------
HAB_L               = 20.0;   // Overall length of earthen habitat structure (m)
HAB_R_INT           = 5.5;    // Internal vault clearance radius (m)
RAMMED_EARTH_WALL_T = 0.55;   // Monolithic rammed-earth wall thickness (550 mm)
ADOBE_VAULT_T       = 0.35;   // Extruded earthen catenary vault thickness (350 mm)
TOTAL_WALL_T        = RAMMED_EARTH_WALL_T + ADOBE_VAULT_T; // 0.90 m composite thermal barrier

FOUNDATION_W        = 14.0;   // Ground footing breadth (m)
FOUNDATION_D        = 1.20;   // Footing depth / grade ballast (m)

PORTAL_W            = 5.20;   // High-bay rover portal width (clears STRIDER-M 4.6 m)
PORTAL_H            = 3.20;   // High-bay rover portal height (m)

CEILING_RAIL_L      = 18.5;   // Overhead ceiling rail span (m)
CEILING_RAIL_W      = 0.60;   // Rail carriage width (m)
CEILING_RAIL_H      = 0.25;   // Rail carriage height (m)
CEILING_Z           = HAB_R_INT - 0.35; // Apex ceiling gantry height (5.15 m)

AERO_RACK_H         = 3.80;   // Vertical aeroponic rack height (m)
AERO_RACK_W         = 1.10;   // Rack depth (m)
AERO_RACK_L         = 12.0;   // Cultivation bay length (m)

view_mode           = 0;      // 0 = Cutaway, 1 = Full Exterior, 2 = Civil Shell Only

// Material Aesthetic Palette (Physical Material Simulation)
COL_RAMMED_EARTH    = [0.72, 0.53, 0.38]; // Layered in-situ clay/sand rammed earth
COL_ADOBE_VAULT     = [0.80, 0.62, 0.45]; // Extruded clay/loam catenary arch
COL_FOOTING         = [0.42, 0.40, 0.38]; // Stabilized earthen gravel/aggregate trench
COL_AMU_FRAME       = [0.90, 0.92, 0.94]; // Sterile food-grade insulated composite core
COL_AERO_GREEN      = [0.18, 0.68, 0.32]; // High-yield vertical polyculture crops
COL_RAIL_STEEL      = [0.70, 0.73, 0.78]; // Stainless steel apex gantry rail
COL_PORTAL_GOLD     = [0.85, 0.68, 0.25]; // Airtight biosecure seal portal rim

// -----------------------------------------------------------------------------
// Mathematical Helpers
// -----------------------------------------------------------------------------

// Inverted catenary arch approximation: y = a * cosh(x/a) - a
module catenary_shell(span=11.0, height=5.5, thickness=0.35, length=20.0) {
    // 2D polygon profile extruded along length
    steps = 24;
    dx = span / steps;
    a = (pow(span/2, 2)) / (2 * height); // Parabolic-catenary approximation parameter

    rotate([90, 0, 90])
    linear_extrude(height=length, center=true, convexity=10) {
        // Outer arch polygon minus inner arch
        difference() {
            // Outer profile
            polygon(points = [
                for (i = [-steps/2 : steps/2])
                    let (x = i * dx, y = height + thickness - (pow(x, 2) / (2 * a)))
                    [x, max(0, y)],
                [span/2 + thickness, 0],
                [-(span/2 + thickness), 0]
            ]);
            // Inner profile
            polygon(points = [
                for (i = [-steps/2 : steps/2])
                    let (x = i * dx, y = height - (pow(x, 2) / (2 * a)))
                    [x, max(-0.1, y)],
                [span/2, -0.1],
                [-span/2, -0.1]
            ]);
        }
    }
}

// -----------------------------------------------------------------------------
// Component Modules
// -----------------------------------------------------------------------------

// 1. Grade Foundation & Thermal Siphon Footings
module earthen_foundation() {
    color(COL_FOOTING) {
        translate([0, 0, -FOUNDATION_D/2])
            cube([FOUNDATION_W, HAB_L + 1.6, FOUNDATION_D], center=true);
        // Thermal siphon / permafrost anchor pilings
        for (x = [-FOUNDATION_W/2 + 0.6, FOUNDATION_W/2 - 0.6]) {
            for (y = [-HAB_L/2 + 1.5 : 3.4 : HAB_L/2]) {
                translate([x, y, -FOUNDATION_D - 1.0])
                    cylinder(r=0.25, h=2.5, center=true);
            }
        }
    }
}

// 2. Continuous Slip-Form Rammed Earth Monolithic Walls & Buttresses (Form Earth)
module rammed_earth_outer_shell() {
    color(COL_RAMMED_EARTH) {
        // Monolithic lateral battered walls
        for (side = [-1, 1]) {
            translate([side * (HAB_R_INT + RAMMED_EARTH_WALL_T/2), 0, HAB_R_INT/2]) {
                cube([RAMMED_EARTH_WALL_T, HAB_L, HAB_R_INT], center=true);
            }
            // Continuous slip-form stepped buttresses (thermal & seismic stabilization)
            for (y = [-HAB_L/2 + 2.0 : 4.0 : HAB_L/2]) {
                translate([side * (HAB_R_INT + RAMMED_EARTH_WALL_T + 0.6), y, HAB_R_INT/3]) {
                    rotate([0, side * -18, 0])
                        cube([1.2, 0.80, HAB_R_INT * 0.8], center=true);
                }
            }
        }
        // Front and Rear Heavy Earthen End-Gables
        for (end = [-1, 1]) {
            translate([0, end * (HAB_L/2 - RAMMED_EARTH_WALL_T/2), HAB_R_INT/2]) {
                difference() {
                    cube([HAB_R_INT * 2 + TOTAL_WALL_T * 2, RAMMED_EARTH_WALL_T, HAB_R_INT], center=true);
                    // Rover Portal cutout at front
                    if (end == 1) {
                        translate([0, 0, -HAB_R_INT/2 + PORTAL_H/2])
                            cube([PORTAL_W, RAMMED_EARTH_WALL_T * 2, PORTAL_H + 0.1], center=true);
                    }
                    // Rear ventilation and sterile utility transfer lock
                    if (end == -1) {
                        translate([0, 0, 0])
                            cylinder(r=1.2, h=RAMMED_EARTH_WALL_T * 2, center=true);
                    }
                }
            }
        }
    }
}

// 3. 3D-Printed Adobe Catenary Vault (Shangrila-VHP #45 RepRap Mechanics)
module adobe_catenary_vault() {
    color(COL_ADOBE_VAULT) {
        translate([0, 0, 0]) {
            catenary_shell(span=HAB_R_INT * 2, height=HAB_R_INT, thickness=ADOBE_VAULT_T, length=HAB_L);
        }
    }
}

// 4. Inner Biosecure AMU Capsule & Polyculture Aeroponic Sanctum
module inner_amu_sanctum() {
    // Insulated sterile hygienic liner
    color(COL_AMU_FRAME) {
        translate([0, 0, -0.05])
            cube([HAB_R_INT * 1.85, HAB_L - 1.2, 0.10], center=true);
    }

    // Overhead Apex Ceiling Gantry Rail (CORA-M 7-DoF transfer line)
    color(COL_RAIL_STEEL) {
        translate([0, 0, CEILING_Z]) {
            // Twin I-beam rail profile
            cube([CEILING_RAIL_W, CEILING_RAIL_L, CEILING_RAIL_H], center=true);
            // Sliding kinematic carriage
            translate([0, 1.5, -0.18])
                cube([CEILING_RAIL_W * 1.3, 1.2, 0.22], center=true);
        }
    }

    // High-Bay Biosecure Portal Frame
    color(COL_PORTAL_GOLD) {
        translate([0, HAB_L/2 - 0.2, PORTAL_H/2]) {
            difference() {
                cube([PORTAL_W + 0.5, 0.40, PORTAL_H + 0.5], center=true);
                cube([PORTAL_W, 0.50, PORTAL_H], center=true);
            }
        }
    }

    // Vertical Aeroponic Cultivation Towers (Polyculture Food Shells)
    color(COL_AERO_GREEN) {
        for (side = [-1, 1]) {
            for (x_offset = [2.2, 3.8]) {
                for (y = [-AERO_RACK_L/2 : 1.4 : AERO_RACK_L/2 - 1.0]) {
                    translate([side * x_offset, y, AERO_RACK_H/2]) {
                        // Vertical aeroponic cylinder / rack
                        cylinder(r=0.45, h=AERO_RACK_H, center=true);
                        // Foliage shelves
                        for (z = [-AERO_RACK_H/2 + 0.6 : 0.8 : AERO_RACK_H/2]) {
                            translate([0, 0, z])
                                cylinder(r=0.65, h=0.15, center=true);
                        }
                    }
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------
// Top-Level Assembly
// -----------------------------------------------------------------------------

module amu_manna_machine_assembly() {
    earthen_foundation();

    if (view_mode == 0) {
        // Longitudinal Cutaway: negative X side cut away for internal inspection
        difference() {
            union() {
                rammed_earth_outer_shell();
                adobe_catenary_vault();
                inner_amu_sanctum();
            }
            // Cutaway bounding volume
            translate([-15, 0, 10])
                cube([30, HAB_L + 5, 25], center=true);
        }
    } else if (view_mode == 1) {
        // Full Exterior Protected Envelope
        rammed_earth_outer_shell();
        adobe_catenary_vault();
        inner_amu_sanctum();
    } else if (view_mode == 2) {
        // Civil Shell Only (Rammed Earth + Adobe Vault)
        rammed_earth_outer_shell();
        adobe_catenary_vault();
    }
}

// Render root assembly
amu_manna_machine_assembly();
