# AMU OpenSCAD — `cad_and_blender/openscad/opencode/`

> **Issue:** [#5 — AMU Architecture: Physical Blueprint](https://github.com/stellardreams/asi.surge.sh/issues/5) (`tbd priority: [TECHNICAL SPEC]`)
> **Game-plan:** [comment `5710486234`](https://github.com/stellardreams/asi.surge.sh/issues/5#issuecomment-5710486234) (TRIALs 1–14, `VERIFIED` flow)

This folder holds the TRL 1 parametric AMU concept models. We have mostly been working with the **CORA file** (actively developed on `main-dev` → `master`).

## Files

| File | Lines | What it is | Use |
|---|---|---|---|
| `amu_CORA-M-arm-opencode_v1.scad` | 690 | **Canonical — CORA-M (Mobile)** — monkey Y (`apas_7dof_arm():165` Y-branch `branch±22°`, 2 Gold hands), dense Via Ferrata rivets (`RIVET_SPACING 1.4`, `a=0:45:315` 42 rivets, only `X=±6.5` lanes clear at `mms_hull_realistic():275`), caliper widened gap `12*s` + groove torus, rail-free `apas_arm_near_hatch():193` `MMS_RADIUS+0.08`, APAS `ROOF_HATCH_X 2.8` (STS-132), `variant_dual()` default. **Main file for issue #5.** | `F5` preview / `F6` render — `variant_dual(roof_open=true)` |
| `amu_heritage_opencode_v1.scad` | 338 | **Heritage — minimal AMU** — renamed 2026-09-18 from `amu_opencode_v1.scad` (15K). No CORA arm, no dense rivets, no monkey Y. Kept for reference; do not edit for new TRIALs. | `F5` minimal AMU or `SHOW_ARM=false` on CORA-M instead |
| `renders/` | — | `F5`/`F6` outputs committed with source — `amu_CORA-M-arm-opencode_v1-rivets*.png`, `...TRIAL07-*.png`, `...monkey-Y-*.png`, `...caliper-demo.png`, `...closedup.png`, `amu_opencode_v1-09-16-2026-2331-est.png` (TRIAL 5) | Review before ticking `VERIFIED` |
| `renders/annotated/` | — | Marked-up markers for game-plan — `trial2-...`, `trial3-...`, `trial4-...`, `trial6-...`, `trial7-before-arm-float.png` | Linked in `5710486234` |

## Quick Start

- **Open:** `amu_CORA-M-arm-opencode_v1.scad` in **OpenSCAD 2021.01** → `F5` (fast, `~0.3s`, `1281` CSG) → `F6` → `Export STL`
- **Variants:** `variant_dual()` (default, 2 AMUs + `spine_double()` E-W rail), `variant_single()`, `variant_quad()`, `variant_extraction()`
- **Tunable:** `MMS_RADIUS 6.0`, `MMS_LENGTH 17.92`, `RIVET_SPACING 1.4`, `RIVET_R 0.18/H 0.34`, `ROOF_HATCH_X 2.8`, `SOLAR_*`, `GH_TIERS 8`
- **Before → After:** `TRIAL07-before.png` (rail `MMS_RADIUS+0.65` float) → `TRIAL07-remove-arm-railing-one/both.png` (rail-free, rivet climber) → `monkey-Y-golden-grip*.png` (Y at elbow)

## Where to Look in Issue #5

- **TRIAL 14 — dense rivets:** 5 images (`rivets01`, `solo-top/side`, `ortho`, `zoom`) — `VERIFIED`
- **TRIAL 7 — arm:** before (2) → after one/both (2) → Monkey Y (2) + Caliper demo + Closeup — rail removed, Y at middle joint
- **Next:** `TRIAL 6` docking-array, `TRIAL 8` locomotion (`CORA_PATH`), `TRIAL 9` structural notes

## Notes

- **Most work is in the CORA file** — heritage is frozen; keep single source of truth to avoid drift (95% overlap, 338 vs 690 lines).
- **Renders are evidence:** per Discussion 80, flip `🧪→✅` only when `F5` TOP+SIDE shows no cylinder in `4.9×1.4` depression at `mms_hull_realistic():364` and `ls -lh`/`file` verify.
- **Branch:** `main-dev` → `master` via `~/.gemini/config/skills/git-branching-workflow/SKILL.md` (fast-forward, `git rev-parse` check, `v1.1.b` at `c229a0c`→`f995848`).

---
> **Signed:** OpenCode, powered by **opencode/muse-spark-1.2-contributor-free** & **@genidma** — September 18, 2026
