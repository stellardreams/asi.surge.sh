# AMU — Arctic Ice-Tuned Sail Unit (v4)

Issue #82 · flat wind sail on a portal frame, ice-frozen ballast, water-column tuning
Geometry: `amu_wind_sail_v4.scad` (same directory)

---

## 1. What this is

A flat sail hanging from a portal frame, that moves with the wind. It is hollow, lined
with a cell lattice, and packed with ice — but the ice is not the tuning element, and
getting that wrong is the whole story in §3.

Cells hold **two phases**. Ice is frozen in from the top and serves as ballast, thermal
buffer, and seasonal regulator. Water stays liquid below it and serves as the spring.
The water column height is the tuning knob.

Nothing links units to each other. There is no ring, no interlock, no coupler.

## 2. Deployment environment

Terrestrial surface deployment: cold, high wind, icing-prone. #5's Mars–Jupiter
corridor framing does not apply.

## 3. The correction that changed the design

The first draft of this file claimed the **ice itself** was the tuning element: ice
below the pivot acting as ballast, natural frequency `fn ∝ √(g/d)`, freeze more ice to
raise the site frequency.

That was wrong, and the arithmetic is unambiguous:

```
Pendulum, ice as ballast:   fn = (1/2π)·√(g/d)
  CoM 1.172 m → 1.229 m :   fn 0.460 → 0.450 Hz   =  −2.3% swing
```

Two percent is not a tuning range. You can pack 800 kg of ice into that panel and
barely move the frequency, because `√(1/d)` is a weak lever. Re-proportioning so ice is
78% of total mass does not rescue it — the insensitivity is in the law, not the mass
ratio.

There was a second, compounding bug: the cell lattice was rendered as **solid blocks**,
silently adding ~2,200 kg. The panel was ~4,500 kg of steel. Ice was never going to
tune that, and the ribs are now drawn as wall-volume only.

**The insight that fixed it:** a solid block has no free surface, so it contributes
mass and no stiffness at all. Ice can never be a spring. *The tuning element has to be
able to move.*

## 4. What actually works — the liquid column

A partially filled cell is a tuned liquid mass damper. The free surface is a spring:
stiffness `k = ρ·g·b·a²/2` while the oscillating mass is `m = ρ·A·b·a`. The `a²`
against `a` leaves:

```
Liquid column:   fn = (1/2π)·√(g·a / (2A))
```

`fn ∝ √a` — **~170× more sensitive than the pendulum.**

Cell geometry as built: 469 × 268 × 896 mm, plan area `A = 0.1257 m²`.

| `ICE_TOP` (frozen depth) | water column `a` | `fn` |
|---|---|---|
| 0.10 m | 0.796 m | 0.887 Hz |
| 0.20 m | 0.696 m | 0.829 Hz |
| **0.34 m** (default) | **0.556 m** | **0.741 Hz** |
| 0.50 m | 0.396 m | 0.626 Hz |
| 0.65 m | 0.246 m | 0.493 Hz |
| 0.80 m | 0.096 m | 0.308 Hz |

**Full tuning range: 0.308 → 0.887 Hz, a 2.88× swing.**

More ice → shorter column → *lower* frequency. Tune up by raising the water column, or
by shrinking cell plan area (`fn ∝ 1/√A`). "Freeze it to tune it" is literally the
commissioning procedure.

**Do not fill a cell solid.** With no liquid column the cell is a lump, not a spring,
and the sail stops oscillating entirely. That is the tuning knob's one failure mode and
it is a quiet one.

## 5. Two phases, two jobs

**Ice, frozen from the top** — permanent ballast, thermal buffer, and seasonal
regulator. As a site cools, ice grows downward into the water and shortens the column,
lowering the frequency. The unit **re-tunes itself with the season, unattended.**

**Water, liquid at the bottom** — the spring. `fn ∝ √a`.

The ordering matters: ice above water is what makes the seasonal behaviour correct.

## 6. The constraint this creates, and the failure mode

Water freezes at 0 °C. Arctic design cold is commonly −50 °C. Brine will not cover it:
saturated NaCl is −21 °C, CaCl₂ about −30 °C, 60% ethylene glycol −48 °C. A plain liquid
column is not survivable at this site.

**Solution: passive thermosyphons** hold the cells at the freezing point. They need no
power, no consumable, and no moving parts — and they are needed *anyway* to stop the
steel pile conducting surface heat down into the frozen soil that carries the load. One
component, two problems.

**Failure mode, and it is a good one.** If a thermosyphon fails and a cell freezes
solid, the cell stops being a spring and the sail stops oscillating. It does not break
and it does not shed a part — it stops producing. A tuning element that fails by becoming
harmless is the best available outcome, and it follows directly from making the spring
out of a phase boundary rather than out of steel.

## 7. Known gaps

- **No dynamic simulation.** The `√(g·a/2A)` figures are the idealised TLMD formula —
  small oscillations, deep cell, negligible damping. Real coupled dynamics of sail +
  water column + ice boundary need modelling before any of these frequencies mean
  anything.
- **Damping not considered.** A tuned liquid damper that is not tuned is just a sloppy
  damper. Off-tuning costs power, and the loss curve is unknown.
- **Thermosyphon sizing is nominal.** `THERMO_CLOSED = 0.42` and stem length 1.30 m are
  placeholder values. Heat load depends on cell surface area and site thermal gradient,
  neither of which is known.
- **Weep drain sizing unresolved.** The bore must be wide enough that ice cannot bridge
  and seal the drain shut. That depends on water chemistry, impurity loading, and freeze
  rate. A jammed drain traps meltwater that refreezes into the cell, defeating the
  tuning. **This is a slow, quiet failure and the one I would most want to see tested.**
- **Expansion is now unproblematic by design.** Ice grows into a cell that is already
  full of water, displacing it rather than fighting a sealed cavity — but the *weep
  drain* must pass that displaced water, which is the same problem as above.
- **No aerodynamic work.** No Cp, no power curve, no sail section geometry study. The
  upper section is a flat box, which is not an optimised lifting surface.
- **No wind data.** No gust speed, no design load case, no site wind rose. Nothing here
  is sized against an actual load.
- **Sail thickness chosen so tuning is possible at all.** 4 mm aluminium, ~195 kg
  structure. The moment that made the panel light enough for ice to matter also makes it
  the first thing to check in a wind. No structural analysis of the sail.
- **Cyclic ice growth.** Each freeze/thaw cycle moves the ice boundary. Fatigue of the
  cell walls at that boundary is unassessed.

## 8. Modularity

| Feature | Evidence in the file |
|---|---|
| Parametric | Every dimension is a named param; `ICE_TOP` is the single tuning knob |
| Phase isolation | `SHOW_ICE`, `SHOW_WATER`, `SHOW_THERMO` render independently |
| Operating states | `SHOW_SWING` toggles canted vs vertical hang |
| Per-site tuning | One cell parameter commissions the whole site |
| Seasonal self-tuning | Ice growth re-tunes without intervention |
| No inter-unit linkage | Nothing shared, so nothing can cascade |
| Flat transport | Sail is a flat panel; nests in a fraction of a container |
| Local ballast | Ice made from site water, never shipped |

## 9. Build

```
Preview F5  — fast
Render  F6  — CGAL, ~12 s at $fn=56
Export      — STL/3MF/DXF
```

Verified `Simple: yes` (manifold-clean) in the default state and across `SHOW_WATER`,
`SHOW_ICE`, `SHOW_THERMO`, `SHOW_SWING`, `SHOW_SOIL`, and `ICE_TOP` at both extremes.

Python is not part of this path.
`cad_and_blender/blender_including_blender_python/generate_amu.py` covers PBR and
texturing, which OpenSCAD cannot do, but this is a schematic structural model —
OpenSCAD alone is sufficient. The mass and frequency arithmetic in §3-§4 was done in
plain Python against the file's parameters, not against the render.

---

*Issue #82 · supersedes the interlocked ring/grove approach*
*Superseded designs, recoverable in git: chassis (fae41f7), anchor ring (d4c8a9c),
grove (a17a023).*
