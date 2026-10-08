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

// --- Sail root flange (the v1 mount boss, repurposed as the root joint) ---
// This is the load-critical joint. The sail's rocking moment arrives HERE and has to
// reach the pile through it, so it is a preloaded bolted flange with a gusset ring
// rather than a bare bearing.
FLANGE_DIA       = 0.54;     // circular plate, spans the sail foot
FLANGE_T         = 0.030;    // each half of the sandwich
FLANGE_BOLTS     = 4;        // count
FLANGE_BOLT_R    = 0.052;    // bolt circle RADIUS, kept small — see note below
FLANGE_BOLT_D    = 0.011;    // M10 shank
FLANGE_GUSSET    = 4;        // gussets around the joint
FLANGE_GUSSET_T  = 0.012;    // gusset web thickness
FLANGE_GUSSET_D  = 0.055;    // cone depth below the lower plate
FLANGE_GAP       = 0.030;    // gap between the plates — bolt clearance only
FLANGE_PIN_R     = 0.055;    // pivot pin radius — carries rotation, not moment
FLANGE_PRELOAD   = true;     // true = bolts drawn tensioned (the "tightened" state)
FLANGE_NUT_H     = 0.020;
SHOW_FLANGE      = true;

// --- Operating state ---
SHOW_CANT        = true;     // sail leaning by SAIL_CANT
SHOW_ROCK_ARC    = true;     // oscillation arc about the pivot
ROCK_DEG         = 7;        // working swing of the sail about the pin, degrees

// Upper-plate clearance holes are sized so the plate can rotate the full ROCK_DEG
// without fouling its bolts. Travel at the bolt circle is r*sin(theta), so the hole has
// to swallow that travel plus the shank radius plus a little working room.
// DERIVED — must come after ROCK_DEG, or it silently evaluates to undefined.
FLANGE_CLEAR_R   = FLANGE_BOLT_R * sin(ROCK_DEG) + FLANGE_BOLT_D / 2 + 0.0015;

// --- Animation ---
// $t is defined ONLY while OpenSCAD is animating (or when you pass -D '$t=0.5').
// is_undef($t) therefore means "static render", which is how the same file serves both
// a still F6 render and a moving preview without any extra switching.
ANIMATE          = true;
ANIM_CYCLES      = 2;         // full rock cycles across one animation run
ANIM_AMPLITUDE   = ROCK_DEG;
ANIM_LEVEL_WATER = true;      // keep the liquid surface horizontal while the cell tilts

// Live rock angle, in degrees, about the pivot. 0 when not animating.
function anim_osc() =
    (ANIMATE && !is_undef($t)) ? ANIM_AMPLITUDE * sin($t * 360 * ANIM_CYCLES) : 0;

// Total sail lean: static cant plus any live animation offset.
function sail_tilt() = (SHOW_CANT ? SAIL_CANT : 0) + anim_osc();

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
FLANGE_PLATE     = [0.46, 0.48, 0.52];
FLANGE_GUSSET_C  = [0.56, 0.58, 0.62];
BOLT_STEEL       = [0.80, 0.82, 0.86];
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
    // collar stops UNDER the flange joint, so the flange is the joint rather than a
    // bearing perched on top of a finished column
    top = PIVOT + PLATE_LO_Z - FLANGE_GUSSET_D;
    color(COLLAR_METAL)
        translate([0, 0, (z0 + top) / 2])
            cylinder(h = top - z0, r = COLLAR_W / 2, center = true, $fn = 40);
    // spigot — registers the lower plate and takes the gusset cone load in bearing
    color(COLLAR_METAL)
        translate([0, 0, top - 0.014])
            cylinder(h = 0.028, r = FLANGE_PIN_R * 1.35, center = true, $fn = 32);
    if (SHOW_PIVOT) {
        // bearing race — the rotation surface the sail rocks on
        color(BEARING)
            translate([0, 0, PIVOT + FLANGE_MID])
                cylinder(h = FLANGE_PIN_R * 1.1, r = FLANGE_PIN_R * 1.9, center = true, $fn = 36);
    }
    // pivot pin through the whole joint, along X
    color(COLLAR_METAL)
        translate([0, 0, PIVOT + FLANGE_MID])
            rotate([90, 0, 0])
                cylinder(h = FLANGE_DIA * 1.02, r = FLANGE_PIN_R, center = true, $fn = 32);
}

// Sail root flange — the primary load path.
//
// A NOTE ON WHAT THIS JOINT ACTUALLY IS, because the honest answer is not "a tight
// flange". A tight bolted flange and a joint that rotates 7 degrees are mutually
// exclusive. Bolts at any useful bolt circle would have to be dragged ~22 mm sideways
// by a 6 degree rotation at the original 0.42 m PCD, which no bolt can follow. So the
// joint is a BEARING with bolted retention, and the two jobs are split:
//
//   ROTATION  -> the pin, on the bearing race
//   MOMENT    -> the gusset cone, in bearing against the collar spigot
//   SEPARATION-> the bolts, kept in tension by preload
//
// The rocking moment tries to pull the plates APART on one side of the joint and press
// them together on the other. The bolts live in that separating half. Preloading them
// means they never unload to zero, so the plates never lift, fret and mill, and the
// loose-bolt impact on the next gust never happens. That is the "tightened" benefit and
// it is real — but it is anti-separation, not anti-rotation. Something has to give, and
// it is the pin.
//
// Reuses the v1 mount-boss geometry (base plate, bolt circle, gusset polygon) that sat
// on top of the AMU hull, relocated to the sail foot where the load actually is.
//
// WHY IT IS BOLTED AND PRELOADED RATHER THAN A PLAIN BEARING
//
// The sail rocks about the pivot, so this joint carries a REVERSING bending moment
// every cycle — tension on one side of the bolt circle, compression on the other. That
// is the worst case for an unpreloaded bolted joint: the bolts go slack on the
// tension side, the joint works loose, the faces fret and mill, and on the next gust
// the loose bolt slams shut with an impact. Fatigue life in that regime is orders of
// magnitude worse than the same joint kept tight.
//
// Preloading holds the joint closed through the whole cycle. Wind variation then rides
// ON TOP of a steady bolt tension instead of alternating between zero and peak. The
// bolts still see cyclic load, but the joint never opens, so there is no fretting and
// no impact. That is what FLANGE_PRELOAD = true represents.
//
// The gusset ring is the other half of the job. Bolts alone resist moment by stretching;
// a gusset resists it by bearing. Together they share the load, and the gusset is what
// keeps the plate edges from peeling.
// Joint mid-plane. The pivot pin sits here, so rotation happens about the pin and the
// bolts see only small one-directional shear per cycle rather than a racking motion.
FLANGE_MID   = 0;
PLATE_LO_Z   = -(FLANGE_GAP / 2 + FLANGE_T);
PLATE_HI_Z   =  (FLANGE_GAP / 2);

// Flange plate — lower bolted to the collar, upper clamped to the sail foot.
module flange_plate(upper = false) {
    zc = upper ? PLATE_HI_Z + FLANGE_T / 2 : PLATE_LO_Z + FLANGE_T / 2;
    color(FLANGE_PLATE)
        translate([0, 0, zc])
            difference() {
                cylinder(h = FLANGE_T, r = FLANGE_DIA / 2, center = true, $fn = 48);
                for (i = [0 : max(FLANGE_BOLTS - 1, 0)])
                    translate([FLANGE_BOLT_R * cos(i * 360 / max(FLANGE_BOLTS, 1)),
                               FLANGE_BOLT_R * sin(i * 360 / max(FLANGE_BOLTS, 1)), 0])
                        cylinder(h = FLANGE_T * 3,
                                 r = upper ? FLANGE_CLEAR_R : FLANGE_BOLT_D / 2,
                                 center = true, $fn = 20);
                // central bore — the pivot pin passes through and carries no shear
                cylinder(h = FLANGE_T * 3, r = FLANGE_PIN_R * 1.35, center = true, $fn = 32);
            }
}

// Gusset cone — the moment path, and part of the LOWER (static) assembly.
//
// Welded to the collar spigot and to the underside of the lower plate, so the socket
// and its webs are one rigid body. The upper plate hangs off it on bolts alone.
//
// NOTE: gussets welded across the plate gap to BOTH plates would lock the joint solid
// and the sail could not rock at all. That was the first arrangement attempted and it is
// structurally wrong, not merely untidy — the webs have to stay with the static side.
// Nor are they sandwiched BETWEEN the plates: the first version placed them there and
// with the plates touching, they punched straight through both.
module flange_gussets() {
    r_in  = COLLAR_W / 2;
    r_out = FLANGE_DIA / 2 - 0.014;
    z_top = PLATE_LO_Z;
    for (i = [0 : max(FLANGE_GUSSET - 1, 0)])
        color(FLANGE_GUSSET_C)
            rotate([0, 0, i * 360 / max(FLANGE_GUSSET, 1)])
                translate([r_in, 0, z_top])
                    rotate([90, 0, 0])
                        linear_extrude(height = FLANGE_GUSSET_T)
                            polygon([[0, 0],
                                     [r_out - r_in, 0],
                                     [0, -FLANGE_GUSSET_D]]);
}

// Through-bolts tying the plates together.
//
// Shear capacity from the bolts, bearing capacity from the gusset cone. FLANGE_PRELOAD
// reflects that the PRELOADED state is the only correct operating state — a slack joint
// is not a design option here, because it is a cyclic reversing moment.
module flange_bolts() {
    z_span = PLATE_HI_Z + FLANGE_T + 0.024 - (PLATE_LO_Z - 0.024);
    z_mid  = (PLATE_HI_Z + FLANGE_T + 0.024 + PLATE_LO_Z - 0.024) / 2;
    for (i = [0 : max(FLANGE_BOLTS - 1, 0)]) {
        ang = i * 360 / max(FLANGE_BOLTS, 1);
        bx  = FLANGE_BOLT_R * cos(ang);
        by  = FLANGE_BOLT_R * sin(ang);
        color(BOLT_STEEL)
            translate([bx, by, z_mid])
                cylinder(h = z_span, r = FLANGE_BOLT_D / 2, center = true, $fn = 16);
        // countersunk head below the lower plate
        color(BOLT_STEEL)
            translate([bx, by, PLATE_LO_Z - 0.009])
                cylinder(h = 0.018, r = FLANGE_BOLT_D * 1.05, center = true, $fn = 16);
        // hex nut above the upper plate
        color(BOLT_STEEL)
            translate([bx, by, PLATE_HI_Z + FLANGE_T + FLANGE_NUT_H / 2])
                cylinder(h = FLANGE_NUT_H, r = FLANGE_BOLT_D * 1.15, $fn = 6);
    }
}

// Sail root flange — the primary load path.
//
// A NOTE ON WHAT THIS JOINT ACTUALLY IS, because the honest answer is not "a tight
// flange". A tight bolted flange and a joint that rotates 7 degrees are mutually
// exclusive. Bolts at any useful bolt circle would have to be dragged ~22 mm sideways
// by a 6 degree rotation at the original 0.42 m PCD, which no bolt can follow. So the
// joint is a BEARING with bolted retention, and the two jobs are split:
//
//   ROTATION  -> the pin, on the bearing race
//   MOMENT    -> the gusset cone, in bearing against the collar spigot
//   SEPARATION-> the bolts, kept in tension by preload
//
// The rocking moment tries to pull the plates APART on one side of the joint and press
// them together on the other. The bolts live in that separating half. Preloading them
// means they never unload to zero, so the plates never lift, fret and mill, and the
// loose-bolt impact on the next gust never happens. That is the "tightened" benefit and
// it is real — but it is anti-separation, not anti-rotation. Something has to give, and
// it is the pin.
//
// Reuses the v1 mount-boss geometry (base plate, bolt circle, gusset polygon) that
// originally sat on top of the AMU hull, relocated to the sail foot where the load
// actually is.
//
// WHY A PRELOADED BOLTED FLANGE RATHER THAN A PLAIN BEARING
//
// The sail rocks about the pivot, so this joint carries a REVERSING bending moment every
// cycle — tension on one side of the bolt circle, compression on the other. That is the
// worst case for an unpreloaded bolted joint: the bolts go slack on the tension side, the
// joint works loose, the faces fret and mill, and on the next gust the loose bolt slams
// shut with an impact. Fatigue life in that regime is orders of magnitude worse than the
// same joint kept tight.
//
// Preloading holds the joint closed through the whole cycle, so wind variation rides ON
// TOP of a steady bolt tension instead of alternating between zero and peak. The bolts
// still see cyclic load, but the joint never opens, so there is no fretting and no
// impact. That is the "tightened" state and the only correct operating state.
//
// LOAD PATH, top to bottom:
//   sail foot -> upper plate -> bolts in shear -> lower plate + gusset cone (rigid)
//   -> collar spigot -> collar -> footing -> helical pile -> frozen soil
//
// The gusset cone is what stops the moment being carried by bolt stretch alone, and it
// is why the plate can stay this thin. Bolt SIZING is not done — FLANGE_BOLT_D and
// FLANGE_BOLTS are placeholders and no moment capacity has been calculated.

// One sealed damper cell — two phases, one spring.
//
//   ice   frozen in from the TOP -> ballast, thermal buffer, seasonal regulator
//   water liquid at the BOTTOM  -> the spring. Height `a` sets f_abs = sqrt(g*a/2A)
//
// The ice is ABOVE the water deliberately. That ordering is what makes the seasonal
// behaviour correct: as the site cools, ice grows downward into the liquid and
// shortens the column, which sweeps f_abs down toward the sail's frequency. The unit
// tracks the season without anyone touching it.
// Sail panel — 4 mm aluminium box, open at the bottom so meltwater sheds.
//
// SHOW_CUTAWAY removes the windward half of the SHELL only, leaving the damper cells
// intact. Without it the two-phase cells — the entire point of the design — are sealed
// inside an opaque box and invisible in every view.
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
// An earlier draft filled these as solid blocks and silently added ~2200 kg, which made
// any ballast-based tuning impossible. Ribs are walls; keep them thin.
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

    // Liquid column — the spring.
    //
    // The ICE is frozen to the walls, so it rotates with the cell. The WATER is free, so
    // its surface stays level in world space while the cell tilts. Counter-rotating the
    // water block by the sail's tilt is what shows the spring working: the gap opens on
    // the up side and closes on the down side, and that deviation is the restoring force.
    //
    // Schematic caveat: the block is counter-rotated about its own centre rather than
    // genuinely redistributing, so it slightly interpenetrates the cell walls at full
    // tilt. Acceptable for a structural schematic; a real simulation would solve the
    // free-surface shape.
    if (SHOW_WATER) {
        water_h = cell_h - ICE_TOP;
        if (ANIM_LEVEL_WATER)
            translate([0, 0, z_top - cell_h / 2])
                rotate([-sail_tilt(), 0, 0])
                    translate([0, 0, cell_h / 2 - wall - ICE_TOP - water_h / 2])
                        color(WATER_FILL)
                            cube([cell_w - 2 * wall - 0.003,
                                  cell_d - 2 * wall - 0.003, water_h], center = true);
        else
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
        translate([0, 0, PIVOT + FLANGE_MID])
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

    // Static side of the joint: lower plate, gusset cone, bolts. Does not rock.
    if (SHOW_FLANGE)
        translate([0, 0, PIVOT]) {
            flange_plate(upper = false);
            flange_gussets();
            flange_bolts();
        }

    // Rocking side: upper plate clamped to the sail foot, plus the sail itself.
    translate([0, 0, PIVOT])
        rotate([sail_tilt(), 0, 0]) {
            if (SHOW_FLANGE)
                translate([0, 0, PLATE_HI_Z])
                    flange_plate(upper = true);
            translate([0, 0, PLATE_HI_Z + FLANGE_T])
                sail_panel();
            translate([0, 0, PLATE_HI_Z + FLANGE_T])
                damper_bay();
            translate([0, 0, PLATE_HI_Z + FLANGE_T])
                upper_ribs();
            if (SHOW_CANT && SHOW_ROCK_ARC) cant_arc();
        }

    if (SHOW_ROCK_ARC) rock_arc();
}

// ------------------------------- Render --------------------------------------

sail_unit();

// ANIMATION
//
// Press F5, then the play arrow at the bottom of the preview window. The sail rocks
// through ANIM_CYCLES cycles and the liquid surface stays level while the cell tilts.
//
// Headless, for a video:
//   scripts/render_sail_animation.sh          # frames + MP4 into wind/renders/
//
// Set ANIMATE = false for a still, or pass -D '$t=0.25' to freeze a single frame.
// Note that F6/Render on a still is unaffected — $t is undefined there, so anim_osc()
// returns 0 and the sail sits at its static cant.
//
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
