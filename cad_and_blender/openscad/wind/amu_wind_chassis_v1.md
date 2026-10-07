# AMU — Wind Chassis Retrofit (v1)

Issue #82 · chassis-level exploration, modular wind applications
Geometry: `amu_wind_chassis_v1.scad` (same directory)

---

## 1. What this is

A chassis-only variant of the AMU hull that accepts a modular wind turbine mount. It
reuses the canonical AMU's hull form, rivet grid, caliper lanes, and docking features,
and adds one new thing: a bolt-circle mount interface sized for a small turbine.

Non-scope, per #82: no swarm engine, no orbital/ledger layer, no nutrient/logistics
modules. Nothing in `cad_and_blender/openscad/opencode/` was modified.

## 2. Deployment environment

Terrestrial surface deployment: cold, high wind, icing-prone. #5's Mars–Jupiter
corridor framing does **not** apply to this file — off-world use is an open question
for later work, not a design input here.

## 3. Why this file is standalone

The wind chassis does not inherit from `amu_CORA-M-arm-opencode_v1.scad`. Two reasons,
both verified on OpenSCAD 2021.01:

1. **`use <file>` freezes params.** It imports modules, but consumer-side overrides do
   not reach module bodies. A module reading a global resolves that global from its own
   defining file — verified with a test case where `R = 9` still rendered `r1 = 5`.
2. **`include <file>` runs top-level code.** It does allow overrides, but the canonical
   file ends with a bare `variant_dual(...)` render call, so including it bakes an
   entire dual-AMU scene into a chassis-only file.

Consequence: the params listed in §6 are duplicated across the two files by necessity,
and `scripts/check_chassis_param_drift.sh` guards that duplication. Only argument-driven
helpers were worth importing — and because of the coupling risk, even those are
recreated locally. Their canonical form is cited in comments for comparison.

## 4. Files

| File | Purpose |
|---|---|
| `amu_wind_chassis_v1.scad` | The geometry. All #82 CAD lives here. |
| `amu_wind_chassis_v1.md` | This file — constraints, envelope, hardening notes. |
| `scripts/check_chassis_param_drift.sh` | Param drift guard. Run before committing. |

Nothing else in the repo needs editing to change this design.

## 5. Transport envelope

Chassis is **17.92 long × 12.0 diameter** (`MMS_RADIUS = 6.0`).

**Diameter governs, not length.** There is roughly 2 m of longitudinal slack and zero
radial headroom under every candidate limit considered, so the scale factor is always
set by the diameter.

| Candidate limit | Dia bound | Scale | Resulting length |
|---|---|---|---|
| Container internal (assumption) | 2.59 m | 0.216 | 3.87 m |
| Container external | 2.44 m | 0.203 | 3.64 m |
| 108 in max dimension | 2.74 m | 0.229 | 4.10 m |

`SCALE_ENVELOPE` is set to **0.216** and is a *candidate, not a verified figure*. The
governing dimension is settled; the specific number must be read off the governing spec
sheet before this is treated as settled design.

To see the envelope: set `SHOW_SCALE_ENV = true` and preview F5. The green box is the
scaled bounding volume — note it is diameter-limited, so the chassis visibly overhangs
it lengthwise. That overhang is the slack, not an error.

Sub-components must fit individually, not just as an assembly. Currently unverified —
the mount is the tallest protrusion at 0.90 + 0.24 above the hull surface.

## 6. Params that must stay in sync

`MMS_RADIUS`, `MMS_LENGTH`, `WALL_THICK`, `RIVET_SPACING`, `RIVET_R`, `RIVET_H`,
`RIVET_LANE_EXCLUDE`, `RIVET_APAS_EXCLUDE`, `ROOF_HATCH_X`, `APAS_RADIUS`.

```bash
scripts/check_chassis_param_drift.sh    # exit 0 = in sync, 1 = drift
```

These are load-bearing, not cosmetic. Changing `RIVET_SPACING` in one file silently
desynchronises the exclusion arithmetic, which is what keeps rivets out of the caliper
lanes, the APAS ring, and the new mount zone.

Two params are **local to this file** and must not be synced: `RIVET_EMBED` and
`MOUNT_SEAT`. Both exist to fix non-manifold geometry (see §8), not to match the
canonical file.

## 7. Modularity

| Feature | Evidence in the file |
|---|---|
| Parametric assembly/disassembly | Every dimension is a named param; toggles isolate subsystems |
| Subsystem isolation | `SHOW_HULL`, `SHOW_RIVETS`, `SHOW_CALIPER`, `SHOW_MOUNT`, `SHOW_DOCKING` |
| Reversible interface | Bolt circle — mount removes without touching hull geometry |
| No new hull cutouts | Moment path runs into the existing caliper groove, not through the shell |

The mount is the modular payload. Everything else is the fixed platform. Swapping the
mount for another payload means changing `wind_turbine_mount()` and the exclusion radius,
not the hull.

## 8. Two geometry fixes worth knowing about

Both were found by rendering and reading CGAL's output, not by inspection. The canonical
file has neither, and both are cheap to carry over if its renders are ever cleaned up.

- **`RIVET_EMBED = 0.06`** — rivets originally sat exactly on the hull surface with the
  shank growing outward. Where the hull's `$fn=64` and the shank's `$fn=20`
  tessellations disagree, coincident facets make CGAL report non-manifold. Embedding the
  shank 0.06 into the shell makes the union well-defined. Protrusion above the surface is
  unchanged.
- **`MOUNT_SEAT = 0.06`** — same problem on the mount base plate, which would also have
  floated a visible gap above the hull.

With both applied the model reports `Simple: yes`, 7 volumes, ~9800 vertices at `$fn=64`,
46 s render. Before the fixes: `Simple: no`, 35 volumes.

## 9. Environmental hardening notes

High-level, per #82. These are design notes, not analysis.

**Cold.** Composite blades are the known weak point — plastics and Kevlar embrittle
below their glass-transition temperature, which is exactly the failure mode a cold
environment induces. Metals are comparatively tolerant but lose toughness and change
dimensional behaviour; the mount's bolt pattern must tolerate differential contraction
between a cold-seated steel boss and an aluminium hull rather than being preloaded tight.
Any elastomer in the mount should be specified for low-temperature compression set.

**Icing.** Rime accretes on the leading edge and on any horizontal shelf. The mount's base
plate is a horizontal annulus and is therefore an ice-collection surface — consider
draining or shedding it, or a heater path if the design relies on the mount staying
clear. The gusset ring is a trap for ice: it creates an upward-facing ledge at the
boss-to-plate transition. Sharp crests shed better than rounded ones, so the bolt boss
profile should avoid re-entrant corners where ice can bridge.

**Wind loading.** Side load on the mount becomes an overturning moment at the hull.
The caliper groove (X=±6.5, 0.42 deep, 4.9 long) is the stiffest structure on this hull
and the reason no new cutout was needed — moment transfers into the groove and thence to
the bulkheads. Note the asymmetry: the mount sits at `WIND_MOUNT_X = 0.0`, hull centre,
while the caliper lanes sit at ±6.5. The load path is real but long, and a cyclic wind
load will fatigue the groove fillets. That is the joint to watch, and it has not been
calculated.

**UV.** High UV exposure degrades polymers and elastomers. If any composite or gasket
enters the mount interface, specify UV-stable grades — carbon fibre laminates are
dimensionally stable but their resin matrix is not.

## 10. Known gaps

- Transport scale factor unverified against a governing spec sheet (§5)
- No structural or fatigue analysis of the mount-to-groove load path (§9)
- Cold/UV/icing notes are qualitative; no materials specified
- Icing mitigation on the base plate is noted, not modelled

## 11. Build

```
Preview F5  — fast, good for checking the envelope toggle
Render  F6  — CGAL, ~46 s at $fn=64
Export      — STL/3MF/DXF
```

Python is not part of this path. `cad_and_blender/blender_including_blender_python/generate_amu.py`
covers PBR and texturing, which OpenSCAD cannot do, but this deliverable is a chassis
variant — OpenSCAD alone is sufficient. Python becomes relevant only if textured realistic
renders are wanted later.

---

*Issue #82 · Params guarded by `scripts/check_chassis_param_drift.sh`*
