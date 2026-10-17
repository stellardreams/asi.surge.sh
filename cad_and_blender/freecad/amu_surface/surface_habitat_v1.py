#!/usr/bin/env python3
"""
surface_habitat_v1.py - Parametric FreeCAD/Python Solid Model for AMU-Surface Base Habitat (v1.0)

Lineage:
- Ported from OpenSCAD: cad_and_blender/openscad/amu_surface/amu_surface_habitat_v1.scad
- Governing Issues: #18 (FreeCAD Transition Program), #101 (Hardware Invention & Model Registry)
- Solid Kernel: OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module

Features:
- Vaulted catenary/cylindrical habitat arch (L = 18.0 m, R = 5.5 m)
- Insulated floor slab with foundation footing beams and permafrost anchor stakes
- Apex overhead I-beam ceiling gantry crane rail (CEILING_Z = 5.15 m, L = 16.8 m)
- High-bay rover staging portal (PORTAL_W = 5.2 m, PORTAL_H = 3.2 m) clearing STRIDER-M
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
__target_spec__ = "AMU-Surface Base Habitat Vaulted Arch & Overhead Gantry (v1.0)"
__kernel__      = "OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module"
__lineage__     = "cad_and_blender/openscad/amu_surface/amu_surface_habitat_v1.scad"

# Ensure FreeCAD library is accessible
for lib_path in ["/usr/lib/freecad/lib", "/usr/lib/freecad-python3/lib"]:
    if os.path.exists(lib_path) and lib_path not in sys.path:
        sys.path.append(lib_path)

import FreeCAD
import Part

# -----------------------------------------------------------------------------
# Parametric Dimensions (Meters)
# -----------------------------------------------------------------------------
HAB_L          = 18.0   # Overall length
HAB_R          = 5.5    # Radius of vaulted structural shell
HAB_FLOOR_Y    = 8.0    # Floor width
HAB_WALL_T     = 0.28   # Wall thickness

PORTAL_W       = 5.2    # High-bay rover deployment portal width
PORTAL_H       = 3.2    # High-bay portal height

CEILING_RAIL_L = 16.8   # Apex gantry crane rail length
CEILING_Z      = 5.15   # Apex ceiling gantry height


def build_surface_habitat_v1():
    """Generates the vaulted habitat shell, apex ceiling rail, and foundation floor."""
    solids = []

    # 1. Outer & Inner Cylindrical Shell
    outer_cyl = Part.makeCylinder(HAB_R, HAB_L, FreeCAD.Vector(-HAB_L/2.0, 0, 0), FreeCAD.Vector(1, 0, 0))
    inner_cyl = Part.makeCylinder(HAB_R - HAB_WALL_T, HAB_L - 0.8, FreeCAD.Vector(-(HAB_L - 0.8)/2.0, 0, 0), FreeCAD.Vector(1, 0, 0))
    vault_tube = outer_cyl.cut(inner_cyl)

    # Cut off bottom half below floor level (Z < 0)
    ground_cutter = Part.makeBox(HAB_L + 4.0, 2.0 * HAB_R + 4.0, HAB_R + 2.0, FreeCAD.Vector(-(HAB_L + 4.0)/2.0, -(HAB_R + 2.0), -(HAB_R + 2.0)))
    arch_shell = vault_tube.cut(ground_cutter)

    # Cut rover deployment airlock portal at +X end wall
    portal_cutter = Part.makeBox(2.0, PORTAL_W, PORTAL_H, FreeCAD.Vector(HAB_L/2.0 - 1.0, -PORTAL_W/2.0, 0.0))
    habitat_shell = arch_shell.cut(portal_cutter)
    solids.append(habitat_shell)

    # 2. Insulated Structural Floor Slab
    floor_slab = Part.makeBox(HAB_L, HAB_FLOOR_Y, 0.30, FreeCAD.Vector(-HAB_L/2.0, -HAB_FLOOR_Y/2.0, -0.30))
    solids.append(floor_slab)

    # 3. Foundation Footing Beams
    for fy in [-HAB_R - 0.4, HAB_R + 0.4 - 1.2]:
        footing = Part.makeBox(HAB_L + 1.2, 1.2, 0.8, FreeCAD.Vector(-(HAB_L + 1.2)/2.0, fy, -0.80))
        solids.append(footing)

    # 4. Apex Heavy I-Beam Ceiling Gantry Rail (Z = 5.15 m)
    # Rail top flange, web, and bottom flange
    flange_w = 0.60
    flange_t = 0.06
    web_h = 0.25
    web_t = 0.08

    top_flange = Part.makeBox(CEILING_RAIL_L, flange_w, flange_t, FreeCAD.Vector(-CEILING_RAIL_L/2.0, -flange_w/2.0, CEILING_Z))
    web = Part.makeBox(CEILING_RAIL_L, web_t, web_h, FreeCAD.Vector(-CEILING_RAIL_L/2.0, -web_t/2.0, CEILING_Z - web_h))
    bot_flange = Part.makeBox(CEILING_RAIL_L, flange_w, flange_t, FreeCAD.Vector(-CEILING_RAIL_L/2.0, -flange_w/2.0, CEILING_Z - web_h - flange_t))
    gantry_rail = top_flange.fuse(web).fuse(bot_flange)
    solids.append(gantry_rail)

    # 5. Portal Reinforced Frame Arch at +X
    portal_post_l = Part.makeBox(0.40, 0.35, PORTAL_H + 0.3, FreeCAD.Vector(HAB_L/2.0 - 0.40, -PORTAL_W/2.0 - 0.35, 0.0))
    portal_post_r = Part.makeBox(0.40, 0.35, PORTAL_H + 0.3, FreeCAD.Vector(HAB_L/2.0 - 0.40, PORTAL_W/2.0, 0.0))
    portal_lintel = Part.makeBox(0.40, PORTAL_W + 1.05, 0.35, FreeCAD.Vector(HAB_L/2.0 - 0.40, -PORTAL_W/2.0 - 0.35, PORTAL_H))
    frame = portal_post_l.fuse(portal_post_r).fuse(portal_lintel)
    solids.append(frame)

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
    print("Building AMU-Surface Habitat (v1.0) solid model via FreeCAD...")
    model = build_surface_habitat_v1()

    if FreeCAD.GuiUp:
        doc = FreeCAD.activeDocument() or FreeCAD.newDocument("Surface_Habitat_v1")
        obj = doc.addObject("Part::Feature", "Surface_Habitat_Assembly")
        obj.Shape = model
        doc.recompute()
        print("Inserted Surface_Habitat_Assembly into active FreeCAD document.")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    step_out = os.path.join(script_dir, "..", "step_exports", "surface_habitat_v1.step")
    export_step(model, os.path.abspath(step_out))
