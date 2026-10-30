#!/usr/bin/env python3
"""
weibull_wind_resource.py -- Phase 2: Arctic Wind Resource & Weibull Sensitivity Analysis.

Closes the primary analytical gap identified in v1.3.0 release notes:
"The envelope gives high wind (80-120 km/h). A power estimate is about the mean."

Models Annual Energy Production (AEP), capacity factors, and aerodynamic yields
across standardized IEC Arctic Wind Classes (Class I, II, III, and S) with
temperature-corrected air density (rho = 1.35 kg/m^3 at -60 °C vs 1.225 kg/m^3 standard).

Units: SI (m/s, kW, MWh, kg/m^3)
Part of Wind v2.0 (Tracked under Issue #88 & Parent Issue #82).
"""

import math
import sys

# -----------------------------------------------------------------------------
# 1. Physics & Turbine Parameters
# -----------------------------------------------------------------------------
ROTOR_DIAMETER_M = 26.0
SWEPT_AREA_M2 = math.pi * ((ROTOR_DIAMETER_M / 2.0) ** 2) # ~530.93 m^2
RATED_POWER_KW = 50.0

V_CUT_IN_MS = 3.0
V_RATED_MS = 10.5
V_CUT_OUT_MS = 25.0

AIR_DENSITY_STD = 1.225   # Standard atmosphere (+15 °C)
AIR_DENSITY_ARCTIC = 1.35 # Extreme Arctic (-60 °C, 1.35x denser)
CP_MAX = 0.44             # Aerodynamic rotor efficiency coefficient
ETA_DRIVE = 0.93          # PMSG and AFE power electronics efficiency

def weibull_pdf(v, k, c):
    """Weibull probability density function."""
    if v < 0:
        return 0.0
    return (k / c) * ((v / c) ** (k - 1.0)) * math.exp(-((v / c) ** k))

def wind_power_curve(v, rho):
    """Aerodynamic and electrical power generation at wind speed v and density rho."""
    if v < V_CUT_IN_MS or v > V_CUT_OUT_MS:
        return 0.0
    # Available kinetic power in wind stream
    p_aero_w = 0.5 * rho * SWEPT_AREA_M2 * (v ** 3) * CP_MAX * ETA_DRIVE
    p_elec_kw = p_aero_w / 1000.0
    return min(RATED_POWER_KW, p_elec_kw)

def evaluate_wind_regime(name, v_mean, k, rho):
    """Integrates Weibull distribution over 8760 hours to compute AEP and CF."""
    # Scale parameter c from mean wind and Gamma(1 + 1/k)
    gamma_val = math.gamma(1.0 + 1.0 / k)
    c = v_mean / gamma_val

    annual_hours = 8760.0
    dv = 0.1
    v_max = 35.0
    steps = int(v_max / dv)

    total_energy_kwh = 0.0
    for i in range(steps):
        v = (i + 0.5) * dv
        prob = weibull_pdf(v, k, c) * dv
        p_kw = wind_power_curve(v, rho)
        total_energy_kwh += p_kw * prob * annual_hours

    aep_mwh = total_energy_kwh / 1000.0
    capacity_factor = (total_energy_kwh / (RATED_POWER_KW * annual_hours)) * 100.0
    hours_at_rated = 0.0
    for i in range(steps):
        v = (i + 0.5) * dv
        if v >= V_RATED_MS and v <= V_CUT_OUT_MS:
            hours_at_rated += weibull_pdf(v, k, c) * dv * annual_hours

    return {
        "name": name,
        "v_mean": v_mean,
        "k": k,
        "c": c,
        "rho": rho,
        "aep_mwh": aep_mwh,
        "cf_pct": capacity_factor,
        "hours_rated": hours_at_rated,
    }

def run_resource_analysis():
    print("=" * 78)
    print(" WIND v2.0: ARCTIC WEIBULL WIND RESOURCE SENSITIVITY & AEP AUDIT")
    print(" Tracked under Issue #88 & Parent Issue #82")
    print("=" * 78)

    # Scenarios across representative mean wind regimes
    scenarios = [
        ("Arctic Class III (Low)",     5.0, 2.0, AIR_DENSITY_ARCTIC),
        ("Arctic Class II (Moderate)", 6.5, 2.1, AIR_DENSITY_ARCTIC),
        ("Arctic Class I (High)",      8.0, 2.2, AIR_DENSITY_ARCTIC),
        ("Arctic Class S (Extreme)",   9.5, 2.4, AIR_DENSITY_ARCTIC),
        ("Class II Baseline (Std Air)",6.5, 2.1, AIR_DENSITY_STD),
    ]

    print(f"\n[1] PARAMETRIC ROTOR SPECIFICATIONS:")
    print(f"  • Rotor Diameter: {ROTOR_DIAMETER_M} m | Swept Area: {SWEPT_AREA_M2:.1f} m²")
    print(f"  • Rated Capacity: {RATED_POWER_KW} kW @ {V_RATED_MS} m/s")
    print(f"  • Operational Band: Cut-in {V_CUT_IN_MS} m/s -> Cut-out {V_CUT_OUT_MS} m/s")

    print(f"\n[2] ANNUAL ENERGY PRODUCTION (AEP) & CAPACITY FACTOR MATRIX:")
    print(f"  {'Regime Description':<28} | {'Mean v':<7} | {'Density':<8} | {'AEP (MWh)':<10} | {'Cap Factor':<10} | {'Full-Load Hrs':<12}")
    print("  " + "-" * 76)

    results = []
    for sc in scenarios:
        res = evaluate_wind_regime(sc[0], sc[1], sc[2], sc[3])
        results.append(res)
        print(f"  {res['name']:<28} | {res['v_mean']:>5.1f} m/s | {res['rho']:>4.2f} kg/m³ | {res['aep_mwh']:>8.1f} MWh | {res['cf_pct']:>8.1f} % | {res['hours_rated']:>8.0f} hrs")

    # Cold air density gain comparison
    aep_arctic = results[1]["aep_mwh"]
    aep_std = results[4]["aep_mwh"]
    cold_air_delta_pct = ((aep_arctic - aep_std) / aep_std) * 100.0

    print(f"\n[3] COLD-AIR DENSITY BENEFIT AUDIT (-60 °C vs +15 °C Standard):")
    print(f"  • Standard Air Density AEP (6.5 m/s) : {aep_std:.1f} MWh/yr (CF: {results[4]['cf_pct']:.1f}%)")
    print(f"  • Arctic Dense Air AEP (6.5 m/s)     : {aep_arctic:.1f} MWh/yr (CF: {results[1]['cf_pct']:.1f}%)")
    print(f"  • Net Arctic Energy Gain (+10.2% rho): +{cold_air_delta_pct:.1f} % annual energy bonus")

    print(f"\n[4] MEAN WIND SENSITIVITY DISCLOSURE:")
    print(f"  • A 5.0 m/s site generates {results[0]['aep_mwh']:.1f} MWh/yr (CF: {results[0]['cf_pct']:.1f}%)")
    print(f"  • An 8.0 m/s site generates {results[2]['aep_mwh']:.1f} MWh/yr (CF: {results[2]['cf_pct']:.1f}%)")
    print(f"  • Ratio (8.0 m/s vs 5.0 m/s)        : {results[2]['aep_mwh'] / results[0]['aep_mwh']:.2f}× energy yield")

    # Assertions
    assert results[1]["cf_pct"] >= 20.0, f"Expected Class II CF >= 20%, got {results[1]['cf_pct']}%"
    assert results[2]["aep_mwh"] > results[0]["aep_mwh"], "Energy yield must scale monotonically with mean wind"
    assert cold_air_delta_pct > 0.0, "Cold air density must provide positive net energy gain below rated"

    print("\n[5] VERIFICATION RESULT: PASS (All Weibull wind resource and AEP assertions satisfied)")
    print("=" * 78)
    return True

if __name__ == "__main__":
    if not run_resource_analysis():
        sys.exit(1)
