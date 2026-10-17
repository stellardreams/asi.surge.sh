#!/usr/bin/env python3
"""
render_wind_v3_cinematic.py - 15-Second Cinematic Multi-View & Matrix Camera Fly-Around

Lineage:
- Governing Issues: #104 (Modular Arctic Wind Turbine v3.0 FreeCAD Refinements & Rigging), #82
- Motion Design:
  1. Matrix-Style Sweeping Orbit (0s - 4s): Wide establishing bullet-time 3D orbit around full mast.
  2. Rotor & Blades Macro Swivel (4s - 8s): Zoomed-in inspection of NACA 4415/4418 lofts and sleeve joints.
  3. Structural Guy Collar & Clevis Lug Swivel (8s - 11.5s): Mid-mast zoom on turnbuckles & 24mm steel cables.
  4. Container Roof Gin-Pole & Outriggers Swivel (11.5s - 15s): Low-angle inspection of erection winch & helical anchors.
- Duration: Exactly 15.00 seconds (180 frames @ 12.0 fps).
- Renderer: OpenCASCADE B-Rep tessellation -> Matplotlib 3D -> ffmpeg (MP4 & looping GIF).
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

TOTAL_FRAMES = 180
FPS = 12.0


def load_turntable_renderer():
    """Dynamically loads group extraction functions from turntable renderer."""
    spec = importlib.util.spec_from_file_location("turntable_mod", "scripts/render_freecad_turntables.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def get_camera_params(f, total_frames=TOTAL_FRAMES):
    """
    Computes camera target center (cx, cy, cz), field bounding range,
    azimuth, and elevation for frame f to achieve a 15-second cinematic
    trajectory combining matrix orbit, zoomed-in stations, and continuous swivel.
    """
    t = f / float(total_frames - 1)  # 0.0 to 1.0

    # -------------------------------------------------------------------------
    # Shot 1: Wide Matrix-Style Orbit (0.0s - 4.2s, t: 0.00 -> 0.28)
    # -------------------------------------------------------------------------
    if t < 0.28:
        p = t / 0.28
        s = 0.5 - 0.5 * math.cos(p * math.pi)  # Smooth cosine ease in-out
        cx = 0.0
        cy = 0.0
        cz = 16.0
        max_range = 17.5
        azim = -60.0 + s * 105.0  # -60° -> +45°
        elev = 14.0 + math.sin(p * math.pi) * 14.0  # 14° -> 28° -> 14°

    # -------------------------------------------------------------------------
    # Shot 2: Zoomed-In Rotor & NACA Aerodynamic Blades (4.2s - 8.0s, t: 0.28 -> 0.54)
    # -------------------------------------------------------------------------
    elif t < 0.54:
        p = (t - 0.28) / (0.54 - 0.28)
        s = 0.5 - 0.5 * math.cos(p * math.pi)
        # Glide camera focus up to nacelle/hub center at z = 26.6m
        cx = 0.0 * (1.0 - s) + 0.35 * s
        cy = 0.0
        cz = 16.0 * (1.0 - s) + 26.6 * s
        max_range = 17.5 * (1.0 - s) + 4.2 * s
        azim = 45.0 + s * 85.0  # 45° -> 130°
        elev = 14.0 * (1.0 - s) + 8.0 * s

    # -------------------------------------------------------------------------
    # Shot 3: Zoomed-In Structural Guy Collar & Rigging (8.0s - 11.4s, t: 0.54 -> 0.76)
    # -------------------------------------------------------------------------
    elif t < 0.76:
        p = (t - 0.54) / (0.76 - 0.54)
        s = 0.5 - 0.5 * math.cos(p * math.pi)
        # Pan camera down to guy wire collar at z = 18.6m
        cx = 0.35 * (1.0 - s) + 0.0 * s
        cy = 0.0
        cz = 26.6 * (1.0 - s) + 18.6 * s
        max_range = 4.2 * (1.0 - s) + 3.8 * s
        azim = 130.0 + s * 80.0  # 130° -> 210°
        elev = 8.0 * (1.0 - s) + 26.0 * s  # Higher elevation to look down on clevis lugs

    # -------------------------------------------------------------------------
    # Shot 4: Zoomed-In Gin-Pole Erection Winch & Outriggers (11.4s - 15.0s, t: 0.76 -> 1.00)
    # -------------------------------------------------------------------------
    else:
        p = (t - 0.76) / (1.00 - 0.76)
        s = 0.5 - 0.5 * math.cos(p * math.pi)
        # Pan camera down to container roof level (z = 3.4m)
        cx = 0.0 * (1.0 - s) + 0.60 * s
        cy = 0.0
        cz = 18.6 * (1.0 - s) + 3.4 * s
        max_range = 3.8 * (1.0 - s) + 5.2 * s
        azim = 210.0 + s * 90.0  # 210° -> 300° (Completes 360° circle from -60°)
        elev = 26.0 * (1.0 - s) + 16.0 * s

    return cx, cy, cz, max_range, azim, elev


def render_frame_worker(args):
    """Worker function for parallel frame rendering across CPU processes."""
    frame_idx, mesh_data, limits, azim, elev, frame_path = args
    cx, cy, cz, max_range = limits

    fig = plt.figure(figsize=(10.0, 5.625), facecolor="#0a0c10")
    ax = fig.add_subplot(111, projection="3d", facecolor="#0a0c10")

    for triangles, face, edge in mesh_data:
        coll = Poly3DCollection(triangles, alpha=0.96, facecolors=face, edgecolors=edge, linewidths=0.28)
        ax.add_collection3d(coll)

    ax.set_xlim(cx - max_range, cx + max_range)
    ax.set_ylim(cy - max_range, cy + max_range)
    ax.set_zlim(cz - max_range, cz + max_range)
    ax.axis("off")
    ax.view_init(elev=elev, azim=azim)

    plt.savefig(
        frame_path,
        dpi=160,
        bbox_inches="tight",
        pad_inches=0.0,
        facecolor=fig.get_facecolor(),
        edgecolor="none",
    )
    plt.close(fig)
    return frame_idx


def main():
    parser = argparse.ArgumentParser(description="15-Second Cinematic Camera Renderer for Modular Arctic Wind Turbine v3.1")
    parser.add_argument("--cores", type=int, default=mp.cpu_count(), help="Number of CPU cores to utilize")
    parser.add_argument("--frames", type=int, default=TOTAL_FRAMES, help="Total frames (default 180)")
    parser.add_argument("--fps", type=float, default=FPS, help="Frame rate (default 12.0 fps)")
    args = parser.parse_args()

    total_frames = args.frames
    fps = args.fps
    duration = total_frames / fps
    print(f"\n=======================================================")
    print(f"🎬 Initializing 15-Second Cinematic Renderer: Modular Arctic Wind Turbine v3.1")
    print(f"   Trajectory: Matrix Sweep -> NACA Rotor Zoom -> Guy Rigging Zoom -> Gin-Pole Zoom")
    print(f"   Specs: {total_frames} frames @ {fps:.1f} fps ({duration:.2f}s duration) on {args.cores} CPU cores")
    print(f"=======================================================")

    tt_mod = load_turntable_renderer()
    groups = tt_mod.get_wind_turbine_v3_groups()

    frames_dir = "scratch/frames/wind_v3_cinematic"
    if os.path.exists(frames_dir):
        shutil.rmtree(frames_dir)
    os.makedirs(frames_dir, exist_ok=True)

    # Precompute tessellation meshes (once)
    print("Computing OpenCASCADE B-Rep tessellation for 7 color groups...")
    mesh_data = []
    for g in groups:
        pts_raw, facets = g["shape"].tessellate(g["tol"])
        pts = np.array([[p.x, p.y, p.z] for p in pts_raw])
        triangles = pts[facets]
        mesh_data.append((triangles, g["face"], g["edge"]))

    # Prepare frame tasks
    tasks = []
    for f in range(total_frames):
        cx, cy, cz, max_range, azim, elev = get_camera_params(f, total_frames)
        limits = (cx, cy, cz, max_range)
        frame_path = os.path.join(frames_dir, f"frame_{f:04d}.png")
        tasks.append((f, mesh_data, limits, azim, elev, frame_path))

    print(f"Rendering {total_frames} frames in parallel across {args.cores} workers...")
    pool = mp.Pool(processes=args.cores)
    rendered_count = 0
    for idx in pool.imap_unordered(render_frame_worker, tasks):
        rendered_count += 1
        if rendered_count % 30 == 0 or rendered_count == total_frames:
            print(f"  -> Rendered {rendered_count}/{total_frames} frames ({rendered_count / total_frames * 100:.1f}%)")
    pool.close()
    pool.join()

    out_dir = "cad_and_blender/freecad/wind/renders"
    os.makedirs(out_dir, exist_ok=True)
    mp4_out = os.path.join(out_dir, "modular_wind_turbine_v3_cinematic.mp4")
    gif_out = os.path.join(out_dir, "modular_wind_turbine_v3_cinematic.gif")
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
    print("🎉 15-Second Cinematic Animation Complete!")


if __name__ == "__main__":
    main()
