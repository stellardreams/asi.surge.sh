#!/usr/bin/env python3
"""
wind_v3_container_stowage.py - Parametric FreeCAD Solid Model for 20 ft ISO Container Stowage (v3.1)

=============================================================================
METADATA & SPECIFICATION TRACEABILITY
=============================================================================
__version__     = "3.1.0"
__revision__    = "v3.1.0-subsystem-breakdown"
__author__      = "Stellar Dreams Engineering"
__date__        = "2026-10-17"
__target_spec__ = "Intermodal Container Packing Architecture (Package 6 under Issues #104 and #82)"
__kernel__      = "OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module"
__lineage__     = "FreeCAD component breakdown evolved from OpenSCAD wind_v2_container_stowage.scad"
=============================================================================
"""

import sys
import os

for lib_path in ["/usr/lib/freecad/lib", "/usr/lib/freecad-python3/lib"]:
    if os.path.exists(lib_path) and lib_path not in sys.path:
        sys.path.append(lib_path)

import FreeCAD
import Part

CONT_L = 5.898   # Internal length
CONT_W = 2.352   # Internal width
CONT_H = 2.393   # Internal height


def build_container_stowage_solid():
    """Builds the 20ft ISO container stowage package with racked turbine components."""
    solids = []

    # 1. Container Floor and Structural Corner Posts
    floor_slab = Part.makeBox(CONT_L, CONT_W, 0.14, FreeCAD.Vector(-CONT_L / 2.0, -CONT_W / 2.0, 0.0))
    solids.append(floor_slab)

    # 4x Vertical Corner Posts
    for sx in [-1.0, 1.0]:
        for sy in [-1.0, 1.0]:
            px = sx * (CONT_L / 2.0 - 0.12) if sx > 0 else -CONT_L / 2.0
            py = sy * (CONT_W / 2.0 - 0.12) if sy > 0 else -CONT_W / 2.0
            post = Part.makeBox(0.12, 0.12, CONT_H, FreeCAD.Vector(px, py, 0.14))
            solids.append(post)

    # 2. Stowed Sectional Mast Pipes (5x Ø0.508 m x 4.80 m segments bundled longitudinally)
    mast_r = 0.254
    mast_len = 4.80
    for row in range(2):
        for col in range(3):
            if row == 1 and col == 2:
                continue  # 5 segments total (3 on bottom, 2 on top)
            my = -CONT_W / 2.0 + 0.35 + col * 0.56
            mz = 0.14 + 0.32 + row * 0.54
            pipe = Part.makeCylinder(mast_r, mast_len, FreeCAD.Vector(-CONT_L / 2.0 + 0.20, my, mz), FreeCAD.Vector(1, 0, 0))
            solids.append(pipe)

    # 3. Stowed Segmented Blade Cassettes (21x <= 1.90 m blade sleeves)
    # Arranged vertically in slotted stanchion racks
    rack_w = 0.90
    rack_l = 2.20
    for i in range(7):
        bx = -CONT_L / 2.0 + 0.30 + i * 0.28
        blade_sleeve = Part.makeBox(0.18, 0.85, 1.85, FreeCAD.Vector(bx, CONT_W / 2.0 - 0.95, 0.14))
        solids.append(blade_sleeve)

    # 4. Stowed Nacelle Tophead on Transit Skid
    skid = Part.makeBox(3.20, 1.20, 0.20, FreeCAD.Vector(CONT_L / 2.0 - 3.40, -0.60, 0.14))
    nacelle_stowed = Part.makeCylinder(0.55, 3.00, FreeCAD.Vector(CONT_L / 2.0 - 3.30, 0, 0.90), FreeCAD.Vector(1, 0, 0))
    solids.append(skid.fuse(nacelle_stowed))

    # 5. Stowed Gin-Pole Erection Winch Pack & Cable Reels
    winch_pack = Part.makeBox(0.80, 0.90, 0.70, FreeCAD.Vector(CONT_L / 2.0 - 1.00, -CONT_W / 2.0 + 0.25, 0.14))
    solids.append(winch_pack)

    compound = solids[0]
    for s in solids[1:]:
        compound = compound.fuse(s)
    return compound


if __name__ == "__main__":
    print("Building Wind Turbine v3.1 Container Stowage Subsystem...")
    solid = build_container_stowage_solid()
    print(f"Valid B-Rep Solid: {solid.isValid()} | Faces: {len(solid.Faces)} | Volume: {solid.Volume:.2f} m³")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    out_step = os.path.join(script_dir, "..", "..", "step_exports", "wind_v3_container_stowage.step")
    os.makedirs(os.path.dirname(out_step), exist_ok=True)
    solid.exportStep(out_step)
    print(f"✅ Exported: {out_step} ({os.path.getsize(out_step):,} bytes)")
