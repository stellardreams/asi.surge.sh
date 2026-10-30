#!/usr/bin/env python3
"""
powertrain_envelope.py -- Package 3: Arctic Direct-Drive Powertrain (-60 °C) & Nacelle Sizing.

Calculates torque, electromagnetic active mass, mechanical bedplate structure,
cold-start viscous drag, and steady-state thermal equilibrium for a 50 kW
direct-drive permanent magnet synchronous generator (PMSG) operating at -60 °C.

Part of Wind v2.0 (Issue #87, parent #82).
"""

import math
import sys

# -----------------------------------------------------------------------------
# 1. Operational & Environmental Envelope
# -----------------------------------------------------------------------------
P_RATED_ELEC_W = 50_000.0        # Rated electrical output power (50 kW)
OMEGA_RPM = 65.0                 # Nominal rotational speed (RPM)
T_MIN_AMB_C = -60.0              # Extreme Arctic minimum temperature (°C)
T_DESIGN_OP_C = -20.0            # Target minimum operating nacelle internal temp (°C)
ETA_ELEC_TARGET = 0.93           # Minimum target generator electrical efficiency

# Physical constants
OMEGA_RAD_S = OMEGA_RPM * (2.0 * math.pi / 60.0)  # ~6.807 rad/s

# Mechanical Power & Torque
P_RATED_MECH_W = P_RATED_ELEC_W / ETA_ELEC_TARGET  # ~53 763 W
TORQUE_RATED_NM = P_RATED_MECH_W / OMEGA_RAD_S     # ~7 898 N·m

# -----------------------------------------------------------------------------
# 2. PMSG Electromagnetic Sizing (Outer/Inner Stator Ring Topology)
# -----------------------------------------------------------------------------
# Shear stress sizing for permanent magnet machines:
# sigma = F_tan / A_gap = Torque / (2 * pi * R_gap^2 * L_stack)
# Standard air-cooled direct-drive wind turbine shear stress: 25 - 35 kPa
SHEAR_STRESS_PA = 30_000.0  # 30 kPa

# Sizing stator bore diameter to fit within 20 ft ISO container cross-section (width < 2.3 m)
# Baselined stator air-gap radius: R_gap = 0.60 m (Diameter = 1.20 m)
R_GAP_M = 0.60
D_GAP_M = 2.0 * R_GAP_M
L_STACK_M = TORQUE_RATED_NM / (2.0 * math.pi * (R_GAP_M ** 2) * SHEAR_STRESS_PA)  # ~0.116 m stack length

# Electromagnetic Active Material Masses
# Stator laminations (electrical steel M400-50A, density 7650 kg/m^3)
R_STATOR_OUTER_M = R_GAP_M + 0.08  # 80 mm slot depth + yoke
STATOR_CORE_VOL_M3 = math.pi * (R_STATOR_OUTER_M**2 - R_GAP_M**2) * L_STACK_M
MASS_STATOR_IRON_KG = STATOR_CORE_VOL_M3 * 7650.0 * 0.75  # ~75% stacking/slot factor

# Copper windings (copper density 8960 kg/m^3)
MASS_COPPER_KG = 75.0  # Distributed multi-phase copper windings

# NdFeB permanent magnets (density 7500 kg/m^3, grade N42SH rated to -60 °C with low temp-coeff)
MASS_MAGNETS_KG = 42.0

MASS_ELECTROMAGNETIC_ACTIVE_KG = MASS_STATOR_IRON_KG + MASS_COPPER_KG + MASS_MAGNETS_KG

# Structural Generator Housing & Rotor Support Spider (Cast nodular iron / structural steel)
MASS_GENERATOR_STRUCTURE_KG = 280.0
MASS_GENERATOR_TOTAL_KG = MASS_ELECTROMAGNETIC_ACTIVE_KG + MASS_GENERATOR_STRUCTURE_KG

# -----------------------------------------------------------------------------
# 3. Main Shaft, Bearings & Nacelle Bedplate Budget
# -----------------------------------------------------------------------------
# Dual tapered roller bearing arrangement with forged alloy steel main shaft (42CrMo4)
D_SHAFT_M = 0.180  # 180 mm outer diameter hollow shaft
L_SHAFT_M = 0.950  # 950 mm shaft length
MASS_MAIN_SHAFT_KG = 165.0
MASS_MAIN_BEARINGS_KG = 85.0   # 2x heavy-duty spherical/tapered roller bearings

# Structural Bedplate & Yaw Drive
MASS_BEDPLATE_STEEL_KG = 320.0  # Heavy welded structural plate transferred to mast top
MASS_YAW_SYSTEM_KG = 145.0      # Slewing ring, dual electric geared drive units
MASS_BRAKE_SYSTEM_KG = 65.0     # Spring-applied caliper, ventilated disc, manual release lever
MASS_COWL_INSULATION_KG = 110.0 # Aerodynamic composite cowl + aerogel thermal blanket

MASS_NACELLE_TOTAL_KG = (
    MASS_GENERATOR_TOTAL_KG +
    MASS_MAIN_SHAFT_KG +
    MASS_MAIN_BEARINGS_KG +
    MASS_BEDPLATE_STEEL_KG +
    MASS_YAW_SYSTEM_KG +
    MASS_BRAKE_SYSTEM_KG +
    MASS_COWL_INSULATION_KG
)

# -----------------------------------------------------------------------------
# 4. Thermal Balance & Internal Self-Heating
# -----------------------------------------------------------------------------
# In operation, generator efficiency losses are converted into heat:
Q_LOSS_HEAT_W = P_RATED_MECH_W - P_RATED_ELEC_W  # ~3 763 W

# Nacelle heat dissipation:
# 1. Shell conductive/convective loss through composite cowl with thermal insulation:
A_COWL_SURFACE_M2 = 9.5  # Surface area of cylindrical / streamlined cowl
U_COWL_W_M2_K = 0.65     # Thermal transmittance with aerogel insulation
Q_LOSS_SHELL_PER_K = A_COWL_SURFACE_M2 * U_COWL_W_M2_K  # ~6.18 W/K

# 2. Forced internal convective ventilation / cooling air circulation through labyrinth louvers
# Designed passive/thermostatic louver venting to reject heat and maintain internal air around 15 °C to 30 °C
# At equilibrium under thermostatically controlled louver ventilation (e.g. V_dot ~ 0.08 m^3/s):
# m_dot_air * c_p * (T_internal - T_ambient) + Q_shell = Q_LOSS_HEAT_W
# Thermostatically modulated ventilation conductance:
G_VENT_W_K = 40.0  # W/K effective convective conductance via regulated ventilation
G_TOTAL_THERMAL_W_K = Q_LOSS_SHELL_PER_K + G_VENT_W_K  # ~46.2 W/K

DELTA_T_HEATING_K = Q_LOSS_HEAT_W / G_TOTAL_THERMAL_W_K  # ~81.5 K rise above ambient
T_INTERNAL_EQUILIBRIUM_C = T_MIN_AMB_C + DELTA_T_HEATING_K  # ~ +21.5 °C at -60 °C ambient

# Standstill standby trace heater (when turbine is locked in dead calm Arctic night)
# Maintains bearings and stator above -40 °C with louvers fully closed:
P_TRACE_HEATER_W = Q_LOSS_SHELL_PER_K * ((-40.0) - T_MIN_AMB_C)  # ~123.5 W

# -----------------------------------------------------------------------------
# 5. Cold-Start Viscous Drag Assessment
# -----------------------------------------------------------------------------
# AeroShell Grease 33 (base oil viscosity at -60 °C is ~1500 cSt vs 15 cSt at 40 °C)
# Startup breakaway torque required to overcome cold grease channels:
TORQUE_BREAKAWAY_COLD_NM = 45.0  # ~45 N·m breakaway torque per bearing set
BREAKAWAY_FRACTION = TORQUE_BREAKAWAY_COLD_NM / TORQUE_RATED_NM


def main():
    print("=" * 72)
    print(" WIND v2.0: ARCTIC DIRECT-DRIVE POWERTRAIN SIZING & ENVELOPE (-60 °C)")
    print(" Tracked under Issue #87 (Parent #82)")
    print("=" * 72)

    print("\n[1] OPERATING SPECIFICATIONS & RATED TORQUE:")
    print(f"  • Rated Electrical Power     : {P_RATED_ELEC_W / 1e3:.1f} kW")
    print(f"  • Target Generator Efficiency: {ETA_ELEC_TARGET * 100:.1f} %")
    print(f"  • Shaft Mechanical Power     : {P_RATED_MECH_W / 1e3:.2f} kW")
    print(f"  • Rotor Rotational Speed     : {OMEGA_RPM:.1f} RPM ({OMEGA_RAD_S:.3f} rad/s)")
    print(f"  • Rated Rotor Shaft Torque   : {TORQUE_RATED_NM:.1f} N·m ({TORQUE_RATED_NM/1e3:.2f} kN·m)")

    print("\n[2] PMSG ELECTROMAGNETIC SIZING:")
    print(f"  • Air-gap Stator Diameter    : {D_GAP_M * 1e3:.0f} mm")
    print(f"  • Active Magnetic Stack Length: {L_STACK_M * 1e3:.1f} mm")
    print(f"  • Design Shear Stress        : {SHEAR_STRESS_PA / 1e3:.1f} kPa")
    print(f"  • Stator Lamination Iron Mass: {MASS_STATOR_IRON_KG:.1f} kg")
    print(f"  • Copper Windings Mass       : {MASS_COPPER_KG:.1f} kg")
    print(f"  • NdFeB Magnets Mass         : {MASS_MAGNETS_KG:.1f} kg")
    print(f"  • Total Active Electromagnetic Mass: {MASS_ELECTROMAGNETIC_ACTIVE_KG:.1f} kg")
    print(f"  • Total Generator Mass       : {MASS_GENERATOR_TOTAL_KG:.1f} kg")

    print("\n[3] NACELLE MASS BUDGET & LIFT CONFORMANCE:")
    print(f"  • Direct-Drive PMSG Assembly : {MASS_GENERATOR_TOTAL_KG:.1f} kg")
    print(f"  • Main Shaft (42CrMo4 Alloy) : {MASS_MAIN_SHAFT_KG:.1f} kg")
    print(f"  • Main Bearings (Low-Temp)   : {MASS_MAIN_BEARINGS_KG:.1f} kg")
    print(f"  • Structural Steel Bedplate  : {MASS_BEDPLATE_STEEL_KG:.1f} kg")
    print(f"  • Yaw Drive & Slewing Ring   : {MASS_YAW_SYSTEM_KG:.1f} kg")
    print(f"  • Spring-Applied Brake Caliper: {MASS_BRAKE_SYSTEM_KG:.1f} kg")
    print(f"  • Cowl & Aerogel Insulation  : {MASS_COWL_INSULATION_KG:.1f} kg")
    print("  -------------------------------------------------------------")
    print(f"  • TOTAL NACELLE ALLOCATED MASS: {MASS_NACELLE_TOTAL_KG:.1f} kg")
    print(f"  • Kinematics Lift Mass Limit : 1 600.0 kg")
    print(f"  • Mass Margin                : {1600.0 - MASS_NACELLE_TOTAL_KG:.1f} kg ({((1600.0 - MASS_NACELLE_TOTAL_KG)/1600.0)*100:.1f}%)")

    print("\n[4] THERMAL BALANCE & REGULATED SELF-HEATING:")
    print(f"  • Internal Heat Generation ($I^2 R$): {Q_LOSS_HEAT_W:.1f} W (3.76 kW heat)")
    print(f"  • Insulated Cowl Shell Conductance: {Q_LOSS_SHELL_PER_K:.2f} W/K")
    print(f"  • Regulated Ventilation Conductance: {G_VENT_W_K:.2f} W/K")
    print(f"  • Ambient Air Temperature    : {T_MIN_AMB_C:.1f} °C")
    print(f"  • Self-Heating Equilibrium ΔT: +{DELTA_T_HEATING_K:.1f} °C")
    print(f"  • Internal Operating Temp    : +{T_INTERNAL_EQUILIBRIUM_C:.1f} °C (Optimum operating range for electronics/grease)")
    print(f"  • Standstill Trace Heater Req: {P_TRACE_HEATER_W:.1f} W (to maintain -40 °C during dead calm)")

    print("\n[5] COLD-START BREAKAWAY TORQUE:")
    print(f"  • Breakaway Torque at -60 °C : {TORQUE_BREAKAWAY_COLD_NM:.1f} N·m")
    print(f"  • Breakaway vs Rated Torque  : {BREAKAWAY_FRACTION * 100:.2f}% (Trivial for turbine aerodynamic torque)")

    # Assertions
    assert MASS_NACELLE_TOTAL_KG <= 1600.0, f"Nacelle mass {MASS_NACELLE_TOTAL_KG} kg exceeds 1600 kg limit!"
    assert D_GAP_M <= 2.2, f"Stator diameter {D_GAP_M} m exceeds ISO container width limit!"
    assert T_INTERNAL_EQUILIBRIUM_C >= T_DESIGN_OP_C, f"Operating internal temp {T_INTERNAL_EQUILIBRIUM_C} °C below target {T_DESIGN_OP_C} °C!"
    assert T_INTERNAL_EQUILIBRIUM_C <= 65.0, f"Operating internal temp {T_INTERNAL_EQUILIBRIUM_C} °C exceeds allowable rating!"
    assert BREAKAWAY_FRACTION < 0.05, f"Breakaway torque fraction {BREAKAWAY_FRACTION} exceeds 5% limit!"

    print("\n[6] VERIFICATION RESULT: PASS (All 5 structural, thermal & mass assertions satisfied)")
    print("=" * 72)
    return 0


if __name__ == "__main__":
    sys.exit(main())
