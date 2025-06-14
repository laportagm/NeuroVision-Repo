extends Node3D

## Test scene to verify brain structure colors are applied correctly

func _ready():
	print("\n========== BRAIN STRUCTURE COLOR TEST ==========")
	
	# Create test meshes for each brain structure
	var structures = M3DesignTokens.BRAIN_STRUCTURE_COLORS.keys()
	var grid_size = ceil(sqrt(structures.size()))
	var spacing = 3.0
	
	for i in range(structures.size()):
		var structure_id = structures[i]
		var color = M3DesignTokens.get_color(structure_id)
		
		# Create sphere mesh
		var mesh_instance = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radial_segments = 32
		sphere.height_segments = 16
		mesh_instance.mesh = sphere
		
		# Create material with structure color
		var material = StandardMaterial3D.new()
		material.albedo_color = color
		material.metallic = 0.1
		material.roughness = 0.7
		mesh_instance.set_surface_override_material(0, material)
		
		# Position in grid
		var row = i / int(grid_size)
		var col = i % int(grid_size)
		mesh_instance.position = Vector3(
			(col - grid_size/2) * spacing,
			0,
			(row - grid_size/2) * spacing
		)
		
		add_child(mesh_instance)
		
		# Add label
		var label_3d = Label3D.new()
		label_3d.text = structure_id
		label_3d.position = Vector3(0, -1.5, 0)
		label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label_3d.modulate = M3DesignTokens.get_color("on_surface")
		mesh_instance.add_child(label_3d)
		
		print("Created %s with color %s" % [structure_id, color])
	
	# Add camera
	var camera = Camera3D.new()
	camera.position = Vector3(0, 10, 20)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	add_child(camera)
	
	# Add light
	var light = DirectionalLight3D.new()
	light.rotation = Vector3(deg_to_rad(-45), deg_to_rad(-45), 0)
	add_child(light)
	
	print("\nAll brain structure colors displayed!")
	print("You should see spheres with the following colors:")
	for structure_id in structures:
		var color = M3DesignTokens.get_color(structure_id)
		print("  %s: %s" % [structure_id, color])