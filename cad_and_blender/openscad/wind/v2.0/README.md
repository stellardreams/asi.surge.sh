# Wind v2.0 — current design

Containerised Arctic wind turbine, **25–100 kW**, shipped as a 20 ft sea container and
erected without heavy lift.

Supersedes [`../archive/v1.0/`](../archive/v1.0/) — the two-phase sail concept, archived
2026-10-13 because it cannot oscillate and its cell cannot survive −60 °C.

Tracked in [#82](https://github.com/stellardreams/asi.surge.sh/issues/82).

---

## Declared requirements

| | |
|---|---|
| Purpose | generate electricity, **25–100 kW** |
| Transport | 20 ft sea container — max 108″ W × 268″ L × 96″ H, max 24 000 lb (10 886 kg) |
| Erection | **no heavy lift equipment** |
| Extreme cold | **−60 °C** |
| High wind | **80–120 km/h** (22.22–33.33 m/s) |
| Ground | frozen, deep snow, rugged terrain, permafrost |
| Icing | [rime icing](https://en.wikipedia.org/wiki/Hard_rime) on the rotor |
| Cycling | thawing and refreezing |


---

## What the analysis already settles

### ✅ The container is comfortable, not binding

A 23–78 m rotor all ship inside the box once sectioned into 1.7–1.9 m pieces. A 30–45 m blade
is only 16–24 sections. Mass has a real reference point: the US Army Sandia deployable-turbine
guide (SAND2021-14581) describes a ~100 kW, 24 m-rotor system at **8 849 kg (19 509 lb)** —
comfortably inside the 10 886 kg payload.

> **Mass and transport are met by existing technology.** Run [`container_sizing.py`](container_sizing.py).

### ✅ Cold air is an advantage *and* a cost

At −60 °C the air is **1.35× denser** than at 15 °C, so the same rotor makes 1.35× the power —
partly offsetting icing. But loads rise by the same 1.35×. Run [`envelope.py`](envelope.py).

### ✅ Deflector versus power is settled — it is power

---

## The two things that actually block this

### 🔴 1. Mean wind — and there is none yet

**The envelope gives *high* wind. A power estimate is about the *mean*.** Sizing against 25 m/s
instead of a 5 m/s mean overstates output by **128×**.

| mean wind | rotor for 25 kW | rotor for 100 kW |
|---|---|---|
| 5 m/s | 38.5 m | 77.0 m |
| 6 m/s | 29.3 m | 58.6 m |
| 7 m/s | 23.2 m | 46.5 m |

The cube law dominates. A 5 m/s site needs a **3× larger rotor** than a 7 m/s one for identical
output. **This is the first thing to obtain.** Everything downstream is arithmetic.

### 🔴 2. Icing — the largest technical risk

Independent of the container and independent of vehicle choice. At −60 °C supercooled droplets
freeze on leading edges:

- asymmetric accretion shifts the CoM and unbalances the rotor — a fatigue problem in cycles
- it changes the airfoil, so it changes both the power curve and the loads
- shedding is violent and stochastic
- de-icing by heating needs the power being generated

No free answer: hydrophobic coatings, passive shedding, tolerant design, or active heating.
Each trades against something.

---

## What I still need from the decision-maker

1. **Site mean wind and speed distribution.** The single largest unknown.
2. **The rest of the requirements** — there is more on the source page than I have been able to
   load, and I would rather ask than guess at a requirement.
3. **Is the container transport-only, or also the machine's housing?**
   - transport only → mast, hub 30–50 m, real wind resource
   - also housing → rotor on the roof, hub ~3–5 m, only a small rotor works

---

## Files

| file | purpose |
|---|---|
| [`envelope.py`](envelope.py) / [`.md`](envelope.md) | site envelope; why the v1.0 cell is infeasible; cold-density effect |
| [`power_resource.py`](power_resource.py) | wind resource screen; rotor sizing for 25–100 kW |
| [`container_sizing.py`](container_sizing.py) | container envelope → section and mass budget; what it does and does not decide |
| [`foundation_load_envelope.py`](foundation_load_envelope.py) / [`foundation.md`](foundation.md) | Package 1: foundation load envelope, overturning safety, permafrost anchors (#85) |
| [`wind_v2_foundation.scad`](wind_v2_foundation.scad) | Package 1: 3D CAD foundation assembly (container, cribbing, anchors, trunnion) |
| [`erection_kinematics.py`](erection_kinematics.py) / [`mast_erection.md`](mast_erection.md) | Package 2: tilt-up kinematics, winch line tension, gin-pole buckling (#86) |
| [`wind_v2_mast_erection.scad`](wind_v2_mast_erection.scad) | Package 2: 3D CAD modular mast, gin-pole A-frame, and tilt-up stages |
| [`powertrain_envelope.py`](powertrain_envelope.py) / [`powertrain.md`](powertrain.md) | Package 3: Arctic direct-drive PMSG sizing, thermal self-heating, bearing grease (#87) |
| [`wind_v2_nacelle.scad`](wind_v2_nacelle.scad) | Package 3: 3D CAD nacelle bedplate, PMSG generator, yaw drive, fail-safe brake |

All self-check and exit `0`.

## Program tracking structure
 
Wind v2.0 is tracked under parent **[#82](https://github.com/stellardreams/asi.surge.sh/issues/82)**, sequenced from the ground up across four dedicated child issues:
 
- **[#85 — Package 1: Foundation & Arctic Ground Interface](https://github.com/stellardreams/asi.surge.sh/issues/85):** Container reaction footing/ballasting, permafrost ground anchoring (no wet concrete), thermal isolation pad, and ISO corner-casting hinge interfaces.
- **[#86 — Package 2: Mast Structure & Tilt-Up Erection Kinematics](https://github.com/stellardreams/asi.surge.sh/issues/86):** Modular sectional tower (transportable in 20 ft ISO box), gin-pole (A-frame) rigging, winch trajectory (zero heavy lift), and guy-wire load paths under 120 km/h winds.
- **[#87 — Package 3: Arctic Direct-Drive Powertrain (−60 °C) & Nacelle](https://github.com/stellardreams/asi.surge.sh/issues/87):** Direct-drive PMSG (no freeze-prone gearbox lubricants), low-temperature bearing selection, fail-safe aerodynamic braking, and thermal containment.
- **[#88 — Package 4: Sectional Rotor, Anti-Icing & Microgrid System Packaging](https://github.com/stellardreams/asi.surge.sh/issues/88):** 50 kW sectional composite rotor blades, quick-connect spar joints, leading-edge anti-icing to counter [rime icing](https://en.wikipedia.org/wiki/Hard_rime), low-EMI microgrid converter, and total 20 ft container stowage layout.

### Arctic Powertrain Engineering Decisions (−60 °C)

1. **Direct-Drive Permanent Magnet Synchronous Generator (PMSG):**
   - Eliminates the mechanical gearbox completely. At −60 °C, traditional gear oils and synthetic gear lubes (even ISO VG 320 low-temp blends) freeze or channel, resulting in catastrophic gear tooth stripping and bearing seizure.
   - Low-speed multi-pole outer/inner rotor topology directly coupled to the rotor hub.
2. **Low-Temperature Bearings & Synthetic Grease:**
   - Sealed hybrid ceramic / vacuum-degassed chrome steel bearings packed with low-temperature synthetic ester/PFPE greases rated for continuous operation at **−65 °C to +120 °C** (e.g. AeroShell Grease 33 / Mobilith SHC 007).
3. **Thermal Containment & Fine Snow Ingress Sealing:**
   - Double-lip labyrinth seals and heated air purge prevent fine Arctic windblown powder snow from entering stator air gaps.
   - Internal copper losses ($I^2 R$) act as an operational self-heating source, maintaining nacelle internals above −20 °C during rotation without requiring massive auxiliary heating.
4. **Fail-Safe Mechanical Braking:**
   - Spring-applied, electrically released caliper disc brakes — completely eliminating freeze-prone hydraulic fluid lines.

---

> 🤖 **Maintained by:** OpenCode, powered by **opencode/space-bunny-free**
> 📅 **Started:** October 13, 2026
