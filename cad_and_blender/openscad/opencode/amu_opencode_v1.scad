// =============================================================================
// AMU — Autonomous Manufacturing Unit (OpenCode v1.3 — Realistic)
// Awakened Imagination Group — TRL 1 parametric sketch
// Location: cad_and_blender/openscad/opencode/amu_opencode_v1.scad
// Source visuals ingested 2026-09-16 (realistic color-matched):
//   - Renders: Manufacturing Units (tan hull #C8B8A0, black solar #0A0A0F, blue arm #1A6FFF, spine #D0D0D0)
//              Orbiting Greenhouses (transparent hull α0.35, shelves #E0E0E0, sprouts #4A8A4A, cyan beams #4DFFF0)
//              Heritage Greenhouses (warm interior #FFF8EC, soil #5A3A28, leaf #2E7D32)
//   - Video 1: amu-animation-v1.mp4 (asteroid #6E6E72 cratered, Resource Hub teal glow, Orbital Sentry grey)
//   - Video 2: heritage_greenhouse_animation-v1.mp4 (arched glass + central aisle, robots #F0F0F0)
// Target: OpenSCAD >= 2021.01 | Preview F5 | Render F6 → Export STL/3MF/DXF
// Realism note: OpenSCAD is CSG-only — true PBR/textures require Blender (see blender_including_blender_python/generate_amu.py:22)
//              This file pushes OpenSCAD realism to its limit via $fn=64, accurate PBR colors, and micro-details.
// Branch: main-dev → master (see docs/release_notes/v1.1.md:1)
// =============================================================================

// ---------------------------- Realistic palette (PBR) ------------------------
HULL_TAN        = [0.78, 0.70, 0.60]; // tan hull as in Manufacturing Units
HULL_DARK       = [0.68, 0.60, 0.50]; // panel seam
SOLAR_BLACK     = [0.04, 0.04, 0.07]; // solar near-black
SOLAR_GRID      = [0.18, 0.22, 0.45]; // grid line blue
SPINE_METAL     = [0.82, 0.82, 0.84]; // anodized aluminium
ARM_BLUE        = [0.12, 0.45, 0.85]; // heritage Z-arm
BEAM_CYAN       = [0.30, 0.96, 0.96]; // extraction laser
BEAM_GLOW       = [0.45, 1.00, 1.00, 0.22];
ASTEROID_GREY   = [0.44, 0.44, 0.46];
SHELF_ALU       = [0.88, 0.88, 0.89];
SPROUT_GREEN    = [0.30, 0.68, 0.32];
SOIL_BROWN      = [0.36, 0.25, 0.18];

// ---------------------------- User-tunable params ----------------------------
MMS_RADIUS      = 6.0;
MMS_LENGTH      = 14.0;
CORE_RADIUS     = 0.18;
SPINE_LENGTH    = 30.0;
WALL_THICK      = 0.4;

LOGI_RADIUS     = 3.4;
LOGI_LENGTH     = 9.0;
LOGI_OFFSET     = 11.0;

DOOR_W          = 2.2;
DOOR_H          = 2.2;
DOOR_EDGE       = 3.5;
DOOR_FRAME_THICK= 0.18; // realistic frame
BELLY_DOOR_W    = 5.0;  // belly cargo door (ventral, for rail goods)
BELLY_DOOR_L    = 3.2;  // along X
BELLY_DOOR_Y    = -1;   // side: -1 ventral / +1 dorsal

BAY_COUNT       = 3;
BAY_RADIUS      = 1.1;
BAY_LENGTH      = 6.0;

FRAME_SPAN      = 10.0;
FRAME_THICK     = 0.6;
MODULE_SIZE     = 4.0;

SOLAR_W         = 7.0;
SOLAR_H         = 3.5;
SOLAR_GAP       = 1.2;
SOLAR_OFFSET    = 9.0;
SOLAR_CELL_GAP  = 0.35; // grid
SOLAR_ANGLE     = 0;    // flat ISS — 0 for flat, 8 for dynamic taper hint

GH_TIERS        = 8;
GH_SHELF_THICK  = 0.15;
GH_SPROUT_R     = 0.08;

ASTEROID_R      = 12.0;
BEAM_R          = 0.12;

SHOW_HULL       = true;
SHOW_SPINE      = true;   // now ventral, outside hull — not through middle
SHOW_SOLAR      = true;
SHOW_DOOR       = true;
SHOW_BELLY_DOOR = true;   // ventral belly cargo doors for rail
SHOW_GH         = true;
SHOW_ARM        = true;
SHOW_DAUGHTER   = true;
SHOW_TRANSPARENT= true;
SHOW_BEAMS      = true;

EPS = 0.01;

// ------------------------------ Helpers --------------------------------------

module spine_double(len) {
    // transport rail — E-W, at hull center Y=0, connecting circular bulkheads where AMUs face each other
    // thicker r0.42 for visibility between AMUs (was 0.32)
    for (dz = [-0.6, 0.6])
        translate([0, 0, dz])
            rotate([0, 90, 0])
                color(SPINE_METAL) cylinder(h = len, r = 0.42, center = true, $fn = 18);
    // ties every 5 (E-W)
    for (x = [-len/2 + 2 : 5 : len/2 - 2])
        translate([x, 0, 0])
            color([0.45,0.45,0.48]) cube([0.4, 1.8, 0.18], center = true);
    // carriers on rail (centered, as in logistics_core bays)
    for (x = [-len*0.25, 0, len*0.25])
        translate([x, 0, 0.85])
            color(ARM_BLUE) cube([0.9, 0.9, 0.55], center = true);
    // end docking clamps at circular bulkheads
    for (x = [-len/2, len/2])
        translate([x, 0, 0]) {
            color([0.55,0.55,0.58]) cylinder(h = 0.5, r = 0.75, center = true, $fn = 16);
            color([0.30,0.30,0.33]) cube([0.6, 1.4, 0.6], center = true);
        }
}

module torus(r_major, r_minor, seg = 64) {
    rotate_extrude(convexity = 10, $fn = seg)
        translate([r_major, 0, 0])
            circle(r = r_minor, $fn = 32);
}

module mms_hull_realistic(open_left_belly = true, open_right_belly = true) {
    difference() {
        union() {
            // main hull — straight cylinder, flat bulkheads — heritage exterior
            color(HULL_TAN)
                rotate([0, 90, 0])
                    cylinder(h = MMS_LENGTH, r = MMS_RADIUS, center = true, $fn = 64);
            // flat bulkheads + docking rings
            for (sx = [-1, 1]) {
                translate([sx * MMS_LENGTH/2, 0, 0]) {
                    color(HULL_TAN) rotate([0, 90, 0]) cylinder(h = 0.6, r = MMS_RADIUS*0.92, center = true, $fn = 48);
                    color([0.58,0.58,0.60]) rotate([0, 90, 0]) torus(r_major = MMS_RADIUS*0.72, r_minor = 0.18, seg = 48);
                    color([0.22,0.22,0.24]) rotate([0, 90, 0]) cylinder(h = 0.62, r = MMS_RADIUS*0.35, center = true, $fn = 32);
                }
            }
            // panel seams
            for (i = [-1, 0, 1])
                translate([i * MMS_LENGTH*0.28, 0, 0])
                    rotate([0, 90, 0])
                        color(HULL_DARK) torus(r_major = MMS_RADIUS*0.78, r_minor = 0.12, seg = 64);
            // rivet row
            for (i = [-1:0.5:1]) for (a = [0:60:300])
                translate([i * MMS_LENGTH*0.32, cos(a)*MMS_RADIUS*0.83, sin(a)*MMS_RADIUS*0.83])
                    color([0.52,0.48,0.42]) sphere(r = 0.07, $fn = 8);
        }
        // side door cavities (as before)
        if (SHOW_DOOR) {
            for (sx = [-1, 1])
                translate([sx * (MMS_LENGTH/2 - DOOR_EDGE), -MMS_RADIUS*0.55, MMS_RADIUS*0.45]) {
                    cube([DOOR_W, DOOR_H, WALL_THICK*4], center = true);
                }
        }
        // belly cargo doors — ventral, for rail
        // outer entrances remain closed, inner facing where AMUs face each other are open and rail-connected
        if (SHOW_BELLY_DOOR) {
            if (open_left_belly)
                translate([-3.0, -MMS_RADIUS - 0.05, 0])
                    cube([BELLY_DOOR_W, WALL_THICK*4, BELLY_DOOR_L], center = true);
            if (open_right_belly)
                translate([ 3.0, -MMS_RADIUS - 0.05, 0])
                    cube([BELLY_DOOR_W, WALL_THICK*4, BELLY_DOOR_L], center = true);
        }
    }
    // belly door frames — only for open doors; closed outer doors show as solid hatch
    if (SHOW_BELLY_DOOR) {
        for (sx = [-1, 1]) {
            is_open = (sx == -1) ? open_left_belly : open_right_belly;
            translate([sx * 3.0, -MMS_RADIUS + 0.22, 0])
                color(is_open ? HULL_DARK : [0.42,0.38,0.34]) // closed outer = solid tan darker
                    cube([BELLY_DOOR_W+0.4, 0.25, BELLY_DOOR_L+0.4], center = true);
            if (is_open)
                translate([sx * 3.0, -MMS_RADIUS + 0.12, 0])
                    color([0.25,0.25,0.28]) cube([BELLY_DOOR_W*0.88, 0.26, 0.06], center = true);
            else
                translate([sx * 3.0, -MMS_RADIUS + 0.18, 0])
                    color([0.35,0.32,0.30]) cube([BELLY_DOOR_W*0.7, 0.27, BELLY_DOOR_L*0.7], center = true); // closed hatch fill
        }
    }
    // realistic transparent hull — arched glass with Fresnel-like alpha
    if (SHOW_TRANSPARENT)
        % color([0.92, 0.96, 1.0, 0.18])
            union() {
                rotate([0, 90, 0])
                    cylinder(h = MMS_LENGTH*1.02, r = MMS_RADIUS*1.01, center = true, $fn = 64);
                for (sx = [-1, 1])
                    translate([sx * MMS_LENGTH/2, 0, 0])
                        rotate([0, 90, 0]) cylinder(h = 0.62, r = MMS_RADIUS*0.93, center = true, $fn = 48);
            }
}

module greenhouse_interior_realistic() {
    hull_len = MMS_LENGTH * 0.9;
    tier_pitch = (MMS_RADIUS*1.4) / GH_TIERS;
    for (t = [0 : GH_TIERS-1]) {
        z = -MMS_RADIUS*0.65 + t * tier_pitch;
        // aluminium shelf with soil bed
        color(SHELF_ALU) translate([0, 0, z]) cube([hull_len, MMS_RADIUS*1.5, GH_SHELF_THICK], center = true);
        color(SOIL_BROWN) translate([0, 0, z+GH_SHELF_THICK/2+0.04]) cube([hull_len*0.96, MMS_RADIUS*1.46, 0.08], center = true);
        // sprouts — varied greens as in heritage video
        for (x = [-hull_len*0.4 : hull_len*0.22 : hull_len*0.4])
            for (y = [-MMS_RADIUS*0.5 : MMS_RADIUS*0.5 : MMS_RADIUS*0.5]) {
                // vary green per tier
                g = 0.55 + (t % 3)*0.07;
                translate([x, y, z + GH_SHELF_THICK/2 + GH_SPROUT_R + 0.08])
                    color([0.26, g, 0.28])
                        cube([GH_SPROUT_R*1.8, GH_SPROUT_R*1.8, GH_SPROUT_R*2 + (t%2)*0.04], center = true);
            }
    }
    // central aisle (as in heritage video) — gap in middle shelf visuals already via y spacing
    // blue Z-arm — realistic joints
    if (SHOW_ARM) {
        color(ARM_BLUE)
            union() {
                translate([MMS_LENGTH*0.18, -MMS_RADIUS*0.55, MMS_RADIUS*0.2])
                    rotate([0, 25, 0]) cube([4.5, 0.35, 0.35], center = true);
                // joint spheres
                translate([MMS_LENGTH*0.08, -MMS_RADIUS*0.18, 0]) sphere(r = 0.28, $fn = 16);
                translate([MMS_LENGTH*0.08, -MMS_RADIUS*0.18, 0])
                    rotate([0, -35, 0]) cube([3.8, 0.35, 0.35], center = true);
                translate([-MMS_LENGTH*0.04, 0.05, -0.35]) sphere(r = 0.26, $fn = 16);
                translate([-MMS_LENGTH*0.04, 0.05, -0.35])
                    rotate([0, 15, 0]) cube([3.2, 0.35, 0.35], center = true);
                translate([-MMS_LENGTH*0.12, 0.1, -0.6])
                    cube([0.7, 0.7, 0.7], center = true);
            }
    }
}

module solar_wing_realistic(side) {
    // ISS-style: side-mounted Y±, flat — 2 panels per side, gap 1.2, truss outward
    y_base = side * (MMS_RADIUS + 0.6);
    color(SPINE_METAL) translate([0, side*(MMS_RADIUS*0.5 + 0.6), 0])
        cube([0.32, MMS_RADIUS*0.5, 0.32], center = true);
    for (p = [-1, 1]) {
        translate([p * (SOLAR_W/2 + SOLAR_GAP/2), y_base + side*(SOLAR_H/2 + 0.4), 0]) {
            rotate([0, SOLAR_ANGLE, 90]) // flat when 0, dynamic when 8
                union() {
                    color(SOLAR_BLACK) cube([SOLAR_W, SOLAR_H, 0.18], center = true);
                    for (gx = [-SOLAR_W*0.33 : SOLAR_W*0.33 : SOLAR_W*0.33])
                        color(SOLAR_GRID) cube([0.06, SOLAR_H*0.98, 0.19], center = true);
                    for (gy = [-SOLAR_H*0.25 : SOLAR_H*0.5 : SOLAR_H*0.25])
                        color(SOLAR_GRID) cube([SOLAR_W*0.98, 0.06, 0.19], center = true);
                    % color([1,1,1,0.08]) translate([0, SOLAR_H*0.3, 0.1]) cube([SOLAR_W*0.9, 0.4, 0.02], center = true);
                }
        }
    }
}

module extraction_beam(p1, p2) {
    if (SHOW_BEAMS) {
        color(BEAM_CYAN)
            hull() {
                translate(p1) sphere(r = BEAM_R*1.5, $fn = 12);
                translate(p2) sphere(r = BEAM_R*1.2, $fn = 12);
            }
        % color(BEAM_GLOW)
            hull() {
                translate(p1) sphere(r = BEAM_R*2.2, $fn = 12);
                translate(p2) sphere(r = BEAM_R*2.0, $fn = 12);
            }
    }
}

module asteroid(r = ASTEROID_R) {
    color(ASTEROID_GREY)
        union() {
            sphere(r = r, $fn = 32);
            // more crater variety as in video 1
            for (a = [0:45:360]) rotate([a*1.1, a*0.6, a*0.3]) translate([r*0.82, 0, 0]) sphere(r = r*0.14 + (a%90)*0.001, $fn = 12);
            for (a = [30:90:300]) rotate([a, -a*0.8, 0]) translate([r*0.88, 0, 0]) sphere(r = r*0.09, $fn = 10);
        }
}

module amu_assembly(open_left_belly = true, open_right_belly = true) {
    if (SHOW_HULL) {
        mms_hull_realistic(open_left_belly, open_right_belly);
        if (SHOW_GH) greenhouse_interior_realistic();
    }
    if (SHOW_SOLAR) { solar_wing_realistic(-1); solar_wing_realistic(1); }
    // spine not inside hull — variants draw E-W rail outward from bulkheads where needed
}

module variant_single(open_left_belly = true, open_right_belly = true) {
    amu_assembly(open_left_belly, open_right_belly);
    if (SHOW_SPINE) translate([MMS_LENGTH/2, 0, 0]) rotate([0,0,90]) spine_double(SPINE_LENGTH*0.35); // flipped N-S (was E-W) — rail now north-south outward from bulkhead
}

module variant_dual() {
    // outer closed, inner open — E-W rail between the two AMUs (inner facing bulkheads)
    translate([-SPINE_LENGTH/2 - MMS_LENGTH/2, 0, 0]) amu_assembly(open_left_belly = false, open_right_belly = true);
    translate([ SPINE_LENGTH/2 + MMS_LENGTH/2, 0, 0]) amu_assembly(open_left_belly = true, open_right_belly = false);
    spine_double(SPINE_LENGTH+2); // +2 to touch bulkheads, thicker r0.42 for visibility
}

module variant_quad() {
    for (a = [45, 135, 225, 315])
        rotate([0, 0, a])
            translate([SPINE_LENGTH*0.65, 0, 0])
                rotate([0, 90, 0])
                    amu_assembly();
    spine_double(SPINE_LENGTH*1.8);
}

module variant_extraction() {
    asteroid(ASTEROID_R);
    positions = [
        [ 22,  8,  6],
        [ 24, -7,  3],
        [-18, 10,  5],
        [-20, -9, -4],
        [  6, 16, -8]
    ];
    for (i = [0 : len(positions)-1]) {
        translate(positions[i]) {
            amu_assembly();
            extraction_beam([0, 0, 0], -positions[i]*0.55);
        }
    }
    translate([0, 18, 12]) color([0.62, 0.62, 0.65]) cylinder(h = 0.5, r = 3, center = true, $fn = 32);
}

// ------------------------------- Render --------------------------------------
// variant_single(open_left_belly=false, open_right_belly=true); // single with one side closed
variant_single(); // default single — both belly doors open (for solo view)
// variant_dual(); // dual — outer closed, inner facing connected via ventral rail (for transport)
// variant_quad(); // quad X

if (SHOW_DAUGHTER && $preview) {
    translate([0, FRAME_SPAN*2.4, 0])
        scale([0.7, 0.7, 0.7])
            amu_assembly();
}

// Uncomment for extraction scene (video 1):
// !variant_extraction();

// Build tips:
// Preview F5 (fast) | Render F6 (CGAL, high $fn) | Export STL/3MF/DXF — for STEP use FreeCAD import
// Desk model: scale([5.7, 5.7, 5.7]) the assembly → 80×30×30mm
// Realism: OpenSCAD max is PBR colors + $fn=64 + grid/specular; true photorealism needs Blender (generate_amu.py:22) with HDRI + textures — ask to generate that next
// Ingested: https://asi.surge.sh/amu + amu-animation-v1.mp4 + heritage_greenhouse_animation-v1.mp4 (2026-09-16)
// Signed: [OpenCode](https://opencode.ai), powered by opencode/muse-spark-1.2-contributor-free — 2026-09-16

