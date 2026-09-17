// =============================================================================
// AMU — Autonomous Manufacturing Unit (OpenCode v1)
// Awakened Imagination Group of Projects — TRL 1 parametric sketch
// Location: cad_and_blender/openscad/opencode/amu_opencode_v1.scad
// Target: OpenSCAD >= 2021.01
// Branch: main-dev → master (see docs/release_notes/v1.1.md:1)
//
// Stages:
//  - Stage 01 MMS: adaptive core hull (self-replication spine) — R6 × L14
//  - Stage 02 Logistics Core: fuel + 3× transporter bays — R3.4 × L9
//  - Stage 03 Re-tasking Frame: modular mount — span 10, modules 4³
//  - Solar wings + daughter replication hint
// Tune top params only; geometry auto-updates.
// =============================================================================

// ---------------------------- User-tunable params ----------------------------
MMS_RADIUS      = 6.0;    // core hull radius
MMS_LENGTH      = 14.0;   // core hull length (X)
CORE_RADIUS     = 2.2;    // inner spine radius
SPINE_LENGTH    = 30.0;   // central spine length

LOGI_RADIUS     = 3.4;    // logistics tank radius
LOGI_LENGTH     = 9.0;    // logistics tank length
LOGI_OFFSET     = 11.0;   // offset from MMS center

BAY_COUNT       = 3;      // transporter bays around tank
BAY_RADIUS      = 1.1;    // bay radius
BAY_LENGTH      = 6.0;    // bay length

FRAME_SPAN      = 10.0;   // re-tasking frame half-span (Y/Z)
FRAME_THICK     = 0.6;    // strut thickness
MODULE_SIZE     = 4.0;    // payload module size (greenhouse/bioreactor)

SOLAR_PANEL_W   = 8.0;    // solar wing length
SOLAR_PANEL_H   = 4.0;    // solar wing width
SOLAR_OFFSET    = 9.0;    // solar offset from center

SHOW_DAUGHTER   = true;   // show mirrored daughter unit
SHOW_SOLAR      = true;   // show solar wings
SHOW_MODULES    = true;   // show payload modules

EPS = 0.01;

// ------------------------------ Helpers --------------------------------------

module spine(len, r) {
    rotate([0, 90, 0])
        cylinder(h = len, r = r, center = true, $fn = 24);
}

module torus(r_major, r_minor, seg = 48) {
    rotate_extrude(convexity = 10, $fn = seg)
        translate([r_major, 0, 0])
            circle(r = r_minor, $fn = seg);
}

module mms() {
    union() {
        rotate([0, 90, 0])
            cylinder(h = MMS_LENGTH, r1 = MMS_RADIUS*0.7, r2 = MMS_RADIUS, center = true, $fn = 48);
        translate([MMS_LENGTH/2, 0, 0]) sphere(r = MMS_RADIUS*0.7, $fn = 48);
        translate([-MMS_LENGTH/2, 0, 0]) sphere(r = MMS_RADIUS*0.7, $fn = 48);
        for (i = [-1, 0, 1])
            translate([i * MMS_LENGTH*0.3, 0, 0])
                rotate([0, 90, 0])
                    torus(r_major = MMS_RADIUS*0.75, r_minor = 0.25);
    }
}

module logistics_core() {
    union() {
        rotate([0, 90, 0])
            cylinder(h = LOGI_LENGTH, r = LOGI_RADIUS, center = true, $fn = 40);
        for (i = [0 : BAY_COUNT-1]) {
            a = i * 360 / BAY_COUNT;
            rotate([0, 0, a])
                translate([0, LOGI_RADIUS + BAY_RADIUS*0.6, 0])
                    rotate([90, 0, 0])
                        cylinder(h = BAY_LENGTH, r = BAY_RADIUS, center = true, $fn = 20);
        }
    }
}

module retasking_frame() {
    union() {
        for (s = [-1, 1]) {
            translate([0, s * FRAME_SPAN, 0])
                cube([SPINE_LENGTH*0.8, FRAME_THICK, FRAME_THICK*2], center = true);
            translate([0, 0, s * FRAME_SPAN])
                cube([SPINE_LENGTH*0.8, FRAME_THICK*2, FRAME_THICK], center = true);
        }
        for (sy = [-1, 1]) for (sz = [-1, 1])
            translate([0, sy*FRAME_SPAN*0.7, sz*FRAME_SPAN*0.7])
                cube([SPINE_LENGTH*0.8, FRAME_THICK, FRAME_THICK], center = true);
    }
}

module payload_module() {
    union() {
        cube([MODULE_SIZE, MODULE_SIZE, MODULE_SIZE], center = true);
        % cube([MODULE_SIZE*1.05, MODULE_SIZE*1.05, MODULE_SIZE*1.05], center = true);
    }
}

module solar_wing(sign) {
    translate([SOLAR_OFFSET * sign, 0, 0])
        rotate([0, 0, 90])
            cube([SOLAR_PANEL_W, SOLAR_PANEL_H, 0.2], center = true);
    translate([SOLAR_OFFSET*sign*0.5, 0, 0])
        cube([SOLAR_OFFSET, 0.3, 0.3], center = true);
}

function identity4() = [[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]];

module amu_assembly() {
    spine(SPINE_LENGTH, CORE_RADIUS);
    mms();
    translate([LOGI_OFFSET, 0, 0]) logistics_core();
    translate([-LOGI_OFFSET*0.6, 0, 0]) retasking_frame();
    if (SHOW_MODULES)
        for (sy = [-1, 1]) for (sz = [-1, 1])
            translate([-LOGI_OFFSET*0.6, sy*FRAME_SPAN*0.7, sz*FRAME_SPAN*0.7])
                payload_module();
    if (SHOW_SOLAR) { solar_wing(1); solar_wing(-1); }
}

// ------------------------------- Render --------------------------------------
amu_assembly();

if (SHOW_DAUGHTER) {
    translate([0, FRAME_SPAN*2.4, 0])
        scale([0.7, 0.7, 0.7])
            amu_assembly();
}

// Build tips:
// Preview: F5 | Render: F6 (CGAL) | Export: File > Export > STL / 3MF / DXF
// Params at top only — no geometry edits needed for new variants.
// Signed: [OpenCode](https://opencode.ai), powered by opencode/muse-spark-1.2-contributor-free — 2026-09-16
