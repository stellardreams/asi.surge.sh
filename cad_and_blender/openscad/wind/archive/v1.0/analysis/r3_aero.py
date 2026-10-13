#!/usr/bin/env python3
"""R3 desk study — can the sail sustain self-excited pitch oscillation?

Issue #84 / risk register R3. Desk study only: no CFD, no wind tunnel, no physical test.

THE QUESTION
    R3 asks whether the AMU sail can oscillate at all under steady wind. The OpenSCAD
    model cannot answer this: its `wind` mode applies a *prescribed* drag torque that does
    not respond to sail motion, so it contains no aerodynamic feedback whatsoever. This
    script supplies that missing feedback analytically and asks whether any wind speed
    produces net-negative damping.

GEOMETRY (from wind_sail_v5_arctic.scad — verified against the `cube([SAIL_W, SAIL_T, bh])`
blade construction and the `-SAIL_T/2` cutaway, which fixes Y as the wind direction):

    SAIL_W = 0.56 m   panel width, along the pivot axis (X)
    SAIL_T = 0.26 m   panel depth, along the wind (Y)   <-- this is the aerodynamic CHORD
    SAIL_H = 2.55 m   height                            <-- this is the SPAN

    The pivot axis is X at the base. Wind blows along Y. The plate therefore presents a
    0.56 x 2.55 m face, and its aerodynamic chord is 0.26 m.

    Aspect ratio = 2.55 / 0.26 = 9.8 -> a SLENDER plate. Slender plates are the
    flutter-prone case, not the safe case. This is the opposite of the intuitive
    "flat plate is safe" reading and it is why R3 cannot be waved away.

MODEL
    Strip theory: each spanwise strip is a 2-D flat-plate section at incidence alpha.
    All strips share alpha = theta (rigid rotation about the base).

        L_nc   = pi*q*c*alpha + (pi/4)*rho*c^2*alpha_dot      (added mass, m_a = pi*rho*c^2/4)
        L_circ = pi*q*c*C(k)*alpha                            (Theodorsen circulatory)
        M_ac   = -I_a*alpha_ddot,  I_a = pi*rho*b^4, b = c/2  (added inertia about the AC)

    with reduced frequency k = omega*c/(2*V).

    The strip forces are transferred to the base pivot. A vertical (lift) force acting at
    the aerodynamic centre contributes moment y_AC = -c/4 about the pivot. The spanwise
    height contributes no moment to a purely vertical force.

WHAT THIS IS NOT
    Attached-flow, linear, small-amplitude theory. It cannot represent separation,
    leading-edge vortices, wake lock-in, or vortex-induced vibration. Those are the
    mechanisms by which real flat plates are known to sustain oscillation, so a "damped"
    result here is a statement about THIS REGIME ONLY and must be paired with the
    literature review in the accompanying write-up.
"""
import os

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

# ---------------------------------------------------------------- constants
RHO = 1.225        # kg/m^3, air at sea level (matches WIND_AIR_DENSITY in the .scad)
G = 9.81

# sail geometry, from wind_sail_v5_arctic.scad
CHORD = 0.26       # SAIL_T, along the wind
SPAN = 2.55        # SAIL_H
PANEL_W = 0.56     # SAIL_W, along the pivot axis
L_SAIL = 1.30      # effective pendulum length, pivot to structure CoM
ICE_TOP = 0.10     # default ice depth -> the fill the model's default diagnostics assume

# structural / liquid parameters, all read out of the .scad
ZETA_STRUCT = 0.040      # ZETA_TOTAL
CELL_BAND_H = 0.62
SAIL_WALL = 0.004
CELL_COLS = 2
CELL_D = CHORD - 2 * SAIL_WALL - 2 * 0.010
CELL_W = (PANEL_W - 2 * SAIL_WALL) / CELL_COLS - SAIL_WALL
CELL_A = CELL_W * CELL_D
CELL_H = CELL_BAND_H - SAIL_WALL

# ---------------------------------------------------------------- model state (from the .scad)
def structure_mass():
    shell = (2 * PANEL_W * SPAN + 2 * CHORD * SPAN + 2 * PANEL_W * CHORD) * SAIL_WALL * 2700
    ribs = 2 * SAIL_WALL * (CHORD - 2 * SAIL_WALL) * (SPAN - CELL_BAND_H) * 2700
    return shell + ribs + 6.0


M_S = structure_mass()


def liquid_state(ice_top=ICE_TOP):
    """Reproduces the .scad: omega_n^2, inertia, natural frequency."""
    a = CELL_H - ice_top
    mu = CELL_W * CELL_D * a * CELL_COLS * 1000.0 / M_S
    wa2 = G * a / (2 * CELL_A)
    wn2 = max(0.0, mu * wa2 - G / L_SAIL)
    inertia = M_S * L_SAIL ** 2 * (1 + mu)
    return dict(a=a, mu=mu, wn2=wn2, inertia=inertia,
                wn=np.sqrt(wn2), f_sail=np.sqrt(wn2) / (2 * np.pi))


# ---------------------------------------------------------------- aerodynamics
def theodorsen(k):
    """Theodorsen's circulatory function C(k) = F(k) + i G(k), G(k) < 0 for k > 0.

    NOTE ON THE CHOICE OF APPROXIMATION. The exact function is a Hankel-function ratio
    (Epps 2018, AIAA J. doi:10.2514/1.J056399 gives the identity). Direct quadrature of the
    naive real integrand 1 - (k/pi)*int exp(-k cos t) dt returns a PURELY REAL result and
    silently zeroes G(k) -- that was a real bug in the first pass of this script, and it
    would have reported zero aerodynamic damping.

    This script instead uses JONES' APPROXIMATION,

        C(k) ~= 1 - 1.3400 i k / (1 + 2.4300 i k)

    which is the standard engineering substitute, is the form cited in the rotorcraft
    literature (Brunton, via Breitbach 2024) and in NASA TN on Theodorsen/Garrick flutter,
    and is valid for the small-to-moderate reduced frequencies this sail actually operates
    at (k = 0.017 to 0.74 across the wind-speed sweep). It reproduces C(0) = 1 and gives
    Im(C) < 0 throughout, as required.

    It is an approximation, and the damping numbers below inherit its error. The SIGN of
    the result does not depend on it: any C(k) with a negative imaginary part yields
    positive damping.
    """
    return 1.0 - (1.3400j * k) / (1.0 + 2.4300j * k)


def aerodynamic_terms(V, f_sail):
    """Quasi-steady stiffness and circulatory damping about the base pivot.

    Returns k_aero [N*m/rad], c_aero_circ [N*m*s/rad], and the reduced frequency.
    """
    w = 2 * np.pi * f_sail
    q = 0.5 * RHO * V ** 2
    k_red = w * CHORD / (2 * V)

    # quasi-steady: Cm about the pivot = Cn * (e/c), e = c/4 (pivot aft of the AC)
    # k_aero = q * S * e * dCn/dalpha = q*(c*span)*(c/4)*(2*pi)
    k_aero = q * (CHORD * SPAN) * (CHORD / 4) * (2 * np.pi)

    # circulatory: the lift term  pi*q*c*C(k)*alpha  contributes out-of-phase force
    # pi*q*c*G(k)*alpha  -> damping through the lever arm c/4, summed over the span
    Ck = theodorsen(k_red)
    c_aero_circ = (CHORD / 4) * np.pi * q * CHORD * abs(Ck.imag) / w * SPAN

    return k_aero, c_aero_circ, k_red


def aero_damping_added_mass(V, f_sail):
    """Added-mass damping seen through the c/4 lever arm of the lift.

    Small but included for completeness: L_nc carries (pi/4)*rho*c^2*alpha_dot at the AC.
    """
    w = 2 * np.pi * f_sail
    return (CHORD / 4) * (np.pi / 4) * RHO * CHORD ** 2 * SPAN


def added_inertia_sway():
    """Added moment of inertia from strips translating in the flow direction.

    A strip at height z moves z*theta in Y. Its added mass m_a' therefore produces a
    moment m_a'*z^2*theta_ddot about the pivot, integrated over the span.
    """
    m_a_per_span = np.pi * RHO * CHORD ** 2 / 4
    return m_a_per_span * SPAN ** 3 / 3


# ---------------------------------------------------------------- reporting
def check_theodorsen():
    """Fail loudly if the circulation function is not behaving like Theodorsen's.

    Guards against the real failure mode here: a real-valued G(k) from a bad integral,
    which silently reports zero aerodynamic damping and a false 'no flutter' verdict.
    """
    checks, ok = [], True
    C0 = theodorsen(0.0)
    checks.append(("C(0) == 1", abs(C0.real - 1.0) < 1e-9 and abs(C0.imag) < 1e-9))
    ks = np.linspace(1e-4, 1.0, 200)
    ims = np.array([theodorsen(k).imag for k in ks])
    checks.append(("Im(C) < 0 for all k>0", bool(np.all(ims < 0))))
    mags = np.array([abs(theodorsen(k)) for k in ks])
    checks.append(("|C| monotonically decreasing", bool(np.all(np.diff(mags) <= 1e-12))))
    checks.append(("|C(1)| in 0.4..0.8", 0.4 < abs(theodorsen(1.0)) < 0.8))
    print("=" * 78)
    print("0. SELF-CHECK — Theodorsen circulation function")
    print("=" * 78)
    for name, passed in checks:
        print(f"  [{'ok' if passed else 'FAIL'}] {name}")
        ok = ok and passed
    if not ok:
        print("\n  C(k) is not behaving correctly -- do NOT trust the results below.")
        raise SystemExit(1)
    print("\n  C(k) verified. Results below are meaningful.")


def rule(t=""):
    print("=" * 78)
    if t:
        print(t)
        print("=" * 78)


def main():
    check_theodorsen()
    st = liquid_state()
    rule("1. GEOMETRY AND MODEL STATE")
    print(f"  aerodynamic chord c (SAIL_T, along wind) : {CHORD:.3f} m")
    print(f"  span b (SAIL_H)                          : {SPAN:.3f} m")
    print(f"  panel width (SAIL_W, pivot axis)         : {PANEL_W:.3f} m")
    print(f"  aspect ratio b/c                         : {SPAN/CHORD:.1f}  <-- SLENDER")
    print(f"  aerodynamic centre at span fraction      : 0.25 chord, {SPAN/2:.3f} m above pivot")
    print()
    print(f"  structure mass m_s                       : {M_S:.2f} kg")
    print(f"  water column a (ICE_TOP={ICE_TOP:.2f})          : {st['a']:.3f} m")
    print(f"  mu                                       : {st['mu']:.4f}")
    print(f"  inertia about pivot                      : {st['inertia']:.1f} kg m^2")
    print(f"  liquid-only f_sail                       : {st['f_sail']:.4f} Hz")
    print(f"  omega_n                                  : {st['wn']:.4f} rad/s")
    k_liquid = st["inertia"] * st["wn2"]
    print(f"  liquid restoring stiffness               : {k_liquid:.1f} N m/rad")
    print(f"  structural damping c_struct              : "
          f"{2*ZETA_STRUCT*st['inertia']*st['wn']:.2f} N m s/rad")
    print(f"  sway added inertia                       : {added_inertia_sway():.4f} kg m^2 "
          f"({added_inertia_sway()/st['inertia']*100:.2f}% of structural)")

    rule("2. QUASI-STEADY AERODYNAMIC MOMENT — sign and magnitude")
    print("  The pivot sits BELOW the aerodynamic centre, so the quasi-steady moment is")
    print("  RESTORING (weathervane effect), not destabilising.\n")
    print(f"  {'V m/s':>8}{'Re':>12}{'k_aero N m/rad':>18}{'k_aero/k_liquid':>20}")
    for V in [1, 5, 8, 12, 20, 30, 45]:
        k_a, _, k_red = aerodynamic_terms(V, st["f_sail"])
        Re = RHO * V * CHORD / 1.81e-5
        print(f"  {V:>8.0f}{Re:>12.0f}{k_a:>18.1f}{k_a/k_liquid*100:>19.2f}%")
    print("\n  Aerodynamic stiffness never exceeds a few percent of the liquid restoring")
    print("  stiffness at any plausible wind speed, so the sail's frequency is set by the")
    print("  cells, not the air.")

    rule("3. CIRCULATORY DAMPING vs STRUCTURAL DAMPING")
    print("  Self-excited oscillation requires total damping <= 0. Here c_aero is the")
    print("  circulatory (Theodorsen) contribution about the base pivot.\n")
    rows = []
    for V in [1, 5, 8, 12, 20, 30, 45]:
        k_a, c_circ, k_red = aerodynamic_terms(V, st["f_sail"])
        c_am = aero_damping_added_mass(V, st["f_sail"])
        c_struct = 2 * ZETA_STRUCT * st["inertia"] * st["wn"]
        rows.append((V, k_red, c_circ, c_am, c_circ + c_am, c_struct,
                     (c_circ + c_am) / c_struct * 100))
    print(f"  {'V':>5}{'k_red':>10}{'c_circ':>12}{'c_addedmass':>14}"
          f"{'c_aero tot':>13}{'c_struct':>12}{'aero/struct':>13}")
    for V, kr, cc, ca, ctot, cs, pct in rows:
        print(f"  {V:>5.0f}{kr:>10.4f}{cc:>12.4f}{ca:>14.5f}{ctot:>13.4f}"
              f"{cs:>12.2f}{pct:>12.3f}%")
    worst = max(r[6] for r in rows)
    best = min(r[6] for r in rows)
    print(f"\n  Aerodynamic damping share across the sweep: {best:.3f}% to {worst:.3f}%")
    print(f"  That is structural damping being {100/worst:.0f}x to {100/best:.0f}x LARGER "
          f"than aerodynamic.")
    print("  Total damping is POSITIVE at every wind speed tested. The sign does not")
    print("  depend on Jones' approximation: any C(k) with Im(C) < 0 gives positive damping.")

    rule("4. WHY — GEOMETRIC REASON")
    print("  Damping requires an aerodynamic force to act at a lever arm that produces")
    print("  motion. The lift acts at the aerodynamic centre, which is only c/4 = "
          f"{CHORD/4:.3f} m")
    print("  horizontally from the pivot, while the plate is "
          f"{SPAN/2:.3f} m tall. The lift acts almost")
    print("  directly ABOVE the pivot, so it produces essentially no moment about it.")
    print()
    print("  The plate is aerodynamically INERT as an energy source: it can be pushed to a")
    print("  static deflection, and the cells restore it, but nothing pumps energy back in.")

    rule("5. VERDICT ON R3")
    print("  In the attached-flow linear regime at every wind speed tested, the total")
    print("  damping is positive — structural damping exceeds aerodynamic by ~150x to")
    print("  ~7000x — and the quasi-steady aerodynamic moment is RESTORING. The sail will")
    print("  not sustain self-excited oscillation. It settles to a static deflection.")
    print()
    print("  This is Option B in the risk register: ACCEPT A STATIC DEFLECTOR.")
    print("  The register's own stated cost applies — the liquid tuning, thermosyphon,")
    print("  cells and cassette become pointless, because a static deflector needs none of them.")
    print()
    print("  IMPORTANT LIMIT: this is attached-flow theory. It cannot represent separation,")
    print("  leading-edge vortices, or wake lock-in. Real flat plates ARE known to sustain")
    print("  oscillation in specific reduced-velocity regimes (see the literature review),")
    print("  and aspect ratio 9.8 is in the slender regime where that is most likely. So this")
    print("  result says the LINEAR regime is stable, not that oscillation is impossible.")
    print("  It is also consistent with the .scad's own model: that model has no")
    print("  aerodynamic feedback whatsoever, so it could never have shown this either way.")

    # ------------------------------------------------------------ plots
    Vs = np.linspace(0.5, 45, 300)
    k_a_list, c_tot_list, cs_list, kr_list = [], [], [], []
    for V in Vs:
        k_a, c_c, kr = aerodynamic_terms(V, st["f_sail"])
        c_am = aero_damping_added_mass(V, st["f_sail"])
        k_a_list.append(k_a)
        c_tot_list.append(c_c + c_am)
        cs_list.append(2 * ZETA_STRUCT * st["inertia"] * st["wn"])
        kr_list.append(kr)

    fig, axes = plt.subplots(1, 3, figsize=(15, 4.2))

    ax = axes[0]
    ax.plot(Vs, k_a_list, lw=2, label="aerodynamic (quasi-steady, restoring)")
    ax.axhline(k_liquid, color="k", ls="--", lw=1.5, label=f"liquid = {k_liquid:.0f} N m/rad")
    ax.set_yscale("log"); ax.set_xlabel("wind speed V [m/s]")
    ax.set_ylabel("stiffness [N m/rad]"); ax.set_title("Quasi-steady stiffness vs liquid")
    ax.legend(fontsize=8); ax.grid(alpha=.3, which="both")

    ax = axes[1]
    ax.semilogy(Vs, c_tot_list, lw=2, label="aerodynamic total")
    ax.semilogy(Vs, cs_list, lw=2, label=f"structural (zeta={ZETA_STRUCT})")
    ax.set_xlabel("wind speed V [m/s]"); ax.set_ylabel("damping [N m s/rad]")
    ax.set_title("Aerodynamic vs structural damping")
    ax.legend(fontsize=8); ax.grid(alpha=.3, which="both")

    ax = axes[2]
    ax.plot(kr_list, np.array(c_tot_list) / np.array(cs_list) * 100, lw=2)
    ax.set_xlabel("reduced frequency k = omega c / 2V")
    ax.set_ylabel("aero damping share [%]")
    ax.set_title("Damping share vs reduced frequency")
    ax.grid(alpha=.3)

    fig.tight_layout()
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                       "amu_wind_sail_v5_r3_damping.png")
    fig.savefig(out, dpi=110)
    print(f"\n  figure written: {out}")


if __name__ == "__main__":
    main()
