// wind_v2_microgrid_cabinet.scad -- Wind v2.0 Arctic Microgrid Power Converter & Control Cabinet
//
// Parametric 3D CAD model of the autonomous microgrid interface cabinet housed in the forward end
// of the 20 ft ISO shipping container.
//
// Display Modes:
// 0 = Cutaway Front View (Enclosure walls transparent/cut so all power electronics are exposed)
// 1 = Solid Weatherproof Enclosure
//
// Units: millimeters (mm)
// Tracked under Issue #88 (Package 4) and Parent Issue #82

$fn = 32;

mode = 0; // 0 = cutaway/internal, 1 = solid exterior

// Cabinet Dimensions (mm)
cab_w = 1100;
cab_d = 800;
cab_h = 1600;

module cabinet_enclosure() {
    if (mode == 1) {
        // Insulated NEMA 4X / IP66 enclosure (Industrial Arctic Gray)
        color([0.80, 0.82, 0.85]) {
            difference() {
                cube([cab_w, cab_d, cab_h], center=true);
                translate([0, 20, 0])
                cube([cab_w - 50, cab_d - 40, cab_h - 60], center=true);
            }
        }
        // Front door latching handles
        color([0.2, 0.2, 0.2]) {
            for (z = [-cab_h/4, cab_h/4]) {
                translate([cab_w/2 - 50, -cab_d/2 - 10, z])
                cube([20, 30, 80], center=true);
            }
        }
        // High-visibility touchscreen HMI interface
        color([0.1, 0.5, 0.9]) {
            translate([0, -cab_d/2 - 5, cab_h/4])
            cube([320, 15, 240], center=true);
        }
    } else {
        // Mode 0: Transparent rear/side shell with fully open front face
        color([0.80, 0.82, 0.85, 0.25]) {
            difference() {
                cube([cab_w, cab_d, cab_h], center=true);
                translate([0, -30, 0])
                cube([cab_w - 40, cab_d + 10, cab_h - 40], center=true);
            }
        }
    }
    
    // Structural internal frame posts
    color([0.35, 0.38, 0.42]) {
        for (x = [-cab_w/2 + 20, cab_w/2 - 20]) {
            for (y = [-cab_d/2 + 20, cab_d/2 - 20]) {
                translate([x, y, 0])
                cube([30, 30, cab_h - 40], center=true);
            }
        }
    }

    // Arctic status beacon on top (Green = Grid Synchronized)
    color([0.1, 0.85, 0.2]) {
        translate([0, 0, cab_h/2 + 35])
        cylinder(d=80, h=70, center=true);
    }
}

module internal_converter_racks() {
    // Horizontal shelf dividing trays
    color([0.25, 0.27, 0.30]) {
        for (z = [-cab_h/2 + 380, -cab_h/2 + 750, cab_h/2 - 320]) {
            translate([0, 20, z])
            cube([cab_w - 100, cab_d - 100, 20], center=true);
        }
    }

    // Shelf 1 (Bottom): Heavy LCL Filter & Isolation Transformer Chokes (Three-Phase)
    color([0.78, 0.38, 0.12]) {
        for (i = [-1, 0, 1]) {
            translate([i * 280, 20, -cab_h/2 + 190]) {
                cylinder(d=190, h=240, center=true);
                cube([150, 150, 260], center=true);
            }
        }
    }

    // Shelf 2 (Lower-Mid): 750 VDC Bus Film Capacitor Bank (-60 °C rated)
    color([0.15, 0.45, 0.82]) {
        for (row = [-1, 1]) {
            for (col = [-2 : 2]) {
                translate([col * 170, row * 110 + 20, -cab_h/2 + 565])
                cylinder(d=120, h=210, center=true);
            }
        }
    }

    // Shelf 3 (Upper-Mid): Machine-Side Converter (MSC) & Grid-Side Inverter (GSC)
    // Aluminum Finned Heat Sink Arrays
    color([0.88, 0.90, 0.92]) {
        translate([-230, 60, cab_h/2 - 470])
        cube([390, 180, 250], center=true);
        translate([230, 60, cab_h/2 - 470])
        cube([390, 180, 250], center=true);
    }
    // High-Power Silicon Carbide (SiC) Half-Bridge Modules
    color([0.85, 0.12, 0.12]) {
        translate([-230, -55, cab_h/2 - 470])
        cube([370, 45, 220], center=true);
        translate([230, -55, cab_h/2 - 470])
        cube([370, 45, 220], center=true);
    }

    // Shelf 4 (Top): Master Droop Controller PLC, DSP Synchronization Board & Relay Bay
    color([0.12, 0.65, 0.25]) {
        translate([0, 30, cab_h/2 - 160])
        cube([cab_w - 180, 140, 200], center=true);
    }
    // PLC Status Indicators & Terminal Strip
    color([0.95, 0.85, 0.1]) {
        translate([0, -45, cab_h/2 - 160])
        cube([cab_w - 220, 15, 60], center=true);
    }
}

module external_camlok_bay() {
    // Quick-connect Cam-Lok power interface on right side of cabinet
    color([0.2, 0.2, 0.2]) {
        translate([cab_w/2 + 10, 0, -cab_h/4])
        cube([25, 280, 380], center=true);
    }
    // Color-coded 480 VAC 3-Phase + Neutral + Ground Cam-Loks
    cam_colors = [
        [0.1, 0.1, 0.1], // Black - Phase A
        [0.8, 0.1, 0.1], // Red - Phase B
        [0.1, 0.3, 0.8], // Blue - Phase C
        [0.9, 0.9, 0.9], // White - Neutral
        [0.1, 0.7, 0.2]  // Green - Ground
    ];
    for (i = [0 : 4]) {
        color(cam_colors[i]) {
            translate([cab_w/2 + 30, -110 + i * 55, -cab_h/4])
            rotate([0, 90, 0])
            cylinder(d=38, h=50, center=true);
        }
    }
}

module wind_v2_microgrid_cabinet_assembly() {
    cabinet_enclosure();
    internal_converter_racks();
    external_camlok_bay();
}

wind_v2_microgrid_cabinet_assembly();
