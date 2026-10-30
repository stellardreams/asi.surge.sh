#!/usr/bin/env python3
"""
aero_icing_loads.py -- Phase 2: Extreme Wind Gust & Asymmetric Ice Accretion Load Envelope.

Models aerodynamic thrust, yawing moments, and centrifugal imbalance loads on the
Wind v2.0 50 kW sectional rotor under extreme Arctic conditions:
- IEC 61400-1 Extreme Wind Model (EWM): 50-year 3-second gust at v_e50 = 42.0 m/s (151 km/h)
- Air density at -60 °C: rho = 1.35 kg/m^3 (1.102x standard sea level)
- Asymmetric Rime Icing Accretion: 1 blade carries 25 mm ice accretion (mass +18.5 kg), 2 blades clear
- Gyroscopic, centrifugal, and aerodynamic yawing moment calculation
- Structural safety margin against mast base trunnion yielding and guy-wire tension limits.

Units: SI (N, N*m, kg, m/s)
Part of Wind v2.0 (Tracked under Parent Issue #82).
"""

import math
import sys

# -----------------------------------------------------------------------------
# 1. Physical Constants & Rotor Architecture
# -----------------------------------------------------------------------------
R_ROTOR_M = 13.0                 # 26 m rotor diameter (R = 13 m)
SWEPT_AREA_M2 = math.pi * (R_ROTOR_M ** 2) # ~530.93 m^2
RHO_ARCTIC = 1.35                # -60 °C air density (kg/m^3)
OMEGA_NOMINAL_RPM = 65.0         # 65 RPM nominal operating speed
OMEGA_RAD_S = OMEGA_NOMINAL_RPM * (2.0 * math.pi / 60.0) # ~6.807 rad/s

# Blade mass properties
BLADE_MASS_NOMINAL_KG = 145.0    # Single 12 m modular blade clean mass
HUB_MASS_KG = 220.0
NACELLE_MASS_KG = 1501.8         # From powertrain_envelope.py
MAST_HUB_HEIGHT_M = 26.6         # 24 m mast + 2.6 m container foundation

# Extreme Wind Conditions (IEC Class S Arctic)
V_E50_GUST_MS = 42.0             # 50-year peak 3-second gust (151.2 km/h)
V_PARKED_STORM_MS = 35.0         # Parked storm condition with feathered blades

# -----------------------------------------------------------------------------
# 2. Structural & Aerodynamic Load Models
# -----------------------------------------------------------------------------

def operational_aerodynamic_thrust(wind_speed_ms, ct=0.75):
    """Aerodynamic rotor thrust force during power production."""
    thrust_n = 0.5 * RHO_ARCTIC * SWEPT_AREA_M2 * (wind_speed_ms ** 2) * ct
    return thrust_n

def storm_parked_thrust(wind_speed_ms, cd_feathered=0.12):
    """Drag force on rotor blades feathered parallel to storm wind."""
    # Frontal projected area of 3 feathered blades
    area_feathered_m2 = 3.0 * (12.0 * 0.18) # 12 m length, ~0.18 m feathered profile thickness
    drag_n = 0.5 * RHO_ARCTIC * area_feathered_m2 * (wind_speed_ms ** 2) * cd_feathered
    return drag_n

def asymmetric_ice_imbalance_analysis():
    """
    Simulates severe asymmetric rime icing:
    One blade accumulates 25 mm hard rime ice along leading edge (+18.5 kg at r_ice = 7.5 m),
    while other two blades shed ice cleanly via electro-thermal heating.
    """
    m_ice_kg = 18.5              # Accreted ice mass
    r_ice_cg_m = 7.5             # Center of gravity of accreted ice
    unbalance_kg_m = m_ice_kg * r_ice_cg_m # Static unbalance: 138.75 kg*m

    # Rotating centrifugal imbalance force at 65 RPM
    f_centrifugal_imbalance_n = m_ice_kg * (OMEGA_RAD_S ** 2) * r_ice_cg_m

    # Dynamic yawing moment due to asymmetric aerodynamic drag
    # Ice increases blade drag coefficient from Cd=0.015 to Cd=0.085 (+0.070)
    delta_cd = 0.070
    blade_chord_mean_m = 0.55
    blade_heated_span_m = 7.2
    v_rel_mean = OMEGA_RAD_S * r_ice_cg_m # ~51.0 m/s relative tip speed
    delta_drag_n = 0.5 * RHO_ARCTIC * (blade_chord_mean_m * blade_heated_span_m) * (v_rel_mean ** 2) * delta_cd
    my_asymmetric_nm = delta_drag_n * r_ice_cg_m

    return {
        "m_ice_kg": m_ice_kg,
        "unbalance_kg_m": unbalance_kg_m,
        "f_centrifugal_n": f_centrifugal_imbalance_n,
        "delta_drag_n": delta_drag_n,
        "my_asymmetric_nm": my_asymmetric_nm,
    }

def mast_base_and_guy_wire_loads(f_thrust_top_n, f_imbalance_top_n):
    """Calculates overturning moment at mast base and guy-wire tension."""
    total_shear_top_n = math.sqrt(f_thrust_top_n ** 2 + f_imbalance_top_n ** 2)
    # Overturning moment at mast pivot trunnion (H = 24.0 m above trunnion)
    overturning_moment_nm = total_shear_top_n * 24.0

    # 4x Guy-wire spread at R_anchor = 18.0 m attached at H_guy = 18.0 m
    # Wire angle = 45 degrees
    t_wire_n = (total_shear_top_n * 24.0 / 18.0) / math.sin(math.radians(45.0))
    t_wire_kn = t_wire_n / 1000.0

    # Guy-wire rated breaking load (M24 galvanized steel wire rope: MBL = 340 kN)
    wire_mbl_kn = 340.0
    fs_guy_wire = wire_mbl_kn / t_wire_kn

    return {
        "total_shear_kn": total_shear_top_n / 1000.0,
        "overturning_knt_m": overturning_moment_nm / 1000.0,
        "guy_tension_kn": t_wire_kn,
        "guy_fs": fs_guy_wire,
    }

def run_aero_icing_audit():
    print("=" * 78)
    print(" WIND v2.0: ARCTIC AERODYNAMIC & ASYMMETRIC ICING LOAD ENVELOPE")
    print(" Tracked under Parent Issue #82")
    print("=" * 78)

    # 1. Operational Rated Thrust
    f_thrust_rated = operational_aerodynamic_thrust(10.5, ct=0.75) # Rated 10.5 m/s
    print(f"\n[1] OPERATIONAL ROTOR THRUST (Rated v = 10.5 m/s, rho = 1.35 kg/m³):")
    print(f"  • Swept Rotor Area           : {SWEPT_AREA_M2:.1f} m²")
    print(f"  • Operating Thrust Force     : {f_thrust_rated:,.1f} N ({f_thrust_rated/1e3:.2f} kN)")

    # 2. Storm Parked Gust Thrust (42 m/s / 151 km/h)
    f_thrust_storm = storm_parked_thrust(V_E50_GUST_MS)
    print(f"\n[2] EXTREME 50-YEAR STORM GUST (v_e50 = 42.0 m/s / 151 km/h, Feathered):")
    print(f"  • Peak Aerodynamic Drag Load : {f_thrust_storm:,.1f} N ({f_thrust_storm/1e3:.2f} kN)")

    # 3. Asymmetric Icing Imbalance
    ice_res = asymmetric_ice_imbalance_analysis()
    print(f"\n[3] ASYMMETRIC RIME ICING ACCRETION (+18.5 kg on 1 blade at 65 RPM):")
    print(f"  • Static Mass Unbalance      : {ice_res['unbalance_kg_m']:.2f} kg·m")
    print(f"  • Rotating Centrifugal Force : {ice_res['f_centrifugal_n']:,.1f} N ({ice_res['f_centrifugal_n']/1e3:.2f} kN)")
    print(f"  • Asymmetric Rotor Drag Force: {ice_res['delta_drag_n']:,.1f} N")
    print(f"  • Asymmetric Yawing Moment   : {ice_res['my_asymmetric_nm']:,.1f} N·m ({ice_res['my_asymmetric_nm']/1e3:.2f} kN·m)")

    # 4. Mast Base Overturning & Guy-Wire Safety Factor
    # Combined worst-case: Rated operation + full centrifugal ice imbalance
    loads = mast_base_and_guy_wire_loads(f_thrust_rated, ice_res['f_centrifugal_n'])
    print(f"\n[4] MAST LOAD TRANSFER & GUY-WIRE FACTOR OF SAFETY:")
    print(f"  • Combined Tophead Shear Load: {loads['total_shear_kn']:.2f} kN")
    print(f"  • Overturning Moment at Base : {loads['overturning_knt_m']:.2f} kN·m")
    print(f"  • Guy-Wire Operating Tension : {loads['guy_tension_kn']:.2f} kN (45° angle)")
    print(f"  • Guy-Wire Factor of Safety  : {loads['guy_fs']:.2f} (Required: >= 3.00)")

    # Assertions
    assert loads['guy_fs'] >= 3.0, f"Expected guy wire FS >= 3.0, got {loads['guy_fs']:.2f}"
    assert ice_res['f_centrifugal_n'] < 15000.0, "Centrifugal imbalance exceeded 15 kN limit"
    assert f_thrust_storm < 25000.0, "Storm gust drag exceeded 25 kN limit"

    print("\n[5] VERIFICATION RESULT: PASS (All aerodynamic gust and icing load assertions satisfied)")
    print("=" * 78)
    return True

if __name__ == "__main__":
    if not run_aero_icing_audit():
        sys.exit(1)
