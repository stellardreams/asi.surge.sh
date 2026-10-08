# AMU — Arctic Two-Phase Sail Concept (v5)

Issue #82 · vertical sail on stepped base with two-phase cells at the sail foot
Geometry: `amu_wind_sail_v5.scad` (same directory)
Concept: `concept-10-07-2026-2131.jpg`

---

## 1. What this is

A flat vertical sail standing on a stepped footing, rocking about a thrust collar at
its base. At the foot of the sail are sealed cells holding **two phases**: modeled ice
above liquid water. The equations treat the water column as an idealized source of
restoring stiffness; this is a design hypothesis, not a validated model of the liquid.

The OpenSCAD file contains geometry and an illustrative, single-angle equation of
motion. It does not resolve a separate liquid coordinate, liquid sloshing, fluid–structure
interaction, structural flex, or electrical generation. See §7 before interpreting any
animation as evidence of a real operating principle.

**Working target for validation:** this concept is being evaluated as a device that
sustains bounded rocking under steady wind, consistent with the motion-harvesting intent
of the related [AMU Wind Grove concept](amu_wind_grove_v3.md). Whether it self-starts from
rest is a separate test result. This target states what to test; it is not evidence that
the physical sail oscillates or produces power.

## 2. Configuration and model boundary

The concept sketch shows a stepped footing, thrust collar, upright sail, and cells at the
sail foot. This describes the current geometry only; it does not establish that the
arrangement is more effective or physically stable than an alternative.

The model assumes an inverted-pendulum gravity term and a liquid-derived restoring
term in one coordinate. The rendered water surface is held level, but its motion and
forces are not solved. The cells are therefore not represented as a coupled tuned liquid
mass damper (TLMD) in the current equations.

## 3. Idealized equations, not a tuning claim

The source computes idealized liquid-column and sail-frequency estimates:

```
ωₐ² = g·a / (2A)
ωₙ² = μ·ωₐ² − g/L
θ̈ = −ωₙ²·θ − 2ζωₙ·θ̇ + α_wind(t)
```

Here `a` is modeled liquid height, `A` is cell plan area, `μ` is modeled total water mass
divided by modeled structure mass, `L` is an assumed effective length, and `ζ` is an
assumed damping ratio. `α_wind(t)` is a prescribed torque divided by an estimated
inertia. The code has one state coordinate, `θ`; it does not integrate an independent
liquid motion, so `f_abs` is only an idealized diagnostic and is not tuned to a validated
sail frequency.

`ICE_TOP` changes the assumed liquid height and the stability-screen output. It is not a
seasonal controller or evidence of self-tuning. The `μ` value is a parameter in this
approximation, not a conventional tuned-mass-damper sizing rule.

The equation is conditionally stable only when its effective stiffness is positive. The
implementation clamps `ωₙ` to zero when the equation predicts an unstable configuration;
the resulting animation does not simulate physical divergence. Use `is_stable()` and
the stability screen for the model's mathematical classification, not the animation.

## 4. Model values and interpretation

The cell plan area is approximately `0.0631 m²`. The emitted diagnostics report the
modeled liquid height, mass ratio, estimated frequencies, and idealized stability margin
for the current geometry and `ICE_TOP`. These values describe the equations in the file;
they are not measured properties or design allowables. See §7 for the screening table and
validation gate.

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

## 5. Two phases and the unresolved winter state

- **Ice, frozen from the top** — a modeled geometric state. More ice shortens the
  liquid column and lowers its idealised frequency, but also reduces the sail's
  modeled stability margin. This model does not simulate freezing or regulate ice
  growth; seasonal self-tuning is not demonstrated.
- **Water, liquid at the bottom** — the free-surface state used by the idealised
  equations. `ICE_TOP` changes its height, `a`.

Ice above water is the intended arrangement, but the winter operating envelope remains
open until thermal analysis or a physical control demonstrates that ice growth stays
within the stability screen below.

## 6. Thermosyphon constraint

Water freezes at 0 °C; Arctic design cold is commonly −50 °C. Saturated NaCl brine
reaches only −21 °C, CaCl₂ about −30 °C, 60% glycol −48 °C. Cells are held at the
freezing point by **passive thermosyphons** — no power, no consumable, and needed
anyway to stop the steel pile conducting heat into the frozen soil.

**Failure is benign:** if a thermosyphon fails and a cell freezes solid, the cell stops
being a spring and the sail rocks unabsorbed. It does not break and does not shed a
part. Set `THERMO_CHARGED = false` to see an uncharged system.

## 7. Known gaps

- 🔴 **Winter stability envelope.** The idealised model now screens for a stability
  margin of at least 2.0. With the current geometry, that corresponds to
  `ICE_TOP ≤ 0.300 m`. This is a model-screening threshold, not a structural safety
  factor. No thermal model or physical control demonstrates that winter ice growth
  stays within this limit, so the seasonal operating envelope remains unresolved.

The screen is `margin = μ·ωₐ² / (g/L)`. It uses the model's current 64.816 kg structure
mass, 1.30 m effective length, two cells, and 1000 kg/m³ water density. The derived
`ICE_TOP` limit is 0.30022 m. Sample results:

| `ICE_TOP` | Model margin | Stable in equation? | 2.0 screen |
|---:|---:|:---:|:---:|
| 0.10 m | 5.340 | Yes | Pass |
| 0.30 m | 2.003 | Yes | Pass |
| 0.35 m | 1.419 | Yes | Fail |
| 0.40 m | 0.936 | No | Fail |

The reported 2.0 threshold is only a screening choice for this simplified equation; it
does not account for real liquid dynamics, uncertain material properties, wind loads,
or freeze progression.
- 🔴 **Root joint unsized** (§4b). Highest load in the structure, no bolt sizing, no
  moment capacity, no pin bearing pressure calculated.
- 🔴 **Weep drain sizing unresolved.** The bore must stay clear of ice bridges. If it
  seals, meltwater traps and refreezes into the cell, changing the modeled liquid height
  and stability margin without a visible symptom. Needs site water chemistry, impurity
  loading, and freeze-rate analysis.
- 🔴 **Operating principle unproven.** The working test target is bounded rocking under
  steady wind; self-starting from rest will be assessed separately. `dynamic` mode is a
  one-angle free-decay equation;
  `wind` mode adds prescribed drag torque based only on selected wind speed and fixed
  coefficients. The load does not respond to sail motion, and the model has no liquid
  motion, aerodynamic feedback, or generator. Under constant wind, the stable linear
  equation tends toward a static deflection; its transient does not demonstrate
  self-excited flutter or sustained oscillation. A wind-tunnel study observed flutter and
  limit-cycle oscillations for a flat plate in a coupled pitch–plunge setup, but that
  different apparatus does not establish this sail's behavior ([Amandolese et al.](https://doi.org/10.1016/j.jfluidstructs.2013.09.002)).
- 🔴 **No power-conversion model.** There is no generator, load curve, control law, or
  accounting for mechanical and electrical losses. The animation is not a power estimate.
- 🔴 **Validation gate for an oscillating-device claim.** First declare whether the target
  is a passive deflector or a device that must sustain motion. To claim self-excited
  oscillation, validate the actual geometry and pivot in coupled fluid–structure analysis
  or a wind tunnel, with declared wind-speed/Reynolds-number ranges, structural inertia,
  stiffness, friction, and damping. Show a repeatable nonzero limit cycle after the
  initial perturbation under steady flow. If the target is power generation, also measure
  net electrical energy after conversion losses. Until that evidence exists, describe
  this file as an illustrative geometry and prescribed-force animation only.
- 🟠 **Cyclic ice-boundary fatigue.** Each freeze/thaw moves the interface. Cell wall
  life at that boundary unassessed.
- 🟠 **Sail structural adequacy.** 4 mm aluminium chosen so added mass is not swamped
  by structure — which also makes it the first thing to check in a wind. No gust speed,
  design load case, or site wind rose. Flutter or snap-through unexamined by the current
  one-coordinate model.
- 🟠 **Icing on the sail.** The design uses ice as an *internal, deliberate* load.
  Accreted ice is entirely different — asymmetric mass, shifted CoM, changed
  aerodynamics — and would change the physical response. No mitigation modelled.
- 🟡 **Foundation heat conduction.** Steel pile into permafrost. Not assessed.
- 🟡 **Meltwater disposal.** Water draining from cells at −50 °C refreezes on the
  ground. Whether that heaves the footing or builds a harmless collar is unmodelled.
- 🟡 **Maintainability.** Changing the ice/water state requires service access, but the
  maintenance cycle and field procedure have not been established.
- 🟡 **No wind data.** Nothing sized against an actual load.

### Proposed physical test — not performed

This protocol is a screening plan, not a design-load test or safety certification. The
site wind case is still open; choose a controlled test-speed range with the test-facility
operator and do not treat that range as the operating envelope.

1. **Record the test article.** Use the intended sail, pivot, bearing, and liquid/ice
   configuration. Measure or document geometry, mass distribution and inertia, pivot
   stiffness and breakout friction, damping, travel limits, and cell fill state. Record
   airflow uniformity, turbulence, airspeed, and the corresponding Reynolds number.
2. **Measure the wind-off baseline.** Release the sail from the same small positive and
   negative angles. Record angle over time and estimate its free-decay frequency and
   damping. Repeat each release at least three times.
3. **Apply steady wind without gusts.** Increase airspeed in controlled steps within the
   facility's approved limits. At each step, run once from rest and once after equal,
   measured perturbations in both directions. Keep the wind setting constant after each
   start or release.
4. **Measure the response.** Record synchronized airspeed and sail angle; measure pivot
   torque if the rig allows it. Keep the raw time series and video. Stop a run if motion
   grows toward a travel stop, the rig moves, or any component shows distress.
5. **Classify the result before changing the rig.** Record separately whether steady wind
   starts motion from rest and whether motion continues after a perturbation. For a pass
   on sustained oscillation, predeclare the sensor-noise threshold and hold duration; the
   sail must show repeatable, bounded motion above that threshold for at least 30 cycles
   in three runs at the same wind setting, without a decaying amplitude trend. This is a
   proposed concept-screen criterion, not an engineering standard.

If both the rest-start and perturbed runs decay to a static angle, this configuration
does not pass as an oscillating device; describe it as a static deflector or redesign it.
If the perturbed run sustains motion but the rest-start run does not, report a
sustain-only result. Only after the mechanical test passes should a representative
generator load be connected and net electrical energy measured. No power claim follows
from the unloaded motion test.

## 8. Modularity

| Feature | Evidence |
|---|---|
| Parametric | Dimensions are named; `ICE_TOP` selects a modeled ice/water state |
| Phase isolation | `SHOW_ICE`, `SHOW_WATER`, `SHOW_THERMO` render independently |
| Section view | `SHOW_CUTAWAY` sections the windward shell so the cells read |
| Operating states | `SHOW_CANT` toggles lean; `THERMO_CHARGED` toggles charged state |
| Legibility | `SHOW_DATUM` gives a plumb reference and ±swing envelope ghosts |
| Per-site analysis | `ICE_TOP` changes a modeled state; no commissioning or seasonal control is modeled |
| Ice-state parameter | `ICE_TOP` selects a modeled state; it does not regulate seasonal ice growth |
| No inter-unit linkage | Nothing shared, so nothing can cascade |
| Flat transport | Sail is a flat panel; footing is a stack of slabs |
| Local ballast | Ice made from site water, never shipped |

## 8b. Making the motion legible — the first dynamic render looked identical to the kinematic one

Worth recording, because the cause was partly physics and partly framing.

| Problem | Cause | Fix |
|---|---|---|
| Swing only ±3°, decaying to ±1.5° | `INIT_THETA` too small, and `T_SIM` long enough that most of the run was dead | `INIT_THETA` 0.055 → 0.120 rad (±6.9°), `T_SIM` 4.2 → 2.2 s (~2 periods) |
| Motion looked like a one-sided wobble, not an oscillation | `SAIL_CANT` (6°) was being added on top of the dynamic deviation | Removed from dynamic modes. The current equation is centered on plumb by assumption; that is a model setting, not evidence of the physical assembly's equilibrium |
| No fixed reference to measure against | A 7° tilt of a 2.55 m sail moves its tip only ~0.31 m | Added a **plumb datum**, drawn *outboard* of the panel because a datum up the middle disappears inside it, plus ghost edges at the ± half-swing envelope |
| Motion invisible in the render | Camera too far; few pixels for a few degrees | Two presets: `--close` (default) and `--wide` |

The equilibrium correction makes the animation consistent with the equation's assumed
zero-wind equilibrium. The liquid's ability to hold the real sail at plumb remains
unvalidated.

## 8a. Transport envelope

**Restored.** This lived only in the deleted v1 chassis README and was lost when the hull
was removed. Recomputed for the current sail.

| Quantity | Value |
|---|---|
| Assembled height | **2.595 m** (pivot 0.045 + sail 2.55) |
| Footing footprint | 1.060 × 0.827 m |
| Nested panel footprint | 0.610 × 0.290 m |
| Longest single item once serviceable | **1.895 m** (blade alone, cassette removed) |

| Limit | Scale needed | At that scale |
|---|---|---|
| 20ft container internal (2.59 m) | **0.998** | 2.590 m |
| 20ft container external (2.44 m) | 0.940 | 2.440 m |
| 108 in max dimension (2.74 m) | 1.056 | 2.740 m |

**Scale ≈ 1.0. The sail is already container-sized.** Nesting gives roughly 20 panels
across a 20ft container's width at 3 rows deep.

This is a large change from v1, which needed **scale 0.216** because the chassis was
17.92 m long. Going flat moved transport from a 5× reduction problem to essentially none —
and the criterion is met by *geometry*, not by a documented fudge factor.

**One caveat:** 2.595 m against a 2.59 m internal limit is a 5 mm margin, which is inside
build tolerance. Shipping the blade and cassette separately (1.895 m longest item) removes
the question entirely, and the serviceability split already makes that possible.

## 8c. Serviceability — the cells were sealed inside the sail

Arctic labour and parts are expensive, so anything that can fail or wear has to come off
without dismantling the structure around it. Reviewing what actually needs servicing:

| Item | Frequency | Access before | Access now |
|---|---|---|---|
| Two-phase cells (inspection/drain/refill access) | not established | **cut the sail open** | cassette bolts off, slides out |
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

### 🐛 Defect found on review — the cells were rendering in the wrong place

`cell_cassette()` called `translate([0, 0, h]) damper_bay();` while `damper_bay()`
**already** places cells at `+CELL_BAND_H` internally. The double offset put the cells
at **0.624 … 1.24** instead of **0.004 … 0.62** — above the cassette and up *inside the
blade*.

It was invisible in renders because the blade is cut away on the same side, so the cells
were still technically on screen — just in the wrong component. Every assembled view and
every animation since the cassette split showed the cells floating in the blade.

**Caught by intersecting the cassette against the blade and finding 154 facets of overlap
where there should be none.** The test was then validated with a control at
`BLADE_GAP = −0.05`, which correctly reports 152 facets, and at `0.0`, which is empty
because coincident faces are not volumetric overlap. So the test discriminates.

Fixed by removing the redundant translate. Re-verified: intersection empty at
`BLADE_GAP = 0.035`.

Also added `RENDER_SCENE` so the model can be `include`d for single-part inspection
without the full scene contaminating the result, and made `SHOW_CUTAWAY` section the
cassette as well as the blade — the cassette shell was opaque and hid the cells in the
assembled view.

**Lesson worth recording:** a visually plausible render is not a geometrically correct
one. Overlap had to be proven *absent*, not eyeballed.

### Not solved

- **No isolation valve or fill port.** Drain/refill still means opening the cassette. A
  small bore with a cap and a spill tray could improve access without withdrawing the
  cassette; no operating retuning procedure has been demonstrated.
- **Seal strategy.** The cells hold liquid at −40 °C with a 9% freeze expansion to absorb.
  What the seal is made of, and how it is replaced, is unspecified — and rubber at that
  temperature is a known problem.
- **Torque spec and locking.** Quick-release means easy, which also means it can loosen.
  Nothing prevents vibration backing it off.
- **Spare-part strategy.** A cassette is now a spare part. That is a real cost, and nobody
  has said whether the design intends cassettes to be interchangeable between units.

## 8d. Consolidated risk register

The full register — 22 numbered risks across three tiers, plus the four claims that
analysis has since disproved — lives in the #82 issue as a single comment, so it is one
place to look rather than four threads. Summary of the shape:

| Tier | Count | Character |
|---|---|---|
| 🔴 Design-invalidating | 6 | seasonal toppling, unproven operating principle, unsized root joint, no power model, thermosyphon, weep drain |
| 🟠 Fails in service | 7 | stiction, pin wear, no governor, sail adequacy, icing, ice fatigue, frozen cell |
| 🟡 Resolve before structural | 9 | no wind data, pile conduction, meltwater, seals, fill port, fasteners, spares, \`BLADE_GAP\`, group wakes |

Two concept-level items remain open: the winter stability envelope and whether the real
device is meant to deflect passively or sustain oscillation. The current equations settle
neither physical question. Load sizing and cold-weather validation also remain open.

Retired model claims are recorded in the register rather than deleted, so they are not
re-raised as current physics:
- the 1–5% mass-ratio band — wrong rule for an inverted pendulum
- ice as the tuning element — a solid has no free surface, so no stiffness
- the old 2-DOF absorber simulation — not a validated model of this assembly
- seasonal self-tuning — actually seasonal destabilisation

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
