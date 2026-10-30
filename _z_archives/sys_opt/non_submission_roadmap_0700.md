# Non-Submission Engineering, GitHub Issues & AI Render Prompts (`non_submission_roadmap_0700.md`)
**Companion to:** [`forward_tasks.md`](./forward_tasks.md) (`02. Non-Deadline Tasks`) & [`Feedback_0700.md`](./Feedback_0700.md) (*Dedicated IDEaS Submission Plan*)  
**Local Private Mirror:** [`.sys_opt/non_submission_roadmap_0700.md`](file:///vms_and_github/Github/asi.surge.sh/.sys_opt/non_submission_roadmap_0700.md) (Untracked in Git)

> [!NOTE]
> **Purpose of This Document**
> All **non-submission** engineering work, GitHub issue closeout checklists (`#111`, `#103`, `#110`, `#112`), AI visual render prompts (`PROMPT-01` through `PROMPT-05`), and post-deadline R&D tasks (`TASK-01` through `TASK-14`) are consolidated here so that [`Feedback_0700.md`](./Feedback_0700.md) remains 100% focused on executing and submitting the DND / PSPC IDEaS proposal.

---

## 1. Non-Deadline GitHub Issues & Desired Outcomes Reviews (`#111`, `#103`, `#110`, `#112`)

### 1.1 Desired Outcome 1 — [Issue #111](https://github.com/stellardreams/asi.surge.sh/issues/111) (`nema4x_emi_umbilical`): Two-Way EMI Shielding & 360° Braided Umbilical
* **Technical Summary**:
  * **Outbound Emissions (Protecting Site Radar/Comms)**: Brushless 65 RPM direct-drive PMSG (zero slip-ring brush arcing) + 316L stainless Faraday cabinet (`> 80 dB` attenuation, `10 kHz – 18 GHz`) + nanocrystalline common-mode chokes & differential $LC$ sine-wave $dv/dt$ filters ($\text{THD}_V < 1.5\%$).
  * **Inbound Immunity (Protecting Turbine Controls)**: Hardened against `200 V/m` high-power external radar sweeps (`RS103`) and lightning/switching transients (`CS101/114/115/116`).
  * **360° Braided Down-Tower Umbilical**: Flexible sub-zero silicone/EPR power & fiber-optic umbilical enclosed in a tinned-copper + mu-metal overbraid, terminated via $360^\circ$ circumferential EMI compression glands (`< 2.0 mΩ` transfer impedance).
* **Action Item**:
  * [ ] When ready (post-submission), review **[Issue #111](https://github.com/stellardreams/asi.surge.sh/issues/111)** (`nema4x_emi_umbilical`) so we can close it with the `git-zero-open-items-in-issue` protocol.

### 1.2 Desired Outcome 2 — [Issue #103](https://github.com/stellardreams/asi.surge.sh/issues/103) (`wind_turbine_3_to_50kw`): Permafrost Foundation, Helical Anchors & `FormEarth` Cryo-Silicate Grout
* **Technical Summary**:
  * **4-Tier Foundation Architecture**:
    1. **20 ft Container Gravity Sled + 4x Deployable Outriggers** (`6.84 m x 6.84 m` footprint, `46.40 kPa < 150 kPa` bearing pressure).
    2. **4x Deep Helical Permafrost Screw Piles** anchored `> 1.8 m` below the active thaw layer (`85 kN` pullout capacity per pile, `FoS = 2.68`).
    3. **Closed-Cell Polyisocyanurate Thermal Break Pads + Passive $\text{CO}_2$ Thermo-Siphons** preventing summer heat conduction into permafrost.
    4. **`FormEarth` Sub-Zero Sodium-Aluminosilicate Geopolymer Stabilization (`-50 °C`)**: Binds indigenous Arctic gravel/regolith into a `28.5 MPa` monolithic anchor collar (`136.8 kN` pullout per pile, `FoS = 4.07`), saving `2,157 kg` of airlifted ballast.
* **Action Item**:
  * [ ] When ready (post-submission), review **[Issue #103](https://github.com/stellardreams/asi.surge.sh/issues/103)** (`wind_turbine_3_to_50kw`) so we can close it with the `git-zero-open-items-in-issue` protocol.

### 1.3 Post-Deadline Marine & AI Pipeline Issues (`#110` & `#112`)
* **[Issue #110](https://github.com/stellardreams/asi.surge.sh/issues/110)** (`polar_sealift_bluefin`): *Multi-Modal Polar Sealift, STRIDER-M Barge Envelope & 'Blue Fin' Low-Acoustic Marine Logistics (`TASK-12`)* — deferred to post-deadline engineering.
* **[Issue #112](https://github.com/stellardreams/asi.surge.sh/issues/112)** (Sub-issue of **[Issue #102](https://github.com/stellardreams/asi.surge.sh/issues/102)**): *AI Technical Illustration Pipeline — Replicate/Flux + ControlNet for Hardware Diagrams (`TASK-14`)* — tracks automated multi-Reference Image + ControlNet conditioning so CAD geometry stays 100% locked while generating photorealistic overlays.

---

## 2. 3D CAD Exploded Blowup Renders & Individual Gemini Web Prompts (`PROMPT-01` to `PROMPT-05`)

> [!TIP]
> **Revisit Whenever Convenient (Post-Submission / Credit-Dependent)**
> Both 3D CAD exploded blowup diagrams are already generated via [`.sys_opt/simulations/render_exploded_blowup_diagrams.py`](file:///vms_and_github/Github/asi.surge.sh/.sys_opt/simulations/render_exploded_blowup_diagrams.py). Whenever you want to run the photorealistic Gemini Web renders, each prompt has its own standalone `.md` file in `.sys_opt/prompts/individual/` with exact reference image paths.

### 2.1 Completed 3D CAD Exploded Blowup Renders & First Gemini Web Render
* **Isometric Exploded Blowup (`362 KB`)**: `/vms_and_github/Github/asi.surge.sh/.sys_opt/simulations/01_standalone_self_erecting_mawt/exploded_renders/mawt_v3_exploded_blowup_isometric.png`
* **Front Elevation Exploded Blowup (`288 KB`)**: `/vms_and_github/Github/asi.surge.sh/.sys_opt/simulations/01_standalone_self_erecting_mawt/exploded_renders/mawt_v3_exploded_blowup_front.png`
* **First Gemini Web Render (`Human Engineer in Arctic Parka.jpeg`)**: `/vms_and_github/Github/asi.surge.sh/.sys_opt/prompts/tmp/renders/Human Engineer in Arctic Parka.jpeg`

````carousel
![MAWT v3.1 3D Isometric Exploded Blowup Diagram](./mawt_v3_exploded_blowup_isometric.png)
<!-- slide -->
![MAWT v3.1 Front Elevation Exploded Blowup Diagram](./mawt_v3_exploded_blowup_front.png)
<!-- slide -->
![First Gemini Web Render — Human Engineer in Arctic Parka Scale Lineup](./human_engineer_in_arctic_parka.jpeg)
````

### 2.2 Individual Prompt Files & Reference Images to Attach (`PROMPT-01` to `PROMPT-05`)

| Prompt ID | Individual Prompt File | Primary Reference Image(s) to Attach in Gemini Web | Target Output Filename in `.sys_opt/prompts/tmp/renders/` |
| :--- | :--- | :--- | :--- |
| **`PROMPT-01`** | [`01_container_scale_lineup_prompt.md`](file:///vms_and_github/Github/asi.surge.sh/.sys_opt/prompts/individual/01_container_scale_lineup_prompt.md) | 1. `/vms_and_github/Github/asi.surge.sh/cad_and_blender/freecad/wind/renders/wind_v3_container_stowage.png`<br>2. `/vms_and_github/Github/asi.surge.sh/cad_and_blender/freecad/wind/renders/wind_v3_foundation.png` | `Human Engineer in Arctic Parka.jpeg` *(1st pass done!)* |
| **`PROMPT-02`** | [`02_mawt_v3_exploded_blowup_prompt.md`](file:///vms_and_github/Github/asi.surge.sh/.sys_opt/prompts/individual/02_mawt_v3_exploded_blowup_prompt.md) | 1. `/vms_and_github/Github/asi.surge.sh/.sys_opt/simulations/01_standalone_self_erecting_mawt/exploded_renders/mawt_v3_exploded_blowup_isometric.png`<br>2. `/vms_and_github/Github/asi.surge.sh/cad_and_blender/freecad/wind/renders/wind_v3_nacelle.png`<br>3. `/vms_and_github/Github/asi.surge.sh/cad_and_blender/freecad/wind/renders/wind_v3_blade_joint.png` | `02_mawt_v3_exploded_blowup.jpeg` |
| **`PROMPT-03`** | [`03_polar_swarm_cooperative_exploded_prompt.md`](file:///vms_and_github/Github/asi.surge.sh/.sys_opt/prompts/individual/03_polar_swarm_cooperative_exploded_prompt.md) | 1. `/vms_and_github/Github/asi.surge.sh/cad_and_blender/freecad/kinematics/renders/phase1_field_scene_isometric.png`<br>2. `/vms_and_github/Github/asi.surge.sh/cad_and_blender/freecad/wind/renders/wind_v3_mast_erection.png` | `03_polar_swarm_cooperative_exploded.jpeg` |
| **`PROMPT-04`** | [`04_wind_v4_cryo_maglev_exploded_prompt.md`](file:///vms_and_github/Github/asi.surge.sh/.sys_opt/prompts/individual/04_wind_v4_cryo_maglev_exploded_prompt.md) | 1. `/vms_and_github/Github/asi.surge.sh/cad_and_blender/freecad/wind/renders/wind_v3_nacelle.png`<br>2. `/vms_and_github/Github/asi.surge.sh/cad_and_blender/freecad/wind/renders/wind_v3_microgrid_cabinet.png` | `04_wind_v4_cryo_maglev_exploded.jpeg` |
| **`PROMPT-05`** | [`05_formearth_permafrost_foundation_prompt.md`](file:///vms_and_github/Github/asi.surge.sh/.sys_opt/prompts/individual/05_formearth_permafrost_foundation_prompt.md) | 1. `/vms_and_github/Github/asi.surge.sh/cad_and_blender/freecad/wind/renders/wind_v3_foundation.png`<br>2. `/vms_and_github/Github/asi.surge.sh/cad_and_blender/freecad/kinematics/renders/phase1_field_scene_isometric.png` | `05_formearth_permafrost_foundation.jpeg` |

---

## 3. Post-Deadline Advanced R&D & Simulation Summary (`TASK-01` through `TASK-14`)

All 3 advanced post-deadline R&D simulation suites (`01_standalone_self_erecting_mawt`, `02_polar_swarm_200kw_cooperative`, and `03_cryo_maglev_hts_nacelle_v4`) are verified (`PASS`) in [`.sys_opt/simulations/`](file:///vms_and_github/Github/asi.surge.sh/.sys_opt/simulations/):
1. **`01_standalone_self_erecting_mawt/standalone_mawt_audit.py`**: Verifies 100% crane-less self-erection of the `50 kW` baseline inside a single `20 ft` ISO container (`9,216.8 kg <= 10,886 kg`), `168.45 kN` peak gin-pole winch tension (`FoS = 6.17`), and `FormEarth` cryo-silicate permafrost grouting (`28.5 MPa` at `-50 °C`, `FoS = 4.07`).
2. **`02_polar_swarm_200kw_cooperative/polar_swarm_simulation.py`**: Verifies cooperative erection of a `200 kW` (`36.0 m` 2-blade segmented drop-stitch + carbon spar rotor) by `3x STRIDER-M` + `3x CORA-1` (`7.33 kN` per vehicle, `0.36x` safe drawbar margin) and `80.1%` convective tilt-up drag reduction via active edgewise feathering (`beta = 88 deg`).
3. **`03_cryo_maglev_hts_nacelle_v4/cryo_maglev_hts_simulation.py`**: Verifies Wind v4.0 passive Halbach Maglev bearing (`0.52 N·m` breakaway torque vs `45.0 N·m` mechanical, lowers cut-in wind speed from `3.0 m/s` to `1.45 m/s`, `+294 hrs/yr` generation) + `REBCO` HTS stator (`98.4%` electromagnetic efficiency) + `320 L` `LN2` closed-loop cryocooler thermal battery (`10.2 days` passive ride-through).
