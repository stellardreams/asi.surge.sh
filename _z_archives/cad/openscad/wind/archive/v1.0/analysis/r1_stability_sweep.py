#!/usr/bin/env python3
"""R1 seasonal-toppling sweep and lever analysis for wind_sail_v5_arctic.scad.

Issue #84. Companion to amu_wind_sail_v5_r1_stability.md.

WHAT THIS IS
    A parametric sweep of the model's OWN idealised stability equation over the assumed
    ice depth ICE_TOP, plus the lever analysis that shows which candidate fixes can
    actually change the answer.

WHAT THIS IS NOT
    Nothing here simulates freezing, thawing, or a season. ICE_TOP is a STATIC INPUT
    representing an assumed winter state; sweeping it is a parametric what-if. The
    equation is single-coordinate: no liquid coordinate, no sloshing, no fluid-structure
    interaction, no aerodynamic feedback, no generator. The 2.0 margin threshold is a
    SCREENING choice for this equation -- not a structural safety factor, not a
    certification, and not evidence of physical winter behaviour.

GOVERNING RELATIONSHIP
    The model's margin reduces analytically to:

        margin = a^2 * CELL_COLS * 1000 * L_SAIL / (2 * m_structure)

    where a = water column height = CELL_BAND_H - SAIL_WALL - ICE_TOP. Cell plan area
    cancels entirely, as do gravity and cell width/depth individually. Only three levers
    exist: water height (quadratic), effective pendulum length (linear), structure mass
    (inverse linear).

USAGE
    python3 r1_stability_sweep.py

    Requires openscad on PATH for the verification step. Verification runs first; if the
    reimplementation does not match the binary the script exits non-zero and the sweep
    results are not trustworthy.
"""
import math
import os
import re
import subprocess
import sys
import tempfile

# --- defaults, from wind_sail_v5_arctic.scad ---
SAIL_W, SAIL_T, SAIL_H, SAIL_WALL = 0.56, 0.26, 2.55, 0.004
CELL_BAND_H, CELL_COLS = 0.62, 2
L_SAIL = 1.30
G_ACC = 9.81
SCREEN = 2.0
AL = 2700

SCAD = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
               "wind_sail_v5_arctic.scad")
CELL_H = CELL_BAND_H - SAIL_WALL


def structure_mass(sail_wall=SAIL_WALL, cell_band_h=CELL_BAND_H):
    """Mirror structure_mass() exactly. Rib length depends on CELL_BAND_H."""
    shell = (2 * SAIL_W * SAIL_H + 2 * SAIL_T * SAIL_H + 2 * SAIL_W * SAIL_T) * sail_wall * AL
    ribs = 2 * sail_wall * (SAIL_T - 2 * sail_wall) * (SAIL_H - cell_band_h) * AL
    return shell + ribs + 6.0


M_S = structure_mass()


def cell_geom(cols=CELL_COLS, sail_wall=SAIL_WALL):
    """Mirror anim_cell_w/anim_cell_d exactly. cell_w DEPENDS on CELL_COLS."""
    w = (SAIL_W - 2 * sail_wall) / cols - sail_wall
    d = SAIL_T - 2 * sail_wall - 2 * 0.010
    return w, d, w * d


def evaluate(ice_top, l_sail=L_SAIL, m_s=M_S, cell_h=CELL_H, cols=CELL_COLS,
             sail_wall=SAIL_WALL):
    cw, cd, ca = cell_geom(cols, sail_wall)
    a = cell_h - ice_top
    mu = cw * cd * a * cols * 1000.0 / m_s
    wa2 = G_ACC * a / (2.0 * ca)
    wn2 = max(0.0, mu * wa2 - G_ACC / l_sail)
    return {
        "a": a,
        "mu": mu,
        "mu_crit": 2.0 * ca / (l_sail * a),
        "margin": mu * wa2 / (G_ACC / l_sail),
        "stable": mu * wa2 > G_ACC / l_sail,
        "pass": mu * wa2 / (G_ACC / l_sail) >= SCREEN,
        "f_sail": math.sqrt(wn2) / (2 * math.pi),
        "f_abs": math.sqrt(wa2) / (2 * math.pi),
    }


# --------------------------------------------------------------------------
# verification against the real OpenSCAD binary
# --------------------------------------------------------------------------
FIELDS = [
    ("mu", r"mu \(mass ratio\)"),
    ("mu_crit", r"mu_crit \(model\)"),
    ("f_sail", r"f_sail \(model\)"),
    ("f_abs", r"f_abs \(estimate\)"),
    ("margin", r"stability margin"),
    ("stable", r"EQUATION STABLE\?"),
    ("pass", r"SCREEN PASS\?"),
]


def openscad_probe(params, tmpdir):
    """Run OpenSCAD headless and parse the === SAIL DYNAMICS === echo block.

    OpenSCAD's str() concatenation emits EVERY diagnostic on one line, so each field must
    be matched with an anchored regex. A naive split("= ")[-1] returns the final field for
    every key and silently drops all numeric comparisons -- which produces a false PASS.
    """
    out_csg = os.path.join(tmpdir, "probe.csg")
    cmd = ["openscad", "-o", out_csg, "-D", "RENDER_SCENE=false"]
    for k, v in params.items():
        cmd += ["-D", f"{k}={v}"]
    cmd.append(SCAD)
    res = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
    out = res.stderr + res.stdout

    vals = {}
    for key, label in FIELDS:
        m = re.search(label + r"\s*=\s*(-?[\d.eE+]+|true|false)", out)
        if not m:
            continue
        raw = m.group(1)
        if raw in ("true", "false"):
            vals[key] = raw == "true"
        else:
            vals[key] = float(raw)
    return vals


def translate(params):
    """Map OpenSCAD parameter names onto evaluate() arguments."""
    out = {}
    for k, v in params.items():
        if k == "ICE_TOP":
            out["ice_top"] = v
        elif k == "L_SAIL":
            out["l_sail"] = v
        elif k == "CELL_BAND_H":
            out["cell_h"] = v - SAIL_WALL
            out["m_s"] = structure_mass(cell_band_h=v)
        elif k == "CELL_COLS":
            out["cols"] = v
        elif k == "SAIL_WALL":
            out["m_s"] = structure_mass(sail_wall=v)
        else:
            raise KeyError(k)
    return out


def verify(cases):
    rule = "=" * 78
    print(rule)
    print("VERIFICATION -- python reimplementation vs OpenSCAD binary")
    print(rule)
    print(f"{'params':<44}{'field':<11}{'openscad':>12}{'python':>12}{'delta':>11}")
    ok, checked = True, 0
    with tempfile.TemporaryDirectory() as tmpdir:
        for params in cases:
            ref = openscad_probe(params, tmpdir)
            got = evaluate(**translate(params))
            for key in [k for k, _ in FIELDS]:
                if key not in ref:
                    print(f"{str(params):<44}{key:<11}{'NOT PARSED':>12}")
                    ok = False
                    continue
                checked += 1
                if isinstance(ref[key], bool):
                    if ref[key] != got[key]:
                        print(f"{str(params):<44}{key:<11}{str(ref[key]):>12}{str(got[key]):>12}  MISMATCH")
                        ok = False
                    continue
                d = abs(ref[key] - got[key])
                rel = d / abs(ref[key]) if ref[key] else d
                flag = "" if rel < 1e-3 else "  <-- MISMATCH"
                if rel >= 1e-3:
                    ok = False
                print(f"{str(params):<44}{key:<11}{ref[key]:>12.6f}{got[key]:>12.6f}{d:>11.2e}{flag}")
    print()
    print(f"VERIFICATION: {'PASS -- model reproduces' if ok else 'FAIL'} "
          f"({checked} field comparisons)")
    return ok


# --------------------------------------------------------------------------
# reporting
# --------------------------------------------------------------------------
def table(title, rows, headers):
    rule = "=" * 78
    print(rule)
    print(title)
    print(rule)
    w = [max(len(h), 11) for h in headers]
    print("  ".join(h.ljust(w[i]) for i, h in enumerate(headers)))
    print("  ".join("-" * w[i] for i in range(len(headers))))
    for r in rows:
        print("  ".join(str(c).ljust(w[i]) for i, c in enumerate(r)))


def bisect(pred, lo, hi, iters=200):
    for _ in range(iters):
        mid = (lo + hi) / 2
        if pred(mid):
            lo = mid
        else:
            hi = mid
    return lo


def main():
    ok = verify([
        {"ICE_TOP": 0.10},
        {"ICE_TOP": 0.30},
        {"ICE_TOP": 0.35},
        {"ICE_TOP": 0.40},
        {"ICE_TOP": 0.20, "L_SAIL": 1.60},
        {"ICE_TOP": 0.20, "CELL_BAND_H": 0.50},
        {"ICE_TOP": 0.20, "CELL_COLS": 3},
    ])
    if not ok:
        print("\nVerification failed -- sweep results are not trustworthy. Exiting.")
        return 1

    # 1. baseline sweep
    print()
    rows = []
    for it in [0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40,
               0.45, 0.50, 0.55, 0.60]:
        r = evaluate(it)
        rows.append([f"{it:.2f}", f"{r['a']:.3f}", f"{r['mu']:.3f}", f"{r['mu_crit']:.3f}",
                     f"{r['margin']:.3f}", "yes" if r["stable"] else "NO",
                     "yes" if r["pass"] else "NO",
                     f"{r['f_sail']:.4f}", f"{r['f_abs']:.4f}"])
    table("1. BASELINE -- margin and frequency vs assumed ice depth (defaults)",
          rows, ["ICE_TOP", "a (m)", "mu", "mu_crit", "margin", "stable",
                 "screen2", "f_sail Hz", "f_abs Hz"])

    # 2. thresholds
    screen_at = bisect(lambda x: evaluate(x)["pass"], 0.0, CELL_H)
    stable_at = bisect(lambda x: evaluate(x)["stable"], 0.0, CELL_H)
    print()
    print("=" * 78)
    print("2. THRESHOLDS (baseline geometry)")
    print("=" * 78)
    print(f"  ICE_TOP where margin crosses 2.0 (screen)  : {screen_at:.4f} m "
          f"({screen_at/CELL_H*100:.1f}% of cell)")
    print(f"  ICE_TOP where equation stops being stable : {stable_at:.4f} m "
          f"({stable_at/CELL_H*100:.1f}% of cell)")
    print(f"  headroom between screen and toppling       : {stable_at-screen_at:.4f} m")
    print(f"  full freeze (ICE_TOP = cell height)        : {CELL_H:.4f} m")

    # 3. lever sensitivity at the screen boundary
    print()
    rows = [[f"{l:.2f}", f"{evaluate(0.30, l_sail=l)['margin']:.3f}",
             "yes" if evaluate(0.30, l_sail=l)["pass"] else "NO",
             f"{evaluate(0.30, l_sail=l)['f_sail']:.4f}"]
            for l in [1.10, 1.30, 1.60, 2.00, 2.50]]
    table("3a. LEVER L_SAIL at ICE_TOP=0.30 (proxy for 'cells below pivot')",
          rows, ["L_SAIL", "margin", "screen2", "f_sail Hz"])

    rows = []
    for wmm in [2, 3, 4, 8, 12]:
        m = structure_mass(sail_wall=wmm / 1000)
        r = evaluate(0.30, m_s=m)
        rows.append([f"{wmm} mm", f"{m:.2f}", f"{r['margin']:.3f}",
                     "yes" if r["pass"] else "NO", f"{r['f_sail']:.4f}"])
    table("3b. LEVER structure_mass at ICE_TOP=0.30 (via SAIL_WALL)",
          rows, ["SAIL_WALL", "m_s kg", "margin", "screen2", "f_sail Hz"])

    rows = [[c, f"{evaluate(0.30, cols=c)['margin']:.3f}",
             "yes" if evaluate(0.30, cols=c)["pass"] else "NO",
             f"{evaluate(0.30, cols=c)['f_sail']:.4f}"] for c in [1, 2, 3, 4]]
    table("3c. LEVER CELL_COLS at ICE_TOP=0.30",
          rows, ["CELL_COLS", "margin", "screen2", "f_sail Hz"])

    # 4. fill vs margin, and the detuning that rides along with it
    print()
    rows = []
    for it in [0.00, 0.10, 0.20, 0.30, 0.40, 0.50]:
        r = evaluate(it)
        rows.append([f"{it:.2f}", f"{r['a']:.3f}", f"{r['a']/CELL_H*100:.0f}%",
                     f"{r['margin']:.3f}", f"{r['f_sail']:.4f}", f"{r['f_abs']:.4f}"])
    table("4. FILL vs MARGIN -- and the detuning that rides along with it",
          rows, ["ICE_TOP", "a (m)", "fill %", "margin", "f_sail Hz", "f_abs Hz"])
    print()
    print("  margin is QUADRATIC in water height a; f_sail rises as a^2 while f_abs rises")
    print("  as sqrt(a). The two separate steadily as ice accumulates, and f_sail collapses")
    print("  to zero at the instability threshold. Any margin fix therefore detunes the")
    print("  device. Track margin AND frequency together -- margin alone is not sufficient.")

    # 5. required lever movement -- the decisive result
    K = 2 * 1000 * L_SAIL / (2 * M_S)   # margin = K * a^2 at default cols=2

    def budget_at(factor, cols=2):
        a = math.sqrt(2.0 / (factor * K * cols / 2))
        return None if (a <= 0 or a > CELL_H) else CELL_H - a

    print()
    print("=" * 78)
    print("5. REQUIRED LEVER MOVEMENT -- what buys a defensible winter ice budget?")
    print("=" * 78)
    print(f"  {'target ice budget':<28}{'margin now':>11}{'L_SAIL req':>12}"
          f"{'m_s req':>11}{'cols req':>10}")
    print("  " + "-" * 70)
    for T in [0.35, 0.40, 0.45, 0.50]:
        a = CELL_H - T
        base = K * a * a
        need = SCREEN / base
        print(f"  {T:.2f} m ({T/CELL_H*100:.0f}% of cell){'':<7}{base:>11.3f}"
              f"{L_SAIL*need:>11.2f}m{M_S/need:>10.1f}kg{2*need:>10.2f}")
    print()
    print(f"  Against the actual machine: sail is {SAIL_H} m tall and {SAIL_W} m wide,")
    print(f"  with a {structure_mass(sail_wall=SAIL_WALL)-(M_S-48.31):.1f} kg 4 mm shell alone.")
    print(f"    L_SAIL={L_SAIL*((SCREEN)/(K*(CELL_H-0.45)**2)):.2f} m exceeds the sail height")
    print(f"    m_s={M_S/((SCREEN)/(K*(CELL_H-0.45)**2)):.1f} kg is below the bare shell mass")
    print(f"    cols={2*((SCREEN)/(K*(CELL_H-0.45)**2)):.2f} across {SAIL_W} m is not buildable")

    print()
    base_budget = budget_at(1.0)
    rows = []
    for v in [1.60, 1.80, 2.20]:
        rows.append([f"L_SAIL={v:.2f}", v, budget_at(v / L_SAIL)])
    for wmm in [3, 2]:
        m = structure_mass(sail_wall=wmm / 1000)
        a = math.sqrt(SCREEN / (K * M_S / m))
        rows.append([f"SAIL_WALL={wmm}mm", wmm, CELL_H - a])
    for c in [3, 4]:
        rows.append([f"CELL_COLS={c}", c, budget_at(1.0, cols=c)])
    print("=" * 78)
    print("6. WHAT EACH PLAUSIBLE LEVER ACTUALLY BUYS")
    print("=" * 78)
    print(f"  {'lever':<28}{'value':>10}{'ice budget':>14}{'vs baseline':>14}")
    print("  " + "-" * 66)
    for lbl, val, b in rows:
        print(f"  {lbl:<28}{val:>10}{b:>13.4f}m{b-base_budget:>+13.4f}m")
    best = max(b for _, _, b in rows)
    print()
    print(f"  baseline budget {base_budget:.4f} m ; best notional lever reaches "
          f"{best:.4f} m (+{best-base_budget:.4f} m)")
    print(f"  full freeze is {CELL_H:.3f} m.")
    print()
    print("  CONCLUSION: no geometry change closes a meaningful part of this gap. R1 must")
    print("  be solved by holding ICE_TOP down -- a CONTROL strategy, not a design change.")
    print("  The weep drain is NOT one of those controls: it moves liquid, not ice. Only a")
    print("  thermal control (thermosyphon) or an active one can bound an ice front. R5 is")
    print("  therefore the prerequisite, with R6 a separate water-path prerequisite.")

    # 7. candidate classification
    print()
    print("=" * 78)
    print("7. CANDIDATE FIX CLASSIFICATION")
    print("=" * 78)
    for name, kind, note in [
        ("drain / weep drain (R6)", "WATER-PATH control only",
         "a drain moves LIQUID, not ice. Ice leaves the cell only by melting or mechanical "
         "removal, so the drain cannot by itself cap the advancing ice front. Reclassified "
         "from 'control on ICE_TOP' by Codex in 80883b8. Needs separate freeze/thermal "
         "validation; this sweep cannot assess it"),
        ("thermosyphon (R5)", "CANDIDATE thermal control",
         "can bound ice only by holding the brine at its freezing point; ice then forms in "
         "the temperature deficit below that point. Do not credit it with any particular "
         "ICE_TOP until a heat balance and a cold-chamber or field test demonstrate it"),
        ("active re-freeze control", "CONTROL on ICE_TOP",
         "same; no geometric evaluation is possible in this model"),
        ("cells further below pivot", "PROXY via L_SAIL only",
         "model has no coordinate for cell vertical position; L_SAIL also moves the "
         "structure CoM, so it is not a faithful stand-in"),
        ("larger margin at low water", "SELF-CONTRADICTORY as stated",
         "margin falls QUADRATICALLY as fill falls; must be paired with L_SAIL, m_s or "
         "CELL_COLS"),
    ]:
        print(f"  {name}")
        print(f"      type   : {kind}")
        print(f"      finding: {note}")
        print()

    # 8. robustness note
    print("=" * 78)
    print("8. ROBUSTNESS NOTE -- full freeze")
    print("=" * 78)
    print(f"  At ICE_TOP = cell height, a = 0 and mu_crit = inf -- a division-by-zero")
    print("  artifact, not a diagnostic. The run still classifies unstable and fails the")
    print("  screen, so the direction is right, but inf must not be read as a result.")
    print(f"    openscad -o /tmp/ff.csg -D 'RENDER_SCENE=false' -D 'ICE_TOP={CELL_H}' wind_sail_v5_arctic.scad")
    return 0


if __name__ == "__main__":
    sys.exit(main())
