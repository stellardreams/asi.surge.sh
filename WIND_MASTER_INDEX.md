# 👈 Wind master index — everything, in one place

**Start here if you have not read this before.** One file, one page, every open item across
every wind issue — so you never have to hunt through comments or remember how many issues
exist.

Last updated **2026-10-13** · maintained by OpenCode · wind work only

---

## How many issues? Three.

| issue | what it covers | open | closed |
|---|---|---|---|
| **[#82](https://github.com/stellardreams/asi.surge.sh/issues/82)** | Parent. The wind concept, its acceptance criteria, and the engineering evidence. Its body holds no checkboxes — **its tasks live in the [Next steps comment](https://github.com/stellardreams/asi.surge.sh/issues/82#issuecomment-6053782130).** | 7 | 8 |
| **[#83](https://github.com/stellardreams/asi.surge.sh/issues/83)** | Serviceable cassette design closure | 4 | 3 |
| **[#84](https://github.com/stellardreams/asi.surge.sh/issues/84)** | R1 — seasonal toppling / ice stability | 8 | 11 |
| | **total** | **19** | **22** |

Adjacent, not wind: [#5 — AMU Architecture](https://github.com/stellardreams/asi.surge.sh/issues/5) is the
parent architecture issue the wind work retrofits. Everything else in the repo (issues 1–81) is
a different project strand — tokenomics, governance, DNA bank, space ledger. **Nothing outside
these three is touched by the wind work.**

**41 checkboxes total.** Started this session at 35 open; **16 closed with recorded evidence**.

---

## 🎯 Status — both decisions answered, but one reopened

**Decision 2 (site) — ANSWERED.** Operating envelope declared: **−60 °C**, **80–120 km/h**
(22.22–33.33 m/s), frozen ground, deep snow, rugged terrain, permafrost, ice rimming,
thawing and refreezing. Full analysis:
[`amu_wind_sail_v5_envelope.md`](cad_and_blender/openscad/wind/amu_wind_sail_v5_envelope.md).

### 🔴 What −60 °C does: the cell concept is infeasible

| fluid | freezing point | headroom at −60 °C | verdict |
|---|---|---|---|
| saturated NaCl brine | −21 °C | −39 °C | **solid at site** |
| CaCl₂ brine | −30 °C | −30 °C | **solid at site** |
| 60% glycol (best nominated) | −48 °C | **−12 °C** | **solid at site** |

**Every fluid the design nominates freezes solid.** Liquid column → 0, margin → 0, machine
topples. R5 stops being a sizing question and becomes a feasibility one: *there is no passive,
non-flammable working fluid that holds this cell at −60 °C.*

That retires **R1, R4, R5, R6** and the #83 fluid items (fill/drain, seal). The static-deflector
verdict, meanwhile, **holds and strengthens** — damping stays 0.33%–0.49% across 22–33 m/s.

---

### Decision 1 (operating purpose) — ANSWERED as *passive deflector*, but worth one more look

You answered **passive deflector**, and asked for more context. Here is the context, and it
changes the shape of the question rather than just confirming it.

**Codex's framing is right and better than mine:** the fork is *deflector* **or** *electricity*,
decided first. My framing treated it as a single axis.

**If deflector** — the sail works as designed, minus the fluids. Remaining work is structural and
geotechnical. Nothing needs a liquid.

**If electricity** — the pivot is much larger than the sail. Adding a generator to it harvests
nothing, because the sail settles to a static deflection and has no motion to convert. The
vehicle would have to be a conventional small turbine.

**And that path has an unresolved conflict** (new — see
[`amu_wind_sail_v5_power.md`](cad_and_blender/openscad/wind/amu_wind_sail_v5_power.md)):

| rotor diameter | @5 m/s | @6 m/s | @7 m/s |
|---|---|---|---|
| 5 m (flies, goes on ice road) | 0.42 kW | 0.73 kW | 1.16 kW |
| 7 m | 0.83 kW | 1.43 kW | 2.27 kW |
| **24 m — needed for 10 kW** | 10 kW | — | — |
| **172 m — needed for 500 kW** | 500 kW | — | — |

**Modularity and useful output cannot both hold.** A rotor that will actually fly is 3–7 m and
yields sub-kilowatt to about 1 kW. Reaching 10 kW at 5 m/s mean needs a 24 m rotor.

> **This is an envelope problem, not a sail problem and not a turbine problem.** Either the
> target drops to ~1 kW, or the mean wind is far higher than 5–7 m/s, or the transport
> constraint softens. All three cannot hold at once — and it should be settled *before*
> choosing a vehicle, because it decides whether a generator is worth pursuing at all.

### Two gaps in the declared envelope you should know about

1. **No mean wind.** The envelope gives *high* wind. A power estimate is about the *mean*.
   Sizing against 25 m/s instead of 5 m/s overstates output by **128×**.
2. **Cold air is an advantage, and a cost.** At −60 °C the air is **1.35× denser**, so the same
   rotor makes 1.35× the power — partly offsetting icing. But loads rise by the same 1.35×.

Mean-wind figures used above are an explicit **placeholder band**, not measured data and not a
citation. They must be replaced with site-specific data before use.

---

## 👁 One thing only you can do

### Look at the service sequence — #83 item 1

Two renders, committed at [`997bcac`](https://github.com/stellardreams/asi.surge.sh/commit/997bcac):

- [assembled](https://github.com/stellardreams/asi.surge.sh/blob/master/cad_and_blender/openscad/wind/renders/tally_joint_assembled.png)
- [exploded](https://github.com/stellardreams/asi.surge.sh/blob/master/cad_and_blender/openscad/wind/renders/tally_joint_exploded.png)

Check: **①** darker grey cassette at the foot with a visible gap, lighter blade above ·
**②** sequence reads *blade lifts → cassette slides out → studs exposed → cells accessible*, with
cells **in the cassette, not up inside the blade** · **③** is the gap readable or does the
cassette vanish into the flange? · **④** does serviceability help or clutter?

> ⚠️ A render is necessary but **not sufficient** — the register records cells that rendered
> inside the blade and nobody caught it by looking. It took *intersecting* the parts.

---

## ✅ Every remaining checkbox, all 19

### Blocked on **Decision 1** (operating purpose)

| # | item |
|---|---|
| #82 | Prove the physical operating principle and choose the motion concept |
| #82 | Set design wind cases and size the load path |
| #82 | Specify deployment and protection hardware |
| #82 | Validate cold-weather operation |
| #84 | 🔒 Blocked — declare the operating purpose |
| #84 | Decide whether margin alone is an acceptable acceptance metric |

### Blocked on **Decision 2** (site)

| # | item |
|---|---|
| #84 | Establish the design-cold envelope before the control decision |
| #84 | Define the required ice budget from a climate basis |
| #84 | Decide the control that bounds `ICE_TOP`, and the tolerance it must hold |

### Blocked on **Decision 3** (lean limit)

| # | item |
|---|---|
| #83 | Choose `BLADE_GAP` deliberately and record the reasoning |

### Your judgement — no dependency

| # | item | note |
|---|---|---|
| #83 | Visual review of assembled, exploded and close views | the renders above |
| #83 | Define fill/drain access | highest-value item here; interacts with the seal choice |
| #83 | Decide the spare-part strategy | cost decision; changes the seal answer |
| #83 | Set the service interval | depends on pin wear (R8) and seal type |
| #84 | Accept or reject the provisional `0.20 m` target | buys ~88 mm of tolerance vs 0 mm |
| #84 | Decide whether 2.0 is the right stability screen | chosen for an idealised equation, no safety factor behind it |
| #84 | Decide whether a seasonal operating envelope is acceptable | honest, but contradicts the design premise |
| #82 | Decide whether to publish a new release | **after** `main-dev` merges |

### Mine to do once you're unblocked

| # | item |
|---|---|
| #84 | Make the cap observable in the field |
| #82 | Finish the cassette design *(#83)* and the ice-stability work *(#84)* — both already split out |

---

## ⚙️ Automated checks — green, you do not need to run these

```bash
cd cad_and_blender/openscad/wind
~/.venvs/cad/bin/python amu_wind_sail_v5_r1_sweep.py      # stability sweep, self-verifying
~/.venvs/cad/bin/python amu_wind_sail_v5_r3_aero.py      # will it oscillate?
~/.venvs/cad/bin/python amu_wind_sail_v5_blade_gap.py    # what does the gap clear?
```

Each exits non-zero if its own guard fails, so they are safe to wire into CI. Last run: all
three clean. Full readings in §Part A of [`TEST_TALLY.md`](TEST_TALLY.md).

---

## 📦 State

| | |
|---|---|
| `master` | `2afe749` |
| `main-dev` | `11cc59e`, CI green |
| **Awaiting your test → merge** | **11 commits** |

Merge is deliberately gated on your review (branching workflow Step 7).

---

> 🤖 **Maintained by:** OpenCode, powered by **opencode/space-bunny-free**
> 📅 **Last updated:** October 13, 2026 — 7:45 AM Eastern (ET) / 11:45 UTC
