# Wind v2.0 Package 2: Mast Structure & Tilt-Up Erection Kinematics (#86)

## Overview & Zero-Heavy-Lift Mandate

In remote Arctic operations, mobile hydraulic cranes, boom trucks, and excavators are completely unavailable. Every component of the wind turbine tower must be assembled at ground level and hoisted into vertical operational lock using mechanical advantage.

**Package 2** establishes:
1. **Modular Tower Segmentation:** Sizing a $24\text{ m}$ hub-height mast into 5 modular tubular sections ($4.80\text{ m}$ each), comfortably packing inside the $5.89\text{ m}$ interior of a standard 20 ft ISO container.
2. **Kinematic Gin-Pole (A-Frame) Raising System:** An auxiliary $7.0\text{ m}$ rigid steel A-frame lever arm pinned to the container trunnion that converts horizontal pull from a container-mounted winch into vertical rotational torque on the tower.
3. **Four-Part Snatch Block Reduction:** Sizing the hoist wire rope and electric/manual winch to raise a $3\text{ }930\text{ kg}$ total assembly ($2\text{ }330\text{ kg}$ tower + $1\text{ }600\text{ kg}$ nacelle/rotor head).
4. **Permanent Guy-Wire Stabilization:** Four high-strength wire rope stays at an $18\text{ m}$ radius anchor footprint.

---

## 1. Kinematic Sweep & Winch Load Path

Calculated in [`erection_kinematics.py`](erection_kinematics.py):

| Elevation Angle ($\theta$) | Gravitational Torque ($M_{\text{grav}}$) | Winch Line Tension ($T_{\text{winch}}$) | Gin-Pole Compression ($F_{\text{comp}}$) | Cable Length ($d_{\text{winch}}$) |
|---|---|---|---|---|
| **$0.0^\circ$ (Horizontal)** | **$650.73\text{ kN}\cdot\text{m}$** | **$168.45\text{ kN}$ ($37.9\text{ klbf}$)** | **$322.61\text{ kN}$ ($72.5\text{ klbf}$)** | $8.25\text{ m}$ |
| **$15.0^\circ$** | $628.55\text{ kN}\cdot\text{m}$ | $148.25\text{ kN}$ | $280.94\text{ kN}$ | $7.28\text{ m}$ |
| **$30.0^\circ$** | $563.54\text{ kN}\cdot\text{m}$ | $126.09\text{ kN}$ | $237.20\text{ kN}$ | $6.48\text{ m}$ |
| **$45.0^\circ$ (Mid-Lift)** | $460.13\text{ kN}\cdot\text{m}$ | $103.14\text{ kN}$ | $194.10\text{ kN}$ | $5.88\text{ m}$ |
| **$60.0^\circ$** | $325.36\text{ kN}\cdot\text{m}$ | $81.71\text{ kN}$ | $156.01\text{ kN}$ | $5.51\text{ m}$ |
| **$75.0^\circ$** | $168.42\text{ kN}\cdot\text{m}$ | $68.78\text{ kN}$ | $135.36\text{ kN}$ | $5.39\text{ m}$ |
| **$85.0^\circ$** | $56.71\text{ kN}\cdot\text{m}$ | $105.27\text{ kN}$ | $210.38\text{ kN}$ | $5.44\text{ m}$ |
| **$90.0^\circ$ (Vertical Lock)**| $0.00\text{ kN}\cdot\text{m}$ | $0.00\text{ kN}$ | $0.00\text{ kN}$ | $5.50\text{ m}$ |

### Structural Safety Verifications
1. **Container Packing Length:** $4.80\text{ m} \le 5.89\text{ m}$ container interior (**PASS**).
2. **Running Winch Wire Rope:** With a 4-part snatch block reeving, line tension per part is $42.11\text{ kN}$. On standard $19\text{ mm}$ ($3/4\text{ in}$) EIPS wire rope ($\text{MBL} = 260\text{ kN}$), safety factor is **$FS = 6.17 \ge 3.5$** (**PASS**).
3. **Gin-Pole Euler Column Buckling:** Dual-leg structural steel pipe ($219.1\text{ mm}$ OD $\times 10\text{ mm}$ wall, $L = 7.0\text{ m}$) provides critical buckling capacity $P_{\text{crit}} = 2\text{ }900\text{ kN}$. Against peak compression of $322.61\text{ kN}$, safety factor is **$FS = 8.99 \ge 2.0$** (**PASS**).

---

## 2. Parametric 3D CAD Assembly

Implemented in [`wind_v2_mast_erection.scad`](wind_v2_mast_erection.scad):

- **Variable Inspection:** Accepts parameter `tilt_angle` from `0` to `90` degrees.
- **Section Joints:** Five flanged segments with $\varnothing 660\text{ mm}$ bolt flanges and visual bolt rings.
- **Rigid Gin-Pole A-Frame:** Pinned directly to the container base trunnion at a $90^\circ$ angle relative to the mast.
- **Backstay Cables:** Dual wire ropes running from the gin-pole apex to the mast midpoint ($H = 14\text{ m}$).
- **Guy Wires:** Quad permanent guy wires tying off to ground helical anchors at $18\text{ m}$ radius once upright.

---

## 3. Visual Verification Stages

Three key elevation stages rendered from OpenSCAD:

1. **Stage 1 — Horizontal Assembly ($0^\circ$):**  
   Mast and tophead assembled horizontally atop cribbing along container axis. Gin-pole stands vertical ready for initial pull.
   ![Stage 1 - Horizontal](./wind_v2_mast_0deg.png)

2. **Stage 2 — Mid-Lift Elevation ($45^\circ$):**  
   Winch cable pulls gin-pole apex back towards the winch, rotating the tower upwards through backstays.
   ![Stage 2 - Mid-Lift](./wind_v2_mast_45deg.png)

3. **Stage 3 — Vertical Operational Lock ($90^\circ$):**  
   Tower locked in upright vertical position, guy wires tensioned to ground anchors.
   ![Stage 3 - Upright](./wind_v2_mast_90deg.png)

---

## 4. How to Verify

Run the self-checking kinematics simulation:
```bash
python3 cad_and_blender/openscad/wind/v2.0/erection_kinematics.py
```
Expected output:
```text
VERIFICATION: PASS -- All mast erection kinematic & structural safety checks pass cleanly.
  - Section length: 4.80 m <= 5.89 m container limit
  - Winch wire rope safety factor: 6.17 (>= 3.0 required)
  - Gin-pole dual-leg Euler buckling safety factor: 8.99 (>= 2.0 required)
```

Compile OpenSCAD geometry across elevation angles:
```bash
openscad -o /tmp/wind_v2_mast.csg -D 'tilt_angle=45' cad_and_blender/openscad/wind/v2.0/wind_v2_mast_erection.scad
```
