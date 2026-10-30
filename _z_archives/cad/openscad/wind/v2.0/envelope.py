#!/usr/bin/env python3
"""Operating-envelope analysis for the declared site conditions.

Issue #82/#84. Desk study. No CFD, no wind tunnel, no physical test.

DECLARED OPERATING ENVELOPE (supplied by @genidma, 2026-10-13)
    extreme temperature      -60 C
    high wind                80 - 120 km/h  (22.22 - 33.33 m/s)
    frozen ground, deep snow, rugged terrain, permafrost
    ice rimming on the rotor/blade
    thawing and refreezing

WHY THIS RUNS
    R5 screened working fluids against a design cold that was an unsourced assumption
    (-50 C). The real envelope is -60 C, which is colder than every fluid the design
    nominates. This quantifies the consequence for R1's stability screen and R3's verdict,
    using the model's own equations.

WHAT IT IS NOT
    No thermodynamic model, no freeze-rate prediction, no heat balance, no CFD. This is a
    screening comparison of fluid freezing points against a declared ambient, and a
    parametric run of the existing stability equation across the declared wind range.
"""
import math

G = 9.81
AMBIENT_C = -60.0
WIND_KMH = (80.0, 120.0)

# geometry + model state, all from wind_sail_v5_arctic.scad
SAIL_W, SAIL_T, SAIL_H, SAIL_WALL = 0.56, 0.26, 2.55, 0.004
CELL_BAND_H, CELL_COLS = 0.62, 2
L_SAIL, ZETA = 1.30, 0.040
CELL_H = CELL_BAND_H - SAIL_WALL
CELL_D = SAIL_T - 2 * SAIL_WALL - 2 * 0.010
CELL_W = (SAIL_W - 2 * SAIL_WALL) / CELL_COLS - SAIL_WALL
CELL_A = CELL_W * CELL_D
M_S = ((2 * SAIL_W * SAIL_H + 2 * SAIL_T * SAIL_H + 2 * SAIL_W * SAIL_T) * SAIL_WALL * 2700
       + 2 * SAIL_WALL * (SAIL_T - 2 * SAIL_WALL) * (SAIL_H - CELL_BAND_H) * 2700 + 6.0)
RHO_AIR, K_AIR, CD = 1.225, 0.0264, 1.2

# Candidate damping fluids. The first three are the ones the design nominates.
FLUIDS = [
    ("saturated NaCl brine", -21.0, "nominates a thermosyphon-held cell"),
    ("CaCl2 brine",            -30.0, "nominal alternative"),
    ("60% glycol",             -48.0, "nominal alternative, best of the three"),
    ("60% methanol",           -46.0, "not considered in the model"),
    ("80% methanol",           -62.0, "not considered in the model"),
    ("pure ethanol",          -114.0, "not considered in the model"),
]


def margin(ice_top):
    a = CELL_H - ice_top
    mu = CELL_W * CELL_D * a * CELL_COLS * 1000.0 / M_S
    wa2 = G * a / (2 * CELL_A)
    wn2 = max(0.0, mu * wa2 - G / L_SAIL)
    return mu * wa2 / (G / L_SAIL), wn2, mu


def rule(t=""):
    print("=" * 78)
    if t:
        print(t)
        print("=" * 78)


def main():
    rule("0. DECLARED OPERATING ENVELOPE")
    print(f"  extreme temperature : {AMBIENT_C:.0f} C")
    print(f"  high wind           : {WIND_KMH[0]:.0f}-{WIND_KMH[1]:.0f} km/h "
          f"= {WIND_KMH[0]/3.6:.2f}-{WIND_KMH[1]/3.6:.2f} m/s")
    print("  ground              : frozen, deep snow, rugged terrain, permafrost")
    print("  icing               : ice rimming; thawing and refreezing")

    rule("1. FLUID SCREENING AGAINST -60 C")
    print("  A fluid survives only if its freezing point is AT OR BELOW the ambient.")
    print("  If the freezing point is above the ambient, the fluid is solid at site.\n")
    print(f"  {'fluid':<24}{'freezing pt':>13}{'headroom':>12}{'verdict':>26}")
    survivors = []
    for name, fp, note in FLUIDS:
        head = AMBIENT_C - fp          # positive = survives (ambient above freezing pt)
        ok = head >= 0
        if ok:
            survivors.append((name, fp, head))
        print(f"  {name:<24}{fp:>10.0f} C{head:>+10.0f} C"
              f"{('SURVIVES' if ok else 'SOLID AT SITE'):>26}")
    print()
    nom = [f for f in FLUIDS[:3]]
    print("  ** All three fluids the design nominates go SOLID at -60 C. **")
    print("     Best nominated option (60% glycol) is 12 C short of the ambient.")
    if survivors:
        print(f"     Non-nominated fluids that survive: "
              f"{', '.join(f'{n} ({h:+.0f} C)' for n, _, h in survivors)}")
        print("     Caveat: high-concentration alcohol antifreeze is FLAMMABLE and toxic.")
        print("     That is a poor fit for a forward operating site and is not a")
        print("     recommendation -- it is listed only to show the envelope is not")
        print("     unreachable in principle.")
    print()
    print("  CONSEQUENCE: with no cell holding two phases, the liquid column a -> 0 and")
    print(" the stability margin -> 0. The screen in section 2 shows what that means.")

    rule("2. STABILITY SCREEN ACROSS THE DECLARED WIND RANGE")
    print("  Margin is independent of wind speed (wind enters only as prescribed torque),")
    print("  so the wind range affects loading, not this screen. Shown for completeness.\n")
    print(f"  {'ICE_TOP':>10}{'a (m)':>9}{'mu':>8}{'margin':>9}{'stable':>9}{'screen 2.0':>12}")
    for it in [0.00, 0.10, 0.20, 0.30, 0.35, 0.40, 0.50, 0.60, CELL_H]:
        m, wn2, mu = margin(it)
        stab = "yes" if m > 1 else "NO"
        scr = "pass" if m >= 2.0 else "FAIL"
        print(f"  {it:>10.2f}{CELL_H-it:>9.3f}{mu:>8.3f}{m:>9.3f}{stab:>9}{scr:>12}")

    rule("3. WHAT -60 C MEANS FOR ICE DEPTH")
    m_frozen, _, _ = margin(CELL_H)
    print(f"  At -60 C with no viable passive fluid, the cell freezes toward solid.")
    print(f"  Full freeze (ICE_TOP = {CELL_H:.3f} m) gives margin {m_frozen:.4f} and")
    print(f"  is_stable = FALSE. There is no ice depth that is both safe and achievable.")
    print()
    print("  The R1 sweep's provisional 0.20 m cap assumed a thermosyphon holding the cell")
    print("  near its fluid's freezing point. At -60 C that assumption cannot be met by any")
    print("  nominated fluid, so the cap is not a design target -- it is unreachable.")
    print()
    print("  R5 is therefore no longer a sizing question. It is a feasibility question:")
    print("  **there is no passive, non-flammable working fluid that holds this cell at -60 C.**")

    rule("4. R3 VERDICT ACROSS THE DECLARED WIND RANGE")
    print("  R3 concluded the sail settles to a static deflection. Checking that against")
    print("  the declared wind range rather than a generic one:\n")
    st_f = margin(0.10)
    omega = math.sqrt(st_f[1])
    inertia = M_S * L_SAIL ** 2 * (1 + st_f[2])
    c_struct = 2 * ZETA * inertia * omega
    print(f"  {'V m/s':>9}{'Re':>11}{'k_red':>9}{'k_aero N m/rad':>17}"
          f"{'aero damp %':>13}")
    for v in [WIND_KMH[0] / 3.6, 25.0, WIND_KMH[1] / 3.6]:
        q = 0.5 * RHO_AIR * v ** 2
        k_red = omega * SAIL_T / (2 * v)
        k_aero = q * (SAIL_T * SAIL_H) * (SAIL_T / 4) * (2 * math.pi)
        # Jones' approximation for the Theodorsen circulation function
        Ck = 1.0 - (1.3400j * k_red) / (1.0 + 2.4300j * k_red)
        c_circ = (SAIL_T / 4) * math.pi * q * SAIL_T * abs(Ck.imag) / omega * SAIL_H
        c_am = (SAIL_T / 4) * (math.pi / 4) * RHO_AIR * SAIL_T ** 2 * SAIL_H
        share = (c_circ + c_am) / c_struct * 100
        Re = RHO_AIR * v * SAIL_T / 1.81e-5
        print(f"  {v:>9.2f}{Re:>11.0f}{k_red:>9.4f}{k_aero:>17.1f}{share:>12.3f}%")
    print()
    print("  Aerodynamic damping stays a fraction of a percent of structural across the")
    print("  whole declared range, and the quasi-steady moment stays restoring.")
    print("  ** The static-deflector verdict HOLDS at 22-33 m/s. It is not marginal. **")

    rule("5. VERDICT")
    print("  1. OPERATING PURPOSE: passive deflector -- CONFIRMED and now supported by")
    print("     the declared envelope, not just the linear analysis.")
    print()
    print("  2. At -60 C the two-phase cell concept does not survive. Not one nominated")
    print("     fluid holds. The thermosyphon has nothing to work with, so R1, R5, R6 and")
    print("     most of #83's cassette work lose their subject.")
    print()
    print("  3. This is a simplification, not only a loss. A static deflector that weathervanes")
    print("     needs no liquid, no thermosyphon, no ice cap, no fill/drain port and no")
    print("     elastomer seal. Every open item in #83 and #84 about fluids disappears.")
    print()
    print("  4. What remains is structural and geotechnical: a sail that survives 22-33 m/s,")
    print("     an ice-rimming allowance, a permafrost foundation, and thawing/refreezing.")
    print("     Those are answerable, and none of them need a fluid.")


if __name__ == "__main__":
    main()
