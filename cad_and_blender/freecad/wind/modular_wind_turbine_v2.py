#!/usr/bin/env python3
"""
modular_wind_turbine_v2.py - Parametric FreeCAD/Python Solid Model for Modular Arctic Wind Turbine (v2.0)

Lineage:
- Ported from OpenSCAD: cad_and_blender/openscad/wind/v2.0/wind_v2_turbine_full.scad
- Governing Issues: #82 (Parent Wind Roadmap), #18 (FreeCAD Transition Program), #101 (Model Registry)
- Solid Kernel: OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module

Features:
- Standard 20 ft ISO intermodal container footprint functioning as foundation base
- 4x Outrigger stabilizers with permafrost ground anchor footpads
- Sectional tubular steel mast (Hub Height = 24.0 m, Diameter = 0.508 m)
- Direct-drive PMSG nacelle generator housing
- 3-bladed sectional composite aerodynamic rotor (Rotor Diameter = 26.0 m)
"""

import sys
import os
import math

# Ensure FreeCAD library is accessible
for lib_path in ["/usr/lib/freecad/lib", "/usr/lib/freecad-python3/lib"]:
    if os.path.exists(lib_path) and lib_path not in sys.path:
        sys.path.append(lib_path)

import FreeCAD
import Part

# -----------------------------------------------------------------------------
# Parametric Dimensions (Meters)
# -----------------------------------------------------------------------------
CONT_L       = 6.058   # 20 ft ISO container length
CONT_W       = 2.438   # 20 ft ISO container width
CONT_H       = 2.591   # 20 ft ISO container height

MAST_H       = 24.0    # Tower hub height
MAST_D       = 0.508   # Tower outer diameter

ROTOR_DIA    = 26.0    # Rotor diameter
BLADE_LEN    = 12.0    # Individual blade length
NACELLE_L    = 3.2     # Generator nacelle housing length
NACELLE_D    = 1.4     # Nacelle diameter


def build_modular_wind_turbine_v2():
    """Builds complete Modular Arctic Wind Turbine v2.0 solid model assembly."""
    solids = []

    # 1. 20 ft ISO Container Base (Footing)
    cont_box = Part.makeBox(CONT_L, CONT_W, CONT_H, FreeCAD.Vector(-CONT_L/2.0, -CONT_W/2.0, 0.0))
    solids.append(cont_box)

    # 4x Foundation Outriggers extending laterally from container
    outrigger_w = 0.35
    outrigger_ext = 1.60
    for sign_x in [-1.0, 1.0]:
        for sign_y in [-1.0, 1.0]:
            ox = sign_x * (CONT_L/2.0 - 0.50)
            oy = sign_y * CONT_W/2.0
            beam = Part.makeBox(outrigger_w, outrigger_ext, 0.25, FreeCAD.Vector(ox - outrigger_w/2.0, min(oy, oy + sign_y * outrigger_ext), 0.10))
            pad_y = oy + sign_y * (outrigger_ext - 0.20)
            footpad = Part.makeCylinder(0.35, 0.15, FreeCAD.Vector(ox, pad_y, 0.0), FreeCAD.Vector(0, 0, 1))
            solids.append(beam.fuse(footpad))

    # 2. Sectional Tubular Steel Mast (Hub Height = 24.0 m)
    mast = Part.makeCylinder(MAST_D / 2.0, MAST_H, FreeCAD.Vector(0, 0, CONT_H), FreeCAD.Vector(0, 0, 1))
    solids.append(mast)

    # Mast Flange Rings at 6 m intervals
    for fz in [6.0, 12.0, 18.0]:
        flange = Part.makeCylinder(MAST_D / 2.0 + 0.10, 0.12, FreeCAD.Vector(0, 0, CONT_H + fz), FreeCAD.Vector(0, 0, 1))
        solids.append(flange)

    # 3. Arctic Direct-Drive PMSG Nacelle Generator Housing
    nacelle_z = CONT_H + MAST_H
    nacelle_body = Part.makeCylinder(NACELLE_D / 2.0, NACELLE_L, FreeCAD.Vector(-NACELLE_L * 0.70, 0, nacelle_z), FreeCAD.Vector(1, 0, 0))
    solids.append(nacelle_body)

    # 4. Central Rotor Hub Spinner
    spinner_x = NACELLE_L * 0.30
    hub = Part.makeCylinder(0.60, 0.45, FreeCAD.Vector(spinner_x, 0, nacelle_z), FreeCAD.Vector(1, 0, 0))
    cone = Part.makeCone(0.60, 0.10, 0.40, FreeCAD.Vector(spinner_x + 0.45, 0, nacelle_z), FreeCAD.Vector(1, 0, 0))
    solids.append(hub.fuse(cone))

    # 5. Three Aerodynamic Rotor Blades (120° Spacing)
    for i in range(3):
        angle = i * (2.0 * math.pi / 3.0)
        # Blade root at hub
        b_root_r = 0.45
        b_tip_r = 0.18
        
        # Build blade along Z-axis then rotate into position on YZ plane
        blade_cone = Part.makeCone(b_root_r, b_tip_r, BLADE_LEN, FreeCAD.Vector(0, 0, 0), FreeCAD.Vector(0, 0, 1))
        
        # Flatten cone to represent airfoil chord profile
        # Rotation around X-axis by blade angle
        rot = FreeCAD.Rotation(FreeCAD.Vector(1, 0, 0), math.degrees(angle))
        blade_cone.Placement = FreeCAD.Placement(FreeCAD.Vector(spinner_x + 0.20, 0, nacelle_z), rot)
        solids.append(blade_cone)

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
    print("Building Modular Arctic Wind Turbine (v2.0) solid model via FreeCAD...")
    model = build_modular_wind_turbine_v2()

    if FreeCAD.GuiUp:
        doc = FreeCAD.activeDocument() or FreeCAD.newDocument("Modular_Wind_Turbine_v2")
        obj = doc.addObject("Part::Feature", "Wind_Turbine_Assembly")
        obj.Shape = model
        doc.recompute()
        print("Inserted Wind_Turbine_Assembly into active FreeCAD document.")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    step_out = os.path.join(script_dir, "..", "step_exports", "modular_wind_turbine_v2.step")
    export_step(model, os.path.abspath(step_out))
