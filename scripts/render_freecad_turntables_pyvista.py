#!/usr/bin/env python3
"""
render_freecad_turntables_pyvista.py - Hardware-Accelerated Offscreen OpenGL/EGL Cinematic Matrix Renderer via PyVista/VTK

Lineage:
- Governing Issue: #108 (Benchmark FreeCAD render pipeline on Linux MacBook & GPU transition)
- Parent Issue: #101 (Hardware Invention & Model Registry & FreeCAD Transition)
- Architecture:
  1. FreeCAD OpenCASCADE B-Rep solid model extraction & tessellation (identical groups & colors).
  2. PyVista / VTK hardware-accelerated offscreen OpenGL/EGL rasterizer (true 3D depth-buffering).
  3. Dynamic 6.5-second (78 frames @ 12.0 fps) Matrix-Style Cinematic Camera Orbit:
     - 360° Orbital Pan (azimuth)
     - Sinusoidal Elevation Pitch / Tilt Arc (dipping from high angle down to low dramatic angle and back)
     - Dynamic Radial Dolly / Zoom (smoothly pushing in to highlight mechanical details and pulling out)
  4. Explicit plotter.render() + SHA-256 frame uniqueness assertion (prevents cached static buffer frames).
  5. Non-destructive versioned file naming (*_cinematic_v2.mp4 / .gif) preserving v1 baselines in REGISTRY.md.
  6. Thermal safety cooldown sleep cycle between models (default 3.0s).

Usage:
    python3 scripts/render_freecad_turntables_pyvista.py                       # Render all 9 cinematic targets (v2)
    python3 scripts/render_freecad_turntables_pyvista.py --model strider_m_v2  # Render single target
    python3 scripts/render_freecad_turntables_pyvista.py --frames 78 --fps 12  # 6.5s @ 12 fps (default)
"""

import sys
import os
import math
import shutil
import hashlib
import argparse
import subprocess
import time
import numpy as np

# Ensure FreeCAD library is accessible
for lib_path in ["/usr/lib/freecad/lib", "/usr/lib/freecad-python3/lib"]:
    if os.path.exists(lib_path) and lib_path not in sys.path:
        sys.path.append(lib_path)

import FreeCAD
import Part
import importlib.util

# Check PyVista availability early
try:
    import pyvista as pv
    pv.OFF_SCREEN = True
except ImportError:
    print("❌ Error: 'pyvista' package is required for hardware-accelerated rendering.")
    print("   Install via: pip install pyvista")
    sys.exit(1)


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def get_base_catalog():
    mod = load_module("render_freecad_turntables", "scripts/render_freecad_turntables.py")
    return mod.MODELS_CATALOG


def get_strider_cora_wind_hoist_groups():
    """
    9th Special Target: Multi-System Cooperative Field Hoisting Scene
    (STRIDER-M v2.1 + CORA-M v1.1 + Modular Wind Turbine v3.1 at mid-erection tilt).
    """
    wind_mod = load_module("wind_v3", "cad_and_blender/freecad/wind/modular_wind_turbine_v3.py")
    strider_mod = load_module("strider_v2", "cad_and_blender/freecad/mobility/strider_m_v2.py")
    cora_mod = load_module("cora_v1", "cad_and_blender/freecad/robotics/cora_m_arm_v1.py")

    groups = []

    # 1. Turbine Container Sled & Outriggers at origin (0, 0, 0)
    cont_box = Part.makeBox(wind_mod.CONT_L, wind_mod.CONT_W, wind_mod.CONT_H,
                            FreeCAD.Vector(-wind_mod.CONT_L / 2.0, -wind_mod.CONT_W / 2.0, 0.0))
    groups.append({"shape": cont_box, "face": "#1976d2", "edge": "#0d47a1", "tol": 0.35})

    # 2. Gin-Pole A-Frame & Winch on Container Roof
    apex_x, apex_z = -0.12, wind_mod.CONT_H + 5.0
    leg_l = Part.makeCylinder(0.06, 5.15, FreeCAD.Vector(apex_x, -1.0, wind_mod.CONT_H), FreeCAD.Vector(0, 1.0, 5.0))
    leg_r = Part.makeCylinder(0.06, 5.15, FreeCAD.Vector(apex_x, 1.0, wind_mod.CONT_H), FreeCAD.Vector(0, -1.0, 5.0))
    winch_drum = Part.makeCylinder(0.28, 0.70, FreeCAD.Vector(2.2, -0.35, wind_mod.CONT_H + 0.32), FreeCAD.Vector(0, 1, 0))
    groups.append({"shape": leg_l.fuse(leg_r).fuse(winch_drum), "face": "#ffb300", "edge": "#ff8f00", "tol": 0.30})

    # 3. Wind Turbine Mast & Rotor tilted at dramatic 55° mid-hoist angle
    tilt_deg = 55.0
    tilt_rad = math.radians(tilt_deg)
    trunnion_vec = FreeCAD.Vector(-0.12, 0.0, wind_mod.CONT_H)
    rot_tilt = FreeCAD.Rotation(FreeCAD.Vector(0, 1, 0), 90.0 - tilt_deg)

    mast_cyl = Part.makeCylinder(wind_mod.MAST_D / 2.0, wind_mod.MAST_H, FreeCAD.Vector(0, 0, 0), FreeCAD.Vector(0, 0, 1))
    mast_cyl.Placement = FreeCAD.Placement(trunnion_vec, rot_tilt)
    groups.append({"shape": mast_cyl, "face": "#cfd8dc", "edge": "#78909c", "tol": 0.35})

    # Tophead Nacelle & 3x Blades at mast top
    top_x = -0.12 - wind_mod.MAST_H * math.cos(tilt_rad)
    top_z = wind_mod.CONT_H + wind_mod.MAST_H * math.sin(tilt_rad)
    top_vec = FreeCAD.Vector(top_x, 0.0, top_z)

    nac_body = Part.makeCylinder(wind_mod.NACELLE_D / 2.0, wind_mod.NACELLE_L,
                                 FreeCAD.Vector(-wind_mod.NACELLE_L * 0.5, 0, 0), FreeCAD.Vector(1, 0, 0))
    nac_body.Placement = FreeCAD.Placement(top_vec, rot_tilt)
    groups.append({"shape": nac_body, "face": "#ffb300", "edge": "#e65100", "tol": 0.30})

    base_blade = wind_mod.create_modular_aerodynamic_blade()
    blades = []
    for i in range(3):
        b_copy = base_blade.copy()
        r_spin = FreeCAD.Rotation(FreeCAD.Vector(1, 0, 0), i * 120.0)
        b_copy.Placement = FreeCAD.Placement(top_vec, rot_tilt.multiply(r_spin))
        blades.append(b_copy)
    groups.append({"shape": blades[0].fuse(blades[1]).fuse(blades[2]), "face": "#eceff1", "edge": "#90a4ae", "tol": 0.35})

    # 4. STRIDER-M v2.1 Staged at X = +8.50 m, Z = +0.825 m
    strider_offset = FreeCAD.Vector(8.50, 0.0, 0.825)
    track_y = strider_mod.ROVER_W / 2.0 - strider_mod.TRACK_W / 2.0
    t_left = strider_mod.create_crawler_track_v2(center_y=track_y)
    t_right = strider_mod.create_crawler_track_v2(center_y=-track_y)
    tracks = t_left.fuse(t_right)
    tracks.translate(strider_offset)
    groups.append({"shape": tracks, "face": "#263238", "edge": "#11171a", "tol": 0.35})

    deck_z = strider_mod.CHASSIS_H * 0.5
    chassis_frame = Part.makeBox(strider_mod.DECK_L * 1.15, 2.3, strider_mod.CHASSIS_H * 0.72,
                                 FreeCAD.Vector(-strider_mod.DECK_L * 0.575, -1.15, -0.22))
    deck_plate = Part.makeBox(strider_mod.DECK_L, strider_mod.DECK_W, strider_mod.DECK_H,
                              FreeCAD.Vector(-strider_mod.DECK_L / 2.0, -strider_mod.DECK_W / 2.0, deck_z))
    cage = strider_mod.create_front_crash_cage()
    cradle = strider_mod.create_cargo_retention_cradle()
    dock = strider_mod.create_turret_dock_v2()
    s_body = chassis_frame.fuse(deck_plate).fuse(cage).fuse(cradle).fuse(dock)
    s_body.translate(strider_offset)
    groups.append({"shape": s_body, "face": "#37474f", "edge": "#ffab00", "tol": 0.35})

    outs = []
    for sx in [-1.0, 1.0]:
        for sy in [-1.0, 1.0]:
            o = strider_mod.create_outrigger(sign_x=sx, sign_y=sy)
            o.translate(strider_offset)
            outs.append(o)
    outs_solid = outs[0].fuse(outs[1]).fuse(outs[2]).fuse(outs[3])
    groups.append({"shape": outs_solid, "face": "#ffab00", "edge": "#ff6f00", "tol": 0.30})

    # 5. CORA-M 7-DoF Arm Mounted on STRIDER Turret Dock (8.50, 0.0, 2.03 m)
    cora_solid = cora_mod.build_cora_m_arm()
    cora_solid.Placement = FreeCAD.Placement(FreeCAD.Vector(8.50, 0.0, 2.03),
                                             FreeCAD.Rotation(FreeCAD.Vector(0, 0, 1), 180.0))
    groups.append({"shape": cora_solid, "face": "#00e5ff", "edge": "#00838f", "tol": 0.30})

    return groups


def get_cinematic_catalog():
    """
    Returns all 9 cinematic targets (8 individual inventions + 1 cooperative field hoist scene)
    with custom camera choreography parameters.
    """
    base = get_base_catalog()
    catalog = []
    for m in base:
        item = dict(m)
        if m["name"] == "modular_wind_turbine_v3":
            # Dramatic upward tower sweep & rotor close-up
            item["elev_base"] = 18.0
            item["elev_amp"] = 16.0
            item["dolly_amp"] = 0.22
        elif m["name"] in ("strider_m_v2", "strider_m_v1"):
            # Low permafrost ground sweep to high deck inspection
            item["elev_base"] = 22.0
            item["elev_amp"] = 15.0
            item["dolly_amp"] = 0.18
        else:
            item["elev_base"] = float(m.get("elev", 22.0))
            item["elev_amp"] = 14.0
            item["dolly_amp"] = 0.16
        catalog.append(item)

    # Append 9th Special Cooperative Scene
    catalog.append({
        "name": "strider_cora_wind_hoist",
        "title": "STRIDER-M + CORA-M + Wind v3.1 Cooperative Hoist (Matrix Orbit)",
        "getter": get_strider_cora_wind_hoist_groups,
        "out_dir": "cad_and_blender/freecad/wind/renders",
        "elev": 20,
        "elev_base": 20.0,
        "elev_amp": 15.0,
        "dolly_amp": 0.20,
    })
    return catalog


DEFAULT_FRAMES = 78   # 6.50 seconds at 12.0 fps
DEFAULT_FPS = 12.0


def build_pyvista_multiblock(groups):
    """
    Converts FreeCAD Part B-Rep groups into PyVista PolyData meshes.
    Computes smooth vertex normals for realistic OpenGL specular shading.
    """
    actors_data = []
    all_pts = []

    for g in groups:
        pts_raw, facets = g["shape"].tessellate(g["tol"])
        pts = np.array([[p.x, p.y, p.z] for p in pts_raw], dtype=np.float32)
        if len(pts) == 0 or len(facets) == 0:
            continue
        all_pts.append(pts)

        num_triangles = len(facets)
        faces_vtk = np.empty((num_triangles, 4), dtype=np.int64)
        faces_vtk[:, 0] = 3
        faces_vtk[:, 1:4] = facets
        faces_flat = faces_vtk.ravel()

        mesh = pv.PolyData(pts, faces_flat)
        mesh = mesh.compute_normals(cell_normals=False, point_normals=True, split_vertices=True)
        actors_data.append({
            "mesh": mesh,
            "face_color": g["face"],
            "edge_color": g["edge"]
        })

    if not all_pts:
        return None, (0.0, 0.0, 0.0, 1.0)

    all_pts_arr = np.vstack(all_pts)
    min_b = all_pts_arr.min(axis=0)
    max_b = all_pts_arr.max(axis=0)
    center = (min_b + max_b) / 2.0
    max_range = float(np.max(max_b - min_b)) * 0.58
    bounds = (float(center[0]), float(center[1]), float(center[2]), max_range)

    return actors_data, bounds


def render_model_cinematic(m, total_frames=DEFAULT_FRAMES, target_fps=DEFAULT_FPS, version_tag="cinematic_v2", image_size=(1600, 900)):
    """
    Renders a 6–7s Matrix-style dynamic 3D camera orbit (360° pan + pitch wave + radial dolly)
    using offscreen PyVista OpenGL and verifies frame-to-frame motion via SHA-256 digests.
    """
    duration_sec = total_frames / target_fps
    print(f"\n{'='*75}")
    print(f"🎬 [PyVista Matrix Orbit] {m['title']} ({m['name']})")
    print(f"   Specs: {total_frames} frames @ {target_fps:.1f} fps ({duration_sec:.2f}s duration) | Tag: {version_tag}")
    print(f"{'='*75}")

    t0_prep = time.perf_counter()
    groups = m["getter"]()

    frames_dir = os.path.join("scratch/frames_pv_cinematic", f"{m['name']}_{version_tag}")
    if os.path.exists(frames_dir):
        shutil.rmtree(frames_dir)
    os.makedirs(frames_dir, exist_ok=True)

    actors_data, bounds = build_pyvista_multiblock(groups)
    if actors_data is None:
        print(f"❌ Failed to extract geometry for {m['name']}")
        return False, 0.0, 0

    cx, cy, cz, max_range = bounds
    prep_time = time.perf_counter() - t0_prep
    print(f"   • Geometry Tessellation & Normals Build: {prep_time:.2f}s")

    plotter = pv.Plotter(off_screen=True, window_size=image_size)
    plotter.set_background("#0a0c10")

    for item in actors_data:
        plotter.add_mesh(
            item["mesh"],
            color=item["face_color"],
            show_edges=True,
            edge_color=item["edge_color"],
            line_width=0.5,
            smooth_shading=True,
            specular=0.35,
            specular_power=20
        )

    plotter.enable_eye_dome_lighting()

    base_dist = max_range * 3.25
    elev_base = m.get("elev_base", float(m.get("elev", 22.0)))
    elev_amp = m.get("elev_amp", 14.0)
    dolly_amp = m.get("dolly_amp", 0.16)

    t0_render = time.perf_counter()
    print(f"   • Rendering {total_frames} dynamic camera frames via offscreen OpenGL...")

    frame_hashes = set()

    for f in range(total_frames):
        progress = f / float(total_frames)
        theta = 2.0 * math.pi * progress - math.radians(60.0)

        # 1. Dynamic Pitch / Tilt Wave: smooth sinusoidal elevation sweep
        elev_deg = elev_base + elev_amp * math.sin(2.0 * math.pi * progress)
        elev_rad = math.radians(max(4.0, min(65.0, elev_deg)))

        # 2. Dynamic Radial Dolly / Zoom: push in and pull out smoothly
        dist = base_dist * (1.0 - dolly_amp * math.sin(2.0 * math.pi * progress))

        # 3. Subtle focal vertical tracking for tall structures
        focal_z_shift = max_range * 0.10 * math.sin(2.0 * math.pi * progress)
        fx, fy, fz = cx, cy, cz + focal_z_shift

        cam_x = fx + dist * math.cos(elev_rad) * math.sin(theta)
        cam_y = fy - dist * math.cos(elev_rad) * math.cos(theta)
        cam_z = fz + dist * math.sin(elev_rad)

        # Explicitly update PyVista VTK camera properties and force OpenGL render
        plotter.camera.position = (cam_x, cam_y, cam_z)
        plotter.camera.focal_point = (fx, fy, fz)
        plotter.camera.up = (0.0, 0.0, 1.0)
        plotter.reset_camera_clipping_range()
        plotter.render()

        frame_path = os.path.join(frames_dir, f"frame_{f:04d}.png")
        plotter.screenshot(frame_path)

        with open(frame_path, "rb") as fp:
            frame_hashes.add(hashlib.sha256(fp.read()).hexdigest())

    plotter.close()
    render_time = time.perf_counter() - t0_render
    fps_achieved = total_frames / render_time if render_time > 0 else 0
    unique_count = len(frame_hashes)
    print(f"   • Frame Rasterization Complete: {render_time:.2f}s ({fps_achieved:.1f} fps)")
    print(f"   • Motion Verification Gate: {unique_count}/{total_frames} unique frame SHA-256 hashes")

    if unique_count < max(2, total_frames // 2):
        print(f"   ⚠️ WARNING: Low unique frame count ({unique_count}/{total_frames})! Check OpenGL context.")

    # Non-destructive versioned output filenames (preserves *_turntable.mp4 / .gif baselines)
    os.makedirs(m["out_dir"], exist_ok=True)
    base_filename = f"{m['name']}_{version_tag}"
    mp4_out = os.path.join(m["out_dir"], f"{base_filename}.mp4")
    gif_out = os.path.join(m["out_dir"], f"{base_filename}.gif")
    frame_pattern = os.path.join(frames_dir, "frame_%04d.png")

    cmd_mp4 = [
        "ffmpeg", "-y", "-framerate", f"{target_fps:.2f}", "-i", frame_pattern,
        "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "16",
        "-vf", "scale=trunc(iw/2)*2:trunc(ih/2)*2",
        mp4_out,
    ]
    subprocess.run(cmd_mp4, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    cmd_gif = [
        "ffmpeg", "-y", "-framerate", f"{target_fps:.2f}", "-i", frame_pattern,
        "-vf", "scale=768:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse",
        gif_out,
    ]
    subprocess.run(cmd_gif, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    total_model_time = time.perf_counter() - t0_prep
    print(f"   ✅ Generated MP4: {mp4_out} ({os.path.getsize(mp4_out):,} bytes, {duration_sec:.2f}s)")
    print(f"   ✅ Generated GIF: {gif_out} ({os.path.getsize(gif_out):,} bytes, {duration_sec:.2f}s)")
    print(f"   ⚡ Model Total Elapsed: {total_model_time:.2f}s ({total_model_time/60.0:.2f}m)")

    return True, total_model_time, unique_count


def main():
    parser = argparse.ArgumentParser(description="PyVista / VTK Hardware-Accelerated 6-7s Matrix Cinematic Renderer")
    parser.add_argument("--model", type=str, default=None, help="Specific model name to render (e.g. strider_m_v2)")
    parser.add_argument("--frames", type=int, default=DEFAULT_FRAMES, help=f"Total frames per animation (default: {DEFAULT_FRAMES} for 6.5s)")
    parser.add_argument("--fps", type=float, default=DEFAULT_FPS, help=f"Playback frame rate (default: {DEFAULT_FPS} fps)")
    parser.add_argument("--version-tag", type=str, default="cinematic_v2", help="Version suffix to avoid overwriting baselines (default: cinematic_v2)")
    parser.add_argument("--cooldown", type=float, default=3.0, help="Thermal cooldown sleep in seconds between models (default: 3.0s)")
    args = parser.parse_args()

    catalog = get_cinematic_catalog()
    targets = catalog
    if args.model:
        targets = [m for m in catalog if m["name"] == args.model]
        if not targets:
            print(f"❌ Unknown model '{args.model}'. Available: {[m['name'] for m in catalog]}")
            sys.exit(1)

    duration_target = args.frames / args.fps
    print(f"\n{'='*75}")
    print(f"🚀 Initializing PyVista / OpenGL Matrix Cinematic Renderer")
    print(f"   PyVista Version: {pv.__version__}")
    print(f"   Targets Queue: {len(targets)} animations | {args.frames} frames @ {args.fps:.1f} fps ({duration_target:.2f}s each)")
    print(f"   Version Tag: _{args.version_tag} (Non-destructive; preserves v1 turntables)")
    print(f"   Thermal Cooldown: {args.cooldown:.1f}s between models")
    print(f"{'='*75}")

    summary = []
    overall_start = time.perf_counter()

    for idx, m in enumerate(targets, start=1):
        print(f"\n[{idx}/{len(targets)}] Starting Target: {m['title']} ({m['name']})...")
        success, duration, unique_frames = render_model_cinematic(
            m,
            total_frames=args.frames,
            target_fps=args.fps,
            version_tag=args.version_tag
        )
        status = "PASS" if (success and unique_frames > args.frames // 2) else "WARN"
        summary.append({
            "name": m["name"],
            "title": m["title"],
            "status": status,
            "duration": duration,
            "unique_frames": unique_frames
        })

        if idx < len(targets) and args.cooldown > 0:
            print(f"   ❄️ Thermal cooldown pause ({args.cooldown:.1f}s)...")
            time.sleep(args.cooldown)

    grand_total = time.perf_counter() - overall_start
    print(f"\n{'='*75}")
    print(f"🎉 All {len(targets)} PyVista Matrix Cinematic Renders Completed in {grand_total:.2f}s ({grand_total/60.0:.2f}m)!")
    print(f"{'='*75}")
    print(f"\n📋 Performance & Motion Verification Ledger:")
    for item in summary:
        icon = "✅" if item["status"] == "PASS" else "⚠️"
        print(f"   • {icon} {item['title']} ({item['name']}_{args.version_tag}): {item['duration']:.2f}s | {item['unique_frames']}/{args.frames} unique frames")


if __name__ == "__main__":
    main()
