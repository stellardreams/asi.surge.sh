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

// --- Serviceability: blade <-> cassette ---
//
// The sail is a SWAP-ON-BLADE assembly, not one welded lump. Arctic labour and parts
// are expensive, so anything that can fail or wear must come off without dismantling
// the structure around it.
//
// What actually needs servicing, in order of frequency:
//   1. the damper cells  — need draining/refilling to re-tune. This is the common job.
//   2. the pivot pin / bearing race — wears every cycle.
//   3. the sail blade itself — rarely.
//   4. the pile — never.
//
// Before this split, servicing item 1 meant CUTTING THE SAIL OPEN. The cells were
// sealed inside the shell with no port and no access. That is the failure the split
// fixes.
//
// Assembly order, bottom to top:
//   lower flange plate (fixed to collar)
//     -> CELL CASSETTE        bolts off, slides out, holds the two-phase cells
//        -> BLADE_GAP         service clearance + thermal break
//           -> SAIL BLADE      bolts off, lifts away
//
// Service sequence: unbolt blade, lift, unbolt cassette, withdraw, drain/refill, refit,
// bolt up. Nothing welded, nothing cut.
BLADE_GAP        = 0.035;    // clearance between cassette top and blade underside
BLADE_BOLTS      = 4;
CASSETTE_BOLTS   = 4;
BLADE_LIFT       = 0.0;      // >0 lifts the blade off for an exploded/service view
CASSETTE_SLIDE   = 0.0;      // >0 withdraws the cassette sideways
BLADE_SHAFT_D    = 0.011;    // M11 quick-release studs
SHOW_HANDLES     = true;     // draw handles, so bolts are undoable by hand in gloves
HANDLE_R         = 0.030;

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
CELL_BAND_H      = 0.62;     // cassette height, and the cell zone inside it
CELL_COLS        = 2;        // cells across the sail width
ICE_TOP          = 0.10;     // frozen depth from the TOP of each cell.
                             // WAS 0.26, which is stable but badly frequency-mismatched
                             // (f_sail/f_abs = 0.65). See §"STABILITY WINDOW" below —
                             // the viable band is roughly 0.05-0.15, and above about
                             // 0.40 the sail TOPPLES. Lower ice means more liquid, and
                             // more liquid is what both stabilises it and matches
                             // the frequencies.
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
SHOW_CANT        = true;     // sail leaning by SAIL_CANT (kinematic mode only)
SHOW_DATUM       = true;     // vertical reference line at the pivot — without it a
                             // few degrees of tilt has nothing to be measured against
                             // and the motion is very hard to see
SHOW_ROCK_ARC    = true;     // oscillation arc about the pivot
ROCK_DEG         = 7;        // working swing of the sail about the pin, degrees

// Upper-plate clearance holes are sized so the plate can rotate the full ROCK_DEG
// without fouling its bolts. Travel at the bolt circle is r*sin(theta), so the hole has
// to swallow that travel plus the shank radius plus a little working room.
// DERIVED — must come after ROCK_DEG, or it silently evaluates to undefined.
FLANGE_CLEAR_R   = FLANGE_BOLT_R * sin(ROCK_DEG) + FLANGE_BOLT_D / 2 + 0.0015;

// --- Animation ---
//
// $t is OpenSCAD's animation time. It is ALWAYS defined (reads 0 when not animating),
// which is how one file serves both a still F6 render and a moving preview.
//
// ANIM_MODE = "kinematic"  the original sin() sweep. Cheap, always smooth, but it is a
//                          picture of motion, not motion. It lies about tuning.
// ANIM_MODE = "dynamic"    a real 2-DOF pendulum-tuned-absorber integration. This is
//                          the one that shows whether the concept actually works.
ANIM_MODE       = "dynamic";
ANIMATE         = true;      // master switch; dynamic mode ignores it since the
                              // ODE always runs when $t is set

ANIM_CYCLES     = 2;         // kinematic sweep only
ANIM_AMPLITUDE  = ROCK_DEG;
ANIM_LEVEL_WATER = true;     // keep the liquid surface level in world space

// --- Real-dynamics parameters (ANIM_MODE = "dynamic") ---
//
// THE SAIL STANDS UP. That is an INVERTED pendulum, so gravity is DESTABILISING, not
// restoring, and the liquid column is what stops the sail falling over. That inverts
// the usual tuned-damper intuition completely — see the note on MASS_RATIO.
G_ACC           = 9.81;
L_SAIL          = 1.30;      // effective pendulum length, pivot to structure CoM (m)
INIT_THETA      = 0.120;     // initial gust deflection (rad) ~ 6.9 deg
T_SIM           = 2.20;      // physical seconds the animation represents. ~2 periods at
                             // 0.91 Hz, so amplitude stays high across the whole run.
                             // Longer runs just show the decay sitting at zero.
ODE_STEPS       = 420;
ZETA_TOTAL      = 0.040;     // combined structural + liquid damping ratio

// Mass ratio. NOT free — it is determined by the water column, which ICE_TOP sets.
//   mu      = m_water / m_structure
//   mu_crit = 2A / (L * a)      <- below this the sail TOPPLES
//   mu      > mu_crit  : stable
// Stability and frequency matching therefore trade off against each other, and the
// usable window is NARROW. Solving it is what ECHO_DIAG below reports.
function mass_ratio() = anim_cell_w() * anim_cell_d() * anim_water_h() * CELL_COLS * 1000
                        / structure_mass();
function structure_mass() =
    // sail shell: 4.473 m2 of 4 mm aluminium
    (2 * SAIL_W * SAIL_H + 2 * SAIL_T * SAIL_H + 2 * SAIL_W * SAIL_T) * SAIL_WALL * 2700
    // two full-height ribs
    + 2 * SAIL_WALL * (SAIL_T - 2 * SAIL_WALL) * (SAIL_H - CELL_BAND_H) * 2700
    // flange plates, bolts, collar, pin — nominal
    + 6.0;

// Cell geometry, derived from the sail and cell parameters.
function anim_cell_w() = (SAIL_W - 2 * SAIL_WALL) / CELL_COLS - SAIL_WALL;
function anim_cell_d() = SAIL_T - 2 * SAIL_WALL - 2 * 0.010;
function anim_cell_h() = CELL_BAND_H - SAIL_WALL;
function anim_cell_A() = anim_cell_w() * anim_cell_d();
function anim_water_h() = anim_cell_h() - ICE_TOP;

// Absorber natural frequency from the liquid column: omega_a^2 = g*a/(2A)
function omega_a() = sqrt(G_ACC * anim_water_h() / (2 * anim_cell_A()));
function f_abs_hz() = omega_a() / (2 * PI);
function mu_crit()  = 2 * anim_cell_A() / (L_SAIL * anim_water_h());
function is_stable() = mass_ratio() * omega_a() * omega_a() > G_ACC / L_SAIL;
// Undamped natural frequency of the stabilised sail, guarded so an unstable
// configuration returns 0 instead of a NaN.
function omega_n() = sqrt(max(0, mass_ratio() * omega_a() * omega_a() - G_ACC / L_SAIL));
function f_sail_hz() = omega_n() / (2 * PI);

// MODEL CHOICE, and it is forced by the numbers rather than preferred.
//
// The textbook 2-DOF pendulum-tuned-absorber model assumes a LIGHT absorber on a heavy
// structure. That assumption is violated here by an order of magnitude: mu is about
// 1.0, meaning the liquid weighs as much as the sail. Checked by eigenanalysis, the
// 2-DOF form then has a POSITIVE eigenvalue — a saddle — and the solution grows
// exponentially instead of oscillating. It was tried, it diverged to 1700 degrees, and
// it is wrong for this geometry.
//
// So the liquid is NOT modelled as an absorber. It is modelled as what it physically
// is here: a stabilising term acting on the sail's inverted pendulum, plus damping.
// That is a single-DOF model and it is stable by construction:
//
//     theta'' = -wn^2 * theta - 2*zeta*wn*theta'
//     wn^2    = mu*wa^2 - g/L          (positive only when the liquid beats gravity)
//
// Consequences, and they matter:
//   - The liquid's job is holding the sail UP, not absorbing vibration. The device is a
//     liquid-stabilised inverted pendulum, which is a different and better-understood
//     machine than a tuned mass damper.
//   - There is NO second resonance to tune to. "Match f_abs to f_sail" was the wrong
//     objective. The relevant figure is simply whether mu*wa^2 exceeds g/L by enough
//     margin, and the ECHO below reports that margin.
//   - At small angles the liquid surface stays essentially level and the liquid moves
//     SIDEWAYS, so liquid_angle_deg() = 0 is the correct small-angle behaviour rather
//     than a simplification. The sloshing resonance is real but is NOT resolved here.
function dyn_deriv(q) = [
    q[1],
    -omega_n() * omega_n() * q[0] - 2 * ZETA_TOTAL * omega_n() * q[1]
];

function qplus(q, d, h) = [q[0] + d[0] * h, q[1] + d[1] * h];

function rk4(q, h) =
    let (k1 = dyn_deriv(q),
         k2 = dyn_deriv(qplus(q, k1, h / 2)),
         k3 = dyn_deriv(qplus(q, k2, h / 2)),
         k4 = dyn_deriv(qplus(q, k3, h)))
    qplus(q, (k1 + 2 * k2 + 2 * k3 + k4) / 6, h);

// fold() does not exist in this OpenSCAD, so the integration recurses.
function dyn_integrate(i, n, q, h) =
    i >= n ? q : dyn_integrate(i + 1, n, rk4(q, h), h);

function dyn_state(frac) =
    let (n = max(0, min(ODE_STEPS, floor(frac * ODE_STEPS))))
    dyn_integrate(0, n, [INIT_THETA, 0], T_SIM / ODE_STEPS);

// Diagnostics — print once per render so a misconfigured sail is visible immediately
// rather than showing up as an animation that simply does not move.
ECHO_DIAG       = true;
if (ECHO_DIAG)
    echo(str("=== SAIL DYNAMICS ===",
             str("  a (water col)      = ", anim_water_h()),
             str("  A (cell plan)      = ", anim_cell_A()),
             str("  structure mass     = ", structure_mass(), " kg"),
             str("  water mass         = ", mass_ratio() * structure_mass(), " kg"),
             str("  mu (mass ratio)    = ", mass_ratio()),
             str("  mu_crit (topples)  = ", mu_crit()),
             str("  STABLE?            = ", is_stable()),
             str("  f_sail (stabilised)= ", f_sail_hz(), " Hz"),
             str("  f_abs (liquid)     = ", f_abs_hz(), " Hz"),
             str("  stability margin   = ", mass_ratio() * omega_a() * omega_a() / (G_ACC / L_SAIL))));

function anim_phase() = is_undef($t) ? 0 : $t;

// Degrees the sail is actually at.
// In dynamic mode the equilibrium is PLUMB, not canted.
//
// This is a physics correction, not a legibility trick. The liquid stabilises the sail
// about vertical — that is what omega_n^2 = mu*wa^2 - g/L means — so adding SAIL_CANT
// on top put the equilibrium in the wrong place. It also made the motion read poorly:
// the sail leaned one way only, so a +-3 deg wobble looked like "nearly still" rather
// than an oscillation.
function sail_angle_deg() =
    ANIM_MODE == "dynamic"
      ? let (q = dyn_state(anim_phase()))
          q[0] * 180 / PI
      : (SHOW_CANT ? SAIL_CANT : 0) + anim_osc();

// Degrees the liquid mass is actually at. Its free surface stays level in world space,
// so this is the surface angle. Equal to sail_angle_deg() in kinematic mode.
// Zero: at small angles the liquid stays level and moves sideways. See MODEL CHOICE.
function liquid_angle_deg() = 0;

function anim_osc() =
    (ANIM_MODE == "dynamic" || !ANIMATE) ? 0
      : ANIM_AMPLITUDE * sin(anim_phase() * 360 * ANIM_CYCLES);

// Rotation the liquid block needs INSIDE the cell so that it lands at liquid_angle_deg()
// in world space, given the cell is already drawn at sail_angle_deg().
function liquid_local_rot() = liquid_angle_deg() - sail_angle_deg();


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
DATUM_COL        = [0.95, 0.25, 0.30, 0.85];   // plumb reference at the pivot
CASSETTE_SHELL   = [0.52, 0.56, 0.62];         // deliberately a different tone from the blade
QR_COL           = [0.95, 0.62, 0.15];          // quick-release hardware
HANDLE_COL       = [0.30, 0.85, 0.55];

// ------------------------------ Helpers --------------------------------------

// Re-added: previously dropped as dead code, now used by the cassette draw handles.
module torus(r_major, r_minor, seg = 32) {
    rotate_extrude(convexity = 4, $fn = seg)
        translate([r_major, 0, 0])
            circle(r = r_minor, $fn = 8);
}

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
// CELL CASSETTE — the serviceable part.
//
// A closed tray holding the two-phase cells, bolted to the upper flange plate. It is the
// component that comes off for draining and re-tuning, which is the frequent job. Pulling
// the whole sail off to reach two cells would be absurd, so the cassette is split out.
module cell_cassette() {
    w = SAIL_W + 0.05;                 // slightly proud of the blade so it reads as a part
    h = CELL_BAND_H;
    color(CASSETTE_SHELL)
        translate([0, 0, h / 2])
            difference() {
                cube([w, SAIL_T + 0.03, h], center = true);
                translate([0, 0, -0.012])
                    cube([w - 0.030, SAIL_T - 0.002, h - 0.024], center = true);
            }
    // cells inside the cassette
    translate([0, 0, h]) damper_bay();

    // quick-release bolts through the cassette flange into the upper plate
    for (i = [0 : CASSETTE_BOLTS - 1])
        translate([(i < CASSETTE_BOLTS/2 ? -1 : 1) * w * 0.40,
                   (i % 2 == 0 ? -1 : 1) * (SAIL_T + 0.03) * 0.30,
                   0.018])
            qr_stud(0.10, BLADE_SHAFT_D);

    // draw handles — so the bolts are undoable by hand in gloves at -40 C
    if (SHOW_HANDLES)
        for (sx = [-1, 1])
            color(HANDLE_COL)
                translate([sx * w * 0.46, 0, h * 0.52])
                    rotate([0, 90, 0])
                        torus(r_major = 0.055, r_minor = 0.010, seg = 20);
}

// Sail blade — bolts to the cassette top, lifts away for service.
//
// Separate from the cassette with a BLADE_GAP so it can be lifted without fouling, and so
// the joint is thermally broken — aluminium to aluminium, no direct path.
module sail_blade() {
    z0 = CELL_BAND_H + BLADE_GAP;
    bh = SAIL_H - z0;
    color(SAILPANEL)
        translate([0, 0, z0 + bh / 2])
            difference() {
                cube([SAIL_W, SAIL_T, bh], center = true);
                translate([0, 0, -SAIL_WALL / 2])
                    cube([SAIL_W - 2 * SAIL_WALL, SAIL_T - 2 * SAIL_WALL,
                          bh - SAIL_WALL], center = true);
                if (SHOW_CUTAWAY)
                    translate([0, -SAIL_T / 2, 0])
                        cube([SAIL_W * 1.4, SAIL_T, bh * 1.4], center = true);
            }

    // blade fixing bolts into the cassette
    for (i = [0 : BLADE_BOLTS - 1])
        translate([(i < BLADE_BOLTS/2 ? -1 : 1) * SAIL_W * 0.34,
                   (i % 2 == 0 ? -1 : 1) * SAIL_T * 0.28,
                   z0 + 0.018])
            qr_stud(0.10, BLADE_SHAFT_D);
}

// Quick-release stud: a captive bolt on a knurled collar, undoned by hand.
// No tools needed, which is the whole point at a remote Arctic site.
module qr_stud(len, d = BLADE_SHAFT_D) {
    color(QR_COL)
        translate([0, 0, len / 2])
            cylinder(h = len, r = d / 2, center = true, $fn = 16);
    color(QR_COL)
        translate([0, 0, -0.012])
            cylinder(h = 0.026, r = d * 1.15, $fn = 16);
}

// Upper stiffener ribs — wall volume only.
// An earlier draft filled these as solid blocks and silently added ~2200 kg, which made
// any ballast-based tuning impossible. Ribs are walls; keep them thin.
module upper_ribs() {
    inner_w = SAIL_W - 2 * SAIL_WALL;
    inner_t = SAIL_T - 2 * SAIL_WALL;
    z0 = CELL_BAND_H + BLADE_GAP + 0.06;   // ribs live in the BLADE only
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
                rotate([liquid_local_rot(), 0, 0])
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

// Vertical datum + swing envelope at the pivot.
//
// A 7-degree tilt of a 2.55 m sail moves its tip by only about 0.31 m. Without a fixed
// vertical reference to compare against, that reads as nothing happening. The datum is
// the plumb line through the pivot; the envelope marks the +/- half-swing.
// Plumb datum + swing envelope at the pivot.
//
// A 7-degree tilt of a 2.55 m sail moves its tip by only ~0.31 m. With nothing fixed to
// measure that against, it reads as nothing happening. So the datum is drawn OUTBOARD of
// the sail — a line up the plumb axis offset clear of the panel — because a plumb line
// drawn up the middle just disappears inside it.
//
// Two ghost edges mark the +/- half-swing envelope at tip height, so the moving sail is
// visibly swinging between two limits rather than just drifting.
module pivot_datum(swing_deg) {
    off = SAIL_W / 2 + 0.16;              // clear of the panel on both sides
    tip = SAIL_H * 1.02;

    for (s = [-1, 1]) {
        // plumb reference, offset outboard
        color(DATUM_COL)
            translate([s * off, 0, PIVOT])
                cylinder(h = tip, r = 0.008, center = true, $fn = 8);
        // tick where plumb meets tip height
        color(DATUM_COL)
            translate([s * off, 0, PIVOT + tip / 2])
                cube([0.030, 0.030, 0.11], center = true);
    }

    // swing envelope: ghost sail edges at the +/- half-swing limits
    for (s = [-1, 1])
        color([0.95, 0.25, 0.30, 0.35])
            rotate([s * swing_deg, 0, 0])
                for (sx = [-1, 1])
                    translate([sx * SAIL_W / 2, 0, PIVOT])
                        cube([0.014, 0.014, SAIL_H], center = true);
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
        rotate([sail_angle_deg(), 0, 0]) {
            if (SHOW_FLANGE)
                translate([0, 0, PLATE_HI_Z])
                    flange_plate(upper = true);

            // cassette — withdraws sideways for service
            translate([CASSETTE_SLIDE, 0, PLATE_HI_Z + FLANGE_T])
                cell_cassette();

            // blade — lifts straight off for service
            translate([0, 0, PLATE_HI_Z + FLANGE_T + BLADE_LIFT])
                sail_blade();

            translate([0, 0, PLATE_HI_Z + FLANGE_T + BLADE_LIFT])
                upper_ribs();
            if (SHOW_CANT && SHOW_ROCK_ARC) cant_arc();
        }

    if (SHOW_ROCK_ARC) rock_arc();

    // datum drawn last and unrotated so it stays plumb while the sail swings
    if (SHOW_DATUM) pivot_datum(abs(INIT_THETA) * 180 / PI);
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
