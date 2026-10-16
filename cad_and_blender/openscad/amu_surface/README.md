# AMU-Surface Architecture & STRIDER-M Field Transporter

**Directory:** `cad_and_blender/openscad/amu_surface/`  
**Tracked Under:** [#97 (AMU-Surface Architecture, STRIDER-M Transporter Transfer & Autonomous Wind Erection)](https://github.com/stellardreams/asi.surge.sh/issues/97)  
**Parent Issue:** [#81 (CORA-M Arm Rails & Phased Kinematics)](https://github.com/stellardreams/asi.surge.sh/issues/81)  
**Cross-References:** [#82 (Modular Wind)](https://github.com/stellardreams/asi.surge.sh/issues/82), [#85 (Foundation)](https://github.com/stellardreams/asi.surge.sh/issues/85), [#86 (Mast Tilt-Up)](https://github.com/stellardreams/asi.surge.sh/issues/86), [#88 (Sectional Rotor)](https://github.com/stellardreams/asi.surge.sh/issues/88)

---

## 1. Overview & Universal Planetary Scope

While orbital AMU variants are engineered as spinning cylindrical habitats for micro-gravity and Lagrange point operations, **AMU-Surface** is architected for surface gravity environments (Earth/Arctic permafrost, Lunar regolith, and Martian surface):

* **Preserving Soil & Regolith Integrity**: Eliminates heavy cranes, bucket trucks, and human rigging teams in extreme sub-zero / hostile environments.
* **Overhead Ceiling Gantry Rail**: Adapts the interior ceiling-mounted rail layout from the heritage AMU greenhouse concepts ([`amu-orbiting-greenhouses.png`](https://asi.surge.sh/img/portfolio/amu/amu-orbiting-greenhouses.png)) into a surface vault.
* **STRIDER-M Heavy Transporter**: Repurposes the continuous wide-track chassis from the heavy mining equipment concept ([`mining.png`](https://asi.surge.sh/img/portfolio/effort/mining.png)), acting as mechanical "heavy-duty snowshoes" delivering an ultralow mean ground pressure of **$6.92\text{ kPa}$** (far below the $25.0\text{ kPa}$ active layer disturbance limit).
* **Ceiling-to-Rover Arm Transfer Docking**: Allows the 7-DoF CORA-M robotic arm to transition from internal factory ceiling rails down to the STRIDER-M rover deck via an automated cam-latch collar and conductive umbilical power interface.
* **Autonomous Field Erection**: STRIDER-M navigates to the 20 ft ISO wind turbine container footing, extracts 1.71 m sectional blades, mates carbon spar joints with titanium shear pins, torques studs to the 50 kW direct-drive PMSG hub, and rigs winch lines for mast tilt-up.

---

## 2. Repository File Index

| File | Subsystem & Description |
|:---|:---|
| [`amu_surface_habitat.scad`](amu_surface_habitat.scad) | Pressurized surface vault shelter, permafrost thermal-siphon footings, overhead ceiling gantry rail, and high-bay rover deployment portal. |
| [`strider_m_transporter.scad`](strider_m_transporter.scad) | Low-ground-pressure continuous wide-track crawler rover ("snowshoes" / grousers), heated battery reservoir, and CORA-M latch collar dock. |
| [`amu_surface_transfer_docking.scad`](amu_surface_transfer_docking.scad) | Phased kinematics simulation of CORA-M arm transferring from ceiling gantry down to the STRIDER-M rover deck. |
| [`amu_surface_wind_erection.scad`](amu_surface_wind_erection.scad) | Field erection assembly showing STRIDER-M with mounted CORA-M arm assembling sectional rotor blades at the 20 ft ISO turbine container footing. |
| [`amu_surface_audit.py`](amu_surface_audit.py) | Verification suite checking ground pressure ($6.92\text{ kPa} \le 25\text{ kPa}$), shoulder torque ($FS = 1.23 \ge 1.20$), and battery energy margin ($77.5\% \ge 20\%$). |

---

## 3. Physics & Kinematics Proof Points (`amu_surface_audit.py`)

1. **Ground Pressure ($6.92\text{ kPa}$ vs $\le 25\text{ kPa}$ limit, $FS = 3.61$):**
   * Total rover operating mass: $9\text{ }150\text{ kg}$ (chassis, tracks, 120 kWh battery, CORA-M arm, and payload).
   * Total ground contact area: $12.96\text{ m}^2$ ($2 \times 5.4\text{ m} \times 1.2\text{ m}$ continuous tracks).
   * Result: Mean ground pressure is only $6.92\text{ kPa}$—exceeding tundra active layer and lunar regolith trafficability standards with a factor of safety of $3.61$.
2. **CORA-M Blade Handling Envelope ($FS = 1.23 \ge 1.20$):**
   * Evaluated lifting a $44.5\text{ kg}$ sectional composite blade module at $2.40\text{ m}$ reach.
   * Peak combined gravity and inertial dynamic torque: $1\text{ }180.9\text{ N}\cdot\text{m}$.
   * Harmonic Drive actuator rating ($1\text{ }450\text{ N}\cdot\text{m}$) satisfies structural safety with $FS = 1.23$.
3. **Autonomous Power & Energy Margin ($77.5\%$ Remaining):**
   * Complete mission energy demand (transit, blade extraction, joint torquing, anchor driving, winch rigging, and $-60^\circ\text{C}$ thermal heating): $27.03\text{ kWh}$.
   * Remaining battery SoC on 120 kWh reservoir: $77.5\% \gg 20.0\%$ reserve threshold.
