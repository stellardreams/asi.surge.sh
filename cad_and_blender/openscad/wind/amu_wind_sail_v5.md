# AMU — Arctic Ice-Tuned Sail Unit (v5)

Issue #82 · vertical sail on stepped base, tuned liquid mass damper cells at the sail foot
Geometry: `amu_wind_sail_v5.scad` (same directory)
Concept: `concept-10-07-2026-2131.jpg`

---

## 1. What this is

A flat vertical sail standing on a stepped footing, rocking about a thrust collar at
its base. At the foot of the sail are sealed cells holding **two phases**: ice frozen
down from the top, liquid water below. The water's free surface is a spring.

Modelled on the concept sketch. The underground portion is unchanged from v4 — the
helical pile stays, because screw-in installation is still correct at this site.

## 2. The concept sketch is the better configuration, and it isn't just cosmetic

v4 hung the sail from a two-legged portal frame by a trunnion at the *top* of the panel.
That put the centre of mass below the pivot, making it a plain gravity pendulum where
restoring moment came from `m·g·d`.

The sketch shows something else: stepped footing, small thrust collar, vertical sail
standing **up**.

**That is the textbook configuration for a tuned liquid mass damper.** TLMDs are
overwhelmingly used on high-rise buildings and offshore platforms — where the absorber
mass sits *above* the pivot and gravity provides no restoring moment at all. In that
inverted case, all the restoring stiffness comes from the moving liquid, which is the
entire reason these dampers exist as a technology.

So the sketch inverts v4's pendulum deliberately. Gravity stops doing the work and the
water column starts. v4 chose a pendulum because it was easy to justify with a formula.
The sketch chooses the arrangement that is actually right.

Portal frame, legs, cross tie, and wide trunnion: **removed**.

## 3. How tuning actually works — corrected framing

The sail has its own natural frequency `f_sail`, fixed by geometry. The water column is
a **second** oscillator:

```
f_abs = (1/2π)·√(g·a / (2A))
```

Tuning is bringing those two together. Sweep `a` until the absorber matches the sail,
and the sail's oscillation feeds the liquid instead of building resonantly. The liquid
moves in antiphase and the coupling cancels it.

**This corrects v4**, which implied the sail simply operated "at" the cell frequency, as
if the cell frequency *were* the device frequency. It is not. The cell is a second
mass-spring that must be *matched* to the sail. There is no single device frequency
until the two agree.

v4 also said the ice ballast resists overturning. With the sail standing on a footing
there is no overturning to resist — the base is in compression. That claim is gone
because it stopped being true.

Cell as built: 272 × 232 × 616 mm, plan area `A = 0.0631 m²`.

| `ICE_TOP` | water column `a` | `f_abs` | water per cell |
|---|---|---|---|
| 0.06 m | 0.556 m | **1.046 Hz** (highest) | 35.1 kg |
| **0.26 m** (default) | **0.356 m** | **0.837 Hz** | 22.5 kg |
| 0.48 m | 0.136 m | 0.517 Hz | 8.6 kg |
| 0.56 m | 0.056 m | **0.332 Hz** (lowest) | 3.5 kg |

**Tuning range 0.332 → 1.046 Hz, a 3.15× sweep.**

## 4. Mass ratio is the unresolved driver

A pendulum TLMD is only effective in a narrow band around `m_absorber / m_structure`.
Outside it the damper is either too light to matter, or so heavy it dominates the
structure. The useful band is typically **1–5%**.

For the configured cell, water mass per cell runs **3.5 → 35 kg**, so roughly 7 → 70 kg
across two cells, against a sail structure of order 20 kg. That is a mass ratio from
~35% to well over 100% — **far outside the 1–5% band where these dampers work.**

This has not been calculated properly and it may well dictate the cell dimensions more
than the frequency match does. Either the cells need to be much smaller, or the sail
needs to be much heavier, or the arrangement needs rethinking. **This is the single
biggest open item in the design** and it is a structural finding, not a tuning one.

## 4b. Sail root flange — the primary load path

The v1 mount-boss geometry (base plate, bolt circle, gusset polygon) that originally sat
on top of the AMU hull, relocated to the sail foot where the load actually is.

**What this joint actually is, honestly:** *not* a tight flange. A tight bolted flange
and a joint that rotates 7° are mutually exclusive — bolts at the original 0.42 m bolt
circle would be dragged ~22 mm sideways by a 6° rotation, which no bolt can follow. So
the three jobs are split:

| Job | Carried by |
|---|---|
| Rotation | The pin, on the bearing race |
| Moment | The gusset cone, bearing against the collar spigot |
| Separation | The bolts, held in tension by preload |

The rocking moment tries to pull the plates apart on one side and press them together on
the other. The bolts live in the separating half. Preloading them means they never
unload to zero, so the plates never lift, fret and mill, and the loose-bolt impact on
the next gust never happens. That is the "tightened" benefit — and it is
**anti-separation, not anti-rotation.** Something has to give, and it is the pin.

Upper-plate holes are clearance holes sized to swallow the full swing:
`FLANGE_CLEAR_R = FLANGE_BOLT_R·sin(ROCK_DEG) + shank/2 + 0.0015`. Bolts sit close to
the axis so that travel stays small.

**Load path, top to bottom:**
```
sail foot → upper plate → bolts in shear → lower plate + gusset cone (rigid)
          → collar spigot → collar → footing → helical pile → frozen soil
```

**Not done:** no bolt sizing, no moment capacity, no pin bearing pressure. `FLANGE_BOLTS`
and `FLANGE_BOLT_D` are placeholders. This is the joint most likely to be under-designed
and it carries the highest load in the structure.

Two errors caught while building it, both worth recording:
- Gussets initially placed in the gap between the plates **and welded to both** would
  have locked the joint solid — the sail could not rock at all. Structurally wrong, not
  merely untidy. They belong under the lower plate, welded to the collar.
- The upper plate rotating on the pin dragged its bolt holes off the bolts, producing a
  non-manifold solid. That is what drove the clearance-hole solution above.

## 5. Two phases, two jobs

- **Ice, frozen from the top** — ballast, thermal buffer, seasonal regulator. As the
  site cools, ice grows downward into the liquid, shortening the column and sweeping
  `f_abs` down. The unit re-tunes itself with the season, unattended.
- **Water, liquid at the bottom** — the spring. `f_abs ∝ √a`.

The ordering matters: ice above water is what makes the seasonal behaviour correct.

## 6. Thermosyphon constraint

Water freezes at 0 °C; Arctic design cold is commonly −50 °C. Saturated NaCl brine
reaches only −21 °C, CaCl₂ about −30 °C, 60% glycol −48 °C. Cells are held at the
freezing point by **passive thermosyphons** — no power, no consumable, and needed
anyway to stop the steel pile conducting heat into the frozen soil.

**Failure is benign:** if a thermosyphon fails and a cell freezes solid, the cell stops
being a spring and the sail rocks unabsorbed. It does not break and does not shed a
part. Set `THERMO_CHARGED = false` to see an uncharged system.

## 7. Known gaps

- 🔴 **Root joint unsized** (§4b). Highest load in the structure, no bolt sizing, no
  moment capacity, no pin bearing pressure calculated.
- 🔴 **Mass ratio outside the usable band** (§4). Computed above, unresolved. May force
  a redesign of cell size or sail mass.
- 🔴 **Weep drain sizing unresolved.** The bore must stay clear of ice bridges. If it
  seals, meltwater traps and refreezes into the cell, moving `f_abs` off target with no
  visible symptom. Needs site water chemistry, impurity loading, freeze rate.
- 🔴 **No dynamic simulation.** The frequencies are the idealised formula — small
  oscillations, deep cell, negligible damping. Real coupled sail + liquid dynamics
  unmodelled. For a pendulum TLMD the coupling behaviour is where the action is.
- 🔴 **Off-tuning loss unknown.** No Cp, no power curve, no loss-vs-misfit curve.
- 🟠 **Cyclic ice-boundary fatigue.** Each freeze/thaw moves the interface. Cell wall
  life at that boundary unassessed.
- 🟠 **Sail structural adequacy.** 4 mm aluminium chosen so added mass is not swamped
  by structure — which also makes it the first thing to check in a wind. No gust speed,
  design load case, or site wind rose. Flutter or snap-through unexamined.
- 🟠 **Icing on the sail.** The design uses ice as an *internal, deliberate* load.
  Accreted ice is entirely different — asymmetric mass, shifted CoM, changed
  aerodynamics — and would corrupt the tuning it depends on. No mitigation modelled.
- 🟡 **Foundation heat conduction.** Steel pile into permafrost. Not assessed.
- 🟡 **Meltwater disposal.** Water draining from cells at −50 °C refreezes on the
  ground. Whether that heaves the footing or builds a harmless collar is unmodelled.
- 🟡 **Maintainability.** Re-tuning means re-freezing, so the cells need serviceable
  access. Unresolved whether this is a serviceable design or a one-shot commission.
- 🟡 **No wind data.** Nothing sized against an actual load.

## 8. Modularity

| Feature | Evidence |
|---|---|
| Parametric | Every dimension named; `ICE_TOP` is the single tuning knob |
| Phase isolation | `SHOW_ICE`, `SHOW_WATER`, `SHOW_THERMO` render independently |
| Section view | `SHOW_CUTAWAY` sections the windward shell so the cells read |
| Operating states | `SHOW_CANT` toggles lean; `THERMO_CHARGED` toggles charged state |
| Legibility | `SHOW_DATUM` gives a plumb reference and ±swing envelope ghosts |
| Per-site tuning | One cell parameter commissions a site |
| Seasonal self-tuning | Ice growth re-tunes without intervention |
| No inter-unit linkage | Nothing shared, so nothing can cascade |
| Flat transport | Sail is a flat panel; footing is a stack of slabs |
| Local ballast | Ice made from site water, never shipped |

## 8b. Making the motion legible — the first dynamic render looked identical to the kinematic one

Worth recording, because the cause was partly physics and partly framing.

| Problem | Cause | Fix |
|---|---|---|
| Swing only ±3°, decaying to ±1.5° | `INIT_THETA` too small, and `T_SIM` long enough that most of the run was dead | `INIT_THETA` 0.055 → 0.120 rad (±6.9°), `T_SIM` 4.2 → 2.2 s (~2 periods) |
| Motion looked like a one-sided wobble, not an oscillation | **Equilibrium was in the wrong place.** `SAIL_CANT` (6°) was being added on top of the dynamic deviation | Removed. The liquid stabilises the sail about **plumb** — that is what `ω_n² = μω_a² − g/L` means — so the equilibrium is vertical, not canted |
| No fixed reference to measure against | A 7° tilt of a 2.55 m sail moves its tip only ~0.31 m | Added a **plumb datum**, drawn *outboard* of the panel because a datum up the middle disappears inside it, plus ghost edges at the ± half-swing envelope |
| Motion invisible in the render | Camera too far; few pixels for a few degrees | Two presets: `--close` (default) and `--wide` |

The equilibrium correction is a physics fix, not a legibility trick — the earlier version
was placing the sail at an angle the liquid was not actually holding it at.

## 8c. Serviceability — the cells were sealed inside the sail

Arctic labour and parts are expensive, so anything that can fail or wear has to come off
without dismantling the structure around it. Reviewing what actually needs servicing:

| Item | Frequency | Access before | Access now |
|---|---|---|---|
| Damper cells (drain/refill to re-tune) | frequent | **cut the sail open** | cassette bolts off, slides out |
| Pivot pin / bearing race | per wear cycle | strip the whole sail | flange unbolts |
| Sail blade | rare | — | 4 bolts, lifts off |
| Pile | never | — | — |

The cells were the failure. Sealed inside the shell with no port and no access, the most
frequent maintenance job on the machine was impossible without destroying the machine.

### The split

```
lower flange plate (fixed to collar)
  -> CELL CASSETTE     4 quick-release bolts, withdraws sideways, holds the two-phase cells
     -> BLADE_GAP      0.035 service clearance + thermal break
        -> SAIL BLADE   4 quick-release bolts, lifts straight off
```

`BLADE_GAP = 0.035` does three jobs at once: the blade lifts without fouling, aluminium
is not bolted directly to aluminium, and there is no rigid conductive path from the
outdoor blade down through the joint.

Quick-release studs are **undone by hand** — knurled collar, draw handles on the cassette.
No tools, which is the entire point at a remote site in gloves at −40 °C.

`BLADE_LIFT` and `CASSETTE_SLIDE` drive an exploded view:

```
openscad -D 'BLADE_LIFT=0.75' -D 'CASSETTE_SLIDE=0.55' amu_wind_sail_v5.scad
```

### Not solved

- **No isolation valve or fill port.** Drain/refill still means opening the cassette. A
  small bore with a cap and a spill tray would let a technician re-tune without withdrawing
  anything.
- **Seal strategy.** The cells hold liquid at −40 °C with a 9% freeze expansion to absorb.
  What the seal is made of, and how it is replaced, is unspecified — and rubber at that
  temperature is a known problem.
- **Torque spec and locking.** Quick-release means easy, which also means it can loosen.
  Nothing prevents vibration backing it off.
- **Spare-part strategy.** A cassette is now a spare part. That is a real cost, and nobody
  has said whether the design intends cassettes to be interchangeable between units.

## 9. Build

```
Preview F5  — fast
Render  F6  — CGAL, ~3.5 s at $fn=56
Export      — STL/3MF/DXF
```

Verified `Simple: yes` (manifold-clean), 5 volumes, 1790 vertices, **zero error AND
zero warning lines** across 21 parameter variations including `SHOW_WATER`, `SHOW_ICE`, `SHOW_THERMO`, `SHOW_CANT`, `SHOW_SOIL`, `CELL_COLS`,
`THERMO_CHARGED`, and `ICE_TOP` variations.

**Bug fixed from v4:** the oscillation indicator used `rotate_extrude` on a circle
centred on the axis. A circle at the origin spans negative X, and OpenSCAD rejects
mixed-sign points for `rotate_extrude`. The error was silent in practice because the
render still reported valid volumes — it was missed by grepping render output for
volume and warning lines only. Both files now use a flat polygon ribbon.

---

*Issue #82 · per concept-10-07-2026-2131.jpg*
*Supersedes v4 (portal-frame pendulum). Recoverable in git: chassis fae41f7, anchor
ring d4c8a9c, grove a17a023, sail v4 0c54d94.*
