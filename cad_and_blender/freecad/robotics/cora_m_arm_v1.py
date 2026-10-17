#!/usr/bin/env python3
"""
cora_m_arm_v1.py - Parametric FreeCAD/Python Solid Model for CORA-M 7-DoF Manipulator Arm (v1.0)

Lineage:
- Ported from OpenSCAD: cad_and_blender/openscad/amu_surface/amu_CORA-M-arm-opencode_v1.scad
  and amu_surface_transfer_docking_v1.scad
- Governing Issues: #18 (FreeCAD Transition Program), #101 (Hardware Invention & Model Registry)
- Solid Kernel: OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module

Features:
- Standardized circular cam-lock docking collar base (R = 0.48 m) with power umbilical
- Shoulder yaw turret and articulating shoulder pitch joint
- Primary bicep boom and elbow articulation knuckle
- Y-shaped dual-branch forearm structure (Monkey-Y architecture)
- Dual wrist roll/pitch/yaw assemblies
- Canonical symmetrical golden end-effector caliper jaws with parametric clamping gap
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

# Scale factor matching standard physical meter dimensions
SCALE = 1.0  # Full engineering scale (meters)

# Kinematic articulation angles (degrees)
SHOULDER_YAW   = 0.0
SHOULDER_PITCH = 25.0
ELBOW_PITCH    = 35.0
WRIST_PITCH    = 15.0
CALIPER_GAP    = 0.12  # Dynamic gripping gap between golden jaws (meters)


def make_arm_segment(length, r1, r2):
    """Creates a tapered cylindrical boom segment with spherical joint caps."""
    cyl = Part.makeCone(r1, r2, length, FreeCAD.Vector(0, 0, 0), FreeCAD.Vector(0, 0, 1))
    s1 = Part.makeSphere(r1, FreeCAD.Vector(0, 0, 0))
    s2 = Part.makeSphere(r2, FreeCAD.Vector(0, 0, length))
    return cyl.fuse(s1).fuse(s2)


def make_caliper_gripper(gap=CALIPER_GAP):
    """Creates symmetrical golden end-effector calipers."""
    solids = []
    # Tool hub
    hub = Part.makeCone(0.12, 0.07, 0.14, FreeCAD.Vector(0, 0, 0), FreeCAD.Vector(0, 0, 1))
    solids.append(hub)

    # Left and right caliper jaws
    jaw_thick = 0.035
    jaw_width = 0.08
    jaw_len = 0.18

    left_jaw = Part.makeBox(jaw_thick, jaw_width, jaw_len, FreeCAD.Vector(-(gap/2.0 + jaw_thick), -jaw_width/2.0, 0.14))
    right_jaw = Part.makeBox(jaw_thick, jaw_width, jaw_len, FreeCAD.Vector(gap/2.0, -jaw_width/2.0, 0.14))
    solids.append(left_jaw)
    solids.append(right_jaw)

    # Cleated teeth on inner grasping face
    for tz in [0.20, 0.25]:
        lt = Part.makeBox(0.015, jaw_width - 0.02, 0.015, FreeCAD.Vector(-gap/2.0, -(jaw_width - 0.02)/2.0, tz))
        rt = Part.makeBox(0.015, jaw_width - 0.02, 0.015, FreeCAD.Vector(gap/2.0 - 0.015, -(jaw_width - 0.02)/2.0, tz))
        solids.append(lt)
        solids.append(rt)

    compound = solids[0]
    for s in solids[1:]:
        compound = compound.fuse(s)
    return compound


def build_cora_m_arm(shoulder_pitch=SHOULDER_PITCH, elbow_pitch=ELBOW_PITCH, caliper_gap=CALIPER_GAP):
    """Builds complete 7-DoF CORA-M robotic arm solid model assembly."""
    solids = []

    # 1. Standardized Docking Collar Base (mates to STRIDER-M turret or AMU ceiling rail)
    base_plate = Part.makeCylinder(0.48, 0.18, FreeCAD.Vector(0, 0, 0), FreeCAD.Vector(0, 0, 1))
    umbilical = Part.makeCylinder(0.30, 0.04, FreeCAD.Vector(0, 0, -0.04), FreeCAD.Vector(0, 0, 1))
    solids.append(base_plate.fuse(umbilical))

    # 2. Shoulder Yaw Turret
    turret = Part.makeCylinder(0.38, 0.35, FreeCAD.Vector(0, 0, 0.18), FreeCAD.Vector(0, 0, 1))
    solids.append(turret)

    # 3. Shoulder Pitch Knuckle
    pitch_pivot_z = 0.18 + 0.35
    knuckle = Part.makeCylinder(0.22, 0.44, FreeCAD.Vector(0, -0.22, pitch_pivot_z), FreeCAD.Vector(0, 1, 0))
    solids.append(knuckle)

    # 4. Primary Upper Boom (Bicep)
    boom_len = 1.35
    bicep = make_arm_segment(boom_len, 0.18, 0.14)
    # Rotate bicep by shoulder pitch angle around Y-axis
    bicep_rot = FreeCAD.Rotation(FreeCAD.Vector(0, 1, 0), shoulder_pitch)
    bicep.Placement = FreeCAD.Placement(FreeCAD.Vector(0, 0, pitch_pivot_z), bicep_rot)
    solids.append(bicep)

    # Compute elbow position in global space
    elbow_vec = bicep_rot.multVec(FreeCAD.Vector(0, 0, boom_len)) + FreeCAD.Vector(0, 0, pitch_pivot_z)

    # 5. Elbow Articulation Knuckle
    elbow = Part.makeCylinder(0.16, 0.36, FreeCAD.Vector(elbow_vec.x, elbow_vec.y - 0.18, elbow_vec.z), FreeCAD.Vector(0, 1, 0))
    solids.append(elbow)

    # Forearm rotation (shoulder pitch + elbow pitch)
    forearm_pitch = shoulder_pitch - elbow_pitch
    forearm_rot = FreeCAD.Rotation(FreeCAD.Vector(0, 1, 0), forearm_pitch)

    # 6. Y-Shaped Dual Forearm Split (Monkey-Y Architecture)
    forearm_len = 1.10
    for sign_branch in [-1.0, 1.0]:
        forearm = make_arm_segment(forearm_len, 0.12, 0.09)
        # Apply Y-split yaw angle of ±18 degrees
        branch_rot = forearm_rot.multiply(FreeCAD.Rotation(FreeCAD.Vector(1, 0, 0), sign_branch * 18.0))
        forearm.Placement = FreeCAD.Placement(elbow_vec, branch_rot)
        solids.append(forearm)

        # Compute wrist position
        wrist_vec = branch_rot.multVec(FreeCAD.Vector(0, 0, forearm_len)) + elbow_vec

        # 7. Wrist Knuckle & Golden Calipers
        wrist_knuckle = Part.makeSphere(0.10, wrist_vec)
        solids.append(wrist_knuckle)

        calipers = make_caliper_gripper(gap=caliper_gap)
        calipers.Placement = FreeCAD.Placement(wrist_vec, branch_rot)
        solids.append(calipers)

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
    print("Building CORA-M 7-DoF Manipulator Arm (v1.0) solid model via FreeCAD...")
    model = build_cora_m_arm()

    if FreeCAD.GuiUp:
        doc = FreeCAD.activeDocument() or FreeCAD.newDocument("CORA_M_v1")
        obj = doc.addObject("Part::Feature", "CORA_M_Arm_Assembly")
        obj.Shape = model
        doc.recompute()
        print("Inserted CORA_M_Arm_Assembly into active FreeCAD document.")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    step_out = os.path.join(script_dir, "..", "step_exports", "cora_m_arm_v1.step")
    export_step(model, os.path.abspath(step_out))
