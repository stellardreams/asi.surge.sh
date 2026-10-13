# Wind designs — archive v1.0

**Frozen. Superseded. Kept for the record, not for use.**

Archived 2026-10-13, when the project's purpose changed. Everything here descends from the
AMU chassis experiments in [#82](https://github.com/stellardreams/asi.surge.sh/issues/82);
it is filed as **wind** work, not AMU, and the `amu_` prefix has been dropped.

**Do not start new work from anything in this folder.** The current design is
[`../../v2.0/`](../v2.0/).

---

## Why it was archived

Two findings ended the two-phase sail concept.

**1. The sail cannot oscillate.** Aerodynamic damping is 0.014%–0.656% of structural damping
across the whole wind range, because the lift acts 0.065 m from a pivot 1.275 m below it. It
weathervanes and settles. With no sustained motion there is nothing to convert into
electricity. See [`analysis/r3_aero.md`](analysis/r3_aero.md).

**2. The cell cannot survive the site.** At the declared −60 °C, every fluid the design
nominated goes solid — the best of them, 60% glycol, is 12 °C short. The liquid column goes to
zero and the machine topples. See [`../../v2.0/envelope.md`](../../v2.0/envelope.md).

Neither is fixable within this concept. A stabiliser could reintroduce oscillation, but the
cell is dead either way.

---

## What is here

| file | concept | status |
|---|---|---|
| `wind_anchor_v1.scad` | thrust bearing / anchor ring | superseded by grove |
| `wind_grove_v3.scad` | grove frame, 3 iterations in | superseded by sail v4 |
| `wind_sail_v4_portal.scad` | portal-frame pendulum | superseded by sail v5 |
| `wind_sail_v5_arctic.scad` | **Arctic two-phase sail** — the concept these issues tracked | superseded by the purpose decision |
| `wind_sail_v5_arctic_build123d.py` | static geometry port of sail v5 | port of the above |

### Analysis, kept with the concept it analyses

| file | what it established |
|---|---|
| `analysis/r1_stability.md` + `r1_stability_sweep.py` | stability vs ice depth; margin is quadratic in water height; **no geometric lever reaches a defensible ice budget** |
| `analysis/r3_aero.md` + `r3_aero.py` | **the sail cannot oscillate**; Option A re-scoped from "bluff section" to "moment arm" |
| `analysis/blade_gap.py` | `BLADE_GAP` is set by the lean limit, not the thermal break; R21 cannot close before R7 |
| `analysis/seal_fastener.md` | EPDM is the only viable elastomer; but a welded seam may be better; the design has two fastener populations, not one |

All four still run and self-verify. From this directory:

```bash
~/.venvs/cad/bin/python analysis/r1_stability_sweep.py
~/.venvs/cad/bin/python analysis/r3_aero.py
~/.venvs/cad/bin/python analysis/blade_gap.py
```

---

## Worth carrying forward

Not the geometry — the reasoning. Three lessons that still apply to v2.0:

1. **Verify the verifier.** Three separate false passes occurred in this workstream, each
   looking exactly like a correct result. One was a parse bug that silently zeroed a damping
   term and produced a confident "no flutter". Every guard now self-checks and exits non-zero.
2. **A prescribed input cannot validate a feedback mechanism.** The model's wind mode never
   responded to sail motion, so it could not have shown oscillation *or* ruled it out. That is
   why the conclusion needed independent analysis.
3. **A render is not a measurement.** Cells once rendered inside the blade and nobody saw it;
   it took intersecting the parts.

---

## Lineage

The original commit for each concept is recoverable in git history. Pre-archive paths were
`cad_and_blender/openscad/wind/amu_wind_*`; `git log --follow` works on these files.
