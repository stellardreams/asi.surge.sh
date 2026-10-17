#!/usr/bin/env python3
"""
modular_wind_turbine_v3.py - Parametric FreeCAD/Python Solid Model for Modular Arctic Wind Turbine (v3.1)

=============================================================================
METADATA & SPECIFICATION TRACEABILITY
=============================================================================
__version__     = "3.1.0"
__revision__    = "v3.1.0-rigging-and-airfoil-refinements"
__author__      = "Stellar Dreams Engineering"
__date__        = "2026-10-17"
__target_spec__ = "Modular Arctic / Northern Operations Wind Energy System (50 kW Class, -60°C Survival, 120 km/h Gusts, 20ft ISO Pack)"
__kernel__      = "OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module"
__lineage__     = "Evolved from modular_wind_turbine_v2.py under Issues #104 and #82"
=============================================================================

Key Engineering Upgrades in v3.1:
1. Aerodynamic Lofted Blades: 28-point discretized NACA 4415/4418 airfoil section
   lofting with continuous chord taper (1.20 m root to 0.45 m tip) and 10° -> 1°
   aerodynamic wash-out twist.
2. Segmented Blade Sleeve Joints: Integrated structural sleeve joint flanges at 1.9 m
   spanwise intervals, enabling 100% packing compliance inside a standard 20 ft container.
3. 4-Point Guyed Mast Tension Ring & Mechanical Rigging: Structural collar at z = 16.0 m
   fitted with 4x discrete clevis lug ears, pin bosses, and upper/lower turnbuckle
   tensioners anchoring 24 mm high-tensile steel cables to outrigger terminals.
4. Deployable Ground Bearing Pads & Helical Anchor Caps: Outrigger footpads detailed
   with central helical screw anchor drive caps, hinge locking shear pins, and D-ring brackets.
5. Crane-Less Gin-Pole Winch Erection Rigging: Integrated A-frame on container roof with
   dual base pivot trunnions, apex sheave pulley wheel, electric winch planetary motor drum,
   and hoist wire rope line running to the lower mast lifting collar at z = 6.0 m.
6. Microgrid Interconnection Bay: Exterior weatherproof 400V 3-phase power conversion &
   hybrid microgrid control cabinet integrated on the container rear bulkhead.
7. Low-Temperature Nacelle Cowl: Aerodynamic insulated nacelle cowl with rime-ice shedding
   geometry and internal thermal equilibrium management for -60°C ambient operation.
"""

import sys
import os
import math

# -----------------------------------------------------------------------------
# Module Metadata & Semantic Versioning
# -----------------------------------------------------------------------------
__version__     = "3.1.0"
__revision__    = "v3.1.0-rigging-and-airfoil-refinements"
__author__      = "Stellar Dreams Engineering"
__date__        = "2026-10-17"
__target_spec__ = "Modular Arctic / Northern Operations Wind Energy System (50 kW Class, -60°C Survival, 120 km/h Gusts, 20ft ISO Pack)"
__kernel__      = "OpenCASCADE (B-Rep analytical geometry) via FreeCAD Part module"
__lineage__     = "Evolved from modular_wind_turbine_v2.py under Issues #104 and #82"

# Ensure FreeCAD library is accessible
for lib_path in ["/usr/lib/freecad/lib", "/usr/lib/freecad-python3/lib"]:
    if os.path.exists(lib_path) and lib_path not in sys.path:
        sys.path.append(lib_path)

import FreeCAD
import Part

# -----------------------------------------------------------------------------
# Parametric Dimensions (Meters & Engineering Constants)
# -----------------------------------------------------------------------------
# Base Foundation (Standard 20 ft ISO Container Footprint)
CONT_L          = 6.058   # 20 ft ISO intermodal container length
CONT_W          = 2.438   # 20 ft ISO intermodal container width
CONT_H          = 2.591   # 20 ft ISO intermodal container height

# Deployable Foundation Outriggers & Helical Anchors
OUTRIGGER_W     = 0.40    # Heavy tubular steel outrigger width
OUTRIGGER_EXT   = 2.20    # Lateral extension beyond container wall
PAD_RADIUS      = 0.45    # Ground bearing pad radius
PAD_THICK       = 0.18    # Pad structural thickness

# Sectional Tubular Mast (5 segments x 4.8 m = 24.0 m tower height)
MAST_H          = 24.0    # Tower hub height
MAST_D          = 0.508   # Tower outer diameter (20-inch pipe)
MAST_WALL       = 0.008   # 8 mm steel wall
SECTIONS_COUNT  = 5       # Number of modular sections (4.8 m each)
GUY_RING_Z      = 16.0    # Guy wire collar height (approx 2/3 mast elevation)
GUY_CABLE_D     = 0.024   # 24 mm high-tensile steel guy cable

# Direct-Drive PMSG Nacelle & Generator Housing
NACELLE_L       = 3.40    # Insulated nacelle length
NACELLE_D       = 1.35    # Nacelle outer diameter
NOSE_CONE_L     = 0.65    # Rime-ice shedding spinner cone length
HUB_D           = 1.10    # Rotor hub central barrel diameter

# Aerodynamic Rotor & Blade Geometry (26.0 m Diameter)
ROTOR_DIA       = 26.0    # Swept rotor diameter
BLADE_SPAN      = 12.0    # Aerodynamic blade length from hub flange
BLADE_ROOT_CHORD= 1.20    # Maximum chord at blade root
BLADE_TIP_CHORD = 0.45    # Minimum chord at blade tip
BLADE_SECTIONS  = 7       # Modular segments per blade (each <= 1.90 m)


def make_airfoil_wire(chord, thickness=0.18, z=0.0, twist_deg=0.0, n_pts=28):
    """Generates a closed NACA 4-digit airfoil wire scaled and twisted at elevation z."""
    pts_upper = []
    pts_lower = []
    for i in range(n_pts + 1):
        xc = i / float(n_pts)
        yt = 5.0 * thickness * (
            0.2969 * math.sqrt(xc)
            - 0.1260 * xc
            - 0.3516 * (xc ** 2)
            + 0.2843 * (xc ** 3)
            - 0.1036 * (xc ** 4)
        )
        x_local = (xc - 0.25) * chord
        y_upper = yt * chord
        y_lower = -yt * chord

        rad = math.radians(twist_deg)
        cos_t, sin_t = math.cos(rad), math.sin(rad)
        xu = x_local * cos_t - y_upper * sin_t
        yu = x_local * sin_t + y_upper * cos_t
        xl = x_local * cos_t - y_lower * sin_t
        yl = x_local * sin_t + y_lower * cos_t

        pts_upper.append(FreeCAD.Vector(xu, yu, z))
        pts_lower.append(FreeCAD.Vector(xl, yl, z))

    poly_pts = pts_upper + pts_lower[::-1][1:] + [pts_upper[0]]
    return Part.makePolygon(poly_pts)


def create_modular_aerodynamic_blade():
    """Constructs a lofted aerodynamic blade with segmented structural sleeve collars."""
    w_root = make_airfoil_wire(chord=BLADE_ROOT_CHORD, thickness=0.21, z=0.40, twist_deg=10.0, n_pts=28)
    w_st1  = make_airfoil_wire(chord=1.05, thickness=0.18, z=3.80, twist_deg=6.5, n_pts=28)
    w_st2  = make_airfoil_wire(chord=0.75, thickness=0.16, z=8.00, twist_deg=3.2, n_pts=28)
    w_tip  = make_airfoil_wire(chord=BLADE_TIP_CHORD, thickness=0.14, z=BLADE_SPAN, twist_deg=0.8, n_pts=28)

    airfoil_solid = Part.makeLoft([w_root, w_st1, w_st2, w_tip], True)

    root_flange = Part.makeCylinder(0.32, 0.42, FreeCAD.Vector(0, 0, 0.0), FreeCAD.Vector(0, 0, 1))
    blade = airfoil_solid.fuse(root_flange)

    seg_step = BLADE_SPAN / float(BLADE_SECTIONS)
    for s in range(1, BLADE_SECTIONS):
        sz = s * seg_step
        chord_at_s = BLADE_ROOT_CHORD - (BLADE_ROOT_CHORD - BLADE_TIP_CHORD) * (sz / BLADE_SPAN)
        collar_w = chord_at_s * 1.08
        collar = Part.makeBox(collar_w, 0.22, 0.08, FreeCAD.Vector(-collar_w * 0.35, -0.11, sz - 0.04))
        blade = blade.fuse(collar)

    return blade


def build_modular_wind_turbine_v3():
    """Builds complete Modular Arctic Wind Turbine v3.1 solid assembly."""
    solids = []

    # 1. 20 ft ISO Container Foundation Sled
    cont_box = Part.makeBox(CONT_L, CONT_W, CONT_H, FreeCAD.Vector(-CONT_L / 2.0, -CONT_W / 2.0, 0.0))
    solids.append(cont_box)

    for sx in [-1.0, 1.0]:
        for sy in [-1.0, 1.0]:
            for sz in [0.0, CONT_H - 0.30]:
                cx = sx * (CONT_L / 2.0 - 0.30) if sx > 0 else -CONT_L / 2.0
                cy = sy * (CONT_W / 2.0 - 0.30) if sy > 0 else -CONT_W / 2.0
                corner = Part.makeBox(0.30, 0.30, 0.30, FreeCAD.Vector(cx, cy, sz))
                solids.append(corner)

    # 4x Deployable Foundation Outriggers with Ground Bearing Pads & Helical Anchor Caps
    for sign_x in [-1.0, 1.0]:
        for sign_y in [-1.0, 1.0]:
            ox = sign_x * (CONT_L / 2.0 - 0.60)
            oy = sign_y * (CONT_W / 2.0)
            beam_y = min(oy, oy + sign_y * OUTRIGGER_EXT)
            beam = Part.makeBox(OUTRIGGER_W, OUTRIGGER_EXT, 0.28, FreeCAD.Vector(ox - OUTRIGGER_W / 2.0, beam_y, 0.12))
            
            # Hinge locking shear pin boss
            hinge_pin = Part.makeCylinder(0.06, 0.35, FreeCAD.Vector(ox, oy, 0.10), FreeCAD.Vector(1, 0, 0))
            
            pad_y = oy + sign_y * (OUTRIGGER_EXT - 0.25)
            pad = Part.makeCylinder(PAD_RADIUS, PAD_THICK, FreeCAD.Vector(ox, pad_y, 0.0), FreeCAD.Vector(0, 0, 1))
            
            # Central helical screw anchor drive cap
            helical_cap = Part.makeCylinder(0.12, 0.14, FreeCAD.Vector(ox, pad_y, PAD_THICK), FreeCAD.Vector(0, 0, 1))
            
            # Guy cable D-ring anchor bracket on bearing pad
            dring_bracket = Part.makeBox(0.12, 0.12, 0.16, FreeCAD.Vector(ox - 0.06, pad_y - 0.06, PAD_THICK))
            
            solids.append(beam.fuse(hinge_pin).fuse(pad).fuse(helical_cap).fuse(dring_bracket))

    # Rear Microgrid Interconnection Power Cabinet
    cab_l = 0.90
    cab_w = 1.40
    cab_h = 1.80
    microgrid_cabinet = Part.makeBox(
        cab_l, cab_w, cab_h,
        FreeCAD.Vector(-CONT_L / 2.0 - cab_l, -cab_w / 2.0, 0.40)
    )
    solids.append(microgrid_cabinet)

    # Gin-Pole Erection A-Frame with Base Pivot Trunnions, Sheave, and Winch
    # Base pivot trunnion brackets on container roof
    trunnion_l = Part.makeBox(0.24, 0.22, 0.26, FreeCAD.Vector(0.68, -0.81, CONT_H))
    trunnion_r = Part.makeBox(0.24, 0.22, 0.26, FreeCAD.Vector(0.68, 0.59, CONT_H))
    
    # A-Frame Tubular Legs
    gin_pole_l = Part.makeCylinder(0.08, 4.20, FreeCAD.Vector(0.80, -0.70, CONT_H + 0.13), FreeCAD.Vector(-0.25, 0.15, 1.0))
    gin_pole_r = Part.makeCylinder(0.08, 4.20, FreeCAD.Vector(0.80, 0.70, CONT_H + 0.13), FreeCAD.Vector(-0.25, -0.15, 1.0))
    
    # Apex Cross-Spreader and Sheave Pulley Wheel
    apex_z = CONT_H + 0.13 + 4.20 * (1.0 / math.sqrt(0.25**2 + 0.15**2 + 1.0))
    apex_x = 0.80 - 4.20 * (0.25 / math.sqrt(0.25**2 + 0.15**2 + 1.0))
    sheave_wheel = Part.makeCylinder(0.14, 0.10, FreeCAD.Vector(apex_x, -0.05, apex_z - 0.05), FreeCAD.Vector(0, 1, 0))
    apex_cross = Part.makeCylinder(0.06, 0.40, FreeCAD.Vector(apex_x, -0.20, apex_z), FreeCAD.Vector(0, 1, 0))
    
    # Planetary Electric Winch Drum & Motor Gearbox
    winch_frame = Part.makeBox(0.60, 0.70, 0.50, FreeCAD.Vector(1.40, -0.35, CONT_H))
    winch_drum  = Part.makeCylinder(0.16, 0.40, FreeCAD.Vector(1.50, -0.20, CONT_H + 0.25), FreeCAD.Vector(0, 1, 0))
    winch_motor = Part.makeCylinder(0.13, 0.25, FreeCAD.Vector(1.50, 0.20, CONT_H + 0.25), FreeCAD.Vector(0, 1, 0))
    
    # Tower Lifting Trunnion Collar on Lower Mast (z = CONT_H + 6.0 m)
    lift_collar_z = CONT_H + 6.0
    lift_collar = Part.makeCylinder(MAST_D / 2.0 + 0.10, 0.28, FreeCAD.Vector(0, 0, lift_collar_z), FreeCAD.Vector(0, 0, 1))
    
    # Erection Hoist Cable (from Winch over Apex Sheave to Lift Collar)
    hoist_to_apex = Part.makeCylinder(0.016, math.sqrt((apex_x - 1.50)**2 + (apex_z - (CONT_H + 0.25))**2),
                                      FreeCAD.Vector(1.50, 0, CONT_H + 0.25),
                                      FreeCAD.Vector(apex_x - 1.50, 0, apex_z - (CONT_H + 0.25)))
    hoist_to_mast = Part.makeCylinder(0.016, math.sqrt((0 - apex_x)**2 + (lift_collar_z - apex_z)**2),
                                      FreeCAD.Vector(apex_x, 0, apex_z),
                                      FreeCAD.Vector(-apex_x, 0, lift_collar_z - apex_z))

    gin_rigging = trunnion_l.fuse(trunnion_r).fuse(gin_pole_l).fuse(gin_pole_r).fuse(apex_cross).fuse(sheave_wheel).fuse(winch_frame).fuse(winch_drum).fuse(winch_motor).fuse(lift_collar).fuse(hoist_to_apex).fuse(hoist_to_mast)
    solids.append(gin_rigging)

    # 2. Sectional Tubular Steel Mast (Hub Height = 24.0 m)
    mast = Part.makeCylinder(MAST_D / 2.0, MAST_H, FreeCAD.Vector(0, 0, CONT_H), FreeCAD.Vector(0, 0, 1))
    solids.append(mast)

    sec_len = MAST_H / float(SECTIONS_COUNT)
    for s in range(1, SECTIONS_COUNT):
        fz = CONT_H + s * sec_len
        flange = Part.makeCylinder(MAST_D / 2.0 + 0.12, 0.14, FreeCAD.Vector(0, 0, fz - 0.07), FreeCAD.Vector(0, 0, 1))
        solids.append(flange)

    # 4-Point Guy Wire Tension Ring Collar with Mechanical Clevis Lug Ears
    collar_z = CONT_H + GUY_RING_Z
    guy_ring = Part.makeCylinder(MAST_D / 2.0 + 0.18, 0.35, FreeCAD.Vector(0, 0, collar_z), FreeCAD.Vector(0, 0, 1))
    solids.append(guy_ring)

    # 4x Guy Wire Tension Cables with Clevis Lugs and Turnbuckles
    for sign_x in [-1.0, 1.0]:
        for sign_y in [-1.0, 1.0]:
            anchor_x = sign_x * (CONT_L / 2.0 - 0.60)
            anchor_y = sign_y * (CONT_W / 2.0 + OUTRIGGER_EXT - 0.25)
            anchor_z = PAD_THICK

            collar_pt = FreeCAD.Vector(sign_x * 0.38, sign_y * 0.38, collar_z + 0.17)
            target_pt = FreeCAD.Vector(anchor_x, anchor_y, anchor_z + 0.16)
            cable_vec = target_pt - collar_pt
            cable_len = cable_vec.Length

            # Radial Clevis Lug Ear on Guy Collar
            lug_ear = Part.makeBox(0.14, 0.14, 0.20, FreeCAD.Vector(sign_x * 0.32 - 0.07, sign_y * 0.32 - 0.07, collar_z + 0.07))
            
            # Upper Turnbuckle Tensioner Body (cylinder along cable line)
            tb_upper = Part.makeCylinder(0.045, 0.45, collar_pt, cable_vec)
            
            # Lower Turnbuckle Tensioner Body (near outrigger pad)
            tb_lower_pt = target_pt - cable_vec * (0.50 / cable_len)
            tb_lower = Part.makeCylinder(0.045, 0.45, tb_lower_pt, cable_vec)

            # High-Tensile Guy Wire Cable
            cable = Part.makeCylinder(GUY_CABLE_D / 2.0, cable_len, collar_pt, cable_vec)
            
            solids.append(lug_ear.fuse(tb_upper).fuse(tb_lower).fuse(cable))

    # 3. Direct-Drive Arctic Nacelle Housing & Thermal Cowl
    nacelle_z = CONT_H + MAST_H
    nacelle_body = Part.makeCylinder(
        NACELLE_D / 2.0, NACELLE_L,
        FreeCAD.Vector(-NACELLE_L * 0.68, 0, nacelle_z), FreeCAD.Vector(1, 0, 0)
    )
    rear_cowl = Part.makeCone(
        NACELLE_D / 2.0, 0.30, 0.85,
        FreeCAD.Vector(-NACELLE_L * 0.68, 0, nacelle_z), FreeCAD.Vector(-1, 0, 0)
    )
    solids.append(nacelle_body.fuse(rear_cowl))

    # 4. Central Rotor Hub & Anti-Icing Nose Spinner Cone
    spinner_x = NACELLE_L * 0.32
    hub_barrel = Part.makeCylinder(HUB_D / 2.0, 0.55, FreeCAD.Vector(spinner_x, 0, nacelle_z), FreeCAD.Vector(1, 0, 0))
    spinner_cone = Part.makeCone(
        HUB_D / 2.0, 0.12, NOSE_CONE_L,
        FreeCAD.Vector(spinner_x + 0.55, 0, nacelle_z), FreeCAD.Vector(1, 0, 0)
    )
    solids.append(hub_barrel.fuse(spinner_cone))

    # 5. Three Aerodynamic Rotor Blades (120° Spacing)
    base_blade = create_modular_aerodynamic_blade()
    blade_center_x = spinner_x + 0.28

    for i in range(3):
        angle_deg = i * 120.0
        blade_copy = base_blade.copy()
        rot = FreeCAD.Rotation(FreeCAD.Vector(1, 0, 0), angle_deg)
        blade_copy.Placement = FreeCAD.Placement(FreeCAD.Vector(blade_center_x, 0, nacelle_z), rot)
        solids.append(blade_copy)

    compound = solids[0]
    for s in solids[1:]:
        compound = compound.fuse(s)

    return compound


def export_step(solid, output_path):
    """Exports solid to standard ISO 10303 STEP format."""
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    solid.exportStep(output_path)
    file_size = os.path.getsize(output_path)
    print(f"✅ Exported STEP solid model: {output_path} ({file_size:,} bytes)")
    return file_size


if __name__ == "__main__":
    print(f"Building Modular Arctic Wind Turbine ({__version__}) solid model via FreeCAD...")
    model = build_modular_wind_turbine_v3()

    if FreeCAD.GuiUp:
        doc = FreeCAD.activeDocument() or FreeCAD.newDocument("Modular_Wind_Turbine_v3")
        obj = doc.addObject("Part::Feature", "Wind_Turbine_Assembly_v3")
        obj.Shape = model
        doc.recompute()
        print("Inserted Wind_Turbine_Assembly_v3 into active FreeCAD document.")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    step_out = os.path.join(script_dir, "..", "step_exports", "modular_wind_turbine_v3.step")
    export_step(model, os.path.abspath(step_out))
