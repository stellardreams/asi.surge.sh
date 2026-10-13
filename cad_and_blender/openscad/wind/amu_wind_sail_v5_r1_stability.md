# R1 — seasonal toppling: parametric sweep and lever analysis

Status: study complete — see [#84](https://github.com/stellardreams/asi.surge.sh/issues/84)
Model: `cad_and_blender/openscad/wind/amu_wind_sail_v5.scad` @ `670aefc`
Tooling: OpenSCAD 2021.01, run headless with `RENDER_SCENE=false`; Python 3
Sweep script: `amu_wind_sail_v5_r1_sweep.py` (same directory)

---

## 1. Scope and what this is not

This is a **parametric sweep of an existing idealised equation**. It reuses the model's own
diagnostics and changes nothing about the design. Specifically:

- `ICE_TOP` is a **static input**, not a simulation. Nothing here freezes, thaws, or tracks
  a season. Sweeping it is a what-if over *assumed* winter states.
- The equation is single-coordinate. There is no liquid coordinate, no sloshing, no
  fluid–structure interaction, no aerodynamic feedback, and no generator.
- The 2.0 margin screen is a **screening threshold chosen for this equation**. It is not a
  structural safety factor and not a certification.
- Nothing here establishes physical winter behaviour. It establishes what the *model* does
  as the assumed ice depth moves, and which levers could change the answer.

## 2. Verification

The sweep is computed in Python for density, then verified field-by-field against the
OpenSCAD binary itself. 49 field comparisons across 7 parameter sets, including `L_SAIL`,
`CELL_BAND_H`, and `CELL_COLS` overrides:

```
VERIFICATION: PASS -- model reproduces (49 field comparisons)
```

All numeric quantities agree to ~1e-6, and all 7 fields parse for every case (a field that
fails to parse is reported, not silently skipped). Baseline also reproduces the values
recorded in [#82](https://github.com/stellardreams/asi.surge.sh/issues/82) exactly
(`ICE_TOP=0.10` → margin `5.340`, screen pass; `ICE_TOP=0.35` → margin `1.419`, screen fail;
`ICE_TOP=0.40` → unstable).

> **Parsing trap worth recording.** OpenSCAD's `str()` concatenation emits *every* `echo`
> diagnostic on a single line. A naive `line.split("= ")[-1]` therefore returns the final
> field for every key, silently dropping all numeric comparison and producing a **false
> PASS**. Each field must be matched with an anchored regex. This bit the first verification
> pass here; the committed script does it correctly and exits non-zero on any mismatch.

## 3. The governing relationship

From the model's own functions, the stability margin reduces to:

```
margin = a² · CELL_COLS · 1000 · L_SAIL / (2 · m_structure)
```

where `a` = water column height = `CELL_BAND_H − SAIL_WALL − ICE_TOP`.

**Cell plan area cancels entirely.** So are gravity and cell width/depth individually. Three
levers exist, and only three:

| Lever | Scaling | Direction |
|---|---|---|
| water height `a` | **quadratic** | more ice → margin collapses |
| `L_SAIL` (effective pendulum length) | linear | longer → more margin |
| structure mass | inverse linear | lighter → more margin |

`CELL_COLS` is linear and equivalent to raising `L_SAIL` in effect. `CELL_BAND_H` moves both
`a` and the rib mass, so it is not a clean lever.

## 4. Baseline sweep

| `ICE_TOP` | `a` (m) | `mu` | `mu_crit` | margin | stable | screen 2.0 | `f_sail` Hz | `f_abs` Hz |
|---|---|---|---|---|---|---|---|---|
| 0.05 | 0.566 | 1.102 | 0.172 | 6.425 | yes | yes | 1.0183 | 1.0556 |
| 0.10 | 0.516 | 1.005 | 0.188 | 5.340 | yes | yes | 0.9108 | 1.0079 |
| 0.15 | 0.466 | 0.907 | 0.208 | 4.355 | yes | yes | 0.8009 | 0.9579 |
| 0.20 | 0.416 | 0.810 | 0.233 | 3.471 | yes | yes | 0.6873 | 0.9050 |
| 0.25 | 0.366 | 0.713 | 0.265 | 2.687 | yes | yes | 0.5678 | 0.8489 |
| 0.30 | 0.316 | 0.615 | 0.307 | 2.003 | yes | yes | 0.4378 | 0.7888 |
| 0.35 | 0.266 | 0.518 | 0.365 | 1.419 | yes | **NO** | 0.2830 | 0.7237 |
| 0.40 | 0.216 | 0.421 | 0.449 | 0.936 | **NO** | NO | 0.0000 | 0.6521 |
| 0.45 | 0.166 | 0.323 | 0.585 | 0.553 | NO | NO | 0.0000 | 0.5717 |
| 0.50 | 0.116 | 0.226 | 0.837 | 0.270 | NO | NO | 0.0000 | 0.4779 |
| 0.55 | 0.066 | 0.129 | 1.471 | 0.087 | NO | NO | 0.0000 | 0.3605 |
| 0.60 | 0.016 | 0.031 | 6.068 | 0.005 | NO | NO | 0.0000 | 0.1775 |

**Thresholds**

| Quantity | Value | As fraction of cell |
|---|---|---|
| `ICE_TOP` where margin crosses 2.0 (screen) | **0.3002 m** | 48.7% |
| `ICE_TOP` where the equation stops being stable | **0.3927 m** | 63.8% |
| headroom between screen and toppling | 0.0925 m | 15.0% |

## 5. The frequency finding

This is the part that matters most for R1 and it is worse than the margin alone suggests.

| `ICE_TOP` | fill | margin | `f_sail` | `f_abs` |
|---|---|---|---|---|
| 0.00 | 100% | 7.611 | 1.1241 | 1.1013 |
| 0.10 | 84% | 5.340 | 0.9108 | 1.0079 |
| 0.20 | 68% | 3.471 | 0.6873 | 0.9050 |
| 0.30 | 51% | 2.003 | 0.4378 | 0.7888 |
| 0.40 | 35% | 0.936 | **0.0000** | 0.6521 |

`f_sail` moves as `a²` while `f_abs` moves as `√a`, so the two separate steadily as ice
accumulates. By the screen boundary the device frequency has **more than halved** (0.911 →
0.438 Hz), and at the toppling threshold the model has no positive stiffness at all, so
`f_sail` collapses to zero.

The consequence: **the device is detuned precisely when the wind is worst.** Any margin
improvement that changes `a`, `L_SAIL` or `m_s` changes the frequency relationship too. These
must always be tracked together — margin alone is not a sufficient acceptance metric.

## 6. The decisive result — no geometric fix reaches a defensible budget

To hold the 2.0 screen at a larger ice budget, each lever would need:

| target ice budget | margin today | `L_SAIL` needed | `m_s` needed | `CELL_COLS` needed |
|---|---|---|---|---|
| 0.35 m (57%) | 1.419 | 1.83 m | 46.0 kg | 2.82 |
| 0.40 m (65%) | 0.936 | 2.78 m | 30.3 kg | 4.27 |
| 0.45 m (73%) | 0.553 | **4.70 m** | **17.9 kg** | **7.24** |
| 0.50 m (81%) | 0.270 | 9.63 m | 8.7 kg | 14.82 |

Against the actual machine — a **2.55 m** tall sail, **0.56 m** wide, 4 mm aluminium with a
48.3 kg shell alone:

- `L_SAIL = 4.70 m` exceeds the height of the sail.
- `m_s = 17.9 kg` is below the bare shell mass; unreachable.
- `CELL_COLS = 7.24` across a 0.56 m sail is not buildable.

What the plausible moves actually buy:

| lever | value | ice budget | vs baseline |
|---|---|---|---|
| baseline | — | 0.3002 m | — |
| `L_SAIL` = 1.60 | 1.60 | 0.3314 m | +0.0311 m |
| `L_SAIL` = 1.80 | 1.80 | 0.3476 m | +0.0474 m |
| `L_SAIL` = 2.20 | 2.20 | 0.3733 m | +0.0730 m |
| `SAIL_WALL` = 3 mm | 3 | 0.3382 m | +0.0379 m |
| `SAIL_WALL` = 2 mm | 2 | 0.3823 m | +0.0821 m |
| `CELL_COLS` = 3 | 3 | 0.3582 m | +0.0579 m |
| `CELL_COLS` = 4 | 4 | 0.3927 m | +0.0925 m |

Even the best notional lever (`CELL_COLS=4`) lands at **0.3927 m — exactly the toppling
threshold, i.e. zero screen margin.** Full freeze is 0.616 m.

**Conclusion: no geometry change closes a meaningful part of this gap. R1 must be solved by
holding `ICE_TOP` down — which is a control strategy, not a design change.**

## 7. Classification of the four registered candidate fixes

| candidate | type | finding |
|---|---|---|
| drain / weep drain (R6) | **water-path control only** | Can release displaced/melt water but cannot by itself cap the advancing ice front. Requires separate freeze/thermal validation; this sweep cannot assess it. |
| active re-freeze control | **control on `ICE_TOP`** | Same. No geometric evaluation is possible in this model. |
| cells further below pivot | **proxy only, via `L_SAIL`** | The model has no coordinate for cell vertical position. `L_SAIL` is a proxy that also moves the structure CoM, so it is not a faithful stand-in. Best case +0.047 m at a defensible `L_SAIL`. |
| larger margin at low water | **self-contradictory as written** | Margin falls *quadratically* as fill falls. "More margin at low water" cannot be achieved by filling less; it must be paired with `L_SAIL`, `m_s` or `CELL_COLS`. |

## 8. Consequences for the register

1. **R6 (weep drain) is a water-path dependency for R1.** A working drain may prevent trapped
   meltwater from changing the liquid column, but it cannot by itself cap ice depth. Keep R6
   separate for tracking; R1's ice-depth control must be demonstrated independently, while
   the drain is validated as part of the same winter-state test.
2. **R5 (thermosyphon capacity) is likewise load-bearing.** If the thermosyphon holds the
   cells at freezing point, ice forms only outside the thermosiphoned region. If it fails,
   the cell can freeze toward 0.616 m, where this model has no answer at all.
3. **The "cells below pivot" candidate should be downgraded.** It is the weakest geometric
   lever, and the model cannot represent it faithfully.
4. **R1 and R4 are coupled more tightly than recorded.** The frequency collapse in §5 is an
   R4 finding (no loss curve, no Cp, unverified tuning) that only becomes visible through an
   R1 sweep.

## 8a. Proposed dispositions for #84 open items

> **Authored by Codex (`GPT-6`)**, in commit
> [`80883b8`](https://github.com/stellardreams/asi.surge.sh/commit/80883b8) (`docs: propose R1
> closure criteria #84`). Reviewed by OpenCode — see
> [#84 review](https://github.com/stellardreams/asi.surge.sh/issues/84#issuecomment-6142561084).
> Codex corrected §7 and §8 in the same commit; the weep-drain reclassification is Codex's
> work and overturns a conclusion of the original sweep.

These are engineering dispositions for closing the *analysis* questions. They do not certify
the device or close physical validation gates. No deployment site or climate basis is
available, and this model does not simulate heat transfer or freeze progression.

1. **Control and provisional limit:** do not treat the weep drain as an ice-depth controller.
   It provides a path for displaced/melt water; it cannot prevent the ice front advancing.
   Treat the thermosyphon as the candidate passive thermal control, but do not credit it with
   holding a particular `ICE_TOP` until a heat-balance model and cold-chamber or field test
   show that result under the declared ambient and wind envelope. For the next design
   iteration, use `ICE_TOP ≤ 0.20 m` as a *provisional qualification target*, not an
   operating guarantee or final requirement. The model gives margin 3.471 and
   `f_sail = 0.687 Hz` there, compared with margin 2.003 at 0.30 m and instability at
   0.3927 m. Add independent ice-depth monitoring and a defined safe response if the limit
   is exceeded; if monitoring or a safe response cannot be provided, demonstrate the target
   by passive thermal design alone. R5 thermal capacity is a prerequisite; R6 drain sizing is
   a separate water-path prerequisite, not the primary ice cap.
2. **Climate basis:** leave the final ice budget open until a deployment site is selected.
   For that site, derive the required winter case from joint cold-duration, wind/gust,
   precipitation/freezing-rain, and melt/refreeze exposure, with a stated return period and
   consequence class. Use local authoritative weather/design data and a site survey; do not
   infer an ice depth from air temperature alone. Convert the environmental case into a
   measured or validated maximum `ICE_TOP`. The provisional 0.20 m target is a test point
   pending this work, not evidence that a climate delivers less ice.
3. **Acceptance metric:** require both stability margin and tuning performance at every
   tested ice state. Retain margin ≥ 2.0 as the current model screen, and add a separately
   declared allowed frequency band or minimum useful response based on the intended
   operating purpose and measured response. Report `ICE_TOP`, margin, `f_sail`, and `f_abs`
   together; do not pass a design on margin alone. These equations remain screening metrics
   until validated against coupled dynamics and physical measurements.
4. **Cells below pivot:** downgrade this from a candidate fix to an unverified geometry
   sensitivity. The current model has no cell-height coordinate and `L_SAIL` also changes
   assumed structure center of mass. Do not claim a benefit without a revised center-of-mass
   and coupled model; the current proxy gives only about +0.047 m at `L_SAIL = 1.80 m`.
5. **Low-water claim:** correct the register wording. Lower fill/greater ice depth reduces
   margin quadratically in this model. It is not a stability fix. Any low-water proposal must
   identify an independent change (for example `L_SAIL`, structure mass, or `CELL_COLS`) and
   show both margin and frequency consequences; current plausible geometry changes do not
   establish a defensible full-winter ice budget.
6. **R5/R6 dependency:** update the register to make R5 (thermosyphon heat balance and
   capacity) a direct prerequisite to demonstrating the ice-depth bound, and R6 (weep-drain
   flow, ice bridging, and meltwater escape) a separate prerequisite to maintaining the
   assumed liquid/ice geometry. They are coupled validation work, not interchangeable
   controls. Failure of either must be represented in the winter-state test matrix, including
   detection delay and the chosen safe response.

**Closure evidence needed:** site climate/design basis; thermal model with stated assumptions;
instrumented freeze/thaw test showing maximum ice depth and water escape; and measured
frequency/stability response over the tested envelope. Until these exist, #84 can close its
model-analysis and register-wording items, but the seasonal operating limit remains open.

## 8b. Review of the provisional `0.20 m` target — tolerance it acquires

Added by OpenCode on review. Codex selects `ICE_TOP ≤ 0.20 m` as a provisional qualification
target in §8a item 1 but does not quantify what it buys. It is well chosen, and here is why.

The cap is **not a free number**. Holding margin at exactly 2.0 leaves zero tolerance, so any
excess ice fails:

| cap `ICE_TOP` | margin | tolerance before margin drops below 2.0 |
|---|---|---|
| 0.3002 m | 2.000 | **0 mm** — any excess ice fails |
| 0.2802 m | 2.262 | 19 mm |
| 0.2500 m | 2.687 | 47 mm |
| **0.2000 m** | **3.471** | **~88 mm** |

Near the cap, `d(margin)/d(ice) = 4.0/a`, so margin falls **0.127 per 10 mm** of excess ice at
`a = 0.316 m` — 6.3% of the entire screen margin per centimetre.

**Choosing 0.20 m over 0.30 m buys roughly 88 mm of ice tolerance instead of none.** That is
the strongest argument for the target and should be stated alongside it. It does *not* make
0.20 m achievable — 88 mm is still a demanding target for a passive control at −50 °C — but it
converts an infeasible requirement into a testable one.

Tolerance scales as `1/a`, so a deeper water column buys finer tolerance, but only linearly:

| water column `a` | tolerance (ice costing 10% of margin) |
|---|---|
| 0.316 m (cap at 0.30) | 15.8 mm |
| 0.616 m (current full cell) | 30.8 mm |
| 1.00 m | 50.0 mm |

Scaling the cell therefore trades against the problem rather than solving it.

## 8c. Review — the design-cold temperature may be the root constraint

Neither the sweep nor Codex's dispositions address this, and it may bound R1 more tightly
than any control choice.

A thermosyphon bounds ice only by holding the brine at its freezing point; ice forms in the
temperature deficit *below* that point. Against the −50 °C design cold asserted in §6:

| working fluid | freezing point | deficit below −50 °C |
|---|---|---|
| saturated NaCl brine | −21 °C | 29 °C |
| CaCl₂ | −30 °C | 20 °C |
| 60% glycol | −48 °C | **2 °C** |

The best candidate still leaves a 2 °C gap, and the thermosyphon competes for the same heat
it must also deliver to the pile. **No passive control credibly caps ice at −50 °C with these
fluids.** Two consequences that should be decided before the control question:

1. **Site selection may be the real decision.** A site at −40 °C design cold puts 60% glycol
   ~8 °C inside its limit rather than 2 °C outside it. The envelope, not the cap, may be the
   binding constraint — which argues for choosing the site before choosing the fluid, and
   makes Codex's item 2 (site first) a prerequisite to item 1 (control), not merely adjacent
   to it.
2. **A seasonal-operating envelope is a legitimate answer.** If deep winter cannot be held,
   declaring the machine inoperative below a threshold temperature and operating only in
   shoulder seasons is honest. It directly contradicts the "least stable when the wind is
   worst" premise, so it must be a stated design decision rather than an outcome.

Note the −50 °C figure is asserted in §6 as *"Arctic design cold is commonly −50 °C"* without
a source. If it is an upper bound chosen for conservatism rather than a site requirement, the
whole control question is easier than it looks.

## 9. Robustness note

At full freeze (`ICE_TOP` = cell height) `a = 0` and the model reports `mu_crit = inf` — a
division-by-zero artifact, not a diagnostic. The run still classifies as unstable and fails
the screen, so the direction is right, but `inf` must not be read as a physical result.

```bash
openscad -o /tmp/ff.csg -D 'RENDER_SCENE=false' -D 'ICE_TOP=0.616' amu_wind_sail_v5.scad
# a (water col) = 0 ... mu_crit = inf ... EQUATION STABLE? = false ... SCREEN PASS? = false
```

## 10. Reproduce

```bash
cd cad_and_blender/openscad/wind
python3 amu_wind_sail_v5_r1_sweep.py
```

Verification runs first and must print `VERIFICATION: PASS` before the sweep results are
trustworthy. The script needs `openscad` on `PATH`; it shells out to the binary for the
verification step and exits non-zero on any mismatch.
