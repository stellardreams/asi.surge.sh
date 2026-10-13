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
| drain / weep drain (R6) | **control on `ICE_TOP`** | Not a geometry parameter. The swept value is the *outcome*, not an input. Cannot be evaluated by this sweep; needs R6 thermal work. |
| active re-freeze control | **control on `ICE_TOP`** | Same. No geometric evaluation is possible in this model. |
| cells further below pivot | **proxy only, via `L_SAIL`** | The model has no coordinate for cell vertical position. `L_SAIL` is a proxy that also moves the structure CoM, so it is not a faithful stand-in. Best case +0.047 m at a defensible `L_SAIL`. |
| larger margin at low water | **self-contradictory as written** | Margin falls *quadratically* as fill falls. "More margin at low water" cannot be achieved by filling less; it must be paired with `L_SAIL`, `m_s` or `CELL_COLS`. |

## 8. Consequences for the register

1. **R6 (weep drain) is on R1's critical path.** The register recommends testing R6 first on
   detection-cost grounds. This sweep adds an independent, quantitative reason: the drain is
   the only candidate fix that acts on the variable that actually governs margin. My earlier
   suggestion to keep R6 and R1 as separate issues still stands for *tracking* purposes — but
   they are not independent engineering problems, and neither can be closed first.
2. **R5 (thermosyphon capacity) is likewise load-bearing.** If the thermosyphon holds the
   cells at freezing point, ice forms only outside the thermosiphoned region. If it fails,
   the cell can freeze toward 0.616 m, where this model has no answer at all.
3. **The "cells below pivot" candidate should be downgraded.** It is the weakest geometric
   lever, and the model cannot represent it faithfully.
4. **R1 and R4 are coupled more tightly than recorded.** The frequency collapse in §5 is an
   R4 finding (no loss curve, no Cp, unverified tuning) that only becomes visible through an
   R1 sweep.

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
