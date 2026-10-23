// amu_manna_machine_envelope_v1.scad -- 🏺 The New Manna Machine (Automated Earthen Bio-Habitat)
//
// Engineering & CAD Specifications:
// - Version: v1.1 (Autonomous Food Production & Crop Cultivation Systems)
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
//    - Passive solar fiber-optic / light-pipe penetrations along vault apex
// 3. Autonomous Controlled-Environment Food Production Core (Polyculture Sanctum):
//    - Multi-Tier Aeroponic Mist Columns (micro-tubers/potatoes, high-protein legumes/beans, leafy greens)
//    - Full-spectrum horticultural LED luminaire arrays (tunable photosynthetic spectra)
//    - Closed-loop transpiration water recovery condenser coils & air recirculation fans
//    - Sub-floor automated nutrient dosing reservoirs, pumps, and EC/pH balancing manifolds
//    - High-bay portal clearing STRIDER-M transporter (PORTAL_W = 5.2 m, PORTAL_H = 3.2 m)
//    - Overhead ceiling gantry rail interfacing CORA-M 7-DoF manipulator with acoustic buzz-pollination toolhead
//    - Explicit exclusion of insect farming per plans/SPACE_FLOURISHING_FRAMEWORK.md
//
// Viewing Modes:
//   view_mode = 0 : Longitudinal Cutaway (revealing internal AMU polyculture food core)
//   view_mode = 1 : Full Enclosed Bio-Habitat Envelope
//   view_mode = 2 : Civil Shell Only (Rammed Earth & Adobe Vault)
//   view_mode = 3 : Food Production Infrastructure & Plumbing Only

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

view_mode           = 0;      // 0 = Cutaway, 1 = Full Exterior, 2 = Civil Shell, 3 = Food Core Only

// Material Aesthetic Palette (Physical Material Simulation)
COL_RAMMED_EARTH    = [0.72, 0.53, 0.38]; // Layered in-situ clay/sand rammed earth
COL_ADOBE_VAULT     = [0.80, 0.62, 0.45]; // Extruded clay/loam catenary arch
COL_FOOTING         = [0.42, 0.40, 0.38]; // Stabilized earthen gravel/aggregate trench
COL_AMU_FRAME       = [0.90, 0.92, 0.94]; // Sterile food-grade insulated composite core
COL_AERO_GREEN      = [0.18, 0.68, 0.32]; // High-yield vertical polyculture crops (leafy greens/beans)
COL_TUBER_BROWN     = [0.55, 0.40, 0.25]; // Aeroponic root-zone mist chamber (potatoes/cassava)
COL_LED_PURPLE      = [0.88, 0.20, 0.85]; // Horticultural grow light LEDs (deep red & royal blue)
COL_WATER_CONDENSER = [0.25, 0.55, 0.85]; // Aluminum finned dehumidification & water recovery coils
COL_NUTRIENT_TANK   = [0.15, 0.45, 0.70]; // Closed-loop automated nutrient dosing reservoir
COL_LIGHT_PIPE      = [0.95, 0.95, 0.90]; // Sunlight collection dome & optical fiber pipe
COL_RAIL_STEEL      = [0.70, 0.73, 0.78]; // Stainless steel apex gantry rail
COL_PORTAL_GOLD     = [0.85, 0.68, 0.25]; // Airtight biosecure seal portal rim

// -----------------------------------------------------------------------------
// Mathematical Helpers
// -----------------------------------------------------------------------------

// Inverted catenary arch approximation: y = a * cosh(x/a) - a
module catenary_shell(span=11.0, height=5.5, thickness=0.35, length=20.0) {
    steps = 24;
    dx = span / steps;
    a = (pow(span/2, 2)) / (2 * height);

    rotate([90, 0, 90])
    linear_extrude(height=length, center=true, convexity=10) {
        difference() {
            polygon(points = [
                for (i = [-steps/2 : steps/2])
                    let (x = i * dx, y = height + thickness - (pow(x, 2) / (2 * a)))
                    [x, max(0, y)],
                [span/2 + thickness, 0],
                [-(span/2 + thickness), 0]
            ]);
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

// 1. Grade Foundation, Drainage Trench & Sub-Floor Nutrient Tanks
module earthen_foundation() {
    color(COL_FOOTING) {
        difference() {
            translate([0, 0, -FOUNDATION_D/2])
                cube([FOUNDATION_W, HAB_L + 1.6, FOUNDATION_D], center=true);
            // Recessed sub-floor trench for closed-loop nutrient & drainage plumbing
            translate([0, 0, -0.4])
                cube([4.8, HAB_L - 2.0, 0.85], center=true);
        }
        // Thermal siphon / permafrost anchor pilings
        for (x = [-FOUNDATION_W/2 + 0.6, FOUNDATION_W/2 - 0.6]) {
            for (y = [-HAB_L/2 + 1.5 : 3.4 : HAB_L/2]) {
                translate([x, y, -FOUNDATION_D - 1.0])
                    cylinder(r=0.25, h=2.5, center=true);
            }
        }
    }

    // Sub-Floor Automated Nutrient Reservoirs & Circulation Manifold
    color(COL_NUTRIENT_TANK) {
        for (y = [-4.0, 0.0, 4.0]) {
            translate([0, y, -0.45])
                cube([2.2, 2.4, 0.65], center=true);
        }
        // Dual recirculating plumbing lines running full length
        for (x = [-1.4, 1.4]) {
            translate([x, 0, -0.30])
                rotate([90, 0, 0])
                cylinder(r=0.08, h=HAB_L - 3.0, center=true);
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
                    // Rear ventilation & water condenser portal
                    if (end == -1) {
                        translate([0, 0, 0])
                            cylinder(r=1.2, h=RAMMED_EARTH_WALL_T * 2, center=true);
                    }
                }
            }
        }
    }
}

// 3. 3D-Printed Adobe Catenary Vault with Passive Solar Light-Pipes (Shangrila-VHP #45)
module adobe_catenary_vault() {
    color(COL_ADOBE_VAULT) {
        catenary_shell(span=HAB_R_INT * 2, height=HAB_R_INT, thickness=ADOBE_VAULT_T, length=HAB_L);
    }

    // Solar Fiber-Optic / Light-Pipe Apertures traversing vault apex
    color(COL_LIGHT_PIPE) {
        for (y = [-HAB_L/2 + 2.5 : 2.5 : HAB_L/2 - 2.5]) {
            translate([0, y, HAB_R_INT + ADOBE_VAULT_T/2]) {
                // Outer collector dome
                sphere(r=0.35);
                // Optical transport tube
                cylinder(r=0.18, h=ADOBE_VAULT_T * 1.5, center=true);
                // Internal ceiling diffuser lens
                translate([0, 0, -ADOBE_VAULT_T])
                    cylinder(r=0.30, h=0.08, center=true);
            }
        }
    }
}

// 4. Autonomous Closed-Loop Controlled-Environment Food Production Core
module food_production_subsystems() {
    // Insulated sterile hygienic sub-floor grating & service walkway
    color(COL_AMU_FRAME) {
        translate([0, 0, 0.05])
            cube([HAB_R_INT * 1.85, HAB_L - 1.2, 0.10], center=true);
        // Central robotic / agronomist service walkway
        translate([0, 0, 0.12])
            cube([1.8, HAB_L - 1.6, 0.06], center=true);
    }

    // High-Bay Biosecure Rover Air-Lock Portal
    color(COL_PORTAL_GOLD) {
        translate([0, HAB_L/2 - 0.2, PORTAL_H/2]) {
            difference() {
                cube([PORTAL_W + 0.5, 0.40, PORTAL_H + 0.5], center=true);
                cube([PORTAL_W, 0.50, PORTAL_H], center=true);
            }
        }
    }

    // Overhead Apex Ceiling Gantry Rail with Robotic Buzz-Pollination Toolhead
    color(COL_RAIL_STEEL) {
        translate([0, 0, CEILING_Z]) {
            // Twin structural guide rails
            cube([CEILING_RAIL_W, CEILING_RAIL_L, CEILING_RAIL_H], center=true);
            // Autonomous robotic toolhead carrier
            translate([0, 1.2, -0.22]) {
                cube([CEILING_RAIL_W * 1.3, 1.4, 0.25], center=true);
                // Buzz-pollination acoustic vibrator & inspection NDVI sensor mast
                translate([0, 0, -0.35])
                    cylinder(r=0.08, h=0.50, center=true);
                translate([0, 0, -0.65])
                    sphere(r=0.12);
            }
        }
    }

    // Rear Transpiration Condensers & Dehumidification Water Recovery
    color(COL_WATER_CONDENSER) {
        translate([0, -HAB_L/2 + 0.6, 2.5]) {
            // Cooling fin pack
            cube([3.2, 0.35, 2.4], center=true);
            // Dual high-efficiency centrifugal air recirculation blower cowls
            for (x = [-0.9, 0.9]) {
                translate([x, 0.25, 0])
                    cylinder(r=0.45, h=0.30, center=true);
            }
        }
    }

    // Multi-Tier Aeroponic Polyculture Towers (Left & Right Bays)
    for (side = [-1, 1]) {
        for (x_offset = [2.2, 3.8]) {
            // Suspended Full-Spectrum LED Luminaire Strips (Purple Deep Red + Blue)
            color(COL_LED_PURPLE) {
                translate([side * (x_offset - 0.65), 0, AERO_RACK_H * 0.65]) {
                    rotate([90, 0, 0])
                    cube([0.08, AERO_RACK_H * 0.7, AERO_RACK_L], center=true);
                }
            }

            // Aeroponic Mist Columns
            for (y = [-AERO_RACK_L/2 : 1.4 : AERO_RACK_L/2 - 1.0]) {
                translate([side * x_offset, y, 0]) {
                    // Lower Tier: Root-Zone Aeroponic Mist Chamber (Micro-Tubers/Potatoes)
                    color(COL_TUBER_BROWN) {
                        translate([0, 0, 0.65]) {
                            cylinder(r=0.48, h=1.1, center=true);
                            // Internal high-pressure mist manifold collar
                            translate([0, 0, 0.45])
                                cylinder(r=0.52, h=0.08, center=true);
                        }
                    }
                    // Middle & Upper Tier: High-Calorie Legumes & Leafy Green Crop Canopy
                    color(COL_AERO_GREEN) {
                        translate([0, 0, AERO_RACK_H/2 + 0.4])
                            cylinder(r=0.35, h=AERO_RACK_H - 1.2, center=true);
                        // Rotating tiered crop foliage rings
                        for (z = [1.5 : 0.65 : AERO_RACK_H]) {
                            translate([0, 0, z])
                                cylinder(r1=0.72, r2=0.55, h=0.22, center=true);
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
    if (view_mode == 0) {
        // Longitudinal Cutaway: negative X side cut away for internal inspection
        difference() {
            union() {
                earthen_foundation();
                rammed_earth_outer_shell();
                adobe_catenary_vault();
                food_production_subsystems();
            }
            // Cutaway bounding volume
            translate([-15, 0, 10])
                cube([30, HAB_L + 5, 25], center=true);
        }
    } else if (view_mode == 1) {
        // Full Exterior Protected Envelope
        earthen_foundation();
        rammed_earth_outer_shell();
        adobe_catenary_vault();
        food_production_subsystems();
    } else if (view_mode == 2) {
        // Civil Construction Phase (Foundation + Rammed Earth + Adobe Vault)
        earthen_foundation();
        rammed_earth_outer_shell();
        adobe_catenary_vault();
    } else if (view_mode == 3) {
        // Pure Food Production Core & Environmental Life Support Loop
        earthen_foundation();
        food_production_subsystems();
    }
}

// Render root assembly
amu_manna_machine_assembly();
