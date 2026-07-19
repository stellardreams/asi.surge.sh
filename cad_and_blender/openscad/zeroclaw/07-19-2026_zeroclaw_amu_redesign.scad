// =============================================================================
// AMU — Autonomous Manufacturing Unit (Redesign)
// Awakened Imagination Group of Projects
// 3-Stage parametric design: MMS + Logistics Core + Re-tasking Frame
// Target: OpenSCAD >= 2021.01
//
// Design notes:
//  - Stage 01 MMS: central adaptive core hull (self-replication spine)
//  - Stage 02 Logistics Core: fuel reserve + transporter bays
//  - Stage 03 Re-tasking Frame: modular mount for greenhouses/bioreactors/compute
//  - Self-replication hinted by a mirrored "daughter" MMS on the far spine node
// Proportions loosely grounded in the Heritage Greenhouse concept render.
// =============================================================================

// ---------------------------- User-tunable params ----------------------------
MMS_RADIUS      = 6.0;    // core hull radius
MMS_LENGTH      = 14.0;   // core hull length (along spine axis = X)
CORE_RADIUS     = 2.2;    // inner manufacturing spine radius
SPINE_LENGTH    = 30.0;   // central structural spine length

LOGI_RADIUS     = 3.4;    // logistics core (tank) radius
LOGI_LENGTH     = 9.0;    // logistics core length
LOGI_OFFSET     = 11.0;   // axial offset of logistics core from MMS center

BAY_COUNT       = 3;      // number of transporter bays around logistics core
BAY_RADIUS      = 1.1;    // transporter bay radius
BAY_LENGTH      = 6.0;    // transporter bay length

FRAME_SPAN      = 10.0;   // re-tasking frame half-span (Y)
FRAME_THICK     = 0.6;    // frame strut thickness
MODULE_SIZE     = 4.0;    // generic payload module (greenhouse/bioreactor) size

SOLAR_PANEL_W   = 8.0;    // solar wing length
SOLAR_PANEL_H   = 4.0;    // solar wing width
SOLAR_OFFSET    = 9.0;    // axial offset of solar wings

SHOW_DAUGHTER   = true;   // show mirrored replication hint
SHOW_SOLAR      = true;   // show solar wings
SHOW_MODULES    = true;   // show re-tasking payload modules

EPS = 0.01;

// ------------------------------ Reusable parts -------------------------------

// Central manufacturing spine (the self-replication axis)
module spine(len, r) {
    rotate([0, 90, 0])
        cylinder(h = len, r = r, center = true, $fn = 24);
}

// Stage 01 — Main Manufacturing Site (adaptive core hull)
module mms() {
    union() {
        // outer hull: truncated cone-ish capsule along X
        rotate([0, 90, 0])
            cylinder(h = MMS_LENGTH, r1 = MMS_RADIUS*0.7, r2 = MMS_RADIUS, center = true, $fn = 48);
        // end cap dome
        translate([MMS_LENGTH/2, 0, 0])
            sphere(r = MMS_RADIUS*0.7, $fn = 48);
        translate([-MMS_LENGTH/2, 0, 0])
            sphere(r = MMS_RADIUS*0.7, $fn = 48);
        // ring detail nodes
        for (i = [-1, 0, 1]) {
            translate([i * MMS_LENGTH*0.3, 0, 0])
                rotate([0, 90, 0])
                    torus(r_major = MMS_RADIUS*0.75, r_minor = 0.25);
        }
    }
}

// a torus helper (OpenSCAD has no built-in)
module torus(r_major, r_minor, seg = 48) {
    rotate_extrude(convexity = 10, $fn = seg)
        translate([r_major, 0, 0])
            circle(r = r_minor, $fn = seg);
}

// Stage 02 — Logistics Core (fuel reserve + transporter bays)
module logistics_core() {
    union() {
        // central fuel tank
        rotate([0, 90, 0])
            cylinder(h = LOGI_LENGTH, r = LOGI_RADIUS, center = true, $fn = 40);
        // transporter bays radiating around the tank
        for (i = [0 : BAY_COUNT-1]) {
            a = i * 360 / BAY_COUNT;
            rotate([0, 0, a])
                translate([0, LOGI_RADIUS + BAY_RADIUS*0.6, 0])
                    rotate([90, 0, 0])
                        cylinder(h = BAY_LENGTH, r = BAY_RADIUS, center = true, $fn = 20);
        }
    }
}

// Stage 03 — Re-tasking Frame (modular payload mount)
module retasking_frame() {
    union() {
        // four perimeter struts
        for (s = [-1, 1]) {
            translate([0, s * FRAME_SPAN, 0])
                cube([SPINE_LENGTH*0.8, FRAME_THICK, FRAME_THICK*2], center = true);
            translate([0, 0, s * FRAME_SPAN])
                cube([SPINE_LENGTH*0.8, FRAME_THICK*2, FRAME_THICK], center = true);
        }
        // corner diagonals
        for (sy = [-1, 1])
            for (sz = [-1, 1])
                translate([0, sy*FRAME_SPAN*0.7, sz*FRAME_SPAN*0.7])
                    rotate([0, 0, 0])
                        cube([SPINE_LENGTH*0.8, FRAME_THICK, FRAME_THICK], center = true);
    }
}

// Generic payload module (greenhouse / bioreactor / compute)
module payload_module() {
    union() {
        cube([MODULE_SIZE, MODULE_SIZE, MODULE_SIZE], center = true);
        // glazed greenhouse shell hint (translucent look via thinner shell)
        % cube([MODULE_SIZE*1.05, MODULE_SIZE*1.05, MODULE_SIZE*1.05], center = true);
    }
}

// Solar wing
module solar_wing(sign) {
    translate([SOLAR_OFFSET * sign, 0, 0])
        rotate([0, 0, 90])
            cube([SOLAR_PANEL_W, SOLAR_PANEL_H, 0.2], center = true);
    // support strut
    translate([SOLAR_OFFSET*sign*0.5, 0, 0])
        cube([SOLAR_OFFSET, 0.3, 0.3], center = true);
}

// ------------------------------- Assembly ------------------------------------

module amu_assembly(mirror_x = false) {
    // mirror whole unit for daughter replication hint
    transform = mirror_x ? [1,1,1] : [1,1,1];
    multmatrix(mirror_x ? [[-1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]] : identity4())
    {
        // central spine
        spine(SPINE_LENGTH, CORE_RADIUS);

        // Stage 01 MMS at center
        mms();

        // Stage 02 Logistics Core offset along spine
        translate([LOGI_OFFSET, 0, 0])
            logistics_core();

        // Stage 03 Re-tasking Frame at opposite spine node
        translate([-LOGI_OFFSET*0.6, 0, 0])
            retasking_frame();

        // payload modules mounted on frame corners
        if (SHOW_MODULES) {
            for (sy = [-1, 1])
                for (sz = [-1, 1])
                    translate([-LOGI_OFFSET*0.6, sy*FRAME_SPAN*0.7, sz*FRAME_SPAN*0.7])
                        payload_module();
        }

        // solar wings
        if (SHOW_SOLAR) {
            solar_wing(1);
            solar_wing(-1);
        }
    }
}

// identity 4x4 (helper, since multmatrix wants a matrix)
function identity4() = [[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]];

// ------------------------------- Render --------------------------------------
amu_assembly(false);

if (SHOW_DAUGHTER) {
    // daughter unit hinting self-replication, parked on far spine node
    translate([SPINE_LENGTH*0.0, FRAME_SPAN*2.4, 0])
        scale([0.7, 0.7, 0.7])
            amu_assembly(false);
}

// ----------------------------- Build tips ------------------------------------
// Render: F6 (CGAL) for a clean solid; F5 for preview.
// Export STL: F6 then File > Export > STL for slicing / 3D print of a desk model.
// Tune the user params at top to re-proportion stages without touching geometry.
