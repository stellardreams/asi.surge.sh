#!/usr/bin/env python3
"""
zeroclaw_truss_node_v1.py - Parametric FreeCAD/Python Solid Model for ZeroClaw Octahedral Truss Node (v1.0)

Lineage:
- Ported from OpenSCAD: cad_and_blender/openscad/zeroclaw/07-19-2026_zeroclaw_amu_node.scad
- Governing Issues: #18 (FreeCAD Transition Program), #101 (Hardware Invention & Model Registry)
- Solid Kernel: OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module

Features:
- Parametric spherical connector node core with center through-bolt bore
- 6-axis radiating octahedral strut arms with flanged quick-disconnect mechanical couplings
- 6-bolt circular fastener pattern per coupling flange for in-space robotic lattice assembly
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
# Parametric Dimensions (Millimeters)
# -----------------------------------------------------------------------------
NODE_RADIUS   = 12.0    # Central spherical node radius
NODE_HOLE_R   = 4.5     # Central through-hole radius
STRUT_LEN     = 30.0    # Strut arm length from node center
STRUT_DIA     = 8.0     # Strut cylindrical arm diameter
FLANGE_DIA    = 14.0    # Tip coupling flange diameter
FLANGE_THICK  = 3.0     # Flange thickness
BOLT_HOLES    = 6       # Bolts per flange
BOLT_DIA      = 2.5     # Bolt hole diameter
FACES         = 6       # Symmetrical 6-axis lattice distribution


def make_strut_arm():
    """Generates a single strut arm with flanged coupling and bolt pattern."""
    # Cylindrical arm body
    arm = Part.makeCylinder(STRUT_DIA / 2.0, STRUT_LEN, FreeCAD.Vector(0, 0, 0), FreeCAD.Vector(0, 0, 1))

    # Flange at tip
    flange = Part.makeCylinder(FLANGE_DIA / 2.0, FLANGE_THICK, FreeCAD.Vector(0, 0, STRUT_LEN - FLANGE_THICK), FreeCAD.Vector(0, 0, 1))
    solid = arm.fuse(flange)

    # 6x Bolt circle bore holes
    bolt_circle_r = FLANGE_DIA / 2.0 - BOLT_DIA * 1.5
    for i in range(BOLT_HOLES):
        a = i * (2.0 * math.pi / BOLT_HOLES)
        bx = bolt_circle_r * math.cos(a)
        by = bolt_circle_r * math.sin(a)
        bolt_hole = Part.makeCylinder(BOLT_DIA / 2.0, FLANGE_THICK * 1.5, FreeCAD.Vector(bx, by, STRUT_LEN - FLANGE_THICK - 0.2), FreeCAD.Vector(0, 0, 1))
        solid = solid.cut(bolt_hole)

    return solid


def build_zeroclaw_node():
    """Generates complete 6-axis octahedral lattice truss connector node."""
    # 1. Spherical Node Core with central through-bore
    core_sphere = Part.makeSphere(NODE_RADIUS, FreeCAD.Vector(0, 0, 0))
    center_bore = Part.makeCylinder(NODE_HOLE_R, NODE_RADIUS * 2.4, FreeCAD.Vector(0, 0, -NODE_RADIUS * 1.2), FreeCAD.Vector(0, 0, 1))
    node_body = core_sphere.cut(center_bore)

    solids = [node_body]

    # 2. Six radiating octahedral arms
    single_strut = make_strut_arm()

    for i in range(FACES):
        azimuth = i * (360.0 / FACES)
        tilt = 35.0 if (i % 2 == 0) else -35.0

        # Create combined rotation (tilt around Y, then azimuth around Z)
        rot_tilt = FreeCAD.Rotation(FreeCAD.Vector(0, 1, 0), tilt)
        rot_azimuth = FreeCAD.Rotation(FreeCAD.Vector(0, 0, 1), azimuth)
        combined_rot = rot_azimuth.multiply(rot_tilt)

        arm_copy = single_strut.copy()
        arm_copy.Placement = FreeCAD.Placement(FreeCAD.Vector(0, 0, 0), combined_rot)
        solids.append(arm_copy)

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
    print("Building ZeroClaw Octahedral Truss Node (v1.0) solid model via FreeCAD...")
    model = build_zeroclaw_node()

    if FreeCAD.GuiUp:
        doc = FreeCAD.activeDocument() or FreeCAD.newDocument("ZeroClaw_Node_v1")
        obj = doc.addObject("Part::Feature", "ZeroClaw_Node_Assembly")
        obj.Shape = model
        doc.recompute()
        print("Inserted ZeroClaw_Node_Assembly into active FreeCAD document.")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    step_out = os.path.join(script_dir, "..", "step_exports", "zeroclaw_truss_node_v1.step")
    export_step(model, os.path.abspath(step_out))
