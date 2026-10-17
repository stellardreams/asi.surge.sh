#!/usr/bin/env python3
"""
render_wind_v3_erection_assembly.py - 16-Second Assembly & Tilt-Up Erection Animation

Lineage:
- Governing Issues: #104 (Modular Arctic Wind Turbine v3.0 FreeCAD Refinements & Rigging), #82
- Motion Design:
  1. Stage 1 (0.0s - 3.0s, Frames 0-36): Foundation Leveling & Outrigger Deployment (4x outriggers swing out 90° & anchor).
  2. Stage 2 (3.0s - 6.67s, Frames 36-80): Modular Mast Horizontal Assembly (5x 4.8m tubular sections glide & bolt on cribbing).
  3. Stage 3 (6.67s - 9.33s, Frames 80-112): Tophead Equipment Docking & 26m Rotor Blade Rigging (Nacelle, hub & 3x blades lock).
  4. Stage 4 (9.33s - 13.33s, Frames 112-160): Crane-Less Gin-Pole Tilt-Up Arc (Winch hoist tensions, 0° -> 90° smooth ascent).
  5. Stage 5 (13.33s - 16.0s, Frames 160-192): Vertical Foundation Lock, Guy Tensioning & Commissioning Rotor Spin.
- Duration: Exactly 16.00 seconds (192 frames @ 12.0 fps).
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

TOTAL_FRAMES = 192
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


def build_cad_meshes():
    """Generates analytical OpenCASCADE solid geometry and pre-tessellates all turbine components."""
    spec = importlib.util.spec_from_file_location("mod_wind", "cad_and_blender/freecad/wind/modular_wind_turbine_v3.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)

    CONT_L = mod.CONT_L
    CONT_W = mod.CONT_W
    CONT_H = mod.CONT_H
    MAST_H = mod.MAST_H
    MAST_D = mod.MAST_D
    OUTRIGGER_EXT = mod.OUTRIGGER_EXT
    PAD_RADIUS = mod.PAD_RADIUS
    PAD_THICK = mod.PAD_THICK

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

    # 2. Outrigger Beam, Pad & Helical Cap
    beam = Part.makeBox(mod.OUTRIGGER_W, OUTRIGGER_EXT, 0.28, FreeCAD.Vector(-mod.OUTRIGGER_W / 2.0, 0, 0.12))
    pad = Part.makeCylinder(PAD_RADIUS, PAD_THICK, FreeCAD.Vector(0, OUTRIGGER_EXT - 0.25, 0.0), FreeCAD.Vector(0, 0, 1))
    cap = Part.makeCylinder(0.12, 0.14, FreeCAD.Vector(0, OUTRIGGER_EXT - 0.25, PAD_THICK), FreeCAD.Vector(0, 0, 1))
    out_solid = beam.fuse(pad).fuse(cap)
    pts, facets = out_solid.tessellate(0.30)
    pts_out = np.array([[p.x, p.y, p.z] for p in pts])
    facets_out = np.array(facets)

    # 3. Mast Section (single 4.8m tube with flange)
    sec_h = MAST_H / float(mod.SECTIONS_COUNT)
    tube = Part.makeCylinder(MAST_D / 2.0, sec_h, FreeCAD.Vector(0, 0, 0), FreeCAD.Vector(0, 0, 1))
    flange = Part.makeCylinder(MAST_D / 2.0 + 0.12, 0.14, FreeCAD.Vector(0, 0, sec_h - 0.07), FreeCAD.Vector(0, 0, 1))
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

    # 5. Nacelle & Cowl
    nacelle_body = Part.makeCylinder(mod.NACELLE_D / 2.0, mod.NACELLE_L, FreeCAD.Vector(-mod.NACELLE_L * 0.68, 0, 0), FreeCAD.Vector(1, 0, 0))
    rear_cowl = Part.makeCone(mod.NACELLE_D / 2.0, 0.30, 0.85, FreeCAD.Vector(-mod.NACELLE_L * 0.68, 0, 0), FreeCAD.Vector(-1, 0, 0))
    nac_solid = nacelle_body.fuse(rear_cowl)
    pts, facets = nac_solid.tessellate(0.30)
    pts_nac = np.array([[p.x, p.y, p.z] for p in pts])
    facets_nac = np.array(facets)

    # 6. Hub & Spinner
    spinner_x = mod.NACELLE_L * 0.32
    hub_barrel = Part.makeCylinder(mod.HUB_D / 2.0, 0.55, FreeCAD.Vector(spinner_x, 0, 0), FreeCAD.Vector(1, 0, 0))
    spinner_cone = Part.makeCone(mod.HUB_D / 2.0, 0.12, mod.NOSE_CONE_L, FreeCAD.Vector(spinner_x + 0.55, 0, 0), FreeCAD.Vector(1, 0, 0))
    hub_solid = hub_barrel.fuse(spinner_cone)
    pts, facets = hub_solid.tessellate(0.25)
    pts_hub = np.array([[p.x, p.y, p.z] for p in pts])
    facets_hub = np.array(facets)

    # 7. Blade
    base_blade = mod.create_modular_aerodynamic_blade()
    pts, facets = base_blade.tessellate(0.35)
    pts_blade = np.array([[p.x, p.y, p.z] for p in pts])
    facets_blade = np.array(facets)

    # 8. Gin-Pole A-Frame & Winch
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

    # 9. Cribbing Stand (A-frame / Trestle support)
    stand_w, stand_h = 1.40, CONT_H - MAST_D / 2.0
    c_leg_l = Part.makeBox(0.35, 0.22, stand_h, FreeCAD.Vector(-0.175, -stand_w/2.0, 0))
    c_leg_r = Part.makeBox(0.35, 0.22, stand_h, FreeCAD.Vector(-0.175, stand_w/2.0 - 0.22, 0))
    c_top   = Part.makeBox(0.40, stand_w, 0.20, FreeCAD.Vector(-0.20, -stand_w/2.0, stand_h - 0.20))
    cribbing_solid = c_leg_l.fuse(c_leg_r).fuse(c_top)
    pts, facets = cribbing_solid.tessellate(0.35)
    pts_crib = np.array([[p.x, p.y, p.z] for p in pts])
    facets_crib = np.array(facets)

    meta = {
        "CONT_L": CONT_L, "CONT_W": CONT_W, "CONT_H": CONT_H,
        "MAST_H": MAST_H, "MAST_D": MAST_D, "OUTRIGGER_EXT": OUTRIGGER_EXT,
        "PAD_THICK": PAD_THICK, "GUY_RING_Z": mod.GUY_RING_Z,
        "spinner_x": spinner_x, "apex_x": apex_x, "apex_z": apex_z
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
    }

    return meshes, meta


def get_scene_and_camera(f, meta, total_frames=TOTAL_FRAMES):
    """
    Computes kinematics, camera focus, range, azimuth, elevation, and HUD text
    for frame f.
    """
    CONT_L = meta["CONT_L"]
    CONT_W = meta["CONT_W"]
    CONT_H = meta["CONT_H"]
    MAST_H = meta["MAST_H"]
    GUY_RING_Z = meta["GUY_RING_Z"]
    OUTRIGGER_EXT = meta["OUTRIGGER_EXT"]
    t_sec = f / FPS

    # -------------------------------------------------------------------------
    # Stage Determination & Kinematics
    # -------------------------------------------------------------------------
    if f < 36:
        stage_num = 1
        stage_title = "STAGE 1: FOUNDATION OUTRIGGER & HELICAL ANCHOR DEPLOYMENT"
        stage_desc = "4x heavy tubular outriggers swing out 90° and set frozen terrain pads"
        stage_color = "#e06c28"
        p = f / 36.0
        s = 0.5 - 0.5 * math.cos(p * math.pi)
        outrigger_ext = s
        p_mast = 0.0
        p_blades = 0.0
        gin_pole_erect = False
        tilt_theta = 0.0
        spin_ang = 0.0

        # Camera: low-angle zoom on container foundation
        cx = 0.0
        cy = 0.0
        cz = 2.0
        max_r = 6.2 - 0.8 * s
        azim = -42.0 + 20.0 * s
        elev = 22.0 - 4.0 * s

    elif f < 80:
        stage_num = 2
        stage_title = "STAGE 2: MODULAR TUBULAR MAST HORIZONTAL ASSEMBLY [5x 4.8m SECTIONS]"
        stage_desc = "Tubular sections glide on ground cribbing and lock flanged sleeve joints"
        stage_color = "#5dade2"
        p = (f - 36) / 44.0
        s = 0.5 - 0.5 * math.cos(p * math.pi)
        outrigger_ext = 1.0
        p_mast = p
        p_blades = 0.0
        gin_pole_erect = False
        tilt_theta = 0.0
        spin_ang = 0.0

        # Camera: smoothly glides along assembling mast (-X axis)
        cx = -2.0 - 10.0 * s
        cy = 0.0
        cz = 2.4 + 1.2 * s
        max_r = 7.5 + 6.5 * s
        azim = -22.0 - 24.0 * s
        elev = 18.0 + 4.0 * s

    elif f < 112:
        stage_num = 3
        stage_title = "STAGE 3: TOPHEAD NACELLE DOCKING & 26m ROTOR BLADE RIGGING"
        stage_desc = "Insulated nacelle mounts, 3x aerodynamic blades lock, gin-pole hoists line"
        stage_color = "#d49b28"
        p = (f - 80) / 32.0
        s = 0.5 - 0.5 * math.cos(p * math.pi)
        outrigger_ext = 1.0
        p_mast = 1.0
        p_blades = min(1.0, max(0.0, (p - 0.20) / 0.60))
        gin_pole_erect = (p >= 0.50)
        tilt_theta = 0.0
        spin_ang = 0.0

        # Camera: frames nacelle docking and blade attachment, pulls back
        cx = -16.0 * (1.0 - s) + (-10.0) * s
        cy = 0.0
        cz = 3.6 * (1.0 - s) + 5.5 * s
        max_r = 11.0 * (1.0 - s) + 16.5 * s
        azim = -46.0 - 10.0 * s
        elev = 22.0 + 4.0 * s

    elif f < 160:
        stage_num = 4
        p = (f - 112) / 48.0
        s = 0.5 - 0.5 * math.cos(p * math.pi)
        tilt_theta = s * 90.0
        stage_title = f"STAGE 4: CRANE-LESS GIN-POLE TILT-UP ARC [θ = {tilt_theta:4.1f}°]"
        stage_desc = "Electric winch tensions hoist rope over A-frame apex, tilting tower to vertical"
        stage_color = "#e06c28"
        outrigger_ext = 1.0
        p_mast = 1.0
        p_blades = 1.0
        gin_pole_erect = True
        spin_ang = 0.0

        # Camera: cinematic crane shot ascending with rising tophead
        cx = -10.0 * (1.0 - s) + 0.0 * s
        cy = 0.0
        cz = 5.5 * (1.0 - s) + 16.0 * s
        max_r = 16.5 * (1.0 - s) + 17.5 * s
        azim = -56.0 + 72.0 * s
        elev = 26.0 - 10.0 * s

    else:
        stage_num = 5
        stage_title = "STAGE 5: VERTICAL LOCK, GUY TENSIONING & COMMISSIONING ROTOR SPIN"
        stage_desc = "Tower seated in base socket, 4x guy wires locked taut, 26m rotor generates power"
        stage_color = "#2ecc71"
        p = (f - 160) / 32.0
        s = 0.5 - 0.5 * math.cos(p * math.pi)
        outrigger_ext = 1.0
        p_mast = 1.0
        p_blades = 1.0
        gin_pole_erect = True
        tilt_theta = 90.0
        # Smoothly accelerates rotor spin: 2.5 full revolutions
        spin_ang = math.radians(p * 900.0)

        # Camera: majestic full-system celebratory orbit around spinning turbine
        cx = 0.0
        cy = 0.0
        cz = 16.0
        max_r = 17.5
        azim = 16.0 + 75.0 * p
        elev = 16.0 - 2.0 * math.sin(p * math.pi)

    kinematics = {
        "stage_num": stage_num,
        "stage_title": stage_title,
        "stage_desc": stage_desc,
        "stage_color": stage_color,
        "t_sec": t_sec,
        "outrigger_ext": outrigger_ext,
        "p_mast": p_mast,
        "p_blades": p_blades,
        "gin_pole_erect": gin_pole_erect,
        "tilt_theta": tilt_theta,
        "spin_ang": spin_ang,
        "camera": (cx, cy, cz, max_r, azim, elev)
    }
    return kinematics


def render_frame_worker(args):
    """Parallel worker to render a single 3D animation frame."""
    f, meshes, meta, kinematics, frame_path = args

    CONT_L = meta["CONT_L"]
    CONT_W = meta["CONT_W"]
    CONT_H = meta["CONT_H"]
    MAST_H = meta["MAST_H"]
    GUY_RING_Z = meta["GUY_RING_Z"]
    OUTRIGGER_EXT = meta["OUTRIGGER_EXT"]
    PAD_THICK = meta["PAD_THICK"]
    spinner_x = meta["spinner_x"]
    apex_x = meta["apex_x"]
    apex_z = meta["apex_z"]

    cx, cy, cz, max_r, azim, elev = kinematics["camera"]
    tilt_theta = kinematics["tilt_theta"]
    outrigger_ext = kinematics["outrigger_ext"]
    p_mast = kinematics["p_mast"]
    p_blades = kinematics["p_blades"]
    gin_pole_erect = kinematics["gin_pole_erect"]
    spin_ang = kinematics["spin_ang"]

    PIVOT = np.array([0.0, 0.0, CONT_H])
    beta = math.radians(tilt_theta - 90.0)
    Ry = rot_y(beta)

    def to_tower(pts_vert):
        """Transforms vertical tower points under base hinge rotation."""
        return PIVOT + (pts_vert @ Ry.T)

    fig = plt.figure(figsize=(10.0, 5.625), facecolor="#0a0c10")
    ax = fig.add_subplot(111, projection="3d", facecolor="#0a0c10")

    # -------------------------------------------------------------------------
    # 1. Snowy Arctic Terrain Grid
    # -------------------------------------------------------------------------
    for gx in np.linspace(-30.0, 10.0, 11):
        ax.plot([gx, gx], [-14.0, 14.0], [0, 0], color="#161c26", linewidth=0.65, alpha=0.6)
    for gy in np.linspace(-14.0, 14.0, 9):
        ax.plot([-30.0, 10.0], [gy, gy], [0, 0], color="#161c26", linewidth=0.65, alpha=0.6)

    # -------------------------------------------------------------------------
    # 2. Cribbing Stands on Ground (visible before/during tilt-up)
    # -------------------------------------------------------------------------
    pts_crib, facets_crib = meshes["cribbing"]
    for cx_stand in [-6.0, -12.0, -18.0, -24.0]:
        pts_c = pts_crib.copy()
        pts_c[:, 0] += cx_stand
        coll = Poly3DCollection(pts_c[facets_crib], alpha=0.88, facecolors="#3b4252", edgecolors="#252a34", linewidths=0.22)
        ax.add_collection3d(coll)

    # -------------------------------------------------------------------------
    # 3. Base Container & Microgrid Cabinet
    # -------------------------------------------------------------------------
    pts_base, facets_base = meshes["base"]
    coll = Poly3DCollection(pts_base[facets_base], alpha=0.96, facecolors="#2e333b", edgecolors="#1c2026", linewidths=0.25)
    ax.add_collection3d(coll)

    # -------------------------------------------------------------------------
    # 4. Foundation Outriggers & Helical Caps
    # -------------------------------------------------------------------------
    pts_out, facets_out = meshes["outrigger"]
    for sx in [-1.0, 1.0]:
        for sy in [-1.0, 1.0]:
            ox = sx * (CONT_L / 2.0 - 0.60)
            oy = sy * (CONT_W / 2.0)
            pts_o = pts_out.copy()
            if sy < 0:
                pts_o[:, 1] = -pts_o[:, 1]
            pts_o[:, 1] *= outrigger_ext
            pts_o += np.array([ox, oy, 0.0])
            coll = Poly3DCollection(pts_o[facets_out], alpha=0.96, facecolors="#e06c28", edgecolors="#9e4410", linewidths=0.25)
            ax.add_collection3d(coll)

    # -------------------------------------------------------------------------
    # 5. Gin-Pole A-Frame & Winch
    # -------------------------------------------------------------------------
    if gin_pole_erect:
        pts_gp, facets_gp = meshes["gin_pole"]
        coll = Poly3DCollection(pts_gp[facets_gp], alpha=0.96, facecolors="#d49b28", edgecolors="#7a550e", linewidths=0.25)
        ax.add_collection3d(coll)

        pts_w, facets_w = meshes["winch"]
        coll = Poly3DCollection(pts_w[facets_w], alpha=0.96, facecolors="#3b4252", edgecolors="#252a34", linewidths=0.25)
        ax.add_collection3d(coll)

    # -------------------------------------------------------------------------
    # 6. Modular Mast Sections (5x 4.8m)
    # -------------------------------------------------------------------------
    pts_sec, facets_sec = meshes["mast_sec"]
    sec_h = MAST_H / 5.0
    for s_idx in range(5):
        thresh = s_idx / 5.0
        if p_mast >= thresh:
            slide_progress = min(1.0, (p_mast - thresh) * 5.0) if f < 80 else 1.0
            slide_s = 0.5 - 0.5 * math.cos(slide_progress * math.pi)
            offset_z = (1.0 - slide_s) * (-8.0)

            pts_s = pts_sec.copy()
            pts_s[:, 2] += s_idx * sec_h + offset_z
            pts_s_world = to_tower(pts_s)
            coll = Poly3DCollection(pts_s_world[facets_sec], alpha=0.96, facecolors="#9daab8", edgecolors="#4d5866", linewidths=0.25)
            ax.add_collection3d(coll)

    # -------------------------------------------------------------------------
    # 7. Collars (Lifting Collar at z=6.0m, Guy Collar at z=16.0m)
    # -------------------------------------------------------------------------
    if f >= 48:
        pts_lc, facets_lc = meshes["lift_collar"]
        pts_l = pts_lc.copy()
        pts_l[:, 2] += 6.0
        coll = Poly3DCollection(to_tower(pts_l)[facets_lc], alpha=0.96, facecolors="#d49b28", edgecolors="#7a550e", linewidths=0.25)
        ax.add_collection3d(coll)

    if f >= 68:
        pts_gc, facets_gc = meshes["guy_collar"]
        pts_g = pts_gc.copy()
        pts_g[:, 2] += GUY_RING_Z
        coll = Poly3DCollection(to_tower(pts_g)[facets_gc], alpha=0.96, facecolors="#d49b28", edgecolors="#7a550e", linewidths=0.25)
        ax.add_collection3d(coll)

    # -------------------------------------------------------------------------
    # 8. Nacelle, Hub & Aerodynamic Blades
    # -------------------------------------------------------------------------
    if f >= 80:
        pts_nac, facets_nac = meshes["nacelle"]
        pts_n = pts_nac.copy()
        pts_n[:, 2] += MAST_H
        coll = Poly3DCollection(to_tower(pts_n)[facets_nac], alpha=0.96, facecolors="#1c5cb8", edgecolors="#0e346d", linewidths=0.25)
        ax.add_collection3d(coll)

        pts_hub, facets_hub = meshes["hub"]
        pts_h = pts_hub.copy()
        pts_h[:, 2] += MAST_H
        coll = Poly3DCollection(to_tower(pts_h)[facets_hub], alpha=0.96, facecolors="#d49b28", edgecolors="#7a550e", linewidths=0.25)
        ax.add_collection3d(coll)

        # 3 Aerodynamic Blades
        blade_center_x = spinner_x + 0.28
        pts_blade, facets_blade = meshes["blade"]
        Rx_spin = rot_x(spin_ang)

        # Radial slide-in distance during Stage 3
        slide_blade_dist = (1.0 - (0.5 - 0.5 * math.cos(p_blades * math.pi))) * 3.5

        for i in range(3):
            ang = math.radians(i * 120.0)
            R_blade = rot_x(ang)
            pts_b = pts_blade.copy()
            # Apply radial assembly standoff
            pts_b[:, 2] += slide_blade_dist
            # Rotate blade into rotor disc
            pts_b = pts_b @ R_blade.T
            # Spin rotor
            pts_b = pts_b @ Rx_spin.T
            # Position at hub center
            pts_b[:, 0] += blade_center_x
            pts_b[:, 2] += MAST_H
            coll = Poly3DCollection(to_tower(pts_b)[facets_blade], alpha=0.96, facecolors="#dce2ec", edgecolors="#7d8b9e", linewidths=0.25)
            ax.add_collection3d(coll)

    # -------------------------------------------------------------------------
    # 9. Dynamic Rigging Cables (Winch Hoist Wire Rope & 4x Guy Wires)
    # -------------------------------------------------------------------------
    if gin_pole_erect:
        lc_world = to_tower(np.array([[0.0, 0.0, 6.0]]))[0]
        apex_pt = np.array([apex_x, 0.0, apex_z])
        winch_pt = np.array([1.50, 0.0, CONT_H + 0.25])

        # Winch Hoist Rope
        ax.plot([winch_pt[0], apex_pt[0], lc_world[0]],
                [winch_pt[1], apex_pt[1], lc_world[1]],
                [winch_pt[2], apex_pt[2], lc_world[2]],
                color="#e67e22", linewidth=2.0, alpha=0.92)

        # 4 Guy Wires
        gc_world = to_tower(np.array([[0.0, 0.0, GUY_RING_Z]]))[0]
        for sx in [-1.0, 1.0]:
            for sy in [-1.0, 1.0]:
                anchor = np.array([
                    sx * (CONT_L / 2.0 - 0.60),
                    sy * (CONT_W / 2.0 + OUTRIGGER_EXT - 0.25),
                    PAD_THICK
                ])
                ax.plot([anchor[0], gc_world[0]],
                        [anchor[1], gc_world[1]],
                        [anchor[2], gc_world[2]],
                        color="#5dade2", linewidth=1.15, alpha=0.75)

    # -------------------------------------------------------------------------
    # 10. Engineering Title & Stage HUD Display
    # -------------------------------------------------------------------------
    fig.text(0.04, 0.94, "MODULAR ARCTIC WIND TURBINE v3.1  |  ERECTION & ASSEMBLY KINEMATICS",
             color="#dce2ec", fontsize=10.0, fontfamily="monospace", fontweight="bold")
    fig.text(0.04, 0.90, "50 kW Class  *  -60°C Arctic Survival  *  Crane-Less Gin-Pole Tilt-Up",
             color="#7d8b9e", fontsize=8.2, fontfamily="monospace")
    fig.text(0.78, 0.94, f"TIME: {kinematics['t_sec']:5.2f}s / {TOTAL_FRAMES/FPS:.2f}s",
             color="#7d8b9e", fontsize=8.8, fontfamily="monospace", fontweight="bold")

    fig.text(0.04, 0.052, kinematics["stage_title"],
             color=kinematics["stage_color"], fontsize=9.0, fontfamily="monospace", fontweight="bold")
    fig.text(0.04, 0.022, f"Action: {kinematics['stage_desc']}",
             color="#9daab8", fontsize=8.0, fontfamily="monospace")

    # -------------------------------------------------------------------------
    # 11. Camera View Limits
    # -------------------------------------------------------------------------
    ax.set_xlim(cx - max_r, cx + max_r)
    ax.set_ylim(cy - max_r, cy + max_r)
    ax.set_zlim(cz - max_r, cz + max_r)
    ax.axis("off")
    ax.view_init(elev=elev, azim=azim)

    plt.savefig(
        frame_path,
        dpi=150,
        bbox_inches="tight",
        pad_inches=0.0,
        facecolor=fig.get_facecolor(),
        edgecolor="none"
    )
    plt.close(fig)
    return f


def main():
    parser = argparse.ArgumentParser(description="16-Second Assembly & Tilt-Up Erection Animation Renderer for Modular Arctic Wind Turbine v3.1")
    parser.add_argument("--cores", type=int, default=mp.cpu_count(), help="Number of CPU cores to utilize")
    parser.add_argument("--frames", type=int, default=TOTAL_FRAMES, help="Total frames (default 192)")
    parser.add_argument("--fps", type=float, default=FPS, help="Frame rate (default 12.0 fps)")
    args = parser.parse_args()

    total_frames = args.frames
    fps = args.fps
    duration = total_frames / fps

    print(f"\n=======================================================")
    print(f"🎬 Initializing 16-Second Erection & Assembly Renderer: Modular Arctic Wind Turbine v3.1")
    print(f"   5-Stage Kinematics: Outriggers -> Mast Assembly -> Rotor Rigging -> Tilt-Up Arc -> Vertical Spin")
    print(f"   Specs: {total_frames} frames @ {fps:.1f} fps ({duration:.2f}s duration) on {args.cores} CPU cores")
    print(f"=======================================================\n")

    print("Building OpenCASCADE B-Rep solid geometry and pre-tessellating meshes...")
    meshes, meta = build_cad_meshes()
    print("Pre-computation complete for all 11 component meshes.")

    frames_dir = "scratch/frames/wind_v3_erection"
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
        if rendered_count % 24 == 0 or rendered_count == total_frames:
            pct = rendered_count / total_frames * 100.0
            print(f"  -> Rendered {rendered_count}/{total_frames} frames ({pct:.1f}%)")
    pool.close()
    pool.join()

    out_dir = "cad_and_blender/freecad/wind/renders"
    os.makedirs(out_dir, exist_ok=True)
    mp4_out = os.path.join(out_dir, "modular_wind_turbine_v3_erection.mp4")
    gif_out = os.path.join(out_dir, "modular_wind_turbine_v3_erection.gif")
    frame_pattern = os.path.join(frames_dir, "frame_%04d.png")

    print("\nEncoding high-definition H.264 MP4 video...")
    cmd_mp4 = [
        "ffmpeg", "-y", "-framerate", f"{fps:.2f}", "-i", frame_pattern,
        "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "17",
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
    print("🎉 16-Second Assembly & Erection Animation Complete!")


if __name__ == "__main__":
    main()
