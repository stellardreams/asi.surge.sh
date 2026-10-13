# #83 — seal and fastener engineering notes

Prepared by OpenCode, 2026-10-13. **Proposals, not decisions.** Every material choice below is
sourced; every *dimension* or *torque value* that would need a load case is called out as
missing rather than invented.

Closes the research half of [R17 (seal strategy) and R19 (fasteners)](https://github.com/stellardreams/asi.surge.sh/issues/82#issuecomment-6051591627).

---

## 1. Seal material — R17

### The working fluid decides the material

The cell holds brine **or** 60% glycol depending on R5's outcome. That choice is not
cosmetic — it eliminates some candidates outright:

| material | low-temp limit | glycol | brine | compression set | cost |
|---|---|---|---|---|---|
| **EPDM** | **−45 °C** | ✅ excellent | ✅ good | fair | low |
| FKM (Viton), general | −30 °C | poor | ✅ excellent | ✅ good | ~3.9× NBR |
| FKM low-temp grade (Parker VX065-75) | **−54 °C** | poor | ✅ excellent | ✅ good | high |
| NBR | −35 °C (B1083: −55 °C) | fair | poor | poor | baseline |
| HNBR | −30 °C | fair | good | good | mid |
| FFKM | −40 °C | ✅ | ✅ | ✅ | **~100× FKM** |
| PTFE | broad | ✅ | ✅ | ❌ not elastic | low |

Sources: [Merit Brass](https://www.meritbrass.com/blog/epdm-hnbr-and-fkm-sealing-elements-key-differences-and-applications)
(EPDM −45 °C), [Parker O-Ring Handbook](https://www.parker.com/content/dam/parker/na/united-states/industries/off-road/pdfs-offroad/O-Ring%20Material%20Offering%20Manual.pdf)
(FKM grades VX065-75 at −65 °F/−54 °C, VG286-80 at −50 °F/−45.7 °C; general V0986-50 at −15 °F),
[Marco Rubber FKM vs EPDM](https://www.marcorubber.com/FKM-vs-EPDM/material-type/10v7)
(compression set), [Freudenberg material trends](https://www.fst.com/-/media/files/pr/2015-02/media_days/media%20day%202015_material%20trends_osen_final.pdf)
(EPDM Tg ≈ −51 to −52 °C), [NH O-Ring](https://nh-oring.de/en/o-ring-designations-materials-simply-explained)
(cost ratios, FFKM 329× NBR).

### Recommendation

**EPDM, 70 Shore A** — *if* the fluid is glycol or brine. It is the only common elastomer with a
rated −45 °C limit that suits both candidate fluids, and its glass transition sits near −51 °C,
so it retains flexibility with margin at a −40 °C site.

If the damping fluid is ever an **oil**, EPDM is disqualified (poor mineral-oil resistance) and
the choice becomes a low-temperature FKM grade — which costs more and still needs its compound
rated, not assumed from the family.

### The better answer — don't seal it, weld it

> **Since the cassette is already a replaceable spare part (R20), the cell seam should be welded
> and the seal should be non-serviceable.**

This dissolves the hardest half of R17 rather than answering it. The open question in the
register is *"how a seal gets replaced at −40 °C"* — and the right answer may be **never**: a
leaking cell is a spent cassette, replaced as a unit, which the design already supports.

Welded aluminium also removes every elastomer from the cold list, removes compression set as a
failure mode, and removes a wear item from the service interval.

**Cost:** no field repair of the seam. Acceptable only because the cassette is already a spare.
**This is an architectural recommendation and it needs a decision, not a material spec.**

---

## 2. Fasteners — R19

### The design has two fastener populations with opposite requirements

| | flange bolts | quick-release studs |
|---|---|---|
| load path | yes — R2 says unsized | no — service feature |
| failure mode | joint opens, machine topples | stud works loose, cassette drops |
| must be removable | by tool, in workshop | **by hand, in gloves, at −40 °C** |
| consequence of backing off | structural | loss of the serviceability win |

The register treats these as one problem ("no torque spec, no locking"). They are two, and the
hand-undoable requirement is what makes the high-strength answer unusable.

### Retention method comparison at cold

| method | −40/−50 °C rating | hand-removable cold | torque control | notes |
|---|---|---|---|---|
| **Nyloc insert** | insert is nylon, brittle when cold | ❌ unreliable | ❌ | the standard answer, and the wrong one here |
| **LOCTITE 263** (high strength) | apply −55 °C, **cold-tested to −75 °C** | ❌ **requires heat** | via torque | [Henkel TDS](https://datasheets.tdx.henkel.com/LOCTITE-263-en_GL.pdf) |
| **LOCTITE 243** (medium) | −55 to +150 °C | ✅ hand tools | via torque | 26 N·m M10 breakaway |
| **LOCTITE 246** (high-temp paste) | −54 °C to +232 °C | ✅ hand tools | via torque | [McMaster-Carr](https://www.mcmaster.com/products/high-temperature-threadlockers) |
| **All-metal prevailing torque** | no elastomer, so no cold limit | ✅ | ✅ | MIL-DTL-18240F, NAS3350 |
| Cotter pin + castle nut | temperature-independent | ✅ | ❌ | prevents rotation, not torque loss |

Henkel's stated standard continuous range for anaerobic adhesives is **−55 °C to +150 °C**.

### Recommendation

**Flange bolts (load-critical, R2):** LOCTITE **243** — removable with hand tools, so a joint can
still be inspected and undone without a heat gun at a remote site. Do **not** use 263 here; its
"requires heat to disassemble" property is unusable at −40 °C.

**Quick-release studs (service feature):** **no adhesive.** Either an all-metal prevailing-torque
insert or a positive mechanical retainer. An anaerobic adhesive here would defeat the entire
serviceability premise — the stud could not be undone in gloves in the cold, which is the one
thing the cassette split was built to achieve.

### The torque value cannot be specified yet

R19 is open partly because **R2 is open**: `FLANGE_BOLTS` and `FLANGE_BOLT_D` are placeholders,
so there is no fastener size to write a torque for. And R2 is open because there is no wind data
(R14). The chain is: **wind rose → load path → bolt size → torque spec → locking method.**

Two process requirements that can be stated now:

1. **Torque must be specified with an application temperature.** Thread friction differs sharply
   between room temperature and −40 °C, so a "dry torque" figure applied in the cold does not
   yield the intended preload. State the reference condition explicitly.
2. **Record as-installed preload, not just torque.** Cold assembly makes torque a poor proxy for
   clamp load; a direct-measurement method (or a documented k-factor for the specific fastener)
   is what actually guarantees the joint.

---

## 3. What this does not settle

- **Fill/drain access** (R18) — the highest-value item in #83, still open. The welded-seam
  recommendation above interacts with it directly: a welded cell is *harder* to fill through a
  port, because the port is now the only leak path and needs its own sealing. Worth deciding
  together, not separately.
- **Service interval** — depends on R8 pin wear, and now also on whether the seam is elastomer
  (a wear item with a life) or welded (not).
- **Spare-part strategy** — R20 is a cost decision, not an engineering one.

## 4. Confidence

Material choices are **sourced** and can be relied on as stated. The welded-seam
recommendation is a **design argument** that needs a decision. Torque values are **not
proposed** because the load case they would derive from does not exist yet — inventing one
would be the same class of error as the earlier false-pass bugs.
