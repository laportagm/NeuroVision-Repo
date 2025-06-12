@tool
extends EditorScript

## Simple LOD Generator for NeuroVision brain models
## 
## This tool generates optimized LOD (Level of Detail) variants from the original
## high-resolution brain models to improve performance on standard hardware.
##
## Target specifications:
## - LOW: ~25k vertices (for Intel UHD 620)
## - MEDIUM: ~50k vertices (balanced quality/performance)
## - HIGH: Original quality
##
## Usage: Select this script in FileSystem dock and run via Script > Run

# === CONSTANTS ===
const SOURCE_PATH: String = "res://assets/3d_models/raw/"
const OUTPUT_PATH: String = "res://assets/3d_models/processed/"

# LOD reduction ratios (1.0 = original quality)
const LOD_RATIOS: Dictionary = {
	"_high": 1.0,      # Keep original quality
	"_medium": 0.5,    # 50% reduction
	"_low": 0.25       # 75% reduction
}

# === MAIN EXECUTION ===

func _run() -> void:
	print("\n=== NeuroVision LOD Generator ===")
	print("Starting LOD generation process...")
	
	# Ensure output directory exists
	_ensure_directory_exists(OUTPUT_PATH)
	
	# Find all model files
	var models = _find_model_files()
	
	if models.is_empty():
		print("ERROR: No model files found in " + SOURCE_PATH)
		return
	
	print("Found %d model(s) to process" % models.size())
	
	# Process each model
	for model_file in models:
		_process_model(model_file)
	
	print("\n=== LOD Generation Complete ===")
	print("Models saved to: " + OUTPUT_PATH)
	print("Remember to reimport the project for changes to take effect!")

# === PROCESSING METHODS ===

func _process_model(model_file: String) -> void:
	"""Process a single model file to generate LOD variants"""
	print("\nProcessing: " + model_file)
	
	var full_path = SOURCE_PATH + model_file
	var resource = load(full_path)
	
	if not resource:
		print("  ERROR: Failed to load " + model_file)
		return
	
	# Get base name without extension
	var base_name = model_file.get_basename()
	
	# Generate LOD variants
	for suffix in LOD_RATIOS:
		var ratio = LOD_RATIOS[suffix]
		var output_name = base_name + suffix + ".glb"
		var output_path = OUTPUT_PATH + output_name
		
		print("  Generating " + suffix + " variant (%.0f%% quality)..." % (ratio * 100))
		
		if ratio == 1.0:
			# For high quality, just copy the original
			_copy_original(full_path, output_path)
		else:
			# For reduced quality, simplify the mesh
			_generate_simplified_variant(resource, output_path, ratio)

func _generate_simplified_variant(resource: Resource, output_path: String, ratio: float) -> void:
	"""Generate a simplified variant of the model"""
	
	# Check if it's a PackedScene with GLB data
	if resource is PackedScene:
		# For GLB files loaded as PackedScene, we need to extract and simplify meshes
		var scene = resource.instantiate()
		var simplified_scene = _simplify_scene_meshes(scene, ratio)
		
		# Save as new scene
		var packed = PackedScene.new()
		packed.pack(simplified_scene)
		
		var error = ResourceSaver.save(packed, output_path)
		if error == OK:
			print("    ✓ Saved: " + output_path)
		else:
			print("    ✗ Failed to save: " + output_path + " (Error: " + str(error) + ")")
		
		# Clean up
		scene.queue_free()
		simplified_scene.queue_free()
	else:
		print("    ✗ Unsupported resource type: " + resource.get_class())

func _simplify_scene_meshes(scene: Node3D, ratio: float) -> Node3D:
	"""Simplify all meshes in a scene"""
	var simplified_scene = scene.duplicate()
	
	# Find all MeshInstance3D nodes
	var mesh_instances = _find_all_mesh_instances(simplified_scene)
	var total_vertices_before = 0
	var total_vertices_after = 0
	
	for mesh_instance in mesh_instances:
		if mesh_instance.mesh:
			var original_vertices = _count_mesh_vertices(mesh_instance.mesh)
			total_vertices_before += original_vertices
			
			# Create simplified mesh
			var simplified_mesh = _simplify_mesh(mesh_instance.mesh, ratio)
			if simplified_mesh:
				mesh_instance.mesh = simplified_mesh
				total_vertices_after += _count_mesh_vertices(simplified_mesh)
			else:
				total_vertices_after += original_vertices
	
	print("    Vertices: %d -> %d (%.1f%% reduction)" % [
		total_vertices_before,
		total_vertices_after,
		(1.0 - float(total_vertices_after) / float(total_vertices_before)) * 100.0
	])
	
	return simplified_scene

func _simplify_mesh(original_mesh: Mesh, ratio: float) -> ArrayMesh:
	"""Simplify a single mesh using Godot's built-in tools"""
	if not original_mesh is ArrayMesh:
		# Convert to ArrayMesh if needed
		var array_mesh = ArrayMesh.new()
		for surface_idx in range(original_mesh.get_surface_count()):
			var arrays = original_mesh.surface_get_arrays(surface_idx)
			array_mesh.add_surface_from_arrays(
				original_mesh.surface_get_primitive_type(surface_idx),
				arrays
			)
			# Copy material
			var material = original_mesh.surface_get_material(surface_idx)
			if material:
				array_mesh.surface_set_material(surface_idx, material)
		original_mesh = array_mesh
	
	var simplified_mesh = ArrayMesh.new()
	
	for surface_idx in range(original_mesh.get_surface_count()):
		var arrays = original_mesh.surface_get_arrays(surface_idx)
		
		# Get vertex data
		var vertices = arrays[Mesh.ARRAY_VERTEX]
		if not vertices or vertices.is_empty():
			continue
		
		# Simple decimation: skip vertices based on ratio
		var new_arrays = _decimate_surface(arrays, ratio)
		
		# Add simplified surface
		simplified_mesh.add_surface_from_arrays(
			original_mesh.surface_get_primitive_type(surface_idx),
			new_arrays
		)
		
		# Copy material
		var material = original_mesh.surface_get_material(surface_idx)
		if material:
			simplified_mesh.surface_set_material(surface_idx, material)
	
	return simplified_mesh

func _decimate_surface(arrays: Array, ratio: float) -> Array:
	"""Decimate a surface by reducing vertices"""
	var new_arrays = []
	new_arrays.resize(Mesh.ARRAY_MAX)
	
	# Get original data
	var vertices = arrays[Mesh.ARRAY_VERTEX]
	var normals = arrays[Mesh.ARRAY_NORMAL]
	var uvs = arrays[Mesh.ARRAY_TEX_UV]
	var indices = arrays[Mesh.ARRAY_INDEX]
	
	if not vertices:
		return arrays
	
	# For indexed meshes
	if indices and indices.size() > 0:
		# Build new vertex data by sampling
		var vertex_count = vertices.size()
		var step = int(1.0 / ratio)
		if step < 1:
			step = 1
		
		var new_vertices = PackedVector3Array()
		var new_normals = PackedVector3Array()
		var new_uvs = PackedVector2Array()
		var vertex_map = {}  # old index -> new index
		
		# Sample vertices
		var new_index = 0
		for i in range(0, vertex_count, step):
			new_vertices.append(vertices[i])
			if normals:
				new_normals.append(normals[i])
			if uvs:
				new_uvs.append(uvs[i])
			vertex_map[i] = new_index
			new_index += 1
		
		# Rebuild indices
		var new_indices = PackedInt32Array()
		for i in range(0, indices.size(), 3):  # Process triangles
			var i0 = indices[i]
			var i1 = indices[i + 1]
			var i2 = indices[i + 2]
			
			# Find closest sampled vertices
			var ni0 = _find_closest_sampled_vertex(i0, vertex_map, step)
			var ni1 = _find_closest_sampled_vertex(i1, vertex_map, step)
			var ni2 = _find_closest_sampled_vertex(i2, vertex_map, step)
			
			# Skip degenerate triangles
			if ni0 != ni1 and ni1 != ni2 and ni2 != ni0:
				if ni0 in vertex_map and ni1 in vertex_map and ni2 in vertex_map:
					new_indices.append(vertex_map[ni0])
					new_indices.append(vertex_map[ni1])
					new_indices.append(vertex_map[ni2])
		
		# Build new arrays
		new_arrays[Mesh.ARRAY_VERTEX] = new_vertices
		if normals:
			new_arrays[Mesh.ARRAY_NORMAL] = new_normals
		if uvs:
			new_arrays[Mesh.ARRAY_TEX_UV] = new_uvs
		new_arrays[Mesh.ARRAY_INDEX] = new_indices
		
		# Copy other attributes if present
		for i in range(Mesh.ARRAY_MAX):
			if i not in [Mesh.ARRAY_VERTEX, Mesh.ARRAY_NORMAL, Mesh.ARRAY_TEX_UV, Mesh.ARRAY_INDEX]:
				if arrays[i] != null:
					new_arrays[i] = arrays[i]
	else:
		# For non-indexed meshes, just copy with reduced vertices
		new_arrays = arrays.duplicate()
	
	return new_arrays

func _find_closest_sampled_vertex(vertex_index: int, vertex_map: Dictionary, step: int) -> int:
	"""Find the closest sampled vertex index"""
	# Round to nearest sampled vertex
	var sampled_index = int(vertex_index / step) * step
	return sampled_index

# === UTILITY METHODS ===

func _find_model_files() -> Array:
	"""Find all GLB/GLTF files in the source directory"""
	var files = []
	var dir = DirAccess.open(SOURCE_PATH)
	
	if not dir:
		print("ERROR: Cannot open directory: " + SOURCE_PATH)
		return files
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".glb") or file_name.ends_with(".gltf"):
			files.append(file_name)
		file_name = dir.get_next()
	
	return files

func _find_all_mesh_instances(node: Node) -> Array:
	"""Recursively find all MeshInstance3D nodes"""
	var mesh_instances = []
	
	if node is MeshInstance3D:
		mesh_instances.append(node)
	
	for child in node.get_children():
		mesh_instances.append_array(_find_all_mesh_instances(child))
	
	return mesh_instances

func _count_mesh_vertices(mesh: Mesh) -> int:
	"""Count total vertices in a mesh"""
	var total = 0
	
	for surface_idx in range(mesh.get_surface_count()):
		var arrays = mesh.surface_get_arrays(surface_idx)
		if arrays[Mesh.ARRAY_VERTEX]:
			total += arrays[Mesh.ARRAY_VERTEX].size()
	
	return total

func _copy_original(source_path: String, dest_path: String) -> void:
	"""Copy original file for high quality variant"""
	var dir = DirAccess.open(SOURCE_PATH)
	if dir:
		var error = dir.copy(source_path, dest_path)
		if error == OK:
			print("    ✓ Copied: " + dest_path)
		else:
			print("    ✗ Failed to copy: " + dest_path + " (Error: " + str(error) + ")")

func _ensure_directory_exists(path: String) -> void:
	"""Ensure a directory exists, create if needed"""
	var dir = DirAccess.open("res://")
	if not dir.dir_exists(path):
		var error = dir.make_dir_recursive(path)
		if error == OK:
			print("Created directory: " + path)
		else:
			print("ERROR: Failed to create directory: " + path)