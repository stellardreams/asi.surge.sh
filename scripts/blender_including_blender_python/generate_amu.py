# Date Created: 2026-01-25
# Version: 2.0
# Updated by: Claude (Anthropic)
# Purpose: Generate AMU with cavities for 3D printing

import bpy
import bmesh
import math

def setup_units():
    """Sets the scene units to Millimeters for precision engineering."""
    scene = bpy.context.scene
    scene.unit_settings.system = 'METRIC'
    scene.unit_settings.length_unit = 'MILLIMETERS'
    scene.unit_settings.scale_length = 0.001

def delete_default_objects():
    """Clears the scene to start fresh."""
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()

def create_amu_with_cavities():
    """
    Generates the AMU with door cavities:
    X: 80mm (Length)
    Y: 30mm (Height)
    Z: 30mm (Width)
    Wall Thickness: 1.2mm
    Cavities: 6mm x 6mm, positioned 20mm from edges, 3mm from base
    Top Platform: 8mm x 2mm x 6mm, centered at X=40mm (middle)
    """
    length = 80.0
    height = 30.0
    width = 30.0
    wall_thickness = 1.2
    fillet_radius = 2.0
    
    # --- Create Outer Shell ---
    bpy.ops.mesh.primitive_cylinder_add(
        radius=height/2, 
        depth=length, 
        rotation=(0, math.radians(90), 0)
    )
    outer_body = bpy.context.active_object
    outer_body.name = "AMU_Outer_Shell"

    # --- Create Inner Shell (Hollow) ---
    bpy.ops.mesh.primitive_cylinder_add(
        radius=(height/2) - wall_thickness, 
        depth=length + 2,
        rotation=(0, math.radians(90), 0)
    )
    inner_body = bpy.context.active_object
    inner_body.name = "AMU_Inner_Cut"

    # Boolean to make it hollow
    mod_bool = outer_body.modifiers.new(name="Hollow", type='BOOLEAN')
    mod_bool.object = inner_body
    mod_bool.operation = 'DIFFERENCE'
    
    bpy.context.view_layer.objects.active = outer_body
    bpy.ops.object.modifier_apply(modifier="Hollow")
    bpy.data.objects.remove(inner_body, do_unlink=True)

    # --- Bevel/Fillet edges ---
    bpy.ops.object.mode_set(mode='EDIT')
    bm = bmesh.from_edit_mesh(outer_body.data)
    for edge in bm.edges:
        edge.select = True
    bmesh.ops.bevel(bm, geom=bm.edges, offset=fillet_radius, segments=8, affect='EDGES')
    bmesh.update_edit_mesh(outer_body.data)
    bpy.ops.object.mode_set(mode='OBJECT')

    # --- Create Cavities (Doors) ---
    cavity_width = 6.0  # X dimension
    cavity_height = 6.0  # Y dimension
    cavity_depth = wall_thickness  # Z dimension (matches wall thickness)
    
    # Position cavities 20mm from outermost edges
    # Total length = 80mm, so edges are at ±40mm
    # 20mm from edge means at ±20mm from center
    x_positions = [-20.0, 20.0]
    
    # 3mm from base: base is at -15mm (height/2), so Y = -15 + 3 = -12mm
    y_pos = -(height/2) + 3.0
    
    # Z position: on the side wall, aligned with cylinder surface
    z_offset = (width/2)  # Position on outer surface
    
    for i, x_pos in enumerate(x_positions):
        # Create cavity cutter - positioned on the Z+ side
        bpy.ops.mesh.primitive_cube_add(
            size=1.0, 
            location=(x_pos, y_pos, z_offset)
        )
        cutter = bpy.context.active_object
        cutter.name = f"Door_Cutter_{i}"
        cutter.scale = (cavity_width, cavity_height, cavity_depth + 2)  # Extra depth to ensure clean cut
        
        # Boolean subtraction
        mod_door = outer_body.modifiers.new(name=f"Door_{i}", type='BOOLEAN')
        mod_door.object = cutter
        mod_door.operation = 'DIFFERENCE'
        
        bpy.context.view_layer.objects.active = outer_body
        bpy.ops.object.modifier_apply(modifier=f"Door_{i}")
        bpy.data.objects.remove(cutter, do_unlink=True)

    # --- Create Top Platform ---
    # Centered between the two cavities at X=0 (40mm is the center of 80mm length)
    platform_length = 8.0   # X
    platform_height = 2.0   # Y
    platform_width = 6.0    # Z
    
    bpy.ops.mesh.primitive_cube_add(
        size=1.0,
        location=(0, (height/2) + (platform_height/2), 0)
    )
    top_platform = bpy.context.active_object
    top_platform.name = "AMU_Top_Platform"
    top_platform.scale = (platform_length, platform_height, platform_width)
    
    # Join platform to main body
    bpy.ops.object.select_all(action='DESELECT')
    outer_body.select_set(True)
    top_platform.select_set(True)
    bpy.context.view_layer.objects.active = outer_body
    bpy.ops.object.join()
    
    print("AMU Model with Cavities Generated Successfully.")

if __name__ == "__main__":
    setup_units()
    # delete_default_objects()  # Commented out - uncomment to clear scene
    create_amu_with_cavities()