#!/usr/bin/env python3
"""
wind_v3_mast_erection.py - Parametric FreeCAD Solid Model for Sectional Mast & Gin-Pole Rigging (v3.1)

=============================================================================
METADATA & SPECIFICATION TRACEABILITY
=============================================================================
__version__     = "3.1.0"
__revision__    = "v3.1.0-subsystem-breakdown"
__author__      = "Stellar Dreams Engineering"
__date__        = "2026-10-17"
__target_spec__ = "Modular Arctic Mast & Erection Rigging (Package 2 under Issues #104 and #82)"
__kernel__      = "OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module"
__lineage__     = "FreeCAD component breakdown evolved from OpenSCAD wind_v2_mast_erection.scad"
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

CONT_L        = 6.058
CONT_W        = 2.438
CONT_H        = 2.591
OUTRIGGER_EXT = 2.20
PAD_THICK     = 0.18

MAST_H        = 24.0
MAST_D        = 0.508
SECTIONS_COUNT= 5
GUY_RING_Z    = 16.0
GUY_CABLE_D   = 0.024


def build_mast_erection_solid():
    """Builds sectional tubular mast, guy ring with clevises/turnbuckles, and gin-pole winch rigging."""
    solids = []

    # 1. Sectional Tubular Steel Mast (24.0 m)
    mast = Part.makeCylinder(MAST_D / 2.0, MAST_H, FreeCAD.Vector(0, 0, CONT_H), FreeCAD.Vector(0, 0, 1))
    solids.append(mast)

    # 4x Sectional Flange Rings
    sec_len = MAST_H / float(SECTIONS_COUNT)
    for s in range(1, SECTIONS_COUNT):
        fz = CONT_H + s * sec_len
        flange = Part.makeCylinder(MAST_D / 2.0 + 0.12, 0.14, FreeCAD.Vector(0, 0, fz - 0.07), FreeCAD.Vector(0, 0, 1))
        solids.append(flange)

    # 2. Guy Wire Tension Collar at z = 16.0 m
    collar_z = CONT_H + GUY_RING_Z
    guy_ring = Part.makeCylinder(MAST_D / 2.0 + 0.18, 0.35, FreeCAD.Vector(0, 0, collar_z), FreeCAD.Vector(0, 0, 1))
    solids.append(guy_ring)

    # 3. 4x Guy Cables with Radial Clevis Lugs and Dual Turnbuckles
    for sign_x in [-1.0, 1.0]:
        for sign_y in [-1.0, 1.0]:
            anchor_x = sign_x * (CONT_L / 2.0 - 0.60)
            anchor_y = sign_y * (CONT_W / 2.0 + OUTRIGGER_EXT - 0.25)
            anchor_z = PAD_THICK

            collar_pt = FreeCAD.Vector(sign_x * 0.38, sign_y * 0.38, collar_z + 0.17)
            target_pt = FreeCAD.Vector(anchor_x, anchor_y, anchor_z + 0.16)
            cable_vec = target_pt - collar_pt
            cable_len = cable_vec.Length

            lug_ear = Part.makeBox(0.14, 0.14, 0.20, FreeCAD.Vector(sign_x * 0.32 - 0.07, sign_y * 0.32 - 0.07, collar_z + 0.07))
            tb_upper = Part.makeCylinder(0.045, 0.45, collar_pt, cable_vec)
            tb_lower_pt = target_pt - cable_vec * (0.50 / cable_len)
            tb_lower = Part.makeCylinder(0.045, 0.45, tb_lower_pt, cable_vec)
            cable = Part.makeCylinder(GUY_CABLE_D / 2.0, cable_len, collar_pt, cable_vec)

            solids.append(lug_ear.fuse(tb_upper).fuse(tb_lower).fuse(cable))

    # 4. Container Roof Crane-Less Gin-Pole Erection Rigging
    trunnion_l = Part.makeBox(0.24, 0.22, 0.26, FreeCAD.Vector(0.68, -0.81, CONT_H))
    trunnion_r = Part.makeBox(0.24, 0.22, 0.26, FreeCAD.Vector(0.68, 0.59, CONT_H))
    gin_pole_l = Part.makeCylinder(0.08, 4.20, FreeCAD.Vector(0.80, -0.70, CONT_H + 0.13), FreeCAD.Vector(-0.25, 0.15, 1.0))
    gin_pole_r = Part.makeCylinder(0.08, 4.20, FreeCAD.Vector(0.80, 0.70, CONT_H + 0.13), FreeCAD.Vector(-0.25, -0.15, 1.0))

    apex_z = CONT_H + 0.13 + 4.20 * (1.0 / math.sqrt(0.25**2 + 0.15**2 + 1.0))
    apex_x = 0.80 - 4.20 * (0.25 / math.sqrt(0.25**2 + 0.15**2 + 1.0))
    sheave_wheel = Part.makeCylinder(0.14, 0.10, FreeCAD.Vector(apex_x, -0.05, apex_z - 0.05), FreeCAD.Vector(0, 1, 0))
    apex_cross = Part.makeCylinder(0.06, 0.40, FreeCAD.Vector(apex_x, -0.20, apex_z), FreeCAD.Vector(0, 1, 0))

    winch_frame = Part.makeBox(0.60, 0.70, 0.50, FreeCAD.Vector(1.40, -0.35, CONT_H))
    winch_drum  = Part.makeCylinder(0.16, 0.40, FreeCAD.Vector(1.50, -0.20, CONT_H + 0.25), FreeCAD.Vector(0, 1, 0))
    winch_motor = Part.makeCylinder(0.13, 0.25, FreeCAD.Vector(1.50, 0.20, CONT_H + 0.25), FreeCAD.Vector(0, 1, 0))

    lift_collar_z = CONT_H + 6.0
    lift_collar = Part.makeCylinder(MAST_D / 2.0 + 0.10, 0.28, FreeCAD.Vector(0, 0, lift_collar_z), FreeCAD.Vector(0, 0, 1))

    hoist_to_apex = Part.makeCylinder(0.016, math.sqrt((apex_x - 1.50)**2 + (apex_z - (CONT_H + 0.25))**2),
                                      FreeCAD.Vector(1.50, 0, CONT_H + 0.25),
                                      FreeCAD.Vector(apex_x - 1.50, 0, apex_z - (CONT_H + 0.25)))
    hoist_to_mast = Part.makeCylinder(0.016, math.sqrt((0 - apex_x)**2 + (lift_collar_z - apex_z)**2),
                                      FreeCAD.Vector(apex_x, 0, apex_z),
                                      FreeCAD.Vector(-apex_x, 0, lift_collar_z - apex_z))

    gin_rigging = trunnion_l.fuse(trunnion_r).fuse(gin_pole_l).fuse(gin_pole_r).fuse(apex_cross).fuse(sheave_wheel).fuse(winch_frame).fuse(winch_drum).fuse(winch_motor).fuse(lift_collar).fuse(hoist_to_apex).fuse(hoist_to_mast)
    solids.append(gin_rigging)

    compound = solids[0]
    for s in solids[1:]:
        compound = compound.fuse(s)
    return compound


if __name__ == "__main__":
    print("Building Wind Turbine v3.1 Mast & Erection Rigging Subsystem...")
    solid = build_mast_erection_solid()
    print(f"Valid B-Rep Solid: {solid.isValid()} | Faces: {len(solid.Faces)} | Volume: {solid.Volume:.2f} m³")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    out_step = os.path.join(script_dir, "..", "..", "step_exports", "wind_v3_mast_erection.step")
    os.makedirs(os.path.dirname(out_step), exist_ok=True)
    solid.exportStep(out_step)
    print(f"✅ Exported: {out_step} ({os.path.getsize(out_step):,} bytes)")
