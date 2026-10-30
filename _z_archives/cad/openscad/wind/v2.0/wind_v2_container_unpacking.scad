// wind_v2_container_unpacking.scad -- Wind v2.0: Multi-Stage Container Unpacking & Field Deployment
//
// Parametric 3D CAD model of the complete field deployment sequence from
// sealed 20 ft ISO container to assembled ground hardware ready for tilt-up lift.
//
// Normalized deployment stage parameter:
// stage = 0.00 : Sealed container seated on permafrost with leveling outriggers
// stage = 0.25 : Rear double cargo doors swing open 270 deg against container flanks
// stage = 0.50 : Overhead monorail hoist extends; nacelle and electrical skid roll out
// stage = 0.75 : Modular mast segments extracted from bunks and aligned on container roof
// stage = 1.00 : Gin-pole A-frame pinned at 90 deg and winch cable rigged (ready for erection)
//
// Units: millimeters (mm)
// Tracked under Issue #88 & Parent Issue #82

$fn = 32;

// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------
stage = 0.50; // [0.00 : 0.01 : 1.00]

box_l = 5898; // ISO internal length
box_w = 2352; // ISO internal width
box_h = 2393; // ISO internal height

door_thick = 60;
door_w = (box_w - 40) / 2;
door_h = box_h - 40;

// Sub-stage helper functions
function clamp(val, min_v, max_v) = max(min_v, min(val, max_v));
function sub_stage(s, s_min, s_max) = clamp((s - s_min) / (s_max - s_min), 0.0, 1.0);

// Stage timelines:
// 1. Outriggers extend: stage 0.00 -> 0.20
s_outriggers = sub_stage(stage, 0.00, 0.20);

// 2. Doors open (0 to 270 deg): stage 0.15 -> 0.40
s_doors = sub_stage(stage, 0.15, 0.40);
door_angle = s_doors * 270;

// 3. Monorail extension & nacelle roll-out: stage 0.35 -> 0.65
s_nacelle = sub_stage(stage, 0.35, 0.65);

// 4. Mast sections roof assembly: stage 0.60 -> 0.85
s_mast = sub_stage(stage, 0.60, 0.85);

// 5. Gin-pole erection to 90 deg: stage 0.80 -> 1.00
s_gin = sub_stage(stage, 0.80, 1.00);

// -----------------------------------------------------------------------------
// Modules
// -----------------------------------------------------------------------------

module permafrost_ground_pad() {
    // Snow / frozen gravel terrain
    color([0.88, 0.90, 0.92, 0.7])
    translate([3000, 0, -box_h/2 - 250])
    cube([22000, 10000, 100], center=true);
}

module container_body() {
    // Solar-absorptive matte dark charcoal container shell
    color([0.18, 0.19, 0.21, 0.85]) {
        difference() {
            cube([box_l + 160, box_w + 120, box_h + 160], center=true);
            cube([box_l, box_w, box_h], center=true);
            // Rear door opening cut
            translate([box_l/2, 0, 0])
            cube([300, box_w - 20, box_h - 20], center=true);
            // Side cutaway for interior visibility
            translate([0, box_w/2, 0])
            cube([box_l - 600, 200, box_h - 400], center=true);
        }
    }
    // Structural corner castings & posts
    color([0.35, 0.35, 0.38]) {
        for (x = [-box_l/2, box_l/2]) {
            for (y = [-box_w/2, box_w/2]) {
                translate([x, y, 0])
                cube([140, 140, box_h + 160], center=true);
            }
        }
    }
}

module leveling_outriggers() {
    // Heavy telescoping foundation outriggers with screw jacks
    color([0.85, 0.55, 0.15]) { // High-vis industrial yellow
        for (x_sign = [-1, 1]) {
            for (y_sign = [-1, 1]) {
                ext_dist = s_outriggers * 1200;
                translate([x_sign * (box_l/2 - 400), y_sign * (box_w/2 + ext_dist/2), -box_h/2 + 60]) {
                    // Telescoping box arm
                    cube([220, ext_dist + 20, 120], center=true);
                    // Ground screw foot pad
                    translate([0, y_sign * ext_dist/2, -150 * s_outriggers]) {
                        cylinder(d=380, h=40, center=true);
                        cylinder(d=80, h=260, center=true);
                    }
                }
            }
        }
    }
}

module container_rear_doors() {
    // Left & right rear cargo doors swinging open
    color([0.16, 0.17, 0.19]) {
        // Left Door (hinged at y = -box_w/2)
        translate([box_l/2 + 70, -box_w/2 + 20, 0])
        rotate([0, 0, -door_angle])
        translate([0, door_w/2, 0])
        cube([door_thick, door_w, door_h], center=true);

        // Right Door (hinged at y = +box_w/2)
        translate([box_l/2 + 70, box_w/2 - 20, 0])
        rotate([0, 0, door_angle])
        translate([0, -door_w/2, 0])
        cube([door_thick, door_w, door_h], center=true);
    }
}

module overhead_crane_monorail() {
    // Internal I-beam monorail extending out the rear doors
    rail_ext = s_nacelle * 2800;
    color([0.85, 0.55, 0.15]) {
        translate([box_l/2 - 2000 + rail_ext/2, 0, box_h/2 - 100])
        cube([4000 + rail_ext, 120, 180], center=true);

        // Hoist trolley traveler
        translate([box_l/2 + rail_ext - 300, 0, box_h/2 - 240])
        cube([350, 260, 140], center=true);
    }
}

module deploying_nacelle_and_skid() {
    // Nacelle tophead travels out on the monorail and lands cleanly on ground sleeper cribbing
    slide_x = s_nacelle * 3600;
    // Stowed inside container at Z = -box_h/2 + 750.
    // Bottom of skid is at -650 - 70 = -720 mm relative to nacelle center.
    // Ground plane is at Z = -box_h/2 - 200.
    // Timber cribbing sleeper height = 60 mm.
    // Target nacelle center at rest: (-box_h/2 - 200) + 60 + 720 = -box_h/2 + 580.
    // Total vertical travel = 580 - 750 = -170 mm.
    drop_z = s_nacelle * (-170);

    translate([box_l/2 - 1500 + slide_x, 0, -box_h/2 + 750 + drop_z]) {
        // Direct-drive nacelle body
        color([0.25, 0.4, 0.7]) {
            scale([1.0, 0.7, 0.7])
            sphere(d=1450);
            // Transport skid
            translate([0, 0, -650])
            cube([1800, 1400, 140], center=true);
        }
        // PMSG rotor ring & hub face
        color([0.85, 0.5, 0.15])
        translate([650, 0, 0])
        rotate([0, 90, 0])
        cylinder(d=1200, h=220, center=true);

        // Timber cribbing sleeper pads beneath skid
        color([0.55, 0.35, 0.20]) {
            translate([-600, 0, -750]) cube([300, 1500, 60], center=true);
            translate([600, 0, -750]) cube([300, 1500, 60], center=true);
        }
    }
}

module stowed_or_deployed_mast() {
    // 5 modular mast sections
    if (s_mast < 0.4) {
        // Stowed inside container
        color([0.72, 0.74, 0.78, 1.0 - s_mast*2.5]) {
            for (row = [0 : 1]) {
                for (col = [0 : 2]) {
                    translate([-box_l/2 + 2600, -box_w/2 + 350 + col * 560, -box_h/2 + 350 + row * 540])
                    rotate([0, 90, 0])
                    cylinder(d=508, h=4800, center=true);
                }
            }
        }
    }

    if (s_mast > 0.05) {
        // Assembled mast sections appearing atop the container
        mast_alpha = clamp(s_mast * 1.5, 0.0, 1.0);
        color([0.88, 0.90, 0.93, mast_alpha]) {
            translate([0, 0, box_h/2 + 80 + 254]) {
                // Trunnion base pivot at x = 0, assembling forward along X
                rotate([0, 90, 0])
                cylinder(d=508, h=24000 * s_mast);
            }
        }
    }
}

module gin_pole_and_rigging() {
    // Gin-pole A-frame appears on container roof and tilts up to 90 deg
    if (s_gin > 0.0) {
        gin_angle = s_gin * 90;
        translate([0, 0, box_h/2 + 80 + 254]) {
            rotate([0, -gin_angle, 0]) {
                color([0.85, 0.55, 0.15]) {
                    // A-frame legs
                    for (dy = [-900, 900]) {
                        hull() {
                            translate([0, dy, 0]) sphere(d=219);
                            translate([0, 0, 7000]) sphere(d=219);
                        }
                    }
                    // Apex sheave block
                    translate([0, 0, 7000])
                    cube([350, 400, 450], center=true);
                }
            }
        }

        // Winch hoist cable
        if (s_gin > 0.4) {
            color([0.8, 0.2, 0.2])
            hull() {
                translate([-box_l/2 + 650, 0, box_h/2 + 200]) sphere(d=25);
                translate([0, 0, box_h/2 + 80 + 254 + 7000 * s_gin]) sphere(d=25);
            }
        }
    }
}

// -----------------------------------------------------------------------------
// Main Assembly
// -----------------------------------------------------------------------------
module wind_v2_container_unpacking_assembly() {
    permafrost_ground_pad();
    container_body();
    leveling_outriggers();
    container_rear_doors();
    overhead_crane_monorail();
    deploying_nacelle_and_skid();
    stowed_or_deployed_mast();
    gin_pole_and_rigging();
}

wind_v2_container_unpacking_assembly();
