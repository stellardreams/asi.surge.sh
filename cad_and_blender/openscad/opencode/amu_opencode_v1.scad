// =============================================================================
// AMU — Autonomous Manufacturing Unit (OpenCode v1.1 — Heritage-matched)
// Awakened Imagination Group — TRL 1 parametric sketch
// Location: cad_and_blender/openscad/opencode/amu_opencode_v1.scad
// Source visuals: https://asi.surge.sh/amu (2026-09-16 ingest)
//   - Manufacturing Units: tan cylinder R6×L14, 4× solar (2 per side), double-rail spine, blue Z-arm, side door 6×6
//   - Orbiting Greenhouses: transparent hull, 8× interior shelves with sprouts, large side solar, blue Z-arm
//   - Heritage Greenhouses: 6-tier vertical farming interior, central aisle
// Target: OpenSCAD >= 2021.01 | Preview F5 | Render F6 → Export STL/3MF/DXF
// Branch: main-dev → master (see docs/release_notes/v1.1.md:1)
// =============================================================================

// ---------------------------- User-tunable params ----------------------------
MMS_RADIUS      = 6.0;    // hull radius (tan cylinder)
MMS_LENGTH      = 14.0;   // hull length (X) — scale to 80mm desk model via 5.7×
CORE_RADIUS     = 0.18;   // single spine rail radius (double-rail uses 2×)
SPINE_LENGTH    = 30.0;   // central double-rail spine length
WALL_THICK      = 0.4;    // hull wall for hollow feel (visual only)

LOGI_RADIUS     = 3.4;    // logistics tank radius (if standalone core)
LOGI_LENGTH     = 9.0;
LOGI_OFFSET     = 11.0;

DOOR_W          = 2.2;    // side door cavity width (maps to 6mm at 5.7×)
DOOR_H          = 2.2;    // door height
DOOR_EDGE       = 3.5;    // distance from hull end to door center

BAY_COUNT       = 3;
BAY_RADIUS      = 1.1;
BAY_LENGTH      = 6.0;

FRAME_SPAN      = 10.0;
FRAME_THICK     = 0.6;
MODULE_SIZE     = 4.0;

SOLAR_W         = 7.0;    // per-panel length (heritage: large blue pane 8×4)
SOLAR_H         = 3.5;    // per-panel width
SOLAR_GAP       = 1.2;    // gap between the 2 panels per side
SOLAR_OFFSET    = 9.0;

GH_TIERS        = 8;      // orbiting greenhouse shelf count (image: 8)
GH_SHELF_THICK  = 0.15;
GH_SPROUT_R     = 0.08;

SHOW_HULL       = true;
SHOW_SPINE      = true;
SHOW_SOLAR      = true;   // now 4 panels per unit (2 per side) per image
SHOW_DOOR       = true;
SHOW_GH         = true;   // show interior greenhouse shelves when enabled
SHOW_ARM        = true;   // blue Z-arm (heritage signature)
SHOW_DAUGHTER   = true;
SHOW_TRANSPARENT= true;   // % transparent hull hint

EPS = 0.01;

// ------------------------------ Helpers --------------------------------------

module spine_double(len) {
    // double-rail spine as in Manufacturing Units image (two parallel rails)
    for (dz = [-0.6, 0.6])
        translate([0, 0, dz])
            rotate([0, 90, 0])
                cylinder(h = len, r = CORE_RADIUS, center = true, $fn = 16);
}

module torus(r_major, r_minor, seg = 48) {
    rotate_extrude(convexity = 10, $fn = seg)
        translate([r_major, 0, 0])
            circle(r = r_minor, $fn = seg);
}

module mms_hull() {
    difference() {
        union() {
            // main tan cylinder + domed caps
            rotate([0, 90, 0])
                cylinder(h = MMS_LENGTH, r1 = MMS_RADIUS*0.75, r2 = MMS_RADIUS, center = true, $fn = 48);
            translate([MMS_LENGTH/2, 0, 0]) sphere(r = MMS_RADIUS*0.75, $fn = 32);
            translate([-MMS_LENGTH/2, 0, 0]) sphere(r = MMS_RADIUS*0.75, $fn = 32);
            // ring nodes
            for (i = [-1, 0, 1])
                translate([i * MMS_LENGTH*0.28, 0, 0])
                    rotate([0, 90, 0])
                        torus(r_major = MMS_RADIUS*0.78, r_minor = 0.22);
        }
        // side door cavity (as in Blender generate_amu.py:75 — 6×6 at 20mm from edge)
        if (SHOW_DOOR) {
            for (sx = [-1, 1])
                translate([sx * (MMS_LENGTH/2 - DOOR_EDGE), -MMS_RADIUS*0.55, MMS_RADIUS*0.45])
                    cube([DOOR_W, DOOR_H, WALL_THICK*4], center = true);
        }
    }
    // transparent hull hint
    if (SHOW_TRANSPARENT)
        % union() {
            rotate([0, 90, 0])
                cylinder(h = MMS_LENGTH*1.02, r = MMS_RADIUS*1.01, center = true, $fn = 48);
            translate([MMS_LENGTH/2, 0, 0]) sphere(r = MMS_RADIUS*0.76, $fn = 32);
            translate([-MMS_LENGTH/2, 0, 0]) sphere(r = MMS_RADIUS*0.76, $fn = 32);
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

// heritage greenhouse interior: 8 horizontal shelves with sprouts + blue Z-arm
module greenhouse_interior() {
    // 8 tiers inside hull (Orbiting Greenhouses image)
    hull_len = MMS_LENGTH * 0.9;
    tier_pitch = (MMS_RADIUS*1.4) / GH_TIERS;
    for (t = [0 : GH_TIERS-1]) {
        z = -MMS_RADIUS*0.65 + t * tier_pitch;
        // shelf
        translate([0, 0, z])
            cube([hull_len, MMS_RADIUS*1.5, GH_SHELF_THICK], center = true);
        // sprouts (small green cubes) — spaced along X/Y
        for (x = [-hull_len*0.4 : hull_len*0.22 : hull_len*0.4])
            for (y = [-MMS_RADIUS*0.5 : MMS_RADIUS*0.5 : MMS_RADIUS*0.5])
                translate([x, y, z + GH_SHELF_THICK/2 + GH_SPROUT_R])
                    color([0.3, 0.7, 0.3])
                        cube([GH_SPROUT_R*1.8, GH_SPROUT_R*1.8, GH_SPROUT_R*2], center = true);
    }
    // blue Z-arm (signature in all 3 renders) — 3 segments, blue
    if (SHOW_ARM) {
        color([0.12, 0.45, 0.78])
            union() {
                // segment 1: from door to spine
                translate([MMS_LENGTH*0.18, -MMS_RADIUS*0.55, MMS_RADIUS*0.2])
                    rotate([0, 25, 0])
                        cube([4.5, 0.35, 0.35], center = true);
                // segment 2: diagonal Z kink
                translate([MMS_LENGTH*0.08, -MMS_RADIUS*0.18, 0])
                    rotate([0, -35, 0])
                        cube([3.8, 0.35, 0.35], center = true);
                // segment 3: to spine rail
                translate([-MMS_LENGTH*0.04, 0.05, -0.35])
                    rotate([0, 15, 0])
                        cube([3.2, 0.35, 0.35], center = true);
                // end effector (small blue cube at spine)
                translate([-MMS_LENGTH*0.12, 0.1, -0.6])
                    cube([0.7, 0.7, 0.7], center = true);
            }
    }
}

module solar_wing_dual(sign) {
    // 2 panels per side as in Manufacturing Units image (dual black wings)
    for (p = [-1, 1]) {
        translate([SOLAR_OFFSET * sign, 0, p * (SOLAR_H/2 + SOLAR_GAP/2)])
            rotate([0, 0, 90])
                color([0.08, 0.08, 0.12])
                    cube([SOLAR_W, SOLAR_H, 0.18], center = true);
    }
    // single strut to hull (as in image)
    translate([SOLAR_OFFSET*sign*0.5, 0, 0])
        cube([SOLAR_OFFSET, 0.32, 0.32], center = true);
}

module amu_assembly() {
    if (SHOW_SPINE) spine_double(SPINE_LENGTH);
    if (SHOW_HULL) {
        mms_hull();
        if (SHOW_GH) greenhouse_interior();
    }
    // logistics core offset (for freighter variant) — optional
    // translate([LOGI_OFFSET, 0, 0]) logistics_core();

    if (SHOW_SOLAR) { solar_wing_dual(1); solar_wing_dual(-1); }
}

// ------------------------------- Assembly variants ---------------------------
// Single unit (as in top-left of Manufacturing Units)
module variant_single() { amu_assembly(); }

// Two units linked by spine (bottom-left image)
module variant_dual() {
    translate([-SPINE_LENGTH/2 - MMS_LENGTH/2, 0, 0]) amu_assembly();
    translate([ SPINE_LENGTH/2 + MMS_LENGTH/2, 0, 0]) amu_assembly();
    // spine already spans, but emphasize double-rail connection
}

// Four units in X (right side of Manufacturing Units)
module variant_quad() {
    for (a = [45, 135, 225, 315])
        rotate([0, 0, a])
            translate([SPINE_LENGTH*0.65, 0, 0])
                rotate([0, 90, 0])
                    amu_assembly();
    // central crossing spine
    spine_double(SPINE_LENGTH*1.8);
}

// ------------------------------- Render --------------------------------------
// Choose variant: single / dual / quad
// variant_single(); // default
variant_single();

if (SHOW_DAUGHTER) {
    // daughter replication hint — 0.7× scaled unit parked off-spine (top-right image logic)
    translate([0, FRAME_SPAN*2.4, 0])
        scale([0.7, 0.7, 0.7])
            amu_assembly();
}

// Build tips:
// Preview: F5 | Render: F6 (CGAL) | Export: File > Export > STL / 3MF / DXF
// For desk model 80×30×30mm: scale([5.7, 5.7, 5.7]) the assembly
// Params at top only — heritage greenhouse tuned via GH_TIERS=8, SHOW_GH, SHOW_ARM
// Ingested: https://asi.surge.sh/amu (2026-09-16) — 3 renders + heritage greenhouse
// Signed: [OpenCode](https://opencode.ai), powered by opencode/muse-spark-1.2-contributor-free — 2026-09-16
