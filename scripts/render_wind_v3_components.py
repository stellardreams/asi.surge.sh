#!/usr/bin/env python3
"""
render_wind_v3_components.py - High-Resolution Isometric Render Generator for FreeCAD Wind Components

Renders 6 subsystem components:
1. Foundation Sled & Deployable Outriggers
2. Mast & Guy-Wire Erection Rigging
3. Direct-Drive Arctic Nacelle & Powertrain
4. 12m NACA 4415/4418 Aerodynamic Blade & Sleeve Joints
5. Weatherproof Arctic Microgrid Power Bay
6. 20 ft ISO Container Logistics & Stowage Racks
"""

import sys
import os
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection

sys.path.append(os.getcwd())
for lib_path in ["/usr/lib/freecad/lib", "/usr/lib/freecad-python3/lib"]:
    if os.path.exists(lib_path) and lib_path not in sys.path:
        sys.path.append(lib_path)

import FreeCAD
import Part

from cad_and_blender.freecad.wind.components.wind_v3_foundation import build_foundation_solid
from cad_and_blender.freecad.wind.components.wind_v3_mast_erection import build_mast_erection_solid
from cad_and_blender.freecad.wind.components.wind_v3_nacelle import build_nacelle_solid
from cad_and_blender.freecad.wind.components.wind_v3_blade_joint import build_blade_joint_solid
from cad_and_blender.freecad.wind.components.wind_v3_microgrid_cabinet import build_microgrid_cabinet_solid
from cad_and_blender.freecad.wind.components.wind_v3_container_stowage import build_container_stowage_solid

COMPONENTS = [
    {
        "name": "wind_v3_foundation",
        "title": "Foundation Sled & Deployable Outriggers (v3.1)",
        "builder": build_foundation_solid,
        "face": "#e06c28",
        "edge": "#9e4410",
        "tol": 0.25,
        "elev": 22,
        "azim": -55,
    },
    {
        "name": "wind_v3_mast_erection",
        "title": "Sectional Mast & Guy-Wire Rigging (v3.1)",
        "builder": build_mast_erection_solid,
        "face": "#9daab8",
        "edge": "#4d5866",
        "tol": 0.25,
        "elev": 18,
        "azim": -60,
    },
    {
        "name": "wind_v3_nacelle",
        "title": "Direct-Drive Arctic Nacelle & Hub (v3.1)",
        "builder": build_nacelle_solid,
        "face": "#1c5cb8",
        "edge": "#0e346d",
        "tol": 0.20,
        "elev": 20,
        "azim": -45,
    },
    {
        "name": "wind_v3_blade_joint",
        "title": "NACA 4415/4418 Aerodynamic Blade & Sleeve Joints (v3.1)",
        "builder": build_blade_joint_solid,
        "face": "#dce2ec",
        "edge": "#7d8b9e",
        "tol": 0.25,
        "elev": 24,
        "azim": -70,
    },
    {
        "name": "wind_v3_microgrid_cabinet",
        "title": "Weatherproof Arctic Microgrid Power Bay (v3.1)",
        "builder": build_microgrid_cabinet_solid,
        "face": "#d49b28",
        "edge": "#7a550e",
        "tol": 0.18,
        "elev": 22,
        "azim": -45,
    },
    {
        "name": "wind_v3_container_stowage",
        "title": "20 ft ISO Container Logistics & Stowage (v3.1)",
        "builder": build_container_stowage_solid,
        "face": "#3b4252",
        "edge": "#252a34",
        "tol": 0.25,
        "elev": 25,
        "azim": -50,
    },
]


def render_component(c, out_dir):
    print(f"Rendering {c['title']}...")
    solid = c["builder"]()
    pts_raw, facets = solid.tessellate(c["tol"])
    pts = np.array([[p.x, p.y, p.z] for p in pts_raw])
    triangles = pts[facets]

    min_x, max_x = pts[:, 0].min(), pts[:, 0].max()
    min_y, max_y = pts[:, 1].min(), pts[:, 1].max()
    min_z, max_z = pts[:, 2].min(), pts[:, 2].max()
    cx = (min_x + max_x) / 2.0
    cy = (min_y + max_y) / 2.0
    cz = (min_z + max_z) / 2.0
    max_range = max(max_x - min_x, max_y - min_y, max_z - min_z) * 0.58

    fig = plt.figure(figsize=(10.0, 5.625), facecolor="#0a0c10")
    ax = fig.add_subplot(111, projection="3d", facecolor="#0a0c10")

    coll = Poly3DCollection(triangles, alpha=0.96, facecolors=c["face"], edgecolors=c["edge"], linewidths=0.28)
    ax.add_collection3d(coll)

    ax.set_xlim(cx - max_range, cx + max_range)
    ax.set_ylim(cy - max_range, cy + max_range)
    ax.set_zlim(cz - max_range, cz + max_range)
    ax.axis("off")
    ax.view_init(elev=c["elev"], azim=c["azim"])

    out_png = os.path.join(out_dir, f"{c['name']}.png")
    plt.savefig(
        out_png,
        dpi=160,
        bbox_inches="tight",
        pad_inches=0.0,
        facecolor=fig.get_facecolor(),
        edgecolor="none",
    )
    plt.close(fig)
    print(f"✅ Generated render: {out_png} ({os.path.getsize(out_png):,} bytes)")


def main():
    out_dir = "cad_and_blender/freecad/wind/renders"
    os.makedirs(out_dir, exist_ok=True)
    for c in COMPONENTS:
        render_component(c, out_dir)
    print("\n🎉 All 6 component renders completed successfully!")


if __name__ == "__main__":
    main()
