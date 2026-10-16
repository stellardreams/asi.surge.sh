"""
wind_farm_fleet_sizing_audit.py -- Engineering Sizing & Ratio Audit for Arctic Macro-Grid Wind Farm

Analyzes logistics, cycle times, and operational balance ratios to erect a 100+ unit (5.0+ MW)
distributed modular wind turbine farm across polar permafrost.
"""

def compute_fleet_sizing(num_turbines=100, turbine_kw=50, season_days=60, shift_hrs_per_day=12):
    total_power_mw = (num_turbines * turbine_kw) / 1000.0
    total_work_hrs = season_days * shift_hrs_per_day # e.g. 720 hours in polar summer window

    # Cycle breakdown per turbine (hours):
    t_pad_survey    = 1.0  # Site grade check, anchor marking, outrigger level
    t_convoy_haul   = 2.5  # Hauler transit time from AMU staging hub to pad (round trip)
    t_blade_unpack  = 1.2  # Unlatching 20 ft ISO bay, extracting 3 blade modules
    t_hub_pinning   = 1.5  # CORA-M root bolt circle alignment, shear pin torquing
    t_mast_tilt     = 0.8  # Gin-pole winch hoisting, damper check, stay-line lock
    t_commission    = 1.0  # Cabling tie-in, microgrid bus sync, inverter check

    total_erection_hrs_per_turbine = t_pad_survey + t_blade_unpack + t_hub_pinning + t_mast_tilt + t_commission
    # Total machine hours on site per turbine = 5.5 hours (crane/surveyor)
    # Haulage machine hours per turbine = 2.5 hours

    total_crane_hrs = num_turbines * (t_blade_unpack + t_hub_pinning + t_mast_tilt) # 3.5 hrs * 100 = 350 hrs
    total_haul_hrs  = num_turbines * t_convoy_haul                                   # 2.5 hrs * 100 = 250 hrs
    total_surv_hrs  = num_turbines * (t_pad_survey + t_commission)                   # 2.0 hrs * 100 = 200 hrs

    # Sizing fleet with 1.4x Arctic contingency factor (blizzards, whiteouts, 30% maintenance downtime):
    contingency = 1.40
    avail_hrs = total_work_hrs / contingency # 514 effective working hours

    min_erector_rovers  = -(-total_crane_hrs // avail_hrs) # ceil division
    min_hauler_rovers   = -(-total_haul_hrs // avail_hrs)
    min_surveyor_rovers = -(-total_surv_hrs // avail_hrs)

    # Balanced Fleet Composition:
    # We round to complete operational task forces (e.g. 4 sectors/quadrants):
    quadrants = 4
    erector_per_quad  = 2  # 1 active + 1 parallel/contingency
    hauler_per_quad   = 3  # 2 active convoy shuttles + 1 loading at hub
    surveyor_per_quad = 1  # 1 mobile site prep & bus tie-in scout

    total_erectors  = quadrants * erector_per_quad  # 8 rovers with CORA-M
    total_haulers   = quadrants * hauler_per_quad   # 12 rovers with Cargo Sleds
    total_surveyors = quadrants * surveyor_per_quad # 4 scout rovers
    total_striders  = total_erectors + total_haulers + total_surveyors # 24 rovers

    # Habitat / Base Station:
    # 1 Central Command Quad-AMU Superhub (or 4 perimeter AMU shelter modules)
    total_amus = 4
    total_cora_arms = total_erectors + 2 # 8 in field + 2 depot/gantry spares = 10 arms

    # Ratios:
    ratio_turb_to_strider = num_turbines / total_striders
    ratio_turb_to_amu     = num_turbines / total_amus
    ratio_turb_to_cora    = num_turbines / total_cora_arms
    ratio_strider_to_amu  = total_striders / total_amus

    return {
        "num_turbines": num_turbines,
        "total_power_mw": total_power_mw,
        "total_amus": total_amus,
        "total_striders": total_striders,
        "total_cora_arms": total_cora_arms,
        "erectors": total_erectors,
        "haulers": total_haulers,
        "surveyors": total_surveyors,
        "ratio_turb_to_strider": ratio_turb_to_strider,
        "ratio_turb_to_amu": ratio_turb_to_amu,
        "ratio_turb_to_cora": ratio_turb_to_cora,
        "ratio_strider_to_amu": ratio_strider_to_amu,
        "completion_days": (total_crane_hrs * contingency) / (total_erectors * shift_hrs_per_day)
    }

if __name__ == "__main__":
    res = compute_fleet_sizing(100)
    print("=" * 65)
    print(f"ARCTIC WIND FARM FLEET SIZING AUDIT (100+ TURBINES / {res['total_power_mw']} MW)")
    print("=" * 65)
    print(f"Turbine Target:           {res['num_turbines']} units (50 kW each)")
    print(f"Operational Window:       60 days (1 summer polar campaign)")
    print("-" * 65)
    print("OPTIMAL FLEET ALLOCATION:")
    print(f"  • AMU-Surface Hubs:     {res['total_amus']} modules (1 Quad-Superhub or 4 Quadrant Outposts)")
    print(f"  • STRIDER-M Rovers:     {res['total_striders']} rovers total:")
    print(f"      - Erector/Crane:     {res['erectors']} units (with CORA-M mounted)")
    print(f"      - Logistics Haulers: {res['haulers']} units (with Heavy Cargo Sleds)")
    print(f"      - Surveyors/Scouts:  {res['surveyors']} units (with LiDAR & cable tensioners)")
    print(f"  • CORA-M Manipulators:  {res['total_cora_arms']} arms (8 field erectors + 2 depot spares)")
    print("-" * 65)
    print("EQUIPMENT RATIOS:")
    print(f"  • 1 AMU Hub      : {res['ratio_turb_to_amu']:.1f} Turbines")
    print(f"  • 1 STRIDER Rover: {res['ratio_turb_to_strider']:.1f} Turbines (~4.2 turbines / rover)")
    print(f"  • 1 CORA-M Arm   : {res['ratio_turb_to_cora']:.1f} Turbines (10 turbines / arm)")
    print(f"  • 1 AMU Hub      : {res['ratio_strider_to_amu']:.1f} STRIDER Rovers (6 rovers / hub)")
    print("-" * 65)
    print(f"Estimated Campaign Duration: {res['completion_days']:.1f} days (well within 60-day window)")
    print("=" * 65)
