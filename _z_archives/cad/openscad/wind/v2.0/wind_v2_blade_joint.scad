// wind_v2_blade_joint.scad -- Wind v2.0 Package 4: Sectional Rotor Blade & Spar Joint
//
// Parametric 3D CAD model of a modular blade segment:
// - Aerodynamic blade shell profile (NACA series inspired)
// - Carbon-fiber box-beam internal spar
// - Male / female plug-in spar sleeve connection
// - High-strength cross-pinning shear fasteners (dual M24 titanium/alloy pins)
// - Leading-edge electro-thermal anti-icing foil zone
//
// Units: millimeters (mm)
// Tracked under Issue #88 (Parent #82)

$fn = 48;

// -----------------------------------------------------------------------------
// Parameters (in mm)
// -----------------------------------------------------------------------------
section_length   = 1714; // Modular segment length (~1.71 m)
chord_root       = 820;  // Root chord of section
chord_tip        = 740;  // Tip chord of section
spar_width       = 240;  // Carbon spar box-beam width
spar_height      = 120;  // Carbon spar box-beam height
spar_wall        = 18;   // Carbon spar wall thickness
plug_overlap     = 280;  // Male joint insertion depth into female sleeve
pin_dia          = 26;   // Dual shear pin diameter (M24 bolt in Ø26 sleeve)

// Visual mode: 0 = Assembled Segment with Exploded Plug, 1 = Solid Segment, 2 = Cross-Section Cutaway
display_mode = 0;

// -----------------------------------------------------------------------------
// Foil Profile Helper (Parametric Cambered Airfoil Slice)
// -----------------------------------------------------------------------------
module airfoil_slice(chord=800, thickness_ratio=0.18, camber=0.03) {
    // Airfoil profile using dual cubic hulls
    hull() {
        // Leading edge radius
        circle(r=chord * thickness_ratio * 0.3);
        // Mid-chord upper / lower max thickness
        translate([chord * 0.32, chord * camber])
        scale([1.0, thickness_ratio / 0.5])
        circle(r=chord * 0.15);
        // Trailing edge
        translate([chord * 0.95, -chord * camber * 0.5])
        circle(r=chord * 0.012);
    }
}

// -----------------------------------------------------------------------------
// Sub-Modules
// -----------------------------------------------------------------------------

module aerodynamic_blade_skin() {
    // Tapered composite blade aerodynamic shell
    color([0.94, 0.95, 0.97, 0.85]) {
        difference() {
            // Outer skin
            hull() {
                translate([0, 0, 0])
                linear_extrude(height=1)
                airfoil_slice(chord=chord_root);

                translate([chord_root - chord_tip, 0, section_length])
                linear_extrude(height=1)
                airfoil_slice(chord=chord_tip);
            }
            // Hollow interior for carbon spar
            hull() {
                translate([0, 0, -2])
                linear_extrude(height=1)
                scale([0.95, 0.90])
                airfoil_slice(chord=chord_root);

                translate([chord_root - chord_tip, 0, section_length + 2])
                linear_extrude(height=1)
                scale([0.95, 0.90])
                airfoil_slice(chord=chord_tip);
            }
            // Shear pin access holes on upper and lower surfaces
            for (z = [plug_overlap * 0.35, plug_overlap * 0.75]) {
                translate([chord_root * 0.32, 0, z])
                cylinder(d=pin_dia + 6, h=spar_height * 2.5, center=true);
            }
        }
    }
}

module anti_icing_heating_foil() {
    // Leading-edge electro-thermal heating foil zone (orange highlight)
    color([0.95, 0.45, 0.1, 0.95]) {
        intersection() {
            hull() {
                translate([0, 0, 0])
                linear_extrude(height=1)
                airfoil_slice(chord=chord_root * 1.01);

                translate([chord_root - chord_tip, 0, section_length])
                linear_extrude(height=1)
                airfoil_slice(chord=chord_tip * 1.01);
            }
            // Mask to leading edge 15% chord
            translate([-chord_root * 0.1, -spar_height, -10])
            cube([chord_root * 0.25, spar_height * 2, section_length + 20]);
        }
    }
}

module carbon_box_spar() {
    // Carbon-fiber primary structural load-bearing box-beam
    spar_center_x = chord_root * 0.32;

    color([0.22, 0.24, 0.26]) {
        // Main internal spar running the full length of the section
        translate([spar_center_x - spar_width/2, -spar_height/2, 0])
        difference() {
            cube([spar_width, spar_height, section_length]);
            // Hollow core
            translate([spar_wall, spar_wall, -2])
            cube([spar_width - 2*spar_wall, spar_height - 2*spar_wall, section_length + 4]);
            // Pin holes at the female root end
            for (z = [plug_overlap * 0.35, plug_overlap * 0.75]) {
                translate([spar_width/2, spar_height/2, z])
                rotate([90, 0, 0])
                cylinder(d=pin_dia, h=spar_height * 1.5, center=true);
            }
        }
    }
}

module male_joint_plug() {
    // Male carbon-fiber plug protruding from the tip end of the section
    spar_center_x = chord_root * 0.32;
    plug_clearance = 1.0; // 1 mm sliding fit tolerance

    color([0.15, 0.55, 0.85]) {
        translate([
            spar_center_x - (spar_width - 2*spar_wall - plug_clearance)/2,
            -(spar_height - 2*spar_wall - plug_clearance)/2,
            section_length - (display_mode == 0 ? -120 : 0) // Exploded view offset
        ])
        difference() {
            cube([
                spar_width - 2*spar_wall - plug_clearance,
                spar_height - 2*spar_wall - plug_clearance,
                plug_overlap
            ]);
            // Hollow weight-saving core
            translate([15, 15, -2])
            cube([
                spar_width - 2*spar_wall - plug_clearance - 30,
                spar_height - 2*spar_wall - plug_clearance - 30,
                plug_overlap + 4
            ]);
            // Shear pin holes
            for (z = [plug_overlap * 0.35, plug_overlap * 0.75]) {
                translate([
                    (spar_width - 2*spar_wall - plug_clearance)/2,
                    (spar_height - 2*spar_wall - plug_clearance)/2,
                    z
                ])
                rotate([90, 0, 0])
                cylinder(d=pin_dia, h=spar_height * 1.5, center=true);
            }
        }
    }
}

module shear_locking_pins() {
    // Dual high-strength titanium cross pins
    spar_center_x = chord_root * 0.32;
    color([0.85, 0.85, 0.2]) {
        for (z = [plug_overlap * 0.35, plug_overlap * 0.75]) {
            translate([spar_center_x, 0, z])
            rotate([90, 0, 0])
            cylinder(d=pin_dia - 1, h=spar_height + 40, center=true);
        }
    }
}

// -----------------------------------------------------------------------------
// Assembly
// -----------------------------------------------------------------------------
module wind_v2_blade_joint_assembly() {
    aerodynamic_blade_skin();
    anti_icing_heating_foil();
    carbon_box_spar();
    male_joint_plug();
    shear_locking_pins();
}

wind_v2_blade_joint_assembly();
