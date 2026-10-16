// wind_v2_nacelle_snow.scad -- Nacelle in Arctic Snow Environment
//
// 3D CAD scene showing the Wind v2.0 Arctic Direct-Drive Nacelle
// installed in harsh Arctic conditions with wind-blown sastrugi snow drifts,
// rime frost buildup around the mast trunk, snow-deflecting labyrinth louvers,
// and the aerodynamic composite cowl.
//
// Tracked under Issue #87 & Parent Issue #82

$fn = 48;

use <wind_v2_nacelle.scad>

module arctic_snow_terrain() {
    // Vast wind-blown permafrost snowfield
    color([0.94, 0.96, 0.99]) {
        translate([0, 0, -450])
        difference() {
            cube([16000, 16000, 300], center=true);
            // Sastrugi snow drift ridges sculpted by prevailing Arctic winds
            for (dx = [-5000 : 2000 : 5000]) {
                translate([dx, 0, 140])
                rotate([0, 10, 15])
                cube([1100, 17000, 80], center=true);
            }
        }
    }

    // Packed rime frost and snow apron banked around the mast trunk
    color([0.88, 0.92, 0.96, 0.9]) {
        for (a = [0 : 30 : 330]) {
            rotate([0, 0, a])
            translate([460, 0, -320])
            scale([1.8, 1.2, 0.5])
            sphere(d=420);
        }
    }

    // Frost particles / ice accretion caps on cowl ridges
    color([0.96, 0.98, 1.0, 0.8]) {
        translate([50, 0, 1500])
        scale([1.1, 0.7, 0.1])
        sphere(d=1800);
    }
}

// 1. Arctic snowfield environment
arctic_snow_terrain();

// 2. Direct-drive nacelle tophead assembly
// cowl_mode = 0 renders full protective aerodynamic composite cowl with snow louvers
cowl_mode = 0;
wind_v2_nacelle_assembly();
