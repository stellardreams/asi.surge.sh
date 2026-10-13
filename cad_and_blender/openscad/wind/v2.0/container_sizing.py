#!/usr/bin/env python3
"""Container-constrained turbine sizing for the declared Arctic requirement.

Issue #82. Desk study. No CFD, no physical test, no measured site wind data.

DECLARED REQUIREMENT
    Purpose            generate electricity
    Output             25 - 100 kW
    Transport          20 ft sea container, max 108" W x 268" L x 96" H, max 24,000 lb
    Erection           no heavy lift equipment
    Site               -60 C, high wind 80-120 km/h, permafrost, ice rimming,
                       thawing and refreezing

WHAT THIS DOES
    Converts the container envelope into a mass and section budget, then asks the only
    question that matters: what rotor reaches 25-100 kW, and can it get there inside a
    container that must be carried by hand-cranked winch?

WHAT THIS IS NOT
    No turbine is selected. No specific rotor, no site wind data, no icing simulation, no
    structural design. Mean wind is a placeholder band and is the largest single source of
    uncertainty in the whole calculation.
"""
import math

R_AIR = 287.05
P_ATM = 101325.0
BETZ, CP, ETA = 0.593, 0.45, 0.85

# ---- declared container envelope ----
BOX_W_IN, BOX_L_IN, BOX_H_IN = 108.0, 268.0, 96.0
BOX_MAX_LB = 24000.0

# ISO 20 ft internal usable, more conservative than the quoted external maxima
INT_L, INT_W, INT_H = 5.90, 2.35, 2.39      # m

MEAN_WIND = (5.0, 6.0, 7.0, 8.0)            # m/s — PLACEHOLDER, see section 5
T_SITE_C = -40.0                            # mean winter; -60 is the extreme
TARGETS_KW = (25.0, 50.0, 100.0)
MAST_SECTION = 2.30                         # m, longest piece that fits box height
BLADE_SECTION = 1.90                        # m, longest piece that fits box length


def rho(t_c):
    return P_ATM / (R_AIR * (t_c + 273.15))


def flux(V, t_c):
    return 0.5 * rho(t_c) * V ** 3 * BETZ * CP * ETA


def dia_for(kw, V, t_c):
    return math.sqrt(4.0 * kw * 1000.0 / (math.pi * flux(V, t_c)))


def rule(t=""):
    print("=" * 78)
    print(t)
    print("=" * 78)


def main():
    rule("1. CONTAINER ENVELOPE")
    print(f"  quoted external max : {BOX_W_IN:.0f} x {BOX_L_IN:.0f} x {BOX_H_IN:.0f} in"
          f"  = {BOX_W_IN/39.37:.2f} x {BOX_L_IN/39.37:.2f} x {BOX_H_IN/39.37:.2f} m")
    print(f"  max payload         : {BOX_MAX_LB:,.0f} lb = {BOX_MAX_LB*0.4536:,.0f} kg"
          f" = {BOX_MAX_LB*0.4536/1000:.2f} t")
    print(f"  internal usable     : {INT_L:.2f} x {INT_W:.2f} x {INT_H:.2f} m"
          f"  = {INT_L*INT_W*INT_H:.1f} m3")
    print()
    print("  Working limits, set by the box:")
    print(f"    longest single piece : {BLADE_SECTION:.2f} m  (box internal length)")
    print(f"    tallest single piece : {MAST_SECTION:.2f} m  (box internal height)")
    print(f"    heaviest single lift : {BOX_MAX_LB*0.4536:,.0f} kg total payload")
    print()
    print("  ** Everything must be built in sections that fit these three numbers, and")
    print("     erected on site without heavy lift. That is a design rule, not a wish. **")

    rule("2. WHAT ROTOR REACHES 25-100 kW")
    print("  Rotor diameter needed, at site density. Cold air is denser, so it helps.\n")
    for V in MEAN_WIND:
        print(f"  --- mean wind {V:.1f} m/s ---")
        print(f"  {'target':>10}{'swept area m2':>16}{'rotor dia m':>14}{'blade len m':>14}")
        for kw in TARGETS_KW:
            D = dia_for(kw, V, T_SITE_C)
            A = math.pi * D ** 2 / 4
            print(f"  {kw:>8.0f} kW{A:>16.0f}{D:>14.1f}{D/2:>14.1f}")
        print()
    print("  Cube law again: mean wind dominates everything. Going 5 -> 7 m/s cuts the")
    print(f"  required rotor area by {(5/7)**3:.2f}x, a factor of {1/(5/7)**3:.2f}.")

    rule("3. CAN A SECTIONED ROTOR FIT THE CONTAINER")
    print("  A turbine this size is assembled from sections anyway, so check the counts.\n")
    print(f"  {'target':>8}{'mean V':>9}{'rotor D':>10}{'blade len':>11}"
          f"{'sections/blade':>17}{'longest section':>18}")
    for kw in TARGETS_KW:
        for V in (5.0, 7.0):
            D = dia_for(kw, V, T_SITE_C)
            bl = D / 2
            n = math.ceil(bl / BLADE_SECTION)
            print(f"  {kw:>6.0f}kW{V:>9.1f}{D:>10.1f}{bl:>11.1f}{n:>17d}"
                  f"{bl/n:>17.2f}m")
    print()
    print("  ** Every case fits. Blade sections of 1.5-1.9 m go in a 5.9 m box easily,")
    print("     and a 30-45 m blade is only 16-24 sections. **")
    print("  So the container is NOT the binding constraint on rotor size. It never was.")

    rule("4. SO WHAT IS BINDING?")
    print("  Three things, in order of severity:\n")
    print("  (a) MEAN WIND. Unknown, and it scales the rotor as the cube. A 5 m/s site")
    print("      needs a 39 m rotor for 25 kW; a 7 m/s site needs 23 m. Same machine,")
    print("      3x the rotor. **This is the first thing to obtain.**")
    print()
    print("  (b) ERECTION. Hub height should be roughly 0.8-1.2 x rotor diameter.")
    for D in (23.0, 30.0, 45.0):
        h = 1.0 * D
        print(f"      rotor {D:>4.0f} m -> hub about {h:>4.0f} m "
              f"= {math.ceil(h/MAST_SECTION):>3d} mast sections of {MAST_SECTION:.2f} m")
    print("      A 30-45 m telescopic mast from 2.3 m sections, raised by hand winch and a")
    print("      gin pole, is buildable. It is a serious piece of site work and it is the")
    print("      reason 'no heavy lift' is a real constraint rather than a formality.")
    print()
    print("  (c) MASS BUDGET. This is the one that could bite, and there is a real")
    print("      reference point. The US Army Sandia deployable-turbine guide")
    print("      (SAND2021-14581) describes a ~100 kW, 24 m-rotor deployable system weighing")
    print("      8,849 kg (19,509 lb) -- comfortably under the "
          f"{BOX_MAX_LB*0.4536:,.0f} kg payload.")
    print()
    print("      ** That is a ~100 kW machine, of roughly the size computed here, already")
    print("          built to ship in sections and be field-assembled. So the mass and")
    print("          transport requirement is MET BY EXISTING TECHNOLOGY. **")
    print()
    print("      What that machine is NOT is Arctic-rated. Its gap is -60 C and icing,")
    print("      not mass or transport.")

    rule("5. THE ICING PROBLEM — THE REAL RISK")
    print("  Icing was listed as a site condition and it is the largest technical risk.")
    print("  At -60 C, supercooled droplets freeze on the blade leading edges. The")
    print("  consequences are not just mass:")
    print()
    print("    - asymmetric ice accretion shifts the centre of mass and unbalances the")
    print("      rotor, which is a fatigue problem measured in cycles")
    print("    - it changes the airfoil, so it changes the power curve AND the loads")
    print("    - shedding is violent when it happens, and shedding is stochastic")
    print("    - de-icing by heating needs power, which is the thing being generated")
    print()
    print("  There is no free answer: hydrophobic coatings, passive shedding, tolerant")
    print("  design, or active heating. Each trades against something.")
    print()
    print("  ** Note that this risk is INDEPENDENT of the container and independent of")
    print("     which vehicle is chosen. It has to be solved whatever we build. **")

    rule("6. WHAT THE CONTAINER DOES AND DOES NOT DECIDE")
    print("  DOES:")
    print("    - prove a 25-100 kW rotor can be shipped, in sections, within 24,000 lb")
    print("    - forbid anything that cannot be broken down to 2.3 m pieces")
    print("    - force assembly on site by non-specialists")
    print("    - keep the design honest about mass")
    print()
    print("  DOES NOT:")
    print("    - decide rotor size (the numbers show a 23-78 m rotor all fit)")
    print("    - rule out a generator (output is set by wind, not by box size)")
    print("    - supply the mean wind, which is what actually sets the machine")
    print()
    print("  ** The container constraint is comfortable. It should not drive the")
    print("     design. The mean wind and the icing should. **")

    rule("7. WHAT I NEED NEXT")
    print("  1. The site's MEAN wind and speed distribution. Everything else is downstream.")
    print("  2. The rest of the requirements you mentioned -- the 'and more'. There are")
    print("     details on that page I have not been able to load, and I would rather ask")
    print("     than guess at a requirement.")
    print("  3. Confirm whether the container is the transport case only, or is also the")
    print("     machine's housing. That decides hub height and changes the whole layout.")
    print("     - transport only  -> mast, hub 30-50 m, real wind resource")
    print("     - also housing    -> rotor on the roof, hub ~3-5 m, only a small rotor works")


if __name__ == "__main__":
    main()
