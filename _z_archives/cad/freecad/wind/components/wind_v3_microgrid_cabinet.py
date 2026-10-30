#!/usr/bin/env python3
"""
wind_v3_microgrid_cabinet.py - Parametric FreeCAD Solid Model for Arctic Microgrid Power Bay (v3.1)

=============================================================================
METADATA & SPECIFICATION TRACEABILITY
=============================================================================
__version__     = "3.1.0"
__revision__    = "v3.1.0-subsystem-breakdown"
__author__      = "Stellar Dreams Engineering"
__date__        = "2026-10-17"
__target_spec__ = "Autonomous Arctic Microgrid Conversion Bay (Package 5 under Issues #104 and #82)"
__kernel__      = "OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module"
__lineage__     = "FreeCAD component breakdown evolved from OpenSCAD wind_v2_microgrid_cabinet.scad"
=============================================================================
"""

import sys
import os

for lib_path in ["/usr/lib/freecad/lib", "/usr/lib/freecad-python3/lib"]:
    if os.path.exists(lib_path) and lib_path not in sys.path:
        sys.path.append(lib_path)

import FreeCAD
import Part

CAB_L = 0.90   # Depth
CAB_W = 1.40   # Width
CAB_H = 1.80   # Height


def build_microgrid_cabinet_solid():
    """Builds the weatherproof NEMA 4X / IP66 microgrid power cabinet."""
    solids = []

    # 1. Main Enclosure Hull
    main_box = Part.makeBox(CAB_L, CAB_W, CAB_H, FreeCAD.Vector(-CAB_L / 2.0, -CAB_W / 2.0, 0.0))
    solids.append(main_box)

    # 2. Dual Front Access Doors with Sealing Flanges
    door_l = Part.makeBox(0.04, CAB_W * 0.46, CAB_H * 0.88, FreeCAD.Vector(CAB_L / 2.0, -CAB_W * 0.48, CAB_H * 0.06))
    door_r = Part.makeBox(0.04, CAB_W * 0.46, CAB_H * 0.88, FreeCAD.Vector(CAB_L / 2.0, 0.02, CAB_H * 0.06))
    
    # Recessed door handles
    handle_l = Part.makeBox(0.05, 0.04, 0.16, FreeCAD.Vector(CAB_L / 2.0 + 0.04, -0.06, CAB_H * 0.50))
    handle_r = Part.makeBox(0.05, 0.04, 0.16, FreeCAD.Vector(CAB_L / 2.0 + 0.04, 0.02, CAB_H * 0.50))
    solids.append(door_l.fuse(door_r).fuse(handle_l).fuse(handle_r))

    # 3. Touchscreen HMI Panel on Front Face
    hmi_bezel = Part.makeBox(0.03, 0.38, 0.28, FreeCAD.Vector(CAB_L / 2.0 + 0.04, -0.38, CAB_H * 0.65))
    solids.append(hmi_bezel)

    # 4. Lateral Heat-Sink Cooling Fins (Left & Right Sides)
    for sign_y in [-1.0, 1.0]:
        fy = sign_y * (CAB_W / 2.0)
        for i in range(8):
            fz = 0.30 + i * 0.16
            fin = Part.makeBox(CAB_L * 0.70, 0.04, 0.05, FreeCAD.Vector(-CAB_L * 0.35, fy - 0.02 if sign_y < 0 else fy - 0.02, fz))
            solids.append(fin)

    # 5. Top Grid-Synchronization Status Beacon
    beacon_base = Part.makeCylinder(0.08, 0.06, FreeCAD.Vector(0, 0, CAB_H), FreeCAD.Vector(0, 0, 1))
    beacon_dome = Part.makeCylinder(0.06, 0.12, FreeCAD.Vector(0, 0, CAB_H + 0.06), FreeCAD.Vector(0, 0, 1))
    solids.append(beacon_base.fuse(beacon_dome))

    # 6. Container Bulkhead Structural Mounting Channels
    channel_top = Part.makeBox(0.06, CAB_W + 0.10, 0.10, FreeCAD.Vector(-CAB_L / 2.0 - 0.06, -CAB_W / 2.0 - 0.05, CAB_H - 0.20))
    channel_bot = Part.makeBox(0.06, CAB_W + 0.10, 0.10, FreeCAD.Vector(-CAB_L / 2.0 - 0.06, -CAB_W / 2.0 - 0.05, 0.10))
    solids.append(channel_top.fuse(channel_bot))

    # 7. Bottom Conduit Gland Penetrations
    gland_plate = Part.makeBox(CAB_L * 0.50, CAB_W * 0.40, 0.04, FreeCAD.Vector(-CAB_L * 0.25, -CAB_W * 0.20, -0.04))
    solids.append(gland_plate)

    compound = solids[0]
    for s in solids[1:]:
        compound = compound.fuse(s)
    return compound


if __name__ == "__main__":
    print("Building Wind Turbine v3.1 Microgrid Cabinet Subsystem...")
    solid = build_microgrid_cabinet_solid()
    print(f"Valid B-Rep Solid: {solid.isValid()} | Faces: {len(solid.Faces)} | Volume: {solid.Volume:.2f} m³")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    out_step = os.path.join(script_dir, "..", "..", "step_exports", "wind_v3_microgrid_cabinet.step")
    os.makedirs(os.path.dirname(out_step), exist_ok=True)
    solid.exportStep(out_step)
    print(f"✅ Exported: {out_step} ({os.path.getsize(out_step):,} bytes)")
