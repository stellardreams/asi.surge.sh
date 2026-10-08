// =============================================================================
// AMU — Arctic Wind Anchor Unit (v1)
// Interlocking self-burying foundation for modular wind generation
// Location: cad_and_blender/openscad/wind/amu_wind_anchor_v1.scad
// Issue: #82
// Target: OpenSCAD >= 2021.01 | Preview F5 | Render F6 → Export STL/3MF/DXF
// =============================================================================
//
// SUPERSEDES amu_wind_chassis_v1.scad (was committed at fae41f7, removed)
//
// That file put a small wind mount on top of the full AMU hull. Wrong scale for
// the problem: a 17.92 × 12.0 hull is orbital infrastructure, and it has no reason
// to exist at an Arctic site. This file removes the hull entirely.
//
// WHAT CHANGED AND WHY
//
//   1. Hull removed. No cylinder, no rivet grid, no caliper lanes, no APAS docking.
//      The unit is now a slender anchored mast, not a repurposed spacecraft bus.
//
//   2. Foundation is a helical pile, not a buried trunk. A helical pile is screwed
//      in — non-displacing, no spoil, no excavation. This matters more than it
//      sounds: the bearing capacity comes from the frozen soil, and every metre you
//      dig to place a smooth post disturbs exactly the material you depend on.
//      Screw-in leaves it alone. Smooth-post-in-drilled-hole is modelled below only
//      as a comparison (SHOW_SMOOTH_ALT) — it is the rejected option, not the design.
//
//   3. Units interlock in a CLOSED RING, above grade. This is the answer to the
//      cascade problem. In a linear row, unit 1 tilting adds to unit 2's moment,
//      which adds to unit 3's — a racking failure that propagates and accumulates.
//      A ring has no free end, so there is no racking mechanism: unit 1's rotation
//      loads its two neighbours symmetrically and the ring self-equilibrates.
//      Tilt redistributes instead of cascading.
//
//   4. Couplers are COMPRESSION-ONLY. Neighbours push on each other in compression
//      like a masonry arch. No coupler ever sees tension, so cyclic gusting cannot
//      tear the group apart progressively. The spigot/joint geometry is one-way:
//      it can push, it cannot pull.
//
//   5. Piles are INDEPENDENT. The interlock is above grade only. A settling or
//      tilting unit drags nobody's foundation with it — it fails alone. This is the
//      single most important line in the file. Tying the buried sections together
//      would convert a local problem into a group-wide one, which is exactly the
//      failure mode the ring was chosen to avoid.
//
//   6. Each unit leans slightly inward, pre-tilted. A ring that leans into itself is
//      self-stabilising in the way an arch or a stack of barrels is: overturning
//      moment is resisted by geometry before it is resisted by the foundation. The
//      pile heads therefore carry less overturning demand, which is what lets them
//      stay shallow enough not to disturb the frozen ground.
//
//   Known tradeoff: a lean needs a stiff upper structure to develop it, and that
//   stiff structure is what carries the blade loads. Not analysed here. See README §8.
//
// ENVIRONMENT
//
//   Terrestrial surface deployment: cold, high wind, icing-prone. #5's Mars–Jupiter
//   corridor framing does NOT apply. Non-scope per #82: no swarm engine, no orbital
//   or ledger layer, no nutrient/logistics modules. Nothing in openscad/opencode/ is
//   modified, and nothing here inherits params from it — this file shares no params
//   with the canonical AMU, so no drift guard is needed. The check that guarded the
//   deleted v1 is gone with it.
//
// =============================================================================

// ---------------------------- User-tunable params ----------------------------

// --- Group geometry ---
GROUP_COUNT      = 6;        // units in the ring — see README §6 on choosing this
RING_RADIUS      = 3.20;     // centre-to-centre radius of the ring
UNIT_LEAN        = 4;        // degrees of inward pre-lean (self-stabilising arc)
GROUP_MODE       = true;     // true = closed ring | false = single unit (compare)

// --- Above grade ---
MAST_DIA         = 0.62;     // mast outside diameter
MAST_HEIGHT      = 5.60;     // ground to nacelle interface
MAST_WALL        = 0.045;    // wall thickness (shown as a cutaway band)
COUPLER_Z        = 2.45;     // height above grade where units interlock

// --- Below grade: helical pile ---
PILE_SHAFT_DIA   = 0.34;     // central shaft
PILE_DEPTH       = 2.90;     // embedment depth
HELIX_DIA        = 1.05;     // bearing plate diameter
HELIX_T          = 0.055;    // bearing plate thickness
HELIX_COUNT      = 3;        // bearing plates
HELIX_PITCH      = 0.62;     // vertical spacing between plates
HELIX_STAGGER    = 60;       // degrees between plates — cancels torsional reaction

// --- Interlock joint: compression only ---
COUPLER_LEN      = 0.86;     // radial length of each coupler arm
COUPLER_HGT      = 0.34;     // vertical height
COUPLER_T        = 0.13;     // arm thickness
SPIGOT_DIA       = 0.30;     // tongue that enters the neighbour's socket
SPIGOT_LEN       = 0.40;     // insertion depth
PIN_DIA          = 0.11;     // shear pin — takes side load, allows rotation

// --- Blade / nacelle interface ---
NACELLE_DIA      = 0.86;
ROTOR_HUB_Y      = 0.0;      // hub offset from mast axis, along unit's local X

// --- Ground for visual reference ---
GROUND_DEPTH     = 3.60;     // soil block depth (display only)
SHOW_SOIL        = true;     // translucent permafrost block
SHOW_SMOOTH_ALT  = false;    // REJECTED option — smooth post in drilled hole
SHOW_COUPLER_X   = true;     // highlight the interlock joints
SHOW_LEAN_VEC    = true;     // show inward lean direction arrows

$fn = 64;

// ------------------------------ Palette -------------------------------------
SOIL_FROZEN      = [0.42, 0.55, 0.62, 0.35];
SOIL_SURFACE     = [0.58, 0.66, 0.70, 0.55];
PILE_METAL       = [0.55, 0.57, 0.60];
MASTEEL          = [0.72, 0.73, 0.76];
COUPLER_LIGHT    = [0.86, 0.87, 0.90];
COUPLER_DARK     = [0.38, 0.40, 0.44];
NACELLE_PAINT    = [0.80, 0.74, 0.62];
LEAN_ARROW      = [0.20, 0.85, 0.55, 0.9];
ICE_TINT        = [0.75, 0.90, 1.00, 0.30];

// ------------------------------ Helpers --------------------------------------

module torus(r_major, r_minor, seg = 48) {
    rotate_extrude(convexity = 4, $fn = seg)
        translate([r_major, 0, 0])
            circle(r = r_minor, $fn = 12);
}

// Helical pile: central shaft plus staggered bearing plates.
//
// The plates are modelled as flat discs, not true helices. A real helix is a swept
// surface that is expensive to render and impossible to read at this scale; a
// stacked-plate approximation carries the same bearing logic and renders in
// seconds. Helix angles are a fabrication detail, not a structural one here.
module helical_pile(shaft_dia = PILE_SHAFT_DIA, depth = PILE_DEPTH,
                    helix_dia = HELIX_DIA, helix_t = HELIX_T,
                    n = HELIX_COUNT, pitch = HELIX_PITCH, stagger = HELIX_STAGGER) {
    color(PILE_METAL) {
        // central shaft — runs from below the deepest plate up through the cap
        translate([0, 0, -depth - 0.30])
            cylinder(h = depth + 0.30, r = shaft_dia / 2, center = true, $fn = 32);
        // bearing plates
        for (i = [0 : n - 1])
            rotate([0, 0, i * stagger])
                translate([0, 0, -0.45 - i * pitch])
                    cylinder(h = helix_t, r = helix_dia / 2, center = true, $fn = 48);
    }
}

// Compression-only interlock joint.
//
// Geometry is deliberately one-way. The spigot sits inside the neighbour's socket
// and there is no undercut, no hook, no shoulder that could carry tension — a pull
// simply separates the joint. That is the property the whole group depends on:
// neighbours can push on each other indefinitely but cannot hold one another up.
//
// The shear pin takes side load while permitting rotation, so a tilting neighbour
// transmits force but not moment. That is what stops one unit levering the next.
module coupler_joint(len = COUPLER_LEN, hgt = COUPLER_HGT, t = COUPLER_T,
                     spigot_dia = SPIGOT_DIA, spigot_len = SPIGOT_LEN,
                     pin_dia = PIN_DIA) {
    // arm — reaches outward from the mast toward the neighbour
    color(COUPLER_LIGHT)
        translate([len / 2, 0, 0])
            cube([len, t, hgt], center = true);

    // socket — a collar the neighbour's spigot enters
    color(COUPLER_DARK)
        translate([len - 0.06, 0, 0])
            difference() {
                cylinder(h = hgt, r = spigot_dia / 2 + 0.07, center = true, $fn = 32);
                // bore is open at the outer face only — one-way entry
                translate([0, 0, 0.02])
                    cylinder(h = hgt / 2 + 0.06, r = spigot_dia / 2, center = true, $fn = 32);
            }

    // spigot — protrudes into the neighbour's socket
    color(COUPLER_LIGHT)
        translate([len - 0.06 + spigot_len / 2 - 0.10, 0, 0])
            cube([spigot_len, spigot_dia * 0.82, spigot_dia * 0.82], center = true);

    // shear pin — vertical, allows rotation
    color(PILE_METAL)
        translate([0.16, 0, hgt / 2])
            cylinder(h = hgt + 0.10, r = pin_dia / 2, center = true, $fn = 20);
}

// Mast — tapered column, ground to nacelle interface.
module mast(dia = MAST_DIA, h = MAST_HEIGHT, wall = MAST_WALL) {
    color(MASTEEL)
        translate([0, 0, h / 2])
            cylinder(h = h, r1 = dia / 2 * 1.12, r2 = dia / 2, center = true, $fn = 48);

    // wall thickness shown as a translucent band near the base — indicates this is
    // a tube, not a solid rod, without cutting the model
    color(ICE_TINT)
        translate([0, 0, 0.55])
            difference() {
                cylinder(h = 0.42, r = dia / 2 * 1.12, center = true, $fn = 48);
                translate([0, 0, 0])
                    cylinder(h = 0.42, r = dia / 2 * 1.12 - wall, center = true, $fn = 48);
            }

    // base flange — spreads mast load into the pile cap
    color(COUPLER_DARK)
        translate([0, 0, 0.06])
            cylinder(h = 0.12, r = dia / 2 * 1.55, center = true, $fn = 40);
}

// Pile cap — transition between the helical pile and the mast base, above grade.
// Kept above the soil surface deliberately: no grout, no excavation, no disturbed
// frozen material at the critical interface.
module pile_cap(dia = MAST_DIA) {
    color(COUPLER_DARK)
        translate([0, 0, 0.14])
            cylinder(h = 0.20, r = dia / 2 * 1.30, center = true, $fn = 40);
    color(PILE_METAL)
        translate([0, 0, 0.26])
            cylinder(h = 0.06, r = dia / 2 * 1.18, center = true, $fn = 40);
}

// Nacelle + rotor hub interface. Hub is offset along local +X, so the rotor axis
// is horizontal and the blades clear the mast.
module nacelle(dia = NACELLE_DIA, hub_y = ROTOR_HUB_Y, h = MAST_HEIGHT) {
    color(NACELLE_PAINT)
        translate([hub_y * 0.45, 0, h + 0.30])
            rotate([0, 90, 0])
                cylinder(h = dia * 0.86, r = dia / 2, center = true, $fn = 40);
    color(COUPLER_DARK)
        translate([hub_y - 0.02, 0, h + 0.30])
            rotate([0, 90, 0])
                cylinder(h = 0.20, r = dia / 2 * 0.40, center = true, $fn = 32);
    // yaw bearing collar
    color(PILE_METAL)
        translate([0, 0, h + 0.04])
            torus(r_major = dia / 2 * 0.52, r_minor = 0.05, seg = 32);
}

// Inward lean indicator — shows which way the group arcs.
module lean_arrow(d = UNIT_LEAN) {
    color(LEAN_ARROW)
        translate([0, 0, MAST_HEIGHT * 0.62])
            rotate([0, 90, d])
                translate([MAST_HEIGHT * 0.22, 0, 0])
                    cylinder(h = MAST_HEIGHT * 0.34, r = 0.035, center = true, $fn = 12);
}

// ------------------------------- Unit ----------------------------------------

// One anchored unit: helical pile below grade, mast and interlock above.
// Local origin is at the mast base on the soil surface.
module anchor_unit() {
    if (SHOW_SMOOTH_ALT) {
        // REJECTED alternative, retained for comparison. A smooth post in a drilled
        // hole: it requires excavation, which disturbs the frozen soil that provides
        // the bearing capacity, and it develops no torsional resistance, so the pile
        // must also resist a torque it has no geometry to refuse.
        color([0.85, 0.35, 0.30, 0.85])
            translate([0, 0, -PILE_DEPTH / 2])
                cylinder(h = PILE_DEPTH, r = PILE_SHAFT_DIA / 2 * 1.5, center = true, $fn = 32);
        color([0.85, 0.35, 0.30, 0.35])
            translate([0, 0, -PILE_DEPTH / 2])
                cylinder(h = PILE_DEPTH + 0.1, r = PILE_SHAFT_DIA / 2 * 1.5 + 0.10, center = true, $fn = 32);
    } else {
        helical_pile();
    }

    pile_cap();
    mast();
    nacelle();

    // interlock joint — one per unit, reaching toward the next unit in the ring
    if (GROUP_MODE && SHOW_COUPLER_X)
        translate([0, 0, COUPLER_Z])
            coupler_joint();

    if (SHOW_LEAN_VEC && GROUP_MODE) lean_arrow();
}

// ------------------------------- Group ---------------------------------------

// Closed ring of GROUP_COUNT units, each rotated to face the ring centre.
// Closed geometry is the point: no free end means no racking mechanism.
module anchor_ring(n = GROUP_COUNT, ring_r = RING_RADIUS, lean = UNIT_LEAN) {
    for (i = [0 : n - 1]) {
        a = i * 360 / n;
        // place on the ring, face inward, then lean the whole unit toward centre
        translate([ring_r * cos(a), ring_r * sin(a), 0])
            rotate([0, 0, a + 180])
                rotate([0, lean, 0])
                    anchor_unit();
    }
}

module ground_block(depth = GROUND_DEPTH, ring_r = RING_RADIUS) {
    color(SOIL_FROZEN)
        translate([0, 0, -depth / 2 - 0.02])
            cylinder(h = depth, r = ring_r + 1.35, center = true, $fn = 64);
    color(SOIL_SURFACE)
        translate([0, 0, -0.015])
            cylinder(h = 0.03, r = ring_r + 1.35, center = true, $fn = 64);
}

// ------------------------------- Render --------------------------------------

if (GROUP_MODE) {
    if (SHOW_SOIL) ground_block();
    anchor_ring();
} else {
    // single-unit view — for inspecting the joint and pile detail without the
    // group geometry in the way
    if (SHOW_SOIL)
        color(SOIL_FROZEN)
            translate([0, 0, -GROUND_DEPTH / 2])
                cylinder(h = GROUND_DEPTH, r = 2.0, center = true, $fn = 64);
    anchor_unit();
}

// Build tips:
// Preview F5 | Render F6 | Export STL/3MF/DXF
// Set GROUP_MODE = false to inspect a single unit's pile and joint up close.
// Set SHOW_SMOOTH_ALT = true to see the REJECTED smooth-post alternative for
// comparison — it needs excavation, which thaws the bearing material.
//
// Structure recap: closed ring (no racking) + compression-only joints (no tension
// tearing) + independent piles (no cascade) + inward lean (overturning resisted by
// geometry before foundation). README §5-§7 explain each.
//
// Issue: #82 | supersedes amu_wind_chassis_v1.scad
//
// Signed: [OpenCode](https://opencode.ai) — 2026-10-07
