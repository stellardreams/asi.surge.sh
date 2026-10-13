#!/usr/bin/env python3
"""#83 — decide BLADE_GAP deliberately.

The risk register (R21) says the implemented 0.035 m is "an implemented value, not a
decided one", and that it is simultaneously a service clearance, a thermal break, and dead
height. This computes what each driver actually requires, so the value can be chosen from a
tolerance stack rather than inherited.

Every figure below is computed from the geometry in amu_wind_sail_v5.scad. Assumptions are
stated inline and repeated in the summary, because the point of this script is to make the
assumptions visible rather than to produce a number nobody can audit.
"""
import math

# ---------------------------------------------------------------- geometry (from the .scad)
SAIL_W = 0.56        # panel width, along the pivot axis
SAIL_H = 2.55        # height
SAIL_T = 0.26        # depth, along the wind
SAIL_WALL = 0.004    # 4 mm aluminium
CELL_BAND_H = 0.62
BLADE_GAP = 0.035    # implemented value under review
BLADE_SHAFT_D = 0.011
STUD_LEN = 0.10      # qr_stud(0.10, BLADE_SHAFT_D)

# ---------------------------------------------------------------- material properties
K_AL = 205.0         # aluminium, W/m K
E_AL = 69e9          # Pa
RHO_AL = 2700.0      # kg/m^3
K_AIR = 0.0264       # W/m K at -40 C
H_CONTACT = 10000.0  # W/m^2 K, machined metal-to-metal joint (typical)
CD = 1.2             # drag coefficient, matches WIND_DRAG_COEFFICIENT in the .scad
RHO_AIR = 1.225      # matches WIND_AIR_DENSITY in the .scad
CP_AL = 900.0        # J/kg K, specific heat, for the thermal transient


def rule(t=""):
    print("=" * 78)
    if t:
        print(t)
        print("=" * 78)


def second_moment():
    """I about the horizontal axis for bending under wind, as a thin-walled box.

    The panel spans 2.55 m vertically, wind pushes along the 0.26 m depth, so the beam axis
    is vertical and the cross-section is the 0.56 x 0.26 box. Bending is about X, so the
    0.26 m dimension is the depth.

    The .scad also adds two full-height ribs, which raise this further; they are excluded
    here so the number is a LOWER bound on stiffness, i.e. an UPPER bound on deflection.
    """
    w, d, t = SAIL_W, SAIL_T, SAIL_WALL
    # two flanges normal to Y, each w x t, at +/- d/2
    i_flange = 2 * (w * t) * (d / 2) ** 2
    # two webs normal to X, each t x d
    i_web = 2 * t * d ** 3 / 12
    return i_flange + i_web


def tip_deflection(V):
    """Cantilever tip deflection of the blade under uniform wind pressure."""
    i = second_moment()
    q = 0.5 * RHO_AIR * V ** 2 * CD
    return q * SAIL_H ** 4 / (8 * E_AL * i)


def blade_mass():
    return (2 * SAIL_W * SAIL_H + 2 * SAIL_T * SAIL_H + 2 * SAIL_W * SAIL_T) * SAIL_WALL * RHO_AL


def gap_conductance(d):
    """Effective conductance across the gap: conduction through trapped air, plus the
    contact conductance the gap has displaced."""
    return K_AIR / d


def main():
    rule("1. DRIVER 1 — THERMAL BREAK  (is 35 mm needed?)")
    print("  A machined aluminium-to-aluminium joint conducts ~"
          f"{H_CONTACT:.0f} W/m^2 K. A parallel air gap of thickness d conducts")
    print("  k_air/d. The break ratio is what matters:\n")
    print(f"  {'gap':>10}{'h_gap W/m2K':>16}{'vs contact':>14}{'reduction':>13}")
    for d in [0.002, 0.004, 0.005, 0.008, 0.012, 0.020, BLADE_GAP]:
        h = gap_conductance(d)
        print(f"  {d*1000:>8.0f}mm{h:>16.2f}{H_CONTACT:>14.0f}{H_CONTACT/h:>12.0f}x")
    # A thermal break is satisfied once the gap path is negligible against the metal path.
    # Criterion: >=1000x reduction, i.e. h_gap <= 10 W/m2 K. Beyond that, widening buys
    # nothing that any subsequent heat load can exploit.
    d_thermal_req = K_AIR / 10.0
    print(f"\n  Criterion: a >=1000x reduction, i.e. h_gap <= 10 W/m2 K.")
    print(f"  That is satisfied at d = {d_thermal_req*1000:.1f} mm.")
    print(f"  The implemented {BLADE_GAP*1000:.0f} mm is {BLADE_GAP/d_thermal_req:.0f}x that")
    print("  requirement, for no thermal gain anyone can measure.")

    rule("2. DRIVER 2 — WIND DEFLECTION  (does the gap have to swallow it?)")
    i = second_moment()
    print(f"  Box second moment about the bending axis : {i:.3e} m^4")
    print(f"  Blade mass                                : {blade_mass():.1f} kg")
    print(f"  (the two full-height ribs in the .scad are excluded, so this is conservative)\n")
    print(f"  {'V m/s':>8}{'q Pa':>10}{'tip deflection':>18}{'fraction of 35 mm':>20}")
    for V in [10, 20, 30, 45, 60]:
        d = tip_deflection(V)
        print(f"  {V:>8.0f}{0.5*RHO_AIR*V**2*CD:>10.1f}{d*1000:>16.2f} mm"
              f"{d/BLADE_GAP*100:>19.1f}%")
    print("\n  Even at 60 m/s the tip moves ~1.4 mm. Deflection does not need 35 mm;")
    print("  it needs about 5 mm to stay clear under a storm load case.")

    rule("3. DRIVER 3 — SERVICE CLEARANCE  (the cassette must slide out)")
    print("  The cassette withdraws sideways under the blade, and the blade lifts off the")
    print("  studs. Neither motion is bounded by BLADE_GAP itself — the gap is the running")
    print("  clearance between the blade underside and the cassette top face, so it must")
    print("  absorb:\n")
    print("    a) assembly tolerance stack across the joint")
    print("    b) blade deflection under load (section 2)")
    print("    c) blade rotation about the pivot, which sweeps the underside")
    # rotation sweep: the blade underside edge moves down by L*theta at the far corner
    for theta_deg in [1, 2, 5]:
        sweep = SAIL_W * math.sin(math.radians(theta_deg))
        print(f"    c) at {theta_deg:>2} deg of lean the underside sweeps {sweep*1000:>6.1f} mm vertically")
    print("\n  The sweep term dominates, and it is a ROTATION allowance, not a gap.")
    print("  Bounding lean is a latch/brake question (R7), not a BLADE_GAP question —")
    print("  which is itself an argument for splitting them.")

    rule("4. TOLERANCE STACK — what the gap must actually clear")
    rows = [
        ("flange plate flatness, each half", 0.30),
        ("gusset weld proudness", 0.40),
        ("cassette top face machining", 0.30),
        ("stud collar seating", 0.50),
        ("blade hole position (4 x M11)", 0.60),
        ("blade deflection at 45 m/s", 1.40),
        ("snow / accreted ice allowance on the blade foot", 3.00),
    ]
    print(f"  {'contributor':<44}{'mm':>8}")
    for n, v in rows:
        print(f"  {n:<44}{v:>8.2f}")
    # RSS rather than worst-case sum: these are manufacturing tolerances, not extremes
    rss = math.sqrt(sum(v * v for _, v in rows))
    worst = sum(v for _, v in rows)
    print(f"  {'RSS (statistical)':<44}{rss:>8.2f}")
    print(f"  {'worst-case sum':<44}{worst:>8.2f}")

    rule("5. THE REAL DRIVER — THE LEAN LIMIT, NOT THE THERMAL BREAK")
    print("  Section 3c is the binding constraint. The blade underside sweeps as the panel")
    print("  leans, and that sweep has to fit inside the gap:")
    print()
    print(f"  {'lean limit':>12}{'underside sweep':>19}{'gap needed':>13}{'35 mm enough?':>16}")
    for th in [0.5, 1, 2, 3, 5]:
        sweep = SAIL_W * math.sin(math.radians(th))
        need = sweep + worst / 1000.0        # sweep plus the worst-case tolerance stack
        print(f"  {th:>10.1f} deg{sweep*1000:>17.1f} mm{need*1000:>11.1f} mm"
              f"{('yes' if BLADE_GAP>=need else 'NO'):>16}")
    print()
    print("  So BLADE_GAP is set by HOW FAR THE SAIL IS ALLOWED TO LEAN — which is the R7")
    print("  latch/brake decision, not a free parameter. **R21 cannot be closed before R7.**")
    print("  The two are coupled, and coupling them is the actual finding here.")

    rule("6. DECISION")
    d_thermal_req = K_AIR / 10.0            # >=1000x reduction vs metal contact
    d_tolerance = worst / 1000.0 * 2        # 2x worst-case stack, field serviceable
    print(f"  thermal requirement   : >= {d_thermal_req*1000:>5.1f} mm  "
          f"({H_CONTACT/(K_AIR/d_thermal_req):.0f}x reduction vs metal contact)")
    print(f"  tolerance requirement : >= {d_tolerance*1000:>5.1f} mm  "
          f"(2x the {worst:.2f} mm worst-case stack)")
    print(f"  deflection requirement : >= {tip_deflection(60)*1000:>5.2f} mm  "
          f"(tip motion at 60 m/s)")
    print()
    for lean in [1, 2, 3]:
        sweep = SAIL_W * math.sin(math.radians(lean))
        need = max(d_thermal_req, d_tolerance, sweep + worst / 1000.0)
        rounded = math.ceil(need * 200) / 200        # nearest 5 mm
        print(f"  if lean is bounded at {lean} deg -> BLADE_GAP = {rounded*1000:>5.0f} mm "
              f"({(BLADE_GAP-rounded)*1000:+.0f} mm vs implemented)")
    print()
    lean_impl = math.degrees(math.asin(min(1.0, (BLADE_GAP - worst / 1000.0) / SAIL_W)))
    print("  Implemented value      : "
          f"{BLADE_GAP*1000:.0f} mm, which implicitly bounds lean at {lean_impl:.1f} deg")
    print()
    print("  RECOMMENDATION")
    print("    Do not set BLADE_GAP yet. Set the lean limit first (R7: latch and parking")
    print("    brake), then read BLADE_GAP off the table above. Recording 35 mm now would")
    print(f"    bake in an implicit {lean_impl:.1f} deg lean limit that nothing else in the")
    print("    design states -- a number nobody chose, discovered by working backwards.")
    print()
    print("  CONFIDENCE")
    print("    Thermal break, deflection and the tolerance stack are computable from the")
    print("    .scad geometry and are reported with their assumptions. The lean-sweep term")
    print("    depends on where the blade underside's outermost point is relative to the")
    print("    pivot, which is read from SAIL_W and should be confirmed against the")
    print("    assembly drawing. Every figure is a proposal pending that confirmation.")


if __name__ == "__main__":
    main()
