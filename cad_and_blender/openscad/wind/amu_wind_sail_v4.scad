// =============================================================================
// AMU — Arctic Ice-Tuned Sail Unit (v4)
// Flat wind sail on a portal frame, ice-frozen ballast, water-column tuning
// Location: cad_and_blender/openscad/wind/amu_wind_sail_v4.scad
// Issue: #82
// Target: OpenSCAD >= 2021.01 | Preview F5 | Render F6 → Export STL/3MF/DXF
// =============================================================================
//
// REPLACES THE INTERLOCKED GROVE. Ring geometry, compression-only couplers, screw
// jacks, and the cascade analysis are gone — not deprecated, REMOVED. They answered
// "how do independent units fail safely together", and a flat sail with no
// structural linkage between units never asks that question. Nothing is shared, so
// nothing can cascade. The whole interlocking thread existed because of a root-graft
// analogy; dropping the analogy dropped the machinery with it.
//
// Superseded design history, all recoverable in git:
//   amu_wind_chassis_v1.scad  — wind mount on the AMU hull      (fae41f7)
//   amu_wind_anchor_v1.scad   — interlocked helical-pile ring   (d4c8a9c)
//   amu_wind_grove_v3.scad    — interlocked bladeless grove     (a17a023)
//
// =============================================================================
//
// A CORRECTION, RECORDED BECAUSE IT CHANGED THE DESIGN
//
// The first version of this file claimed the ice itself was the tuning element:
// ice below the pivot acting as ballast, natural frequency going as sqrt(g*g/d),
// freeze more ice to raise the site frequency. That was WRONG, and the arithmetic
// says so plainly:
//
//   Pendulum, ice as ballast:   fn = (1/2pi)sqrt(g/d)
//     CoM 1.172 m -> 1.229 m :  fn 0.460 -> 0.450 Hz   = -2.3% swing
//
// Two percent is not a tuning range. You can pack 800 kg of ice into the panel and
// barely move the frequency, because fn propto sqrt(1/d) is inherently insensitive —
// CoM distance is a weak lever. Re-proportioning so ice is 78% of total mass does not
// rescue it either; the insensitivity is in the law, not the mass ratio.
//
// (The earlier draft also had a modelling bug: the cell lattice was rendered as
// SOLID blocks, making the panel ~4500 kg of steel. Ice was never going to tune that.)
//
// THE MECHANISM THAT ACTUALLY WORKS
//
// A partially filled cell is a tuned liquid mass damper. Its free surface is a
// spring: stiffness k = rho*g*b*a^2/2 while the oscillating mass is m = rho*A*b*a.
// The a^2 against a leaves:
//
//   Liquid column:              fn = (1/2pi)sqrt(g*a/(2*A))
//     a 0.02 -> 0.30 m :  fn 0.158 -> 0.611 Hz   = 3.87x swing
//
// That is a real tuning range, and it is 170x more sensitive than the pendulum.
//
// Note what this means for the ice: a SOLID block has no free surface, so it
// contributes mass and no stiffness at all. Ice can never be the tuning element.
// The tuning element has to be something that can MOVE. This is why the cell holds
// both phases, and why "pack it with ice" was half the idea.
//
// SO EACH CELL HOLDS TWO PHASES, AND THEY DO DIFFERENT JOBS
//
//   - ICE, frozen in from the top. Permanent ballast and thermal buffer. Also the
//     seasonal regulator: as the site cools, ice grows downward and shortens the
//     water column, which lowers the frequency. The panel re-tunes itself with the
//     season without anyone touching it.
//   - WATER, liquid, at the bottom. The spring. Its column height `a` is the tuning
//     knob, and it is what sets the frequency.
//
// Tune up by raising the water column (or shrinking cell plan area A, which raises fn
// as 1/sqrt(A)). Tune down by freezing more. "Freeze it to tune it" is literally the
// commissioning procedure.
//
// THE CONSTRAINT THIS CREATES, AND WHY IT IS SURVIVABLE
//
// Water freezes at 0 C. Arctic design cold is commonly -50 C. Brine will not cover
// it either — saturated NaCl is -21 C, CaCl2 about -30 C, 60% ethylene glycol -48 C.
// So a plain liquid column is not survivable at this site.
//
// The cells are held at the freezing point by PASSIVE THERMOSYPHONS. These are a
// standard permafrost foundation component, need no power and no consumable, and
// they are needed ANYWAY to stop the steel pile conducting surface heat down into the
// frozen soil that carries the load. One component, two problems.
//
// FAILURE MODE, AND IT IS A GOOD ONE
//
// If a thermosyphon ever fails and a cell freezes solid, the cell stops being a
// spring and the panel stops oscillating. It does not break and it does not shed a
// part — it stops producing. A tuning element that fails by becoming harmless is the
// best available outcome, and it is a direct benefit of making the spring out of a
// phase boundary rather than out of steel.
//
// GEOMETRY CONSEQUENCES OF TUNING WITH fn propto sqrt(1/d)
//
// The trunnion is at the TOP of the panel, not halfway down. Everything hangs from
// it as a pendulum, so the whole sail contributes restoring moment and the CoM is
// always below the pivot — the unit is stable at any ice fill, including empty.
//
// Transport: the panel is FLAT. A stack of them uses a small fraction of a container.
// The ice is not shipped at all — it is made from site water after installation. This
// is the first design in the whole thread that fits the transport requirement instead
// of fighting it.
//
// ENVIRONMENT: terrestrial, cold, high wind, icing-prone. #5's Mars–Jupiter framing
// does not apply. Non-scope per #82: no swarm engine, orbital/ledger, or
// nutrient/logistics modules. Nothing in openscad/opencode/ is modified, nothing
// here inherits params from it.
//
// =============================================================================

// ---------------------------- User-tunable params ----------------------------

// --- Sail geometry ---
SAIL_W           = 1.90;     // panel width (X, along the trunnion)
SAIL_T           = 0.30;     // panel thickness (Y, along the wind)
SAIL_H           = 2.60;     // total panel height, hanging below the trunnion
SAIL_WALL        = 0.004;    // 4 mm aluminium. See the mass note below — steel at
                             // this thickness over this area is ~1100 kg, and a panel
                             // that heavy cannot be tuned by anything you add to it.
SAIL_UPPER       = 0.70;     // upper section — carries the aerodynamic load
SAIL_BAY         = 0.90;     // ballast bay — holds the cells

// --- Portal frame ---
PIVOT_H          = 2.78;     // trunnion height above grade
LEG_OFFSET       = 0.12;     // legs stand outboard of the sail, so it swings free
LEG_DIA          = 0.11;
FOOT_DIA         = 0.62;
FOOT_H           = 0.10;

// --- Cells ---
BAY_COLS         = 4;        // sealed cells across the bay
ICE_TOP          = 0.34;     // ice depth from the TOP of each cell, at commissioning
WEEP_DIA         = 0.012;    // drain bore — must defeat ice bridging. SIZING OPEN.
SHOW_ICE         = true;     // render the frozen ballast
SHOW_WATER       = true;     // render the liquid spring column
SHOW_THERMO      = true;     // render the passive thermosyphon stems

// --- Thermosyphon ---
THERMO_LEN       = 1.30;     // stem length below grade — sets the cooling capacity
THERMO_DIA       = 0.052;
THERMO_CLOSED    = 0.42;     // ammonia charge, nominal

// --- Operating state ---
SWING_DEG        = 13;       // static hang angle of the sail from vertical
SHOW_SWING       = true;
SHOW_OSC_ARC     = true;     // oscillation sweep
OSC_DEG          = 9;        // visual sweep

// --- Foundation (carried from v2) ---
PILE_SHAFT_DIA   = 0.30;
PILE_DEPTH       = 2.60;
HELIX_DIA        = 0.98;
HELIX_T          = 0.052;
HELIX_COUNT      = 3;
HELIX_PITCH      = 0.58;
HELIX_STAGGER    = 60;

// --- Ground ---
GROUND_DEPTH     = 3.30;
SHOW_SOIL        = true;

$fn = 56;

// ------------------------------ Palette -------------------------------------
SOIL_FROZEN      = [0.42, 0.55, 0.62, 0.35];
SOIL_SURFACE     = [0.58, 0.66, 0.70, 0.55];
SAILPANEL        = [0.82, 0.84, 0.88];
FRAME_DARK       = [0.32, 0.34, 0.38];
TRUNNION         = [0.64, 0.66, 0.70];
ICE_FILL         = [0.68, 0.86, 0.97, 0.62];
WATER_FILL       = [0.20, 0.55, 0.92, 0.42];
THERMO_STEM      = [0.80, 0.50, 0.18];
PILE_METAL       = [0.55, 0.57, 0.60];
OSC_ARC          = [0.28, 0.72, 0.96, 0.55];
SWING_ARC        = [1.00, 0.74, 0.22, 0.50];

// ------------------------------ Helpers --------------------------------------

module helical_pile(shaft_dia = PILE_SHAFT_DIA, depth = PILE_DEPTH,
                    helix_dia = HELIX_DIA, helix_t = HELIX_T,
                    n = HELIX_COUNT, pitch = HELIX_PITCH, stagger = HELIX_STAGGER) {
    color(PILE_METAL) {
        translate([0, 0, -depth - 0.26])
            cylinder(h = depth + 0.26, r = shaft_dia / 2, center = true, $fn = 28);
        for (i = [0 : n - 1])
            rotate([0, 0, i * stagger])
                translate([0, 0, -0.40 - i * pitch])
                    cylinder(h = helix_t, r = helix_dia / 2, center = true, $fn = 40);
    }
}

// Sail shell — 4 mm aluminium box, open at the bottom so rain and snowmelt shed.
module sail_shell() {
    color(SAILPANEL)
        translate([0, 0, -SAIL_H / 2])
            difference() {
                cube([SAIL_W, SAIL_T, SAIL_H], center = true);
                // interior void, open downward
                translate([0, 0, SAIL_WALL / 2])
                    cube([SAIL_W - 2 * SAIL_WALL, SAIL_T - 2 * SAIL_WALL,
                          SAIL_H - SAIL_WALL], center = true);
            }
}

// Upper section ribs — thin stiffeners, not solid blocks.
//
// These are drawn as WALL-VOLUME only. An earlier draft filled them as solid
// cubes, which silently added ~2200 kg to the panel and made the whole tuning idea
// impossible. Ribs are the correct representation and they cost nothing.
module upper_ribs() {
    inner_w = SAIL_W - 2 * SAIL_WALL;
    inner_t = SAIL_T - 2 * SAIL_WALL;
    n = 4;
    for (i = [1 : n - 1])
        color(FRAME_DARK)
            translate([-inner_w / 2 + (inner_w / n) * i, 0, -SAIL_UPPER / 2])
                cube([SAIL_WALL, inner_t, SAIL_UPPER], center = true);
}

// One sealed ballast cell — two phases, one spring.
//
//   ice   frozen in from the TOP   -> ballast + thermal buffer + seasonal regulator
//   water liquid at the BOTTOM    -> the spring. Column height `a` sets the frequency.
//
// The ice is modelled ABOVE the water, not mixed into it, because that ordering is
// what makes the seasonal behaviour correct: as the site cools, ice grows downward
// into the water and shortens the column, lowering the frequency on its own.
module ballast_cell(cell_w, cell_d, cell_h) {
    wall = 0.012;
    z_top = 0;
    z_bot = -cell_h;

    // cell body — closed container
    color(FRAME_DARK)
        difference() {
            translate([0, 0, z_top - cell_h / 2])
                cube([cell_w, cell_d, cell_h], center = true);
            translate([0, 0, z_top - cell_h / 2 + wall])
                cube([cell_w - 2 * wall, cell_d - 2 * wall, cell_h - wall], center = true);
        }

    // liquid column — the spring. Occupies the bottom of the cell; whatever the ice
    // has not claimed. Its top face is the free surface that does the work.
    if (SHOW_WATER) {
        water_h = cell_h - ICE_TOP;
        color(WATER_FILL)
            translate([0, 0, z_bot + wall + water_h / 2])
                cube([cell_w - 2 * wall - 0.003, cell_d - 2 * wall - 0.003, water_h],
                     center = true);
    }

    // frozen ballast — from the top down to the waterline
    if (SHOW_ICE) {
        color(ICE_FILL)
            translate([0, 0, z_top - wall - ICE_TOP / 2])
                cube([cell_w - 2 * wall - 0.003, cell_d - 2 * wall - 0.003, ICE_TOP],
                     center = true);
    }

    // weep drain through the floor — sized to defeat ice bridging.
    // SIZING IS UNRESOLVED and depends on site water chemistry and freeze rate.
    // A jammed drain means meltwater cannot escape and refreezes into the cell,
    // which defeats the tuning. Listed in the README as an open gap.
    color(FRAME_DARK)
        translate([0, 0, z_bot + wall / 2])
            cylinder(h = wall * 2.4, r = WEEP_DIA / 2, center = true, $fn = 14);
}

// Ballast bay — BAY_COLS sealed cells across the lower section.
module ballast_bay() {
    inner_w = SAIL_W - 2 * SAIL_WALL;
    cell_w  = inner_w / BAY_COLS;
    cell_d  = SAIL_T - 2 * SAIL_WALL;
    cell_h  = SAIL_BAY - SAIL_WALL;
    // partition walls
    for (i = [1 : BAY_COLS - 1])
        color(FRAME_DARK)
            translate([-inner_w / 2 + cell_w * i, 0,
                       -SAIL_UPPER - cell_h / 2])
                cube([SAIL_WALL, cell_d, cell_h], center = true);
    // cells
    for (i = [0 : BAY_COLS - 1])
        translate([-inner_w / 2 + cell_w * (i + 0.5), 0, -SAIL_UPPER])
            ballast_cell(cell_w - SAIL_WALL, cell_d, cell_h);
}

// Passive thermosyphon — keeps the cells at the freezing point.
//
// No power, no consumable, no moving parts. Same device needed anyway to stop the
// pile conducting heat into the frozen soil, so it does double duty. Evaporates a
// working fluid in the warm upper stem and condenses it in the cold buried stem,
// establishing a passive temperature gradient.
module thermosyphon_stem() {
    color(THERMO_STEM)
        translate([0, 0, -THERMO_LEN / 2])
            cylinder(h = THERMO_LEN, r = THERMO_DIA / 2, center = true, $fn = 20);
    // condenser bulb, buried
    color(THERMO_STEM)
        translate([0, 0, -THERMO_LEN])
            sphere(r = THERMO_DIA * 0.85, $fn = 20);
    // evaporator head, above grade
    color(THERMO_STEM)
        translate([0, 0, 0.14])
            sphere(r = THERMO_DIA * 0.80, $fn = 20);
}

// Portal frame — trunnion at the top, legs outboard so the sail swings clear.
module portal_frame() {
    for (s = [-1, 1]) {
        lx = s * (SAIL_W / 2 + LEG_OFFSET);
        color(TRUNNION)
            translate([lx, 0, PIVOT_H / 2])
                cylinder(h = PIVOT_H, r = LEG_DIA / 2, center = true, $fn = 28);
        color(FRAME_DARK)
            translate([lx, 0, FOOT_H / 2])
                cylinder(h = FOOT_H, r = FOOT_DIA / 2, center = true, $fn = 32);
        // bracket carrying the trunnion inboard to the sail
        color(FRAME_DARK)
            translate([lx - s * LEG_OFFSET / 2, 0, PIVOT_H])
                rotate([0, 90, 0])
                    cylinder(h = LEG_OFFSET, r = LEG_DIA * 0.42, center = true, $fn = 20);
    }
    // trunnion — the sail hangs from this
    color(FRAME_DARK)
        translate([0, 0, PIVOT_H])
            rotate([0, 90, 0])
                cylinder(h = SAIL_W + 2 * LEG_OFFSET, r = 0.062, center = true, $fn = 32);
    // cross tie between the legs
    color(TRUNNION)
        translate([0, 0, 0.62])
            rotate([0, 90, 0])
                cylinder(h = SAIL_W + 2 * LEG_OFFSET, r = LEG_DIA * 0.34, center = true, $fn = 20);
}

module swing_arc(deg = SWING_DEG) {
    color(SWING_ARC)
        rotate([deg, 0, 0])
            translate([0, 0, -SAIL_H * 0.42])
                cylinder(h = SAIL_H * 0.84, r = 0.020, center = true, $fn = 10);
}

// FIXED: the original used rotate_extrude on a circle centred on the axis. A circle
// centred at the origin spans negative X, and OpenSCAD rejects mixed-sign points for
// rotate_extrude ("all points must have the same X coordinate sign"). The error was
// easy to miss because the render still reported volumes. Now a flat ribbon.
module osc_arc(deg = SWING_DEG, sweep = OSC_DEG) {
    r_o = sweep * 0.040 + 0.14;
    r_i = sweep * 0.040;
    pts = concat(
        [for (i = [0 : 24]) let (a = -sweep + 2 * sweep * i / 24)
            [r_i * cos(a), r_i * sin(a)]],
        [for (i = [24 : -1 : 0]) let (a = -sweep + 2 * sweep * i / 24)
            [r_o * cos(a), r_o * sin(a)]]
    );
    color(OSC_ARC)
        rotate([deg, 0, 0])
            translate([0, -SAIL_H * 0.80, 0])
                rotate([90, 0, 0])
                    linear_extrude(height = 0.010)
                        polygon(pts);
}

// ------------------------------- Unit ----------------------------------------

// One sail unit. Origin at the trunnion, at grade.
module sail_unit() {
    helical_pile();
    if (SHOW_SOIL) ground_block();
    portal_frame();

    if (SHOW_THERMO) {
        // thermosyphons pass down through the bay floor, one per cell pair
        for (i = [0 : 1])
            translate([-(SAIL_W / 4) + SAIL_W / 2 * i, 0, -SAIL_UPPER - 0.16])
                thermosyphon_stem();
    }

    translate([0, 0, PIVOT_H])
        rotate([SHOW_SWING ? SWING_DEG : 0, 0, 0]) {
            sail_shell();
            upper_ribs();
            ballast_bay();
            if (SHOW_SWING && SHOW_OSC_ARC) osc_arc();
            if (SHOW_SWING) swing_arc();
        }
}

module ground_block(depth = GROUND_DEPTH) {
    color(SOIL_FROZEN)
        translate([0, 0, -depth / 2 - 0.02])
            cube([SAIL_W + 1.0, 3.10, depth], center = true);
    color(SOIL_SURFACE)
        translate([0, 0, -0.015])
            cube([SAIL_W + 1.0, 3.10, 0.03], center = true);
}

// ------------------------------- Render --------------------------------------

sail_unit();

// Build tips:
// Preview F5 | Render F6 | Export STL/3MF/DXF
//
// THE ONE PARAMETER THAT MATTERS:  ICE_TOP
//
//   ICE_TOP = depth of frozen ballast from the top of each cell.
//   Increasing it shortens the water column `a`, which LOWERS the frequency,
//   because fn = (1/2pi)sqrt(g*a/(2*A)).
//
//   Commissions a site by freezing the right amount. Seasonally, ice grows
//   downward on its own and re-tunes the unit as the site cools — no adjustment.
//
//   a small -> low frequency (heavily frozen)
//   a large -> high frequency (mostly water, or smaller cell plan area)
//
//   Do NOT set ICE_TOP to the full cell height expecting a solid-ice design. A cell
//   with no liquid column is not a spring; it is a lump, and the sail stops
//   oscillating entirely. See the header correction.
//
// SHOW_WATER = false hides the spring so the ice ballast can be read on its own.
// SHOW_THERMO = false hides the passive freezing stems.
//
// Transport: the sail is FLAT. A stack nests in a fraction of a container. The ice
// is not shipped — it is made from site water after installation.
//
// Issue: #82 | supersedes the interlocked ring/grove approach
//
// Signed: [OpenCode](https://opencode.ai) — 2026-10-07
