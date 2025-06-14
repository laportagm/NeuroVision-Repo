extends Node

## Brain Structure Color Manager
##
## Manages the application of educational colors to brain structure models
## based on the M3DesignTokens color system.

signal structure_colored(structure_id: String, mesh: MeshInstance3D)
signal batch_coloring_complete()

# === CONSTANTS ===
const MATERIAL_TRANSITION_TIME: float = 0.3
const BATCH_PROCESS_DELAY: float = 0.05

# === PRIVATE VARIABLES ===
var _structure_materials: Dictionary = {}  # structure_id -> Material
var _processing_queue: Array = []
var _is_processing: bool = false

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[BrainStructureColorManager] Initializing brain structure color system")
	_preload_structure_materials()

func apply_structure_colors(model_instance: Node3D, structure_mappings: Dictionary = {}) -> void:
	"""Apply brain structure colors to all meshes in a model"""
	print("[BrainStructureColorManager] Applying colors to brain model")
	
	# Find all mesh instances
	var meshes = _find_all_meshes(model_instance)
	
	for mesh in meshes:
		var structure_id = _get_structure_id_from_mesh(mesh, structure_mappings)
		if structure_id:
			_queue_structure_coloring(structure_id, mesh)
	
	# Start processing queue
	_process_coloring_queue()

func apply_single_structure_color(structure_id: String, mesh: MeshInstance3D) -> void:
	"""Apply color to a single brain structure"""
	if not mesh:
		return
		
	var material = _get_or_create_structure_material(structure_id)
	if material:
		_apply_material_to_mesh(mesh, material)
		structure_colored.emit(structure_id, mesh)

func get_structure_color(structure_id: String) -> Color:
	"""Get the color for a specific brain structure"""
	return M3DesignTokens.get_color(structure_id)

func reset_to_default_colors(model_instance: Node3D) -> void:
	"""Reset all meshes to their default brain structure colors"""
	var meshes = _find_all_meshes(model_instance)
	
	for mesh in meshes:
		var structure_id = _get_structure_id_from_mesh(mesh)
		if structure_id:
			apply_single_structure_color(structure_id, mesh)

# === PRIVATE METHODS ===

func _preload_structure_materials() -> void:
	"""Preload materials for all known brain structures"""
	var brain_structures = M3DesignTokens.BRAIN_STRUCTURE_COLORS.keys()
	
	for structure_id in brain_structures:
		_get_or_create_structure_material(structure_id)
	
	print("[BrainStructureColorManager] Preloaded %d structure materials" % _structure_materials.size())

func _get_or_create_structure_material(structure_id: String) -> StandardMaterial3D:
	"""Get or create a material for a brain structure"""
	if structure_id in _structure_materials:
		return _structure_materials[structure_id]
	
	# Create new material with structure color
	var material = StandardMaterial3D.new()
	var color = M3DesignTokens.get_color(structure_id)
	
	# Base color
	material.albedo_color = color
	
	# Add slight metallic/roughness for realism
	material.metallic = 0.1
	material.roughness = 0.7
	
	# Subtle rim lighting for depth
	material.rim_enabled = true
	material.rim = 0.5
	material.rim_tint = 0.3
	
	# Enable proper lighting
	material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	
	# Store material
	_structure_materials[structure_id] = material
	
	return material

func _apply_material_to_mesh(mesh: MeshInstance3D, material: Material) -> void:
	"""Apply material to all surfaces of a mesh"""
	if not mesh or not mesh.mesh:
		return
		
	var surface_count = mesh.mesh.get_surface_count()
	
	# Apply to all surfaces
	for i in range(surface_count):
		mesh.set_surface_override_material(i, material)

func _find_all_meshes(node: Node3D) -> Array:
	"""Recursively find all MeshInstance3D nodes"""
	var meshes = []
	
	if node is MeshInstance3D:
		meshes.append(node)
	
	for child in node.get_children():
		if child is Node3D:
			meshes.append_array(_find_all_meshes(child))
	
	return meshes

func _get_structure_id_from_mesh(mesh: MeshInstance3D, mappings: Dictionary = {}) -> String:
	"""Extract structure ID from mesh name or metadata"""
	# Check metadata first
	if mesh.has_meta("structure_id"):
		return mesh.get_meta("structure_id")
	
	# Check mappings
	if mesh.name in mappings:
		return mappings[mesh.name]
	
	# Try to normalize mesh name to structure ID
	var normalized = _normalize_structure_name(mesh.name)
	
	# Check if normalized name exists in brain structures
	if M3DesignTokens.has_token(normalized):
		return normalized
	
	# Special cases
	var special_mappings = {
		"hipp and others": "hippocampus",
		"hipp_and_others": "hippocampus",
		"striatum_good": "basal_ganglia",
		"cortex_regions": "cortex"
	}
	
	var lower_name = normalized.to_lower()
	for pattern in special_mappings:
		if lower_name.contains(pattern):
			return special_mappings[pattern]
	
	return ""

func _normalize_structure_name(mesh_name: String) -> String:
	"""Normalize mesh name to potential structure ID"""
	var normalized = mesh_name.to_lower()
	
	# Remove common suffixes
	var suffixes_to_remove = ["_good", "_bad", "(good)", "(bad)", "_mesh", "_instance"]
	for suffix in suffixes_to_remove:
		normalized = normalized.replace(suffix, "")
	
	# Replace spaces and special characters
	normalized = normalized.replace(" ", "_")
	normalized = normalized.replace("-", "_")
	
	# Remove numbers at the end
	var regex = RegEx.new()
	regex.compile("_\\d+$")
	normalized = regex.sub(normalized, "")
	
	return normalized.strip_edges()

func _queue_structure_coloring(structure_id: String, mesh: MeshInstance3D) -> void:
	"""Add structure to coloring queue"""
	_processing_queue.append({
		"structure_id": structure_id,
		"mesh": mesh
	})

func _process_coloring_queue() -> void:
	"""Process the coloring queue with delays for performance"""
	if _is_processing or _processing_queue.is_empty():
		return
		
	_is_processing = true
	
	while not _processing_queue.is_empty():
		var item = _processing_queue.pop_front()
		apply_single_structure_color(item.structure_id, item.mesh)
		
		# Small delay between items for performance
		if not _processing_queue.is_empty():
			await get_tree().create_timer(BATCH_PROCESS_DELAY).timeout
	
	_is_processing = false
	batch_coloring_complete.emit()

# === DEBUG METHODS ===

func debug_list_structure_materials() -> void:
	"""Print all loaded structure materials"""
	print("[BrainStructureColorManager] Loaded materials:")
	for structure_id in _structure_materials:
		var material = _structure_materials[structure_id]
		print("  %s: %s" % [structure_id, material.albedo_color])

func debug_apply_test_colors(model_instance: Node3D) -> void:
	"""Apply test colors to verify system is working"""
	var test_colors = ["primary", "secondary", "tertiary", "error", "success"]
	var meshes = _find_all_meshes(model_instance)
	
	for i in range(meshes.size()):
		var color_name = test_colors[i % test_colors.size()]
		var material = StandardMaterial3D.new()
		material.albedo_color = M3DesignTokens.get_color(color_name)
		_apply_material_to_mesh(meshes[i], material)