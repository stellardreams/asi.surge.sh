# R3 — can the sail sustain self-excited oscillation?

Status: **desk study complete** — see [#82](https://github.com/stellardreams/asi.surge.sh/issues/82)
*Next steps* item 1
Model source: `wind_sail_v5_arctic.scad` @ `d9d25af`
Script: `amu_wind_sail_v5_r3_aero.py` (same directory)
Tooling: Python 3.13 · numpy 2.5.3 · scipy 1.18.1 · matplotlib 3.11.2

---

## 1. Why this question could not be answered before

The OpenSCAD model's `wind` mode applies a **prescribed** drag torque that does not respond to
sail motion. It has no aerodynamic feedback at all, so it can neither show oscillation nor
rule it out. The `f_sail` it prints is a property of the liquid alone.

This study supplies the missing feedback analytically.

## 2. Geometry — this is where the answer comes from

Read from the `.scad` blade construction `cube([SAIL_W, SAIL_T, bh])` and confirmed by the
`-SAIL_T/2` cutaway, which fixes **Y as the wind direction**:

| Quantity | Value | Source |
|---|---|---|
| aerodynamic **chord** `c` | **0.26 m** | `SAIL_T` — the dimension *along the wind* |
| **span** `b` | 2.55 m | `SAIL_H` |
| panel width | 0.56 m | `SAIL_W` — along the pivot axis |
| aspect ratio `b/c` | **9.8** | slender |
| pivot axis | X, at the base | rotation about X |
| aerodynamic centre | `c/4` = **0.065 m** horizontally from the pivot, **1.275 m** above it | — |

**This is a slender plate, not a broad one.** Aspect ratio 9.8 is the flutter-prone regime.
The intuitive "flat plate is safe" reading does not apply here, which is why R3 could not be
 waved away.

## 3. Model

Strip theory. Each spanwise strip is a 2-D flat-plate section at incidence `α`; all strips
share `α = θ` because the rotation is rigid.

```
L_nc   = π q c α + (π/4) ρ c² α̇            added mass, m_a = πρc²/4
L_circ = π q c C(k) α                      Theodorsen circulatory, k = ωc/2V
M_ac   = −I_a α̈ ,  I_a = πρb⁴ , b = c/2    added inertia about the AC
```

Forces transfer to the base pivot through the chordwise offset `c/4`. The spanwise height
contributes **no** moment to a purely vertical force.

**Circulation function.** `C(k)` uses **Jones' approximation**, `C ≈ 1 − 1.34ik/(1 + 2.43ik)`,
valid across the reduced frequencies this sail actually sees (`k` = 0.017–0.74). It reproduces
`C(0) = 1`, gives `Im(C) < 0` throughout, and `|C| → ~0.5`.

> ⚠️ **A parsing trap worth recording.** The first implementation integrated
> `1 − (k/π)∫₀^π exp(−k cos θ) dθ`, whose imaginary part cancels identically by antisymmetry.
> That returns a purely real `C(k)`, so `G(k) ≡ 0`, and the study **reported zero aerodynamic
> damping** — a false pass. The exact `C(k)` is a Hankel-function ratio (Epps 2018,
> [doi:10.2514/1.J056399](https://doi.org/10.2514/1.J056399)). Any C(k) with `Im(C) < 0` gives
> positive damping, so the *sign* of the result below does not depend on the approximation.

## 4. Results

### 4.1 Quasi-steady aerodynamic moment is RESTORING

The pivot sits **below** the aerodynamic centre — the weathervane case, which is stabilising.

| V (m/s) | Re | `k_aero` (N·m/rad) | share of liquid stiffness |
|---|---|---|---|
| 1 | 17 600 | 0.2 | 0.00% |
| 8 | 140 800 | 10.6 | 0.15% |
| 20 | 351 900 | 66.3 | 0.92% |
| 45 | 791 900 | 335.8 | 4.67% |

Liquid restoring stiffness is **7192 N·m/rad**. Aerodynamic stiffness rises as `V²` but never
reaches 5% of it. **The cells, not the air, set the sail's frequency.**

### 4.2 Aerodynamic damping is negligible against structural damping

| V (m/s) | `k_red` | `c_circ` | `c_aero` total | `c_struct` | aero share |
|---|---|---|---|---|---|
| 1 | 0.744 | 0.0034 | 0.0142 | 100.54 | **0.014%** |
| 8 | 0.093 | 0.1099 | 0.1207 | 100.54 | **0.120%** |
| 20 | 0.037 | 0.2866 | 0.2973 | 100.54 | **0.296%** |
| 45 | 0.016 | 0.6490 | 0.6598 | 100.54 | **0.656%** |

Structural damping exceeds aerodynamic by **152× to 7098×** across the sweep. Total damping
is **positive at every wind speed**. Self-excited oscillation is not possible in this regime.

Sway added inertia is 0.36 kg·m² — 0.16% of the structural 219.6 kg·m². Also negligible.

## 5. The geometric reason — and why it is robust

Damping requires an aerodynamic force acting at a lever arm that produces motion. The lift
acts at the aerodynamic centre, which is only **0.065 m** horizontally from the pivot while
the plate is **1.275 m** tall. **The lift acts almost directly above the pivot**, so it
produces almost no moment about it.

**This argument survives the model's limitations.** It does not depend on Jones'
approximation, and it does not depend on attached flow: even with separation, the centre of
pressure of a flat panel stays near mid-chord, still close to the pivot's vertical line. The
plate is **aerodynamically inert as an energy source.** Wind can push it to a static
deflection and the cells restore it, but nothing pumps energy back in.

## 6. Verdict on R3

> **In the linear attached-flow regime, at every wind speed tested, the sail will not sustain
> self-excited oscillation. It settles to a static deflection.**

That is **Option B** in the risk register: *accept a static deflector*. The register's own
stated cost applies — the liquid tuning, thermosyphon, cells and cassette all become
pointless, because a static deflector needs none of them.

### What this does NOT prove

- **Attached-flow theory only.** Separation, leading-edge vortices and wake lock-in are not
  represented.
- **Real flat plates are known to sustain oscillation.** Onoue & Breuer (JFM, 2018) observe
  self-sustained pitch oscillation of a flat plate above a critical reduced velocity — but
  the outcome is **sensitive to the phase of vortex shedding at which the perturbation is
  applied**, i.e. it is bistable/metastable rather than robust.
- Aspect ratio 9.8 is exactly where that is most likely. **This result says the linear regime
  is stable; it does not say oscillation is impossible.**

Mitigating factor: the sail's Reynolds number is **88 000–790 000**, well above the
`Re ≲ 30 000` band where Theodorsen theory is known to under-predict pitching moment because
of leading-edge vortices. At this sail's Reynolds number Theodorsen is more defensible than
for the thin-plate cases usually cited against it.

## 7. The constructive finding — what geometry *would* inject energy

The analysis identifies precisely what is missing. A force must act at a **large lever arm in
the flow direction**. Today it acts 0.065 m from the pivot. Candidates, in rough order of
intention:

| Change | Mechanism | Risk |
|---|---|---|
| **Horizontal stabiliser near the sail top** | Gives a large-area surface far from the pivot; its unsteady force acts with a ~2.5 m lever arm. This is the standard torsional-flutter geometry. | Adds drag and overturning moment to the footing; interacts with R1's stability budget |
| **Move the pivot above the panel centre of pressure** | Inverts the weathervane into a destabiliser | Directly conflicts with R1 — the liquid restoring term exists to hold an inverted pendulum up |
| **Deliberate bluff section (notch / D-profile)** | Lowers `dCn/dα`, reduces restoring moment | Cost is drag. On this analysis it does **not** help: the problem is the lever arm, not the lift slope |

Note the third row: **"make the sail bluff" (Option A as currently written) addresses the
wrong variable.** The plate is not over-damped because of its section — it is under-driven
because its aerodynamic centre sits almost on top of the pivot. A bluff section without a
long moment arm will not produce self-excited oscillation.

## 8. Recommendation

1. **Record Option B as the analytical outcome** for the current geometry, with §6's limits
   attached. Do not close R3 on it — the large-amplitude and separated regimes are untested.
2. **Re-scope Option A** in the register to "stabiliser or moment-arm change", not "bluff
   section". The present wording points at the wrong mechanism.
3. **This gates the device-goal declaration** (#82 *Next steps* item 1). If the device is a
   static deflector, the thermosyphon, cells, cassette and the entire R1/#83/#84 workstream
   are solving a problem that no longer exists. That decision should be made **before**
   further CAD work, not after.
4. **CFD remains unjustified** for the current geometry — the result is analytic and the
   geometric argument is robust. It becomes justified only if a stabiliser is proposed, to
   size that moment arm.

---

*Desk study. No CFD, no wind tunnel, no physical test. Attached-flow linear theory with
Jones' approximation for `C(k)`.*
