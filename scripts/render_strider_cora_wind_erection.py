#!/usr/bin/env python3
"""
render_strider_cora_wind_erection.py - Multi-Core Cinematic Renderer for Cooperative Field Hoisting

Lineage:
- Governing Issues: #105 (STRIDER-M + CORA-M + Wind Turbine v3.1 Kinematics), #104, #82
- Motion Design (20.00 Seconds, 240 Frames @ 12.0 fps):
  1. Stage 1 (0.0s - 4.0s, Frames 0-48): STRIDER-M Tundra Arrival & Spider Outrigger Stabilization (Phase 2)
  2. Stage 2 (4.0s - 8.0s, Frames 48-96): CORA-M 7-DoF Unlatching & Robotic Mast Offloading Across Transom Rollers (Phase 3)
  3. Stage 3 (8.0s - 12.0s, Frames 96-144): Modular Mast Horizontal Sleeve Coupling & 26m Rotor Rigging (Phase 3/4)
  4. Stage 4 (12.0s - 16.5s, Frames 144-198): Cooperative Gin-Pole Winch Hoisting & Tilt-Up Erection Arc (Phase 4)
  5. Stage 5 (16.5s - 20.0s, Frames 198-240): Foundation Socket Lock, Microgrid Power Umbilical & Rotor Commissioning (Phase 5)
- Renderer: OpenCASCADE B-Rep pre-tessellation -> NumPy rigid kinematics -> Matplotlib 3D -> ffmpeg (MP4 & looping GIF).
"""

import sys
import os
import math
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

TOTAL_FRAMES = 240
FPS = 12.0

# -----------------------------------------------------------------------------
# 3D Rotation Matrix Utilities
# -----------------------------------------------------------------------------
def rot_x(rad):
    c, s = math.cos(rad), math.sin(rad)
    return np.array([[1.0, 0.0, 0.0], [0.0, c, -s], [0.0, s, c]])

def rot_y(rad):
    c, s = math.cos(rad), math.sin(rad)
    return np.array([[c, 0.0, s], [0.0, 1.0, 0.0], [-s, 0.0, c]])

def rot_z(rad):
    c, s = math.cos(rad), math.sin(rad)
    return np.array([[c, -s, 0.0], [s, c, 0.0], [0.0, 0.0, 1.0]])

# -----------------------------------------------------------------------------
# Analytical CAD Mesh Pre-Tessellation
# -----------------------------------------------------------------------------
def build_cad_meshes():
    """Generates analytical OpenCASCADE solid geometry and pre-tessellates all subsystem components."""
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    
    # Import source modules
    def load_mod(name, rel_path):
        p = os.path.join(repo_root, rel_path)
        spec = importlib.util.spec_from_file_location(name, p)
        m = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(m)
        return m

    strider_mod = load_mod("strider", "cad_and_blender/freecad/mobility/strider_m_v2.py")
    cora_mod = load_mod("cora", "cad_and_blender/freecad/robotics/cora_m_arm_v1.py")
    wind_mod = load_mod("wind", "cad_and_blender/freecad/wind/modular_wind_turbine_v3.py")

    CONT_L = wind_mod.CONT_L
    CONT_W = wind_mod.CONT_W
    CONT_H = wind_mod.CONT_H
    MAST_H = wind_mod.MAST_H
    MAST_D = wind_mod.MAST_D
    OUTRIGGER_EXT = wind_mod.OUTRIGGER_EXT
    PAD_RADIUS = wind_mod.PAD_RADIUS
    PAD_THICK = wind_mod.PAD_THICK

    # 1. Base Container & Microgrid Cabinet
    cont_box = Part.makeBox(CONT_L, CONT_W, CONT_H, FreeCAD.Vector(-CONT_L/2.0, -CONT_W/2.0, 0.0))
    cab_l, cab_w, cab_h = 0.90, 1.40, 1.80
    cabinet = Part.makeBox(cab_l, cab_w, cab_h, FreeCAD.Vector(CONT_L/2.0, -cab_w/2.0, 0.40))
    trunnion_l = Part.makeBox(0.24, 0.22, 0.26, FreeCAD.Vector(-0.12, -0.81, CONT_H))
    trunnion_r = Part.makeBox(0.24, 0.22, 0.26, FreeCAD.Vector(-0.12, 0.59, CONT_H))
    base_solid = cont_box.fuse(cabinet).fuse(trunnion_l).fuse(trunnion_r)
    pts, facets = base_solid.tessellate(0.35)
    pts_base = np.array([[p.x, p.y, p.z] for p in pts])
    facets_base = np.array(facets)

    # 2. Container Outrigger Beam & Pad
    beam = Part.makeBox(wind_mod.OUTRIGGER_W, OUTRIGGER_EXT, 0.28, FreeCAD.Vector(-wind_mod.OUTRIGGER_W / 2.0, 0, 0.12))
    pad = Part.makeCylinder(PAD_RADIUS, PAD_THICK, FreeCAD.Vector(0, OUTRIGGER_EXT - 0.25, 0.0), FreeCAD.Vector(0, 0, 1))
    cap = Part.makeCylinder(0.12, 0.14, FreeCAD.Vector(0, OUTRIGGER_EXT - 0.25, PAD_THICK), FreeCAD.Vector(0, 0, 1))
    out_solid = beam.fuse(pad).fuse(cap)
    pts, facets = out_solid.tessellate(0.30)
    pts_out = np.array([[p.x, p.y, p.z] for p in pts])
    facets_out = np.array(facets)

    # 3. Mast Section (single 4.8m tube with flanged sleeve)
    sec_h = MAST_H / float(wind_mod.SECTIONS_COUNT)
    tube = Part.makeCylinder(MAST_D / 2.0, sec_h, FreeCAD.Vector(0, 0, 0), FreeCAD.Vector(0, 0, 1))
    flange = Part.makeCylinder(MAST_D / 2.0 + 0.08, 0.14, FreeCAD.Vector(0, 0, sec_h - 0.07), FreeCAD.Vector(0, 0, 1))
    sec_solid = tube.fuse(flange)
    pts, facets = sec_solid.tessellate(0.30)
    pts_sec = np.array([[p.x, p.y, p.z] for p in pts])
    facets_sec = np.array(facets)

    # 4. Collars
    lift_collar = Part.makeCylinder(MAST_D / 2.0 + 0.10, 0.28, FreeCAD.Vector(0, 0, -0.14), FreeCAD.Vector(0, 0, 1))
    pts, facets = lift_collar.tessellate(0.25)
    pts_lc = np.array([[p.x, p.y, p.z] for p in pts])
    facets_lc = np.array(facets)

    guy_collar = Part.makeCylinder(MAST_D / 2.0 + 0.18, 0.35, FreeCAD.Vector(0, 0, -0.17), FreeCAD.Vector(0, 0, 1))
    pts, facets = guy_collar.tessellate(0.25)
    pts_gc = np.array([[p.x, p.y, p.z] for p in pts])
    facets_gc = np.array(facets)

    # 5. Nacelle, Cowl, Hub, Blades
    nacelle_body = Part.makeCylinder(wind_mod.NACELLE_D / 2.0, wind_mod.NACELLE_L, FreeCAD.Vector(-wind_mod.NACELLE_L * 0.68, 0, 0), FreeCAD.Vector(1, 0, 0))
    rear_cowl = Part.makeCone(wind_mod.NACELLE_D / 2.0, 0.30, 0.85, FreeCAD.Vector(-wind_mod.NACELLE_L * 0.68, 0, 0), FreeCAD.Vector(-1, 0, 0))
    nac_solid = nacelle_body.fuse(rear_cowl)
    pts, facets = nac_solid.tessellate(0.30)
    pts_nac = np.array([[p.x, p.y, p.z] for p in pts])
    facets_nac = np.array(facets)

    spinner_x = wind_mod.NACELLE_L * 0.32
    hub_barrel = Part.makeCylinder(wind_mod.HUB_D / 2.0, 0.55, FreeCAD.Vector(spinner_x, 0, 0), FreeCAD.Vector(1, 0, 0))
    spinner_cone = Part.makeCone(wind_mod.HUB_D / 2.0, 0.12, wind_mod.NOSE_CONE_L, FreeCAD.Vector(spinner_x + 0.55, 0, 0), FreeCAD.Vector(1, 0, 0))
    hub_solid = hub_barrel.fuse(spinner_cone)
    pts, facets = hub_solid.tessellate(0.25)
    pts_hub = np.array([[p.x, p.y, p.z] for p in pts])
    facets_hub = np.array(facets)

    base_blade = wind_mod.create_modular_aerodynamic_blade()
    pts, facets = base_blade.tessellate(0.35)
    pts_blade = np.array([[p.x, p.y, p.z] for p in pts])
    facets_blade = np.array(facets)

    # 6. Gin-Pole A-Frame & Winch
    gin_l = Part.makeCylinder(0.08, 4.20, FreeCAD.Vector(0.80, -0.70, CONT_H + 0.13), FreeCAD.Vector(-0.25, 0.15, 1.0))
    gin_r = Part.makeCylinder(0.08, 4.20, FreeCAD.Vector(0.80, 0.70, CONT_H + 0.13), FreeCAD.Vector(-0.25, -0.15, 1.0))
    apex_z = CONT_H + 0.13 + 4.20 * (1.0 / math.sqrt(0.25**2 + 0.15**2 + 1.0))
    apex_x = 0.80 - 4.20 * (0.25 / math.sqrt(0.25**2 + 0.15**2 + 1.0))
    sheave = Part.makeCylinder(0.14, 0.10, FreeCAD.Vector(apex_x, -0.05, apex_z - 0.05), FreeCAD.Vector(0, 1, 0))
    gp_solid = gin_l.fuse(gin_r).fuse(sheave)
    pts, facets = gp_solid.tessellate(0.25)
    pts_gp = np.array([[p.x, p.y, p.z] for p in pts])
    facets_gp = np.array(facets)

    winch_frame = Part.makeBox(0.60, 0.70, 0.50, FreeCAD.Vector(1.40, -0.35, CONT_H))
    winch_drum  = Part.makeCylinder(0.16, 0.40, FreeCAD.Vector(1.50, -0.20, CONT_H + 0.25), FreeCAD.Vector(0, 1, 0))
    winch = winch_frame.fuse(winch_drum)
    pts, facets = winch.tessellate(0.25)
    pts_w = np.array([[p.x, p.y, p.z] for p in pts])
    facets_w = np.array(facets)

    # 7. Ground Cribbing Trestle Stand
    stand_w, stand_h = 2.00, CONT_H - MAST_D / 2.0
    c_leg_l = Part.makeBox(0.35, 0.24, stand_h, FreeCAD.Vector(-0.175, -stand_w/2.0, 0))
    c_leg_r = Part.makeBox(0.35, 0.24, stand_h, FreeCAD.Vector(-0.175, stand_w/2.0 - 0.24, 0))
    c_top   = Part.makeBox(0.40, stand_w, 0.20, FreeCAD.Vector(-0.20, -stand_w/2.0, stand_h - 0.20))
    cribbing_solid = c_leg_l.fuse(c_leg_r).fuse(c_top)
    pts, facets = cribbing_solid.tessellate(0.35)
    pts_crib = np.array([[p.x, p.y, p.z] for p in pts])
    facets_crib = np.array(facets)

    # 8. STRIDER-M v2.1 Chassis & Body Components
    # Crawler Tracks
    track_l = strider_mod.create_crawler_track_v2(center_y=0.0)
    pts, facets = track_l.tessellate(0.45)
    pts_track = np.array([[p.x, p.y, p.z] for p in pts])
    facets_track = np.array(facets)

    # Center Chassis Frame, Deck Plate, Cradle & Turret Dock
    deck_z = strider_mod.CHASSIS_H * 0.5
    chassis_frame = Part.makeBox(strider_mod.DECK_L * 1.15, 2.3, strider_mod.CHASSIS_H * 0.72, FreeCAD.Vector(-strider_mod.DECK_L * 0.575, -1.15, -0.22))
    deck_plate = Part.makeBox(strider_mod.DECK_L, strider_mod.DECK_W, strider_mod.DECK_H, FreeCAD.Vector(-strider_mod.DECK_L/2.0, -strider_mod.DECK_W/2.0, deck_z))
    body_core = chassis_frame.fuse(deck_plate)
    cage = strider_mod.create_front_crash_cage()
    cradle = strider_mod.create_cargo_retention_cradle()
    dock = strider_mod.create_turret_dock_v2()
    strider_body_solid = body_core.fuse(cage).fuse(cradle).fuse(dock)
    pts, facets = strider_body_solid.tessellate(0.40)
    pts_sbody = np.array([[p.x, p.y, p.z] for p in pts])
    facets_sbody = np.array(facets)

    # Single Spider Outrigger Assembly (for dynamic articulation)
    single_outrigger = strider_mod.create_outrigger(sign_x=1.0, sign_y=1.0)
    pts, facets = single_outrigger.tessellate(0.35)
    pts_sout = np.array([[p.x, p.y, p.z] for p in pts])
    facets_sout = np.array(facets)

    # 9. CORA-M 7-DoF Manipulator Components
    # Base Turret & Shoulder Knuckle
    collar_base = Part.makeCylinder(0.48, 0.18, FreeCAD.Vector(0, 0, 0), FreeCAD.Vector(0, 0, 1))
    turret = Part.makeCylinder(0.38, 0.35, FreeCAD.Vector(0, 0, 0.18), FreeCAD.Vector(0, 0, 1))
    knuckle = Part.makeCylinder(0.22, 0.44, FreeCAD.Vector(0, -0.22, 0.53), FreeCAD.Vector(0, 1, 0))
    cora_base_solid = collar_base.fuse(turret).fuse(knuckle)
    pts, facets = cora_base_solid.tessellate(0.30)
    pts_cbase = np.array([[p.x, p.y, p.z] for p in pts])
    facets_cbase = np.array(facets)

    # Bicep Boom (1.35m)
    bicep = cora_mod.make_arm_segment(1.35, 0.18, 0.14)
    pts, facets = bicep.tessellate(0.30)
    pts_bicep = np.array([[p.x, p.y, p.z] for p in pts])
    facets_bicep = np.array(facets)

    # Forearm (Monkey-Y dual branches) & Caliper Grippers
    elbow = Part.makeCylinder(0.16, 0.36, FreeCAD.Vector(0, -0.18, 0), FreeCAD.Vector(0, 1, 0))
    forearm_solids = [elbow]
    for sign_b in [-1.0, 1.0]:
        fa = cora_mod.make_arm_segment(1.10, 0.12, 0.09)
        b_rot = FreeCAD.Rotation(FreeCAD.Vector(1, 0, 0), sign_b * 18.0)
        fa.Placement = FreeCAD.Placement(FreeCAD.Vector(0, 0, 0), b_rot)
        wrist_vec = b_rot.multVec(FreeCAD.Vector(0, 0, 1.10))
        kn = Part.makeSphere(0.10, wrist_vec)
        cal = cora_mod.make_caliper_gripper(gap=0.12)
        cal.Placement = FreeCAD.Placement(wrist_vec, b_rot)
        forearm_solids.extend([fa, kn, cal])
    cora_forearm_solid = forearm_solids[0]
    for s in forearm_solids[1:]:
        cora_forearm_solid = cora_forearm_solid.fuse(s)
    pts, facets = cora_forearm_solid.tessellate(0.30)
    pts_cfa = np.array([[p.x, p.y, p.z] for p in pts])
    facets_cfa = np.array(facets)

    meta = {
        "CONT_L": CONT_L, "CONT_W": CONT_W, "CONT_H": CONT_H,
        "MAST_H": MAST_H, "MAST_D": MAST_D, "OUTRIGGER_EXT": OUTRIGGER_EXT,
        "PAD_THICK": PAD_THICK, "GUY_RING_Z": wind_mod.GUY_RING_Z,
        "spinner_x": spinner_x, "apex_x": apex_x, "apex_z": apex_z,
        "ROVER_W": strider_mod.ROVER_W, "TRACK_W": strider_mod.TRACK_W
    }

    meshes = {
        "base": (pts_base, facets_base),
        "outrigger": (pts_out, facets_out),
        "mast_sec": (pts_sec, facets_sec),
        "lift_collar": (pts_lc, facets_lc),
        "guy_collar": (pts_gc, facets_gc),
        "nacelle": (pts_nac, facets_nac),
        "hub": (pts_hub, facets_hub),
        "blade": (pts_blade, facets_blade),
        "gin_pole": (pts_gp, facets_gp),
        "winch": (pts_w, facets_w),
        "cribbing": (pts_crib, facets_crib),
        "strider_track": (pts_track, facets_track),
        "strider_body": (pts_sbody, facets_sbody),
        "strider_outrigger": (pts_sout, facets_sout),
        "cora_base": (pts_cbase, facets_cbase),
        "cora_bicep": (pts_bicep, facets_bicep),
        "cora_forearm": (pts_cfa, facets_cfa)
    }

    return meshes, meta

# -----------------------------------------------------------------------------
# Kinematics & Camera Director
# -----------------------------------------------------------------------------
def get_scene_and_camera(f, meta, total_frames=TOTAL_FRAMES):
    """
    Computes kinematics, camera focus, range, azimuth, elevation, and telemetry HUD
    for frame f across all 5 continuous stages.
    """
    t_sec = f / FPS
    CONT_H = meta["CONT_H"]
    trunnion_x = -0.12
    trunnion_z = CONT_H

    # Defaults
    strider_x = 8.50
    strider_out_ext = 1.0
    cora_yaw = 180.0
    cora_pitch = 10.0
    cora_elbow = 70.0
    mast_assembled_ratio = 1.0
    tilt_theta = 0.0
    spin_ang = 0.0
    umbilical_connected = False
    offloading_active = False
    offload_mast_pos = None

    # Stage 1: STRIDER-M Arrival & Spider Outrigger Stabilization (0.0s - 4.0s, Frames 0-48)
    if f < 48:
        stage_num = 1
        stage_title = "STAGE 1: STRIDER-M TUNDRA ARRIVAL & SPIDER OUTRIGGER STABILIZATION [PHASE 2]"
        stage_desc = "Transporter positions in polar corridor (X=+8.5m); 4x spider outriggers anchor frozen terrain"
        stage_color = "#e06c28"
        p = f / 48.0
        s = 0.5 - 0.5 * math.cos(p * math.pi)
        # Transporter drives in from X = 13.5m to 8.5m
        strider_x = 13.5 - 5.0 * s
        # Outriggers deploy in the second half of Stage 1 (p >= 0.50)
        strider_out_ext = max(0.0, min(1.0, (p - 0.45) / 0.55))
        cora_yaw = 180.0
        cora_pitch = 10.0
        cora_elbow = 70.0
        mast_assembled_ratio = 0.40 + 0.20 * s

        # Camera: low-angle zoom framing STRIDER-M arrival and track cleats
        cx = strider_x * 0.6
        cy = 0.0
        cz = 2.2
        max_r = 11.5 - 2.5 * s
        azim = -32.0 + 16.0 * s
        elev = 18.0 - 4.0 * s

    # Stage 2: CORA-M Unlatching & Robotic Mast Offloading (4.0s - 8.0s, Frames 48-96)
    elif f < 96:
        stage_num = 2
        stage_title = "STAGE 2: CORA-M 7-DoF UNLATCHING & ROBOTIC MAST OFFLOADING [PHASE 3]"
        stage_desc = "CORA-M unlatches from deck cradle; golden calipers roll 4.8m mast tube across transom rollers"
        stage_color = "#ffd700"
        p = (f - 48) / 48.0
        s = 0.5 - 0.5 * math.cos(p * math.pi)
        strider_x = 8.50
        strider_out_ext = 1.0
        # Arm articulates: unlatches, rotates yaw towards cribbing (180° -> 135° -> 90° -> 0°)
        cora_yaw = 180.0 - 180.0 * s
        cora_pitch = 10.0 + 35.0 * math.sin(s * math.pi)
        cora_elbow = 70.0 - 40.0 * math.sin(s * math.pi)
        offloading_active = True
        # Offloaded mast tube translates from STRIDER deck (X = 6.5m) to cribbing (X = -2.0m)
        offload_x = 6.50 * (1.0 - s) + (-2.00) * s
        offload_mast_pos = np.array([offload_x, 0.0, trunnion_z])
        mast_assembled_ratio = 0.60 + 0.40 * s

        # Camera: medium orbital tracking CORA-M golden calipers and mast offloading
        cx = 3.5
        cy = 0.0
        cz = 2.8
        max_r = 9.0 + 1.5 * s
        azim = -48.0 - 20.0 * s
        elev = 22.0 + 4.0 * s

    # Stage 3: Modular Mast Sleeve Coupling & 26m Rotor Rigging (8.0s - 12.0s, Frames 96-144)
    elif f < 144:
        stage_num = 3
        stage_title = "STAGE 3: MODULAR MAST HORIZONTAL SLEEVE COUPLING & 26m ROTOR RIGGING [PHASE 3/4]"
        stage_desc = "5x modular mast sections lock flanged sleeve joints; insulated nacelle & 3x blades assemble at tip"
        stage_color = "#5dade2"
        p = (f - 96) / 48.0
        s = 0.5 - 0.5 * math.cos(p * math.pi)
        strider_x = 8.50
        strider_out_ext = 1.0
        cora_yaw = 0.0
        cora_pitch = 30.0 + 15.0 * math.sin(s * math.pi)
        cora_elbow = 40.0
        mast_assembled_ratio = 1.0

        # Camera: wide crane shot scanning along the 24m horizontal tower to nacelle
        cx = -8.0 - 8.0 * s
        cy = 0.0
        cz = 3.5 + 1.5 * s
        max_r = 13.0 + 5.0 * s
        azim = -68.0 + 24.0 * s
        elev = 24.0 + 2.0 * s

    # Stage 4: Cooperative Gin-Pole Winch Hoisting & Tilt-Up Erection Arc (12.0s - 16.5s, Frames 144-198)
    elif f < 198:
        stage_num = 4
        p = (f - 144) / 54.0
        s = 0.5 - 0.5 * math.cos(p * math.pi)
        tilt_theta = s * 90.0
        stage_title = f"STAGE 4: COOPERATIVE GIN-POLE TILT-UP HOISTING [θ = {tilt_theta:4.1f}°] [PHASE 4]"
        stage_desc = "Container electric winch & STRIDER-M auxiliary winch line hoist tower; CORA-M tracks ascent"
        stage_color = "#e67e22"
        strider_x = 8.50
        strider_out_ext = 1.0
        # CORA-M tracks ascending mast
        cora_yaw = 0.0
        cora_pitch = 30.0 + 40.0 * s
        cora_elbow = 40.0 - 20.0 * s
        mast_assembled_ratio = 1.0

        # Camera: dramatic rising perspective tracking tophead ascent to 24m vertical
        cx = -8.0 * (1.0 - s) + 2.0 * s
        cy = 0.0
        cz = 5.0 * (1.0 - s) + 15.5 * s
        max_r = 17.5 + 2.5 * s
        azim = -44.0 + 64.0 * s
        elev = 26.0 - 8.0 * s

    # Stage 5: Foundation Lock, Microgrid Power Umbilical & Rotor Commissioning (16.5s - 20.0s, Frames 198-240)
    else:
        stage_num = 5
        stage_title = "STAGE 5: VERTICAL LOCK, MICROGRID UMBILICAL TETHER & ROTOR COMMISSIONING [PHASE 5]"
        stage_desc = "Tower seated in base socket; CORA-M connects 400V microgrid tether; 26m rotor spins 2.5 revs"
        stage_color = "#2ecc71"
        p = (f - 198) / 42.0
        s = 0.5 - 0.5 * math.cos(p * math.pi)
        tilt_theta = 90.0
        spin_ang = s * 900.0  # 2.5 revolutions (900 degrees)
        strider_x = 8.50
        strider_out_ext = 1.0
        # CORA-M routes and plugs the microgrid umbilical between turbine and STRIDER-M
        cora_yaw = -15.0 * math.sin(s * math.pi)
        cora_pitch = 25.0
        cora_elbow = 55.0
        umbilical_connected = True
        mast_assembled_ratio = 1.0

        # Camera: majestic wide orbit framing the operational wind-diesel microgrid cluster
        cx = 3.0
        cy = 0.0
        cz = 12.0
        max_r = 20.0 - 2.0 * s
        azim = 20.0 + 35.0 * s
        elev = 18.0 + 4.0 * s

    return {
        "f": f,
        "t_sec": t_sec,
        "stage_num": stage_num,
        "stage_title": stage_title,
        "stage_desc": stage_desc,
        "stage_color": stage_color,
        "strider_x": strider_x,
        "strider_out_ext": strider_out_ext,
        "cora_yaw": cora_yaw,
        "cora_pitch": cora_pitch,
        "cora_elbow": cora_elbow,
        "mast_assembled_ratio": mast_assembled_ratio,
        "tilt_theta": tilt_theta,
        "spin_ang": spin_ang,
        "umbilical_connected": umbilical_connected,
        "offloading_active": offloading_active,
        "offload_mast_pos": offload_mast_pos,
        "camera": (cx, cy, cz, max_r, azim, elev)
    }

# -----------------------------------------------------------------------------
# Parallel Frame Rendering Worker
# -----------------------------------------------------------------------------
def render_frame_worker(task_data):
    """Worker process rendering a single multi-system kinematic frame."""
    f, meshes, meta, kinematics, frame_path = task_data
    CONT_L = meta["CONT_L"]
    CONT_W = meta["CONT_W"]
    CONT_H = meta["CONT_H"]
    MAST_H = meta["MAST_H"]
    MAST_D = meta["MAST_D"]
    GUY_RING_Z = meta["GUY_RING_Z"]
    OUTRIGGER_EXT = meta["OUTRIGGER_EXT"]
    PAD_THICK = meta["PAD_THICK"]
    ROVER_W = meta["ROVER_W"]
    TRACK_W = meta["TRACK_W"]

    cx, cy, cz, max_r, azim, elev = kinematics["camera"]
    tilt_rad = math.radians(kinematics["tilt_theta"])
    spin_rad = math.radians(kinematics["spin_ang"])
    strider_x = kinematics["strider_x"]
    strider_z = 0.825

    fig = plt.figure(figsize=(16, 9), dpi=140, facecolor="#0e1319")
    ax = fig.add_subplot(111, projection="3d", facecolor="#0e1319")

    # 1. Permafrost Snow Grid (Z = 0.000 m)
    gx = np.linspace(-32.0, 16.0, 12)
    gy = np.linspace(-14.0, 14.0, 8)
    GX, GY = np.meshgrid(gx, gy)
    GZ = np.zeros_like(GX)
    ax.plot_wireframe(GX, GY, GZ, color="#253342", alpha=0.40, linewidth=0.65)

    def draw_mesh(pts, facets, transform_fn, col, alpha=0.88, edge_col="#222222", edge_w=0.15):
        t_pts = transform_fn(pts)
        polys = [t_pts[tri] for tri in facets]
        coll = Poly3DCollection(polys, facecolors=col, alpha=alpha, edgecolors=edge_col, linewidths=edge_w)
        ax.add_collection3d(coll)

    # 2. Wind Turbine Foundation Base & Outriggers
    draw_mesh(meshes["base"][0], meshes["base"][1], lambda p: p, "#1976d2", alpha=0.85, edge_col="#0d47a1")
    for sx in [-1.0, 1.0]:
        for sy in [-1.0, 1.0]:
            bx = sx * (CONT_L / 2.0 - 0.40)
            by = sy * (CONT_W / 2.0)
            def t_out(p, bx=bx, by=by, sy=sy):
                R = np.eye(3) if sy > 0 else rot_z(math.pi)
                return np.dot(p, R.T) + np.array([bx, by, 0.0])
            draw_mesh(meshes["outrigger"][0], meshes["outrigger"][1], t_out, "#1565c0", alpha=0.82, edge_col="#0d47a1")

    # 3. Gin-Pole A-Frame & Winch
    draw_mesh(meshes["gin_pole"][0], meshes["gin_pole"][1], lambda p: p, "#90a4ae", alpha=0.90, edge_col="#546e7a")
    draw_mesh(meshes["winch"][0], meshes["winch"][1], lambda p: p, "#ffb300", alpha=0.92, edge_col="#ff8f00")

    # 4. Cribbing Trestle Stands
    for crib_x in [-4.50, -10.50, -16.50, -22.50]:
        draw_mesh(meshes["cribbing"][0], meshes["cribbing"][1], lambda p, cx=crib_x: p + np.array([cx, 0.0, 0.0]), "#795548", alpha=0.88, edge_col="#4e342e")

    # 5. Tower Kinematic Transformation (0° horizontal along -X -> 90° vertical along +Z)
    trunnion_pos = np.array([-0.12, 0.0, CONT_H])
    Ry = rot_y(-tilt_rad)  # Rotates around Y: X goes to Z
    def to_tower(p_local):
        # p_local: [0, 0, z_span] where z_span is along tower length
        # At tilt=0: span extends along -X. At tilt=90°: span extends along +Z.
        span_vec = np.zeros_like(p_local)
        span_vec[:, 0] = -p_local[:, 2] * math.cos(tilt_rad)
        span_vec[:, 1] = p_local[:, 1]
        span_vec[:, 2] = p_local[:, 2] * math.sin(tilt_rad)
        return span_vec + trunnion_pos

    # 6. Modular Mast Sections
    sec_len = 4.80
    for s_idx in range(5):
        s_base = s_idx * sec_len
        def t_sec(p, sb=s_base):
            p_rot = np.zeros_like(p)
            p_rot[:, 0] = p[:, 0]
            p_rot[:, 1] = p[:, 1]
            p_rot[:, 2] = sb + p[:, 2]
            return to_tower(p_rot)
        draw_mesh(meshes["mast_sec"][0], meshes["mast_sec"][1], t_sec, "#e0e0e0", alpha=0.92, edge_col="#9e9e9e")

    # Collars
    draw_mesh(meshes["lift_collar"][0], meshes["lift_collar"][1], lambda p: to_tower(p + np.array([0, 0, 6.0])), "#ffb300", alpha=0.95, edge_col="#ff8f00")
    draw_mesh(meshes["guy_collar"][0], meshes["guy_collar"][1], lambda p: to_tower(p + np.array([0, 0, GUY_RING_Z])), "#00e5ff", alpha=0.95, edge_col="#00b0ff")

    # 7. Tophead Nacelle, Hub & 3x Blades
    top_pos_local = np.array([[0.0, 0.0, MAST_H]])
    top_pos_world = to_tower(top_pos_local)[0]
    
    def to_nacelle(p):
        p_tilt = np.dot(p, Ry.T)
        return p_tilt + top_pos_world

    draw_mesh(meshes["nacelle"][0], meshes["nacelle"][1], to_nacelle, "#ffb300", alpha=0.90, edge_col="#ff8f00")
    
    # Hub with Rotor Spin
    R_spin = rot_x(spin_rad)
    def to_hub(p):
        p_spun = np.dot(p, R_spin.T)
        return to_nacelle(p_spun)
    draw_mesh(meshes["hub"][0], meshes["hub"][1], to_hub, "#ff8f00", alpha=0.92, edge_col="#e65100")

    # 3x Aerodynamic Blades (120° spacing)
    for b_idx in range(3):
        b_ang = b_idx * (2.0 * math.pi / 3.0) + spin_rad
        Rb = rot_x(b_ang)
        def to_blade(p, Rb=Rb):
            p_rot = np.dot(p, Rb.T)
            return to_nacelle(p_rot)
        draw_mesh(meshes["blade"][0], meshes["blade"][1], to_blade, "#eceff1", alpha=0.95, edge_col="#90a4ae")

    # 8. STRIDER-M v2.1 Transporter
    strider_world_pos = np.array([strider_x, 0.0, strider_z])
    
    # Body core & deck
    draw_mesh(meshes["strider_body"][0], meshes["strider_body"][1], lambda p: p + strider_world_pos, "#263238", alpha=0.88, edge_col="#ffab00")
    
    # Dual Crawler Tracks
    track_y = ROVER_W / 2.0 - TRACK_W / 2.0
    for sign_tr in [-1.0, 1.0]:
        t_pos = strider_world_pos + np.array([0.0, sign_tr * track_y, 0.0])
        draw_mesh(meshes["strider_track"][0], meshes["strider_track"][1], lambda p, tp=t_pos: p + tp, "#1a2327", alpha=0.92, edge_col="#37474f")

    # 4x Spider Outriggers (with dynamic deployment factor)
    out_factor = kinematics["strider_out_ext"]
    for sign_x in [-1.0, 1.0]:
        for sign_y in [-1.0, 1.0]:
            def t_sout(p, sx=sign_x, sy=sign_y, factor=out_factor):
                p_copy = p.copy()
                # Deploy outrigger: scale outward Y and ground Z
                p_copy[:, 1] = p_copy[:, 1] * (0.50 + 0.50 * factor)
                p_copy[:, 2] = p_copy[:, 2] * factor
                if sy < 0:
                    p_copy[:, 1] = -p_copy[:, 1]
                if sx < 0:
                    p_copy[:, 0] = -p_copy[:, 0]
                return p_copy + strider_world_pos
            draw_mesh(meshes["strider_outrigger"][0], meshes["strider_outrigger"][1], t_sout, "#ffab00", alpha=0.90, edge_col="#ff8f00")

    # 9. CORA-M 7-DoF Manipulator Arm
    turret_dock_world = strider_world_pos + np.array([0.0, 0.0, 1.205])
    cora_yaw_rad = math.radians(kinematics["cora_yaw"])
    cora_pitch_rad = math.radians(kinematics["cora_pitch"])
    cora_elbow_rad = math.radians(kinematics["cora_elbow"])

    R_yaw = rot_z(cora_yaw_rad)
    R_shoulder = rot_y(cora_pitch_rad)
    R_elbow = rot_y(cora_pitch_rad - cora_elbow_rad)

    # Turret Base
    draw_mesh(meshes["cora_base"][0], meshes["cora_base"][1], lambda p: np.dot(p, R_yaw.T) + turret_dock_world, "#ffd700", alpha=0.95, edge_col="#b78103")

    # Bicep Boom
    knuckle_pivot_world = turret_dock_world + np.dot(np.array([0.0, 0.0, 0.53]), R_yaw.T)
    R_bicep_full = np.dot(R_yaw, R_shoulder)
    draw_mesh(meshes["cora_bicep"][0], meshes["cora_bicep"][1], lambda p: np.dot(p, R_bicep_full.T) + knuckle_pivot_world, "#ffd700", alpha=0.95, edge_col="#b78103")

    # Forearm & Golden Calipers
    bicep_end_world = knuckle_pivot_world + np.dot(np.array([0.0, 0.0, 1.35]), R_bicep_full.T)
    R_fa_full = np.dot(R_yaw, R_elbow)
    draw_mesh(meshes["cora_forearm"][0], meshes["cora_forearm"][1], lambda p: np.dot(p, R_fa_full.T) + bicep_end_world, "#ffd700", alpha=0.95, edge_col="#b78103")

    # 10. Winch Lines, Dynamic Guy Wires & Umbilical Tether
    apex_pt = np.array([meta["apex_x"], 0.0, meta["apex_z"]])
    winch_pt = np.array([1.50, 0.0, CONT_H + 0.25])
    lc_world = to_tower(np.array([[0.0, 0.0, 6.0]]))[0]

    # Container Gin-Pole Winch Line
    ax.plot([winch_pt[0], apex_pt[0], lc_world[0]],
            [winch_pt[1], apex_pt[1], lc_world[1]],
            [winch_pt[2], apex_pt[2], lc_world[2]],
            color="#e67e22", linewidth=2.0, alpha=0.92)

    # STRIDER-M Auxiliary Winch Tether (to forward bull-bar shackle)
    strider_winch_pt = strider_world_pos + np.array([-2.60, 0.0, 1.05])
    ax.plot([strider_winch_pt[0], apex_pt[0]],
            [strider_winch_pt[1], apex_pt[1]],
            [strider_winch_pt[2], apex_pt[2]],
            color="#ffab00", linewidth=1.5, linestyle="--", alpha=0.85)

    # 4x Dynamic Guy Wires
    gc_world = to_tower(np.array([[0.0, 0.0, GUY_RING_Z]]))[0]
    for sx in [-1.0, 1.0]:
        for sy in [-1.0, 1.0]:
            anchor = np.array([
                sx * (CONT_L / 2.0 - 0.40),
                sy * (CONT_W / 2.0 + OUTRIGGER_EXT - 0.25),
                PAD_THICK
            ])
            ax.plot([anchor[0], gc_world[0]],
                    [anchor[1], gc_world[1]],
                    [anchor[2], gc_world[2]],
                    color="#00e5ff", linewidth=1.2, alpha=0.78)

    # High-Voltage Arctic Microgrid Umbilical Tether
    if kinematics["umbilical_connected"]:
        cab_plug = np.array([CONT_L / 2.0 + 0.90, 0.0, 1.20])
        strider_plug = strider_world_pos + np.array([-1.20, 0.0, 0.95])
        # Sagging catenary curve between plugs
        ux = np.linspace(cab_plug[0], strider_plug[0], 15)
        uy = np.zeros_like(ux)
        mid_x = (cab_plug[0] + strider_plug[0]) / 2.0
        uz = 0.65 + 0.50 * ((ux - mid_x) / (mid_x - cab_plug[0]))**2
        ax.plot(ux, uy, uz, color="#ffd700", linewidth=3.0, alpha=0.95)

    # 11. Engineering Telemetry HUD Overlay
    fig.text(0.04, 0.94, "ARCTIC FIELD INITIATIVE #105  |  COOPERATIVE MULTI-SYSTEM KINEMATICS",
             color="#00e5ff", fontsize=10.0, fontfamily="monospace", fontweight="bold")
    fig.text(0.04, 0.90, "STRIDER-M v2.1 Transporter  *  CORA-M v1.1 7-DoF Robotics  *  Modular Wind Turbine v3.1",
             color="#7d8b9e", fontsize=8.2, fontfamily="monospace")
    fig.text(0.78, 0.94, f"TIME: {kinematics['t_sec']:5.2f}s / {TOTAL_FRAMES/FPS:.2f}s",
             color="#7d8b9e", fontsize=8.8, fontfamily="monospace", fontweight="bold")

    fig.text(0.04, 0.052, kinematics["stage_title"],
             color=kinematics["stage_color"], fontsize=9.0, fontfamily="monospace", fontweight="bold")
    fig.text(0.04, 0.022, f"Action: {kinematics['stage_desc']}",
             color="#9daab8", fontsize=8.0, fontfamily="monospace")

    # 12. Camera Positioning
    ax.set_xlim(cx - max_r, cx + max_r)
    ax.set_ylim(cy - max_r * 0.70, cy + max_r * 0.70)
    ax.set_zlim(0.0, cz + max_r * 0.75)
    ax.axis("off")
    ax.view_init(elev=elev, azim=azim)

    plt.savefig(
        frame_path,
        dpi=130,
        bbox_inches="tight",
        pad_inches=0.0,
        facecolor=fig.get_facecolor(),
        edgecolor="none"
    )
    plt.close(fig)
    return f

# -----------------------------------------------------------------------------
# Main Renderer Pipeline & Video Encoding
# -----------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="Multi-Core Cinematic Renderer for STRIDER-M + CORA-M + Wind Turbine v3.1 Kinematics")
    parser.add_argument("--cores", type=int, default=mp.cpu_count(), help="Number of CPU cores to utilize")
    parser.add_argument("--frames", type=int, default=TOTAL_FRAMES, help="Total frames (default 240)")
    parser.add_argument("--fps", type=float, default=FPS, help="Frame rate (default 12.0 fps)")
    args = parser.parse_args()

    total_frames = args.frames
    fps = args.fps
    duration = total_frames / fps

    print(f"\n=======================================================")
    print(f"🎬 Initializing 20-Second Cooperative Field Hoisting Renderer (Issue #105 / TASK-03F)")
    print(f"   Systems: STRIDER-M v2.1 Transporter + CORA-M v1.1 Arm + Wind Turbine v3.1")
    print(f"   5 Stages: Arrival/Outriggers -> Mast Offload -> Rotor Rigging -> Tilt-Up Hoist -> Umbilical & Spin")
    print(f"   Specs: {total_frames} frames @ {fps:.1f} fps ({duration:.2f}s duration) on {args.cores} CPU cores")
    print(f"=======================================================\n")

    print("Building OpenCASCADE B-Rep solid geometry and pre-tessellating subsystem meshes...")
    meshes, meta = build_cad_meshes()
    print("Pre-computation complete for all 17 multi-system meshes.")

    frames_dir = "scratch/frames/strider_cora_wind_erection"
    if os.path.exists(frames_dir):
        shutil.rmtree(frames_dir)
    os.makedirs(frames_dir, exist_ok=True)

    tasks = []
    for f in range(total_frames):
        kinematics = get_scene_and_camera(f, meta, total_frames)
        frame_path = os.path.join(frames_dir, f"frame_{f:04d}.png")
        tasks.append((f, meshes, meta, kinematics, frame_path))

    print(f"Rendering {total_frames} frames in parallel across {args.cores} CPU workers...")
    pool = mp.Pool(processes=args.cores)
    rendered_count = 0
    for idx in pool.imap_unordered(render_frame_worker, tasks):
        rendered_count += 1
        if rendered_count % 30 == 0 or rendered_count == total_frames:
            pct = rendered_count / total_frames * 100.0
            print(f"  -> Rendered {rendered_count}/{total_frames} frames ({pct:.1f}%)")
    pool.close()
    pool.join()

    out_dir = "cad_and_blender/freecad/wind/renders"
    os.makedirs(out_dir, exist_ok=True)
    mp4_out = os.path.join(out_dir, "strider_cora_wind_erection.mp4")
    gif_out = os.path.join(out_dir, "strider_cora_wind_erection.gif")
    frame_pattern = os.path.join(frames_dir, "frame_%04d.png")

    print("\nEncoding high-definition H.264 MP4 video...")
    cmd_mp4 = [
        "ffmpeg", "-y", "-framerate", f"{fps:.2f}", "-i", frame_pattern,
        "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "18",
        "-vf", "scale=trunc(iw/2)*2:trunc(ih/2)*2",
        mp4_out,
    ]
    subprocess.run(cmd_mp4, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    print("Encoding looping animated GIF with Lanczos filtering...")
    cmd_gif = [
        "ffmpeg", "-y", "-framerate", f"{fps:.2f}", "-i", frame_pattern,
        "-vf", "scale=768:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse",
        gif_out,
    ]
    subprocess.run(cmd_gif, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    print(f"\n✅ Generated MP4: {mp4_out} ({os.path.getsize(mp4_out):,} bytes, {fps:.2f} fps)")
    print(f"✅ Generated GIF: {gif_out} ({os.path.getsize(gif_out):,} bytes, {fps:.2f} fps)")
    print("🎉 20-Second Multi-System Cooperative Field Erection Animation Complete!")

if __name__ == "__main__":
    main()
