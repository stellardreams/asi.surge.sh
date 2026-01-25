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

def create_amu():
    """
    Generates the AMU based on specific dimensions:
    X: 80mm (Length)
    Y: 30mm (Height)
    Z: 30mm (Across)
    Wall Thickness: 1.2mm
    """
    length = 80.0
    height = 30.0
    width = 30.0
    wall_thickness = 1.2
    fillet_radius = 2.0
    
    # --- Create Outer Shell ---
    # We use a cylinder as basis (rotated to align with X-axis)
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
        depth=length + 2, # Slightly longer for clean Cut
        rotation=(0, math.radians(90), 0)
    )
    inner_body = bpy.context.active_object
    inner_body.name = "AMU_Inner_Cut"

    # Boolean to make it hollow
    mod_bool = outer_body.modifiers.new(name="Hollow", type='BOOLEAN')
    mod_bool.object = inner_body
    mod_bool.operation = 'DIFFERENCE'
    
    # Apply modifier and delete cutter
    bpy.context.view_layer.objects.active = outer_body
    bpy.ops.object.modifier_apply(modifier="Hollow")
    bpy.data.objects.remove(inner_body, do_unlink=True)

    # --- Bevel/Fillet edges ---
    # To avoid sharp edges on the end caps
    bpy.ops.object.mode_set(mode='EDIT')
    bm = bmesh.from_edit_mesh(outer_body.data)
    # Select all boundary edges of the cylinder caps
    for edge in bm.edges:
        edge.select = True
    bmesh.ops.bevel(bm, geom=bm.edges, offset=fillet_radius, segments=8, affect='EDGES')
    bmesh.update_edit_mesh(outer_body.data)
    bpy.ops.object.mode_set(mode='OBJECT')

    # --- Create Cavities (Doors) ---
    # "6mm wide and 6mm long. 20mm from outermost edges. 3mm from the base."
    cavity_size = 6.0
    edge_offset = 20.0
    base_offset = 3.0
    
    # Calculate positions
    # X: Outermost is ±40. offset 20 -> X = ±20.
    # Y: Base is -15. Offset 3 -> Y = -12.
    x_positions = [-20.0, 20.0]
    y_pos = -(height/2) + base_offset + (cavity_size/2)
    
    for i, x_pos in enumerate(x_positions):
        bpy.ops.mesh.primitive_cube_add(
            size=1.0, 
            location=(x_pos, y_pos, 0)
        )
        cutter = bpy.context.active_object
        cutter.name = f"Door_Cutter_{i}"
        cutter.scale = (cavity_size, cavity_size, width + 5) # Punch through Z
        
        # Boolean subtraction
        mod_door = outer_body.modifiers.new(name=f"Door_{i}", type='BOOLEAN')
        mod_door.object = cutter
        mod_door.operation = 'DIFFERENCE'
        
        bpy.context.view_layer.objects.active = outer_body
        bpy.ops.object.modifier_apply(modifier=f"Door_{i}")
        bpy.data.objects.remove(cutter, do_unlink=True)

    # --- Create Top Base ---
    # "8mm horizontal length (X), 2mm vertical height (Y), 6mm across (Z). Center 40mm."
    bpy.ops.mesh.primitive_cube_add(
        size=1.0,
        location=(0, (height/2) + (2.0/2), 0)
    )
    top_base = bpy.context.active_object
    top_base.name = "AMU_Top_Base"
    top_base.scale = (8.0, 2.0, 6.0)
    
    # Join onto main body
    bpy.ops.object.select_all(action='DESELECT')
    outer_body.select_set(True)
    top_base.select_set(True)
    bpy.context.view_layer.objects.active = outer_body
    bpy.ops.object.join()

if __name__ == "__main__":
    setup_units()
    delete_default_objects()
    create_amu()
    print("AMU Model Generated Successfully.")
