# Private Engineering Note: MIL-STD-461G Two-Way EMI Shielding, NEMA 4X (`IP66/IP68`) Microgrid Cabinet & 360° Braided Umbilical Armor

- **Document Path**: `.sys_opt/docs/mil_std_461g_emi_and_nema4x_enclosure_spec.md` *(Private, local on `mram`, git-ignored)*
- **Associated CAD & Render Assets**:
  - STEP Solid Model: [`cad_and_blender/freecad/step_exports/wind_v3_microgrid_cabinet.step`](file:///vms_and_github/Github/asi.surge.sh/cad_and_blender/freecad/step_exports/wind_v3_microgrid_cabinet.step)
  - High-Res Render (Repo): [`cad_and_blender/freecad/wind/renders/wind_v3_microgrid_cabinet.png`](file:///vms_and_github/Github/asi.surge.sh/cad_and_blender/freecad/wind/renders/wind_v3_microgrid_cabinet.png)
  - High-Res Render (Brain): [`wind_v3_microgrid_cabinet.png`](./wind_v3_microgrid_cabinet.png)
- **Authors**: `@genidma` & `Gemini 4 Argon` (`@agy`)

---

## 1. Visual Architecture: `wind_v3_microgrid_cabinet.png`

![Microgrid Cabinet Render](./wind_v3_microgrid_cabinet.png)

---

## 2. Two-Way Electromagnetic Shielding (`MIL-STD-461G`)

`MIL-STD-461G` (*Requirements for the Control of Electromagnetic Interference Characteristics of Subsystems and Equipment*) protects both **outbound** and **inbound** electromagnetic vectors:

```text
+-------------------------------------------------------------------------+
|                NEMA 4X + MIL-STD-461G FARADAY CABINET                   |
|          (3.0 mm Welded 316L Stainless Steel + EMI Gaskets)             |
|                                                                         |
|   [ 50 kW SiC Inverter ] ---> [ Two-Stage Sine-Wave LC Choke ]          |
|            |                                 |                          |
|   1. BLOCKS OUTGOING NOISE:                  |  2. BLOCKS INCOMING      |
|      - RE102 (No radio waves leak out)       |     JAMMING / ATTACKS:   |
|      - CE102 (No power-wire buzz leaks out)  |     - RS103 (Survives    |
|      So we NEVER blind friendly NORAD        |       200 V/m external   |
|      radar or HF/SATCOM radios!              |       radar/EW jamming)  |
|                                              |     - CS101-116 (Blocks  |
|                                              |       grid EMP/surges)   |
+-------------------------------------------------------------------------+
```

| Test Code | Direction | Frequency / Level | What It Means in Plain Language |
| :--- | :---: | :--- | :--- |
| **RE102** | **Outbound** (Radiated Emissions) | `10 kHz – 18 GHz` | Prevents the wind turbine's inverter and `24 m` mast from broadcasting radio static that could blind nearby NORAD North Warning System radars or military HF/VHF/SATCOM radios. |
| **CE102** | **Outbound** (Conducted Emissions) | `10 kHz – 10 MHz` | Prevents high-frequency switching ripple from traveling out along the `400V AC` microgrid power cables into base camp electronics. |
| **RS103** | **Inbound** (Radiated Susceptibility) | Up to `200 V/m` (`2 MHz – 18 GHz`) | Ensures our turbine's PLC and inverter survive intense external electromagnetic fields—whether from a nearby military radar beam sweeping across the mast or hostile electronic warfare (EW) jamming. |
| **CS101 / CS114 / CS115 / CS116** | **Inbound** (Conducted Susceptibility) | Damped sinusoids & fast transients | Protects the cabinet against lightning strikes, diesel generator switching spikes, and high-altitude EMP/surge transients on the microgrid bus. |

---

## 3. What `NEMA 4X` Means (and Australian / IEC `IP66 / IP68` Equivalence)

- **NEMA 4X** (National Electrical Manufacturers Association Type 4X) is the North American industrial standard for extreme-environment outdoor electrical enclosures:
  - **`4` (Watertight & Ice-Proof)**: Must block windblown tundra dust, driving sleet, high-pressure hose-down water (`65 GPM` from a `1 in.` nozzle), and remain undamaged when completely encased in external rime/glaze ice.
  - **`X` (Extreme Corrosion Resistance)**: Constructed from welded **`316L` marine-grade stainless steel** (or marine aluminum) so coastal Arctic salt spray never rusts the seams (preserving the low-impedance Faraday cage seal for 20+ years).
- **International & Australian Advanced Manufacturing Equivalence (`IEC 60529 IP66 / IP68`)**:
  - In Australia and Europe, extreme mining, offshore, and defence enclosures use **IP66 / IP68** (`Ingress Protection` rated for zero dust ingress + high-pressure water jets / continuous immersion) fabricated via precision laser-welded `316L` stainless steel.
  - **Partner Note (`@genidma`)**: Tracked in `forward_tasks.md` (`02. Non-Deadline Tasks`) to explore advanced manufacturing enclosure fabrication with your Australian contact.

---

## 4. How the `360°` Grounded Steel / Tinned-Copper Braided Umbilical Armor Works

When `50 kW` of 3-phase power travels down the `24.0 m` mast from the nacelle to the container cabinet (`wind_v3_microgrid_cabinet.step`), an unshielded cable would turn the entire `24.0 m` mast into a giant radio antenna—and in the Arctic, exposed rubber cables get chewed by **Arctic foxes (`Vulpes lagopus`) or polar bears**, abraded by blowing ice crystals, or cracked when flexed at `-60 °C` during the `20.0 s` mast tilt-up.

### 4.1 Concentric 5-Layer Umbilical Architecture

```text
           CROSS-SECTION OF 360° BRAIDED DOWN-TOWER UMBILICAL CABLE
           ========================================================

                     . - ~ ~ ~ - .
                 . '   Layer 5     ' .      <-- Layer 5: Outer 316L Stainless Steel
               /   . - ~ ~ ~ ~ - .     \        Mechanical Mesh Armor (Animal bite,
              /  /    Layer 4      \    \       ice abrasion & crush protection)
             |  |   . - ~ ~ ~ - .   |    |
             |  |  |  Layer 3    |  |    |  <-- Layer 4: Arctic Fluorosilicone / EPR
             |  |  |  (3x 400V   |  |    |      Cryo Jacket (Flexible down to -70 °C)
             |  |  |   Phase +   |  |    |
             |  |  |  Fiber/CAN) |  |    |  <-- Layer 3: Inner Tinned-Copper + Mu-Metal
              \  \   ' - _ _ - '   /    /       Dense Double-Braided Faraday Shield
               \   ' . _ _ _ _ . '     /        (>95% optical coverage, blocks EMI)
                 ' .               . '
                     ' - ~ ~ ~ - '
                           |
                           v
        Terminated at BOTH ends via 360° Iris/Cone EMC Compression Glands
        bolted directly to Nacelle Housing & NEMA 4X Cabinet Ground Bus!
```

1. **Why "360° Termination" Matters (No "Pigtail" Ground Wires)**:
   - If you twist a cable shield into a single little ground wire ("pigtail") at the cabinet entry, high-frequency noise (`> 10 MHz`) sees that wire as an inductor and leaks right past it!
   - Instead, a **360° EMC Iris/Cone Compression Gland** clamps around the **entire circumference (`360°`)** of the braided metal mesh right where the cable enters the `NEMA 4X` steel wall. High-frequency electromagnetic currents flowing on the shield are shunted radially in all directions onto the cabinet outer skin and down into the 4x permafrost screw piles—zero RF leakage inside or outside!
2. **Dual-Mesh Function (Mechanical + Electromagnetic)**:
   - **Inner Braid (Tinned Copper / Nickel-Plated Copper Mesh)**: High electrical conductivity to drain common-mode inverter noise (`CE102` / `RE102`).
   - **Outer Braid (`316L` Austenitic Stainless Steel Wire Mesh)**: High tensile and shear strength that stays ductile at `-60 °C` (`FCC` crystal structure, no brittle transition), flexing smoothly across the mast hinge trunnion during the `0° -> 90°` tilt-up while stopping wildlife bites, falling ice chunks, and pinch loads.
   - **Partner Note (`@genidma`)**: Tracked in `forward_tasks.md` (`02. Non-Deadline Tasks`) to consult your German mesh-manufacturing contact on custom dual-layer cryo-flexible stainless/copper braided umbilical sleeving!
