#!/usr/bin/env python3
"""
container_pack_audit.py -- Package 4: Sectional Rotor, Anti-Icing & Container Stowage Sizing.

Audits mass, volume, and packing constraints for transporting the complete
Wind v2.0 50 kW Arctic wind turbine within a single standard 20 ft ISO shipping container.
Also calculates leading-edge electro-thermal anti-icing power budgets at -60 °C.

Part of Wind v2.0 (Issue #88, parent #82).
"""

import math
import sys

# -----------------------------------------------------------------------------
# 1. 20 ft ISO Shipping Container Envelope
# -----------------------------------------------------------------------------
# Standard 20 ft ISO dry container internal dimensions (ISO 668)
CONTAINER_L_M = 5.898   # Internal length (19' 4.25")
CONTAINER_W_M = 2.352   # Internal width (7' 8.6")
CONTAINER_H_M = 2.393   # Internal height (7' 10.2")

CONTAINER_VOL_MAX_M3 = CONTAINER_L_M * CONTAINER_W_M * CONTAINER_H_M  # ~33.2 m³
CONTAINER_PAYLOAD_MAX_KG = 10_886.0  # 24 000 lb maximum cargo weight

# -----------------------------------------------------------------------------
# 2. Package 4: Rotor Sizing & Sectional Blade Architecture
# -----------------------------------------------------------------------------
# 50 kW nominal upwind 3-bladed rotor
ROTOR_RADIUS_M = 13.0   # 26 m rotor diameter (swept area = 530.9 m²)
HUB_RADIUS_M = 1.0      # Hub diameter = 2.0 m
BLADE_SPAN_M = ROTOR_RADIUS_M - HUB_RADIUS_M  # 12.0 m blade aerodynamic span

# Sized into modular segments to fit container length (< 5.89 m)
# Baselined at 1.8 m modular blade sections (7 sections per blade + tip cap)
NUM_BLADES = 3
NUM_SECTIONS_PER_BLADE = 7
SECTION_LENGTH_M = 1.714  # 12.0 m / 7 sections ≈ 1.714 m (fits comfortably < 2.3 m container width)
TOTAL_BLADE_SECTIONS = NUM_BLADES * NUM_SECTIONS_PER_BLADE  # 21 sections

# Blade Section Materials & Mass (Carbon/Glass hybrid spar + foam core)
# Average blade mass for modern 12 m blade ≈ 140 kg each
MASS_SINGLE_BLADE_KG = 145.0
MASS_ROTOR_BLADES_ALL_KG = NUM_BLADES * MASS_SINGLE_BLADE_KG  # 435.0 kg
MASS_ROTOR_HUB_SPIDER_KG = 220.0  # Pitch bearings, central casting, spinner nose cone
MASS_ROTOR_TOTAL_KG = MASS_ROTOR_BLADES_ALL_KG + MASS_ROTOR_HUB_SPIDER_KG  # 655.0 kg

# -----------------------------------------------------------------------------
# 3. Leading-Edge Electro-Thermal Anti-Icing Power Budget (-60 °C)
# -----------------------------------------------------------------------------
# Heating foil along the outer 60% of blade span (where ice accretion and relative velocity peak)
HEATED_SPAN_M = 0.60 * BLADE_SPAN_M  # 7.2 m heated leading edge per blade
HEATED_CHORD_PERIMETER_M = 0.25      # 250 mm wrap around leading-edge stagnation line
HEATED_AREA_PER_BLADE_M2 = HEATED_SPAN_M * HEATED_CHORD_PERIMETER_M  # 1.80 m²
HEATED_AREA_TOTAL_M2 = NUM_BLADES * HEATED_AREA_PER_BLADE_M2          # 5.40 m²

# Thermal flux required to prevent rime icing in freezing Arctic airflow at -60 °C (ambient + convective wind loss)
# Empirical anti-icing flux for extreme cold: 600 - 900 W/m²
FLUX_ANTI_ICE_W_M2 = 750.0  # 750 W/m²
P_ANTI_ICE_TOTAL_W = HEATED_AREA_TOTAL_M2 * FLUX_ANTI_ICE_W_M2  # 4 050 W (4.05 kW)
ANTI_ICE_POWER_FRACTION = P_ANTI_ICE_TOTAL_W / 50_000.0          # 8.1% of 50 kW turbine output

# -----------------------------------------------------------------------------
# 4. Microgrid Power Electronics & Low-EMI Electrical Cabinet
# -----------------------------------------------------------------------------
# 4-quadrant back-to-back AC-DC-AC converter, grid-forming droop control, EMI filtering (MIL-STD-461G)
MASS_POWER_CONVERTER_KG = 320.0
MASS_ELECTRICAL_CABINET_KG = 180.0
MASS_CABLES_AND_HARNESSES_KG = 160.0
MASS_MICROGRID_ELECTRICAL_KG = MASS_POWER_CONVERTER_KG + MASS_ELECTRICAL_CABINET_KG + MASS_CABLES_AND_HARNESSES_KG  # 660.0 kg

# -----------------------------------------------------------------------------
# 5. Full Program Mass & Volume Reconciliation (All 4 Packages)
# -----------------------------------------------------------------------------
# Package 1: Foundation & Ground Anchors (#85)
# Note: Earth anchors, ISO corner shoe outriggers, jacks, rigging (excluding on-site rock ballast)
MASS_PACKAGE_1_EQUIPMENT_KG = 1_850.0
VOL_PACKAGE_1_M3 = 3.8

# Package 2: Mast Structure & Tilt-Up Erection (#86)
# 6x sectional lattice/tubular mast trunks (5.0 m each), gin-pole A-frame, 20 kN winch, snatch blocks
MASS_PACKAGE_2_MAST_KG = 3_450.0
MASS_PACKAGE_2_WINCH_GINPOLE_KG = 680.0
MASS_PACKAGE_2_TOTAL_KG = MASS_PACKAGE_2_MAST_KG + MASS_PACKAGE_2_WINCH_GINPOLE_KG  # 4 130 kg
VOL_PACKAGE_2_M3 = 11.2

# Package 3: Arctic Direct-Drive Powertrain & Nacelle (#87)
# From powertrain_envelope.py: generator, main shaft, bedplate, yaw drive, cowl
MASS_PACKAGE_3_NACELLE_KG = 1_501.8
VOL_PACKAGE_3_M3 = 4.2

# Package 4: Sectional Rotor, Anti-Icing, Inverter & Stowage Racks (#88)
MASS_STOWAGE_RACKS_DUNNAGE_KG = 420.0
MASS_PACKAGE_4_TOTAL_KG = MASS_ROTOR_TOTAL_KG + MASS_MICROGRID_ELECTRICAL_KG + MASS_STOWAGE_RACKS_DUNNAGE_KG  # 1 735.0 kg
VOL_PACKAGE_4_M3 = 5.6

# Total System Packed Cargo
MASS_TOTAL_SYSTEM_KG = (
    MASS_PACKAGE_1_EQUIPMENT_KG +
    MASS_PACKAGE_2_TOTAL_KG +
    MASS_PACKAGE_3_NACELLE_KG +
    MASS_PACKAGE_4_TOTAL_KG
)

VOL_TOTAL_SYSTEM_M3 = (
    VOL_PACKAGE_1_M3 +
    VOL_PACKAGE_2_M3 +
    VOL_PACKAGE_3_M3 +
    VOL_PACKAGE_4_M3
)

MASS_MARGIN_KG = CONTAINER_PAYLOAD_MAX_KG - MASS_TOTAL_SYSTEM_KG
VOL_PACKING_DENSITY = VOL_TOTAL_SYSTEM_M3 / CONTAINER_VOL_MAX_M3


def main():
    print("=" * 76)
    print(" WIND v2.0: FULL SYSTEM 20 FT ISO CONTAINER STOWAGE & ROTOR AUDIT")
    print(" Tracked under Issue #88 (Package 4) & Parent Issue #82")
    print("=" * 76)

    print("\n[1] 20 FT ISO CONTAINER CAPACITY ENVELOPE:")
    print(f"  • Internal Dimensions        : {CONTAINER_L_M:.3f} m L × {CONTAINER_W_M:.3f} m W × {CONTAINER_H_M:.3f} m H")
    print(f"  • Internal Gross Volume      : {CONTAINER_VOL_MAX_M3:.2f} m³")
    print(f"  • Maximum Allowable Payload  : {CONTAINER_PAYLOAD_MAX_KG:.1f} kg (24 000 lb)")

    print("\n[2] PACKAGE 4: SECTIONAL ROTOR SIZING:")
    print(f"  • Rotor Configuration        : 3-bladed upwind horizontal axis")
    print(f"  • Swept Diameter / Area      : {2.0 * ROTOR_RADIUS_M:.1f} m / {math.pi * ROTOR_RADIUS_M**2:.1f} m²")
    print(f"  • Aerodynamic Blade Span     : {BLADE_SPAN_M:.1f} m")
    print(f"  • Modular Section Length     : {SECTION_LENGTH_M:.2f} m (fits crosswise or axial in container)")
    print(f"  • Total Blade Sections       : {TOTAL_BLADE_SECTIONS} modules ({NUM_SECTIONS_PER_BLADE} per blade)")
    print(f"  • 3x Blade Total Mass        : {MASS_ROTOR_BLADES_ALL_KG:.1f} kg")
    print(f"  • Central Hub & Pitch Spider : {MASS_ROTOR_HUB_SPIDER_KG:.1f} kg")
    print(f"  • Total Rotor Mass           : {MASS_ROTOR_TOTAL_KG:.1f} kg")

    print("\n[3] ELECTRO-THERMAL ANTI-ICING SIZING (-60 °C RIME ICING):")
    print(f"  • Heated Leading-Edge Span   : {HEATED_SPAN_M:.1f} m outer blade span (60%)")
    print(f"  • Total Heated Surface Area  : {HEATED_AREA_TOTAL_M2:.2f} m²")
    print(f"  • Heat Flux Requirement      : {FLUX_ANTI_ICE_W_M2:.1f} W/m²")
    print(f"  • Required Heating Power     : {P_ANTI_ICE_TOTAL_W:.1f} W ({P_ANTI_ICE_TOTAL_W/1e3:.2f} kW)")
    print(f"  • Generator Output Share     : {ANTI_ICE_POWER_FRACTION * 100:.1f} % of rated 50 kW output")

    print("\n[4] TOTAL SYSTEM MASS BUDGET RECONCILIATION:")
    print(f"  • Package 1 (Foundation Hardware & Outriggers) : {MASS_PACKAGE_1_EQUIPMENT_KG:8.1f} kg  ({VOL_PACKAGE_1_M3:4.1f} m³)")
    print(f"  • Package 2 (Modular Mast, Winch & Gin-Pole)   : {MASS_PACKAGE_2_TOTAL_KG:8.1f} kg  ({VOL_PACKAGE_2_M3:4.1f} m³)")
    print(f"  • Package 3 (Direct-Drive PMSG & Nacelle)      : {MASS_PACKAGE_3_NACELLE_KG:8.1f} kg  ({VOL_PACKAGE_3_M3:4.1f} m³)")
    print(f"  • Package 4 (Rotor, Microgrid Inverter & Racks): {MASS_PACKAGE_4_TOTAL_KG:8.1f} kg  ({VOL_PACKAGE_4_M3:4.1f} m³)")
    print("  " + "-" * 62)
    print(f"  • TOTAL PACKED CARGO MASS                      : {MASS_TOTAL_SYSTEM_KG:8.1f} kg  ({VOL_TOTAL_SYSTEM_M3:4.1f} m³)")
    print(f"  • 20 FT ISO CONTAINER PAYLOAD CAPACITY         : {CONTAINER_PAYLOAD_MAX_KG:8.1f} kg  ({CONTAINER_VOL_MAX_M3:4.1f} m³)")
    print(f"  • PAYLOAD MASS MARGIN                          : {MASS_MARGIN_KG:8.1f} kg  ({(MASS_MARGIN_KG/CONTAINER_PAYLOAD_MAX_KG)*100:4.1f}% margin)")
    print(f"  • PACKING VOLUMETRIC UTILIZATION               : {VOL_PACKING_DENSITY * 100:4.1f}%")

    # Safety assertions
    assert MASS_TOTAL_SYSTEM_KG <= CONTAINER_PAYLOAD_MAX_KG, (
        f"Total mass {MASS_TOTAL_SYSTEM_KG} kg exceeds container payload {CONTAINER_PAYLOAD_MAX_KG} kg!"
    )
    assert VOL_TOTAL_SYSTEM_M3 <= CONTAINER_VOL_MAX_M3, (
        f"Total volume {VOL_TOTAL_SYSTEM_M3} m³ exceeds container volume {CONTAINER_VOL_MAX_M3} m³!"
    )
    assert SECTION_LENGTH_M < CONTAINER_W_M, (
        f"Blade section {SECTION_LENGTH_M} m exceeds container internal width {CONTAINER_W_M} m!"
    )
    assert ANTI_ICE_POWER_FRACTION < 0.15, (
        f"Anti-icing power fraction {ANTI_ICE_POWER_FRACTION} exceeds 15% generation budget!"
    )

    print("\n[5] VERIFICATION RESULT: PASS (All 4 container transport & anti-icing assertions satisfied)")
    print("=" * 76)
    return 0


if __name__ == "__main__":
    sys.exit(main())
