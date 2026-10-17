#!/usr/bin/env python3
"""
amu_heritage_orbital_v1.py - Parametric FreeCAD/Python Solid Model for AMU Heritage Orbital Spacecraft (v1.0)

Lineage:
- Ported from OpenSCAD: cad_and_blender/openscad/opencode/amu_heritage_opencode_v1.scad
- Governing Issues: #5 (Heritage Orbital Core), #18 (FreeCAD Transition Program), #101 (Model Registry)
- Solid Kernel: OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module

Features:
- Primary cylindrical MMS manufacturing hull (Length = 17.92 m, Radius = 6.0 m)
- Modular external spine transport rail (Length = 30.0 m)
- Four-tier deployable solar wing arrays with structural outriggers
- APAS/PMA-2 docking collar and logistical payload airlocks
"""

import sys
import os

# -----------------------------------------------------------------------------
# Module Metadata & Semantic Versioning
# -----------------------------------------------------------------------------
__version__     = "1.0.0"
__revision__    = "v1.0.0-baseline"
__author__      = "Stellar Dreams Engineering"
__date__        = "2026-10-17"
__target_spec__ = "AMU Heritage MMS Orbital Spacecraft Hull & Spine Assembly (v1.0)"
__kernel__      = "OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module"
__lineage__     = "cad_and_blender/openscad/opencode/amu_heritage_opencode_v1.scad"

# Ensure FreeCAD library is accessible
for lib_path in ["/usr/lib/freecad/lib", "/usr/lib/freecad-python3/lib"]:
    if os.path.exists(lib_path) and lib_path not in sys.path:
        sys.path.append(lib_path)

import FreeCAD
import Part

# -----------------------------------------------------------------------------
# Parametric Dimensions (Meters)
# -----------------------------------------------------------------------------
MMS_RADIUS   = 6.0    # Hull radius
MMS_LENGTH   = 17.92  # Hull length
WALL_THICK   = 0.40   # Outer hull skin thickness
SPINE_LENGTH = 30.0   # Structural transport rail spine length

SOLAR_W      = 7.0    # Solar panel width
SOLAR_H      = 3.5    # Solar panel height
SOLAR_OFFSET = 9.0    # Offset from spacecraft center


def build_amu_heritage_orbital():
    """Generates the primary cylindrical hull, spine, solar wings, and docking collars."""
    solids = []

    # 1. Main Pressurized Cylindrical Hull (MMS Core)
    outer_hull = Part.makeCylinder(MMS_RADIUS, MMS_LENGTH, FreeCAD.Vector(-MMS_LENGTH/2.0, 0, 0), FreeCAD.Vector(1, 0, 0))
    inner_bay = Part.makeCylinder(MMS_RADIUS - WALL_THICK, MMS_LENGTH - 1.2, FreeCAD.Vector(-(MMS_LENGTH - 1.2)/2.0, 0, 0), FreeCAD.Vector(1, 0, 0))
    mms_hull = outer_hull.cut(inner_bay)
    solids.append(mms_hull)

    # 2. Fore and Aft Endcap Bulkheads with APAS-95 Docking Rings
    for sign_x in [-1.0, 1.0]:
        bulkhead = Part.makeCylinder(MMS_RADIUS - 0.05, 0.40, FreeCAD.Vector(sign_x * (MMS_LENGTH/2.0 - 0.20), 0, 0), FreeCAD.Vector(sign_x, 0, 0))
        # Center APAS hatch tunnel
        collar = Part.makeCylinder(1.55, 0.60, FreeCAD.Vector(sign_x * (MMS_LENGTH/2.0 - 0.10), 0, 0), FreeCAD.Vector(sign_x, 0, 0))
        collar_bore = Part.makeCylinder(1.22, 0.70, FreeCAD.Vector(sign_x * (MMS_LENGTH/2.0 - 0.15), 0, 0), FreeCAD.Vector(sign_x, 0, 0))
        dock_ring = collar.cut(collar_bore)
        solids.append(bulkhead.fuse(dock_ring))

    # 3. Ventral Structural Spine Transport Rails
    y_out = 1.2
    for dz in [-0.60, 0.60]:
        rail = Part.makeCylinder(0.18, SPINE_LENGTH, FreeCAD.Vector(-SPINE_LENGTH/2.0, y_out, dz), FreeCAD.Vector(1, 0, 0))
        solids.append(rail)

    # Stanchions connecting spine to hull
    for sx in [-12.0, -6.0, 0.0, 6.0, 12.0]:
        post = Part.makeBox(0.30, y_out, 1.40, FreeCAD.Vector(sx - 0.15, 0.0, -0.70))
        solids.append(post)

    # 4. Articulating Solar Wing Arrays (4 Tiers)
    panel_thick = 0.08
    for sign_y in [-1.0, 1.0]:
        # Solar mast boom extending laterally from hull
        mast = Part.makeCylinder(0.25, SOLAR_OFFSET + 1.0, FreeCAD.Vector(0, 0, 0), FreeCAD.Vector(0, sign_y, 0))
        solids.append(mast)

        # 2 tiers of solar panel sheets per wing
        for tier_x in [-SOLAR_W/2.0 - 0.4, SOLAR_W/2.0 + 0.4]:
            panel = Part.makeBox(SOLAR_W, panel_thick, SOLAR_H, FreeCAD.Vector(tier_x - SOLAR_W/2.0, sign_y * SOLAR_OFFSET, -SOLAR_H/2.0))
            solids.append(panel)

    compound = solids[0]
    for s in solids[1:]:
        compound = compound.fuse(s)
    return compound


def export_step(solid, output_path):
    """Exports solid to standard ISO 10303 STEP format."""
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    solid.exportStep(output_path)
    file_size = os.path.getsize(output_path)
    print(f"✅ Exported STEP solid model: {output_path} ({file_size:,} bytes)")
    return file_size


# Main execution block
if __name__ == "__main__":
    print("Building AMU Heritage Orbital (v1.0) solid model via FreeCAD...")
    model = build_amu_heritage_orbital()

    if FreeCAD.GuiUp:
        doc = FreeCAD.activeDocument() or FreeCAD.newDocument("AMU_Heritage_Orbital_v1")
        obj = doc.addObject("Part::Feature", "AMU_Heritage_Assembly")
        obj.Shape = model
        doc.recompute()
        print("Inserted AMU_Heritage_Assembly into active FreeCAD document.")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    step_out = os.path.join(script_dir, "..", "step_exports", "amu_heritage_orbital_v1.step")
    export_step(model, os.path.abspath(step_out))
