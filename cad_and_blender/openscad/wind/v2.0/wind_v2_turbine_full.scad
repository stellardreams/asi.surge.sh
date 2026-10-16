// wind_v2_turbine_full.scad -- Full Wind v2.0 Operational 50 kW Wind Turbine Architecture
//
// Complete 3D CAD engineering model showing the fully erected 50 kW modular wind turbine:
// - Package 1: 20 ft ISO container foundation footing with 4x extended structural outriggers & anchor pads
// - Package 2: 24 m modular tubular steel mast (Ø508 mm) with flanged joints & 4-point guy wire rigging
// - Package 3: Arctic direct-drive PMSG nacelle tophead with aerodynamic composite cowl & cooling louvers
// - Package 4: 26 m diameter 3-bladed sectional composite rotor with high-visibility anti-icing leading edges
//
// Animation Parameterization:
// - Driven by OpenSCAD `$t` variable ($t: 0 -> 1 sweeps 0 -> 360 deg blade rotation).
// - Rated operational speed: 65 RPM direct-drive (tip speed 88.5 m/s at 26 m diameter).
// - Headless render command:
//     scripts/render_turbine_animation.sh --view landscape
//     scripts/render_turbine_animation.sh --view hero
//
// Tracked under Issue #82 (Parent Program Architecture)

$fn = 32;

use </vms_and_github/Github/asi.surge.sh/cad_and_blender/openscad/wind/v2.0/wind_v2_mast_erection.scad>
use </vms_and_github/Github/asi.surge.sh/cad_and_blender/openscad/wind/v2.0/wind_v2_nacelle.scad>

// Full 26 m 3-bladed rotor assembly with realistic chord taper and anti-icing edges
module full_operational_rotor() {
    rotor_dia = 26000;
    blade_len = 12000;

    // Central hub spinner
    color([0.85, 0.3, 0.2]) {
        rotate([0, 90, 0])
        cylinder(d=1200, h=700, center=true);
        translate([450, 0, 0])
        rotate([0, 90, 0])
        cylinder(d1=1200, d2=200, h=600);
    }

    // 3 Aerodynamic blades spaced 120 deg
    // Parameterized with $t (animation time 0 -> 1) for dynamic rotation (360 deg per full cycle)
    rot_offset = $t * 360;
    for (ang = [0, 120, 240]) {
        rotate([ang + rot_offset, 0, 0]) { // Dynamic rotation driven by $t
            translate([200, 0, 0]) {
                // Main blade shell
                color([0.93, 0.95, 0.97]) {
                    hull() {
                        translate([0, 0, 600])
                        rotate([0, 90, 0])
                        scale([1.0, 0.22, 1.0])
                        cylinder(d=950, h=180, center=true);

                        translate([0, 0, blade_len])
                        rotate([0, 90, 0])
                        scale([1.0, 0.14, 1.0])
                        cylinder(d=420, h=90, center=true);
                    }
                }
                // High-visibility orange anti-icing leading edge (outer 60% span)
                color([0.95, 0.45, 0.1]) {
                    hull() {
                        translate([0, -950*0.22/2 * 0.70, blade_len * 0.40])
                        rotate([0, 90, 0])
                        scale([1.05, 0.25, 1.05])
                        cylinder(d=280, h=185, center=true);

                        translate([0, -420*0.14/2, blade_len])
                        rotate([0, 90, 0])
                        scale([1.05, 0.18, 1.05])
                        cylinder(d=180, h=95, center=true);
                    }
                }
            }
        }
    }
}

module complete_arctic_wind_system() {
    // 1. 20 ft ISO Container foundation (Package 1)
    // Matte dark charcoal shell with corner castings
    cont_cx = -6058/2 + 500;
    cont_cy = 0;
    cont_cz = 2591/2;

    color([0.18, 0.19, 0.21]) {
        translate([cont_cx, cont_cy, cont_cz])
        cube([6058, 2438, 2591], center=true);
    }

    // Foundation structural outriggers extended for overturning stability
    color([0.85, 0.55, 0.15]) {
        for (x_sign = [-1, 1]) {
            for (y_sign = [-1, 1]) {
                ext_dist = 1200;
                ox = cont_cx + x_sign * (6058/2 - 400);
                oy = cont_cy + y_sign * (2438/2 + ext_dist/2);
                translate([ox, oy, 150]) {
                    cube([300, ext_dist, 200], center=true);
                    translate([0, y_sign * (ext_dist/2 - 100), -100])
                    cylinder(d=450, h=100);
                }
            }
        }
    }

    // 2. Upright 24 m modular tubular steel mast (Package 2)
    translate([0, 0, 2591 + 35]) {
        // Mast column (Ø508 mm)
        color([0.88, 0.90, 0.93]) {
            difference() {
                cylinder(d=508, h=24000);
                cylinder(d=492, h=24002, center=true);
            }
            // Flanged segment joints every 4.8 m
            for (z = [4800 : 4800 : 23900]) {
                translate([0, 0, z])
                cylinder(d=660, h=40, center=true);
            }
        }

        // 4-Point Guy wires stabilizing upper tower
        color([0.4, 0.45, 0.5, 0.7]) {
            for (g_ang = [45, 135, 225, 315]) {
                hull() {
                    translate([0, 0, 18000]) sphere(d=30);
                    translate([18000 * cos(g_ang), 18000 * sin(g_ang), -2500]) sphere(d=50);
                }
            }
        }

        // 3. Nacelle tophead (Package 3)
        translate([0, 0, 24000]) {
            // Yaw interface & bedplate
            color([0.35, 0.38, 0.42])
            cylinder(d=680, h=160, center=true);

            // Aerodynamic cowl with cooling louvers
            color([0.94, 0.95, 0.98]) {
                translate([400, 0, 790])
                scale([1.1, 0.75, 0.8])
                sphere(d=2200);

                // Rear cooling louvers
                translate([-600, 0, 950])
                for (lz = [-100 : 40 : 100]) {
                    translate([0, 0, lz])
                    cube([240, 650, 14], center=true);
                }
            }

            // 4. Sectional Rotor Assembly (Package 4)
            translate([1700, 0, 790])
            full_operational_rotor();
        }
    }
}

complete_arctic_wind_system();
