#!/usr/bin/env python3
"""
strider_m_v2.py - Parametric FreeCAD/Python Solid Model for STRIDER-M Surface Transporter (v2.1)

Lineage:
- Ported from OpenSCAD: cad_and_blender/openscad/amu_surface/strider_m_transporter_v2.scad
- Governing Issues: #18 (FreeCAD Transition Program), #100 (STRIDER-M v2 Transporter CAD), #101 (Registry Governance)
- Solid Kernel: OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module

Features:
- Dual wide continuous crawler tracks with 24 perimeter traction grousers
- 4x Heavy A-frame knee-jointed outrigger trusses ("Spider Outriggers") with clevis mounts,
  hydraulic cylinders, and wide rectangular polar footpad shoes
- Modular Wind Cargo Retention Cradle & Stanchion System:
  - Dual lateral mast pipe saddles for 4.80 m sectional mast tubes (OD 0.51 m)
  - Modular blade sleeve retaining racks for segmented blade transport units (<= 1.90 m)
  - Perimeter ratchet tie-down winch assemblies and forged clevis D-rings
  - Aft transom loading guide rollers for crane-less horizontal module roll-off
  - Transit park-mode CORA-M manipulator arm clamp cradle
- Front tubular bull-bar crash cage with X-brace and recovery shackles
- Broadened 8-lug turret mounting rim (DOCK_COLLAR_R = 0.68 m)
- Amber hazard warning beacons and forward high-intensity LED headlight clusters
"""

import sys
import os
import math

# -----------------------------------------------------------------------------
# Module Metadata & Semantic Versioning
# -----------------------------------------------------------------------------
__version__     = "2.1.0"
__revision__    = "v2.1.0-wind-cargo-retention"
__author__      = "Stellar Dreams Engineering"
__date__        = "2026-10-17"
__target_spec__ = "STRIDER-M Heavy Surface Transporter with Wind Cargo Retention & A-Frame Outriggers (v2.1)"
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


def create_cargo_retention_cradle():
    """
    Generates modular wind cargo retention cradle, mast saddles, blade racks,
    winches, aft transom rollers, and CORA-M park latch on the utility deck.
    """
    solids = []
    cz = CHASSIS_H * 0.5 + DECK_H  # Deck surface = 0.925 m

    # 1. Dual Lateral Mast Pipe Saddles (3 longitudinal stations, port & starboard)
    # Designed to retain 4.80 m sectional mast pipes (OD 0.51 m)
    saddle_stations = [-2.30, -0.60, 1.50]
    saddle_ys = [-1.15, 1.15]
    saddle_r_inner = 0.28
    saddle_r_outer = 0.35
    saddle_width = 0.16

    for sx in saddle_stations:
        for sy in saddle_ys:
            # Base structural riser box
            riser = Part.makeBox(saddle_width, 0.40, 0.25, FreeCAD.Vector(sx - saddle_width/2.0, sy - 0.20, cz))
            
            # Semicircular concave cradle saddle
            outer_cyl = Part.makeCylinder(saddle_r_outer, saddle_width, FreeCAD.Vector(sx - saddle_width/2.0, sy, cz + 0.35), FreeCAD.Vector(1, 0, 0))
            inner_cyl = Part.makeCylinder(saddle_r_inner, saddle_width + 0.02, FreeCAD.Vector(sx - saddle_width/2.0 - 0.01, sy, cz + 0.35), FreeCAD.Vector(1, 0, 0))
            top_cut = Part.makeBox(saddle_width + 0.04, saddle_r_outer * 2.2, saddle_r_outer * 1.5, FreeCAD.Vector(sx - saddle_width/2.0 - 0.02, sy - saddle_r_outer * 1.1, cz + 0.35))
            
            saddle_ring = outer_cyl.cut(inner_cyl)
            saddle_half = saddle_ring.cut(top_cut)
            
            # Upright clamping posts
            post_l = Part.makeBox(saddle_width, 0.08, 0.35, FreeCAD.Vector(sx - saddle_width/2.0, sy - saddle_r_outer, cz + 0.20))
            post_r = Part.makeBox(saddle_width, 0.08, 0.35, FreeCAD.Vector(sx - saddle_width/2.0, sy + saddle_r_outer - 0.08, cz + 0.20))
            
            cradle_unit = riser.fuse(saddle_half).fuse(post_l).fuse(post_r)
            solids.append(cradle_unit)

    # 2. Outer Blade Sleeve Retention Racks (perimeter stanchions & longitudinal top rail)
    # Secures segmented rotor blade sleeve modules (length <= 1.90 m)
    for sign_y in [-1.0, 1.0]:
        ry = sign_y * (DECK_W / 2.0 - 0.10)
        # Stanchion posts
        for px in [-2.50, -1.30, 0.0, 1.30, 2.50]:
            post = Part.makeBox(0.08, 0.08, 0.50, FreeCAD.Vector(px - 0.04, ry - 0.04, cz))
            solids.append(post)
        # Longitudinal coaming rail
        rail = Part.makeBox(5.08, 0.08, 0.06, FreeCAD.Vector(-2.54, ry - 0.04, cz + 0.44))
        solids.append(rail)
        # Vertical divider slats for modular blade segments
        for bx in [-1.90, -0.65, 0.65, 1.90]:
            divider = Part.makeBox(0.04, 0.24, 0.38, FreeCAD.Vector(bx - 0.02, ry - 0.12 * sign_y, cz))
            solids.append(divider)

    # 3. Ratchet Winch Tie-Down Hardware (4 winches + 8 clevis D-rings)
    for sign_y in [-1.0, 1.0]:
        wy = sign_y * 1.45
        for wx in [-1.80, 0.80]:
            winch_drum = Part.makeCylinder(0.09, 0.22, FreeCAD.Vector(wx, wy - 0.11, cz + 0.12), FreeCAD.Vector(0, 1, 0))
            winch_base = Part.makeBox(0.24, 0.26, 0.12, FreeCAD.Vector(wx - 0.12, wy - 0.13, cz))
            solids.append(winch_drum.fuse(winch_base))

    for sign_y in [-1.0, 1.0]:
        dy = sign_y * (DECK_W / 2.0 - 0.05)
        for dx in [-2.60, -1.30, 1.0, 2.60]:
            dring = Part.makeCylinder(0.06, 0.04, FreeCAD.Vector(dx, dy, cz + 0.05), FreeCAD.Vector(1, 0, 0))
            solids.append(dring)

    # 4. Transom Loading Rollers at aft deck (enables horizontal winch-assisted roll-off)
    roller_x = -DECK_L / 2.0  # -2.80 m
    for ry in [-1.15, 1.15]:
        roller = Part.makeCylinder(0.08, 0.60, FreeCAD.Vector(roller_x - 0.04, ry - 0.30, cz + 0.06), FreeCAD.Vector(0, 1, 0))
        bearing_l = Part.makeBox(0.12, 0.08, 0.16, FreeCAD.Vector(roller_x - 0.10, ry - 0.38, cz))
        bearing_r = Part.makeBox(0.12, 0.08, 0.16, FreeCAD.Vector(roller_x - 0.10, ry + 0.30, cz))
        solids.append(roller.fuse(bearing_l).fuse(bearing_r))

    # 5. Center Transit Park-Mode Cradle for Folded CORA-M Arm
    cx = -1.60
    cy = 0.0
    saddle_base = Part.makeBox(0.55, 1.30, 0.22, FreeCAD.Vector(cx - 0.275, cy - 0.65, cz))
    left_jaw = Part.makeBox(0.55, 0.22, 0.40, FreeCAD.Vector(cx - 0.275, cy - 0.65, cz))
    right_jaw = Part.makeBox(0.55, 0.22, 0.40, FreeCAD.Vector(cx - 0.275, cy + 0.43, cz))
    park_cradle = saddle_base.fuse(left_jaw).fuse(right_jaw)
    for sign_y in [-1.0, 1.0]:
        latch_bar = Part.makeBox(0.35, 0.16, 0.18, FreeCAD.Vector(cx - 0.175, cy + sign_y * 0.35 - 0.08, cz + 0.32))
        park_cradle = park_cradle.fuse(latch_bar)
    solids.append(park_cradle)

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
    """Builds complete STRIDER-M v2.1 solid model assembly with outriggers, cage, wind cargo retention, and cradle."""
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

    # Crash cage, cargo retention cradle, turret dock
    cage = create_front_crash_cage()
    cradle = create_cargo_retention_cradle()
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
    print("Building STRIDER-M Transporter (v2.1) solid model via FreeCAD...")
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
