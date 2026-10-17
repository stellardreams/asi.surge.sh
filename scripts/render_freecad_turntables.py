#!/usr/bin/env python3
"""
render_freecad_turntables.py - Reproducible Multi-Color 360° Turntable Renderer for FreeCAD STEP Models

Lineage:
- Governing Issue: #101 (Hardware Invention & Model Registry & FreeCAD Transition)
- Architecture: FreeCAD OpenCASCADE B-Rep tessellation -> Matplotlib Poly3DCollection -> ffmpeg (MP4 & GIF)
- Performance: Multiprocessing parallel frame generation across CPU cores (defaults to max cores).

Usage:
    python3 scripts/render_freecad_turntables.py               # Render all models at max CPU
    python3 scripts/render_freecad_turntables.py --cores 4     # Specify core count
    python3 scripts/render_freecad_turntables.py --model modular_wind_turbine_v3  # Render specific model
"""

import sys
import os
import shutil
import argparse
import subprocess
import numpy as np
import multiprocessing as mp

# Ensure FreeCAD library is accessible
for lib_path in ["/usr/lib/freecad/lib", "/usr/lib/freecad-python3/lib"]:
    if os.path.exists(lib_path) and lib_path not in sys.path:
        sys.path.append(lib_path)

import FreeCAD
import Part
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
import importlib.util


def load_module(name, path):
    """Dynamically loads a FreeCAD Python module from repository path."""
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


# -----------------------------------------------------------------------------
# Color Group Extractors for FreeCAD Solid Models
# -----------------------------------------------------------------------------

def get_strider_m_v1_groups():
    mod = load_module("strider_m_v1", "cad_and_blender/freecad/mobility/strider_m_v1.py")
    track_offset_y = mod.ROVER_W / 2.0 - mod.TRACK_W / 2.0
    tracks = mod.create_crawler_track(center_y=track_offset_y).fuse(
        mod.create_crawler_track(center_y=-track_offset_y)
    )
    
    chassis_box = Part.makeBox(mod.DECK_L * 1.1, 2.2, mod.CHASSIS_H * 0.7, FreeCAD.Vector(-mod.DECK_L * 0.55, -1.1, -0.2))
    for bx in [-2.2, 0.0, 2.2]:
        beam = Part.makeBox(0.5, mod.ROVER_W - 0.4, 0.4, FreeCAD.Vector(bx - 0.25, -(mod.ROVER_W - 0.4)/2.0, 0.0))
        chassis_box = chassis_box.fuse(beam)
        
    deck_z = mod.CHASSIS_H * 0.5
    deck = Part.makeBox(mod.DECK_L, mod.DECK_W, mod.DECK_H, FreeCAD.Vector(-mod.DECK_L/2.0, -mod.DECK_W/2.0, deck_z))
    
    collar_z = deck_z + mod.DECK_H
    outer_collar = Part.makeCylinder(mod.DOCK_COLLAR_R, mod.DOCK_COLLAR_H, FreeCAD.Vector(0, 0, collar_z), FreeCAD.Vector(0, 0, 1))
    inner_collar = Part.makeCylinder(mod.DOCK_COLLAR_R - 0.10, mod.DOCK_COLLAR_H + 0.02, FreeCAD.Vector(0, 0, collar_z - 0.01), FreeCAD.Vector(0, 0, 1))
    dock_ring = outer_collar.cut(inner_collar)
    for i in range(4):
        angle = i * (np.pi / 2.0)
        lx = (mod.DOCK_COLLAR_R - 0.05) * np.cos(angle)
        ly = (mod.DOCK_COLLAR_R - 0.05) * np.sin(angle)
        latch = Part.makeBox(0.12, 0.12, mod.DOCK_COLLAR_H + 0.08, FreeCAD.Vector(lx - 0.06, ly - 0.06, collar_z))
        dock_ring = dock_ring.fuse(latch)
        
    umb_socket = Part.makeCylinder(0.22, 0.15, FreeCAD.Vector(1.4, 0.8, collar_z), FreeCAD.Vector(0, 0, 1))
    
    return [
        {"shape": tracks, "face": "#2e3440", "edge": "#1e222b", "tol": 0.18},
        {"shape": chassis_box, "face": "#3b4252", "edge": "#252a34", "tol": 0.18},
        {"shape": deck, "face": "#e06c28", "edge": "#9e4410", "tol": 0.18},
        {"shape": dock_ring, "face": "#d49b28", "edge": "#7a550e", "tol": 0.18},
        {"shape": umb_socket, "face": "#b8c5d6", "edge": "#536275", "tol": 0.18},
    ]


def get_strider_m_v2_groups():
    mod = load_module("strider_m_v2", "cad_and_blender/freecad/mobility/strider_m_v2.py")
    track_offset_y = mod.ROVER_W / 2.0 - mod.TRACK_W / 2.0
    tracks = mod.create_crawler_track_v2(center_y=track_offset_y).fuse(
        mod.create_crawler_track_v2(center_y=-track_offset_y)
    )
    
    deck_z = mod.CHASSIS_H * 0.5
    chassis_frame = Part.makeBox(mod.DECK_L * 1.15, 2.3, mod.CHASSIS_H * 0.72, FreeCAD.Vector(-mod.DECK_L * 0.575, -1.15, -0.22))
    deck_plate = Part.makeBox(mod.DECK_L, mod.DECK_W, mod.DECK_H, FreeCAD.Vector(-mod.DECK_L/2.0, -mod.DECK_W/2.0, deck_z))
    
    outrigger_fl = mod.create_outrigger(sign_x=1.0, sign_y=1.0)
    outrigger_fr = mod.create_outrigger(sign_x=1.0, sign_y=-1.0)
    outrigger_rl = mod.create_outrigger(sign_x=-1.0, sign_y=1.0)
    outrigger_rr = mod.create_outrigger(sign_x=-1.0, sign_y=-1.0)
    outriggers = outrigger_fl.fuse(outrigger_fr).fuse(outrigger_rl).fuse(outrigger_rr)
    
    cage = mod.create_front_crash_cage()
    cradle = mod.create_park_mode_cradle()
    dock = mod.create_turret_dock_v2()
    accents = cage.fuse(cradle).fuse(dock)
    
    return [
        {"shape": tracks, "face": "#2e3440", "edge": "#1e222b", "tol": 0.18},
        {"shape": chassis_frame, "face": "#3b4252", "edge": "#252a34", "tol": 0.18},
        {"shape": deck_plate, "face": "#e06c28", "edge": "#9e4410", "tol": 0.18},
        {"shape": outriggers, "face": "#b8c5d6", "edge": "#536275", "tol": 0.18},
        {"shape": accents, "face": "#d49b28", "edge": "#7a550e", "tol": 0.18},
    ]


def get_cora_m_arm_groups():
    mod = load_module("cora_m_arm_v1", "cad_and_blender/freecad/robotics/cora_m_arm_v1.py")
    
    base_plate = Part.makeCylinder(0.48, 0.18, FreeCAD.Vector(0, 0, 0), FreeCAD.Vector(0, 0, 1))
    umbilical = Part.makeCylinder(0.30, 0.04, FreeCAD.Vector(0, 0, -0.04), FreeCAD.Vector(0, 0, 1))
    base = base_plate.fuse(umbilical)
    turret = Part.makeCylinder(0.38, 0.35, FreeCAD.Vector(0, 0, 0.18), FreeCAD.Vector(0, 0, 1))
    pitch_pivot_z = 0.18 + 0.35
    knuckle = Part.makeCylinder(0.22, 0.44, FreeCAD.Vector(0, -0.22, pitch_pivot_z), FreeCAD.Vector(0, 1, 0))
    
    boom_len = 1.35
    bicep = mod.make_arm_segment(boom_len, 0.18, 0.14)
    bicep_rot = FreeCAD.Rotation(FreeCAD.Vector(0, 1, 0), mod.SHOULDER_PITCH)
    bicep.Placement = FreeCAD.Placement(FreeCAD.Vector(0, 0, pitch_pivot_z), bicep_rot)
    
    elbow_vec = bicep_rot.multVec(FreeCAD.Vector(0, 0, boom_len)) + FreeCAD.Vector(0, 0, pitch_pivot_z)
    elbow = Part.makeCylinder(0.16, 0.36, FreeCAD.Vector(elbow_vec.x, elbow_vec.y - 0.18, elbow_vec.z), FreeCAD.Vector(0, 1, 0))
    
    forearm_pitch = mod.SHOULDER_PITCH - mod.ELBOW_PITCH
    forearm_rot = FreeCAD.Rotation(FreeCAD.Vector(0, 1, 0), forearm_pitch)
    
    forearms = []
    calipers_list = []
    wrist_knuckles = []
    
    forearm_len = 1.10
    for sign_branch in [-1.0, 1.0]:
        forearm = mod.make_arm_segment(forearm_len, 0.12, 0.09)
        branch_rot = forearm_rot.multiply(FreeCAD.Rotation(FreeCAD.Vector(1, 0, 0), sign_branch * 18.0))
        forearm.Placement = FreeCAD.Placement(elbow_vec, branch_rot)
        forearms.append(forearm)
        
        wrist_vec = branch_rot.multVec(FreeCAD.Vector(0, 0, forearm_len)) + elbow_vec
        wrist_knuckles.append(Part.makeSphere(0.10, wrist_vec))
        
        caliper = mod.make_caliper_gripper(gap=mod.CALIPER_GAP)
        caliper.Placement = FreeCAD.Placement(wrist_vec, branch_rot)
        calipers_list.append(caliper)
        
    joints = base.fuse(turret).fuse(knuckle).fuse(elbow)
    for wk in wrist_knuckles:
        joints = joints.fuse(wk)
        
    white_booms = bicep
    for fa in forearms:
        white_booms = white_booms.fuse(fa)
        
    gold_calipers = calipers_list[0].fuse(calipers_list[1])
    
    return [
        {"shape": joints, "face": "#1c5cb8", "edge": "#0e346d", "tol": 0.10},
        {"shape": white_booms, "face": "#dce2ec", "edge": "#8092a8", "tol": 0.10},
        {"shape": gold_calipers, "face": "#d69a27", "edge": "#7a550e", "tol": 0.08},
    ]


def get_surface_habitat_groups():
    mod = load_module("surface_habitat_v1", "cad_and_blender/freecad/amu_surface/surface_habitat_v1.py")
    
    outer_cyl = Part.makeCylinder(mod.HAB_R, mod.HAB_L, FreeCAD.Vector(-mod.HAB_L/2.0, 0, 0), FreeCAD.Vector(1, 0, 0))
    inner_cyl = Part.makeCylinder(mod.HAB_R - mod.HAB_WALL_T, mod.HAB_L - 0.8, FreeCAD.Vector(-(mod.HAB_L - 0.8)/2.0, 0, 0), FreeCAD.Vector(1, 0, 0))
    vault_tube = outer_cyl.cut(inner_cyl)
    ground_cutter = Part.makeBox(mod.HAB_L + 4.0, 2.0 * mod.HAB_R + 4.0, mod.HAB_R + 2.0, FreeCAD.Vector(-(mod.HAB_L + 4.0)/2.0, -(mod.HAB_R + 2.0), -(mod.HAB_R + 2.0)))
    arch_shell = vault_tube.cut(ground_cutter)
    portal_cutter = Part.makeBox(2.0, mod.PORTAL_W, mod.PORTAL_H, FreeCAD.Vector(mod.HAB_L/2.0 - 1.0, -mod.PORTAL_W/2.0, 0.0))
    habitat_shell = arch_shell.cut(portal_cutter)
    
    floor_slab = Part.makeBox(mod.HAB_L, mod.HAB_FLOOR_Y, 0.30, FreeCAD.Vector(-mod.HAB_L/2.0, -mod.HAB_FLOOR_Y/2.0, -0.30))
    for fy in [-mod.HAB_R - 0.4, mod.HAB_R + 0.4 - 1.2]:
        footing = Part.makeBox(mod.HAB_L + 1.2, 1.2, 0.8, FreeCAD.Vector(-(mod.HAB_L + 1.2)/2.0, fy, -0.80))
        floor_slab = floor_slab.fuse(footing)
        
    top_flange = Part.makeBox(mod.CEILING_RAIL_L, 0.60, 0.06, FreeCAD.Vector(-mod.CEILING_RAIL_L/2.0, -0.30, mod.CEILING_Z))
    web = Part.makeBox(mod.CEILING_RAIL_L, 0.08, 0.25, FreeCAD.Vector(-mod.CEILING_RAIL_L/2.0, -0.04, mod.CEILING_Z - 0.25))
    bot_flange = Part.makeBox(mod.CEILING_RAIL_L, 0.60, 0.06, FreeCAD.Vector(-mod.CEILING_RAIL_L/2.0, -0.30, mod.CEILING_Z - 0.25 - 0.06))
    gantry_rail = top_flange.fuse(web).fuse(bot_flange)
    
    portal_post_l = Part.makeBox(0.40, 0.35, mod.PORTAL_H + 0.3, FreeCAD.Vector(mod.HAB_L/2.0 - 0.40, -mod.PORTAL_W/2.0 - 0.35, 0.0))
    portal_post_r = Part.makeBox(0.40, 0.35, mod.PORTAL_H + 0.3, FreeCAD.Vector(mod.HAB_L/2.0 - 0.40, mod.PORTAL_W/2.0, 0.0))
    portal_lintel = Part.makeBox(0.40, mod.PORTAL_W + 1.05, 0.35, FreeCAD.Vector(mod.HAB_L/2.0 - 0.40, -mod.PORTAL_W/2.0 - 0.35, mod.PORTAL_H))
    portal_frame = portal_post_l.fuse(portal_post_r).fuse(portal_lintel)
    
    return [
        {"shape": habitat_shell, "face": "#c5cbd4", "edge": "#687384", "tol": 0.25},
        {"shape": floor_slab, "face": "#3b4252", "edge": "#252a34", "tol": 0.25},
        {"shape": gantry_rail, "face": "#b8c5d6", "edge": "#536275", "tol": 0.20},
        {"shape": portal_frame, "face": "#d49b28", "edge": "#7a550e", "tol": 0.20},
    ]


def get_amu_heritage_orbital_groups():
    mod = load_module("amu_heritage_orbital_v1", "cad_and_blender/freecad/amu_orbital/amu_heritage_orbital_v1.py")
    
    outer_hull = Part.makeCylinder(mod.MMS_RADIUS, mod.MMS_LENGTH, FreeCAD.Vector(-mod.MMS_LENGTH/2.0, 0, 0), FreeCAD.Vector(1, 0, 0))
    inner_bay = Part.makeCylinder(mod.MMS_RADIUS - mod.WALL_THICK, mod.MMS_LENGTH - 1.2, FreeCAD.Vector(-(mod.MMS_LENGTH - 1.2)/2.0, 0, 0), FreeCAD.Vector(1, 0, 0))
    mms_hull = outer_hull.cut(inner_bay)
    
    dock_rings = []
    for sign_x in [-1.0, 1.0]:
        bulkhead = Part.makeCylinder(mod.MMS_RADIUS - 0.05, 0.40, FreeCAD.Vector(sign_x * (mod.MMS_LENGTH/2.0 - 0.20), 0, 0), FreeCAD.Vector(sign_x, 0, 0))
        collar = Part.makeCylinder(1.55, 0.60, FreeCAD.Vector(sign_x * (mod.MMS_LENGTH/2.0 - 0.10), 0, 0), FreeCAD.Vector(sign_x, 0, 0))
        collar_bore = Part.makeCylinder(1.22, 0.70, FreeCAD.Vector(sign_x * (mod.MMS_LENGTH/2.0 - 0.15), 0, 0), FreeCAD.Vector(sign_x, 0, 0))
        dock_rings.append(bulkhead.fuse(collar.cut(collar_bore)))
    bulkheads = dock_rings[0].fuse(dock_rings[1])
    
    y_out = 1.2
    spine_solids = []
    for dz in [-0.60, 0.60]:
        spine_solids.append(Part.makeCylinder(0.18, mod.SPINE_LENGTH, FreeCAD.Vector(-mod.SPINE_LENGTH/2.0, y_out, dz), FreeCAD.Vector(1, 0, 0)))
    for sx in [-12.0, -6.0, 0.0, 6.0, 12.0]:
        spine_solids.append(Part.makeBox(0.30, y_out, 1.40, FreeCAD.Vector(sx - 0.15, 0.0, -0.70)))
    spine = spine_solids[0]
    for s in spine_solids[1:]:
        spine = spine.fuse(s)
        
    masts = []
    panels = []
    for sign_y in [-1.0, 1.0]:
        masts.append(Part.makeCylinder(0.25, mod.SOLAR_OFFSET + 1.0, FreeCAD.Vector(0, 0, 0), FreeCAD.Vector(0, sign_y, 0)))
        for tier_x in [-mod.SOLAR_W/2.0 - 0.4, mod.SOLAR_W/2.0 + 0.4]:
            panels.append(Part.makeBox(mod.SOLAR_W, 0.08, mod.SOLAR_H, FreeCAD.Vector(tier_x - mod.SOLAR_W/2.0, sign_y * mod.SOLAR_OFFSET, -mod.SOLAR_H/2.0)))
            
    masts_solid = masts[0].fuse(masts[1])
    panels_solid = panels[0]
    for p in panels[1:]:
        panels_solid = panels_solid.fuse(p)
        
    return [
        {"shape": mms_hull, "face": "#c4b59f", "edge": "#6e604d", "tol": 0.30},
        {"shape": bulkheads, "face": "#d49b28", "edge": "#7a550e", "tol": 0.25},
        {"shape": spine.fuse(masts_solid), "face": "#b8c5d6", "edge": "#536275", "tol": 0.25},
        {"shape": panels_solid, "face": "#182c54", "edge": "#0c172e", "tol": 0.25},
    ]


def get_wind_turbine_v2_groups():
    mod = load_module("modular_wind_turbine_v2", "cad_and_blender/freecad/wind/modular_wind_turbine_v2.py")
    cont_box = Part.makeBox(mod.CONT_L, mod.CONT_W, mod.CONT_H, FreeCAD.Vector(-mod.CONT_L/2.0, -mod.CONT_W/2.0, 0.0))
    
    outriggers = []
    outrigger_w = 0.35
    outrigger_ext = 1.60
    for sign_x in [-1.0, 1.0]:
        for sign_y in [-1.0, 1.0]:
            ox = sign_x * (mod.CONT_L/2.0 - 0.50)
            oy = sign_y * mod.CONT_W/2.0
            beam = Part.makeBox(outrigger_w, outrigger_ext, 0.25, FreeCAD.Vector(ox - outrigger_w/2.0, min(oy, oy + sign_y * outrigger_ext), 0.10))
            pad_y = oy + sign_y * (outrigger_ext - 0.20)
            footpad = Part.makeCylinder(0.35, 0.15, FreeCAD.Vector(ox, pad_y, 0.0), FreeCAD.Vector(0, 0, 1))
            outriggers.append(beam.fuse(footpad))
    outriggers_solid = outriggers[0]
    for o in outriggers[1:]:
        outriggers_solid = outriggers_solid.fuse(o)
        
    mast = Part.makeCylinder(mod.MAST_D / 2.0, mod.MAST_H, FreeCAD.Vector(0, 0, mod.CONT_H), FreeCAD.Vector(0, 0, 1))
    for fz in [6.0, 12.0, 18.0]:
        flange = Part.makeCylinder(mod.MAST_D / 2.0 + 0.10, 0.12, FreeCAD.Vector(0, 0, mod.CONT_H + fz), FreeCAD.Vector(0, 0, 1))
        mast = mast.fuse(flange)
        
    nacelle_z = mod.CONT_H + mod.MAST_H
    nacelle_body = Part.makeCylinder(mod.NACELLE_D / 2.0, mod.NACELLE_L, FreeCAD.Vector(-mod.NACELLE_L * 0.70, 0, nacelle_z), FreeCAD.Vector(1, 0, 0))
    
    spinner_x = mod.NACELLE_L * 0.30
    hub = Part.makeCylinder(0.60, 0.45, FreeCAD.Vector(spinner_x, 0, nacelle_z), FreeCAD.Vector(1, 0, 0))
    cone = Part.makeCone(0.60, 0.10, 0.40, FreeCAD.Vector(spinner_x + 0.45, 0, nacelle_z), FreeCAD.Vector(1, 0, 0))
    hub_spinner = hub.fuse(cone)
    
    blades = []
    for i in range(3):
        angle = i * (2.0 * np.pi / 3.0)
        blade_cone = Part.makeCone(0.45, 0.18, mod.BLADE_LEN, FreeCAD.Vector(0, 0, 0), FreeCAD.Vector(0, 0, 1))
        rot = FreeCAD.Rotation(FreeCAD.Vector(1, 0, 0), np.degrees(angle))
        blade_cone.Placement = FreeCAD.Placement(FreeCAD.Vector(spinner_x + 0.20, 0, nacelle_z), rot)
        blades.append(blade_cone)
    rotor = blades[0].fuse(blades[1]).fuse(blades[2]).fuse(hub_spinner)
    
    return [
        {"shape": cont_box, "face": "#2e333b", "edge": "#1c2026", "tol": 0.35},
        {"shape": outriggers_solid, "face": "#e06c28", "edge": "#9e4410", "tol": 0.30},
        {"shape": mast, "face": "#9daab8", "edge": "#4d5866", "tol": 0.30},
        {"shape": nacelle_body, "face": "#1c5cb8", "edge": "#0e346d", "tol": 0.30},
        {"shape": rotor, "face": "#dce2ec", "edge": "#7d8b9e", "tol": 0.30},
    ]


def get_wind_turbine_v3_groups():
    mod = load_module("modular_wind_turbine_v3", "cad_and_blender/freecad/wind/modular_wind_turbine_v3.py")
    
    # 1. Foundation Base & Corner Castings
    cont_box = Part.makeBox(mod.CONT_L, mod.CONT_W, mod.CONT_H, FreeCAD.Vector(-mod.CONT_L / 2.0, -mod.CONT_W / 2.0, 0.0))
    for sx in [-1.0, 1.0]:
        for sy in [-1.0, 1.0]:
            for sz in [0.0, mod.CONT_H - 0.30]:
                cx = sx * (mod.CONT_L / 2.0 - 0.30) if sx > 0 else -mod.CONT_L / 2.0
                cy = sy * (mod.CONT_W / 2.0 - 0.30) if sy > 0 else -mod.CONT_W / 2.0
                corner = Part.makeBox(0.30, 0.30, 0.30, FreeCAD.Vector(cx, cy, sz))
                cont_box = cont_box.fuse(corner)

    # 2. Outriggers & Bearing Pads
    outriggers = []
    for sign_x in [-1.0, 1.0]:
        for sign_y in [-1.0, 1.0]:
            ox = sign_x * (mod.CONT_L / 2.0 - 0.60)
            oy = sign_y * (mod.CONT_W / 2.0)
            beam_y = min(oy, oy + sign_y * mod.OUTRIGGER_EXT)
            beam = Part.makeBox(mod.OUTRIGGER_W, mod.OUTRIGGER_EXT, 0.28, FreeCAD.Vector(ox - mod.OUTRIGGER_W / 2.0, beam_y, 0.12))
            pad_y = oy + sign_y * (mod.OUTRIGGER_EXT - 0.25)
            pad = Part.makeCylinder(mod.PAD_RADIUS, mod.PAD_THICK, FreeCAD.Vector(ox, pad_y, 0.0), FreeCAD.Vector(0, 0, 1))
            outriggers.append(beam.fuse(pad))
    outriggers_solid = outriggers[0]
    for o in outriggers[1:]:
        outriggers_solid = outriggers_solid.fuse(o)

    # 3. Microgrid Cabinet & Gin-Pole Rigging
    cab_l, cab_w, cab_h = 0.90, 1.40, 1.80
    cabinet = Part.makeBox(cab_l, cab_w, cab_h, FreeCAD.Vector(-mod.CONT_L / 2.0 - cab_l, -cab_w / 2.0, 0.40))
    gin_pole_l = Part.makeCylinder(0.08, 4.20, FreeCAD.Vector(0.80, -0.70, mod.CONT_H), FreeCAD.Vector(-0.25, 0.15, 1.0))
    gin_pole_r = Part.makeCylinder(0.08, 4.20, FreeCAD.Vector(0.80, 0.70, mod.CONT_H), FreeCAD.Vector(-0.25, -0.15, 1.0))
    winch = Part.makeBox(0.60, 0.70, 0.50, FreeCAD.Vector(1.40, -0.35, mod.CONT_H))
    rigging = cabinet.fuse(gin_pole_l).fuse(gin_pole_r).fuse(winch)

    # 4. Mast, Flanges, Guy Collar & Guy Cables
    mast = Part.makeCylinder(mod.MAST_D / 2.0, mod.MAST_H, FreeCAD.Vector(0, 0, mod.CONT_H), FreeCAD.Vector(0, 0, 1))
    sec_len = mod.MAST_H / float(mod.SECTIONS_COUNT)
    for s in range(1, mod.SECTIONS_COUNT):
        fz = mod.CONT_H + s * sec_len
        flange = Part.makeCylinder(mod.MAST_D / 2.0 + 0.12, 0.14, FreeCAD.Vector(0, 0, fz - 0.07), FreeCAD.Vector(0, 0, 1))
        mast = mast.fuse(flange)

    collar_z = mod.CONT_H + mod.GUY_RING_Z
    guy_ring = Part.makeCylinder(mod.MAST_D / 2.0 + 0.18, 0.35, FreeCAD.Vector(0, 0, collar_z), FreeCAD.Vector(0, 0, 1))
    mast = mast.fuse(guy_ring)

    cables = []
    for sign_x in [-1.0, 1.0]:
        for sign_y in [-1.0, 1.0]:
            anchor_x = sign_x * (mod.CONT_L / 2.0 - 0.60)
            anchor_y = sign_y * (mod.CONT_W / 2.0 + mod.OUTRIGGER_EXT - 0.25)
            collar_pt = FreeCAD.Vector(sign_x * 0.35, sign_y * 0.35, collar_z + 0.15)
            target_pt = FreeCAD.Vector(anchor_x, anchor_y, mod.PAD_THICK)
            cable_vec = target_pt - collar_pt
            cables.append(Part.makeCylinder(mod.GUY_CABLE_D / 2.0, cable_vec.Length, collar_pt, cable_vec))
    cables_solid = cables[0]
    for c in cables[1:]:
        cables_solid = cables_solid.fuse(c)

    # 5. Nacelle Body & Cowl
    nacelle_z = mod.CONT_H + mod.MAST_H
    nacelle_body = Part.makeCylinder(mod.NACELLE_D / 2.0, mod.NACELLE_L, FreeCAD.Vector(-mod.NACELLE_L * 0.68, 0, nacelle_z), FreeCAD.Vector(1, 0, 0))
    rear_cowl = Part.makeCone(mod.NACELLE_D / 2.0, 0.30, 0.85, FreeCAD.Vector(-mod.NACELLE_L * 0.68, 0, nacelle_z), FreeCAD.Vector(-1, 0, 0))
    nacelle = nacelle_body.fuse(rear_cowl)

    # 6. Hub & Spinner
    spinner_x = mod.NACELLE_L * 0.32
    hub_barrel = Part.makeCylinder(mod.HUB_D / 2.0, 0.55, FreeCAD.Vector(spinner_x, 0, nacelle_z), FreeCAD.Vector(1, 0, 0))
    spinner_cone = Part.makeCone(mod.HUB_D / 2.0, 0.12, mod.NOSE_CONE_L, FreeCAD.Vector(spinner_x + 0.55, 0, nacelle_z), FreeCAD.Vector(1, 0, 0))
    hub_spinner = hub_barrel.fuse(spinner_cone)

    # 7. Blades
    base_blade = mod.create_modular_aerodynamic_blade()
    blade_center_x = spinner_x + 0.28
    blades = []
    for i in range(3):
        angle_deg = i * 120.0
        blade_copy = base_blade.copy()
        rot = FreeCAD.Rotation(FreeCAD.Vector(1, 0, 0), angle_deg)
        blade_copy.Placement = FreeCAD.Placement(FreeCAD.Vector(blade_center_x, 0, nacelle_z), rot)
        blades.append(blade_copy)
    blades_solid = blades[0].fuse(blades[1]).fuse(blades[2])

    return [
        {"shape": cont_box, "face": "#2e333b", "edge": "#1c2026", "tol": 0.35},
        {"shape": outriggers_solid, "face": "#e06c28", "edge": "#9e4410", "tol": 0.30},
        {"shape": rigging.fuse(cables_solid), "face": "#d49b28", "edge": "#7a550e", "tol": 0.25},
        {"shape": mast, "face": "#9daab8", "edge": "#4d5866", "tol": 0.30},
        {"shape": nacelle, "face": "#1c5cb8", "edge": "#0e346d", "tol": 0.30},
        {"shape": hub_spinner, "face": "#d49b28", "edge": "#7a550e", "tol": 0.25},
        {"shape": blades_solid, "face": "#dce2ec", "edge": "#7d8b9e", "tol": 0.35},
    ]


def get_zeroclaw_node_groups():
    mod = load_module("zeroclaw_truss_node_v1", "cad_and_blender/freecad/amu_orbital/zeroclaw_truss_node_v1.py")
    
    core_sphere = Part.makeSphere(mod.NODE_RADIUS, FreeCAD.Vector(0, 0, 0))
    center_bore = Part.makeCylinder(mod.NODE_HOLE_R, mod.NODE_RADIUS * 2.4, FreeCAD.Vector(0, 0, -mod.NODE_RADIUS * 1.2), FreeCAD.Vector(0, 0, 1))
    node_body = core_sphere.cut(center_bore)
    
    single_strut = mod.make_strut_arm()
    arms = []
    for i in range(mod.FACES):
        azimuth = i * (360.0 / mod.FACES)
        tilt = 35.0 if (i % 2 == 0) else -35.0
        rot_tilt = FreeCAD.Rotation(FreeCAD.Vector(0, 1, 0), tilt)
        rot_azimuth = FreeCAD.Rotation(FreeCAD.Vector(0, 0, 1), azimuth)
        combined_rot = rot_azimuth.multiply(rot_tilt)
        arm_copy = single_strut.copy()
        arm_copy.Placement = FreeCAD.Placement(FreeCAD.Vector(0, 0, 0), combined_rot)
        arms.append(arm_copy)
    arms_solid = arms[0]
    for a in arms[1:]:
        arms_solid = arms_solid.fuse(a)
        
    return [
        {"shape": node_body, "face": "#1c5cb8", "edge": "#0e346d", "tol": 0.22},
        {"shape": arms_solid, "face": "#b8c5d6", "edge": "#536275", "tol": 0.22},
    ]


MODELS_CATALOG = [
    {
        "name": "strider_m_v1",
        "title": "STRIDER-M v1.0 Transporter",
        "getter": get_strider_m_v1_groups,
        "out_dir": "cad_and_blender/freecad/mobility/renders",
        "elev": 22,
    },
    {
        "name": "strider_m_v2",
        "title": "STRIDER-M v2.0 Transporter",
        "getter": get_strider_m_v2_groups,
        "out_dir": "cad_and_blender/freecad/mobility/renders",
        "elev": 22,
    },
    {
        "name": "cora_m_arm_v1",
        "title": "CORA-M 7-DoF Manipulator Arm",
        "getter": get_cora_m_arm_groups,
        "out_dir": "cad_and_blender/freecad/robotics/renders",
        "elev": 24,
    },
    {
        "name": "surface_habitat_v1",
        "title": "AMU-Surface Base Habitat",
        "getter": get_surface_habitat_groups,
        "out_dir": "cad_and_blender/freecad/amu_surface/renders",
        "elev": 25,
    },
    {
        "name": "amu_heritage_orbital_v1",
        "title": "AMU Heritage Orbital Spacecraft",
        "getter": get_amu_heritage_orbital_groups,
        "out_dir": "cad_and_blender/freecad/amu_orbital/renders",
        "elev": 20,
    },
    {
        "name": "modular_wind_turbine_v2",
        "title": "Modular Arctic Wind Turbine v2.0",
        "getter": get_wind_turbine_v2_groups,
        "out_dir": "cad_and_blender/freecad/wind/renders",
        "elev": 18,
    },
    {
        "name": "modular_wind_turbine_v3",
        "title": "Modular Arctic Wind Turbine v3.0",
        "getter": get_wind_turbine_v3_groups,
        "out_dir": "cad_and_blender/freecad/wind/renders",
        "elev": 18,
    },
    {
        "name": "zeroclaw_truss_node_v1",
        "title": "ZeroClaw Octahedral Truss Node",
        "getter": get_zeroclaw_node_groups,
        "out_dir": "cad_and_blender/freecad/amu_orbital/renders",
        "elev": 25,
    },
]

TOTAL_FRAMES = 36


def render_frame_worker(args):
    """Worker function for parallel frame rendering across CPU processes."""
    frame_idx, azim, elev, mesh_data, limits, frame_path = args
    cx, cy, cz, max_range = limits
    
    fig = plt.figure(figsize=(8, 4.5), facecolor="#0a0c10")
    ax = fig.add_subplot(111, projection="3d", facecolor="#0a0c10")
    
    for triangles, face, edge in mesh_data:
        coll = Poly3DCollection(triangles, alpha=0.96, facecolors=face, edgecolors=edge, linewidths=0.18)
        ax.add_collection3d(coll)
        
    ax.set_xlim(cx - max_range, cx + max_range)
    ax.set_ylim(cy - max_range, cy + max_range)
    ax.set_zlim(cz - max_range, cz + max_range)
    ax.axis("off")
    ax.view_init(elev=elev, azim=azim)
    
    plt.savefig(
        frame_path,
        dpi=100,
        bbox_inches="tight",
        pad_inches=0.0,
        facecolor=fig.get_facecolor(),
        edgecolor="none",
    )
    plt.close(fig)
    return frame_idx


def render_model(m, pool, cpu_cores, total_frames=TOTAL_FRAMES):
    """Renders a single model to MP4 and GIF turntable animations."""
    print(f"\n=======================================================")
    print(f"🎬 Processing Turntable: {m['title']} ({m['name']})")
    print(f"=======================================================")
    
    groups = m["getter"]()
    
    frames_dir = os.path.join("scratch/frames", m["name"])
    if os.path.exists(frames_dir):
        shutil.rmtree(frames_dir)
    os.makedirs(frames_dir, exist_ok=True)
    
    # Precompute tessellation meshes (once per model)
    mesh_data = []
    all_pts = []
    for g in groups:
        pts_raw, facets = g["shape"].tessellate(g["tol"])
        pts = np.array([[p.x, p.y, p.z] for p in pts_raw])
        all_pts.append(pts)
        triangles = pts[facets]
        mesh_data.append((triangles, g["face"], g["edge"]))
        
    all_pts = np.vstack(all_pts)
    min_x, max_x = all_pts[:, 0].min(), all_pts[:, 0].max()
    min_y, max_y = all_pts[:, 1].min(), all_pts[:, 1].max()
    min_z, max_z = all_pts[:, 2].min(), all_pts[:, 2].max()
    cx = (min_x + max_x) / 2.0
    cy = (min_y + max_y) / 2.0
    cz = (min_z + max_z) / 2.0
    max_range = max(max_x - min_x, max_y - min_y, max_z - min_z) * 0.58
    limits = (cx, cy, cz, max_range)
    
    tasks = []
    for f in range(total_frames):
        azim = (f * 360.0 / total_frames) - 60.0
        frame_path = os.path.join(frames_dir, f"frame_{f:04d}.png")
        tasks.append((f, azim, m["elev"], mesh_data, limits, frame_path))
        
    print(f"Rendering {total_frames} frames across {cpu_cores} parallel workers...")
    pool.map(render_frame_worker, tasks)
    
    os.makedirs(m["out_dir"], exist_ok=True)
    mp4_out = os.path.join(m["out_dir"], f"{m['name']}_turntable.mp4")
    gif_out = os.path.join(m["out_dir"], f"{m['name']}_turntable.gif")
    
    frame_pattern = os.path.join(frames_dir, "frame_%04d.png")
    cmd_mp4 = [
        "ffmpeg", "-y", "-framerate", "18", "-i", frame_pattern,
        "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "18",
        "-vf", "scale=trunc(iw/2)*2:trunc(ih/2)*2",
        mp4_out,
    ]
    subprocess.run(cmd_mp4, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    cmd_gif = [
        "ffmpeg", "-y", "-framerate", "14", "-i", frame_pattern,
        "-vf", "scale=480:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse",
        gif_out,
    ]
    subprocess.run(cmd_gif, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    print(f"✅ Generated: {mp4_out} ({os.path.getsize(mp4_out):,} bytes)")
    print(f"✅ Generated: {gif_out} ({os.path.getsize(gif_out):,} bytes)")


def main():
    parser = argparse.ArgumentParser(description="Multi-Color 360° Turntable Renderer for FreeCAD Models")
    parser.add_argument("--model", type=str, help="Specific model name to render (e.g. modular_wind_turbine_v3)")
    parser.add_argument("--cores", type=int, default=mp.cpu_count(), help="Number of CPU cores to utilize")
    parser.add_argument("--frames", type=int, default=TOTAL_FRAMES, help="Total frames per 360° rotation")
    args = parser.parse_args()

    targets = MODELS_CATALOG
    if args.model:
        targets = [m for m in MODELS_CATALOG if m["name"] == args.model]
        if not targets:
            print(f"❌ Unknown model '{args.model}'. Available models: {[m['name'] for m in MODELS_CATALOG]}")
            sys.exit(1)

    print(f"🚀 Initializing FreeCAD Turntable Renderer on {args.cores} CPU cores (rendering {len(targets)} models)...")
    pool = mp.Pool(processes=args.cores)
    
    for m in targets:
        render_model(m, pool, args.cores, args.frames)

    pool.close()
    pool.join()
    print("\n🎉 Turntable generation complete!")


if __name__ == "__main__":
    main()
