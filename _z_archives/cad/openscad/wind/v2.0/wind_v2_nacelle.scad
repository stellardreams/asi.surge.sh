// wind_v2_nacelle.scad -- Wind v2.0 Package 3: Arctic Direct-Drive Powertrain & Nacelle
//
// Parametric 3D CAD model of the 50 kW direct-drive wind turbine nacelle:
// - PMSG direct-drive stator and rotor outer ring
// - Heavy-duty forged alloy main shaft with dual bearing pillow blocks
// - Welded structural steel bedplate interface to mast top
// - Yaw bearing slewing ring with dual electric geared drive pinions
// - Spring-applied fail-safe caliper disc brake (zero hydraulic fluid)
// - Aerodynamic composite cowl with snow-deflecting labyrinth louvers
//
// Units: millimeters (mm)
// Tracked under Issue #87 (Parent #82)

$fn = 64;

// -----------------------------------------------------------------------------
// Parameters (in mm)
// -----------------------------------------------------------------------------
stator_outer_dia     = 1360;  // 1.36 m stator outer housing diameter
stator_inner_dia     = 1200;  // 1.20 m air gap diameter
rotor_magnet_dia     = 1196;  // 1.196 m permanent magnet outer ring
stack_length         = 180;   // Active stator/rotor stack axial width
shaft_dia            = 180;   // Main shaft outer diameter
shaft_length         = 950;   // Main shaft length
hub_flange_dia       = 480;   // Rotor hub connection flange
hub_flange_thick     = 45;    // Flange thickness

// Bedplate & Yaw
bedplate_length      = 1500;  // Bedplate main spine length
bedplate_width       = 700;   // Bedplate width
bedplate_thick       = 40;    // Structural plate thickness
pedestal_height      = 750;   // Elevated bearing pedestal height (60 mm air gap to wheel bottom under vibration)
shaft_center_z       = bedplate_thick + pedestal_height; // 790 mm

mast_top_dia         = 508;   // Mast top connection flange diameter (matches mast trunk)
yaw_bearing_outer    = 680;   // Yaw slewing ring outer diameter
yaw_bearing_inner    = 460;   // Yaw inner bore
yaw_bearing_height   = 90;    // Yaw bearing height

// Caliper Brake
brake_disc_dia       = 620;   // Ventilated brake disc diameter
brake_disc_thick     = 30;    // Disc thickness

// Cowl Enclosure
cowl_length          = 2300;  // Nacelle shell length
cowl_width           = 1500;  // Nacelle shell width
cowl_height          = 1650;  // Nacelle shell height
cowl_wall_thick      = 15;    // Composite skin thickness

// Visual Display Mode: 0 = Full Cowl, 1 = Cutaway Cowl, 2 = Powertrain Skeleton Only
cowl_mode = 0;

// -----------------------------------------------------------------------------
// Sub-Modules
// -----------------------------------------------------------------------------

module mast_top_interface() {
    color([0.35, 0.38, 0.42]) {
        // Mast tubular section stub (visible tower trunk beneath nacelle)
        translate([0, 0, -420])
        difference() {
            cylinder(d=mast_top_dia, h=300);
            cylinder(d=mast_top_dia - 16, h=302, center=true);
        }
        // Mast top landing flange
        translate([0, 0, -120])
        difference() {
            cylinder(d=mast_top_dia + 60, h=30);
            cylinder(d=mast_top_dia - 60, h=40, center=true);
        }
        // Yaw slewing ring bearing
        translate([0, 0, -90])
        difference() {
            cylinder(d=yaw_bearing_outer, h=yaw_bearing_height);
            cylinder(d=yaw_bearing_inner, h=yaw_bearing_height + 2, center=true);
            for (a = [0 : 30 : 330]) {
                rotate([0, 0, a])
                translate([yaw_bearing_outer/2 - 25, 0, -1])
                cylinder(d=22, h=yaw_bearing_height + 4);
            }
        }
    }
}

module yaw_drive_motors() {
    color([0.2, 0.5, 0.8]) {
        for (side = [-1, 1]) {
            translate([side * (yaw_bearing_outer/2 + 70), 0, -30]) {
                cylinder(d=160, h=260);
                translate([0, 0, -50])
                cylinder(d=190, h=50);
                translate([-side * 40, 0, -85])
                cylinder(d=100, h=70);
            }
        }
    }
}

module bedplate() {
    color([0.45, 0.48, 0.52]) {
        // Main structural weldment plate terminates at X = 220, providing complete longitudinal separation
        translate([-bedplate_length * 0.48, -bedplate_width/2, 0])
        cube([bedplate_length * 0.65, bedplate_width, bedplate_thick]);

        // Heavy bearing pedestal front (X: [50, 230])
        translate([50, -bedplate_width/2 + 60, bedplate_thick])
        difference() {
            cube([180, bedplate_width - 120, pedestal_height]);
            translate([90, (bedplate_width - 120)/2, pedestal_height])
            rotate([0, 90, 0])
            cylinder(d=shaft_dia + 80, h=200, center=true);
        }

        // Heavy bearing pedestal rear (X: [-450, -270])
        translate([-450, -bedplate_width/2 + 60, bedplate_thick])
        difference() {
            cube([180, bedplate_width - 120, pedestal_height]);
            translate([90, (bedplate_width - 120)/2, pedestal_height])
            rotate([0, 90, 0])
            cylinder(d=shaft_dia + 80, h=200, center=true);
        }
    }
}

module main_shaft_and_bearings() {
    color([0.7, 0.72, 0.75]) {
        translate([-500, 0, shaft_center_z])
        rotate([0, 90, 0])
        difference() {
            cylinder(d=shaft_dia, h=shaft_length + 150);
            cylinder(d=shaft_dia - 60, h=shaft_length + 152, center=true);
        }
        translate([shaft_length - 350, 0, shaft_center_z])
        rotate([0, 90, 0])
        difference() {
            cylinder(d=hub_flange_dia, h=hub_flange_thick);
            cylinder(d=shaft_dia - 60, h=hub_flange_thick + 2, center=true);
            for (a = [0 : 30 : 330]) {
                rotate([0, 0, a])
                translate([hub_flange_dia/2 - 35, 0, -1])
                cylinder(d=26, h=hub_flange_thick + 4);
            }
        }
    }

    color([0.25, 0.28, 0.32]) {
        // Front main bearing block
        translate([140, 0, shaft_center_z])
        rotate([0, 90, 0])
        difference() {
            cylinder(d=shaft_dia + 76, h=140, center=true);
            cylinder(d=shaft_dia, h=142, center=true);
        }
        // Rear main bearing block
        translate([-360, 0, shaft_center_z])
        rotate([0, 90, 0])
        difference() {
            cylinder(d=shaft_dia + 76, h=120, center=true);
            cylinder(d=shaft_dia, h=122, center=true);
        }
    }
}

module fail_safe_caliper_brake() {
    color([0.6, 0.6, 0.65]) {
        translate([-100, 0, shaft_center_z])
        rotate([0, 90, 0])
        difference() {
            cylinder(d=brake_disc_dia, h=brake_disc_thick, center=true);
            cylinder(d=shaft_dia + 10, h=brake_disc_thick + 2, center=true);
            for (r = [140, 200, 260]) {
                for (a = [0 : 45 : 315]) {
                    rotate([0, 0, a])
                    translate([r, 0, 0])
                    cylinder(d=20, h=brake_disc_thick + 4, center=true);
                }
            }
        }
    }
    color([0.85, 0.2, 0.15]) {
        translate([-100, brake_disc_dia/2 - 40, shaft_center_z])
        cube([130, 160, 110], center=true);
    }
}

module pmsg_direct_drive_generator() {
    gen_pos_x = 440;

    color([0.2, 0.35, 0.65]) {
        translate([gen_pos_x, 0, shaft_center_z])
        rotate([0, 90, 0])
        difference() {
            cylinder(d=stator_outer_dia, h=stack_length, center=true);
            cylinder(d=stator_inner_dia, h=stack_length + 2, center=true);
            for (a = [0 : 15 : 345]) {
                rotate([0, 0, a])
                translate([stator_outer_dia/2, 0, 0])
                cube([20, 12, stack_length + 4], center=true);
            }
        }
    }

    color([0.85, 0.5, 0.15]) {
        translate([gen_pos_x, 0, shaft_center_z])
        rotate([0, 90, 0])
        difference() {
            cylinder(d=stator_inner_dia + 30, h=stack_length + 60, center=true);
            cylinder(d=stator_inner_dia, h=stack_length + 64, center=true);
        }
    }

    color([0.8, 0.85, 0.9]) {
        translate([gen_pos_x, 0, shaft_center_z])
        rotate([0, 90, 0])
        difference() {
            cylinder(d=rotor_magnet_dia, h=stack_length, center=true);
            cylinder(d=rotor_magnet_dia - 120, h=stack_length + 2, center=true);
        }
        for (a = [0 : 60 : 300]) {
            translate([gen_pos_x, 0, shaft_center_z])
            rotate([a, 0, 0])
            cube([stack_length - 20, rotor_magnet_dia - 120, 30], center=true);
        }
    }
}

module aerodynamic_cowl() {
    if (cowl_mode < 2) {
        cowl_offset_x = 50;

        color([0.92, 0.93, 0.95, cowl_mode == 0 ? 0.92 : 0.4]) {
            translate([cowl_offset_x, 0, shaft_center_z])
            difference() {
                scale([1.0, cowl_width/cowl_length, cowl_height/cowl_length])
                sphere(d=cowl_length);

                scale([0.98, (cowl_width - 2*cowl_wall_thick)/cowl_length, (cowl_height - 2*cowl_wall_thick)/cowl_length])
                sphere(d=cowl_length);

                // Hub clearance
                translate([cowl_length/2 - 100, 0, 0])
                rotate([0, 90, 0])
                cylinder(d=hub_flange_dia + 80, h=400, center=true);

                // Mast clearance
                translate([-cowl_offset_x, 0, -shaft_center_z])
                cylinder(d=yaw_bearing_outer + 60, h=400, center=true);

                // Cutaway half
                if (cowl_mode == 1) {
                    translate([0, cowl_length/2, 0])
                    cube([cowl_length * 1.5, cowl_length, cowl_length * 1.5], center=true);
                }
            }

            // Snow louvers
            translate([-cowl_length * 0.42, 0, shaft_center_z + 180])
            for (z = [-120 : 40 : 120]) {
                translate([0, 0, z])
                cube([220, cowl_width * 0.45, 12], center=true);
            }
        }
    }
}

module wind_v2_nacelle_assembly() {
    mast_top_interface();
    yaw_drive_motors();
    bedplate();
    main_shaft_and_bearings();
    fail_safe_caliper_brake();
    pmsg_direct_drive_generator();
    aerodynamic_cowl();
}

wind_v2_nacelle_assembly();
