// wind_v2_container_stowage.scad -- Wind v2.0 Package 4: 20 ft ISO Container Stowage Architecture
//
// Parametric 3D CAD model of the complete wind turbine stowed inside a standard 20 ft ISO shipping box:
// - ISO 20 ft container outer frame & corner castings (5.898 m L × 2.352 m W × 2.393 m H internal)
// - Package 1: Foundation outrigger beams & ground anchor racks
// - Package 2: 6x Modular tubular mast segments (5.0 m each) bundled in cradles
// - Package 3: Pre-assembled direct-drive nacelle tophead on transport skid
// - Package 4: 21x Sectional rotor blade segments in vertical slotted racks
// - Package 4: 50 kW Microgrid electrical converter cabinet & winch pack
//
// Units: millimeters (mm)
// Tracked under Issue #88 (Parent #82)

$fn = 32;

// -----------------------------------------------------------------------------
// Parameters (in mm)
// -----------------------------------------------------------------------------
box_l = 5898; // ISO internal length
box_w = 2352; // ISO internal width
box_h = 2393; // ISO internal height

// Display Mode: 0 = Transparent Container with Packed Equipment, 1 = Solid ISO Container
c_mode = 0;

// -----------------------------------------------------------------------------
// Sub-Modules
// -----------------------------------------------------------------------------

module iso_container_frame() {
    color([0.65, 0.22, 0.22, c_mode == 0 ? 0.25 : 1.0]) {
        difference() {
            cube([box_l + 160, box_w + 120, box_h + 160], center=true);
            cube([box_l, box_w, box_h], center=true);
            // Open side/top cutout for visibility in mode 0
            if (c_mode == 0) {
                translate([0, box_w/2, 0])
                cube([box_l - 200, box_w, box_h - 200], center=true);
            }
        }
    }
    // Heavy corner castings & structural corner posts
    color([0.35, 0.35, 0.38]) {
        for (x = [-box_l/2, box_l/2]) {
            for (y = [-box_w/2, box_w/2]) {
                translate([x, y, 0])
                cube([120, 120, box_h + 120], center=true);
            }
        }
    }
}

module stowed_mast_segments() {
    // 6x modular mast sections (Ø508 mm × 5 000 mm L) stacked in lower right cradle
    color([0.72, 0.74, 0.78]) {
        for (row = [0 : 1]) {
            for (col = [0 : 2]) {
                translate([-box_l/2 + 2600, -box_w/2 + 350 + col * 560, -box_h/2 + 350 + row * 540])
                rotate([0, 90, 0])
                difference() {
                    cylinder(d=508, h=5000, center=true);
                    cylinder(d=480, h=5004, center=true);
                }
            }
        }
    }
}

module stowed_nacelle_skid() {
    // Package 3 direct-drive nacelle tophead stowed in forward bay
    color([0.25, 0.4, 0.7]) {
        translate([box_l/2 - 1100, 0, -box_h/2 + 750]) {
            // Nacelle body
            scale([1.0, 0.7, 0.7])
            sphere(d=1450);
            // Transport skid frame
            translate([0, 0, -650])
            cube([1800, 1400, 140], center=true);
        }
    }
}

module stowed_blade_segments_rack() {
    // 21x sectional blade modules (1.71 m L) racked vertically in mid-bay upper tier
    color([0.92, 0.94, 0.96]) {
        for (i = [0 : 20]) {
            bay_x = -box_l/2 + 700 + (i % 7) * 450;
            bay_y = (i < 7) ? -box_w/2 + 400 : (i < 14 ? 0 : box_w/2 - 400);
            translate([bay_x, bay_y, box_h/2 - 950])
            rotate([0, 0, 90])
            cube([220, 750, 1714], center=true);
        }
    }
    // High-visibility anti-icing edge stripes
    color([0.95, 0.45, 0.1]) {
        for (i = [0 : 20]) {
            bay_x = -box_l/2 + 700 + (i % 7) * 450;
            bay_y = (i < 7) ? -box_w/2 + 400 : (i < 14 ? 0 : box_w/2 - 400);
            translate([bay_x - 100, bay_y, box_h/2 - 950])
            cube([20, 150, 1714], center=true);
        }
    }
}

module stowed_electrical_cabinet_and_winch() {
    // Microgrid converter cabinet & tilt-up winch pack
    color([0.2, 0.6, 0.3]) {
        // 50 kW Power Converter Cabinet
        translate([-box_l/2 + 650, box_w/2 - 550, -box_h/2 + 650])
        cube([1100, 800, 1300], center=true);

        // Tilt-up Winch & Snatch Block Skid
        translate([-box_l/2 + 650, -box_w/2 + 550, -box_h/2 + 450])
        cube([950, 800, 900], center=true);
    }
}

module stowed_foundation_outriggers() {
    // Package 1 ground anchors, leveling jacks, and trunnion brackets
    color([0.45, 0.45, 0.5]) {
        translate([0, 0, -box_h/2 + 80])
        cube([box_l - 400, box_w - 200, 120], center=true);
    }
}

// -----------------------------------------------------------------------------
// Assembly
// -----------------------------------------------------------------------------
module wind_v2_container_stowage_assembly() {
    iso_container_frame();
    stowed_foundation_outriggers();
    stowed_mast_segments();
    stowed_nacelle_skid();
    stowed_blade_segments_rack();
    stowed_electrical_cabinet_and_winch();
}

wind_v2_container_stowage_assembly();
