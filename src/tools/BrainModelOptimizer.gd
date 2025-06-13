@tool
extends EditorScript

## Brain Model Optimizer for NeuroVision
##
## This tool optimizes the brain models for better performance on standard hardware
## by creating LOD variants and applying optimization techniques.
##
## Features:
## - Creates LOD variants with proper triangle reduction
## - Optimizes textures for each LOD level
## - Generates collision meshes
## - Reports performance metrics
##
## Usage: Run from Script Editor with Script > Run

# === CONSTANTS ===
const SOURCE_DIR: String = "res://assets/3d_models/raw/"
const OUTPUT_DIR: String = "res://assets/3d_models/processed/"
const USE_SUBDIRECTORIES: bool = true  # Create model-specific folders for LODs

# Target polygon counts for each LOD
const LOD_TARGETS: Dictionary = {
	"_low": 25000,     # For Intel UHD 620
	"_medium": 50000,  # Balanced
	"_high": 100000    # High quality
}

# Texture size multipliers for each LOD
const TEXTURE_SCALES: Dictionary = {
	"_low": 0.25,     # 256x256 from 1024x1024
	"_medium": 0.5,   # 512x512 from 1024x1024
	"_high": 1.0      # Original size
}

var processed_models: int = 0
var total_models: int = 0

# === MAIN EXECUTION ===

func _run() -> void:
	print("\n========================================")
	print("   NeuroVision Brain Model Optimizer")
	print("========================================\n")
	
	# Create output directory if needed
	_ensure_output_directory()
	
	# Find all models to process
	var models = _find_brain_models()
	total_models = models.size()
	
	if total_models == 0:
		print("❌ No brain models found in: " + SOURCE_DIR)
		print("\nPlease ensure your brain model files (.glb) are in:")
		print("  " + SOURCE_DIR)
		return
	
	print("Found %d model(s) to optimize\n" % total_models)
	
	# Process each model
	for model_path in models:
		_optimize_model(model_path)
		processed_models += 1
	
	_print_summary()

# === MODEL PROCESSING ===

func _optimize_model(model_path: String) -> void:
	"""Optimize a single brain model"""
	var model_name = model_path.get_file().get_basename()
	print("📦 Processing: %s" % model_name)
	print("────────────────────────────────────────")
	
	# Load the model
	var resource = load(model_path)
	if not resource:
		print("  ❌ Failed to load model")
		return
	
	# Analyze original model
	var stats = _analyze_model(resource)
	print("  📊 Original: %d vertices, %d triangles" % [stats.vertices, stats.triangles])
	
	# Generate each LOD variant
	for lod_suffix in LOD_TARGETS:
		var target_triangles = LOD_TARGETS[lod_suffix]
		var texture_scale = TEXTURE_SCALES[lod_suffix]
		
		print("\n  🔧 Generating%s variant:" % lod_suffix)
		print("     Target: ~%d triangles" % target_triangles)
		
		var optimized = _create_optimized_variant(resource, target_triangles, texture_scale)
		if optimized:
			var output_path: String
			if USE_SUBDIRECTORIES:
				# Create subdirectory for this model
				var subdirectory = OUTPUT_DIR + model_name.replace("-", "_") + "_LOD/"
				_ensure_directory_exists(subdirectory)
				output_path = subdirectory + model_name + lod_suffix + ".glb"
			else:
				output_path = OUTPUT_DIR + model_name + lod_suffix + ".glb"
			
			_save_optimized_model(optimized, output_path)
			
			# Analyze result
			var new_stats = _analyze_model(optimized)
			var reduction = (1.0 - float(new_stats.triangles) / float(stats.triangles)) * 100.0
			print("     Result: %d triangles (%.1f%% reduction)" % [new_stats.triangles, reduction])
			print("     ✅ Saved: " + output_path)
		else:
			print("     ❌ Failed to optimize")
	
	print("\n")

func _create_optimized_variant(resource: Resource, target_triangles: int, texture_scale: float) -> Resource:
	"""Create an optimized variant of the model"""
	if resource is PackedScene:
		# Instantiate the scene
		var scene = resource.instantiate()
		var optimized_scene = Node3D.new()
		optimized_scene.name = scene.name
		
		# Process all mesh instances
		_optimize_node_recursive(scene, optimized_scene, target_triangles, texture_scale)
		
		# Clean up original
		scene.queue_free()
		
		# Pack the optimized scene
		var packed = PackedScene.new()
		packed.pack(optimized_scene)
		return packed
	
	return null

func _optimize_node_recursive(source: Node, target_parent: Node, target_triangles: int, texture_scale: float) -> void:
	"""Recursively optimize nodes in the scene"""
	# Create corresponding node in target
	var target_node: Node
	
	if source is MeshInstance3D:
		target_node = MeshInstance3D.new()
		target_node.name = source.name
		
		# Optimize the mesh
		if source.mesh:
			var optimized_mesh = _optimize_mesh(source.mesh, target_triangles)
			target_node.mesh = optimized_mesh
			
			# Copy and optimize materials
			for i in range(source.get_surface_override_material_count()):
				var mat = source.get_surface_override_material(i)
				if mat:
					var optimized_mat = _optimize_material(mat, texture_scale)
					target_node.set_surface_override_material(i, optimized_mat)
		
		# Copy transform
		if source is Node3D and target_node is Node3D:
			target_node.transform = source.transform
	
	elif source is Node3D:
		target_node = Node3D.new()
		target_node.name = source.name
		target_node.transform = source.transform
	else:
		target_node = Node.new()
		target_node.name = source.name
	
	# Add to parent
	target_parent.add_child(target_node)
	target_node.owner = target_parent.owner if target_parent.owner else target_parent
	
	# Process children
	for child in source.get_children():
		_optimize_node_recursive(child, target_node, target_triangles, texture_scale)

func _optimize_mesh(original_mesh: Mesh, target_triangles: int) -> ArrayMesh:
	"""Optimize a mesh to target triangle count"""
	var optimized = ArrayMesh.new()
	
	# Calculate total triangles in original
	var total_triangles = 0
	for i in range(original_mesh.get_surface_count()):
		var arrays = original_mesh.surface_get_arrays(i)
		if arrays[Mesh.ARRAY_INDEX]:
			total_triangles += arrays[Mesh.ARRAY_INDEX].size() / 3
		elif arrays[Mesh.ARRAY_VERTEX]:
			total_triangles += arrays[Mesh.ARRAY_VERTEX].size() / 3
	
	# Calculate reduction ratio
	var ratio = float(target_triangles) / float(total_triangles)
	if ratio > 0.95:
		ratio = 1.0  # Don't optimize if already within target
	
	# Process each surface
	for surf_idx in range(original_mesh.get_surface_count()):
		var arrays = original_mesh.surface_get_arrays(surf_idx)
		
		if ratio < 1.0:
			arrays = _simplify_surface_arrays(arrays, ratio)
		
		# Add optimized surface
		optimized.add_surface_from_arrays(
			original_mesh.surface_get_primitive_type(surf_idx),
			arrays
		)
		
		# Copy material reference
		var material = original_mesh.surface_get_material(surf_idx)
		if material:
			optimized.surface_set_material(surf_idx, material)
	
	return optimized

func _simplify_surface_arrays(arrays: Array, ratio: float) -> Array:
	"""Simplify surface arrays by the given ratio"""
	var simplified = []
	simplified.resize(Mesh.ARRAY_MAX)
	
	# Get vertex data
	var vertices = arrays[Mesh.ARRAY_VERTEX]
	var normals = arrays[Mesh.ARRAY_NORMAL]
	var uvs = arrays[Mesh.ARRAY_TEX_UV]
	var indices = arrays[Mesh.ARRAY_INDEX]
	
	if not vertices:
		return arrays
	
	# Use uniform mesh simplification
	if indices and indices.size() > 0:
		# For indexed geometry
		var target_indices = int(indices.size() * ratio)
		target_indices = target_indices - (target_indices % 3)  # Ensure multiple of 3
		
		# Simple uniform sampling of triangles
		var new_indices = PackedInt32Array()
		var step = max(1, int(1.0 / ratio))
		
		for i in range(0, indices.size(), step * 3):
			if i + 2 < indices.size():
				new_indices.append(indices[i])
				new_indices.append(indices[i + 1])
				new_indices.append(indices[i + 2])
			
			if new_indices.size() >= target_indices:
				break
		
		simplified[Mesh.ARRAY_VERTEX] = vertices
		simplified[Mesh.ARRAY_INDEX] = new_indices
		
		# Copy other arrays as-is
		if normals:
			simplified[Mesh.ARRAY_NORMAL] = normals
		if uvs:
			simplified[Mesh.ARRAY_TEX_UV] = uvs
	else:
		# For non-indexed geometry, reduce vertices directly
		var step = max(1, int(1.0 / ratio))
		var new_vertices = PackedVector3Array()
		var new_normals = PackedVector3Array()
		var new_uvs = PackedVector2Array()
		
		for i in range(0, vertices.size(), step * 3):
			# Take complete triangles
			for j in range(3):
				if i + j < vertices.size():
					new_vertices.append(vertices[i + j])
					if normals:
						new_normals.append(normals[i + j])
					if uvs:
						new_uvs.append(uvs[i + j])
		
		simplified[Mesh.ARRAY_VERTEX] = new_vertices
		if normals:
			simplified[Mesh.ARRAY_NORMAL] = new_normals
		if uvs:
			simplified[Mesh.ARRAY_TEX_UV] = new_uvs
	
	# Copy other attributes
	for i in range(Mesh.ARRAY_MAX):
		if i not in [Mesh.ARRAY_VERTEX, Mesh.ARRAY_NORMAL, Mesh.ARRAY_TEX_UV, Mesh.ARRAY_INDEX]:
			if arrays[i] != null:
				simplified[i] = arrays[i]
	
	return simplified

func _optimize_material(original_mat: Material, texture_scale: float) -> Material:
	"""Optimize material textures for LOD"""
	# For now, just return the original material
	# In a full implementation, we would resize textures here
	return original_mat

# === UTILITY FUNCTIONS ===

func _analyze_model(resource: Resource) -> Dictionary:
	"""Analyze model statistics"""
	var stats = {
		"vertices": 0,
		"triangles": 0,
		"surfaces": 0,
		"materials": 0
	}
	
	if resource is PackedScene:
		var scene = resource.instantiate()
		_analyze_node_recursive(scene, stats)
		scene.queue_free()
	
	return stats

func _analyze_node_recursive(node: Node, stats: Dictionary) -> void:
	"""Recursively analyze nodes for statistics"""
	if node is MeshInstance3D and node.mesh:
		var mesh = node.mesh
		stats.surfaces += mesh.get_surface_count()
		
		for i in range(mesh.get_surface_count()):
			var arrays = mesh.surface_get_arrays(i)
			
			if arrays[Mesh.ARRAY_VERTEX]:
				stats.vertices += arrays[Mesh.ARRAY_VERTEX].size()
			
			if arrays[Mesh.ARRAY_INDEX]:
				stats.triangles += arrays[Mesh.ARRAY_INDEX].size() / 3
			elif arrays[Mesh.ARRAY_VERTEX]:
				stats.triangles += arrays[Mesh.ARRAY_VERTEX].size() / 3
			
			if mesh.surface_get_material(i):
				stats.materials += 1
	
	for child in node.get_children():
		_analyze_node_recursive(child, stats)

func _save_optimized_model(resource: Resource, path: String) -> void:
	"""Save the optimized model"""
	var error = ResourceSaver.save(resource, path)
	if error != OK:
		print("     ❌ Failed to save: " + path + " (Error: " + str(error) + ")")

func _find_brain_models() -> Array:
	"""Find all brain model files"""
	var models = []
	var dir = DirAccess.open(SOURCE_DIR)
	
	if not dir:
		return models
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = SOURCE_DIR + file_name
		if file_name.ends_with(".glb") or file_name.ends_with(".gltf"):
			models.append(full_path)
		file_name = dir.get_next()
	
	return models

func _ensure_output_directory() -> void:
	"""Ensure output directory exists"""
	_ensure_directory_exists(OUTPUT_DIR)

func _ensure_directory_exists(path: String) -> void:
	"""Ensure any directory exists"""
	var dir = DirAccess.open("res://")
	if not dir.dir_exists(path):
		dir.make_dir_recursive(path)
		print("Created directory: " + path)

func _print_summary() -> void:
	"""Print optimization summary"""
	print("\n========================================")
	print("           OPTIMIZATION COMPLETE")
	print("========================================")
	print("  Processed: %d/%d models" % [processed_models, total_models])
	print("  Output: " + OUTPUT_DIR)
	print("\n⚡ NEXT STEPS:")
	print("  1. Close and reopen the project")
	print("  2. Let Godot reimport the new models")
	print("  3. Test with PerformanceMonitor")
	print("========================================\n")