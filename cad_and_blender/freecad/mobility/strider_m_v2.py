#!/usr/bin/env python3
"""
strider_m_v2.py - Parametric FreeCAD/Python Solid Model for STRIDER-M Surface Transporter (v2.0)

Lineage:
- Ported from OpenSCAD: cad_and_blender/openscad/amu_surface/strider_m_transporter_v2.scad
- Governing Issues: #18 (FreeCAD Transition Program), #100 (STRIDER-M v2 Transporter CAD), #101 (Registry Governance)
- Solid Kernel: OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module

Features:
- Dual wide continuous crawler tracks with 24 perimeter traction grousers
- 4x Heavy A-frame knee-jointed outrigger trusses ("Spider Outriggers") with clevis mounts,
  hydraulic cylinders, and wide rectangular polar footpad shoes
- Front tubular bull-bar crash cage with X-brace and recovery shackles
- Transit park-mode U-saddle cradle with locking clamp jaws
- Broadened 8-lug turret mounting rim (DOCK_COLLAR_R = 0.68 m)
- Amber hazard warning beacons and forward high-intensity LED headlight clusters
"""

import sys
import os
import math

# -----------------------------------------------------------------------------
# Module Metadata & Semantic Versioning
# -----------------------------------------------------------------------------
__version__     = "2.0.0"
__revision__    = "v2.0.0-spider-outriggers"
__author__      = "Stellar Dreams Engineering"
__date__        = "2026-10-17"
__target_spec__ = "STRIDER-M Heavy Surface Transporter Chassis with A-Frame Outriggers (v2.0)"
__kernel__      = "OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module"
__lineage__     = "cad_and_blender/openscad/amu_surface/strider_m_transporter_v2.scad"

# Ensure FreeCAD library is accessible
for lib_path in ["/usr/lib/freecad/lib", "/usr/lib/freecad-python3/lib"]:
    if os.path.exists(lib_path) and lib_path not in sys.path:
        sys.path.append(lib_path)

import FreeCAD
import Part

# -----------------------------------------------------------------------------
# Parametric Dimensions
# -----------------------------------------------------------------------------
ROVER_L         = 7.6    # Overall length
ROVER_W         = 4.8    # Track-to-track width
CHASSIS_H       = 1.15   # Ground clearance / chassis height

TRACK_W         = 1.25   # Track width
TRACK_L         = 7.0    # Track length
TRACK_H         = 1.35   # Track height
GROUSER_COUNT   = 20     # Traction grousers per track

DECK_L          = 5.6    # Utility cargo deck length
DECK_W          = 3.4    # Utility cargo deck width
DECK_H          = 0.35   # Deck plate thickness

DOCK_COLLAR_R   = 0.68   # Broadened turret dock radius
DOCK_COLLAR_H   = 0.28   # Turret dock height


def create_crawler_track_v2(center_y=0.0):
    """Generates continuous crawler track solid with internal road wheels and grousers."""
    solids = []

    dx = TRACK_L / 2.0 - TRACK_H / 2.0
    r_outer = TRACK_H / 2.0

    # Outer stadium track loop
    c1 = Part.makeCylinder(r_outer, TRACK_W, FreeCAD.Vector(-dx, center_y - TRACK_W/2.0, 0), FreeCAD.Vector(0, 1, 0))
    c2 = Part.makeCylinder(r_outer, TRACK_W, FreeCAD.Vector(dx, center_y - TRACK_W/2.0, 0), FreeCAD.Vector(0, 1, 0))
    box = Part.makeBox(2.0 * dx, TRACK_W, TRACK_H, FreeCAD.Vector(-dx, center_y - TRACK_W/2.0, -r_outer))
    outer_track = c1.fuse(c2).fuse(box)

    # Inner wheel bay cutout
    r_inner = r_outer - 0.22
    w_inner = TRACK_W - 0.24
    ic1 = Part.makeCylinder(r_inner, w_inner, FreeCAD.Vector(-dx, center_y - w_inner/2.0, 0), FreeCAD.Vector(0, 1, 0))
    ic2 = Part.makeCylinder(r_inner, w_inner, FreeCAD.Vector(dx, center_y - w_inner/2.0, 0), FreeCAD.Vector(0, 1, 0))
    ibox = Part.makeBox(2.0 * dx, w_inner, 2.0 * r_inner, FreeCAD.Vector(-dx, center_y - w_inner/2.0, -r_inner))
    inner_cutout = ic1.fuse(ic2).fuse(ibox)

    track_belt = outer_track.cut(inner_cutout)
    solids.append(track_belt)

    # Road wheels
    wheel_r = r_inner - 0.05
    wheel_w = TRACK_W - 0.30
    for wx in [-dx, dx, -dx * 0.5, 0.0, dx * 0.5]:
        wheel = Part.makeCylinder(wheel_r, wheel_w, FreeCAD.Vector(wx, center_y - wheel_w/2.0, 0), FreeCAD.Vector(0, 1, 0))
        hub = Part.makeCylinder(0.22, TRACK_W, FreeCAD.Vector(wx, center_y - TRACK_W/2.0, 0), FreeCAD.Vector(0, 1, 0))
        solids.append(wheel.fuse(hub))

    # Traction Grousers (ice-cleats)
    grouser_w = TRACK_W + 0.06
    step = (2.0 * dx) / (GROUSER_COUNT / 2.0)
    for i in range(int(GROUSER_COUNT / 2.0) + 1):
        gx = -dx + i * step
        bg = Part.makeBox(0.16, grouser_w, 0.11, FreeCAD.Vector(gx - 0.08, center_y - grouser_w/2.0, -r_outer - 0.05))
        tg = Part.makeBox(0.16, grouser_w, 0.11, FreeCAD.Vector(gx - 0.08, center_y - grouser_w/2.0, r_outer - 0.06))
        solids.append(bg)
        solids.append(tg)

    compound = solids[0]
    for s in solids[1:]:
        compound = compound.fuse(s)
    return compound


def create_outrigger(sign_x=1.0, sign_y=1.0, deployed=True):
    """Generates an A-frame knee-joint outrigger truss with hydraulic cylinder and polar footpad."""
    solids = []

    # High clevis pivot on fender
    px = sign_x * 2.3
    py = sign_y * (ROVER_W/2.0)
    pz = TRACK_H/2.0 + 0.10

    clevis = Part.makeCylinder(0.16, 0.42, FreeCAD.Vector(px - 0.21, py, pz), FreeCAD.Vector(1, 0, 0))
    bracket = Part.makeBox(0.38, 0.22, 0.24, FreeCAD.Vector(px - 0.19, py - 0.11 * sign_y, pz - 0.12))
    solids.append(clevis.fuse(bracket))

    # Outrigger deployment angles
    # Upper boom extends outward and downward
    boom_len = 1.35
    knee_x = px
    knee_y = py + sign_y * 1.10
    knee_z = pz - 0.65

    # Upper box boom
    boom = Part.makeBox(0.24, 1.10, 0.22, FreeCAD.Vector(px - 0.12, min(py, knee_y), knee_z))
    solids.append(boom)

    # Knee knuckle
    knuckle = Part.makeCylinder(0.18, 0.32, FreeCAD.Vector(knee_x - 0.16, knee_y, knee_z + 0.10), FreeCAD.Vector(1, 0, 0))
    solids.append(knuckle)

    # Hydraulic cylinder ram pushing knee
    cyl_barrel = Part.makeCylinder(0.10, 0.75, FreeCAD.Vector(px, py + sign_y * 0.20, pz + 0.10), FreeCAD.Vector(0, sign_y * 0.85, -0.55))
    solids.append(cyl_barrel)

    # Lower articulated leg down to ground
    foot_y = knee_y + sign_y * 0.75
    foot_z = -TRACK_H/2.0
    lower_leg = Part.makeBox(0.20, 0.75, 0.18, FreeCAD.Vector(knee_x - 0.10, min(knee_y, foot_y), foot_z))
    solids.append(lower_leg)

    # Wide polar footpad shoe with permafrost biting cleats
    shoe = Part.makeBox(0.65, 0.85, 0.14, FreeCAD.Vector(knee_x - 0.325, foot_y - 0.425, foot_z - 0.07))
    # Cleats under footpad
    for cx in [-0.20, 0.20]:
        cleat = Part.makeBox(0.08, 0.75, 0.08, FreeCAD.Vector(knee_x + cx - 0.04, foot_y - 0.375, foot_z - 0.15))
        shoe = shoe.fuse(cleat)
    solids.append(shoe)

    compound = solids[0]
    for s in solids[1:]:
        compound = compound.fuse(s)
    return compound


def create_front_crash_cage():
    """Generates front tubular bull-bar crash cage with X-brace and recovery shackles."""
    solids = []
    fx = ROVER_L / 2.0 - 0.20
    cage_w = ROVER_W - 0.50
    cage_h = 1.30
    cage_z = -0.20

    # Perimeter tubular frame
    b_bottom = Part.makeBox(0.15, cage_w, 0.12, FreeCAD.Vector(fx, -cage_w/2.0, cage_z))
    b_top = Part.makeBox(0.15, cage_w, 0.12, FreeCAD.Vector(fx, -cage_w/2.0, cage_z + cage_h))
    post_l = Part.makeBox(0.15, 0.12, cage_h, FreeCAD.Vector(fx, -cage_w/2.0, cage_z))
    post_r = Part.makeBox(0.15, 0.12, cage_h, FreeCAD.Vector(fx, cage_w/2.0 - 0.12, cage_z))
    cage_frame = b_bottom.fuse(b_top).fuse(post_l).fuse(post_r)
    solids.append(cage_frame)

    # Diagonal X-brace
    diag1 = Part.makeBox(0.12, cage_w, 0.10, FreeCAD.Vector(fx + 0.01, -cage_w/2.0, cage_z + cage_h/2.0))
    solids.append(diag1)

    # 2x Heavy Forged Recovery Tow Shackles
    for sy in [-1.2, 1.2]:
        shackle = Part.makeCylinder(0.16, 0.14, FreeCAD.Vector(fx + 0.08, sy - 0.07, cage_z + 0.25), FreeCAD.Vector(0, 1, 0))
        shackle_hole = Part.makeCylinder(0.09, 0.16, FreeCAD.Vector(fx + 0.08, sy - 0.08, cage_z + 0.25), FreeCAD.Vector(0, 1, 0))
        solids.append(shackle.cut(shackle_hole))

    compound = solids[0]
    for s in solids[1:]:
        compound = compound.fuse(s)
    return compound


def create_park_mode_cradle():
    """Generates transit park-mode latch saddle to clamp folded CORA-M arm during rover travel."""
    solids = []
    cx = -1.60
    cy = 0.0
    cz = CHASSIS_H * 0.5 + DECK_H

    # U-shaped saddle base
    saddle_base = Part.makeBox(0.55, 1.30, 0.22, FreeCAD.Vector(cx - 0.275, cy - 0.65, cz))
    left_jaw = Part.makeBox(0.55, 0.22, 0.40, FreeCAD.Vector(cx - 0.275, cy - 0.65, cz))
    right_jaw = Part.makeBox(0.55, 0.22, 0.40, FreeCAD.Vector(cx - 0.275, cy + 0.43, cz))
    cradle = saddle_base.fuse(left_jaw).fuse(right_jaw)
    solids.append(cradle)

    # Dual motorized clamping latches
    for sign_y in [-1.0, 1.0]:
        latch_bar = Part.makeBox(0.35, 0.16, 0.18, FreeCAD.Vector(cx - 0.175, cy + sign_y * 0.35 - 0.08, cz + 0.32))
        solids.append(latch_bar)

    compound = solids[0]
    for s in solids[1:]:
        compound = compound.fuse(s)
    return compound


def create_turret_dock_v2():
    """Generates broadened 8-lug turret mounting collar."""
    solids = []
    collar_z = CHASSIS_H * 0.5 + DECK_H
    outer = Part.makeCylinder(DOCK_COLLAR_R, DOCK_COLLAR_H, FreeCAD.Vector(0, 0, collar_z), FreeCAD.Vector(0, 0, 1))
    inner = Part.makeCylinder(DOCK_COLLAR_R - 0.12, DOCK_COLLAR_H + 0.02, FreeCAD.Vector(0, 0, collar_z - 0.01), FreeCAD.Vector(0, 0, 1))
    rim = outer.cut(inner)
    solids.append(rim)

    # 8x Radial Locking Lugs
    for i in range(8):
        angle = i * (2.0 * math.pi / 8.0)
        lx = (DOCK_COLLAR_R - 0.04) * math.cos(angle)
        ly = (DOCK_COLLAR_R - 0.04) * math.sin(angle)
        lug = Part.makeBox(0.12, 0.12, DOCK_COLLAR_H + 0.06, FreeCAD.Vector(lx - 0.06, ly - 0.06, collar_z))
        solids.append(lug)

    compound = solids[0]
    for s in solids[1:]:
        compound = compound.fuse(s)
    return compound


def build_strider_m_v2():
    """Builds complete STRIDER-M v2.0 solid model assembly with outriggers, cage, and cradle."""
    track_offset_y = ROVER_W / 2.0 - TRACK_W / 2.0
    left_track = create_crawler_track_v2(center_y=track_offset_y)
    right_track = create_crawler_track_v2(center_y=-track_offset_y)

    # Center armored frame and deck
    deck_z = CHASSIS_H * 0.5
    chassis_frame = Part.makeBox(DECK_L * 1.15, 2.3, CHASSIS_H * 0.72, FreeCAD.Vector(-DECK_L * 0.575, -1.15, -0.22))
    deck_plate = Part.makeBox(DECK_L, DECK_W, DECK_H, FreeCAD.Vector(-DECK_L/2.0, -DECK_W/2.0, deck_z))
    body = chassis_frame.fuse(deck_plate)

    # 4x A-Frame Knee-Joint Outrigger Trusses
    outrigger_fl = create_outrigger(sign_x=1.0, sign_y=1.0)
    outrigger_fr = create_outrigger(sign_x=1.0, sign_y=-1.0)
    outrigger_rl = create_outrigger(sign_x=-1.0, sign_y=1.0)
    outrigger_rr = create_outrigger(sign_x=-1.0, sign_y=-1.0)
    outriggers = outrigger_fl.fuse(outrigger_fr).fuse(outrigger_rl).fuse(outrigger_rr)

    # Crash cage, park cradle, turret dock
    cage = create_front_crash_cage()
    cradle = create_park_mode_cradle()
    dock = create_turret_dock_v2()

    assembly = left_track.fuse(right_track).fuse(body).fuse(outriggers).fuse(cage).fuse(cradle).fuse(dock)
    return assembly


def export_step(solid, output_path):
    """Exports solid to standard ISO 10303 STEP format."""
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    solid.exportStep(output_path)
    file_size = os.path.getsize(output_path)
    print(f"✅ Exported STEP solid model: {output_path} ({file_size:,} bytes)")
    return file_size


# Main execution block
if __name__ == "__main__":
    print("Building STRIDER-M Transporter (v2.0) solid model via FreeCAD...")
    model = build_strider_m_v2()

    # In GUI mode, insert shape into active FreeCAD document
    if FreeCAD.GuiUp:
        doc = FreeCAD.activeDocument() or FreeCAD.newDocument("STRIDER_M_v2")
        obj = doc.addObject("Part::Feature", "STRIDER_M_v2_Assembly")
        obj.Shape = model
        doc.recompute()
        print("Inserted STRIDER_M_v2_Assembly into active FreeCAD document.")

    # Export headless STEP solid
    script_dir = os.path.dirname(os.path.abspath(__file__))
    step_out = os.path.join(script_dir, "..", "step_exports", "strider_m_v2.step")
    export_step(model, os.path.abspath(step_out))
