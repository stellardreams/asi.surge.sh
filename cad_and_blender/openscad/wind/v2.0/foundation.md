# Wind v2.0 Package 1: Foundation & Arctic Ground Interface (#85)

## Overview & Design Context

In high-latitude Arctic deployments (down to **−60 °C** and survival winds up to **120 km/h / 33.33 m/s**), foundation engineering is governed by strict geotechnical realities:
1. **Zero Wet Concrete:** Mixing and curing cast-in-place concrete in deep permafrost is logistically infeasible without significant heating and aggregate supply lines.
2. **Permafrost Thermal Stability:** Heat transfer from electrical power converters or living modules into the frozen active layer triggers thermal degradation (thermokarst subsidence and frost heave).
3. **No Heavy Lift:** Excavators, pile drivers, and mobile cranes are unavailable.

To satisfy the design mandate, **Wind v2.0** uses the standard **20 ft ISO container as the primary deadweight reaction platform**, elevated on **thermal break cribbing sleepers** and stabilized with **helical ground screw anchors** and **guy-wire tiebacks**.

---

## 1. Load Path & Overturning Analysis

Calculated in [`foundation_load_envelope.py`](foundation_load_envelope.py):

| Parameter | Value | Design Basis |
|---|---|---|
| **Design Air Density** ($\rho$) | $1.656\text{ kg/m}^3$ | At $-60\text{ }^\circ\text{C}$, air is $1.35\times$ denser than standard $15\text{ }^\circ\text{C}$ air |
| **Survival Wind Speed** ($V_{\text{surv}}$) | $120.0\text{ km/h}$ ($33.33\text{ m/s}$) | Peak gust operating requirement |
| **Dynamic Pressure** ($q_{\text{surv}}$) | $920.0\text{ Pa}$ | $0.5 \cdot \rho \cdot V^2$ |
| **Parked Rotor Drag** | $14.17\text{ kN}$ | 3 blades feathered into storm wind ($C_d \approx 0.55$) |
| **Tower Drag** | $11.04\text{ kN}$ | $24\text{ m}$ tubular/lattice mast ($d = 0.5\text{ m}$) |
| **Total Base Shear** | $25.21\text{ kN}$ | Horizontal force at survival wind |
| **Overturning Moment** | $537.8\text{ kN}\cdot\text{m}$ | About container base pivot edge |
| **Container System Mass** | $10\text{ }200\text{ kg}$ ($22\text{ }487\text{ lb}$) | Tare ($2.2\text{ t}$) + internal equipment ($3.5\text{ t}$) + ballast ($4.5\text{ t}$) |
| **Gravity Restoring Moment** | $121.9\text{ kN}\cdot\text{m}$ | Transverse axis ($W/2 = 1.219\text{ m}$) |
| **Guy Wire Tension** | $42.01\text{ kN}$ ($9\text{ }445\text{ lbf}$) | $18\text{ m}$ anchor radius ($53.1^\circ$ guy angle) |
| **Anchor Pullout Tension** | $33.61\text{ kN}$ ($7\text{ }556\text{ lbf}$) | Vertical reaction on helical ground anchor |
| **Soil Bearing Pressure** | $46.40\text{ kPa}$ | Subgrade contact pressure under cribbing pads |

### Safety Factor Verification
- **Gross Container Weight:** $10\text{ }200\text{ kg} \le 10\text{ }886\text{ kg}$ rating (**PASS**).
- **Guy Wire Rope Safety Factor:** $FS = 4.28 \ge 2.5$ on $16\text{ mm}$ EIPS wire rope (**PASS**).
- **Soil Bearing Capacity:** $46.4\text{ kPa} < 150.0\text{ kPa}$ allowable active thaw soil pressure (**PASS**).
- **Helical Anchor Safety Factor:** $FS = 2.68 \ge 1.5$ against pullout in permafrost (**PASS**).

---

## 2. Foundation Geometry & Components

Implemented in [`wind_v2_foundation.scad`](wind_v2_foundation.scad):

### A. 20 ft ISO Container Platform
- Standard dimensions: $6\text{ }058\text{ mm L} \times 2\text{ }438\text{ mm W} \times 2\text{ }591\text{ mm H}$.
- Structural corner posts ($180\text{ mm}$ tube) and longitudinal side rails ($160\text{ mm}$ structural channel) provide rigid torsional transfer of overturning moments.
- Standard ISO 1161 corner castings at all 8 corners provide standardized locking points.

### B. Thermal Isolation Cribbing Sleepers
- Treated timber / high-density composite sleeper pads ($1\text{ }200\text{ mm} \times 600\text{ mm} \times 200\text{ mm}$) at the container corners.
- Elevates the steel container body $200\text{ mm}$ above the permafrost, allowing cold arctic air to circulate underneath and preventing thermal degradation of frozen ground.

### C. Mechanical Permafrost Helical Anchors
- Double-helix steel screw anchors ($250\text{ mm}$ flight diameter, $45\text{ mm}$ solid square/round shaft, $3.0\text{ m}$ embedment depth).
- Installed diagonally at $45^\circ$ angles into the frozen subgrade using portable hydraulic torque heads (small hand-carried drill rig).
- Provides positive hold-down resisting container tipping and anchor guy line reactions.

### D. Mast Base Hinge Trunnion
- High-strength steel pivot bracket ($800\text{ mm} \times 600\text{ mm} \times 35\text{ mm}$ baseplate) mounted over the container roof structural corner beam.
- Dual $40\text{ mm}$ clevis ears housing a $\varnothing 90\text{ mm}$ alloy pivot pin to support the base of the tilt-up mast during raising and operation.

### E. Integrated Winch Skid
- Base-mounted winch package ($1\text{ }000\text{ mm} \times 800\text{ mm}$) on the container roof for gin-pole tilt-up operations without mobile cranes.

---

## 3. Visual Verification

Renders generated from OpenSCAD:
- **Assembly View:** `renders/wind_v2_foundation_iso.png` (Container, sleeper pads, diagonal helical anchors, winch skid, and trunnion).
- **Detail View:** `renders/wind_v2_trunnion_detail.png` (Mast base trunnion bracket and $\varnothing 90\text{ mm}$ pivot pin).

---

## 4. How to Verify

Run the self-checking analytical script:
```bash
python3 cad_and_blender/openscad/wind/v2.0/foundation_load_envelope.py
```
Expected output:
```text
VERIFICATION: PASS -- All 4 foundation & structural load safety checks pass cleanly.
```

Compile OpenSCAD geometry:
```bash
openscad -o /tmp/wind_v2_foundation.csg cad_and_blender/openscad/wind/v2.0/wind_v2_foundation.scad
```
