# Operating envelope — and what survives it

Issue #82 / #84 · declared by @genidma, 2026-10-13 · script `amu_wind_sail_v5_envelope.py`

This answers **Decision 2 (the site)** and tests the **Decision 1 (passive deflector)**
conclusion against the real envelope rather than a generic one.

---

## 1. The declared envelope

| condition | value |
|---|---|
| extreme temperature | **−60 °C** |
| high wind | **80–120 km/h** = 22.22–33.33 m/s |
| ground | frozen, deep snow, rugged terrain, permafrost |
| icing | ice rimming on the rotor/blade |
| cycling | thawing and refreezing |

> Provenance is deliberately not recorded here. Treat these as an internally-held design
> requirement: **keep the source in a private record**, because an unsourced design
> condition is weaker engineering than a cited one, and anyone auditing this later will
> reasonably ask where −60 °C came from.

---

## 2. 🔴 The headline: the two-phase cell does not survive −60 °C

A fluid stays liquid at site only if the ambient is **above** its freezing point. Against
−60 °C:

| fluid | freezing point | headroom | verdict |
|---|---|---|---|
| saturated NaCl brine | −21 °C | −39 °C | **SOLID AT SITE** |
| CaCl₂ brine | −30 °C | −30 °C | **SOLID AT SITE** |
| **60% glycol** (best nominated) | −48 °C | **−12 °C** | **SOLID AT SITE** |
| 60% methanol | −46 °C | −14 °C | solid at site |
| 80% methanol | −62 °C | +2 °C | survives |
| pure ethanol | −114 °C | +54 °C | survives |

**Every fluid the design nominates goes solid at −60 °C.** The best of them is 12 °C short.

The only fluids that survive are high-concentration alcohols, which are **flammable and
toxic** — a poor fit for a forward operating site. They are listed to show the envelope is
not unreachable *in principle*, not as a recommendation.

### Consequence for the stability screen

With no cell holding two phases, the liquid column `a → 0` and the margin → 0:

| `ICE_TOP` (m) | `a` (m) | margin | stable | screen 2.0 |
|---|---|---|---|---|
| 0.00 | 0.616 | 7.611 | yes | pass |
| 0.20 | 0.416 | 3.471 | yes | pass |
| 0.30 | 0.316 | 2.003 | yes | pass |
| 0.40 | 0.216 | 0.936 | **no** | fail |
| 0.616 | 0.000 | **0.000** | **no** | fail |

**There is no ice depth that is both safe and achievable.**

### What this does to R5

R1's provisional `0.20 m` cap assumed a thermosyphon holding the cell near its fluid's
freezing point. **At −60 °C that assumption cannot be met by any nominated fluid**, so the
cap is not a design target — it is unreachable.

> **R5 stops being a sizing question and becomes a feasibility question: there is no
> passive, non-flammable working fluid that holds this cell at −60 °C.**

The thermosyphon has nothing to work with. That retires R5, and with it the ice cap, the
tolerance question, and the cap-observability item.

---

## 3. ✅ But the deflector verdict holds — and it strengthens

The static-deflector conclusion was derived at a generic wind speed. Checked across the
**declared** range:

| V (m/s) | Re | `k_red` | `k_aero` (N·m/rad) | aero damping share |
|---|---|---|---|---|
| 22.22 | 391 037 | 0.0335 | 81.9 | **0.328%** |
| 25.00 | 439 917 | 0.0298 | 103.7 | **0.368%** |
| 33.33 | 586 556 | 0.0223 | 184.3 | **0.488%** |

Aerodynamic damping stays a fraction of a percent of structural across the whole range, and
the quasi-steady moment stays restoring. **The verdict holds at 22–33 m/s and is not
marginal.** It is also now supported by the declared envelope, not only by linear theory.

Note the margin screen is wind-independent: wind enters the model only as prescribed torque,
so it affects loading, not stability.

---

## 4. This is a simplification, not only a loss

A sail that weathervanes and settles needs **no liquid, no thermosyphon, no ice cap, no
fill/drain port and no elastomer seal**.

Everything that disappears:

| retires | because |
|---|---|
| R1 — seasonal toppling | no liquid column to destabilise |
| R5 — thermosyphon capacity | no working fluid |
| R6 — weep drain | no water path to drain |
| R4 — tuning and loss curve | no absorber to tune |
| #83 fill/drain access | no port needed |
| #83 seal material | no fluid to seal |
| #83 service interval (partly) | no fluid to service |
| #84 ice cap, tolerance, observability | nothing to cap |

What remains is **structural and geotechnical**, and none of it needs a fluid:

1. **Sail structural adequacy at 22–33 m/s** — plus storm cases above that. `SAIL_WALL` is
   4 mm, chosen so added mass is not swamped by structure; that makes it the first thing to
   check in a wind.
2. **Ice rimming allowance** — accreted ice is asymmetric mass, shifted CoM and changed
   aerodynamics. Not the internal deliberate load the old design relied on.
3. **Thawing and refreezing** — a foundation on permafrost under a cyclic thermal regime.
4. **Load path sizing** — the root flange is still unsized; this was R2 and it is untouched
   by any of the above.
5. **Ice-rim removal** — a passive deflector needs no rotor to de-ice, but it does need to
   shed accumulated ice or the load case changes.

---

## 5. Designs that follow from the confirmed purpose

The user asked for designs embedded rather than just a verdict. Three coherent directions,
none of which need a fluid.

### Design 1 — passive wind vane *(the direct consequence)*

A free-pivoting sail that aligns with the wind and reports direction.

- **Structure:** rigid sail on a low-friction single bearing, with a hard stop and a
  damping pad. A vane **wants** a stop — it should not be free to oscillate.
- **What it removes:** everything in §4.
- **What it needs:** the bearing's breakaway torque specified (R7, still open), and a
  sensor — a potentiometer or Hall sensor on the pivot.
- **Honest limitation:** it produces **no power**. Its value is as a reference or sensing
  device, or as the alignment element for other equipment.

### Design 2 — passive deflector as a load structure

If the intent was ever to *use* the alignment — to shed load, steer a radiator, orient a
sensor mast, or act as a fixed-angle fairing — that is a structural design, and it does not
need the vane to be free. It can be pinned at an angle.

- **Structure:** fixed angle, no bearing, no breakaway torque question at all.
- **What it needs:** the load case at the chosen angle, and the foundation.
- **This is the cheapest path** and the least likely to have an unstated purpose.

### Design 3 — return to forced oscillation

If self-excitation is still wanted, it now has to be **driven**, since passive cannot work:

- An escapement or motor at −60 °C means a heated, sealed actuator with a service interval —
  exactly what the thermosyphon was meant to avoid. It inverts the "passive, no consumable"
  property the design was built around.
- **Cost estimate is not available** and would be a research question in itself.

---

## 6. Recommendation

**Adopt Design 1 or 2 and close the fluid workstream.**

The confirmation that the device is a static deflector, combined with an envelope that
freezes out every nominated fluid, means the two-phase cell concept is not merely
impractical at this site — it is **infeasible**. Carrying R1/R5/R6 and the #83 fluid items
forward would be maintaining a subsystem that cannot function.

Remaining engineering is structural and geotechnical, and that is tractable.

---

> 🤖 **Prepared by:** OpenCode, powered by **opencode/space-bunny-free**
> 📅 **Date/Time:** October 13, 2026 — 7:45 AM Eastern (ET) / 11:45 UTC
> Reproduce: `python3 amu_wind_sail_v5_envelope.py`
