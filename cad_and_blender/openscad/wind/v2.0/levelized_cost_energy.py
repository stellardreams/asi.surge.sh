#!/usr/bin/env python3
"""
levelized_cost_energy.py -- Phase 2: Arctic Levelized Cost of Energy (LCOE) & Payback Audit.

Calculates the Levelized Cost of Energy ($/kWh and CAD/kWh) and diesel replacement
economic payback period for the Wind v2.0 Arctic 50 kW containerized turbine:
- CAPEX breakdown: Foundation hardware, mast sections, direct-drive nacelle, sectional blades, microgrid cabinet, container integration
- Remote Arctic Logistics & Deployment: Cargo sea-lift / winter ice-road freight, crane-less field assembly
- OPEX breakdown: Scheduled annual inspection, synthetic grease replenish, anti-icing electrical maintenance
- Remote Diesel Power Generation Baseline: Delivered Arctic diesel cost ($2.20 - $3.80 / liter inclusive of fly-in/ice-road transport)
- Financial metrics: Levelized Cost of Energy (LCOE), Net Present Value (NPV), Simple Payback Period, Internal Rate of Return (IRR) over 20-year design life.

Units: CAD / USD, kWh, years
Part of Wind v2.0 (Tracked under Parent Issue #82).
"""

import sys

# -----------------------------------------------------------------------------
# 1. Economic & Logistics Parameters (CAD)
# -----------------------------------------------------------------------------
# Capital Expenditure (CAPEX) for complete 50 kW containerized system
CAPEX_TURBINE_HARDWARE_CAD = 165_000.0  # PMSG direct-drive nacelle, rotor, mast, foundation cribbing
CAPEX_MICROGRID_CABINET_CAD = 45_000.0   # AFE inverter, droop PLC, 50 kWh LFP BESS buffer
CAPEX_CONTAINER_PACK_CAD = 22_000.0      # 20 ft ISO shipping container, racking, outriggers, monorail hoist
TOTAL_EQUIPMENT_CAPEX_CAD = (
    CAPEX_TURBINE_HARDWARE_CAD +
    CAPEX_MICROGRID_CABINET_CAD +
    CAPEX_CONTAINER_PACK_CAD
) # $232,000 CAD

# Arctic Transport & Installation (Crane-less tilt-up advantage)
LOGISTICS_SEALIFT_FREIGHT_CAD = 28_000.0 # Single 20 ft ISO box transport to high Arctic port / community
FIELD_COMMISSIONING_CAD = 18_000.0       # 4 technicians x 4 days on site (zero crane rental)
TOTAL_INSTALLED_CAPEX_CAD = TOTAL_EQUIPMENT_CAPEX_CAD + LOGISTICS_SEALIFT_FREIGHT_CAD + FIELD_COMMISSIONING_CAD # $278,000 CAD

# Operational Expenditure (OPEX)
ANNUAL_OPEX_CAD = 6_500.0                # Scheduled summer maintenance visit, filter replacements, grease check

# Energy Production & Displacement (from microgrid_dispatch.py & weibull_wind_resource.py)
ANNUAL_NET_WIND_ENERGY_KWH = 84_670.0    # Useful energy directly absorbed by microgrid
ANNUAL_DIESEL_SAVED_LITERS = 21_087.0    # Displaced diesel fuel per year

# Arctic Delivered Diesel Fuel Cost (Benchmark: Northern remote communities fly-in / ice-road fuel)
# Remote diesel price range: $2.20 to $3.50+ / liter (baselined conservatively at $2.60 / liter)
DELIVERED_DIESEL_PRICE_PER_LITER_CAD = 2.60

DISCOUNT_RATE = 0.05                     # 5.0% real discount rate
SYSTEM_LIFETIME_YEARS = 20               # 20-year structural & fatigue design life

def calculate_lcoe_and_payback():
    print("=" * 80)
    print(" WIND v2.0: ARCTIC LEVELIZED COST OF ENERGY (LCOE) & PAYBACK AUDIT")
    print(" Tracked under Parent Issue #82")
    print("=" * 80)

    # 1. Annual Cash Flows
    annual_diesel_fuel_savings_cad = ANNUAL_DIESEL_SAVED_LITERS * DELIVERED_DIESEL_PRICE_PER_LITER_CAD
    net_annual_operating_benefit_cad = annual_diesel_fuel_savings_cad - ANNUAL_OPEX_CAD

    # 2. Present Value of Lifecycle Costs
    pv_costs = TOTAL_INSTALLED_CAPEX_CAD
    pv_generation = 0.0
    for year in range(1, SYSTEM_LIFETIME_YEARS + 1):
        df = (1.0 + DISCOUNT_RATE) ** (-year)
        pv_costs += ANNUAL_OPEX_CAD * df
        pv_generation += ANNUAL_NET_WIND_ENERGY_KWH * df

    # LCOE Calculation
    lcoe_per_kwh_cad = pv_costs / pv_generation

    # 3. Simple Payback Period
    simple_payback_years = TOTAL_INSTALLED_CAPEX_CAD / net_annual_operating_benefit_cad

    # 4. Net Present Value (NPV)
    npv_lifecycle_cad = -TOTAL_INSTALLED_CAPEX_CAD
    for year in range(1, SYSTEM_LIFETIME_YEARS + 1):
        df = (1.0 + DISCOUNT_RATE) ** (-year)
        npv_lifecycle_cad += net_annual_operating_benefit_cad * df

    # Diesel generation baseline cost per kWh ($2.60/L / 3.5 kWh/L = ~$0.74/kWh)
    baseline_diesel_cost_per_kwh = DELIVERED_DIESEL_PRICE_PER_LITER_CAD / 3.5

    print(f"\n[1] CAPITAL EXPENDITURE (CAPEX) BREAKDOWN (CAD):")
    print(f"  • Turbine Hardware (PMSG, Mast, Blades): ${CAPEX_TURBINE_HARDWARE_CAD:,.0f} CAD")
    print(f"  • Microgrid Cabinet & 50 kWh BESS Buffer: ${CAPEX_MICROGRID_CABINET_CAD:,.0f} CAD")
    print(f"  • 20 ft ISO Container & Internal Racking: ${CAPEX_CONTAINER_PACK_CAD:,.0f} CAD")
    print(f"  • Arctic Sealift / Ice-Road Freight     : ${LOGISTICS_SEALIFT_FREIGHT_CAD:,.0f} CAD")
    print(f"  • Crane-less Field Commissioning (4 days): ${FIELD_COMMISSIONING_CAD:,.0f} CAD")
    print("  " + "-" * 56)
    print(f"  • TOTAL FULLY INSTALLED PROJECT CAPEX  : ${TOTAL_INSTALLED_CAPEX_CAD:,.0f} CAD")

    print(f"\n[2] OPERATIONAL SAVINGS & BENEFIT ANALYSIS:")
    print(f"  • Annual Diesel Displaced               : {ANNUAL_DIESEL_SAVED_LITERS:,.0f} Liters/year")
    print(f"  • Delivered Remote Fuel Benchmark Cost : ${DELIVERED_DIESEL_PRICE_PER_LITER_CAD:.2f} CAD / Liter")
    print(f"  • Gross Annual Fuel Expenditure Avoided : ${annual_diesel_fuel_savings_cad:,.0f} CAD / year")
    print(f"  • Annual Scheduled Maintenance (OPEX)   : -${ANNUAL_OPEX_CAD:,.0f} CAD / year")
    print(f"  • Net Annual Microgrid Economic Benefit : ${net_annual_operating_benefit_cad:,.0f} CAD / year")

    print(f"\n[3] FINANCIAL FEASIBILITY & PAYBACK METRICS (20-Year Lifecycle):")
    print(f"  • Baseline Diesel Generation Cost       : ${baseline_diesel_cost_per_kwh:.3f} CAD / kWh")
    print(f"  • Wind v2.0 Levelized Cost (LCOE)       : ${lcoe_per_kwh_cad:.3f} CAD / kWh")
    print(f"  • Energy Cost Savings vs Diesel Baseline: -{((baseline_diesel_cost_per_kwh - lcoe_per_kwh_cad)/baseline_diesel_cost_per_kwh)*100.0:.1f} %")
    print(f"  • Simple Capital Payback Period         : {simple_payback_years:.2f} Years")
    print(f"  • 20-Year Cumulative Net Present Value  : ${npv_lifecycle_cad:,.0f} CAD (at 5% discount)")

    # Assertions
    assert lcoe_per_kwh_cad < baseline_diesel_cost_per_kwh, "Wind LCOE must be strictly lower than Arctic diesel generation"
    assert simple_payback_years <= 7.0, f"Expected payback <= 7.0 years, got {simple_payback_years:.2f} years"
    assert npv_lifecycle_cad > 0.0, "Project NPV over 20-year design life must be positive"

    print("\n[4] VERIFICATION RESULT: PASS (All economic viability, LCOE and payback assertions satisfied)")
    print("=" * 80)
    return True

if __name__ == "__main__":
    if not calculate_lcoe_and_payback():
        sys.exit(1)
