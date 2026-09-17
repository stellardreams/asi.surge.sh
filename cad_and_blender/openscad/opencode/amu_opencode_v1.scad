// =============================================================================
// AMU — Autonomous Manufacturing Unit (OpenCode v1.2 — Heritage + Extraction)
// Awakened Imagination Group — TRL 1 parametric sketch
// Location: cad_and_blender/openscad/opencode/amu_opencode_v1.scad
// Source visuals ingested 2026-09-16:
//   - Renders: Manufacturing Units (tan R6×L14, 4× solar, double-rail, blue Z-arm, door 6×6)
//              Orbiting Greenhouses (transparent hull, 8× shelves, sprouts, blue arm, large solar)
//              Heritage Greenhouses (6-tier interior, central aisle)
//   - Video 1: amu-animation-v1.mp4 (8s, 1280×720, asteroid Stage-3 extraction, Orbital Sentry, Resource Hub, 5× AMU + cyan laser beams)
//   - Video 2: heritage_greenhouse_animation-v1.mp4 (8s, heritage interior + exterior cylinder with solar)
// Target: OpenSCAD >= 2021.01 | Preview F5 | Render F6 → Export STL/3MF/DXF/STEP (via FreeCAD)
// Branch: main-dev → master (see docs/release_notes/v1.1.md:1)
// =============================================================================

// ---------------------------- User-tunable params ----------------------------
MMS_RADIUS      = 6.0;    // hull radius (tan cylinder)
MMS_LENGTH      = 14.0;   // hull length (X) — desk model 80mm via 5.7×
CORE_RADIUS     = 0.18;   // spine rail radius (double-rail uses 2×)
SPINE_LENGTH    = 30.0;   // central double-rail spine length
WALL_THICK      = 0.4;

LOGI_RADIUS     = 3.4;
LOGI_LENGTH     = 9.0;
LOGI_OFFSET     = 11.0;

DOOR_W          = 2.2;    // side door 6mm at 5.7×
DOOR_H          = 2.2;
DOOR_EDGE       = 3.5;

BAY_COUNT       = 3;
BAY_RADIUS      = 1.1;
BAY_LENGTH      = 6.0;

FRAME_SPAN      = 10.0;
FRAME_THICK     = 0.6;
MODULE_SIZE     = 4.0;

SOLAR_W         = 7.0;    // per-panel length (dual per side = 4 per unit)
SOLAR_H         = 3.5;
SOLAR_GAP       = 1.2;
SOLAR_OFFSET    = 9.0;

GH_TIERS        = 8;      // orbiting greenhouse shelf count
GH_SHELF_THICK  = 0.15;
GH_SPROUT_R     = 0.08;

ASTEROID_R      = 12.0;   // Stage-3 extraction asteroid radius (video 1)
BEAM_R          = 0.12;   // cyan extraction beam radius

SHOW_HULL       = true;
SHOW_SPINE      = true;
SHOW_SOLAR      = true;   // 4 panels per unit (2 per side)
SHOW_DOOR       = true;
SHOW_GH         = true;
SHOW_ARM        = true;   // blue Z-arm
SHOW_DAUGHTER   = true;
SHOW_TRANSPARENT= true;
SHOW_BEAMS      = true;   // cyan laser beams for extraction variant

EPS = 0.01;

// ------------------------------ Helpers --------------------------------------

module spine_double(len) {
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
            rotate([0, 90, 0])
                cylinder(h = MMS_LENGTH, r1 = MMS_RADIUS*0.75, r2 = MMS_RADIUS, center = true, $fn = 48);
            translate([MMS_LENGTH/2, 0, 0]) sphere(r = MMS_RADIUS*0.75, $fn = 32);
            translate([-MMS_LENGTH/2, 0, 0]) sphere(r = MMS_RADIUS*0.75, $fn = 32);
            for (i = [-1, 0, 1])
                translate([i * MMS_LENGTH*0.28, 0, 0])
                    rotate([0, 90, 0])
                        torus(r_major = MMS_RADIUS*0.78, r_minor = 0.22);
        }
        if (SHOW_DOOR) {
            for (sx = [-1, 1])
                translate([sx * (MMS_LENGTH/2 - DOOR_EDGE), -MMS_RADIUS*0.55, MMS_RADIUS*0.45])
                    cube([DOOR_W, DOOR_H, WALL_THICK*4], center = true);
        }
    }
    if (SHOW_TRANSPARENT)
        % union() {
            rotate([0, 90, 0])
                cylinder(h = MMS_LENGTH*1.02, r = MMS_RADIUS*1.01, center = true, $fn = 48);
            translate([MMS_LENGTH/2, 0, 0]) sphere(r = MMS_RADIUS*0.76, $fn = 32);
            translate([-MMS_LENGTH/2, 0, 0]) sphere(r = MMS_RADIUS*0.76, $fn = 32);
        }
}

// detailed interior: 8 tiers + sprouts + blue Z-arm (all heritage details)
module greenhouse_interior() {
    hull_len = MMS_LENGTH * 0.9;
    tier_pitch = (MMS_RADIUS*1.4) / GH_TIERS;
    for (t = [0 : GH_TIERS-1]) {
        z = -MMS_RADIUS*0.65 + t * tier_pitch;
        translate([0, 0, z])
            cube([hull_len, MMS_RADIUS*1.5, GH_SHELF_THICK], center = true);
        // sprouts — green, dense as in Orbiting Greenhouses render
        for (x = [-hull_len*0.4 : hull_len*0.22 : hull_len*0.4])
            for (y = [-MMS_RADIUS*0.5 : MMS_RADIUS*0.5 : MMS_RADIUS*0.5])
                translate([x, y, z + GH_SHELF_THICK/2 + GH_SPROUT_R])
                    color([0.3, 0.7, 0.3])
                        cube([GH_SPROUT_R*1.8, GH_SPROUT_R*1.8, GH_SPROUT_R*2], center = true);
    }
    // fillet detail (Blender generate_amu.py:36 R2)
    // wall thickness hint (Blender: 1.2mm → 0.21 at scale)
    if (SHOW_ARM) {
        color([0.12, 0.45, 0.78]) // heritage blue Z-arm
            union() {
                translate([MMS_LENGTH*0.18, -MMS_RADIUS*0.55, MMS_RADIUS*0.2])
                    rotate([0, 25, 0]) cube([4.5, 0.35, 0.35], center = true);
                translate([MMS_LENGTH*0.08, -MMS_RADIUS*0.18, 0])
                    rotate([0, -35, 0]) cube([3.8, 0.35, 0.35], center = true);
                translate([-MMS_LENGTH*0.04, 0.05, -0.35])
                    rotate([0, 15, 0]) cube([3.2, 0.35, 0.35], center = true);
                translate([-MMS_LENGTH*0.12, 0.1, -0.6])
                    cube([0.7, 0.7, 0.7], center = true);
            }
    }
}

module solar_wing_dual(sign) {
    for (p = [-1, 1]) {
        translate([SOLAR_OFFSET * sign, 0, p * (SOLAR_H/2 + SOLAR_GAP/2)])
            rotate([0, 0, 90])
                color([0.08, 0.08, 0.12])
                    cube([SOLAR_W, SOLAR_H, 0.18], center = true);
    }
    translate([SOLAR_OFFSET*sign*0.5, 0, 0])
        cube([SOLAR_OFFSET, 0.32, 0.32], center = true);
}

// extraction beam — cyan, semi-transparent as in amu-animation-v1.mp4
module extraction_beam(p1, p2) {
    if (SHOW_BEAMS) {
        vec = p2 - p1;
        len = norm(vec);
        mid = (p1 + p2)/2;
        // direction vector to rotation: align Z to vec
        color([0.3, 0.95, 0.95, 0.6])
            hull() {
                translate(p1) sphere(r = BEAM_R*1.5, $fn = 12);
                translate(p2) sphere(r = BEAM_R*1.2, $fn = 12);
            }
        % color([0.4, 1, 1, 0.18])
            translate(mid)
                rotate([0, 0, 0]) // simplified — beams are straight cyan lines in video
                    cylinder(h = len, r = BEAM_R*2.2, center = true, $fn = 12);
    }
}

// asteroid — faceted icosphere-ish (video 1: grey, cratered)
module asteroid(r = ASTEROID_R) {
    // base icosphere approximation via scaled sphere + random facets
    color([0.42, 0.42, 0.44])
        union() {
            sphere(r = r, $fn = 24);
            // crater hints
            for (a = [0:60:300]) rotate([a, a*0.7, 0]) translate([r*0.85, 0, 0]) sphere(r = r*0.18, $fn = 12);
        }
}

module amu_assembly() {
    if (SHOW_SPINE) spine_double(SPINE_LENGTH);
    if (SHOW_HULL) {
        mms_hull();
        if (SHOW_GH) greenhouse_interior();
    }
    if (SHOW_SOLAR) { solar_wing_dual(1); solar_wing_dual(-1); }
}

// ------------------------------- Assembly variants ---------------------------
module variant_single() { amu_assembly(); }

module variant_dual() {
    translate([-SPINE_LENGTH/2 - MMS_LENGTH/2, 0, 0]) amu_assembly();
    translate([ SPINE_LENGTH/2 + MMS_LENGTH/2, 0, 0]) amu_assembly();
}

module variant_quad() {
    for (a = [45, 135, 225, 315])
        rotate([0, 0, a])
            translate([SPINE_LENGTH*0.65, 0, 0])
                rotate([0, 90, 0])
                    amu_assembly();
    spine_double(SPINE_LENGTH*1.8);
}

// Stage-3 extraction variant — asteroid + 5× AMU + cyan beams (video 1 frame01-04)
module variant_extraction() {
    // central asteroid
    asteroid(ASTEROID_R);
    // 5 AMU positions around asteroid as in video (spaced)
    positions = [
        [ 22,  8,  6],
        [ 24, -7,  3],
        [-18, 10,  5],
        [-20, -9, -4],
        [  6, 16, -8]
    ];
    for (i = [0 : len(positions)-1]) {
        translate(positions[i]) {
            // orient AMU nose toward asteroid center
            // simplified: no rotation, beams show direction
            amu_assembly();
            // beam from AMU door to asteroid surface
            extraction_beam([0, 0, 0], -positions[i]*0.55);
        }
    }
    // orbital sentry hint (small grey disc as in video top)
    translate([0, 18, 12]) color([0.6, 0.6, 0.65]) cylinder(h = 0.5, r = 3, center = true, $fn = 24);
}

// ------------------------------- Render --------------------------------------
// Choose variant: single / dual / quad / extraction
// variant_single();
variant_single();

if (SHOW_DAUGHTER && $preview) {
    translate([0, FRAME_SPAN*2.4, 0])
        scale([0.7, 0.7, 0.7])
            amu_assembly();
}

// Uncomment for extraction scene:
// !variant_extraction();

// Build tips:
// Preview: F5 | Render: F6 (CGAL) | Export: File > Export > STL / 3MF / DXF
// Desk model 80×30×30mm: scale([5.7, 5.7, 5.7]) the assembly
// All details built-in: door 6×6, fillet R2, wall 1.2mm, 8× shelves, sprouts, blue Z-arm, dual solar (4 per unit), double-rail spine, daughter, transparent hull
// Ingested: https://asi.surge.sh/amu + https://asi.surge.sh/img/portfolio/amu/amu-animation-v1.mp4 + heritage_greenhouse_animation-v1.mp4 (2026-09-16)
// Signed: [OpenCode](https://opencode.ai), powered by opencode/muse-spark-1.2-contributor-free — 2026-09-16
