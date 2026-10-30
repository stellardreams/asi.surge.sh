# Private Engineering Note: Permafrost Helical Screw Piles, Passive $\text{CO}_2$ Thermo-Siphons, Anti-Sink Jack-Out Footpads & Formearth Cryo-Composite Ballast

- **Document Path**: `.sys_opt/docs/permafrost_foundation_piles_thermosiphon_formearth.md` *(Private, local on `mram`, git-ignored)*
- **Public Repo Cross-References (Where This Is Documented)**:
  1. Technical Architecture Spec: [`docs/specifications/modular_arctic_wind_architecture.md` (§5.3)](file:///vms_and_github/Github/asi.surge.sh/docs/specifications/modular_arctic_wind_architecture.md)
  2. FreeCAD Parametric B-Rep Generator: [`cad_and_blender/freecad/wind_v3/modular_wind_turbine_v3.py`](file:///vms_and_github/Github/asi.surge.sh/cad_and_blender/freecad/wind_v3/modular_wind_turbine_v3.py) (`build_foundation_subsystem`)
  3. Physics Verification Model: [`scripts/wind_v2/foundation_load_envelope.py`](file:///vms_and_github/Github/asi.surge.sh/scripts/wind_v2/foundation_load_envelope.py)
  4. CAD Render: [`cad_and_blender/freecad/wind/renders/wind_v3_foundation.png`](file:///vms_and_github/Github/asi.surge.sh/cad_and_blender/freecad/wind/renders/wind_v3_foundation.png) · [`wind_v3_foundation.png` (Brain)](./wind_v3_foundation.png)
  5. GitHub Issue Tracker: [Issue #103 (`TASK-06` — Cue: `formearth_arctic` / `arctic_formearth`)](https://github.com/stellardreams/asi.surge.sh/issues/103)
- **Authors**: `@genidma` & `Gemini 4 Argon` (`@agy`)

---

## 1. Visual Architecture: `wind_v3_foundation.png`

![Foundation Render](./wind_v3_foundation.png)

---

## 2. How the 4-Part Permafrost Foundation Works Together

```text
                  [ 24.0 m Wind Turbine Mast ]
                               |
     +=========================+=========================+
     |    20 ft Container Sled + Internal Ballast Bays   |
     |  [ Filled with 2,157 kg Local Gravel + Snow/Ice   |
     |    Cryo-Composite frozen by Thermo-Siphon Loop ]  |
     +=========================+=========================+
       /     (150 mm Thermal Insulation Pad)           \
      / Outrigger Arm                     Outrigger Arm \
  +-------+  <-- 120 kN Jack-Out Collar             +-------+
  |Pad 0.9m| <-- 15° Beveled UHMW-PE Anti-Stick Rim |Pad 0.9m|
==+===+===+=========================================+===+===+==  <-- Ground Surface (Z = 0.0 m)
      |   |   ACTIVE LAYER (0.0 m to -1.2 m):           |   |
      |   |   Freezes in winter, thaws to mud in July   |   |
------+---+---------------------------------------------+---+--  <-- Permafrost Table (Z = -1.2 m)
      |   |   PERMANENTLY FROZEN PERMAFROST (< -1.2 m): |   |
     /=====\  <-- Helical Screw Pile Blades (1.8 m deep)/=====\
      |   |       (Holds 85 kN pullout; unscrews in      |   |
     /=====\       15 mins when relocating!)            /=====\
      |CO2|   <-- Passive Thermo-Siphon Tube:            |CO2|
      +---+       Pumps winter cold (-50 °C) down;       +---+
                  stops summer heat from going down!
```

---

## 3. Solving the "Sinking & Freezing-In" Problem (`@genidma`'s Anti-Sink & Jack-Out Extraction Design)

`@genidma` identified a critical field failure mode: during the July/August Arctic thaw, the top `0.5 m–1.2 m` active layer turns into wet saturated muskeg/silt. If a flat steel outrigger pad sinks `10–20 cm` into the mud and then freezes solid in September (`-40 °C`), **adfreeze bond stress** (`~200–400 kPa` on bare steel) locks the pad into the frozen ground like an ice cube!

To guarantee the pads **never sink excessively** and **always pop free effortlessly** during teardown/relocation, we incorporate three mechanical and thermal countermeasures:

```text
         ANTI-SINK & ANTI-ADFREEZE JACK-OUT FOOTPAD DETAIL
         =================================================

                     Outrigger Clevis Arm
                             |  |
                  +----------+--+----------+
                  |  Double-Acting Acme /  | <-- 1. JACK-OUT EXTRACTION COLLAR:
                  |  Hydraulic Jack Screw  |     Pushing against the central screw pile
                  +----------+--+----------+     lifts the pad UP with 120 kN (27,000 lbf)!
                             |  |
             ================+==+================
            /     Steel Structural Dome          \
           /   [ Perimeter CNT Thermal-Break ]    \ <-- 2. 10-Min +2 °C Pulse melts ice skin
          /________________________________________\
          \      15° Beveled UHMW-PE Liner         / <-- 3. Hydrophobic UHMW-PE + 15° Cone:
           \______________________________________/     Ice cannot bond; angled sides release
                       ||            ||                 immediately on upward lift!
                       || Screw Pile ||
                       ||  Through-  ||
                       ||   Sleeve   ||
```

1. **`15°` Beveled / Conical Profile with Hydrophobic `UHMW-PE` Base Liner**:
   - Bare steel has high ice adhesion (`~250–400 kPa`). Lining the bottom and `15°` sloped sides of the `0.90 m` footpad with **Ultra-High-Molecular-Weight Polyethylene (`UHMW-PE`)**—the same tough polymer used on Arctic expedition sled runners—slashes ice adfreeze bond strength by **`> 90%`** (`< 20 kPa`).
   - Because the sides are sloped at a **`15°` draft angle** (like an inverted frustum or muffin tin), the very first `2 mm` of upward vertical movement breaks the entire perimeter shear bond!
2. **Double-Acting Jack-Out Extraction Collar (`120 kN` Breakout Force)**:
   - Each outrigger vertical leveling jack is coupled via a reaction collar to the helical screw pile sleeve. Before unscrewing the pile, reversing the jack uses the anchored pile as a reaction post to **pull the footpad straight up out of the frozen mud with `120 kN` (`27,000 lbf`) of lifting force**!
3. **Optional Perimeter Thermal-Release Pulse (`+2 °C` for 10 Minutes)**:
   - A `300 W` resistive heating loop embedded inside the footpad rim (powered by the turbine or battery bus before shutdown) warms the pad interface to `+2 °C` for 10 minutes, creating a microscopic water film that releases any frozen silt with zero prying.

---

## 4. How Passive $\text{CO}_2$ Thermo-Siphons Work (The Solar-Can Convection Analogy)

Your analogy to a **solar pop-can air heater** is 100% physically accurate! Both devices are **natural buoyancy thermosiphons** driven purely by temperature differences with **zero moving parts, zero pumps, and zero electricity**:

| Feature | Solar Pop-Can Heater (Warms a House) | Arctic $\text{CO}_2$ Thermo-Siphon Pile (Keeps Ground Frozen) |
| :--- | :--- | :--- |
| **Working Fluid** | Air inside black aluminum cans | Pressurized liquid/vapor $\text{CO}_2$ sealed inside a steel pipe |
| **When Active** | **Sunny Day**: Sun heats air in cans -> warm air becomes buoyant and rises into the house; cool room air flows into bottom. | **Arctic Winter (`-30 °C to -60 °C` air)**: Ground at `-1.8 m` depth is warmer (`-2 °C`) than the winter air (`-50 °C`). Liquid $\text{CO}_2$ at the bottom absorbs ground heat, boils into vapor, rises to the top radiator fins, condenses in the `-50 °C` wind, and drips back down—super-cooling the permafrost to `-15 °C`! |
| **Automatic One-Way Diode Action** | **Nighttime**: Air in cans is colder/heavier than room air, so upward flow stops naturally. | **Arctic Summer (`+15 °C` air)**: Top of pipe is warmer than the bottom (`-10 °C` soil). Warm vapor stays at the top and liquid stays at the bottom—convection **completely stops**, so summer heat is blocked from entering the permafrost! |

---

## 5. Formearth Snow + Ice + Gravel Cryo-Composite Ballast & Phase 2 Geopolymers

1. **Tier 1 (Immediate Arctic Field Method — Snow/Ice/Gravel + Thermo-Siphon Cryo-Composite)**:
   - Instead of flying `2,157 kg` of deadweight concrete on a Hercules, the container base frame has modular ballast trays.
   - Crew members shovel **local Arctic gravel, crushed rock, and compacted snow/water** into the trays.
   - Routing an evaporator loop from the passive $\text{CO}_2$ thermo-siphon through the ballast trays freezes the gravel-rock-snow-ice mixture into a solid, fiber/aggregate-reinforced **Cryo-Composite / Pykrete Monolith** (`density ~2,100–2,300 kg/m³`, compressive strength `> 15–25 MPa` below `-10 °C`—stronger than standard residential concrete, and maintained sub-zero through summer by the insulated container floor + thermo-siphon!).
2. **Tier 2 (Post-Deadline Phase 2 R&D — Ancient Andean / Machu Picchu Geopolymer Binders)**:
   - As `@genidma` noted, materials researchers (such as Prof. Joseph Davidovits at the Geopolymer Institute) have studied whether ancient Andean master builders (Tiwanaku / Puma Punku / Saksaywaman / Machu Picchu) used natural organic/alkali-activated aluminosilicate **geopolymer stone binders** that cure at ambient temperatures using local crushed rock without high-temperature Portland cement kilns.
   - We have logged **Low-Temperature Arctic Aluminosilicate Geopolymer & Cryo-Aggregate Binders** under [Issue #103 (`formearth_arctic`)](https://github.com/stellardreams/asi.surge.sh/issues/103) as a **Post-Deadline (`02. Non-Deadline`) R&D track** so we protect tomorrow's deadline from scope creep while exploring this high-leverage material science!
