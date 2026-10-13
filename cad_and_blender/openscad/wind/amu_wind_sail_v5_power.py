#!/usr/bin/env python3
"""Power-resource screening for the declared Arctic site.

Issue #82. Desk study. No CFD, no physical test, no measured wind data.

WHY THIS EXISTS
    The operating purpose is a fork: passive deflector, or electricity. The sail model
    supports the first and not the second -- its own analysis shows the sail settles to a
    static deflection, so it cannot sustain motion to harvest.

    If the goal is electricity, the useful next number is not a refinement of the sail. It
    is: what can the wind resource at this site actually deliver, and how big does a
    conventional rotor have to be to reach a given output?

    That framing also exposes a gap in the declared envelope. It gives HIGH wind
    (80-120 km/h) but no MEAN wind and no speed distribution, and a power estimate is
    almost entirely a statement about the mean.

WHAT THIS IS NOT
    This is a resource screen, not a design. It uses idealised air density, the Betz limit
    and a generic Cp. It does not model a specific turbine, does not account for wake,
    roughness, turbulence, extreme-value loading, availability, or balance-of-plant losses.
"""
import math

P_ATM = 101325.0      # Pa
R_AIR = 287.05        # J/kg K
RHO_REF = 1.225       # kg/m^3 at 15 C, 101325 Pa (matches the .scad)
BETZ = 0.593
CP = 0.45             # generic capacity factor at Cp_max
ETA = 0.85            # drivetrain + generator + general losses
T_REF_C = 15.0

# declared envelope (high wind) -- provenance deliberately not recorded
WIND_HIGH_KMH = (80.0, 120.0)

# Arctic mean-wind band at 10 m for exposed northern sites. PLACEHOLDER -- see section 4.
MEAN_WIND_BAND = (4.0, 5.0, 6.0, 7.0, 8.0)

TARGETS_KW = (10.0, 100.0, 500.0)


def rule(t=""):
    print("=" * 78)
    print(t)
    print("=" * 78)


def rho(temp_c):
    return P_ATM / (R_AIR * (temp_c + 273.15))


def power_flux(V, temp_c):
    """Available kinetic power per unit swept area, W/m^2."""
    return 0.5 * rho(temp_c) * V ** 3


def useful_flux(V, temp_c):
    """Betz-limited and drivetrain-reduced power per unit swept area."""
    return power_flux(V, temp_c) * BETZ * CP * ETA


def rotor_area_for(target_kw, V, temp_c):
    return target_kw * 1000.0 / useful_flux(V, temp_c)


def dia(area):
    return math.sqrt(4.0 * area / math.pi)


def main():
    rule("0. DECLARED ENVELOPE (as given)")
    print(f"  high wind      : {WIND_HIGH_KMH[0]:.0f}-{WIND_HIGH_KMH[1]:.0f} km/h "
          f"= {WIND_HIGH_KMH[0]/3.6:.2f}-{WIND_HIGH_KMH[1]/3.6:.2f} m/s")
    print(f"  extreme cold   : -60 C")
    print(f"  also           : permafrost, ice rimming, deep snow, rugged terrain,")
    print(f"                   thawing and refreezing")
    print()
    print("  ** The envelope gives HIGH wind. It gives no MEAN wind and no speed")
    print("     distribution. A power estimate is almost entirely about the mean. **")

    rule("1. COLD AIR IS DENSER -- A REAL ARCTIC ADVANTAGE")
    print("  rho = p / (R T). Colder air is denser, and power scales with rho.")
    print()
    print(f"  {'temp':>10}{'rho kg/m3':>13}{'vs 15 C':>11}{'flux at 6 m/s':>17}")
    for t in [15, 0, -20, -40, -60, -70]:
        r = rho(t)
        f = power_flux(6.0, t)
        print(f"  {t:>8.0f} C{r:>13.3f}{r/RHO_REF:>10.2f}x{f:>16.0f}")
    print()
    print(f"  At -60 C the air is {rho(-60)/RHO_REF:.2f}x denser than at 15 C, so the same")
    print(f"  rotor makes {rho(-60)/RHO_REF:.2f}x the power. ** This is a genuine benefit")
    print(f"  and it partly offsets the icing penalty. Note it also means the sail's")
    print(f"  aerodynamic loads rise by the same factor -- {rho(-60)/RHO_REF:.2f}x.")

    rule("2. WHAT THE WIND RESOURCE DELIVERS")
    print("  Useful flux = 0.5 rho V^3 x Betz x Cp x eta")
    print(f"  (rho at -40 C = {rho(-40):.3f}, Betz = {BETZ}, Cp = {CP}, eta = {ETA})")
    print()
    print(f"  {'mean V m/s':>12}{'power flux':>14}{'useful flux':>15}")
    for V in MEAN_WIND_BAND:
        print(f"  {V:>12.1f}{power_flux(V,-40):>14.0f}{useful_flux(V,-40):>15.0f}")
    print("     (W per m^2 of swept area)")

    rule("3. ROTOR SIZE FOR TARGET OUTPUTS")
    print("  Rotor swept area, then diameter, needed to reach each target.")
    print("  Cold air used (rho at -40 C). These are IDEAL figures with no losses")
    print("  beyond the generic eta, and no availability derating.\n")
    for V in [5.0, 6.0, 7.0]:
        print(f"  --- mean wind {V:.1f} m/s ---")
        print(f"  {'target':>10}{'swept area m2':>16}{'rotor diameter m':>19}")
        for t in TARGETS_KW:
            a = rotor_area_for(t, V, -40)
            print(f"  {t:>8.0f} kW{a:>16.1f}{dia(a):>18.1f}")
        print()
    print("  The cube law dominates: at low mean wind a small target still needs a large")
    print("  rotor, and that is the central difficulty of Arctic wind. Going from 5 to")
    print("  7 m/s mean cuts the swept area needed for a fixed output by about (5/7)^3")
    print(f"  = {(5/7)**3:.2f}x -- a factor of {1/(5/7)**3:.2f}.")

    rule("4. THE GAP THAT MATTERS MOST")
    print("  The mean-wind figures above are a PLACEHOLDER band for exposed northern sites.")
    print("  They are not measured data for the chosen site, and they are not even a")
    print("  citation. Before any of this is a design input:")
    print()
    print("    - a MEAN wind speed and speed distribution for the site are required")
    print("    - mean wind is typically 4-8 m/s where high wind is 80-120 km/h")
    print("    - the ratio between them at a site is large and site-specific")
    print("    - availability, icing loss and extreme-value loading all reduce the")
    print("      achievable figure further")
    print()
    f25 = useful_flux(25.0, -40)
    f5 = useful_flux(5.0, -40)
    print(f"  ** Sizing against the HIGH wind overstates the output by {f25/f5:.0f}x -- just over")
    print(f"     two orders of magnitude ({f25:.0f} vs {f5:.0f} W/m2). The high-wind figure sets")
    print(f"     the STRUCTURAL load case; the mean sets the ENERGY. Different numbers,")
    print(f"     different jobs. **")

    rule("4b. THE CONFLICT NOBODY HAS RESOLVED -- MODULARITY vs OUTPUT")
    print("  The envelope carries a hard constraint that cuts against the power target:")
    print("  the unit must be modular and transportable by air, ship or ice road, and")
    print("  assembleable without specialist tools. That caps rotor diameter far below")
    print("  what useful output needs at Arctic mean wind.\n")
    print(f"  {'rotor dia m':>13}{'area m2':>10}", end="")
    for V in [5.0, 6.0, 7.0]:
        print(f"{'@'+str(int(V))+' m/s':>12}", end="")
    print()
    for D in [3.0, 4.0, 5.0, 6.0, 7.0, 10.0]:
        a = math.pi * D ** 2 / 4
        print(f"  {D:>13.1f}{a:>10.1f}", end="")
        for V in [5.0, 6.0, 7.0]:
            print(f"{a*useful_flux(V,-40)/1000:>11.2f}kW", end="")
        print()
    print("\n  A rotor that will actually fly and go on an ice road is in the 3-7 m class.")
    print("  At that size the realistic output is **sub-kilowatt to about 1 kW**, against a")
    print("  target output that is orders of magnitude larger.\n")
    print("  ** This is the real conflict, and it is not a sail problem or a turbine")
    print("     problem -- it is an envelope problem. Either the target output drops to")
    print("     roughly a kilowatt, or the mean wind is far higher than 5-7 m/s, or the")
    print("     transport constraint softens. All three cannot hold at once. **")
    print()
    print("  This should be resolved BEFORE choosing a vehicle. It decides whether the")
    print("  question is worth a generator at all.")

    rule("5. THE SAIL'S CONTRIBUTION TO THIS")
    print("  Zero. The sail's own analysis shows aerodynamic damping at 0.33%-0.49% of")
    print("  structural across 22-33 m/s, so it settles to a static deflection and has no")
    print("  motion to convert. Adding a generator to it would harvest nothing.")
    print()
    print("  So on electricity the honest position is:")
    print("    - the sail is not a low-wind device to be improved; it is not an energy")
    print("      device at all under this analysis")
    print("    - a conventional small turbine, evaluated against the site's real wind")
    print("      resource and cold-weather requirements, is the instrument that answers")
    print("      the electricity question")

    rule("6. WHAT THIS ADDS TO THE DECISION")
    print("  If the goal is a DEFLECTOR: this document adds nothing to the decision and the")
    print("  sail workstream can close. It is recorded here so the electricity option is")
    print("  visibly costed rather than quietly dropped.")
    print()
    print("  If the goal is ELECTRICITY: the pivot is larger than the sail. It is not")
    print("  'close the fluid items and carry on' -- it is 'the sail is the wrong")
    print("  vehicle, evaluate a small wind turbine for this site instead'. The design")
    print("  requirements that carry over are the site envelope, modularity, transport by")
    print("  air/ship/ice road, service access, and assembly without specialist tools.")
    print("  The two-phase cell, thermosyphon, cassette, ice cap and elastomer seal do")
    print("  not carry over at all.")


if __name__ == "__main__":
    main()
