#!/usr/bin/env python3
"""
surface_manna_machine_v1.py - Parametric FreeCAD/Python Solid Model for 🏺 The New Manna Machine (v1.0)

Lineage & Governing Architecture:
- Governing Issue: #119 (🏺 The New Manna Machine: Automated Earthen Bio-Habitats)
- Parent Umbrella: #118 (Global Food Security & Terrestrial Infrastructure)
- Master Program: #63 (Umbrella Space & Terrestrial Infrastructure Management)
- Solid Kernel: OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module
- Architectural Plan Authority: plans/plan-earthen-bio-habitats.md

Engineered Systems:
1. Outer Monolithic Rammed-Earth Barrier & Lateral Buttresses:
   - 550 mm continuous slip-form rammed earth (Form Earth technology)
   - Heavy thermal ballast (Cv ≈ 1.8-2.0 MJ/m³K) for passive permafrost/equatorial insulation
2. Catenary Adobe Vault & Ridge Spine:
   - Extruded earthen catenary arch profile (Shangrila-VHP #45 RepRap 3D-printing mechanics)
3. Controlled-Environment Polyculture Core:
   - High-bay rover deployment portal (PORTAL_W = 5.2 m, PORTAL_H = 3.2 m)
   - Apex overhead I-beam ceiling gantry rail (CEILING_Z = 5.15 m, L = 18.5 m)
   - Multi-tier vertical aeroponic cultivation columns (potatoes/cassava mist roots, beans, leafy greens)
   - Transpiration dehumidification recovery coils and sub-floor nutrient tanks
   - Strict adherence to plans/SPACE_FLOURISHING_FRAMEWORK.md (zero insect farming)
"""

import sys
import os
import math

# -----------------------------------------------------------------------------
# Module Metadata
# -----------------------------------------------------------------------------
__version__     = "1.0.0"
__target_spec__ = "The New Manna Machine (Automated Earthen Bio-Habitat) FreeCAD Solid Model"
__kernel__      = "OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module"
__issue__       = "#119"

# Ensure FreeCAD library is accessible
for lib_path in ["/usr/lib/freecad/lib", "/usr/lib/freecad-python3/lib"]:
    if os.path.exists(lib_path) and lib_path not in sys.path:
        sys.path.append(lib_path)

import FreeCAD
import Part

# -----------------------------------------------------------------------------
# Parametric Dimensions (Meters)
# -----------------------------------------------------------------------------
HAB_L               = 20.0   # Overall habitat length
HAB_R_INT           = 5.5    # Internal vault radius
RAMMED_EARTH_WALL_T = 0.55   # Monolithic rammed earth thickness (550 mm)
ADOBE_VAULT_T       = 0.35   # 3D-printed adobe vault thickness (350 mm)
TOTAL_WALL_T        = RAMMED_EARTH_WALL_T + ADOBE_VAULT_T

PORTAL_W            = 5.20   # High-bay rover portal width
PORTAL_H            = 3.20   # High-bay rover portal height

CEILING_RAIL_L      = 18.5   # Apex ceiling gantry rail span
CEILING_Z           = 5.15   # Apex ceiling gantry rail height
CEILING_RAIL_W      = 0.60
CEILING_RAIL_H      = 0.25

AERO_RACK_H         = 3.80   # Vertical aeroponic cultivation rack height

# -----------------------------------------------------------------------------
# B-Rep Solid Component Builders
# -----------------------------------------------------------------------------

def create_rammed_earth_buttressed_walls():
    """Generates the Form Earth continuous slip-form rammed earth walls and buttresses."""
    solids = []
    # Lateral battered walls
    for side in [-1, 1]:
        wall_x = side * (HAB_R_INT + RAMMED_EARTH_WALL_T / 2.0)
        wall_box = Part.makeBox(RAMMED_EARTH_WALL_T, HAB_L, HAB_R_INT,
                                FreeCAD.Vector(wall_x - RAMMED_EARTH_WALL_T/2.0, -HAB_L/2.0, 0.0))
        solids.append(wall_box)

        # Lateral stabilizing stepped buttresses (thermal & seismic stabilization)
        for y in [-HAB_L/2.0 + 2.0 + i * 4.0 for i in range(5)]:
            buttress = Part.makeBox(1.20, 0.80, HAB_R_INT * 0.8,
                                    FreeCAD.Vector(side * (HAB_R_INT + RAMMED_EARTH_WALL_T) - (0.0 if side == 1 else 1.20),
                                                   y - 0.40, 0.0))
            solids.append(buttress)

    # Front and rear heavy earthen end-gables
    for end in [-1, 1]:
        gable_y = end * (HAB_L/2.0 - RAMMED_EARTH_WALL_T / 2.0)
        gable = Part.makeBox(HAB_R_INT * 2.0 + TOTAL_WALL_T * 2.0, RAMMED_EARTH_WALL_T, HAB_R_INT,
                             FreeCAD.Vector(-(HAB_R_INT + TOTAL_WALL_T), gable_y - RAMMED_EARTH_WALL_T/2.0, 0.0))
        if end == 1:
            # Cut rover portal
            portal_cutter = Part.makeBox(PORTAL_W, RAMMED_EARTH_WALL_T * 2.0, PORTAL_H,
                                         FreeCAD.Vector(-PORTAL_W/2.0, gable_y - RAMMED_EARTH_WALL_T, 0.0))
            gable = gable.cut(portal_cutter)
        elif end == -1:
            # Cut rear ventilation / dehumidification recovery duct
            vent_cutter = Part.makeCylinder(1.20, RAMMED_EARTH_WALL_T * 2.0,
                                            FreeCAD.Vector(0.0, gable_y - RAMMED_EARTH_WALL_T, 2.5),
                                            FreeCAD.Vector(0, 1, 0))
            gable = gable.cut(vent_cutter)
        solids.append(gable)

    return Part.Compound(solids)


def create_adobe_catenary_vault():
    """Generates the 3D printed adobe catenary vault (Shangrila-VHP #45)."""
    outer_r = HAB_R_INT + ADOBE_VAULT_T
    inner_r = HAB_R_INT

    outer_cyl = Part.makeCylinder(outer_r, HAB_L,
                                  FreeCAD.Vector(0.0, -HAB_L/2.0, 0.0),
                                  FreeCAD.Vector(0, 1, 0))
    inner_cyl = Part.makeCylinder(inner_r, HAB_L + 1.0,
                                  FreeCAD.Vector(0.0, -(HAB_L + 1.0)/2.0, 0.0),
                                  FreeCAD.Vector(0, 1, 0))
    vault_shell = outer_cyl.cut(inner_cyl)

    # Cut off bottom half below ground level (Z < 0)
    ground_cutter = Part.makeBox(outer_r * 4.0, HAB_L + 2.0, outer_r * 2.0,
                                 FreeCAD.Vector(-outer_r * 2.0, -(HAB_L + 2.0)/2.0, -outer_r * 2.0))
    vault_arch = vault_shell.cut(ground_cutter)
    return vault_arch


def create_internal_aeroponic_crops():
    """Generates the multi-tier aeroponic polyculture columns and mist chambers."""
    solids = []
    for side in [-1, 1]:
        for x_offset in [2.2, 3.8]:
            for y in [-6.0 + i * 1.5 for i in range(9)]:
                pos_x = side * x_offset
                # Lower tier tuber mist chamber
                tuber_pot = Part.makeCylinder(0.45, 1.10, FreeCAD.Vector(pos_x, y, 0.0), FreeCAD.Vector(0, 0, 1))
                solids.append(tuber_pot)
                # Upper tier vertical crop foliage column
                foliage_col = Part.makeCylinder(0.35, AERO_RACK_H - 1.10, FreeCAD.Vector(pos_x, y, 1.10), FreeCAD.Vector(0, 0, 1))
                solids.append(foliage_col)
                # Crop foliage trays
                for z in [1.6, 2.3, 3.0, 3.6]:
                    tray = Part.makeCylinder(0.65, 0.15, FreeCAD.Vector(pos_x, y, z), FreeCAD.Vector(0, 0, 1))
                    solids.append(tray)

    return Part.Compound(solids)


def create_ceiling_gantry_rail():
    """Generates the apex ceiling gantry rail and robotic toolhead."""
    solids = []
    # I-beam spine
    rail = Part.makeBox(CEILING_RAIL_W, CEILING_RAIL_L, CEILING_RAIL_H,
                        FreeCAD.Vector(-CEILING_RAIL_W/2.0, -CEILING_RAIL_L/2.0, CEILING_Z))
    solids.append(rail)
    # Carrier hoist & pollination toolhead mast
    carrier = Part.makeBox(CEILING_RAIL_W * 1.3, 1.20, 0.25,
                           FreeCAD.Vector(-CEILING_RAIL_W * 0.65, 0.5, CEILING_Z - 0.25))
    solids.append(carrier)
    mast = Part.makeCylinder(0.08, 0.60, FreeCAD.Vector(0.0, 1.1, CEILING_Z - 0.85), FreeCAD.Vector(0, 0, 1))
    solids.append(mast)
    return Part.Compound(solids)


def create_floor_slab_and_tanks():
    """Generates the sterile hygienic floor slab and sub-floor nutrient tanks."""
    solids = []
    # Foundation slab
    slab = Part.makeBox(HAB_R_INT * 2.0, HAB_L - 1.0, 0.20,
                        FreeCAD.Vector(-HAB_R_INT, -(HAB_L - 1.0)/2.0, -0.20))
    solids.append(slab)
    # Nutrient reservoirs
    for y in [-4.0, 0.0, 4.0]:
        tank = Part.makeBox(2.2, 2.0, 0.60, FreeCAD.Vector(-1.1, y - 1.0, -0.80))
        solids.append(tank)
    return Part.Compound(solids)


def get_manna_machine_groups():
    """Returns color-coded B-Rep solid groups compatible with renderers."""
    return [
        {
            "name": "rammed_earth_buttressed_walls",
            "solid": create_rammed_earth_buttressed_walls(),
            "color": (0.72, 0.53, 0.38),   # In-situ subsoil rammed earth
            "alpha": 0.95
        },
        {
            "name": "adobe_catenary_vault",
            "solid": create_adobe_catenary_vault(),
            "color": (0.80, 0.62, 0.45),   # 3D printed clay adobe
            "alpha": 0.85
        },
        {
            "name": "internal_aeroponic_crops",
            "solid": create_internal_aeroponic_crops(),
            "color": (0.18, 0.68, 0.32),   # Living foliage crops
            "alpha": 1.0
        },
        {
            "name": "ceiling_gantry_rail",
            "solid": create_ceiling_gantry_rail(),
            "color": (0.70, 0.73, 0.78),   # Structural stainless steel
            "alpha": 1.0
        },
        {
            "name": "floor_slab_and_tanks",
            "solid": create_floor_slab_and_tanks(),
            "color": (0.25, 0.45, 0.65),   # Composite floor & nutrient plumbing
            "alpha": 1.0
        }
    ]


if __name__ == "__main__":
    print(f"Building FreeCAD B-Rep model for {__target_spec__}...")
    doc = FreeCAD.newDocument("MannaMachine")
    groups = get_manna_machine_groups()
    for g in groups:
        obj = doc.addObject("Part::Feature", g["name"])
        obj.Shape = g["solid"]
    out_step = "cad_and_blender/freecad/step_exports/amu_manna_machine_v1.step"
    os.makedirs(os.path.dirname(out_step), exist_ok=True)
    comp = Part.Compound([g["solid"] for g in groups])
    comp.exportStep(out_step)
    print(f"✅ Exported full engineering B-Rep solid model to STEP: {out_step}")
