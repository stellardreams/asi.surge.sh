#!/usr/bin/env python3
"""
cold_climate_fmea.py -- Package 3 & 4 / Phase 2: Arctic Wind v2.0 Failure Modes, Effects & Criticality Analysis (FMECA).

Conducts a quantitative Failure Modes and Effects Analysis (FMEA) across all
subsystems of the Wind v2.0 Arctic turbine operating down to -60 °C:
- Subsystem 1: Foundation & Permafrost Interface (frost jacking, thaw settlement)
- Subsystem 2: Tilt-Up Kinematics & Mast (cable snap, trunnion pin freeze-up, gin-pole buckling)
- Subsystem 3: Direct-Drive Powertrain (grease channeling, magnet embrittlement, brake pad freeze)
- Subsystem 4: Sectional Rotor & Anti-Icing (shear pin fatigue, heater foil delamination, runback icing)
- Subsystem 5: Microgrid Power Electronics (IGBT thermal cycling, cold-start bus overvoltage, EMI)

Calculates Risk Priority Numbers (RPN = Severity x Occurrence x Detection) before
and after engineering design mitigations to ensure all residual RPN < 50.

Units: FMEA Scoring (1-10 scale per IEC 60812)
Part of Wind v2.0 (Tracked under Parent Issue #82).
"""

import sys

# -----------------------------------------------------------------------------
# 1. FMEA Database Definition
# -----------------------------------------------------------------------------
FMEA_ENTRIES = [
    {
        "subsystem": "Foundation & Soil",
        "component": "Permafrost Ground Interface",
        "failure_mode": "Active layer summer thaw settlement and toppling",
        "cause": "Thermal conduction through container floor thawing underlying permafrost table",
        "severity": 9,  # Catastrophic toppling
        "init_occ": 7,  # Likely without insulation
        "init_det": 4,  # Periodic inspection
        "mitigation": "150 mm elevated timber/steel dunnage cribbing + gravel air plenum creating natural convective freezing buffer",
        "res_sev": 9,
        "res_occ": 2,  # Low probability with passive air gap
        "res_det": 2,  # Laser tilt switch with SCADA alarm
    },
    {
        "subsystem": "Powertrain",
        "component": "Main Bearings Lubrication",
        "failure_mode": "Grease channeling and cold-start bearing seizure at -60 °C",
        "cause": "Base oil viscosity spike in conventional grease below pour point",
        "severity": 8,  # Major bearing failure / downtime
        "init_occ": 8,  # Very high with standard lubricants
        "init_det": 5,  # Temperature sensor
        "mitigation": "Synthetic ester/PAO grease rated to -65 °C (Aeroshell 22 / Mobilith SHC 007) + internal thermal self-heating + 120 W standstill trace heating",
        "res_sev": 8,
        "res_occ": 2,
        "res_det": 2,
    },
    {
        "subsystem": "Powertrain",
        "component": "Permanent Magnets (NdFeB)",
        "failure_mode": "Magnet cracking or embrittlement under thermal shock",
        "cause": "Differential thermal expansion between NdFeB sintered blocks and steel rotor spider",
        "severity": 8,  # Generator destruction
        "init_occ": 5,  # Moderate risk with standard grades
        "init_det": 6,  # Magnetic flux anomaly
        "mitigation": "Low-temperature resilience grade N42SH magnets with flexible cryogenic epoxy bonding and mechanical retaining sleeve",
        "res_sev": 8,
        "res_occ": 1,
        "res_det": 3,
    },
    {
        "subsystem": "Rotor & Blades",
        "component": "Modular Blade Joint",
        "failure_mode": "Shear pin fracture under dynamic gust loading",
        "cause": "Cyclic bending moments during high turbulence Arctic gusts exceeding pin shear yield",
        "severity": 9,  # Blade separation / catastrophic
        "init_occ": 6,  # High stress concentration
        "init_det": 6,  # Visual inspection
        "mitigation": "Dual M24 Grade 5 Titanium/4340 alloy shear pins with internal carbon box-beam sleeve distributing shear across 280 mm overlap (FS = 4.25)",
        "res_sev": 9,
        "res_occ": 1,
        "res_det": 2,
    },
    {
        "subsystem": "Rotor & Blades",
        "component": "Electro-Thermal Anti-Icing",
        "failure_mode": "Severe asymmetric rime icing accretion causing dynamic rotor imbalance",
        "cause": "Leading-edge heater wire open-circuit on 1 blade",
        "severity": 8,  # Excessive tower vibration / trip
        "init_occ": 5,  # Heating element burnout
        "init_det": 4,  # Current telemetry
        "mitigation": "Redundant parallel-wired carbon nanotube (CNT) heating foils with 3-axis accelerometer vibration trip sensor (< 6.4 kN unbalance limit)",
        "res_sev": 8,
        "res_occ": 2,
        "res_det": 2,
    },
    {
        "subsystem": "Mast & Kinematics",
        "component": "Gin-Pole A-Frame",
        "failure_mode": "Euler column buckling during initial tilt-up lift",
        "cause": "Peak winching line tension at horizontal mast elevation (theta = 0 deg)",
        "severity": 9,  # Mast drop during erection
        "init_occ": 5,  # High load condition
        "init_det": 4,  # Tension load cell
        "mitigation": "7.0 m rigid A-frame using Ø219 mm x 8 mm structural pipe providing Euler buckling factor of safety FS = 3.82 against 48.2 kN line tension",
        "res_sev": 9,
        "res_occ": 1,
        "res_det": 2,
    },
    {
        "subsystem": "Braking System",
        "component": "Emergency Caliper Brake",
        "failure_mode": "Hydraulic fluid freezing causing brake failure during overspeed",
        "cause": "Extreme cold freezing hydraulic brake lines",
        "severity": 10, # Runaway rotor destruction
        "init_occ": 8,  # Almost certain in Arctic winter with hydraulics
        "init_det": 5,  # Pressure transducer
        "mitigation": "100% mechanical spring-applied, electrically-released caliper brake (zero hydraulic fluid) with ventilated slotted disc",
        "res_sev": 10,
        "res_occ": 1,
        "res_det": 1,
    },
    {
        "subsystem": "Microgrid Controls",
        "component": "Active Front End (AFE) Inverter",
        "failure_mode": "Cold-start DC bus overvoltage and capacitor failure at -60 °C",
        "cause": "Electrolytic capacitor electrolyte freezing increasing Equivalent Series Resistance (ESR)",
        "severity": 7,  # Converter inverter trip
        "init_occ": 7,  # Common in standard industrial drives
        "init_det": 3,  # DC bus voltage sensor
        "mitigation": "Industrial low-temperature polypropylene film capacitors (rated to -60 °C) + pre-charge soft-start circuit + climate-controlled microgrid cabinet",
        "res_sev": 7,
        "res_occ": 1,
        "res_det": 2,
    },
]

def run_fmea_analysis():
    print("=" * 80)
    print(" WIND v2.0: ARCTIC COLD-CLIMATE FAILURE MODES & EFFECTS ANALYSIS (FMEA)")
    print(" Tracked under Parent Issue #82")
    print("=" * 80)

    print(f"\n[1] SUBSYSTEM CRITICALITY EVALUATION (IEC 60812 Standard):")
    print(f"  {'Subsystem / Component':<32} | {'Initial RPN':<12} | {'Residual RPN':<13} | {'Risk Reduction':<14}")
    print("  " + "-" * 78)

    total_init_rpn = 0
    total_res_rpn = 0

    for item in FMEA_ENTRIES:
        init_rpn = item["severity"] * item["init_occ"] * item["init_det"]
        res_rpn = item["res_sev"] * item["res_occ"] * item["res_det"]
        reduction = ((init_rpn - res_rpn) / init_rpn) * 100.0

        total_init_rpn += init_rpn
        total_res_rpn += res_rpn

        comp_name = f"{item['subsystem']}: {item['component'][:16]}"
        print(f"  {comp_name:<32} | {init_rpn:>4} (S{item['severity']} O{item['init_occ']} D{item['init_det']})  | {res_rpn:>4} (S{item['res_sev']} O{item['res_occ']} D{item['res_det']})   | -{reduction:>5.1f} %")

    print(f"\n[2] AGGREGATE RISK METRICS:")
    print(f"  • Cumulative Baseline System RPN : {total_init_rpn}")
    print(f"  • Cumulative Residual Mitigated RPN: {total_res_rpn}")
    print(f"  • Total System Risk Reduction    : -{((total_init_rpn - total_res_rpn) / total_init_rpn) * 100.0:.1f} %")
    print(f"  • Maximum Individual Residual RPN: {max(item['res_sev'] * item['res_occ'] * item['res_det'] for item in FMEA_ENTRIES)} (Threshold: < 50)")

    # Assertions
    for item in FMEA_ENTRIES:
        rpn = item["res_sev"] * item["res_occ"] * item["res_det"]
        assert rpn <= 40, f"Component {item['component']} residual RPN {rpn} exceeded maximum acceptable threshold of 40"

    print("\n[3] VERIFICATION RESULT: PASS (All failure modes mitigated below criticality threshold RPN < 50)")
    print("=" * 80)
    return True

if __name__ == "__main__":
    if not run_fmea_analysis():
        sys.exit(1)
