#!/usr/bin/env python3
"""
Wind v2.0 Package 2 -- Mast Structure & Tilt-Up Erection Kinematics (#86)

Simulates the mechanical kinematics and cable tensions for erecting a 24 m
hub-height modular wind turbine mast using an integrated gin-pole (A-frame)
and electric/manual winch skid on a 20 ft ISO container foundation.

Zero Heavy-Lift Mandate:
- No mobile cranes or excavators required on site.
- Entire assembly assembled horizontally atop/alongside container and tilted up.
- Modular sections <= 4.8 m length (fitting within 5.89 m container interior).
"""

import sys
import math

# 1. Structural & Geometric Dimensions
HUB_HEIGHT_M = 24.0
NUM_SECTIONS = 5
SECTION_LENGTH_M = HUB_HEIGHT_M / NUM_SECTIONS  # 4.8 m each (< 5.89 m container interior)
MAST_DIAMETER_M = 0.50  # 500 mm OD
MAST_WALL_THICK_M = 0.008  # 8 mm high-strength steel (Q355 / St52)

# Masses
STEEL_DENSITY_KG_M3 = 7850.0
# Section cross-sectional area
MAST_AREA_M2 = math.pi * ((MAST_DIAMETER_M/2.0)**2 - ((MAST_DIAMETER_M - 2*MAST_WALL_THICK_M)/2.0)**2)
MAST_MASS_PER_M_KG = MAST_AREA_M2 * STEEL_DENSITY_KG_M3  # ~96.8 kg/m
TOTAL_MAST_MASS_KG = MAST_MASS_PER_M_KG * HUB_HEIGHT_M   # ~2 323 kg

# Top-head mass (direct-drive PMSG + nacelle bedplate + rotor hub & feathered blades)
TOPHEAD_MASS_KG = 1600.0  # 1.6 tonnes nacelle + hub + blades

TOTAL_LIFTED_MASS_KG = TOTAL_MAST_MASS_KG + TOPHEAD_MASS_KG
G = 9.80665

# Combined Center of Mass from Mast Base Pivot
# Mast mass acts at HUB_HEIGHT / 2; Top-head mass acts at HUB_HEIGHT
R_CM_M = (TOTAL_MAST_MASS_KG * (HUB_HEIGHT_M / 2.0) + TOPHEAD_MASS_KG * HUB_HEIGHT_M) / TOTAL_LIFTED_MASS_KG
TOTAL_WEIGHT_N = TOTAL_LIFTED_MASS_KG * G

# 2. Gin-Pole (A-Frame) Geometry
# Pivot point of mast and gin pole: at container trunnion (X=0, Z=0)
L_GIN_POLE_M = 7.0  # 7.0 m rigid triangular A-frame
# Angle between mast axis and gin-pole axis: fixed at 90 degrees
# When mast is at 0° (horizontal, X-axis), gin pole is at +90° (vertical, Z-axis)
ALPHA_GIN_DEG = 90.0

# Winch Location relative to base trunnion
# Winch is mounted towards the opposite end of the container roof:
# L_CONT = 6.058 m. Trunnion is near one end (X=0), winch is at X = -4.5 m, Z = 0.2 m
WINCH_X_M = -4.5
WINCH_Z_M = 0.2

# 3. Kinematic Sweep from theta = 0 deg (horizontal) to theta = 90 deg (vertical)
def compute_kinematics(theta_deg):
    """
    Computes lifting geometry and forces for mast elevation angle theta (degrees).
    """
    theta_rad = math.radians(theta_deg)

    # Gravitational moment about base pivot:
    # M_grav = W * R_CM * cos(theta)
    M_GRAV_NM = TOTAL_WEIGHT_N * R_CM_M * math.cos(theta_rad)

    # Gin pole tip position:
    # Gin pole angle from horizontal = theta + ALPHA_GIN_DEG
    phi_rad = theta_rad + math.radians(ALPHA_GIN_DEG)
    gin_tip_x = L_GIN_POLE_M * math.cos(phi_rad)
    gin_tip_z = L_GIN_POLE_M * math.sin(phi_rad)

    # Vector from winch to gin pole tip:
    dx_winch = gin_tip_x - WINCH_X_M
    dz_winch = gin_tip_z - WINCH_Z_M
    d_winch_cable = math.sqrt(dx_winch**2 + dz_winch**2)

    # Unit vector of winch cable pulling on gin pole tip:
    u_cable_x = -dx_winch / d_winch_cable
    u_cable_y = 0.0
    u_cable_z = -dz_winch / d_winch_cable

    # Lever arm vector of gin pole tip from pivot: (gin_tip_x, 0, gin_tip_z)
    # Torque produced by 1 Newton of winch cable tension:
    # tau_unit = r x F = gin_tip_x * u_cable_z - gin_tip_z * u_cable_x
    tau_per_N = abs(gin_tip_x * u_cable_z - gin_tip_z * u_cable_x)

    # Required winch cable tension to balance gravity:
    if tau_per_N > 1e-4:
        T_winch_N = M_GRAV_NM / tau_per_N
    else:
        T_winch_N = 0.0

    # Compressive axial load on gin-pole legs
    # Gin pole transfers tension via backstay cables to the mast at height H_backstay
    # Compressive force is approximately resultant of winch cable and backstay line
    F_gin_comp_N = T_winch_N * math.sqrt(2 * (1 + math.cos(math.atan2(dz_winch, dx_winch) - phi_rad)))

    return {
        "theta": theta_deg,
        "m_grav_knm": M_GRAV_NM / 1000.0,
        "winch_tension_kn": T_winch_N / 1000.0,
        "gin_comp_kn": F_gin_comp_N / 1000.0,
        "cable_length_m": d_winch_cable
    }

def run_simulation():
    print("=" * 70)
    print(" WIND v2.0 PACKAGE 2: MAST TILT-UP ERECTION KINEMATICS (#86)")
    print("=" * 70)
    print(f"Hub Height:                  {HUB_HEIGHT_M:.1f} m ({NUM_SECTIONS} sections @ {SECTION_LENGTH_M:.2f} m each)")
    print(f"Mast Section Length:         {SECTION_LENGTH_M:.2f} m (< 5.89 m container length: PASS)")
    print(f"Total Lifted Assembly Mass:  {TOTAL_LIFTED_MASS_KG:.1f} kg (Mast: {TOTAL_MAST_MASS_KG:.0f} kg, Head: {TOPHEAD_MASS_KG:.0f} kg)")
    print(f"Center of Mass from Pivot:   {R_CM_M:.2f} m")
    print(f"Gin-Pole (A-Frame) Length:   {L_GIN_POLE_M:.1f} m (Rigid 90° angle to mast)")
    print(f"Winch Anchor Location:       X = {WINCH_X_M:.2f} m, Z = {WINCH_Z_M:.2f} m")
    print("-" * 70)
    print(f"{'Elevation (deg)':<16} | {'Gravity Torque (kNm)':<22} | {'Winch Tension (kN)':<20} | {'Gin Comp. (kN)':<15}")
    print("-" * 70)

    angles = [0, 15, 30, 45, 60, 75, 85, 90]
    results = []
    max_tension = 0.0
    max_gin_comp = 0.0

    for a in angles:
        res = compute_kinematics(a)
        results.append(res)
        if res["winch_tension_kn"] > max_tension:
            max_tension = res["winch_tension_kn"]
        if res["gin_comp_kn"] > max_gin_comp:
            max_gin_comp = res["gin_comp_kn"]
        print(f"{res['theta']:<16.1f} | {res['m_grav_knm']:<22.2f} | {res['winch_tension_kn']:<20.2f} | {res['gin_comp_kn']:<15.2f}")

    print("=" * 70)
    print(f"Peak Winch Line Pull:        {max_tension:.2f} kN ({max_tension * 224.8:.0f} lbf)")
    print(f"Peak Gin-Pole Compression:   {max_gin_comp:.2f} kN ({max_gin_comp * 224.8:.0f} lbf)")

    # Structural Safety Checks
    # 1. Modular section fit in 20 ft ISO box (< 5.89 m)
    assert SECTION_LENGTH_M <= 5.89, f"Section length {SECTION_LENGTH_M} m exceeds container internal length"

    # 2. Winch cable capacity check
    # Standard 19 mm (3/4 in) 6x36 EIPS wire rope has MBL = 260 kN (~58 400 lbf)
    # Using a 4-part heavy-duty snatch block reeving between winch base and gin pole tip:
    PARTS_OF_LINE = 4
    ROPE_MBL_KN = 260.0
    T_PER_PART_KN = max_tension / PARTS_OF_LINE
    winch_cable_fs = ROPE_MBL_KN / T_PER_PART_KN  # Safety factor on running wire rope
    assert winch_cable_fs >= 3.5, f"Winch rope safety factor insufficient: {winch_cable_fs:.2f} < 3.5"

    # 3. Gin-pole Euler buckling check
    # Gin pole is dual-leg A-frame (two structural steel tubes: 219 mm OD x 10 mm wall, L = 7.0 m)
    # E = 200 GPa, I = pi/64 * (D^4 - d^4)
    E_STEEL_PA = 200e9
    D_LEG = 0.2191  # 8-inch nominal structural pipe (8.625 in)
    T_LEG = 0.0100  # 10 mm wall
    d_leg = D_LEG - 2 * T_LEG
    I_LEG_M4 = (math.pi / 64.0) * (D_LEG**4 - d_leg**4)
    P_CRIT_SINGLE_LEG_N = (math.pi**2 * E_STEEL_PA * I_LEG_M4) / (L_GIN_POLE_M**2)
    P_CRIT_DUAL_LEG_KN = (2 * P_CRIT_SINGLE_LEG_N) / 1000.0

    gin_buckling_fs = P_CRIT_DUAL_LEG_KN / max_gin_comp
    assert gin_buckling_fs >= 2.0, f"Gin pole buckling safety factor insufficient: {gin_buckling_fs:.2f} < 2.0"

    print(f"VERIFICATION: PASS -- All mast erection kinematic & structural safety checks pass cleanly.")
    print(f"  - Section length: {SECTION_LENGTH_M:.2f} m <= 5.89 m container limit")
    print(f"  - Winch wire rope safety factor: {winch_cable_fs:.2f} (>= 3.0 required)")
    print(f"  - Gin-pole dual-leg Euler buckling safety factor: {gin_buckling_fs:.2f} (>= 2.0 required)")
    print("=" * 70)
    return True

if __name__ == "__main__":
    if not run_simulation():
        sys.exit(1)
    sys.exit(0)
