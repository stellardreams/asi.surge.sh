#!/usr/bin/env python3
"""
wind_v3_foundation.py - Parametric FreeCAD Solid Model for Wind Turbine Foundation Sled & Outriggers (v3.1)

=============================================================================
METADATA & SPECIFICATION TRACEABILITY
=============================================================================
__version__     = "3.1.0"
__revision__    = "v3.1.0-subsystem-breakdown"
__author__      = "Stellar Dreams Engineering"
__date__        = "2026-10-17"
__target_spec__ = "Modular Arctic Foundation Architecture (Package 1 under Issues #104 and #82)"
__kernel__      = "OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module"
__lineage__     = "FreeCAD component breakdown evolved from OpenSCAD wind_v2_foundation.scad"
=============================================================================
"""

import sys
import os

for lib_path in ["/usr/lib/freecad/lib", "/usr/lib/freecad-python3/lib"]:
    if os.path.exists(lib_path) and lib_path not in sys.path:
        sys.path.append(lib_path)

import FreeCAD
import Part

CONT_L        = 6.058   # 20 ft ISO container length
CONT_W        = 2.438   # 20 ft ISO container width
CONT_H        = 2.591   # 20 ft ISO container height
OUTRIGGER_W   = 0.40    # Outrigger beam width
OUTRIGGER_EXT = 2.20    # Outrigger lateral extension
PAD_RADIUS    = 0.45    # Ground bearing pad radius
PAD_THICK     = 0.18    # Pad thickness


def build_foundation_solid():
    """Builds the 20ft container foundation sled and 4x deployable outriggers."""
    solids = []

    # 1. 20 ft ISO Container Foundation Sled Hull
    cont_box = Part.makeBox(CONT_L, CONT_W, CONT_H, FreeCAD.Vector(-CONT_L / 2.0, -CONT_W / 2.0, 0.0))
    solids.append(cont_box)

    # 2. 8x ISO Corner Castings
    for sx in [-1.0, 1.0]:
        for sy in [-1.0, 1.0]:
            for sz in [0.0, CONT_H - 0.30]:
                cx = sx * (CONT_L / 2.0 - 0.30) if sx > 0 else -CONT_L / 2.0
                cy = sy * (CONT_W / 2.0 - 0.30) if sy > 0 else -CONT_L / 2.0
                corner = Part.makeBox(0.30, 0.30, 0.30, FreeCAD.Vector(cx, cy, sz))
                solids.append(corner)

    # 3. 4x Deployable Outriggers with Bearing Pads & Helical Anchor Caps
    for sign_x in [-1.0, 1.0]:
        for sign_y in [-1.0, 1.0]:
            ox = sign_x * (CONT_L / 2.0 - 0.60)
            oy = sign_y * (CONT_W / 2.0)
            beam_y = min(oy, oy + sign_y * OUTRIGGER_EXT)
            beam = Part.makeBox(OUTRIGGER_W, OUTRIGGER_EXT, 0.28, FreeCAD.Vector(ox - OUTRIGGER_W / 2.0, beam_y, 0.12))
            
            # Hinge locking shear pin boss
            hinge_pin = Part.makeCylinder(0.06, 0.35, FreeCAD.Vector(ox, oy, 0.10), FreeCAD.Vector(1, 0, 0))
            
            # Ground bearing footpad
            pad_y = oy + sign_y * (OUTRIGGER_EXT - 0.25)
            pad = Part.makeCylinder(PAD_RADIUS, PAD_THICK, FreeCAD.Vector(ox, pad_y, 0.0), FreeCAD.Vector(0, 0, 1))
            
            # Central helical screw anchor drive cap
            helical_cap = Part.makeCylinder(0.12, 0.14, FreeCAD.Vector(ox, pad_y, PAD_THICK), FreeCAD.Vector(0, 0, 1))
            
            # Guy cable D-ring anchor bracket
            dring_bracket = Part.makeBox(0.12, 0.12, 0.16, FreeCAD.Vector(ox - 0.06, pad_y - 0.06, PAD_THICK))
            
            solids.append(beam.fuse(hinge_pin).fuse(pad).fuse(helical_cap).fuse(dring_bracket))

    # 4. Central Roof Base Ring Adapter
    base_ring = Part.makeCylinder(0.38, 0.12, FreeCAD.Vector(0, 0, CONT_H), FreeCAD.Vector(0, 0, 1))
    solids.append(base_ring)

    compound = solids[0]
    for s in solids[1:]:
        compound = compound.fuse(s)
    return compound


if __name__ == "__main__":
    print("Building Wind Turbine v3.1 Foundation Sled Subsystem...")
    solid = build_foundation_solid()
    print(f"Valid B-Rep Solid: {solid.isValid()} | Faces: {len(solid.Faces)} | Volume: {solid.Volume:.2f} m³")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    out_step = os.path.join(script_dir, "..", "..", "step_exports", "wind_v3_foundation.step")
    os.makedirs(os.path.dirname(out_step), exist_ok=True)
    solid.exportStep(out_step)
    print(f"✅ Exported: {out_step} ({os.path.getsize(out_step):,} bytes)")
