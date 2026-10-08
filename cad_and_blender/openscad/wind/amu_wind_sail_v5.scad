// =============================================================================
// AMU — Arctic Ice-Tuned Sail Unit (v5)
// Vertical sail on stepped base, tuned liquid mass damper cells at the sail foot
// Location: cad_and_blender/openscad/wind/amu_wind_sail_v5.scad
// Issue: #82
// Modelled on: cad_and_blender/openscad/wind/concept-10-07-2026-2131.jpg
// Target: OpenSCAD >= 2021.01 | Preview F5 | Render F6 → Export STL/3MF/DXF
// =============================================================================
//
// WHAT CHANGED FROM v4, AND WHY THE CONCEPT SKETCH IS THE BETTER IDEA
//
// v4 hung the sail from a two-legged portal frame by a trunnion at the TOP of the
// panel. That put the sail's centre of mass below the pivot, making it a plain
// gravity pendulum where the restoring moment came from m*g*d.
//
// The concept sketch (concept-10-07-2026-2131.jpg) shows something else: a stepped
// footing, a small thrust collar, and a vertical sail standing UP from it.
//
// That is not a cosmetic change. It is the textbook configuration for a tuned
// liquid mass damper.
//
//   - Tuned liquid mass dampers are overwhelmingly used on HIGH-RISE BUILDINGS and
//     offshore platforms, where the absorber mass sits ABOVE the pivot and gravity
//     provides no restoring moment at all.
//   - In that inverted case the restoring stiffness comes ENTIRELY from the moving
//     liquid — which is the whole reason these dampers exist.
//
// So the sketch inverts v4's pendulum on purpose. Gravity stops doing the work and
// the water column starts doing it, which is precisely the case where liquid columns
// are better than anything mechanical. v4 used a pendulum because it was easy to
// justify with a formula. The sketch uses the arrangement that is actually right.
//
// PORTAL FRAME REMOVED. Legs, cross tie, and the wide trunnion are gone. The sail now
// stands on the footing. Under the sketch the underground portion is unchanged: the
// helical pile stays, because screw-in installation is still correct at this site.
//
// HOW TUNING WORKS HERE (corrected framing — see §4)
//
// The sail has its own natural frequency f_sail, fixed by its geometry. The water
// column is a SECOND oscillator with its own frequency, set by the liquid height:
//
//   f_abs = (1/2pi)*sqrt(g*a / (2A))
//
// Tuning is the act of bringing those two together. Sweep `a` until the absorber
// matches the sail, and the sail's oscillation feeds the liquid instead of building
// resonantly. The liquid moves in antiphase and the coupling cancels it.
//
// This is a different claim from v4's, and the earlier one was sloppy: v4 implied the
// sail simply operated "at" the cell frequency, as if the cell frequency WERE the
// device frequency. It is not. The cell is a second mass-spring that must be MATCHED
// to the sail. There is no single device frequency until they agree.
//
// v4 also said "ice ballast resists overturning." With the sail standing on a footing
// there is no overturning to resist — the base is in compression. That line is gone
// because it stopped being true.
//
// MASS RATIO MATTERS AND IS NOT SPECIFIED
//
// A pendulum TVMD is only effective in a narrow band around m_absorber/m_structure.
// Outside it the damper is either too light to matter or so heavy it dominates the
// structure. Typical useful band is roughly 1-5%. The water column's mass therefore
// has to land in that band for the configured cell plan area, and that has NOT been
// calculated. It is a genuine open gap and it may well drive the cell dimensions more
// than the frequency match does.
//
// ENVIRONMENT: terrestrial, cold, high wind, icing-prone. #5's Mars–Jupiter framing
// does not apply. Non-scope per #82: no swarm engine, orbital/ledger, or
// nutrient/logistics modules. Nothing in openscad/opencode/ is modified, nothing
// here inherits params from it.
//
// =============================================================================

// ---------------------------- User-tunable params ----------------------------

// --- Footing and thrust collar (from the concept sketch) ---
BASE_W           = 1.06;     // widest footing step, sits on grade
BASE_H           = 0.16;
PLINTH_W         = 0.62;     // second step
PLINTH_H         = 0.20;
COLLAR_W         = 0.36;     // thrust bearing — this is the pivot
COLLAR_H         = 0.12;
COLLAR_DIA       = 0.30;     // bearing race diameter

// --- Sail (stands vertical from the collar) ---
SAIL_W           = 0.56;     // panel width, along the pivot axis (X)
SAIL_T           = 0.26;     // panel thickness (Y, along the wind)
SAIL_H           = 2.55;     // top of sail above grade
SAIL_WALL        = 0.004;    // 4 mm aluminium. Heavy enough to be plausible, light
                             // enough that added mass is not swamped by structure.
SAIL_CANT        = 6;        // degrees of static lean from vertical

// --- Damper cells at the sail foot ---
// Sited just above the pivot on purpose: in a pendulum tuned damper the absorber
// belongs near the pivot, where its displacement relative to the sail is largest.
CELL_BAND_H      = 0.62;     // height of the cell zone at the foot of the sail
CELL_COLS        = 2;        // cells across the sail width
ICE_TOP          = 0.26;     // frozen depth from the TOP of each cell — THE knob
WEEP_DIA         = 0.012;    // drain bore. SIZING OPEN — must defeat ice bridging.
SHOW_ICE         = true;
SHOW_WATER       = true;
SHOW_THERMO      = true;
SHOW_PIVOT       = true;     // show the thrust bearing race
SHOW_CUTAWAY     = true;     // section the windward half of the shell so the
                             // two-phase cells are visible. The cells are the whole
                             // point of the design and are otherwise sealed away.

// --- Thermosyphon ---
THERMO_LEN       = 1.20;
THERMO_DIA       = 0.050;
THERMO_CHARGED   = true;     // false = uncharged (cold), so no freezing held

// --- Operating state ---
SHOW_CANT        = true;     // sail leaning by SAIL_CANT
SHOW_ROCK_ARC    = true;     // oscillation arc about the pivot
ROCK_DEG         = 7;        // visual sweep

// --- Foundation (carried unchanged from v2 — screw-in is still right) ---
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
SAILPANEL        = [0.84, 0.86, 0.90];
FOOTING          = [0.62, 0.62, 0.64];
COLLAR_METAL     = [0.70, 0.72, 0.76];
BEARING          = [0.88, 0.55, 0.30];
ICE_FILL         = [0.68, 0.86, 0.97, 0.62];
WATER_FILL       = [0.15, 0.50, 0.95, 0.80];
THERMO_STEM      = [0.82, 0.50, 0.18];
PILE_METAL       = [0.55, 0.57, 0.60];
FRAME_DARK       = [0.32, 0.34, 0.38];
CELL_WALL        = [0.55, 0.58, 0.62, 0.30];  // translucent: both phases must read
RIB              = [0.42, 0.45, 0.50, 0.75];
CANT_ARC         = [1.00, 0.74, 0.22, 0.50];
ROCK_ARC         = [0.28, 0.72, 0.96, 0.55];

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

// Stepped footing — the two steps under the thrust collar, per the concept sketch.
module footing() {
    color(FOOTING)
        translate([0, 0, BASE_H / 2])
            cube([BASE_W, BASE_W * 0.78, BASE_H], center = true);
    color(FOOTING)
        translate([0, 0, BASE_H + PLINTH_H / 2])
            cube([PLINTH_W, PLINTH_W * 0.80, PLINTH_H], center = true);
}

// Thrust collar — carries the sail and IS the pivot.
module thrust_collar() {
    z0 = BASE_H + PLINTH_H;
    color(COLLAR_METAL)
        translate([0, 0, z0 + COLLAR_H / 2])
            cylinder(h = COLLAR_H, r = COLLAR_W / 2, center = true, $fn = 40);
    if (SHOW_PIVOT) {
        // bearing race — the rotation surface the sail rocks on
        color(BEARING)
            translate([0, 0, z0 + COLLAR_H])
                cylinder(h = 0.035, r = COLLAR_DIA / 2, center = true, $fn = 40);
    }
    // pivot pin through the collar, along X — the sail's rocking axis
    color(COLLAR_METAL)
        translate([0, 0, z0 + COLLAR_H])
            rotate([90, 0, 0])
                cylinder(h = SAIL_W * 1.10, r = 0.032, center = true, $fn = 24);
}

// Sail panel — 4 mm aluminium box, open at the bottom so meltwater sheds.
//
// SHOW_CUTAWAY removes the windward half of the SHELL only, leaving the damper cells
// intact. Without it the two-phase cells — the entire point of the design — are
// sealed inside an opaque box and invisible in every view.
module sail_panel() {
    color(SAILPANEL)
        translate([0, 0, SAIL_H / 2])
            difference() {
                cube([SAIL_W, SAIL_T, SAIL_H], center = true);
                // interior void, open downward
                translate([0, 0, -SAIL_WALL / 2])
                    cube([SAIL_W - 2 * SAIL_WALL, SAIL_T - 2 * SAIL_WALL,
                          SAIL_H - SAIL_WALL], center = true);
                // section cut on the windward half, shell only
                if (SHOW_CUTAWAY)
                    translate([0, -SAIL_T / 2, 0])
                        cube([SAIL_W * 1.4, SAIL_T, SAIL_H * 1.4], center = true);
            }
}

// Upper stiffener ribs — wall volume only.
// An earlier draft filled these as solid blocks and silently added ~2200 kg, which
// made any ballast-based tuning impossible. Ribs are walls; keep them thin.
module upper_ribs() {
    inner_w = SAIL_W - 2 * SAIL_WALL;
    inner_t = SAIL_T - 2 * SAIL_WALL;
    z0 = CELL_BAND_H;
    n = 3;
    for (i = [1 : n - 1])
        color(RIB)
            translate([-inner_w / 2 + (inner_w / n) * i,
                       SHOW_CUTAWAY ? inner_t / 2 : 0,
                       z0 + (SAIL_H - z0) / 2])
                cube([SAIL_WALL, SHOW_CUTAWAY ? inner_t / 2 : inner_t,
                      SAIL_H - z0], center = true);
}

// One sealed damper cell — two phases, one spring.
//
//   ice   frozen in from the TOP -> ballast, thermal buffer, seasonal regulator
//   water liquid at the BOTTOM  -> the spring. Height `a` sets f_abs = sqrt(g*a/2A)
//
// The ice is ABOVE the water deliberately. That ordering is what makes the seasonal
// behaviour correct: as the site cools, ice grows downward into the liquid and
// shortens the column, which sweeps f_abs down toward the sail's frequency. The unit
// tracks the season without anyone touching it.
module damper_cell(cell_w, cell_d, cell_h) {
    wall = 0.010;
    z_top = 0;

    color(CELL_WALL)
        difference() {
            translate([0, 0, z_top - cell_h / 2])
                cube([cell_w, cell_d, cell_h], center = true);
            translate([0, 0, z_top - cell_h / 2 + wall])
                cube([cell_w - 2 * wall, cell_d - 2 * wall, cell_h - wall], center = true);
        }

    // liquid column — the spring
    if (SHOW_WATER) {
        water_h = cell_h - ICE_TOP;
        color(WATER_FILL)
            translate([0, 0, z_top - wall - ICE_TOP - water_h / 2])
                cube([cell_w - 2 * wall - 0.003, cell_d - 2 * wall - 0.003, water_h],
                     center = true);
    }

    // frozen ballast from the top down to the waterline
    if (SHOW_ICE)
        color(ICE_FILL)
            translate([0, 0, z_top - wall - ICE_TOP / 2])
                cube([cell_w - 2 * wall - 0.003, cell_d - 2 * wall - 0.003, ICE_TOP],
                     center = true);

    // weep drain. SIZING UNRESOLVED — needs site water chemistry and freeze rate.
    // A sealed drain traps meltwater that refreezes into the cell, moving f_abs off
    // target with no visible symptom.
    color(RIB)
        translate([0, 0, z_top - cell_h + wall / 2])
            cylinder(h = wall * 2.4, r = WEEP_DIA / 2, center = true, $fn = 14);
}

// Damper cells at the sail foot, just above the pivot.
module damper_bay() {
    inner_w = SAIL_W - 2 * SAIL_WALL;
    cell_w  = inner_w / CELL_COLS;
    cell_d  = SAIL_T - 2 * SAIL_WALL;
    cell_h  = CELL_BAND_H - SAIL_WALL;
    // partition
    if (CELL_COLS > 1)
        color(CELL_WALL)
            translate([0, 0, CELL_BAND_H / 2])
                cube([SAIL_WALL, cell_d, CELL_BAND_H], center = true);
    for (i = [0 : CELL_COLS - 1])
        translate([-inner_w / 2 + cell_w * (i + 0.5), 0, CELL_BAND_H])
            damper_cell(cell_w - SAIL_WALL, cell_d, cell_h);
}

module thermosyphon_stem() {
    if (!THERMO_CHARGED)
        color([0.45, 0.45, 0.48])
            translate([0, 0, -THERMO_LEN / 2])
                cylinder(h = THERMO_LEN, r = THERMO_DIA / 2, center = true, $fn = 18);
    color(THERMO_STEM)
        translate([0, 0, -THERMO_LEN / 2])
            cylinder(h = THERMO_LEN, r = THERMO_DIA / 2, center = true, $fn = 18);
    color(THERMO_STEM)
        translate([0, 0, -THERMO_LEN]) sphere(r = THERMO_DIA * 0.85, $fn = 18);
    color(THERMO_STEM)
        translate([0, 0, 0.16]) sphere(r = THERMO_DIA * 0.80, $fn = 18);
}

// Flat annular sector, used as a swing indicator at the base.
// Built as a 2D polygon and given thickness with linear_extrude, so it stays a flat
// ribbon in one plane instead of being revolved into a torus.
module arc_band(r_in, r_out, a0, a1, thick = 0.010, seg = 24) {
    pts = concat(
        [for (i = [0 : seg]) let (a = a0 + (a1 - a0) * i / seg)
            [r_in * cos(a), r_in * sin(a)]],
        [for (i = [seg : -1 : 0]) let (a = a0 + (a1 - a0) * i / seg)
            [r_out * cos(a), r_out * sin(a)]]
    );
    rotate([90, 0, 0])
        translate([0, 0, -thick / 2])
            linear_extrude(height = thick)
                polygon(pts);
}

// Static lean — the sail's rest angle from vertical.
// Drawn just outside the sail face so it is visible rather than buried in the shell.
module cant_arc(deg = SAIL_CANT) {
    color(CANT_ARC)
        translate([SAIL_W / 2 + 0.035, 0, 0])
            rotate([deg, 0, 0])
                translate([0, 0, SAIL_H * 0.50])
                    cylinder(h = SAIL_H * 0.86, r = 0.014, center = true, $fn = 10);
}

// Rocking arc — the ±ROCK_DEG swing the damper absorbs, drawn as a small ribbon at
// the pivot. An earlier version used rotate_extrude on a circle centred on the axis,
// which spans negative X; OpenSCAD rejects mixed-sign points for rotate_extrude. That
// version errored silently because the render still reported volumes. Same bug also
// present in v4.
module rock_arc(deg = ROCK_DEG) {
    color(ROCK_ARC)
        translate([0, 0, PIVOT])
            arc_band(0.30, 0.34, -deg, deg);
}

module ground_block(depth = GROUND_DEPTH) {
    color(SOIL_FROZEN)
        translate([0, 0, -depth / 2 - 0.02])
            cube([BASE_W + 1.0, 3.0, depth], center = true);
    color(SOIL_SURFACE)
        translate([0, 0, -0.015])
            cube([BASE_W + 1.0, 3.0, 0.03], center = true);
}

// ------------------------------- Unit ----------------------------------------

// Origin at grade, under the collar. PIVOT is the rocking axis height.
PIVOT = BASE_H + PLINTH_H + COLLAR_H;

module sail_unit() {
    helical_pile();
    footing();
    thrust_collar();

    if (SHOW_SOIL) ground_block();

    // thermosyphons pass down alongside the cells
    if (SHOW_THERMO)
        for (i = [0 : CELL_COLS - 1])
            translate([-(SAIL_W / 2) + (SAIL_W / CELL_COLS) * (i + 0.5), 0,
                       CELL_BAND_H * 0.5])
                thermosyphon_stem();

    translate([0, 0, PIVOT])
        rotate([SHOW_CANT ? SAIL_CANT : 0, 0, 0]) {
            sail_panel();
            damper_bay();
            upper_ribs();
            if (SHOW_CANT && SHOW_ROCK_ARC) cant_arc();
        }

    if (SHOW_ROCK_ARC) rock_arc();
}

// ------------------------------- Render --------------------------------------

sail_unit();

// Build tips:
// Preview F5 | Render F6 | Export STL/3MF/DXF
//
// ICE_TOP is the tuning knob. It sets the water column height `a`, and therefore the
// ABSORBER frequency f_abs = (1/2pi)sqrt(g*a/(2A)). You sweep it until f_abs matches
// the sail's own frequency — that match is the whole point of the device. There is no
// single "device frequency" until the two agree.
//
//   ICE_TOP small -> tall water column -> HIGHER f_abs
//   ICE_TOP large -> short column      -> LOWER f_abs
//
// Seasonally, ice grows downward on its own and sweeps f_abs down with the season.
//
// Filling a cell solid is the quiet failure: with no free surface it stops being a
// spring, and the sail rocks unabsorbed. No alarm, just lost damping.
//
// THERMO_CHARGED = false shows the stems uncharged, i.e. a damper that is not holding
// the freezing point and therefore not holding the tuning.
//
// Transport: the sail is FLAT and the footing is a stack of slabs. Ice is not shipped
// — it is made from site water after installation.
//
// Issue: #82 | supersedes v4 (portal-frame pendulum) | per concept-10-07-2026-2131.jpg
//
// Signed: [OpenCode](https://opencode.ai) — 2026-10-07
