# Wind test tally — consolidated

Everything awaiting @genidma's test, in one place. Maintained by OpenCode.
Updated 2026-10-13.

The wind work is split across **#82** (parent) · **#83** (cassette) · **#84** (R1 stability).
This file is the single place to look for what needs checking. Per-commit "How to Test"
notes exist too; this supersedes them for anything still open.

---

## Status at a glance

| | |
|---|---|
| Branch with new work | `main-dev` |
| `master` | `2afe749` — merged, CI green |
| Awaiting merge to `master` | `d22ad6f`, `3263942`, `b18555f`, `997bcac` |
| CI on `main-dev` | ✅ `Validate AMU Design` green on all four |
| Open checkboxes | #82: 8 · #83: 4 · #84: 10 |

**All automated checks below have already been run and pass.** Your test is parts B and C.

---

## Part A — Automated (already green, re-run any time)

All from `cad_and_blender/openscad/wind/`. Python via `~/.venvs/cad/bin/python`.

### A1 — R1 stability sweep

```bash
~/.venvs/cad/bin/python amu_wind_sail_v5_r1_sweep.py
```

✅ `VERIFICATION: PASS -- model reproduces (49 field comparisons)`, exit `0`, zero `MISMATCH`.

### A2 — R3 aerodynamic study

```bash
~/.venvs/cad/bin/python amu_wind_sail_v5_r3_aero.py
```

✅ Theodorsen self-check passes all four properties first (`C(0)=1`, `Im(C)<0`, `|C|` monotonic,
`|C(1)|` in range), then reports damping share **0.014%–0.656%**.

### A3 — `BLADE_GAP` drivers

```bash
~/.venvs/cad/bin/python amu_wind_sail_v5_blade_gap.py
```

✅ Reports thermal need 2.6 mm, tolerance need 13.0 mm, deflection need 2.32 mm, and the
lean-limit table showing 35 mm fails above ~2.9° of lean.

### A4 — The four #82 baselines still reproduce

```bash
for v in 0.10 0.30 0.35 0.40; do
  openscad -o /tmp/b.csg -D 'RENDER_SCENE=false' -D "ICE_TOP=$v" amu_wind_sail_v5.scad 2>&1 \
    | grep -o "EQUATION STABLE?.*SCREEN PASS?       = [a-z]*"
done
```

✅ `0.10`→margin `5.340` pass · `0.30`→`2.003` pass · `0.35`→`1.419` **fail** · `0.40`→`0.936`
**unstable**.

### A5 — Model renders clean

```bash
openscad -o /tmp/m.csg -D 'RENDER_SCENE=true' amu_wind_sail_v5.scad
```

✅ Zero errors, zero warnings.

---

## Part B — Needs your eyes 👈

### B1 — Cassette service sequence (#83, the open `YOUR TURN` item)

Two renders committed at [`997bcac`](https://github.com/stellardreams/asi.surge.sh/commit/997bcac):

| view | file |
|---|---|
| assembled | [`tally_joint_assembled.png`](https://github.com/stellardreams/asi.surge.sh/blob/master/cad_and_blender/openscad/wind/renders/tally_joint_assembled.png) |
| exploded | [`tally_joint_exploded.png`](https://github.com/stellardreams/asi.surge.sh/blob/master/cad_and_blender/openscad/wind/renders/tally_joint_exploded.png) |

**Check these four things:**

1. **Darker grey cassette** at the sail foot, with a **visible gap**, and a **lighter blade** above it.
2. In the exploded view: **blade lifts → cassette slides out → orange studs exposed → water cells accessible.** The cells should be in the cassette, *not* up inside the blade.
3. Is the gap readable, or does the cassette disappear into the flange?
4. Does the whole service sequence *help*, or does it clutter?

> ⚠️ This is a **render**, not a dimensional check. The register already records a case where
> cells rendered inside the blade and nobody caught it by looking — it took *intersecting* the
> parts. So treat a good-looking render as necessary, not sufficient.

### B2 — The `BLADE_GAP` finding needs a sanity check

The analysis concludes the implemented **35 mm** implicitly bounds the sail's lean at **2.9°**.
That sweep term is computed from `SAIL_W` as the blade underside's outermost offset from the
pivot. **Worth confirming against the assembly drawing** — if the underside's outer point is
nearer the pivot than `SAIL_W`, the required gap is smaller than reported.

---

## Part C — Needs your decision 🔒

Nothing here can be resolved by analysis. Listed by how much is downstream of it.

### C1 — Operating purpose *(the master blocker)*

Declare whether the device is a **passive deflector** or **must sustain motion**. R3's analysis
points at *static deflector*. If so, the thermosyphon, cells, cassette, R1 and R4 all address a
machine that does not need to move. Still undeclared in `VISION_SPEC_2026.md`, `ROADMAP.md` and
`README.md`. Gates roughly 20 checkboxes.

### C2 — Site selection

Pick a station. I pull its exact value from NRC Canada's *winter design temperatures, 2½% basis*
table and derive the climate-based ice budget. Gates R1's whole control question — at −40 °C the
thermosyphon is feasible, at −50 °C it is not.

### C3 — Lean limit, then `BLADE_GAP`

Bounding lean is the R7 latch/brake decision. Set it, and `BLADE_GAP` reads straight off the
table in `amu_wind_sail_v5_blade_gap.py`. **R21 cannot close before R7.**

### C4 — Welded or elastomer seal?

The research recommends **EPDM** for glycol or brine, but suggests the better answer is to
**weld the seam** and treat a leaking cell as a spent cassette. Needs deciding, and it interacts
with fill/drain access.

### C5 — Smaller ones

Accept/reject the provisional `0.20 m` ice target · whether 2.0 is the right stability screen ·
whether a seasonal operating envelope is acceptable · spare-part strategy · whether to publish a
new release.

---

## When you're back

Fastest useful order:

1. **C1 first.** It's one sentence and it determines whether the rest matters.
2. **B1** — look at the two renders.
3. Say go-ahead on the merge and I'll fast-forward `master` to `997bcac` and watch CI.

---

> 🤖 **Maintained by:** OpenCode, powered by **opencode/space-bunny-free**
> 📅 **Last updated:** October 13, 2026 — 6:20 AM Eastern (ET) / 10:20 UTC
