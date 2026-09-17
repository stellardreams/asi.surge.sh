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
MMS_LENGTH      = 17.92; // was 14.0, +14% per side (28% total) per feedback
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

ROOF_HATCH_L    = 8.0;  // dorsal Shuttle payload bay — length along X (shorter than hull)
ROOF_HATCH_W    = 5.0;  // width along Z (dorsal opening, split 2x doors)
ROOF_HATCH_ANGLE= 155;  // 0=closed flush, 140-175=Shuttle open (clamshell outward)
ROOF_HATCH_X    = 2.8;  // offset from hull center along X — 0=center, ±3-4=between middle & side bulkhead (tunable)
SHOW_ROOF_HATCH = true; // dorsal roof — Space Shuttle cargo bay doors

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
SHOW_BELLY_DOOR = true;   // ventral belly cargo doors for rail (kept as-is)
SHOW_GH         = true;
SHOW_ARM        = true;
SHOW_DAUGHTER   = true;
SHOW_TRANSPARENT= true;
SHOW_BEAMS      = true;
ROOF_HATCH_OPEN = true;   // true=Shuttle open (155° clamshell), false=closed flush
HATCH_HINGE_SIDE= 1;       // legacy single-hinge compat (unused for shuttle dual doors)

EPS = 0.01;

// ------------------------------ Helpers --------------------------------------

module spine_double(len) {
    // transport rail — E-W, slightly out from hull center (Y=1.2) for visibility between AMUs
    y_out = 1.2; // out a little bit per feedback
    for (dz = [-0.6, 0.6])
        translate([0, y_out, dz])
            rotate([0, 90, 0])
                color(SPINE_METAL) cylinder(h = len, r = 0.42, center = true, $fn = 18);
    // ties every 5
    for (x = [-len/2 + 2 : 5 : len/2 - 2])
        translate([x, y_out, 0])
            color([0.45,0.45,0.48]) cube([0.4, 1.8, 0.18], center = true);
    // carriers
    for (x = [-len*0.25, 0, len*0.25])
        translate([x, y_out, 0.85])
            color(ARM_BLUE) cube([0.9, 0.9, 0.55], center = true);
    // end clamps at bulkheads
    for (x = [-len/2, len/2])
        translate([x, y_out, 0]) {
            color([0.55,0.55,0.58]) cylinder(h = 0.5, r = 0.75, center = true, $fn = 16);
            color([0.30,0.30,0.33]) cube([0.6, 1.4, 0.6], center = true);
        }
}

module torus(r_major, r_minor, seg = 64) {
    rotate_extrude(convexity = 10, $fn = seg)
        translate([r_major, 0, 0])
            circle(r = r_minor, $fn = 32);
}

module mms_hull_realistic(open_left_belly = true, open_right_belly = true, roof_open = ROOF_HATCH_OPEN, roof_ang = ROOF_HATCH_ANGLE) {
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
        // dorsal Shuttle payload bay opening — cut through top wall when doors exist
        // kept separate from belly doors; offset ROOF_HATCH_X from center (between middle & side)
        if (SHOW_ROOF_HATCH) {
            translate([ROOF_HATCH_X, MMS_RADIUS + 0.05, 0])
                cube([ROOF_HATCH_L, WALL_THICK*4, ROOF_HATCH_W], center = true);
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
    // dorsal roof — Space Shuttle payload bay doors (dual clamshell, split at centerline Z=0)
    // offset ROOF_HATCH_X from hull center — between middle (0) and bulkhead (≈8.96), keeps entrances where they were
    if (SHOW_ROOF_HATCH) {
        ang = roof_open ? roof_ang : 0;
        // outer coaming / frame around opening (always) — at ROOF_HATCH_X
        color(HULL_DARK)
            difference() {
                translate([ROOF_HATCH_X, MMS_RADIUS + 0.18, 0])
                    cube([ROOF_HATCH_L+0.6, 0.22, ROOF_HATCH_W+0.6], center = true);
                translate([ROOF_HATCH_X, MMS_RADIUS + 0.05, 0])
                    cube([ROOF_HATCH_L+0.08, 0.30, ROOF_HATCH_W+0.08], center = true);
            }
        // rubber seal + centerline seal between two doors
        color([0.18,0.18,0.20]) {
            translate([ROOF_HATCH_X, MMS_RADIUS + 0.08, 0])
                difference() {
                    cube([ROOF_HATCH_L+0.22, 0.08, ROOF_HATCH_W+0.22], center = true);
                    cube([ROOF_HATCH_L-0.12, 0.10, ROOF_HATCH_W-0.12], center = true);
                }
            translate([ROOF_HATCH_X, MMS_RADIUS + 0.12, 0])
                cube([ROOF_HATCH_L+0.22, 0.06, 0.14], center = true);
        }
        // two hinged shuttle doors — clamshell outward from center, at ROOF_HATCH_X
        for (side = [-1, 1]) {
            hinge_z = side * ROOF_HATCH_W/2;
            door_w  = ROOF_HATCH_W/2 - 0.04;
            translate([ROOF_HATCH_X, MMS_RADIUS, hinge_z]) {
                rotate([side * ang, 0, 0])
                    translate([0, 0, -side * door_w/2]) {
                        // main door plate
                        color(HULL_TAN)
                            cube([ROOF_HATCH_L, 0.26, door_w], center = true);
                        // interior lighter (inside when open)
                        color([0.82,0.75,0.66])
                            translate([0, -0.02, 0])
                                cube([ROOF_HATCH_L-0.15, 0.04, door_w-0.15], center = true);
                        // longitudinal stiffeners (shuttle-like)
                        color([0.68,0.65,0.60])
                            for (lx = [-ROOF_HATCH_L*0.35, 0, ROOF_HATCH_L*0.35])
                                translate([lx, 0.04, 0]) cube([0.14, 0.04, door_w*0.88], center = true);
                        // transverse frame
                        color([0.68,0.65,0.60])
                            cube([ROOF_HATCH_L*0.92, 0.04, 0.12], center = true);
                        // radiator panels on inside (shuttle doors have radiators inside)
                        if (roof_open) {
                            color([0.92,0.92,0.94])
                                translate([0, 0.15, 0]) cube([ROOF_HATCH_L*0.85, 0.03, door_w*0.75], center = true);
                            color([0.75,0.75,0.78])
                                for (gx = [-ROOF_HATCH_L*0.28 : ROOF_HATCH_L*0.28 : ROOF_HATCH_L*0.28])
                                    translate([gx, 0.16, 0]) cube([0.03, 0.04, door_w*0.73], center = true);
                        } else {
                            // exterior centreline latches when closed
                            color([0.92,0.92,0.96])
                                for (lx = [-ROOF_HATCH_L*0.38, 0, ROOF_HATCH_L*0.38])
                                    translate([lx, 0.16, side*door_w*0.38]) cube([0.16, 0.08, 0.22], center = true);
                        }
                    }
                // hinge barrels (3 per side like shuttle)
                for (hx = [-ROOF_HATCH_L*0.42, 0, ROOF_HATCH_L*0.42]) {
                    translate([hx, 0.14, 0])
                        rotate([0, 90, 0])
                            color([0.55,0.55,0.58]) cylinder(h = 0.55, r = 0.16, center = true, $fn = 16);
                    translate([hx, 0.14, 0])
                        rotate([0, 90, 0])
                            color([0.35,0.35,0.38]) cylinder(h = 0.66, r = 0.06, center = true, $fn = 12);
                }
                // push struts / actuators when open
                if (roof_open) {
                    for (sx = [-1, 1]) {
                        color([0.70,0.70,0.75])
                            hull() {
                                translate([sx*ROOF_HATCH_L*0.40, 0.12, -side*door_w*0.28])
                                    sphere(r = 0.055, $fn = 8);
                                translate([sx*ROOF_HATCH_L*0.40, 0.08 - side*sin(ang)*door_w*0.42, side*cos(ang)*door_w*0.42 - side*door_w*0.28])
                                    sphere(r = 0.045, $fn = 8);
                            }
                    }
                }
            }
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
    // ISS-style: side-mounted Y±9.2, flat — 2 panels per side, gap 1.2, attached but clears rail Y=1.2
    y_base = side * (MMS_RADIUS + 1.5); // 6+1.5=7.5, panels at 9.65
    color(SPINE_METAL) translate([0, side*(MMS_RADIUS*0.5 + 1.0), 0])
        cube([0.32, MMS_RADIUS*0.5 + 0.6, 0.32], center = true);
    for (p = [-1, 1]) {
        translate([p * (SOLAR_W/2 + SOLAR_GAP/2), y_base + side*(SOLAR_H/2 + 0.4), 0]) { // center at Y±9.65
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

module amu_assembly(open_left_belly = true, open_right_belly = true, roof_open = ROOF_HATCH_OPEN, roof_ang = ROOF_HATCH_ANGLE) {
    if (SHOW_HULL) {
        mms_hull_realistic(open_left_belly, open_right_belly, roof_open, roof_ang);
        if (SHOW_GH) greenhouse_interior_realistic();
    }
    if (SHOW_SOLAR) { solar_wing_realistic(-1); solar_wing_realistic(1); }
    // spine not inside hull — variants draw E-W rail outward from bulkheads where needed
}

module variant_single(open_left_belly = true, open_right_belly = true, roof_open = ROOF_HATCH_OPEN) {
    amu_assembly(open_left_belly, open_right_belly, roof_open, ROOF_HATCH_ANGLE);
    if (SHOW_SPINE) translate([MMS_LENGTH/2, 0, 0]) rotate([0,0,90]) spine_double(SPINE_LENGTH*0.35); // flipped N-S (was E-W) — rail now north-south outward from bulkhead
}

module variant_dual(roof_open = ROOF_HATCH_OPEN) {
    // outer closed, inner open — AMUs rotated 90° (now N-S), rail stays E-W between them
    // roof hatches open Shuttle-style (clamshell) by default so greenhouse visible from top
    gap_extra = 6;
    translate([-SPINE_LENGTH/2 - MMS_LENGTH/2 - gap_extra/2, 0, 0]) rotate([0,0,90]) amu_assembly(open_left_belly = false, open_right_belly = true, roof_open = roof_open, roof_ang = ROOF_HATCH_ANGLE);
    translate([ SPINE_LENGTH/2 + MMS_LENGTH/2 + gap_extra/2, 0, 0]) rotate([0,0,90]) amu_assembly(open_left_belly = true, open_right_belly = false, roof_open = roof_open, roof_ang = ROOF_HATCH_ANGLE);
    spine_double(SPINE_LENGTH+2+gap_extra); // E-W rail unchanged
}

module variant_quad(roof_open = ROOF_HATCH_OPEN) {
    for (a = [45, 135, 225, 315])
        rotate([0, 0, a])
            translate([SPINE_LENGTH*0.65, 0, 0])
                rotate([0, 90, 0])
                    amu_assembly(roof_open = roof_open, roof_ang = ROOF_HATCH_ANGLE);
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
variant_dual(roof_open = true); // default — rail between 2 AMUs (E-W, Y=1.2, r0.42) + Shuttle bay doors open 155° clamshell — outer closed, inner facing connected
// variant_dual(roof_open = false); // closed roof (flush, doors meet at centerline)
// variant_single(roof_open = true);  // single AMU — shuttle bay open (greenhouse + arm visible)
// variant_single(roof_open = false); // single closed
// variant_quad(roof_open = true);

if (SHOW_DAUGHTER && $preview && false) {
    translate([0, FRAME_SPAN*3.2, 0])
        scale([1, 1, 1])
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

