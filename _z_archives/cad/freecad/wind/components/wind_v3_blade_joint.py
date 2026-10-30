#!/usr/bin/env python3
"""
wind_v3_blade_joint.py - Parametric FreeCAD Solid Model for NACA Airfoil Blade & Sleeve Joints (v3.1)

=============================================================================
METADATA & SPECIFICATION TRACEABILITY
=============================================================================
__version__     = "3.1.0"
__revision__    = "v3.1.0-subsystem-breakdown"
__author__      = "Stellar Dreams Engineering"
__date__        = "2026-10-17"
__target_spec__ = "Segmented Arctic Rotor & Blade Joint (Package 4 under Issues #104 and #82)"
__kernel__      = "OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module"
__lineage__     = "FreeCAD component breakdown evolved from OpenSCAD wind_v2_blade_joint.scad"
=============================================================================
"""

import sys
import os
import math

for lib_path in ["/usr/lib/freecad/lib", "/usr/lib/freecad-python3/lib"]:
    if os.path.exists(lib_path) and lib_path not in sys.path:
        sys.path.append(lib_path)

import FreeCAD
import Part

BLADE_SPAN       = 12.0    # Blade length
BLADE_ROOT_CHORD = 1.20    # Max chord at root
BLADE_TIP_CHORD  = 0.45    # Min chord at tip
BLADE_SECTIONS   = 7       # 7 modular segments (<= 1.90 m each)


def make_airfoil_wire(chord, thickness=0.18, z=0.0, twist_deg=0.0, n_pts=28):
    """Generates a closed NACA 4-digit airfoil wire scaled and twisted at elevation z."""
    pts_upper = []
    pts_lower = []
    for i in range(n_pts + 1):
        xc = i / float(n_pts)
        yt = 5.0 * thickness * (
            0.2969 * math.sqrt(xc)
            - 0.1260 * xc
            - 0.3516 * (xc ** 2)
            + 0.2843 * (xc ** 3)
            - 0.1036 * (xc ** 4)
        )
        x_local = (xc - 0.25) * chord
        y_upper = yt * chord
        y_lower = -yt * chord

        rad = math.radians(twist_deg)
        cos_t, sin_t = math.cos(rad), math.sin(rad)
        xu = x_local * cos_t - y_upper * sin_t
        yu = x_local * sin_t + y_upper * cos_t
        xl = x_local * cos_t - y_lower * sin_t
        yl = x_local * sin_t + y_lower * cos_t

        pts_upper.append(FreeCAD.Vector(xu, yu, z))
        pts_lower.append(FreeCAD.Vector(xl, yl, z))

    poly_pts = pts_upper + pts_lower[::-1][1:] + [pts_upper[0]]
    return Part.makePolygon(poly_pts)


def build_blade_joint_solid():
    """Builds the 12m NACA aerodynamic lofted blade with 7 structural sleeve joints and root flange."""
    w_root = make_airfoil_wire(chord=BLADE_ROOT_CHORD, thickness=0.21, z=0.40, twist_deg=10.0, n_pts=28)
    w_st1  = make_airfoil_wire(chord=1.05, thickness=0.18, z=3.80, twist_deg=6.5, n_pts=28)
    w_st2  = make_airfoil_wire(chord=0.75, thickness=0.16, z=8.00, twist_deg=3.2, n_pts=28)
    w_tip  = make_airfoil_wire(chord=BLADE_TIP_CHORD, thickness=0.14, z=BLADE_SPAN, twist_deg=0.8, n_pts=28)

    airfoil_solid = Part.makeLoft([w_root, w_st1, w_st2, w_tip], True)

    # Circular root flange with pitch bearing adapter
    root_flange = Part.makeCylinder(0.32, 0.42, FreeCAD.Vector(0, 0, 0.0), FreeCAD.Vector(0, 0, 1))
    blade = airfoil_solid.fuse(root_flange)

    # 7 Modular Structural Sleeve Joint Collars
    seg_step = BLADE_SPAN / float(BLADE_SECTIONS)
    for s in range(1, BLADE_SECTIONS):
        sz = s * seg_step
        chord_at_s = BLADE_ROOT_CHORD - (BLADE_ROOT_CHORD - BLADE_TIP_CHORD) * (sz / BLADE_SPAN)
        collar_w = chord_at_s * 1.08
        collar = Part.makeBox(collar_w, 0.22, 0.08, FreeCAD.Vector(-collar_w * 0.35, -0.11, sz - 0.04))
        blade = blade.fuse(collar)

    return blade


if __name__ == "__main__":
    print("Building Wind Turbine v3.1 Blade & Sleeve Joint Subsystem...")
    solid = build_blade_joint_solid()
    print(f"Valid B-Rep Solid: {solid.isValid()} | Faces: {len(solid.Faces)} | Volume: {solid.Volume:.2f} m³")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    out_step = os.path.join(script_dir, "..", "..", "step_exports", "wind_v3_blade_joint.step")
    os.makedirs(os.path.dirname(out_step), exist_ok=True)
    solid.exportStep(out_step)
    print(f"✅ Exported: {out_step} ({os.path.getsize(out_step):,} bytes)")
