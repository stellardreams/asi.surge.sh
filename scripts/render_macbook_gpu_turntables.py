#!/usr/bin/env python3
"""
render_macbook_gpu_turntables.py - Staged Multi-Invention Turntable Renderer with Cooldown Cycles for MacBook & Linux Hosts

Lineage:
- Governing Issue: #108 (Benchmark FreeCAD render pipeline on Linux MacBook)
- Parent Issue: #101 (Hardware Invention & Model Registry & FreeCAD Transition)
- Purpose: Executes full 360° turntable animations across 8 major hardware inventions
  with configurable inter-model sleep/cooldown cycles (default 4.0s) to prevent thermal
  throttling and memory pressure on compact laptop hardware.

Usage:
    python3 scripts/render_macbook_gpu_turntables.py --cores 2 --cooldown 4.0
    python3 scripts/render_macbook_gpu_turntables.py --cores 2 --frames 12 --cooldown 2.0  # Quick benchmark smoke test
    python3 scripts/render_macbook_gpu_turntables.py --model strider_m_v2 --cores 2
"""

import sys
import os
import time
import argparse
import subprocess

# Ensure FreeCAD library is accessible
for lib_path in ["/usr/lib/freecad/lib", "/usr/lib/freecad-python3/lib"]:
    if os.path.exists(lib_path) and lib_path not in sys.path:
        sys.path.append(lib_path)

# 8 Major Hardware Inventions from Model Registry
INVENTIONS = [
    {"name": "strider_m_v2", "title": "STRIDER-M v2.1 Surface Transporter"},
    {"name": "strider_m_v1", "title": "STRIDER-M v1.0 Transporter Baseline"},
    {"name": "cora_m_arm_v1", "title": "CORA-M 7-DoF Manipulator Arm"},
    {"name": "modular_wind_turbine_v3", "title": "Modular Arctic Wind Turbine v3.0 / v3.1"},
    {"name": "modular_wind_turbine_v2", "title": "Modular Arctic Wind Turbine v2.0"},
    {"name": "surface_habitat_v1", "title": "AMU-Surface Base Habitat (v1.1)"},
    {"name": "amu_heritage_orbital_v1", "title": "AMU Heritage Orbital Spacecraft"},
    {"name": "zeroclaw_truss_node_v1", "title": "ZeroClaw Octahedral Space Truss Node"},
]


def main():
    parser = argparse.ArgumentParser(description="MacBook / Linux Host Multi-Invention Staged Turntable Renderer")
    parser.add_argument("--cores", type=int, default=2, help="Number of CPU cores to utilize (default: 2)")
    parser.add_argument("--frames", type=int, default=48, help="Number of frames per 360° rotation (default: 48)")
    parser.add_argument("--cooldown", type=float, default=4.0, help="Thermal cooldown sleep cycle between renders in seconds (default: 4.0s)")
    parser.add_argument("--model", type=str, default=None, help="Render single specific model by name")
    parser.add_argument("--slower", action="store_true", default=True, help="Use 37% slower cinematic angular velocity")
    args = parser.parse_args()

    targets = INVENTIONS
    if args.model:
        targets = [inv for inv in INVENTIONS if inv["name"] == args.model]
        if not targets:
            print(f"❌ Unknown model '{args.model}'. Available: {[i['name'] for i in INVENTIONS]}")
            sys.exit(1)

    print(f"\n{'='*75}")
    print(f"🚀 Initializing Staged Multi-Invention Turntable Renderer (MacBook / Linux Host)")
    print(f"   Inventions Queue: {len(targets)} models")
    print(f"   Cores: {args.cores} | Frames: {args.frames} | Cooldown Sleep Cycle: {args.cooldown:.1f}s")
    print(f"   Target Branch: main-dev (Commit, verify, and push to origin)")
    print(f"{'='*75}\n")

    benchmark_log = []
    overall_start = time.perf_counter()

    for idx, inv in enumerate(targets, start=1):
        name = inv["name"]
        title = inv["title"]
        print(f"\n[{idx}/{len(targets)}] 🎬 Starting Render: {title} ({name})...")
        t0 = time.perf_counter()

        cmd = [
            sys.executable,
            "scripts/render_freecad_turntables.py",
            "--model", name,
            "--cores", str(args.cores),
            "--frames", str(args.frames),
        ]
        if args.slower:
            cmd.append("--slower")

        res = subprocess.run(cmd)
        elapsed = time.perf_counter() - t0

        if res.returncode == 0:
            print(f"   ✅ Finished {name} in {elapsed:.2f}s ({elapsed/60.0:.2f}m)")
            benchmark_log.append({"name": name, "title": title, "status": "PASS", "duration": elapsed})
        else:
            print(f"   ❌ FAILED {name} with code {res.returncode}")
            benchmark_log.append({"name": name, "title": title, "status": "FAIL", "duration": elapsed})

        # Cooldown cycle between renders to protect CPU thermals on compact hosts
        if idx < len(targets) and args.cooldown > 0:
            print(f"   ❄️ Entering {args.cooldown:.1f}s thermal cooldown sleep cycle...")
            time.sleep(args.cooldown)

    total_time = time.perf_counter() - overall_start
    print(f"\n{'='*75}")
    print(f"🎉 Batch Render Complete across {len(targets)} Inventions!")
    print(f"   Total Elapsed Time: {total_time:.2f}s ({total_time/60.0:.2f}m)")
    print(f"{'='*75}")
    print(f"\n📋 Benchmark Summary Ledger:")
    for b in benchmark_log:
        status_icon = "✅" if b["status"] == "PASS" else "❌"
        print(f"   • {status_icon} {b['title']}: {b['duration']:.2f}s")

    print(f"\n📌 Next Steps for Agent / Maintainer:")
    print(f"   1. Stage and commit rendered assets on main-dev: git add cad_and_blender/freecad/*/renders/ && git commit -m 'render: batch update turntables (#108, #101)'")
    print(f"   2. Push to remote: git push origin main-dev")
    print(f"   3. Post structured benchmark summary comment to Issue #108 signed with local git skills")


if __name__ == "__main__":
    main()
