# Wind v2.0 Arctic Microgrid Balance-of-Plant & Electrical Integration

Technical specification for the autonomous electrical architecture and diesel-displacement system housed in the 20 ft ISO container. Tracked under Issue #88 (Package 4) and Parent Issue #82.

---

## 1. System Overview & Active Front End (AFE) Converter

The direct-drive permanent magnet synchronous generator (PMSG) generates variable-voltage, variable-frequency 3-phase AC power ($0 - 480\text{ VAC}$, $0 - 32.5\text{ Hz}$).

### Power Electronics Architecture
1. **Back-to-Back IGBT / SiC Converter:**
   * **Machine-Side Converter (MSC):** Field-oriented vector control (FOC) with maximum torque per ampere (MTPA) tracking.
   * **DC Bus:** Regulated $750\text{ VDC}$ intermediate link with low-temperature film capacitors (rated to $-60\text{ }^\circ\text{C}$).
   * **Grid-Side Converter (GSC):** Active Front End (AFE) voltage source inverter synthesizing clean $480\text{ VAC}$ 3-phase, $60\text{ Hz}$ sine wave output.
2. **EMI & Harmonic Filtering:**
   * LCL output filter with common-mode chokes ensuring Total Harmonic Distortion ($\text{THD} < 2.5\%$).
   * Full military/industrial low-EMI compliance (MIL-STD-461G / IEEE 519) to prevent interference with sensitive Arctic communications, science radar, or HF telemetry.

---

## 2. Autonomous Diesel-Wind Droop Harmonization (Zero Blackout Operation)

In isolated Arctic settlements and remote outposts, the electrical microgrid is powered by reciprocating diesel generators.

### Challenges of High-Penetration Wind
* **Wet-Stacking Risk:** Diesel engines run below $30\%$ of rated mechanical capacity experience incomplete fuel combustion, leading to unburned fuel accumulation in the exhaust manifold ("wet-stacking") and engine fouling.
* **Frequency Instability:** Sudden wind dropouts or heavy turbulent gusts can destabilize small microgrid frequency.

### Autonomous Control Strategy (IEEE 1547.4 Compliant)
1. **P/f and Q/V Frequency-Voltage Droop Control:**
   * The wind inverter operates in grid-supporting droop mode, sharing real and reactive power proportionally with the diesel governors without requiring high-speed fiber communications between units.
2. **Dynamic Minimum-Load Protection:**
   * The microgrid master PLC continuously monitors diesel output. If wind generation approaches $70\%$ of instantaneous load, the wind converter modulates its pitch and power electronic setpoint to keep the diesel loaded at $\ge 30\%$ nominal rating.
3. **Containerized BESS Buffer (50 kWh / 25 kW LFP):**
   * Acts as an instantaneous dynamic shock absorber, soaking up rapid wind gust spikes and supplying power during the 10–15 seconds required for a secondary diesel genset to crank and synchronize.

---

## 3. Annual Diesel Fuel Displacement Audit

Based on the validated 8,760-hour dispatch model in [`microgrid_dispatch.py`](microgrid_dispatch.py) for a 45 kW mean Arctic outpost load:

| Metric | 100% Diesel Baseline | Hybrid Wind-Diesel | Impact / Savings |
| :--- | :---: | :---: | :---: |
| **Annual Fuel Consumed** | $145\text{ }757\text{ L/yr}$ | $124\text{ }671\text{ L/yr}$ | **$21\text{ }087\text{ L/yr}$ saved** |
| **Fuel Mass Equivalent** | $122.4\text{ tonnes}$ | $104.7\text{ tonnes}$ | **$17.7\text{ tonnes}$ reduction** |
| **Fuel Reduction Share** | — | — | **$14.5\%$ reduction** |
| **Avoided $\text{CO}_2$ Emissions** | $390.6\text{ tonnes}$ | $334.1\text{ tonnes}$ | **$56.5\text{ tonnes } \text{CO}_2\text{ avoided}$** |
| **Wind Capacity Factor** | — | $27.7\%$ | Useful energy $84.7\text{ MWh/yr}$ |
| **Curtailed / Dump Power** | — | $30.2\%$ | Diverted to thermal heating load |

All surplus wind energy that cannot be absorbed into the electrical bus is diverted to secondary resistive space heating immersion coils inside the container, offsetting building heating oil consumption.
