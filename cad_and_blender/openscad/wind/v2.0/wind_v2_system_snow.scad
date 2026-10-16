// wind_v2_system_snow.scad -- Full Arctic Wind v2.0 System in Operational Snow Scene
//
// Complete 3D CAD scene showing the fully erected 50 kW turbine operating in an
// Arctic blizzard/permafrost terrain:
// - 20 ft ISO foundation container with deployed leveling outriggers seated in snow
// - 24 m modular tubular steel mast reaching vertical operational height
// - Direct-drive PMSG nacelle with aerodynamic cowl and snow louvers
// - Complete 26 m diameter 3-bladed sectional rotor rotating in wind stream
// - Sastrugi snowdrifts, frozen ground pad, and high-visibility anti-icing leading edges
//
// Tracked under Issue #82 (Parent Roadmap)

$fn = 32;

use </vms_and_github/Github/asi.surge.sh/cad_and_blender/openscad/wind/v2.0/wind_v2_mast_erection.scad>
use </vms_and_github/Github/asi.surge.sh/cad_and_blender/openscad/wind/v2.0/wind_v2_nacelle.scad>

// Ground Snowfield with sastrugi wind ripples
module arctic_vast_snowscape() {
    color([0.94, 0.96, 0.99]) {
        translate([4000, 0, -200])
        difference() {
            cube([36000, 24000, 400], center=true);
            // Sastrugi snow drift ridges
            for (dx = [-14000 : 3500 : 16000]) {
                translate([dx, 0, 190])
                rotate([0, 10, 20])
                cube([1800, 28000, 90], center=true);
            }
        }
    }

    // Packed snow bank around container base
    color([0.88, 0.92, 0.96, 0.9]) {
        for (a = [0 : 45 : 315]) {
            rotate([0, 0, a])
            translate([3500, 0, 50])
            scale([2.5, 1.2, 0.6])
            sphere(d=1200);
        }
    }
}

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
    for (ang = [0, 120, 240]) {
        rotate([ang + 15, 0, 0]) { // Dynamic rotation offset
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
                    translate([-60, -180, blade_len * 0.70])
                    cube([40, 60, blade_len * 0.60], center=true);
                }
            }
        }
    }
}

module complete_arctic_wind_system() {
    // 1. Natural terrain
    arctic_vast_snowscape();

    // 2. 20 ft ISO Container foundation (Package 1)
    color([0.18, 0.19, 0.21]) {
        translate([-6058/2 + 500, 0, 2591/2])
        cube([6058, 2438, 2591], center=true);
    }

    // Foundation outriggers extended into snow
    color([0.85, 0.55, 0.15]) {
        for (dx = [-2600, 2600]) {
            for (dy = [-1800, 1800]) {
                translate([dx, dy, 150]) {
                    cube([300, 1200, 200], center=true);
                    translate([0, (dy > 0 ? 600 : -600), -100])
                    cylinder(d=450, h=100);
                }
            }
        }
    }

    // 3. Upright 24 m modular tubular steel mast (Package 2)
    translate([0, 0, 2591 + 35]) {
        // Mast column
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

        // Guy wires stabilizing upper tower
        color([0.4, 0.45, 0.5, 0.7]) {
            for (g_ang = [45, 135, 225, 315]) {
                hull() {
                    translate([0, 0, 18000]) sphere(d=30);
                    translate([18000 * cos(g_ang), 18000 * sin(g_ang), -2500]) sphere(d=50);
                }
            }
        }

        // 4. Nacelle tophead (Package 3)
        translate([0, 0, 24000]) {
            // Yaw interface & bedplate
            color([0.35, 0.38, 0.42])
            cylinder(d=680, h=160, center=true);

            // Aerodynamic cowl with snow louvers
            color([0.94, 0.95, 0.98]) {
                translate([400, 0, 790])
                scale([1.1, 0.75, 0.8])
                sphere(d=2200);

                // Rear cooling snow louvers
                translate([-600, 0, 950])
                for (lz = [-100 : 40 : 100]) {
                    translate([0, 0, lz])
                    cube([240, 650, 14], center=true);
                }
            }

            // 5. Sectional Rotor Assembly (Package 4)
            translate([1700, 0, 790])
            full_operational_rotor();
        }
    }
}

complete_arctic_wind_system();
