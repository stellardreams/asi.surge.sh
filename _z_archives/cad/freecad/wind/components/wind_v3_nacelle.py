#!/usr/bin/env python3
"""
wind_v3_nacelle.py - Parametric FreeCAD Solid Model for Direct-Drive Arctic Nacelle & Hub (v3.1)

=============================================================================
METADATA & SPECIFICATION TRACEABILITY
=============================================================================
__version__     = "3.1.0"
__revision__    = "v3.1.0-subsystem-breakdown"
__author__      = "Stellar Dreams Engineering"
__date__        = "2026-10-17"
__target_spec__ = "Direct-Drive Arctic Powertrain (Package 3 under Issues #104 and #82)"
__kernel__      = "OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module"
__lineage__     = "FreeCAD component breakdown evolved from OpenSCAD wind_v2_nacelle.scad"
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

NACELLE_L   = 3.40    # Insulated nacelle housing length
NACELLE_D   = 1.35    # Nacelle outer diameter
NOSE_CONE_L = 0.65    # Rime-ice shedding nose cone length
HUB_D       = 1.10    # Rotor hub barrel diameter


def build_nacelle_solid():
    """Builds the insulated nacelle, direct-drive generator core, yaw collar, hub, and spinner."""
    solids = []

    # 1. Insulated Nacelle Housing (centered at origin along X axis)
    nacelle_body = Part.makeCylinder(
        NACELLE_D / 2.0, NACELLE_L,
        FreeCAD.Vector(-NACELLE_L * 0.68, 0, 0), FreeCAD.Vector(1, 0, 0)
    )
    rear_cowl = Part.makeCone(
        NACELLE_D / 2.0, 0.30, 0.85,
        FreeCAD.Vector(-NACELLE_L * 0.68, 0, 0), FreeCAD.Vector(-1, 0, 0)
    )
    solids.append(nacelle_body.fuse(rear_cowl))

    # 2. Yaw Bearing Turret Base & Dual Yaw Motors
    yaw_base = Part.makeCylinder(0.42, 0.35, FreeCAD.Vector(-0.25, 0, -NACELLE_D / 2.0 - 0.25), FreeCAD.Vector(0, 0, 1))
    for ym in [-0.28, 0.28]:
        yaw_motor = Part.makeCylinder(0.10, 0.30, FreeCAD.Vector(-0.25, ym, -NACELLE_D / 2.0 - 0.20), FreeCAD.Vector(0, 0, 1))
        yaw_base = yaw_base.fuse(yaw_motor)
    solids.append(yaw_base)

    # 3. Direct-Drive Generator Stator Core Ribs
    for gx in [-0.40, 0.10]:
        stator_rib = Part.makeCylinder(NACELLE_D / 2.0 + 0.04, 0.18, FreeCAD.Vector(gx, 0, 0), FreeCAD.Vector(1, 0, 0))
        solids.append(stator_rib)

    # 4. Central Rotor Hub Barrel
    spinner_x = NACELLE_L * 0.32
    hub_barrel = Part.makeCylinder(HUB_D / 2.0, 0.55, FreeCAD.Vector(spinner_x, 0, 0), FreeCAD.Vector(1, 0, 0))
    
    # 3x Blade Root Pitch Flange Mounting Bosses (120° apart)
    for i in range(3):
        angle = i * (2.0 * math.pi / 3.0)
        by = (HUB_D / 2.0 - 0.05) * math.cos(angle)
        bz = (HUB_D / 2.0 - 0.05) * math.sin(angle)
        boss = Part.makeCylinder(0.24, 0.15, FreeCAD.Vector(spinner_x + 0.28, by, bz), FreeCAD.Vector(0, math.cos(angle), math.sin(angle)))
        hub_barrel = hub_barrel.fuse(boss)
    solids.append(hub_barrel)

    # 5. Anti-Icing Nose Spinner Cone
    spinner_cone = Part.makeCone(
        HUB_D / 2.0, 0.12, NOSE_CONE_L,
        FreeCAD.Vector(spinner_x + 0.55, 0, 0), FreeCAD.Vector(1, 0, 0)
    )
    solids.append(spinner_cone)

    compound = solids[0]
    for s in solids[1:]:
        compound = compound.fuse(s)
    return compound


if __name__ == "__main__":
    print("Building Wind Turbine v3.1 Nacelle & Powertrain Subsystem...")
    solid = build_nacelle_solid()
    print(f"Valid B-Rep Solid: {solid.isValid()} | Faces: {len(solid.Faces)} | Volume: {solid.Volume:.2f} m³")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    out_step = os.path.join(script_dir, "..", "..", "step_exports", "wind_v3_nacelle.step")
    os.makedirs(os.path.dirname(out_step), exist_ok=True)
    solid.exportStep(out_step)
    print(f"✅ Exported: {out_step} ({os.path.getsize(out_step):,} bytes)")
