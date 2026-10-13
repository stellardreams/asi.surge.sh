# AMU — Arctic Wind Anchor Unit (v1)

Issue #82 · interlocked self-burying foundation for modular wind generation
Geometry: `amu_wind_anchor_v1.scad` (same directory)

---

## 1. What this is

A slender anchored mast that screws itself into frozen ground and interlocks with a
finite number of identical units to form a closed ring. No hull, no spacecraft bus,
no repurposed chassis — a 17.92 × 12.0 orbital hull has no business at an Arctic site.

Supersedes `amu_wind_chassis_v1.scad` (committed at `fae41f7`, then removed). That
file put a small wind mount on top of the full AMU hull; it was the wrong scale for
the problem, and the load-path reasoning that made it interesting — moment transfer
into the caliper groove — evaporated along with the hull.

## 2. Deployment environment

Terrestrial surface deployment: cold, high wind, icing-prone. #5's Mars–Jupiter
corridor framing does not apply. Off-world remains an open question, not a design input.

## 3. Files

| File | Purpose |
|---|---|
| `amu_wind_anchor_v1.scad` | The geometry. All #82 CAD lives here. |
| `amu_wind_anchor_v1.md` | This file. |

This file shares **no params** with the canonical AMU, so no drift guard is needed.
The `scripts/check_chassis_param_drift.sh` that guarded v1 was removed with it —
it guarded a duplication that no longer exists.

## 4. Installation: why a helical pile

The bearing capacity comes from the frozen soil. Every metre you excavate to place a
smooth post disturbs exactly the material you depend on.

A helical pile is screwed in — non-displacing, no spoil, no excavation. It also
develops real torsional resistance, so installation torque is self-verifying: the
pile refuses to advance past its capacity.

`SHOW_SMOOTH_ALT = true` renders the rejected smooth-post-in-drilled-hole
alternative in red, for comparison. It is retained deliberately so the tradeoff stays
visible. It is not the design.

## 5. The cascade problem, and the ring

The concern that drove this design: if one unit in a group tilts over, it shouldn't
disturb the rest. Four properties together handle it.

**Closed ring, not a row.** In a linear row, unit 1 tilting adds to unit 2's moment,
which adds to unit 3's — a racking failure that propagates and accumulates along the
run. A ring has no free end, so there is no racking mechanism. Unit 1's rotation loads
its two neighbours symmetrically and the ring self-equilibrates. Tilt redistributes
instead of cascading. **This is the primary fix.**

**Compression-only couplers.** Neighbours push on each other in compression, like a
masonry arch. The joint geometry is one-way by design: the spigot enters the socket
with no undercut, hook, or shoulder that could carry tension. A pull simply separates
it. Cyclic gusting cannot tear the group apart progressively.

**Pinned, not fixed.** The shear pin takes side load while permitting rotation, so a
tilting neighbour transmits force but not moment. It pushes; it cannot lever.

**Independent piles.** The interlock is above grade only. Nothing ties the buried
sections together, so a settling unit drags nobody's foundation with it — it fails
alone. **This is the most important line in the file.** Tying the buried sections would
convert a local problem into a group-wide one, undoing everything the ring achieved.

## 6. Inward pre-lean

`UNIT_LEAN = 4` degrees tips each unit toward the ring centre. A ring that leans into
itself is self-stabilising the way an arch or a stack of barrels is: overturning
moment is resisted by geometry *before* it is resisted by the foundation. Pile heads
therefore carry less overturning demand, which is what lets them stay shallow enough
not to disturb the frozen ground.

**The tradeoff, stated plainly:** a lean needs a stiff upper structure to develop it,
and that same structure carries the blade loads. So the mast must be stiff enough to
hold 4° of lean under gust loading *and* under rotor thrust. Not analysed here — see
§8.

## 7. Choosing GROUP_COUNT

`GROUP_COUNT = 6`. The tradeoff:

- **More units** → the ring self-equilibrates better, and each unit carries less
  overturning, so piles can be shallower.
- **More units** → larger footprint, more total excavation-adjacent disturbance, and a
  longer ring perimeter for a given inner area, which starts to cost more than the
  structural gain is worth.

Six keeps the footprint compact while capturing most of the benefit. Not optimised.

## 8. Known gaps

- **No structural analysis.** The lean requires the mast to be stiff enough to hold
  4° under wind and rotor thrust simultaneously. Uncalculated.
- **No foundation capacity check.** Helix diameter, plate count, pitch, and embedment
  depth are plausible values, not sized against a bearing-capacity calculation. The
  60° plate stagger cancels torsional reaction in principle; that has not been verified.
- **Wind loading unquantified.** No gust speed, no design load case.
- **Icing not modelled.** Helix plates are horizontal surfaces below grade and will
  collect ice on the exposed shaft above it. The mast's taper and the coupler joint's
  upward-facing ledges are ice traps; the socket bore is a plausible place for ice to
  bridge and jam the joint, which would turn a compression-only joint into a
  pinned-in-place one. That deserves a look before this goes near a real site.
- **GROUP_COUNT not optimised** (§7).
- **Thermal disturbance not assessed.** Screw-in avoids excavation, but a steel pile
  conducts heat from the surface down into frozen soil. Passive refrigeration (a
  thermosyphon or phase-change sleeve) may be needed. Not modelled.

## 9. Modularity

| Feature | Evidence in the file |
|---|---|
| Parametric assembly/disassembly | Every dimension is a named param |
| Subsystem isolation | `GROUP_MODE`, `SHOW_SOIL`, `SHOW_COUPLER_X`, `SHOW_LEAN_VEC`, `SHOW_SMOOTH_ALT` |
| Single-unit vs group | `GROUP_MODE = false` renders one unit for detail inspection |
| Reversible interface | Compression-only joint separates by pulling — no disassembly sequence |
| Repetition | `anchor_unit()` is identical across the ring; no unit is special |

## 10. Build

```
Preview F5  — fast
Render  F6  — CGAL, ~40 s at $fn=64
Export      — STL/3MF/DXF
```

Baseline render: `Simple: yes`, 8 volumes, 6920 vertices, 40 s. Manifold-clean; no
embedded solids or coincident facets, because nothing here is seated on a curved
surface the way the v1 rivets were.

Python is not part of this path. `cad_and_blender/blender_including_blender_python/generate_amu.py`
covers PBR and texturing, which OpenSCAD cannot do, but this deliverable is a
schematic structural model — OpenSCAD alone is sufficient.

---

*Issue #82 · supersedes `amu_wind_chassis_v1.scad`*
