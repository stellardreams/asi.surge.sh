// playground_strider_fleet_windfarm_v1.scad -- AMU-Surface Playground Scene 3: 100+ Wind Turbine Macro-Grid (v1.1)
//
// Version Control & Engineering Audit:
// - Version: v1.1 (Macro-Grid & Full Fleet Scaling)
// - Tracked Under: Issue #97 (Parent #81, Cross-ref #82, #85, #86, #88)
// - Operational Role: Demonstrates the multi-rover Arctic wind turbine fleet erection workflow
//   scaled to a 100+ unit (5.0 MW) macro-grid deployment across polar permafrost.
//
// Mathematical Fleet Balance (from wind_farm_fleet_sizing_audit.py):
//   - Turbines: 100 units (10 x 10 grid, 50 kW each = 5.0 MW total capacity)
//   - AMU-Surface Habitat: 4 modules arranged as central Quad-Command Superhub (1 AMU : 25 Turbines)
//   - STRIDER-M Rovers: 24 active units (1 Rover : 4.2 Turbines)
//       * 8 x CORA-M Erector/Crane Rovers (Station assembly & root bolt torquing)
//       * 12 x Overland Logistics Haulers with heavy Arctic Cargo Sleds (continuous component supply lines)
//       * 4 x Surveyor / Guy-Wire Tensioner Scouts (site prep and bus commissioning)
//   - CORA-M Manipulators: 10 units (8 active field cranes, 2 depot gantry units)
//
// Animation Timeline ($t in [0.0, 1.0]):
//   - Continuous rotation of commissioned turbine rotors across the field.
//   - Dual logistic convoy transit (outbound loaded sleds and return empty sleds).
//   - Dynamic mast hoisting and CORA-M blade alignment across active construction sectors.
//
// Units: OpenSCAD model units (1 unit ~ 1 meter)

$fn = 16; // Optimized for rendering 100+ complex assets smoothly

// -----------------------------------------------------------------------------
// Parameters & Geometry
// -----------------------------------------------------------------------------
CONT_L          = 6.06;
CONT_W          = 2.44;
CONT_H          = 2.59;
MAST_L          = 24.0;
ROTOR_R         = 9.6;

// Animation variable
t_override      = undef;
anim_t          = is_undef(t_override) ? $t : t_override;

function ease(v) = (1 - cos(180 * v)) / 2;

// Fleet kinematics
rotor_rot_fast  = anim_t * 360 * 2;
hauler_x_out    = -80.0 + 160.0 * anim_t;
hauler_x_ret    = 80.0 - 160.0 * anim_t;

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
COL_SLED        = [0.28, 0.30, 0.33];
COL_PERMAFROST  = [0.75, 0.78, 0.82];
COL_HAB_SHELL   = [0.86, 0.88, 0.90];
COL_HAB_FRAME   = [0.22, 0.24, 0.26];
COL_FRAME       = [0.22, 0.24, 0.26];
COL_THERMAL_PAD = [0.35, 0.37, 0.40]; // DimGray
COL_STEEL_GREY  = [0.65, 0.68, 0.72]; // Metallic steel
COL_STRUT_DARK  = [0.20, 0.28, 0.30]; // DarkSlateGray

// -----------------------------------------------------------------------------
// Modular Component: Low-Poly Lightweight 50 kW Turbine
// -----------------------------------------------------------------------------
module macro_wind_turbine(stage="operating", phase_deg=0) {
    // stage: "operating" (mast up, spinning), "erecting" (mast tilting), "unpacked" (container on pad)
    
    // 5. Thermal Break Footing Pad underneath container base
    color(COL_THERMAL_PAD) {
        translate([0, 0, 0.05]) cube([CONT_L + 0.2, CONT_W + 0.2, 0.10], center=true);
    }

    // ISO container foundation
    color(COL_CONTAINER) {
        translate([0, 0, CONT_H/2 + 0.10]) cube([CONT_L, CONT_W, CONT_H], center=true);
    }

    // 1. Symmetrical Outriggers (4 symmetrical feet: 2 front, 2 rear)
    // 2. Ice-Screw Anchor Pins with hex flange and shaft extending below z=0
    // 5. Thermal Break Footing Pads under each circular pad
    color(COL_OUTRIGGER) {
        for (ox = [-CONT_L/2 + 0.6, CONT_L/2 - 0.6]) {
            for (oy = [-1, 1]) {
                translate([ox, oy * (CONT_W/2 + 1.0), 0.2]) {
                    // Outrigger box beam
                    cube([0.5, 2.0, 0.3], center=true);
                    
                    // Circular footpad
                    translate([0, oy * 0.8, -0.15]) {
                        cylinder(h=0.22, r=0.42, center=true);
                        
                        // 5. Thermal pad
                        color(COL_THERMAL_PAD)
                            translate([0, 0, -0.16]) cylinder(h=0.10, r=0.45, center=true);

                        // 2. Ice-screw anchor pin
                        color(COL_STEEL_GREY) {
                            translate([0, 0, 0.12]) cylinder(h=0.06, r=0.16, center=true, $fn=6);
                            translate([0, 0, -0.25]) cylinder(h=0.85, r=0.06, center=true, $fn=8);
                        }
                    }
                }
            }
        }
    }

    hinge_x = CONT_L/2 - 0.5;
    hinge_z = CONT_H + 0.10;
    mast_r  = 0.50; // Average base radius

    // 4. Triangulated Bracing Struts
    color(COL_STRUT_DARK) {
        // Strut 1: angled toward box center (-X)
        hull() {
            translate([hinge_x, 0, hinge_z + mast_r * 2.5]) sphere(r=mast_r * 0.35);
            translate([hinge_x - 2.0, 0, CONT_H + 0.10 + 0.1]) sphere(r=mast_r * 0.35);
        }
        // Strut 2: angled toward front-left corner (+Y)
        hull() {
            translate([hinge_x, 0, hinge_z + mast_r * 2.5]) sphere(r=mast_r * 0.35);
            translate([hinge_x + 0.4, CONT_W/2 - 0.25, CONT_H + 0.10 + 0.1]) sphere(r=mast_r * 0.35);
        }
        // Strut 3: angled toward front-right corner (-Y)
        hull() {
            translate([hinge_x, 0, hinge_z + mast_r * 2.5]) sphere(r=mast_r * 0.35);
            translate([hinge_x + 0.4, -CONT_W/2 + 0.25, CONT_H + 0.10 + 0.1]) sphere(r=mast_r * 0.35);
        }
        // Deck mounting blocks
        translate([hinge_x - 2.0, 0, CONT_H + 0.10 + 0.1]) cube([0.4, 0.4, 0.2], center=true);
        translate([hinge_x + 0.4, CONT_W/2 - 0.25, CONT_H + 0.10 + 0.1]) cube([0.4, 0.4, 0.2], center=true);
        translate([hinge_x + 0.4, -CONT_W/2 + 0.25, CONT_H + 0.10 + 0.1]) cube([0.4, 0.4, 0.2], center=true);
    }

    if (stage == "operating") {
        // Fully erected vertical mast & spinning rotor
        translate([hinge_x, 0, hinge_z]) {
            // 3. Reinforced Mast Trunnion Collar & Clevis
            color(COL_FRAME) {
                cylinder(h=mast_r * 3.5, r=mast_r * 1.45, center=false, $fn=16);
                for (side = [-1, 1]) {
                    translate([0, side * (mast_r * 1.45 + 0.05), (mast_r * 3.5)/2])
                        cube([mast_r * 2.2, 0.10, mast_r * 3.2], center=true);
                }
            }
            // Red mechanical cross lock-pin
            color("Red") {
                translate([0, 0, (mast_r * 3.5)/2])
                    rotate([90, 0, 0]) cylinder(h=mast_r * 3.8, r=0.08, center=true);
            }

            color(COL_MAST) {
                translate([0, 0, MAST_L/2]) cylinder(h=MAST_L, r1=0.60, r2=0.40, center=true);
            }
            // Nacelle & Rotor
            translate([0, 0, MAST_L]) {
                color(COL_CONTAINER) translate([0.5, 0, 0]) cube([1.6, 1.0, 1.0], center=true);
                translate([1.3, 0, 0]) {
                    color(COL_ROTOR) sphere(r=0.55);
                    rotate([rotor_rot_fast + phase_deg, 0, 0]) {
                        for (a = [0, 120, 240]) {
                            rotate([a, 0, 0]) {
                                color(COL_ROTOR) translate([0, ROTOR_R/2, 0]) cube([0.2, ROTOR_R, 0.45], center=true);
                                color(COL_ORANGE_EDGE) translate([0, ROTOR_R - 0.4, 0]) cube([0.22, 0.8, 0.48], center=true);
                            }
                        }
                    }
                }
            }
        }
    } else if (stage == "erecting") {
        // Tilted mast in active assembly (e.g. 35 deg angle)
        tilt = 35 + 10 * sin(anim_t * 360);
        translate([hinge_x, 0, hinge_z]) {
            // 3. Reinforced Mast Trunnion Collar & Clevis
            color(COL_FRAME) {
                cylinder(h=mast_r * 3.5, r=mast_r * 1.45, center=false, $fn=16);
                for (side = [-1, 1]) {
                    translate([0, side * (mast_r * 1.45 + 0.05), (mast_r * 3.5)/2])
                        cube([mast_r * 2.2, 0.10, mast_r * 3.2], center=true);
                }
            }
            color("Red") {
                translate([0, 0, (mast_r * 3.5)/2])
                    rotate([90, 0, 0]) cylinder(h=mast_r * 3.8, r=0.08, center=true);
            }

            rotate([0, 90 - tilt, 0]) {
                color(COL_MAST) translate([0, 0, MAST_L/2]) cylinder(h=MAST_L, r1=0.60, r2=0.40, center=true);
                translate([0, 0, MAST_L]) {
                    color(COL_CONTAINER) translate([0.5, 0, 0]) cube([1.6, 1.0, 1.0], center=true);
                    translate([1.3, 0, 0]) {
                        color(COL_ROTOR) sphere(r=0.55);
                        for (a = [0, 120]) {
                            rotate([a, 0, 0]) color(COL_ROTOR) translate([0, ROTOR_R/2, 0]) cube([0.2, ROTOR_R, 0.45], center=true);
                        }
                    }
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------
// Modular Component: Lightweight STRIDER Rover
// -----------------------------------------------------------------------------
module macro_strider(with_cora=false, with_sled=false) {
    // Chassis
    color(COL_ROVER) {
        translate([0, 0, 0.7]) cube([5.2, 2.6, 0.6], center=true);
        translate([1.8, 0, 1.1]) cylinder(h=0.3, r=0.22, center=true);
    }
    // Tracks
    color(COL_TRACK) {
        for (y_side = [-1, 1]) {
            translate([0, y_side * 1.7, 0.45]) cube([5.6, 0.65, 0.55], center=true);
        }
    }
    // CORA-M Arm
    if (with_cora) {
        translate([0.6, 0, 1.0]) {
            color(COL_ARM_WHITE) cylinder(h=0.3, r=0.3, center=false);
            translate([0, 0, 0.3]) rotate([0, 25, 0]) {
                color(COL_ARM_BLUE) translate([0, 0, 0.8]) cube([0.25, 0.3, 1.6], center=true);
                translate([0, 0, 1.6]) rotate([0, 35, 0]) {
                    color(COL_ARM_WHITE) translate([0, 0, 0.7]) cube([0.2, 0.25, 1.4], center=true);
                    color(COL_GOLD) translate([0, 0, 1.5]) cube([0.15, 0.4, 0.3], center=true);
                }
            }
        }
    }
    // Towed Arctic Cargo Sled
    if (with_sled) {
        translate([-5.6, 0, 0]) {
            color(COL_SLED) {
                translate([0, 0, 0.35]) cube([5.4, 2.4, 0.25], center=true);
                for (ys = [-1, 1]) translate([0, ys * 1.05, 0.15]) cube([5.8, 0.3, 0.15], center=true);
            }
            // Sled Payload (mast segments & blade racks)
            color(COL_MAST) translate([0, 0, 0.75]) rotate([0, 90, 0]) cylinder(h=4.6, r=0.45, center=true);
            color(COL_CONTAINER) translate([1.4, 0, 0.95]) cube([1.2, 1.2, 0.8], center=true);
        }
    }
}

// -----------------------------------------------------------------------------
// Central AMU Quad-Command Superhub (4 Modules in Cross Arrangement)
// -----------------------------------------------------------------------------
module central_amu_quad_superhub() {
    // 4 AMU vaulted habitat modules docking into central distribution nexus
    for (ang = [0, 90, 180, 270]) {
        rotate([0, 0, ang]) {
            translate([11.0, 0, 0]) {
                difference() {
                    color(COL_HAB_SHELL) {
                        rotate([0, 90, 0]) cylinder(h=14, r=5.0, center=true);
                    }
                    translate([0, 0, -5.0]) cube([16, 12, 10], center=true);
                }
                color(COL_HAB_FRAME) translate([0, 0, 0.2]) cube([14.4, 10.4, 0.4], center=true);
            }
        }
    }
    // Central Comm & Command Dome
    color(COL_HAB_FRAME) cylinder(h=1.2, r=6.5, center=true);
    color(COL_HAB_SHELL) translate([0, 0, 0.6]) sphere(r=4.8);
    // Microgrid Central Substation / Battery Storage Bank
    for (bx = [-4, 4]) {
        for (by = [-4, 4]) {
            color(COL_CONTAINER) translate([bx * 2.8, by * 2.8, 1.3]) cube([4.2, 2.2, 2.4], center=true);
        }
    }
}

// -----------------------------------------------------------------------------
// Main Scene: 100+ Windmill Arctic Macro-Grid Assembly
// -----------------------------------------------------------------------------
module arctic_windfarm_100_macrogrid() {
    // Permafrost macro-terrain (300 m x 300 m visible envelope)
    color(COL_PERMAFROST) {
        translate([0, 0, -0.4]) cube([320, 320, 0.8], center=true);
    }

    // Central Quad-AMU Superhub
    central_amu_quad_superhub();

    // 10 x 10 Grid of 50 kW Wind Turbines (100 Turbines Total)
    // Grid spacing: dx = 26 m, dy = 26 m
    for (ix = [-4.5 : 1 : 4.5]) {
        for (iy = [-4.5 : 1 : 4.5]) {
            tx = ix * 26.0;
            ty = iy * 26.0;
            
            // Exclude central footprint reserved for AMU Quad-Superhub
            if (abs(tx) > 22 || abs(ty) > 22) {
                // Determine stage: majority operating, specific sectors under active erection
                is_erecting = (ix == 1.5 && iy == 2.5) || (ix == -2.5 && iy == 1.5) || 
                              (ix == 3.5 && iy == -1.5) || (ix == -1.5 && iy == -3.5);
                st = is_erecting ? "erecting" : "operating";
                phase = (abs(ix * 37 + iy * 53)) % 360;

                translate([tx, ty, 0]) {
                    macro_wind_turbine(stage=st, phase_deg=phase);

                    // If under active erection, place an Erector STRIDER with CORA-M
                    if (is_erecting) {
                        translate([6.5, 3.2, 0]) rotate([0, 0, 140]) {
                            macro_strider(with_cora=true, with_sled=false);
                        }
                    }
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // Mobile STRIDER Task Forces (Logistics Shuttles & Surveyors)
    // -------------------------------------------------------------------------
    
    // East-West Main Arterial Highway (Convoy 1 - Outbound Loaded)
    translate([hauler_x_out, 35, 0]) {
        rotate([0, 0, 0]) macro_strider(with_cora=false, with_sled=true);
    }
    translate([hauler_x_out - 14, 35, 0]) {
        rotate([0, 0, 0]) macro_strider(with_cora=false, with_sled=true);
    }

    // East-West Secondary Arterial Highway (Convoy 2 - Inbound Returning)
    translate([hauler_x_ret, -35, 0]) {
        rotate([0, 0, 180]) macro_strider(with_cora=false, with_sled=false);
    }
    translate([hauler_x_ret + 14, -35, 0]) {
        rotate([0, 0, 180]) macro_strider(with_cora=false, with_sled=true);
    }

    // North-South Arterial Highway (Convoy 3 - Cross-Sector Supply)
    translate([38, hauler_x_out * 0.7, 0]) {
        rotate([0, 0, 90]) macro_strider(with_cora=false, with_sled=true);
    }

    // Active Surveyor Scouts
    translate([65, -55, 0]) rotate([0, 0, 45]) macro_strider(with_cora=false, with_sled=false);
    translate([-60, 58, 0]) rotate([0, 0, -120]) macro_strider(with_cora=false, with_sled=false);
    translate([-70, -60, 0]) rotate([0, 0, 30]) macro_strider(with_cora=false, with_sled=false);
}

// Render root
arctic_windfarm_100_macrogrid();
