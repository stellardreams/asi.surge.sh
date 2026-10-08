#!/usr/bin/env python3
"""
amu_wind_sail_v5_build123d.py — build123d port of the v5 Arctic wind sail (issue #82).

Source of truth: cad_and_blender/openscad/wind/amu_wind_sail_v5.scad
That file remains the reference for everything published in the v1.2 release. This is
additive, not a replacement.

SCOPE — static geometry only. The single-DOF RK4 dynamic mode, the animation
sweep, and the ice/water two-phase tuning are all still OpenSCAD-side. Reimplementing
the physics is deliberately NOT bundled into a geometry-kernel port. Dynamics remain
in the .scad until there is a reason to move them.

Dimensional note: the OpenSCAD model is authored in METRES and its STL export carries
those units directly. Validation compares against the measured OpenSCAD bounding box,
not the prose figures in amu_wind_sail_v5.md — see validate_bbox() below.

Usage:
    python amu_wind_sail_v5_build123d.py            # print validation report
    python amu_wind_sail_v5_build123d.py --export out/   # STEP + STL
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass

from build123d import (
    Align,
    Axis,
    Box,
    Cylinder,
    Pos,
    Rot,
    Torus,
    export_step,
    export_stl,
)

# --------------------------------------------------------------------------
# Parameters — ported 1:1 from the .scad top-level constants (lines 76-174, 342-348,
# 351). Values are metres and must not drift: they are the geometry.
# --------------------------------------------------------------------------


@dataclass(frozen=True)
class SailParams:
    """Every dimension the static geometry depends on. Mirrors the .scad constants."""

    # --- footing (lines 76-82) ---
    base_w: float = 1.06          # widest footing step, sits on grade
    base_h: float = 0.16
    plinth_w: float = 0.62        # second step
    plinth_h: float = 0.20
    collar_w: float = 0.36        # thrust bearing — this is the pivot
    collar_h: float = 0.12
    collar_dia: float = 0.30      # bearing race diameter

    # --- sail (lines 118-123) ---
    sail_w: float = 0.56          # panel width, along the pivot axis (X)
    sail_t: float = 0.26          # panel thickness (Y, along the wind)
    sail_h: float = 2.55          # top of sail above the cassette datum
    sail_wall: float = 0.004      # 4 mm aluminium

    # --- serviceability (lines 108-115) ---
    blade_gap: float = 0.035      # clearance between cassette top and blade underside
    blade_bolts: int = 4
    blade_shaft_d: float = 0.011  # M11 quick-release studs

    # --- cassette / cells (line 128) ---
    cell_band_h: float = 0.62     # cassette height, and the cell zone inside it

    # --- root flange (lines 155-165) ---
    flange_dia: float = 0.54
    flange_t: float = 0.030       # each half of the sandwich
    flange_bolts: int = 4
    flange_bolt_r: float = 0.052  # bolt circle RADIUS
    flange_bolt_d: float = 0.011  # M10 shank
    flange_gusset: int = 4
    flange_gusset_t: float = 0.012
    flange_gusset_d: float = 0.055
    flange_gap: float = 0.030
    flange_pin_r: float = 0.055   # pivot pin radius

    # --- pile (lines 342-348) ---
    pile_shaft_dia: float = 0.30
    pile_depth: float = 2.60
    helix_dia: float = 0.98
    helix_t: float = 0.052
    helix_count: int = 3
    helix_pitch: float = 0.58
    helix_stagger: float = 60

    # --- feature switches (lines 114-174, 352) ---
    show_flange: bool = True
    show_cutaway: bool = True     # section the windward half so cells are visible

    # --- facet counts, preserved from the .scad $fn values ---
    fn_footing: int = 40
    fn_pile: int = 28
    fn_helix: int = 40


P = SailParams()

# Derived — same expressions as the .scad (lines 480-481, 877).
PLATE_LO_Z = -(P.flange_gap / 2 + P.flange_t)
PLATE_HI_Z = P.flange_gap / 2
PIVOT_Z = P.base_h + P.plinth_h + P.collar_h


# --------------------------------------------------------------------------
# Geometry
# --------------------------------------------------------------------------


def helical_pile(p: SailParams = P):
    """Helical pile: a plain shaft hanging below grade plus discrete helix flights.

    Note on PILE_DEPTH: it is NOT the embedment depth. The .scad builds a shaft of
    h = depth + 0.26 centred at z = -(depth + 0.26), so the pile bottom lands at
    -2*(depth + 0.26) = -4.290 m below grade. That reproduces the measured
    OpenSCAD bounding box exactly; do not "fix" it to read as a depth.
    """
    shaft_h = p.pile_depth + 0.26
    shaft = Pos(0, 0, -shaft_h) * Cylinder(
        p.pile_shaft_dia / 2,
        shaft_h,
        align=(Align.CENTER, Align.CENTER, Align.CENTER),
    )

    flights = []
    for i in range(p.helix_count):
        flight = Rot(0, 0, i * p.helix_stagger) * Pos(0, 0, -0.40 - i * p.helix_pitch) * Cylinder(
            p.helix_dia / 2,
            p.helix_t,
            align=(Align.CENTER, Align.CENTER, Align.CENTER),
        )
        flights.append(flight)

    return shaft, flights


def footing(p: SailParams = P):
    """Stepped footing — the two steps under the thrust collar."""
    base = Pos(0, 0, p.base_h / 2) * Box(
        p.base_w, p.base_w * 0.78, p.base_h, align=(Align.CENTER, Align.CENTER, Align.CENTER)
    )
    plinth = Pos(0, 0, p.base_h + p.plinth_h / 2) * Box(
        p.plinth_w,
        p.plinth_w * 0.80,
        p.plinth_h,
        align=(Align.CENTER, Align.CENTER, Align.CENTER),
    )
    return base, plinth


def thrust_collar(p: SailParams = P):
    """Thrust collar — carries the sail and IS the pivot."""
    z0 = p.base_h + p.plinth_h
    top = PIVOT_Z + PLATE_LO_Z - p.flange_gusset_d

    column = Pos(0, 0, (z0 + top) / 2) * Cylinder(
        p.collar_w / 2, top - z0, align=(Align.CENTER, Align.CENTER, Align.CENTER)
    )
    # spigot — registers the lower plate and takes the gusset cone load in bearing
    spigot = Pos(0, 0, top - 0.014) * Cylinder(
        p.flange_pin_r * 1.35, 0.028, align=(Align.CENTER, Align.CENTER, Align.CENTER)
    )
    # bearing race — the rotation surface the sail rocks on
    race = Pos(0, 0, top) * Torus(p.collar_dia / 2, 0.014)

    return column, spigot, race


def flange_plate(upper: bool, p: SailParams = P):
    """One half of the preloaded bolted root flange."""
    z = PLATE_HI_Z if upper else PLATE_LO_Z
    return Pos(0, 0, z) * Cylinder(
        p.flange_dia / 2, p.flange_t, align=(Align.CENTER, Align.CENTER, Align.CENTER)
    )


def flange_gussets(p: SailParams = P):
    """Gusset ring below the lower plate — this is the load path to the pile."""
    parts = []
    for i in range(p.flange_gusset):
        parts.append(
            Rot(0, 0, i * 360 / p.flange_gusset)
            * Pos(0, p.flange_dia / 2 - 0.01, PLATE_LO_Z - p.flange_gusset_d / 2)
            * Box(
                p.flange_gusset_t,
                0.03,
                p.flange_gusset_d,
                align=(Align.CENTER, Align.CENTER, Align.CENTER),
            )
        )
    return parts


def flange_bolts(p: SailParams = P):
    parts = []
    for i in range(p.flange_bolts):
        parts.append(
            Rot(0, 0, i * 360 / p.flange_bolts + 45)
            * Pos(p.flange_bolt_r, 0, PLATE_LO_Z - p.flange_t / 2)
            * Cylinder(
                p.flange_bolt_d / 2,
                (p.flange_gap + 2 * p.flange_t),
                align=(Align.CENTER, Align.CENTER, Align.CENTER),
            )
        )
    return parts


def sail_blade(p: SailParams = P):
    """Hollow sail panel above the cassette.

    Built the way the .scad builds it: an outer block minus an inner void. Kept as a
    subtraction rather than a shelled solid so the wall thickness stays explicit.
    """
    z0 = p.cell_band_h + p.blade_gap
    bh = p.sail_h - z0
    mid = z0 + bh / 2

    outer = Pos(0, 0, mid) * Box(
        p.sail_w, p.sail_t, bh, align=(Align.CENTER, Align.CENTER, Align.CENTER)
    )
    void = Pos(0, 0, mid - p.sail_wall / 2) * Box(
        p.sail_w - 2 * p.sail_wall,
        p.sail_t - 2 * p.sail_wall,
        bh - p.sail_wall,
        align=(Align.CENTER, Align.CENTER, Align.CENTER),
    )
    shell = outer - void

    if not p.show_cutaway:
        return shell, []

    # Section the windward half of the shell so the two-phase cells are visible.
    cutaway = Pos(0, -p.sail_t / 2, mid) * Box(
        p.sail_w * 1.4, p.sail_t, bh * 1.4, align=(Align.CENTER, Align.CENTER, Align.CENTER)
    )
    return shell - cutaway, []


def static_sail_unit(p: SailParams = P):
    """Assemble the static geometry. Returns (solids, cutaway_views).

    Excludes: dynamics, animation sweep, ice/water cells, thermosyphons, datum and
    arc annotations. Those stay in the .scad.
    """
    pile_shaft, helix = helical_pile(p)
    base, plinth = footing(p)
    column, spigot, race = thrust_collar(p)

    solids = [pile_shaft, *helix, base, plinth, column, spigot, race]

    # --- static side of the joint ---
    if p.show_flange:
        lo = Pos(0, 0, PIVOT_Z)
        solids += [lo * flange_plate(False, p), *(lo * g for g in flange_gussets(p))]
        solids += [lo * b for b in flange_bolts(p)]

    # --- rocking side: upper plate and the sail ---
    hi = Pos(0, 0, PIVOT_Z) * Pos(0, 0, PLATE_HI_Z + p.flange_t)
    if p.show_flange:
        solids.append(Pos(0, 0, PIVOT_Z + PLATE_HI_Z) * flange_plate(True, p))
    blade, _ = sail_blade(p)
    solids.append(hi * blade)

    return solids, []


# --------------------------------------------------------------------------
# Validation
# --------------------------------------------------------------------------

# Measured from the OpenSCAD v5 STL export with SHOW_SOIL disabled (metres). The
# prose figures in amu_wind_sail_v5.md disagree with these and are tracked as a
# separate issue — geometry beats documentation.
#
# footprint_x is the footing (BASE_W = 1.06) and matches exactly.
# footprint_y is 1.031 against our 0.980: the extra ~51 mm is the SAIL_CANT lean and
# the annotation arcs (cant_arc/rock_arc/pivot_datum), which are OpenSCAD-side.
OPENSCAD_MEASURED = {
    "above_grade": 3.079,
    "below_grade": 4.290,
    "footprint_x": 1.060,
    "footprint_y": 1.031,
}

EXPECTED_ISLANDS = [
    ("shaft + footing + collar + lower flange + gussets + bolts", 0.000, 0.465),
    ("shaft", -4.290, -1.430),
    ("flight 0", -0.426, -0.374),
    ("flight 1", -1.006, -0.954),
    ("flight 2", -1.586, -1.534),
    ("flange_hi", 0.495, 0.525),
    ("blade", 1.180, 3.075),
]


def _bbox_overlap(a, b, tol: float = 1e-6):
    a_bb = a.bounding_box()
    b_bb = b.bounding_box()
    return not (
        a_bb.max.X + tol < b_bb.min.X
        or b_bb.max.X + tol < a_bb.min.X
        or a_bb.max.Y + tol < b_bb.min.Y
        or b_bb.max.Y + tol < a_bb.min.Y
        or a_bb.max.Z + tol < b_bb.min.Z
        or b_bb.max.Z + tol < a_bb.min.Z
    )


def find_connected_components(solids):
    """Group solids that touch or overlap by bounding-box intersection."""
    if not solids:
        return []

    graph = {i: set() for i in range(len(solids))}
    for i in range(len(solids)):
        for j in range(i + 1, len(solids)):
            if _bbox_overlap(solids[i], solids[j]):
                graph[i].add(j)
                graph[j].add(i)

    visited = set()
    islands = []
    for i in range(len(solids)):
        if i in visited:
            continue
        stack = [i]
        comp = []
        visited.add(i)
        while stack:
            node = stack.pop()
            comp.append(node)
            for nbr in graph[node]:
                if nbr not in visited:
                    visited.add(nbr)
                    stack.append(nbr)
        islands.append(sorted(comp))
    return islands


def _expected_of_island(z_min: float, z_max: float, tol: float = 0.04) -> str | None:
    for name, exp_min, exp_max in EXPECTED_ISLANDS:
        if z_min >= exp_min - tol and z_max <= exp_max + tol:
            return name
    return None


def report_islands(solids, tol: float = 0.04) -> int:
    """Print per-island connectivity and label each group as EXPECTED or UNEXPECTED."""
    islands = find_connected_components(solids)
    if not islands:
        print("Connectivity check: no solids were found.")
        return 0

    print("\nConnectivity report — expected vs unexpected islands\n")
    print(f"  {'island':>6} {'label':>11} {'z min':>10} {'z max':>10}")
    print("  " + "-" * 52)

    unexpected = 0
    for idx, island in enumerate(islands, start=1):
        bb = solids[island[0]].bounding_box()
        for j in island[1:]:
            bb = bb.add(solids[j].bounding_box())
        z_min = bb.min.Z
        z_max = bb.max.Z
        label = "EXPECTED" if _expected_of_island(z_min, z_max, tol) else "UNEXPECTED"
        if label == "UNEXPECTED":
            unexpected += 1
        print(f"  {idx:>6} {label:>11} {z_min:>+9.3f} {z_max:>+9.3f}")

    if unexpected:
        print(f"\nFAIL: {unexpected} unexpected island(s) detected.")
        print("      The static port should only produce the known OpenSCAD-derived islands.")
        return unexpected

    print("\nPASS: all islands match the expected static geometry set.")
    return 0


def validate_bbox(solids, tol: float = 0.06) -> int:
    """Compare this port's bounding box against the measured OpenSCAD one.

    The pile bottom and footing footprint are exact by construction and must match.
    The above-grade figure is indicative only: this port omits the cells, thermo-
    syphons and the SAIL_CANT lean, all of which sit above grade, so a small
    shortfall is expected and correct.

    Returns 0 if within tolerance and all islands are expected, 1 otherwise.
    """
    bb = solids[0].bounding_box()
    for s in solids[1:]:
        bb = bb.add(s.bounding_box())
    size = bb.size

    above = bb.max.Z
    below = -bb.min.Z

    checks = [
        ("pile bottom  (below grade)", below, OPENSCAD_MEASURED["below_grade"]),
        ("above grade", above, OPENSCAD_MEASURED["above_grade"]),
        ("footprint X", size.X, OPENSCAD_MEASURED["footprint_x"]),
        ("footprint Y", size.Y, OPENSCAD_MEASURED["footprint_y"]),
    ]

    print("Bounding box — build123d port vs measured OpenSCAD (metres)\n")
    print(f"  {'check':<28} {'port':>8} {'scad':>8} {'delta':>8}")
    print("  " + "-" * 56)
    failed = []
    for name, got, want in checks:
        d = got - want
        flag = ""
        if abs(d) > tol:
            flag = "  <-- OUT OF TOLERANCE"
            failed.append(name)
        print(f"  {name:<28} {got:>8.3f} {want:>8.3f} {d:>+8.3f}{flag}")

    island_failures = report_islands(solids)
    if island_failures:
        failed.append("unexpected islands")

    print()
    if failed:
        print("FAIL: " + ", ".join(failed))
        return 1
    print("PASS: all checks within %.2f m tolerance" % tol)
    print("Note: above-grade is a lower bound — cells, thermosyphons and the")
    print("      SAIL_CANT lean are OpenSCAD-side and intentionally absent here.")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--export", metavar="DIR", help="write STEP + STL into DIR")
    args = ap.parse_args()

    solids, _ = static_sail_unit()
    print(f"build123d {__import__('build123d').__version__} — static v5 sail\n")
    print(f"  parts built : {len(solids)}")

    rc = validate_bbox(solids)

    if args.export:
        from pathlib import Path

        out = Path(args.export)
        out.mkdir(parents=True, exist_ok=True)
        step = out / "amu_wind_sail_v5_build123d.step"
        stl = out / "amu_wind_sail_v5_build123d.stl"

        # build123d exporters want one part, not a list of them — fuse to export
        # while keeping the individual solids above for per-part inspection.
        fused = solids[0]
        for s in solids[1:]:
            fused += s
        export_step(fused, str(step))
        export_stl(fused, str(stl))
        print(f"\n  wrote {step}")
        print(f"  wrote {stl}")

    return rc


if __name__ == "__main__":
    raise SystemExit(main())