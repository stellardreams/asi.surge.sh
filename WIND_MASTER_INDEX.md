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

## 🎯 Read this part and nothing else is missed

Three decisions unlock most of the rest. **None need me — they need you.**

### 🔴 Decision 1 — the operating purpose *(#82)*

**Is the device a passive deflector, or must it sustain motion?**

> **My recommendation: passive deflector.** The R3 analysis concludes it will not sustain
> self-excited oscillation in the linear regime — aerodynamic damping is 0.014%–0.656% of
> structural, because the lift acts **0.065 m** from a pivot **1.275 m** below it.
> Full reasoning: [`amu_wind_sail_v5_r3_aero.md`](cad_and_blender/openscad/wind/amu_wind_sail_v5_r3_aero.md)

**If passive deflector** → the thermosyphon, cells and cassette stop being *necessary*. A much
simpler machine; most of the cold-weather risk evaporates. **No energy output.**
**If oscillation** → you are choosing the hard path: a stabiliser or moment-arm change is
needed first, and CFD becomes worth installing.

### 🔴 Decision 2 — the site *(#82)*

**Where?** Or give me your constraints: latitude, coastal vs inland, access.

**This decides whether the thermosyphon works at all.** The design-cold temperature is a site
input, not a constant:

| design cold | 60% glycol (−48 °C) | result |
|---|---|---|
| **−40 °C** | 8 °C **inside** its limit | real headroom, R1 solvable |
| **−50 °C** | 2 °C **outside** | no passive control closes the gap |

Most Canadian Arctic communities are **−40 to −45 °C** per
[NRC Canada's 2½%-basis table](https://nrc-publications.canada.ca/eng/view/object?id=95e63f97-a6a8-40cc-a0ac-8b8c7e4b2f35).
The −50 °C originally in the model was unsourced and is now corrected. **Name a site and I'll
pull its exact figure and derive the ice budget.**

### 🔴 Decision 3 — the lean limit *(#83)*

**How far may the sail lean?** 1° · 2° · 3° · other?

This is the **R7 latch/brake** decision, and it is what actually sets `BLADE_GAP` — not the
thermal break, as originally assumed.

| lean limit | `BLADE_GAP` needed | 35 mm enough? |
|---|---|---|
| 1° | 16.3 mm | yes |
| 2° | 26.0 mm | yes |
| 3° | 35.8 mm | **no** |

The implemented 35 mm implicitly bounds lean at **2.9°** — a number nobody chose.

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
| `main-dev` | `b541f75`, CI green |
| **Awaiting your test → merge** | **9 commits** |

Merge is deliberately gated on your review (branching workflow Step 7).

---

> 🤖 **Maintained by:** OpenCode, powered by **opencode/space-bunny-free**
> 📅 **Last updated:** October 13, 2026 — 7:10 AM Eastern (ET) / 11:10 UTC
