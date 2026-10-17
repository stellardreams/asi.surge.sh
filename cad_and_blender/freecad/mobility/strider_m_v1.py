#!/usr/bin/env python3
"""
strider_m_v1.py - Parametric FreeCAD/Python Solid Model for STRIDER-M Surface Transporter (v1.0)

Lineage:
- Ported from OpenSCAD: cad_and_blender/openscad/amu_surface/strider_m_transporter_v1.scad
- Governing Issues: #18 (FreeCAD Transition Program), #101 (Hardware Invention & Model Registry)
- Solid Kernel: OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module

Features:
- Dual low-ground-pressure continuous crawler track bogies with traction grousers
- Central armored chassis frame with heated power pack reservoir
- Raised utility deck with corner beveled risers
- Central latch collar docking rim for CORA-M robotic arm mounting (R = 0.55 m)
- Dual concentric umbilical power/data couplings
"""

import sys
import os
import math

# -----------------------------------------------------------------------------
# Module Metadata & Semantic Versioning
# -----------------------------------------------------------------------------
__version__     = "1.0.0"
__revision__    = "v1.0.0-baseline"
__author__      = "Stellar Dreams Engineering"
__date__        = "2026-10-17"
__target_spec__ = "STRIDER-M Heavy Surface Transporter Chassis (v1.0 Baseline)"
__kernel__      = "OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module"
__lineage__     = "cad_and_blender/openscad/amu_surface/strider_m_transporter_v1.scad"

# Ensure FreeCAD library is accessible if running headless via Python
for lib_path in ["/usr/lib/freecad/lib", "/usr/lib/freecad-python3/lib"]:
    if os.path.exists(lib_path) and lib_path not in sys.path:
        sys.path.append(lib_path)

import FreeCAD
import Part

# -----------------------------------------------------------------------------
# Parametric Dimensions (Meters / Scale units matching OpenSCAD benchmark)
# -----------------------------------------------------------------------------
ROVER_L         = 7.2    # Overall vehicle length
ROVER_W         = 4.6    # Overall vehicle width
CHASSIS_H       = 1.2    # Ground clearance / chassis height

TRACK_W         = 1.2    # Width of each continuous crawler track
TRACK_L         = 6.8    # Length of track assembly
TRACK_H         = 1.4    # Height of track loop
GROUSER_COUNT   = 16     # Traction grousers per perimeter pass

DECK_L          = 5.4    # Deck length
DECK_W          = 3.2    # Deck width
DECK_H          = 0.35   # Deck thickness

DOCK_COLLAR_R   = 0.55   # Radius of CORA-M latch collar mount
DOCK_COLLAR_H   = 0.25   # Height of collar above deck


def create_crawler_track(center_y=0.0):
    """Generates continuous crawler track solid with road wheels and grousers."""
    solids = []

    dx = TRACK_L / 2.0 - TRACK_H / 2.0
    r_outer = TRACK_H / 2.0
    
    # Outer hull envelope (stadium prism)
    c1 = Part.makeCylinder(r_outer, TRACK_W, FreeCAD.Vector(-dx, center_y - TRACK_W/2.0, 0), FreeCAD.Vector(0, 1, 0))
    c2 = Part.makeCylinder(r_outer, TRACK_W, FreeCAD.Vector(dx, center_y - TRACK_W/2.0, 0), FreeCAD.Vector(0, 1, 0))
    box = Part.makeBox(2.0 * dx, TRACK_W, TRACK_H, FreeCAD.Vector(-dx, center_y - TRACK_W/2.0, -r_outer))
    outer_track = c1.fuse(c2).fuse(box)

    # Inner cutout for wheel bay
    r_inner = r_outer - 0.22
    w_inner = TRACK_W - 0.20
    ic1 = Part.makeCylinder(r_inner, w_inner, FreeCAD.Vector(-dx, center_y - w_inner/2.0, 0), FreeCAD.Vector(0, 1, 0))
    ic2 = Part.makeCylinder(r_inner, w_inner, FreeCAD.Vector(dx, center_y - w_inner/2.0, 0), FreeCAD.Vector(0, 1, 0))
    ibox = Part.makeBox(2.0 * dx, w_inner, 2.0 * r_inner, FreeCAD.Vector(-dx, center_y - w_inner/2.0, -r_inner))
    inner_cutout = ic1.fuse(ic2).fuse(ibox)

    track_belt = outer_track.cut(inner_cutout)
    solids.append(track_belt)

    # Road wheels (sprockets and idlers)
    wheel_r = r_inner - 0.05
    wheel_w = TRACK_W - 0.28
    for wx in [-dx, dx, -dx * 0.5, 0.0, dx * 0.5]:
        wheel = Part.makeCylinder(wheel_r, wheel_w, FreeCAD.Vector(wx, center_y - wheel_w/2.0, 0), FreeCAD.Vector(0, 1, 0))
        # Center axle hub
        hub = Part.makeCylinder(0.20, TRACK_W, FreeCAD.Vector(wx, center_y - TRACK_W/2.0, 0), FreeCAD.Vector(0, 1, 0))
        solids.append(wheel.fuse(hub))

    # Traction Grousers (ice cleats) on ground contact face
    grouser_w = TRACK_W + 0.06
    step = (2.0 * dx) / (GROUSER_COUNT / 2.0)
    for i in range(int(GROUSER_COUNT / 2.0) + 1):
        gx = -dx + i * step
        # Bottom grouser
        bg = Part.makeBox(0.14, grouser_w, 0.10, FreeCAD.Vector(gx - 0.07, center_y - grouser_w/2.0, -r_outer - 0.05))
        # Top grouser
        tg = Part.makeBox(0.14, grouser_w, 0.10, FreeCAD.Vector(gx - 0.07, center_y - grouser_w/2.0, r_outer - 0.05))
        solids.append(bg)
        solids.append(tg)

    compound = solids[0]
    for s in solids[1:]:
        compound = compound.fuse(s)
    return compound


def create_chassis_and_deck():
    """Generates armored center chassis, power bay, and utility cargo deck."""
    solids = []

    # Center armored frame
    chassis_box = Part.makeBox(DECK_L * 1.1, 2.2, CHASSIS_H * 0.7, FreeCAD.Vector(-DECK_L * 0.55, -1.1, -0.2))
    solids.append(chassis_box)

    # Transverse heavy crossbeams connecting to tracks
    for bx in [-2.2, 0.0, 2.2]:
        beam = Part.makeBox(0.5, ROVER_W - 0.4, 0.4, FreeCAD.Vector(bx - 0.25, -(ROVER_W - 0.4)/2.0, 0.0))
        solids.append(beam)

    # High-visibility orange utility cargo deck
    deck_z = CHASSIS_H * 0.5
    deck = Part.makeBox(DECK_L, DECK_W, DECK_H, FreeCAD.Vector(-DECK_L/2.0, -DECK_W/2.0, deck_z))
    solids.append(deck)

    # CORA-M Arm Latch Collar Docking Station
    collar_z = deck_z + DECK_H
    outer_collar = Part.makeCylinder(DOCK_COLLAR_R, DOCK_COLLAR_H, FreeCAD.Vector(0, 0, collar_z), FreeCAD.Vector(0, 0, 1))
    inner_collar = Part.makeCylinder(DOCK_COLLAR_R - 0.10, DOCK_COLLAR_H + 0.02, FreeCAD.Vector(0, 0, collar_z - 0.01), FreeCAD.Vector(0, 0, 1))
    dock_ring = outer_collar.cut(inner_collar)
    solids.append(dock_ring)

    # 4x Radial alignment cam latches on the collar
    for i in range(4):
        angle = i * (math.pi / 2.0)
        lx = (DOCK_COLLAR_R - 0.05) * math.cos(angle)
        ly = (DOCK_COLLAR_R - 0.05) * math.sin(angle)
        latch = Part.makeBox(0.12, 0.12, DOCK_COLLAR_H + 0.08, FreeCAD.Vector(lx - 0.06, ly - 0.06, collar_z))
        solids.append(latch)

    # Conductive Umbilical Power Socket
    umb_socket = Part.makeCylinder(0.22, 0.15, FreeCAD.Vector(1.4, 0.8, collar_z), FreeCAD.Vector(0, 0, 1))
    solids.append(umb_socket)

    compound = solids[0]
    for s in solids[1:]:
        compound = compound.fuse(s)
    return compound


def build_strider_m_v1():
    """Builds complete STRIDER-M v1.0 solid model assembly."""
    track_offset_y = ROVER_W / 2.0 - TRACK_W / 2.0
    left_track = create_crawler_track(center_y=track_offset_y)
    right_track = create_crawler_track(center_y=-track_offset_y)
    chassis = create_chassis_and_deck()

    full_vehicle = left_track.fuse(right_track).fuse(chassis)
    return full_vehicle


def export_step(solid, output_path):
    """Exports solid to standard ISO 10303 STEP format."""
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    solid.exportStep(output_path)
    file_size = os.path.getsize(output_path)
    print(f"✅ Exported STEP solid model: {output_path} ({file_size:,} bytes)")
    return file_size


# Main execution block
if __name__ == "__main__":
    print("Building STRIDER-M Transporter (v1.0) solid model via FreeCAD...")
    model = build_strider_m_v1()
    
    # In GUI mode, insert shape into active FreeCAD document
    if FreeCAD.GuiUp:
        doc = FreeCAD.activeDocument() or FreeCAD.newDocument("STRIDER_M_v1")
        obj = doc.addObject("Part::Feature", "STRIDER_M_v1_Assembly")
        obj.Shape = model
        doc.recompute()
        print("Inserted STRIDER_M_v1_Assembly into active FreeCAD document.")
    
    # Export headless STEP solid
    script_dir = os.path.dirname(os.path.abspath(__file__))
    step_out = os.path.join(script_dir, "..", "step_exports", "strider_m_v1.step")
    export_step(model, os.path.abspath(step_out))
