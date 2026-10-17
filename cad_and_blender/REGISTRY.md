# Hardware Invention & Model Registry

> **Authoritative Specification:** Single source of truth for all mechanical, structural, and robotic hardware inventions across `asi.surge.sh`.
> **Governing Standards:** Tracked under Issue [#101](https://github.com/stellardreams/asi.surge.sh/issues/101). Direct lineage from [#5](https://github.com/stellardreams/asi.surge.sh/issues/5), [#81](https://github.com/stellardreams/asi.surge.sh/issues/81), [#82](https://github.com/stellardreams/asi.surge.sh/issues/82), [#97](https://github.com/stellardreams/asi.surge.sh/issues/97), [#98](https://github.com/stellardreams/asi.surge.sh/issues/98), and [#100](https://github.com/stellardreams/asi.surge.sh/issues/100).
> **Rule of Promotion:** Baseline models (e.g. `v1.0`) are permanently preserved. New geometric modifications or kinematic enhancements must be versioned iteratively as clean variants (`v2.0`, `v3.0`).

---

## 🏗️ Hardware System Taxonomy

The repository's physical systems span five core technology domains across orbital and surface deployments:

```mermaid
graph TD
    A["Hardware Invention Registry"] --> B["1. Orbital Manufacturing (AMU Orbital)"]
    A --> C["2. Heavy Planetary Transporters (STRIDER)"]
    A --> D["3. Articulated Robotic Manipulators (CORA-M)"]
    A --> E["4. Polar Surface Habitats & Facilities (AMU-Surface)"]
    A --> F["5. Modular Containerized Wind Turbines (Wind v2.0)"]
    
    B --> B1["AMU Heritage Orbital v1.0 (Canonical Cylinder Hull, APAS, Solar Wings)"]
    B --> B2["AMU Orbital CORA-M (Mobile 7-DoF Rail Arm, Via Ferrata Rivets)"]
    B --> B3["ZeroClaw Node & Lattice Vocab (Self-Replicating Octahedral Truss)"]
    
    C --> C1["STRIDER-M v1.0 (Baseline Heavy Tundra Grouser Transporter)"]
    C --> C2["STRIDER-M v2.0 (A-Frame Knee Outriggers + Transit Park Cradle)"]
    
    D --> D1["CORA-M Arm v1.0 (7-DoF Articulation + Dual-Grip Golden Calipers)"]
    
    E --> E1["AMU-Surface Solo v1/v2 (Structural Vault Arch + Diagrid Frame)"]
    E --> E2["Gantry Transfer Portal v1.0 (Ceiling-to-Rover Kinematic Dock)"]
    
    F --> F1["Wind v2.0 Containerized System (20 ft ISO, Guyed Mast, 25-100 kW)"]
```

---

## 1. Orbital Autonomous Manufacturing Units (AMU Orbital)

### System Summary
The foundational orbital self-replicating manufacturing spacecraft engineered to bridge the gap from TRL 1 to TRL 9 for in-space manufacturing, orbital hygiene, space debris mitigation, and infrastructure expansion.

| Variant | Authoritative CAD Source | Dimensions / Mass Envelope | Power & Stationkeeping | Key Subsystems & Payloads | Derived Verification Assets |
|:---|:---|:---|:---|:---|:---|
| **AMU Heritage Orbital v1.0** | • OpenSCAD: [`openscad/opencode/amu_heritage_opencode_v1.scad`](./openscad/opencode/amu_heritage_opencode_v1.scad)<br>• FreeCAD: [`freecad/amu_orbital/amu_heritage_orbital_v1.py`](./freecad/amu_orbital/amu_heritage_orbital_v1.py)<br>• STEP: [`freecad/step_exports/amu_heritage_orbital_v1.step`](./freecad/step_exports/amu_heritage_orbital_v1.step) | Length: $17.92\text{ m}$<br>Radius: $6.0\text{ m}$<br>Modular Cylinder Hull | Dual articulating solar wing arrays ($4\times$ tiers), chemical/cold-gas RCS thruster clusters | • Cylindrical pressurized MMS manufacturing core<br>• Standardized APAS-95 and CBM docking collars<br>• Modular payload bays for materials processing | • Color Turntable: [`amu_heritage_orbital_v1_turntable.gif`](./freecad/amu_orbital/renders/amu_heritage_orbital_v1_turntable.gif) / [`.mp4`](./freecad/amu_orbital/renders/amu_heritage_orbital_v1_turntable.mp4)<br>• Heritage Stills: [`amu_opencode_v1-09-16-2026-2331-est.png`](./openscad/opencode/renders/amu_opencode_v1-09-16-2026-2331-est.png)<br>• Heritage spec: Issue [#5](https://github.com/stellardreams/asi.surge.sh/issues/5) |
| **AMU Orbital CORA-M Mobile** | [`openscad/opencode/amu_CORA-M-arm-opencode_v1.scad`](./openscad/opencode/amu_CORA-M-arm-opencode_v1.scad) | Length: $17.92\text{ m}$<br>Hull Radius: $6.0\text{ m}$<br>Rivets: 42 across 8 sectors | Orbital high-voltage bus bar + umbilical slip ring | • **7-DoF CORA-M Robotic Arm**: Rail-mounted carriage along E-W structural spine<br>• **Via Ferrata Rivet Grid**: $1.4\text{ m}$ grid pitch for locomotive end-effector hand-holds<br>• **Monkey-Y Symmetrical Golden Gripper**: Caliper jaws with dynamic clamping gap for truss manipulation<br>• Dual/Quad AMU constellation variants (`variant_dual`, `variant_quad`) | • Renders: [`renders/amu_CORA-M-arm-opencode_v1-monkey-Y-golden-grip.png`](./openscad/opencode/renders/amu_CORA-M-arm-opencode_v1-monkey-Y-golden-grip.png)<br>• Caliper Demo: [`renders/amu_CORA-M-arm-opencode_v1-caliper-demo.png`](./openscad/opencode/renders/amu_CORA-M-arm-opencode_v1-caliper-demo.png)<br>• Tool Grab Kinematics: [`amu_arm_tool_grab_kinematics.mp4`](./openscad/opencode/amu_arm_tool_grab_kinematics.mp4) |
| **ZeroClaw Structural Node** | • OpenSCAD: [`openscad/zeroclaw/07-19-2026_zeroclaw_amu_node.scad`](./openscad/zeroclaw/07-19-2026_zeroclaw_amu_node.scad)<br>• FreeCAD: [`freecad/amu_orbital/zeroclaw_truss_node_v1.py`](./freecad/amu_orbital/zeroclaw_truss_node_v1.py)<br>• STEP: [`freecad/step_exports/zeroclaw_truss_node_v1.step`](./freecad/step_exports/zeroclaw_truss_node_v1.step) | Node Radius: $12\text{ mm}$<br>Strut Length: $30\text{ mm}$<br>Flange Dia: $14\text{ mm}$ | Passive mechanical interlock | 6-axis octahedral lattice truss connector node for in-space robotic assembly and self-replicating frame construction | • Color Turntable: [`zeroclaw_truss_node_v1_turntable.gif`](./freecad/amu_orbital/renders/zeroclaw_truss_node_v1_turntable.gif) / [`.mp4`](./freecad/amu_orbital/renders/zeroclaw_truss_node_v1_turntable.mp4) |

---

## 2. Heavy Planetary & Polar Transporters (STRIDER-M)

### System Summary
Heavy-duty, low-ground-pressure continuous crawler platform engineered for traversing Arctic permafrost, lunar regolith, or martian terrain without ground subsidence or disruption ($P_{\text{ground}} \le 25\text{ kPa}$).

| Variant | Authoritative CAD Source | Dimensions ($L \times W \times H$) | Ground Clearance | Key Subsystems & Upgrades | Derived Verification Assets |
|:---|:---|:---|:---|:---|:---|
| **STRIDER-M v1.0** | • OpenSCAD: [`openscad/amu_surface/strider_m_transporter_v1.scad`](./openscad/amu_surface/strider_m_transporter_v1.scad)<br>• FreeCAD: [`freecad/mobility/strider_m_v1.py`](./freecad/mobility/strider_m_v1.py)<br>• STEP: [`freecad/step_exports/strider_m_v1.step`](./freecad/step_exports/strider_m_v1.step) | $7.2\text{ m} \times 4.6\text{ m} \times 1.75\text{ m}$ | $1.2\text{ m}$ | • Dual heavy-duty wide continuous crawler tracks ($W = 1.2\text{ m}$)<br>• Heated battery/cryo fuel-cell reservoir<br>• Latch collar docking station ($R = 0.55\text{ m}$, 4x cam latches)<br>• High-visibility utility deck ($5.4\text{ m} \times 3.2\text{ m}$) | • Color Turntable: [`strider_m_v1_turntable.gif`](./freecad/mobility/renders/strider_m_v1_turntable.gif) / [`.mp4`](./freecad/mobility/renders/strider_m_v1_turntable.mp4)<br>• Iso Still: [`strider_m_transporter_v1_iso.png`](./openscad/amu_surface/renders/strider_m_transporter_v1_iso.png)<br>• Rover Exit Still: [`amu_surface_transfer_docking_v1_rover_portal_exit.png`](./openscad/amu_surface/renders/v1_angles/amu_surface_transfer_docking_v1_rover_portal_exit.png) |
| **STRIDER-M v2.1 (Wind Cargo Retention)** | • OpenSCAD: [`openscad/amu_surface/strider_m_transporter_v2.scad`](./openscad/amu_surface/strider_m_transporter_v2.scad)<br>• FreeCAD: [`freecad/mobility/strider_m_v2.py`](./freecad/mobility/strider_m_v2.py)<br>• STEP: [`freecad/step_exports/strider_m_v2.step`](./freecad/step_exports/strider_m_v2.step) | $7.6\text{ m} \times 4.8\text{ m} \times 1.78\text{ m}$ (Stowed)<br>Width with deployed outriggers: $8.6\text{ m}$ | $1.15\text{ m}$ | • **4x A-Frame Knee-Jointed Outrigger Trusses**: High clevis fender mounts, upper box booms, silver hydraulic ram cylinders, wide articulated polar footpads with permafrost cleats (prevents tip-over under $55\text{ m/s}$ gusts)<br>• **Modular Wind Cargo Retention Cradle & Stanchion System**: Dual lateral saddle racks for $4.80\text{ m} \times \varnothing 0.51\text{ m}$ sectional mast pipes, vertical divider racks for $\le 1.90\text{ m}$ blade sleeves, perimeter ratchet tie-down winches, 8x forged clevis D-rings, and aft transom loading guide rollers for crane-less module roll-off<br>• **Deck Transit Park-Mode Latch Cradle**: Transverse U-saddle with dual motorized golden clamping jaws locking folded arm against vibration<br>• **Front Bull-Bar Crash Cage**: Tubular exo-cage with X-brace and dual forged recovery tow-shackles<br>• **Broadened 8-Lug Turret Dock**: $R = 0.68\text{ m}$ with dual concentric optical/power umbilical rings | • Color Turntable: [`strider_m_v2_turntable.gif`](./freecad/mobility/renders/strider_m_v2_turntable.gif) / [`.mp4`](./freecad/mobility/renders/strider_m_v2_turntable.mp4)<br>• Deployed Still: [`strider_m_transporter_v2_deployed_iso.png`](./openscad/amu_surface/renders/v2_angles/strider_m_transporter_v2_deployed_iso.png)<br>• Recessed Still: [`strider_m_transporter_v2_recessed_iso.png`](./openscad/amu_surface/renders/v2_angles/strider_m_transporter_v2_recessed_iso.png)<br>• Front Elevation: [`strider_m_transporter_v2_front_view.png`](./openscad/amu_surface/renders/v2_angles/strider_m_transporter_v2_front_view.png)<br>• Deck Zoom: [`strider_m_transporter_v2_deck_zoom.png`](./openscad/amu_surface/renders/v2_angles/strider_m_transporter_v2_deck_zoom.png)<br>• Video: [`cora_transfer_render02.mp4`](../docs/assets/macrogrid_renders/cora_transfer_render02.mp4) |

---

## 3. Articulated Robotic Manipulators (CORA-M)

### System Summary
Heavy 7-DoF robotic manipulation arm designed for autonomous dual-mode operations: overhead facility ceiling gantry traversing ($Z = 5.15\text{ m}$) and mobile field deployment aboard STRIDER-M transporter ($Z = 1.55\text{ m}$).

| Variant | Authoritative CAD Source | Reach / Scale | DoF | Key Subsystems & Gripper | Derived Verification Assets |
|:---|:---|:---|:---|:---|:---|
| **CORA-M Arm v1.1 (Kinematic Reach Solver)** | • OpenSCAD: [`openscad/amu_surface/amu_CORA-M-arm-opencode_v1.scad`](./openscad/amu_surface/amu_CORA-M-arm-opencode_v1.scad)<br>• FreeCAD: [`freecad/robotics/cora_m_arm_v1.py`](./freecad/robotics/cora_m_arm_v1.py)<br>• STEP: [`freecad/step_exports/cora_m_arm_v1.step`](./freecad/step_exports/cora_m_arm_v1.step) | Reach: $2.73\text{ m}$ spherical radius from shoulder pitch pivot ($L_1 = 1.35\text{ m}$ bicep + $L_2 = 1.10\text{ m}$ forearm + $L_{\text{ee}} = 0.28\text{ m}$ calipers; mounted at $Z = 1.735\text{ m}$ aboard STRIDER-M) | 7-DoF (Base Yaw, Shoulder Pitch, Elbow Pitch, Forearm Roll, Wrist Pitch, Wrist Yaw, Wrist Roll) | • White and deep anodized blue alloy armor casing<br>• Dual golden symmetrical end-effector calipers with dynamic clamping gap `_APAS_caliper_gap`<br>• High-power conductive umbilical coupling and quick-disconnect gantry trolley collar<br>• **7-DoF Kinematic Reach Solver**: Validated reach across STRIDER-M utility deck saddles, blade racks, transit latch, and container gin-pole tilt-up pinning | • Color Turntable: [`cora_m_arm_v1_turntable.gif`](./freecad/robotics/renders/cora_m_arm_v1_turntable.gif) / [`.mp4`](./freecad/robotics/renders/cora_m_arm_v1_turntable.mp4)<br>• Caliper Macro Zoom: [`amu_surface_transfer_docking_v1_calipers_zoom.png`](./openscad/amu_surface/renders/v1_angles/amu_surface_transfer_docking_v1_calipers_zoom.png)<br>• Arm Animation: [`scene1_arm_exit_and_mount.gif`](./openscad/amu_surface_playground/renders/scene1_arm_exit_and_mount.gif)<br>• Field Turbine Install: [`scene2_cora_install_windmill.gif`](./openscad/amu_surface_playground/renders/scene2_cora_install_windmill.gif) |

---

## 4. Polar Habitat & Surface Facilities (AMU-Surface)

### System Summary
Modular vaulted habitat architecture featuring A36 structural steel exoskeleton, perimeter thermal diagrid, environmental Air Handling Units (AHU), and automated ceiling gantry crane corridors.

| Variant | Authoritative CAD Source | Footprint / Height | Structural Envelope | Facility Infrastructure | Derived Verification Assets |
|:---|:---|:---|:---|:---|:---|
| **AMU-Surface Habitat v1.0** | • OpenSCAD: [`openscad/amu_surface/amu_surface_habitat_v1.scad`](./openscad/amu_surface/amu_surface_habitat_v1.scad)<br>• FreeCAD: [`freecad/amu_surface/surface_habitat_v1.py`](./freecad/amu_surface/surface_habitat_v1.py)<br>• STEP: [`freecad/step_exports/surface_habitat_v1.step`](./freecad/step_exports/surface_habitat_v1.step) | Span: $9.0\text{ m}$, Height: $5.8\text{ m}$, Length: $12.0\text{ m}$ | Vaulted gothic/catenary structural ribs, reinforced cold-weather steel skin | • Apex heavy I-beam gantry rail at $Z = 5.15\text{ m}$<br>• Transporter staging airlock bay with motorized roll-up doors<br>• High-voltage buffer bus and staging platform | • Color Turntable: [`surface_habitat_v1_turntable.gif`](./freecad/amu_surface/renders/surface_habitat_v1_turntable.gif) / [`.mp4`](./freecad/amu_surface/renders/surface_habitat_v1_turntable.mp4)<br>• Stills: [`amu_surface_habitat_v1_iso.png`](./openscad/amu_surface/renders/amu_surface_habitat_v1_iso.png)<br>• Playground Suite: [`scene1_iso.png`](./openscad/amu_surface_playground/renders/scene1_iso.png), [`scene1_top.png`](./openscad/amu_surface_playground/renders/scene1_top.png) |
| **Ceiling-to-Rover Gantry Transfer Docking v1.0** | [`openscad/amu_surface/amu_surface_transfer_docking_v1.scad`](./openscad/amu_surface/amu_surface_transfer_docking_v1.scad) | Kinematic envelope spanning $X: [-2.0, 11.5]\text{ m}$, $Z: [1.55, 5.15]\text{ m}$ | 4-Phase Kinematic Timeline: Rail Traverse $\to$ Vertical Descent $\to$ Caliper Latch $\to$ Rover Rollout | Autonomous mechanical mating of CORA-M arm from ceiling carriage to STRIDER-M chassis deck | • Docking Iso: [`amu_surface_transfer_docking_v1_docking_iso.png`](./openscad/amu_surface/renders/v1_angles/amu_surface_transfer_docking_v1_docking_iso.png)<br>• Kinematic Loop: [`amu_surface_transfer_docking_v1.gif`](./openscad/amu_surface/renders/amu_surface_transfer_docking_v1.gif)<br>• High-Fidelity MP4: [`cora_transfer_render01.mp4`](../docs/assets/macrogrid_renders/cora_transfer_render01.mp4) |

---

## 5. Modular Containerized Arctic Wind Turbines (Wind v2.0 / v3.0)

### System Summary
Containerized Arctic wind turbine system designed for deployment without heavy cranes in extreme polar environments ($−60\ ^\circ\text{C}$, $120\text{–}150\text{ km/h}$ survival gusts). Shipped as a standard 20 ft ISO intermodal sea container.

| Variant | Authoritative CAD Source | Dimensions / Capacity | Structural & Power Architecture | Erection & Foundation Mechanics | Derived Verification Assets |
|:---|:---|:---|:---|:---|:---|
| **Modular Arctic Wind Turbine v3.0 (Airfoil Loft & Rigging)** | • FreeCAD: [`freecad/wind/modular_wind_turbine_v3.py`](./freecad/wind/modular_wind_turbine_v3.py)<br>• STEP: [`freecad/step_exports/modular_wind_turbine_v3.step`](./freecad/step_exports/modular_wind_turbine_v3.step)<br>• Architecture Spec: [`docs/specifications/modular_arctic_wind_architecture.md`](../docs/specifications/modular_arctic_wind_architecture.md) | Rated: $50\text{ kW}$<br>Hub Height: $26.6\text{ m}$ ($24\text{ m}$ mast)<br>Rotor Diameter: $26.0\text{ m}$ | NACA 4415/4418 aerodynamic lofted blades with 7 modular joint sleeve collars; low-temperature thermal equilibrium nacelle cowl | 20 ft ISO base sled with 4x deployable outriggers, permafrost ground pads, 4-point guy wire tension collar ($z=16\text{ m}$), and container gin-pole A-frame tilt-up winch | • Color Turntable: [`modular_wind_turbine_v3_turntable.gif`](./freecad/wind/renders/modular_wind_turbine_v3_turntable.gif) / [`.mp4`](./freecad/wind/renders/modular_wind_turbine_v3_turntable.mp4)<br>• Tech Spec: [`modular_arctic_wind_architecture.md`](../docs/specifications/modular_arctic_wind_architecture.md) |
| **Wind Turbine Full Assembly v2.0 (Baseline Reference)** | • OpenSCAD: [`openscad/wind/v2.0/wind_v2_turbine_full.scad`](./openscad/wind/v2.0/wind_v2_turbine_full.scad)<br>• FreeCAD: [`freecad/wind/modular_wind_turbine_v2.py`](./freecad/wind/modular_wind_turbine_v2.py)<br>• STEP: [`freecad/step_exports/modular_wind_turbine_v2.step`](./freecad/step_exports/modular_wind_turbine_v2.step) | Rated: $25\text{–}100\text{ kW}$<br>Hub Height: $24.0\text{ m}$<br>Rotor Diameter: $26.0\text{ m}$ | Direct-drive permanent magnet generator with integrated passive snow-shedding nacelle | Sectional tubular mast with modular outrigger pads directly out of the container chassis | • Color Turntable: [`modular_wind_turbine_v2_turntable.gif`](./freecad/wind/renders/modular_wind_turbine_v2_turntable.gif) / [`.mp4`](./freecad/wind/renders/modular_wind_turbine_v2_turntable.mp4)<br>• Full Turbine Still: [`openscad/wind/renders/`](./openscad/wind/renders/)<br>• Macrogrid Array: [`scene3_macrogrid_iso.png`](./openscad/amu_surface_playground/renders/scene3_macrogrid_iso.png)<br>• 100-Unit Fleet: [`scene3_strider_fleet_windfarm.gif`](./openscad/amu_surface_playground/renders/scene3_strider_fleet_windfarm.gif) |
| **Wind Container Stowage & Logistics** | [`openscad/wind/v2.0/wind_v2_container_stowage.scad`](./openscad/wind/v2.0/wind_v2_container_stowage.scad) | Standard 20 ft ISO Container ($6.058\text{ m} \times 2.438\text{ m} \times 2.591\text{ m}$) | Internal nesting racks for 21x blade segments ($3\times 7$), 5x mast sections, nacelle, microgrid cabinet, and ground anchors | Self-contained intermodal shipping ($9,216.8\text{ kg} \le 10,886\text{ kg}$) with zero external crane requirements | Fully decoupled and prepared for standalone repository spin-off ([`docs/repo_extraction_manifest.md`](../docs/repo_extraction_manifest.md)) |

---

## 6. Promotion & Archival Policy

1. **Immutable Historical Records**:
   - `wind/v1.0` (two-phase thermal sail) is archived in [`openscad/wind/archive/v1.0/`](./openscad/wind/archive/v1.0/) and must not be modified.
   - Heritage orbital AMU (`amu_heritage_opencode_v1.scad`) is frozen as baseline reference for orbital self-replication.
2. **Sequential Semantic Versioning**:
   - All physical hardware files must include an explicit version suffix (`_v1`, `_v2`, `_v3`).
   - Minor parameter adjustments (e.g. gear ratio, cleat count) are recorded via git commits under the active version file.
   - Kinematic or architectural changes (such as the addition of outriggers and transit locks on STRIDER-M, or aerodynamic airfoil lofts on the Wind Turbine) require a new version file (`_v2`, `_v3`).
3. **Cross-Format Verification**:
   - OpenSCAD is the conceptual kinematic benchmark.
   - FreeCAD / CadQuery implementations (tracked under Issue [#18](https://github.com/stellardreams/asi.surge.sh/issues/18) and [#101](https://github.com/stellardreams/asi.surge.sh/issues/101)) maintain exact dimensional parity and provide STEP/IGES solid exports for FEA/CFD.

