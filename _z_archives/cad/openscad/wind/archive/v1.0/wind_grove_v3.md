# AMU — Arctic Wind Grove Unit (v3)

Issue #82 · interlocked bladeless mast cluster with self-erecting raked installation
Geometry: `amu_wind_grove_v3.scad` (same directory)

---

## 1. What this is

Six bladeless oscillating masts, each screwed into frozen ground on its own helical
pile, interlocked in a closed ring by compression-only joints with inline screw jacks.
The ring is erected by installing every unit raked outward and then closing it — the
closing force pulls the whole cluster into compression and makes it self-supporting.

**v2 is kept alongside this, deliberately.** `amu_wind_anchor_v1.scad` is the
conventional-rotor baseline this design is measured against. The progression —
hull chassis → anchored rigid mast → interlocked bladeless grove — is the argument for
why the grove exists. Compare them with `GROUP_MODE` in each file.

## 2. Deployment environment

Terrestrial surface deployment: cold, high wind, icing-prone. #5's Mars–Jupiter
corridor framing does not apply.

## 3. Why bladeless

**The decisive argument is icing.** A conventional turbine's fatigue-critical part is
the blade root cantilever. Rime accumulating on a blade root concentrates load and
changes the section — and then the machine sees cyclic loading at a section it was not
designed for. Rime on a cylindrical shell just adds mass and a surface. For a site
defined by icing, removing the blade-root fatigue class outright is worth more than
any efficiency gain.

**The cost, stated plainly:** a bladeless machine has far less swept area than a bladed
one of equal power. As one wind-energy specialist put it — a conventional turbine gives
you blades, a bladeless one gives you a pole. So matching power output means a
considerably larger machine. The structural win is partly paid back in size and cost.

**The consequence for the joints:** the oscillator *rocks*, by design, perpendicular
to the wind. That is a harmonic input at the mast's own natural frequency — the
classic resonance case — and it means the interlocks receive reversing force rather
than pure compression. See §7.

## 4. The root-graft analogy, and where it was deliberately not followed

You asked about sequoia. There is a directly relevant result.

A 2025 study in *Trees* (Springer), on jack pine root systems and windthrow:

> natural root grafting **decreased the likelihood of uprooting** (p < 0.01) but
> **increased the propensity for stem breakage**

Read carefully: grafting does not eliminate failure, it **relocates** it. A fused
network becomes a load path, so an overloaded member routes force into its neighbours
and something breaks at the joint instead of at the foundation. The share-the-load
benefit is real; the cost is a shared failure mode.

So the design takes the *principle* and rejects the *location*:

- Loads **are** shared between neighbours — above grade, in compression, through
  pinned joints.
- Buried sections stay **independent**. Root-grafting the piles would import exactly
  the failure relocation the study describes.

## 5. The tilt-cascade answer

Your original concern: one unit tilting and disturbing the group. Five properties,
carried forward from v2 and extended here.

| Property | What it prevents |
|---|---|
| **Closed ring, not a row** | No free end → no racking mechanism. Rotation loads both neighbours symmetrically; the ring self-equilibrates. **Primary fix.** |
| **Compression-only couplers** | One-way geometry: spigot enters socket with no undercut or shoulder that could carry tension. Cyclic gusting cannot tear the group apart progressively. |
| **Pinned shear pin** | Transmit side load, permit rotation. A neighbour pushes; it cannot lever. |
| **Independent piles** | Nothing below grade ties together, so a settling unit fails alone. **The most important line in the file.** |
| **Inward lean** | Overturning resisted by geometry before the foundation is asked. |

v3 adds the **rocking bearing**, which is a genuine conflict resolved rather than
avoided: the ring must resist overturning, while the mast base must *not* resist the
rocking motion. The bearing releases that degree of freedom at the base, so both are
true at once. Overturning restraint comes from the ring and the pile, never from
bending the mast.

## 6. Self-erecting installation

This is the part that matters most at a remote Arctic site.

Install each unit raked **outward**, ring open. Walk the ring, close the final joint,
and the closed ring pulls every unit inward into compression. The compression interlock
is created by the act of closing the circle, not by a separate bracing operation.

**No crane, no heavy lifting, no level pad.** Each pile is screwed in tilted; two
people walk a unit into position. A partially closed ring is already stable up to the
point of closure, so erection is staged rather than all-or-nothing.

**Screw jack at every joint.** Ring closure alone makes seating depend on every unit
being *exactly* right — correct rake, correct spacing, correct pile depth. One wrong
unit and the closing force seats some joints while leaving others slack, which is an
intolerant process for a site where you cannot iterate.

The jack fixes that: torque it to spec and that joint is preloaded regardless of its
neighbours. It also gives a place to release a single joint later, so one unit can be
removed without disturbing the rest — v2's "fails alone" property, now serviceable.

The jack pushes. It cannot pull. Same one-way rule as the coupler.

Set `ERECTION_STATE = true` to preview the raked installation condition.

## 7. Known gaps — read these before treating this as design

- **Resonance is the biggest open risk.** The oscillator is excited near its own
  natural frequency, and in a six-unit ring each mast also sits in the wake of its
  upstream neighbour. Vortex-shedding frequency, natural frequency, and neighbour wake
  interaction are three things that could align. **This is the one place where
  interlocking makes things *worse* rather than better**, because a pinned joint that
  only ever received compression now receives reversing force from a rocking neighbour.
  Not analysed.
- **No structural analysis of anything.** No bolt loads, no joint capacity, no pile
  capacity, no mast bending. The screw-jack preload value is not specified.
- **No foundation capacity check.** Helix dimensions carried from v2 as plausible
  values, not sized against a bearing calculation.
- **Wind loading unquantified.** No gust speed, no design load case, no site wind data.
- **Heat conduction down the pile.** Screw-in avoids excavation, but a steel pile
  conducts heat from the surface into frozen soil. A passive refrigeration sleeve may
  be needed. Not modelled.
- **Icing not modelled.** The coupler socket is a sheltered upward-facing cavity. Ice
  bridging inside it would jam the joint — and a jammed joint is a *pinned* joint, the
  one thing the whole design avoids. Now compounded by the jack: a threaded screw in an
  icing environment is a binding risk, and the hex nut is a flat upward face that will
  collect rime. **Worth attention before this goes near a real site.**
- **`GROUP_COUNT = 6` chosen for compact footprint, not optimised.**
- **Efficiency unquantified.** No Cp, no power curve, no comparison against a bladed
  machine of equal output.

## 8. Modularity

| Feature | Evidence in the file |
|---|---|
| Parametric assembly/disassembly | Every dimension is a named param |
| Two assembly states | `ERECTION_STATE` toggles raked vs finished ring |
| Subsystem isolation | `GROUP_MODE`, `SHOW_SOIL`, `OSC_SHOW_SWEEP`, `SHOW_RAKE_ARC`, `SHOW_ERECT_VEC` |
| Single-unit vs group | `GROUP_MODE = false` renders one unit for detail inspection |
| Individually serviceable | Screw jack releases one joint without disturbing the ring |
| Reversible interface | Compression-only joint separates by pulling — no disassembly sequence |
| Repetition | `grove_unit()` identical across the ring; no unit is special |

## 9. Build

```
Preview F5  — fast
Render  F6  — CGAL, ~30 s at $fn=64
Export      — STL/3MF/DXF
```

Verified `Simple: yes` (manifold-clean) at 8 volumes, 4706 vertices, 30 s in the
default finished-ring state, and across `ERECTION_STATE`, `GROUP_MODE`,
`OSC_SHOW_SWEEP`, and `SHOW_SOIL` variations.

Python is not part of this path.
`cad_and_blender/blender_including_blender_python/generate_amu.py` covers PBR and
texturing, which OpenSCAD cannot do, but this deliverable is a schematic structural
model — OpenSCAD alone is sufficient.

---

*Issue #82 · companion to `amu_wind_anchor_v1.scad` (v2)*
*Root-graft finding: Tarroux & DesRochers, "Windthrow mortality influenced by natural
root grafting in boreal jack pine forests," Trees (2025).*
