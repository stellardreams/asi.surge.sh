// =============================================================================
// AMU — Arctic Wind Grove Unit (v3)
// Interlocked bladeless mast cluster with raked self-erecting erection
// Location: cad_and_blender/openscad/wind/amu_wind_grove_v3.scad
// Issue: #82
// Target: OpenSCAD >= 2021.01 | Preview F5 | Render F6 → Export STL/3MF/DXF
// =============================================================================
//
// COMPANION TO v2, NOT A REPLACEMENT. Both remain in this directory:
//
//   amu_wind_anchor_v1.scad  — rigid conventional rotor, ring compression interlock
//   amu_wind_grove_v3.scad   — bladeless oscillator, ring-closure erection  ← this file
//
// v2 is kept deliberately. It is the baseline the grove design is measured against,
// and the progression from "chassis → anchored rigid mast → interlocked bladeless
// grove" is the argument for why the grove exists. Superseding it would throw away
// the comparison. Compare them with GROUP_MODE in each file.
//
// =============================================================================
//
// WHAT IS NEW IN v3, AND THE EVIDENCE BEHIND IT
//
// 1. BLADELESS OSCILLATING MAST (vortex type), not a conventional rotor.
//
//    Removes the entire blade-root bending fatigue class. For an icing environment
//    this is the decisive argument: rime on a blade root concentrates load and
//    changes section; rime on a cylindrical shell just adds mass and a surface.
//
//    Cost, stated plainly: a bladeless machine has far less swept area than a bladed
//    one of equal power (as Hansen's framing has it — a conventional turbine gives
//    you blades, a bladeless one gives you a pole). So equal power means a larger
//    machine. The structural win is partly paid back in size and cost.
//
//    The oscillator therefore ROCKS. That changes the joint design: see (3).
//
// 2. SELF-ERECTING RAKED RING — the erection sequence, not the load path.
//
//    Install each unit raked OUTWARD, ring open. Walk the ring, close the final
//    joint, and the closed ring pulls every unit inward into compression. The
//    compression interlock is created by the act of closing the circle rather than by
//    a separate bracing operation.
//
//    Why this matters at a remote Arctic site: no crane, no heavy lifting, no level
//    pad. Each pile is screwed in tilted; two people walk a unit into position. A
//    partially closed ring is already stable up to the point of closure, so erection
//    is staged rather than all-or-nothing.
//
//    SETUP_RAKE = true previews the raked erection state; false shows the finished
//    ring. See ERECTION_STATE below.
//
// 3. SCREW-JACK PRELOAD AT EACH JOINT.
//
//    Ring closure alone makes seating depend on every unit being *exactly* right —
//    correct rake angle, correct spacing, correct pile depth. Get one wrong and the
//    closing force seats some joints and leaves others slack. That is an intolerant
//    assembly process for a site where you cannot iterate.
//
//    Each joint therefore carries an inline screw jack. The jack is what converts
//    closure into *controlled* preload: torque a jack to spec and that joint is
//    preloaded regardless of its neighbours. It also gives a place to release a
//    single joint later, which is how one unit is removed from the ring without
//    disturbing the rest — the "fails alone" property of v2, now serviceable.
//
//    The jack pushes. It cannot pull. Same one-way rule as the coupler.
//
// 4. ROOT GRAFT — the sequoia analogy, and where it is deliberately NOT followed.
//
//    There is a relevant result: a 2025 study in Trees (Springer) on jack pine found
//    that natural root grafting DECREASED the likelihood of uprooting (p < 0.01) but
//    INCREASED the propensity for stem breakage.
//
//    Read that carefully. Grafting does not remove failure, it RELOCATES it. A fused
//    network becomes a load path, so an overloaded member routes force into its
//    neighbours and something breaks at the joint instead of at the foundation. The
//    share-the-load benefit is real; the cost is a shared failure mode.
//
//    So the principle is taken and the location is not. Loads ARE shared between
//    neighbours — above grade, in compression, through pinned joints. Buried
//    sections stay INDEPENDENT. Root-grafting the piles would import exactly the
//    failure relocation the study describes.
//
// 5. INDEPENDENT PILES. Carried forward unchanged from v2, and it is still the single
//    most important line in the file. Nothing below grade ties together, so a
//    settling or thawing unit drags nobody's foundation with it. It fails alone.
//
// 6. ROCKING BEARING AT THE MAST BASE.
//
//    Separation of concerns, and the one place v2 does not carry over. The oscillator
//    must be free to rock perpendicular to the wind, or it cannot harvest energy and
//    it will fight its own structural stiffness. The rocking bearing releases that
//    DOF at the base. Overturning restraint comes from the ring and the pile, not
//    from bending the mast.
//
//    This is also the honest conflict in the design: the ring must resist
//    overturning while the mast base must NOT. The bearing is what lets both be
//    true. Unanalysed — see the README §7.
//
// ENVIRONMENT: terrestrial, cold, high wind, icing-prone. #5's Mars–Jupiter framing
// does not apply. Non-scope per #82: no swarm engine, orbital/ledger, or
// nutrient/logistics modules. Nothing in openscad/opencode/ is modified, and nothing
// here inherits params from it — no drift guard needed.
//
// =============================================================================

// ---------------------------- User-tunable params ----------------------------

// --- Group geometry ---
GROUP_COUNT      = 6;
RING_RADIUS      = 3.40;
UNIT_LEAN        = 4;        // degrees inward — finished self-stabilising arc
RAKE_OUT         = 9;        // degrees outward — erection state only
ERECTION_STATE   = false;    // false = finished ring | true = raked, ring open
GROUP_MODE       = true;     // true = ring | false = single unit

// --- Bladeless oscillator mast ---
MAST_BASE_DIA    = 0.92;     // wider base — the oscillator's ballast
MAST_TOP_DIA     = 0.58;     // conical taper; more efficient per Vortex form
MAST_HEIGHT      = 6.20;
MAST_WALL        = 0.050;

// --- Rocking bearing (releases rotation at base) ---
ROCK_ARC         = 9;        // degrees of free rock each side of vertical
BEARING_PAD_DIA  = 0.66;
BEARING_SEG      = 5;        // arcs machined into the pad — visualises the DOF

// --- Oscillator indication ---
OSC_SHOW_SWEEP   = true;     // show the rocking sweep arc at the top
OSC_SWEEP_DEG    = 7;        // visual sweep for the oscillator's travel

// --- Helical pile (unchanged logic from v2) ---
PILE_SHAFT_DIA   = 0.34;
PILE_DEPTH       = 2.90;
HELIX_DIA        = 1.05;
HELIX_T          = 0.055;
HELIX_COUNT      = 3;
HELIX_PITCH      = 0.62;
HELIX_STAGGER    = 60;

// --- Interlock joint with inline screw jack ---
COUPLER_Z        = 2.30;     // height above grade
COUPLER_LEN      = 0.92;
COUPLER_HGT      = 0.32;
COUPLER_T        = 0.13;
SPIGOT_DIA       = 0.30;
SPIGOT_LEN       = 0.38;
PIN_DIA          = 0.11;

// --- Screw jack ---
JACK_BORE       = 0.15;      // jack body diameter
JACK_SCREW_D     = 0.11;      // screw shank diameter
JACK_SCREW_L     = 0.46;      // exposed screw length
JACK_NUT_HGT     = 0.20;      // hex nut block height
JACK_TRAVEL      = 0.12;      // stroke modelled

// --- Ground / soil ---
GROUND_DEPTH     = 3.60;
SHOW_SOIL        = true;
SHOW_RAKE_ARC    = true;      // show the erection raking arc
SHOW_ERECT_VEC   = true;      // show closure-force arrows

$fn = 64;

// ------------------------------ Palette -------------------------------------
SOIL_FROZEN      = [0.42, 0.55, 0.62, 0.35];
SOIL_SURFACE     = [0.58, 0.66, 0.70, 0.55];
PILE_METAL       = [0.55, 0.57, 0.60];
MASTEEL          = [0.74, 0.75, 0.78];
MAST_TIP         = [0.86, 0.87, 0.90];
COUPLER_LIGHT    = [0.88, 0.89, 0.92];
COUPLER_DARK     = [0.36, 0.38, 0.42];
JACK_BODY        = [0.72, 0.55, 0.18];
JACK_SCREW       = [0.82, 0.84, 0.88];
BEARING_RED      = [0.90, 0.35, 0.32];
SWEEP_ARC        = [0.25, 0.70, 0.95, 0.55];
RAKE_ARC         = [1.00, 0.72, 0.20, 0.50];
ERECT_VEC        = [0.30, 0.90, 0.50, 0.85];

// ------------------------------ Helpers --------------------------------------

module torus(r_major, r_minor, seg = 48) {
    rotate_extrude(convexity = 4, $fn = seg)
        translate([r_major, 0, 0])
            circle(r = r_minor, $fn = 12);
}

// Helical pile — shaft plus staggered bearing plates.
// Stacked discs, not true helices: a swept helix is expensive to render and
// unreadable at this scale. The approximation carries the same bearing logic.
module helical_pile(shaft_dia = PILE_SHAFT_DIA, depth = PILE_DEPTH,
                    helix_dia = HELIX_DIA, helix_t = HELIX_T,
                    n = HELIX_COUNT, pitch = HELIX_PITCH, stagger = HELIX_STAGGER) {
    color(PILE_METAL) {
        translate([0, 0, -depth - 0.30])
            cylinder(h = depth + 0.30, r = shaft_dia / 2, center = true, $fn = 32);
        for (i = [0 : n - 1])
            rotate([0, 0, i * stagger])
                translate([0, 0, -0.45 - i * pitch])
                    cylinder(h = helix_t, r = helix_dia / 2, center = true, $fn = 48);
    }
}

// Rocking bearing — the DOF release that lets the oscillator work.
//
// Segmented pad: the flat segments are machined arcs, so the mast can rock without
// the base transmitting a bending moment into the pile. Shown in red because it is
// the component whose behaviour most needs checking.
module rocking_bearing(pad_dia = BEARING_PAD_DIA, seg = BEARING_SEG, arc = ROCK_ARC) {
    color(BEARING_RED)
        translate([0, 0, 0.10])
            cylinder(h = 0.20, r = pad_dia / 2, center = true, $fn = 48);
    // machined arc segments — the rocking surfaces
    for (i = [0 : seg - 1])
        color(BEARING_RED)
            rotate([0, 0, i * 360 / seg])
                translate([pad_dia / 2 - 0.05, 0, 0.22])
                    rotate([0, 90, 0])
                        cylinder(h = 0.07, r = 0.055, center = true, $fn = 16);
}

// Screw jack — inline in the coupler.
//
// Push-only, like the coupler it sits in. The screw draws the two coupler halves
// together and torques to spec, so each joint is preloaded independently of its
// neighbours. That is the whole point: it converts ring closure from an intolerant
// assembly process into a controlled one, and it is where a single joint is later
// released to remove one unit without disturbing the rest.
module screw_jack(bore = JACK_BORE, screw_d = JACK_SCREW_D, screw_l = JACK_SCREW_L,
                  nut_h = JACK_NUT_HGT, travel = JACK_TRAVEL) {
    // jack body — tubular, bolted through the coupler arm
    color(JACK_BODY)
        translate([0, 0, 0])
            rotate([0, 90, 0])
                difference() {
                    cylinder(h = 0.34, r = bore / 2, center = true, $fn = 32);
                    translate([0, 0, 0])
                        rotate([90, 0, 0])
                            cylinder(h = 0.40, r = screw_d / 2, center = true, $fn = 24);
                }
    // hex nut block
    color(JACK_BODY)
        translate([0.19, 0, 0])
            rotate([0, 90, 0])
                cylinder(h = nut_h, r = bore / 2 * 1.30, $fn = 6);
    // exposed screw — extends as the jack is torqued, modelled mid-travel
    color(JACK_SCREW)
        translate([0.17 + travel, 0, 0])
            rotate([0, 90, 0])
                cylinder(h = screw_l, r = screw_d / 2, center = true, $fn = 24);
}

// Interlock joint: compression-only, with the jack inline between the two arms.
module coupler_joint(len = COUPLER_LEN, hgt = COUPLER_HGT, t = COUPLER_T,
                     spigot_dia = SPIGOT_DIA, spigot_len = SPIGOT_LEN,
                     pin_dia = PIN_DIA) {
    // inboard arm
    color(COUPLER_LIGHT)
        translate([len * 0.22, 0, 0])
            cube([len * 0.44, t, hgt], center = true);

    // jack sits at the joint centre
    screw_jack();

    // outboard arm
    color(COUPLER_LIGHT)
        translate([len * 0.74, 0, 0])
            cube([len * 0.46, t, hgt], center = true);

    // socket — collar the neighbour's spigot enters. Open on the outer face only.
    color(COUPLER_DARK)
        translate([len - 0.05, 0, 0])
            difference() {
                cylinder(h = hgt, r = spigot_dia / 2 + 0.07, center = true, $fn = 32);
                translate([0, 0, 0.02])
                    cylinder(h = hgt / 2 + 0.06, r = spigot_dia / 2, center = true, $fn = 32);
            }

    // spigot — no undercut, no hook, no shoulder that could carry tension
    color(COUPLER_LIGHT)
        translate([len - 0.05 + spigot_len / 2 - 0.09, 0, 0])
            cube([spigot_len, spigot_dia * 0.80, spigot_dia * 0.80], center = true);

    // shear pin — side load yes, moment no
    color(PILE_METAL)
        translate([0.14, 0, hgt / 2])
            cylinder(h = hgt + 0.10, r = pin_dia / 2, center = true, $fn = 20);
}

// Bladeless oscillator mast.
//
// Tapered shell, no blades. The rock is permitted at the base by the rocking bearing
// and resisted nowhere else — the mast is not meant to be a stiff cantilever, because
// a stiff mast would resist the motion the generator harvests.
module oscillator_mast(base_dia = MAST_BASE_DIA, top_dia = MAST_TOP_DIA,
                       h = MAST_HEIGHT) {
    color(MASTEEL)
        translate([0, 0, h / 2 + 0.24])
            cylinder(h = h, r1 = base_dia / 2, r2 = top_dia / 2, center = true, $fn = 48);

    // wall indication band — shows this is a shell, not a rod
    color([0.75, 0.90, 1.00, 0.28])
        translate([0, 0, 1.05])
            difference() {
                cylinder(h = 0.40, r = base_dia / 2 - (base_dia - top_dia) / h * 0.80, center = true, $fn = 48);
                translate([0, 0, 0])
                    cylinder(h = 0.40, r = base_dia / 2 - (base_dia - top_dia) / h * 0.80 - MAST_WALL, center = true, $fn = 48);
            }

    // linear generator head at the tip — where the rocking motion becomes electricity
    color(COUPLER_DARK)
        translate([0, 0, h + 0.34])
            cylinder(h = 0.20, r = top_dia / 2 * 0.86, center = true, $fn = 40);
    color(MAST_TIP)
        translate([0, 0, h + 0.48])
            cylinder(h = 0.10, r = top_dia / 2 * 0.55, center = true, $fn = 32);

    // oscillator sweep arc at the tip — visualises the travel this unit has
    if (OSC_SHOW_SWEEP) {
        color(SWEEP_ARC)
            translate([0, 0, h + 0.48])
                rotate([0, 90, 0])
                    rotate_extrude(convexity = 4, $fn = 48)
                        translate([top_dia / 2 * 0.55 + 0.30, 0, 0])
                            difference() {
                                circle(r = OSC_SWEEP_DEG * 0.055 + 0.20, $fn = 40);
                                translate([0, 0, 0])
                                    circle(r = OSC_SWEEP_DEG * 0.055, $fn = 40);
                            }
    }
}

// Erection raking arc — shows the tilt a unit is installed at, before closure.
module rake_arc(deg = RAKE_OUT) {
    color(RAKE_ARC)
        translate([0, 0, MAST_HEIGHT * 0.66])
            rotate([0, 90, deg])
                translate([MAST_HEIGHT * 0.20, 0, 0])
                    cylinder(h = MAST_HEIGHT * 0.36, r = 0.030, center = true, $fn = 12);
}

// Closure force arrow — the direction the closing joint pulls, pulling the ring
// inward into compression.
module closure_vec() {
    color(ERECT_VEC)
        translate([0, 0, COUPLER_Z])
            rotate([0, 0, 90])
                rotate([0, 90, 0])
                    translate([COUPLER_LEN * 0.85, 0, 0])
                        cylinder(h = COUPLER_LEN * 0.70, r = 0.045, center = true, $fn = 14);
}

// ------------------------------- Unit ----------------------------------------

// One grove unit. Local origin at the mast base on the soil surface.
// +X points outward from the ring centre, so the coupler's local +X reaches the
// next unit along the ring.
module grove_unit() {
    helical_pile();
    rocking_bearing();
    oscillator_mast();

    if (GROUP_MODE) {
        translate([0, 0, COUPLER_Z]) coupler_joint();
        if (ERECTION_STATE && SHOW_ERECT_VEC) closure_vec();
    }

    if (GROUP_MODE && SHOW_RAKE_ARC && ERECTION_STATE) rake_arc();
}

// ------------------------------- Group ---------------------------------------

// Closed ring. Closed geometry is the point: no free end means no racking
// mechanism, so one unit's rotation loads its two neighbours symmetrically and the
// ring self-equilibrates rather than cascading.
module grove_ring(n = GROUP_COUNT, ring_r = RING_RADIUS, lean = UNIT_LEAN) {
    rake = ERECTION_STATE ? RAKE_OUT : lean;
    for (i = [0 : n - 1]) {
        a = i * 360 / n;
        translate([ring_r * cos(a), ring_r * sin(a), 0])
            rotate([0, 0, a + 180])
                rotate([0, rake, 0])
                    grove_unit();
    }
}

module ground_block(depth = GROUND_DEPTH, ring_r = RING_RADIUS) {
    color(SOIL_FROZEN)
        translate([0, 0, -depth / 2 - 0.02])
            cylinder(h = depth, r = ring_r + 1.45, center = true, $fn = 64);
    color(SOIL_SURFACE)
        translate([0, 0, -0.015])
            cylinder(h = 0.03, r = ring_r + 1.45, center = true, $fn = 64);
}

// ------------------------------- Render --------------------------------------

if (GROUP_MODE) {
    if (SHOW_SOIL) ground_block();
    grove_ring();
} else {
    if (SHOW_SOIL)
        color(SOIL_FROZEN)
            translate([0, 0, -GROUND_DEPTH / 2])
                cylinder(h = GROUND_DEPTH, r = 2.1, center = true, $fn = 64);
    grove_unit();
}

// Build tips:
// Preview F5 | Render F6 | Export STL/3MF/DXF
//
// ERECTION_STATE = true  -> units raked OUTWARD, the installation condition
// ERECTION_STATE = false -> finished ring, units leaning inward into compression
// GROUP_MODE = false     -> single unit, for inspecting bearing / jack / joint
//
// Both states are stable-ish by design: a partially closed ring holds itself up to
// the point of closure, so erection is staged rather than all-or-nothing.
//
// Structure recap: closed ring (no racking) + compression-only joints with screw-jack
// preload (no tension tearing, tolerant assembly) + INDEPENDENT piles (no cascade) +
// inward lean (overturning resisted by geometry first) + rocking bearing (the DOF the
// oscillator needs). README §3-§6 explain each and where the evidence comes from.
//
// Issue: #82 | companion to amu_wind_anchor_v1.scad (v2)
//
// Signed: [OpenCode](https://opencode.ai) — 2026-10-07
