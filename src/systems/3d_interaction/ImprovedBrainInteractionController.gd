class_name ImprovedBrainInteractionController
extends Node3D

## Enhanced controller for 3D brain structure interaction with robust selection mapping
##
## This improved version simplifies mesh-to-structure mapping and provides
## better feedback for educational interactions.

signal structure_selected(structure_id: String, mesh_instance: MeshInstance3D)
signal structure_highlighted(structure_id: String, mesh_instance: MeshInstance3D)
signal selection_cleared()
signal structure_clicked(structure_id: String, position: Vector3)

# === CONSTANTS ===
const HIGHLIGHT_COLOR: Color = Color.CYAN
const SELECTED_COLOR: Color = Color.YELLOW
const HOVER_COLOR: Color = Color(0.5, 0.8, 1.0)
const ORIGINAL_COLOR: Color = Color.WHITE
const HIGHLIGHT_INTENSITY: float = 1.5
const SELECTION_FADE_TIME: float = 0.3

# Common mesh name patterns to normalize
const MESH_NAME_PATTERNS = {
	"striatum_good": "striatum",
	"striatum (good)": "striatum",
	"hipp_and_others_good": "hippocampus",
	"hipp and others (good)": "hippocampus",
	"hippocampus_good": "hippocampus",
	"thalamus_good": "thalamus",
	"amygdala_good": "amygdala",
	"cerebellum_good": "cerebellum",
	"brainstem_good": "brainstem",
	"corpus_callosum_good": "corpus_callosum"
}

# === EXPORTS ===
@export var selection_enabled: bool = true
@export var highlight_enabled: bool = true
@export var multi_selection: bool = false
@export var max_selection_distance: float = 100.0
@export var debug_mode: bool = true  # Enable detailed logging

@export_group("Visual Feedback")
@export var use_outline: bool = true
@export var outline_width: float = 2.0
@export var use_emission: bool = true
@export var emission_strength: float = 0.5

# === PRIVATE VARIABLES ===
var _camera: Camera3D
var _selected_structures: Dictionary = {}  # structure_id -> MeshInstance3D
var _highlighted_structure: MeshInstance3D = null
var _original_materials: Dictionary = {}  # MeshInstance3D -> Array[Material]
var _raycast_enabled: bool = true
var _feedback_manager: SelectionFeedbackManager
var _mesh_to_structure_map: Dictionary = {}  # Cached mesh name -> structure ID mapping
var _structure_to_mesh_map: Dictionary = {}  # Reverse mapping

# === PUBLIC METHODS ===

func initialize(camera: Camera3D) -> void:
	"""Initialize the interaction controller with a camera"""
	_camera = camera
	if not _camera:
		push_error("[ImprovedBrainInteraction] Camera is required for interaction")
		return
	
	# Setup feedback manager
	_feedback_manager = SelectionFeedbackManager.new()
	add_child(_feedback_manager)
	
	# Build initial mapping cache
	_build_mesh_mappings()
	
	print("[ImprovedBrainInteraction] Controller initialized with enhanced mapping")

func register_brain_structure(mesh_instance: MeshInstance3D, structure_id: String) -> void:
	"""Register a mesh instance with its structure ID for reliable mapping"""
	if not mesh_instance or structure_id.is_empty():
		return
	
	# Store in both directions
	var mesh_name = mesh_instance.name
	_mesh_to_structure_map[mesh_name] = structure_id
	_structure_to_mesh_map[structure_id] = mesh_instance
	
	# Also store as metadata on the mesh for redundancy
	mesh_instance.set_meta("structure_id", structure_id)
	mesh_instance.set_meta("structure_name", structure_id.capitalize().replace("_", " "))
	
	if debug_mode:
		print("[ImprovedBrainInteraction] Registered: ", mesh_name, " -> ", structure_id)

func enable_selection(enabled: bool) -> void:
	"""Enable or disable selection functionality"""
	selection_enabled = enabled
	if not enabled:
		clear_all_selections()

func enable_highlighting(enabled: bool) -> void:
	"""Enable or disable highlight functionality"""
	highlight_enabled = enabled
	if not enabled and _highlighted_structure:
		_clear_highlight()

func perform_raycast(mouse_position: Vector2) -> Dictionary:
	"""Perform a raycast from camera through mouse position"""
	if not _camera or not _raycast_enabled:
		return {}
	
	var from = _camera.project_ray_origin(mouse_position)
	var to = from + _camera.project_ray_normal(mouse_position) * max_selection_distance
	
	var space_state = _camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1  # Adjust based on your layer setup
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	
	if debug_mode and result.has("collider"):
		print("[ImprovedBrainInteraction] Raycast hit: ", result.collider.get_path())
	
	return result

func handle_mouse_click(event: InputEventMouseButton) -> void:
	"""Handle mouse click for structure selection"""
	if not selection_enabled or not event.pressed:
		return
	
	# Handle RIGHT mouse button for selection
	if event.button_index == MOUSE_BUTTON_RIGHT:
		if debug_mode:
			print("[ImprovedBrainInteraction] Right click at: ", event.position)
		
		var result = perform_raycast(event.position)
		if result.has("collider"):
			var add_to_selection = event.shift_pressed and multi_selection
			_handle_structure_selection(result, add_to_selection)
		else:
			if debug_mode:
				print("[ImprovedBrainInteraction] No structure hit")
			_feedback_manager.provide_error_feedback("No structure selected")
			clear_all_selections()

func handle_mouse_motion(event: InputEventMouseMotion) -> void:
	"""Handle mouse motion for structure highlighting"""
	if not highlight_enabled:
		return
	
	var result = perform_raycast(event.position)
	if result.has("collider"):
		_handle_structure_highlight(result)
	else:
		_clear_highlight()

func select_structure(structure_id: String, mesh_instance: MeshInstance3D) -> void:
	"""Programmatically select a structure"""
	if not selection_enabled:
		return
	
	if not multi_selection:
		clear_all_selections()
	
	_apply_selection_visual(mesh_instance)
	_selected_structures[structure_id] = mesh_instance
	
	# Provide feedback
	_feedback_manager.provide_selection_feedback(mesh_instance, structure_id)
	
	structure_selected.emit(structure_id, mesh_instance)

func select_structure_by_id(structure_id: String) -> bool:
	"""Select a structure by its ID"""
	if not _structure_to_mesh_map.has(structure_id):
		if debug_mode:
			print("[ImprovedBrainInteraction] Structure ID not found: ", structure_id)
		_feedback_manager.provide_error_feedback("Structure not found: " + structure_id)
		return false
	
	var mesh_instance = _structure_to_mesh_map[structure_id]
	select_structure(structure_id, mesh_instance)
	return true

func select_structure_by_mesh(mesh_instance: MeshInstance3D) -> void:
	"""Select a structure by its mesh instance"""
	if not mesh_instance:
		return
	
	var structure_id = _get_structure_id_from_mesh(mesh_instance)
	if structure_id.is_empty():
		if debug_mode:
			print("[ImprovedBrainInteraction] Could not determine structure ID for mesh: ", mesh_instance.name)
		_feedback_manager.provide_error_feedback("Unknown structure")
		return
	
	select_structure(structure_id, mesh_instance)

func deselect_structure(structure_id: String) -> void:
	"""Deselect a specific structure"""
	if structure_id in _selected_structures:
		var mesh = _selected_structures[structure_id]
		_restore_original_material(mesh)
		_feedback_manager.provide_deselection_feedback(mesh)
		_selected_structures.erase(structure_id)

func clear_all_selections() -> void:
	"""Clear all selected structures"""
	for structure_id in _selected_structures:
		var mesh = _selected_structures[structure_id]
		_restore_original_material(mesh)
		_feedback_manager.provide_deselection_feedback(mesh)
	
	_selected_structures.clear()
	selection_cleared.emit()

func get_selected_structures() -> Array:
	"""Get array of selected structure IDs"""
	return _selected_structures.keys()

func is_structure_selected(structure_id: String) -> bool:
	"""Check if a structure is selected"""
	return structure_id in _selected_structures

# === PRIVATE METHODS ===

func _build_mesh_mappings() -> void:
	"""Build initial mesh name to structure ID mappings"""
	# Add common patterns
	for pattern in MESH_NAME_PATTERNS:
		_mesh_to_structure_map[pattern] = MESH_NAME_PATTERNS[pattern]
	
	if debug_mode:
		print("[ImprovedBrainInteraction] Built ", _mesh_to_structure_map.size(), " initial mappings")

func _get_structure_id_from_mesh(mesh_instance: MeshInstance3D) -> String:
	"""Get structure ID from mesh instance with multiple fallback strategies"""
	# Strategy 1: Check metadata
	if mesh_instance.has_meta("structure_id"):
		return mesh_instance.get_meta("structure_id")
	
	# Strategy 2: Check direct mapping
	var mesh_name = mesh_instance.name
	if _mesh_to_structure_map.has(mesh_name):
		return _mesh_to_structure_map[mesh_name]
	
	# Strategy 3: Try normalized name
	var normalized = _normalize_mesh_name(mesh_name)
	if _mesh_to_structure_map.has(normalized):
		return _mesh_to_structure_map[normalized]
	
	# Strategy 4: Check pattern matching
	for pattern in MESH_NAME_PATTERNS:
		if mesh_name.to_lower().contains(pattern.split("_")[0]):
			return MESH_NAME_PATTERNS[pattern]
	
	# Strategy 5: Fuzzy matching
	var fuzzy_id = _fuzzy_match_structure_id(mesh_name)
	if not fuzzy_id.is_empty():
		# Cache this mapping for future use
		_mesh_to_structure_map[mesh_name] = fuzzy_id
		return fuzzy_id
	
	# Fallback: Use cleaned mesh name as ID
	return normalized

func _normalize_mesh_name(mesh_name: String) -> String:
	"""Normalize mesh name to structure ID format"""
	var normalized = mesh_name.to_lower().strip_edges()
	
	# Remove common suffixes
	var suffixes = ["_good", " (good)", "_mesh", "_model", "_obj", "_glb"]
	for suffix in suffixes:
		normalized = normalized.replace(suffix, "")
	
	# Replace spaces and special characters
	normalized = normalized.replace(" ", "_")
	normalized = normalized.replace("-", "_")
	
	# Remove numbers at the end
	var regex = RegEx.new()
	regex.compile("_\\d+$")
	normalized = regex.sub(normalized, "")
	
	return normalized.strip_edges()

func _fuzzy_match_structure_id(mesh_name: String) -> String:
	"""Attempt fuzzy matching for structure ID"""
	var cleaned = _normalize_mesh_name(mesh_name)
	
	# Known structure IDs to match against
	var known_structures = [
		"hippocampus", "amygdala", "thalamus", "striatum",
		"cerebellum", "brainstem", "corpus_callosum",
		"prefrontal_cortex", "motor_cortex", "visual_cortex"
	]
	
	# Check for partial matches
	for structure in known_structures:
		if cleaned.contains(structure) or structure.contains(cleaned):
			return structure
		
		# Check abbreviations
		if cleaned.length() >= 3:
			var abbrev = structure.substr(0, 3)
			if cleaned.begins_with(abbrev):
				return structure
	
	return ""

func _handle_structure_selection(raycast_result: Dictionary, add_to_selection: bool = false) -> void:
	"""Handle structure selection from raycast result"""
	var collider = raycast_result.collider
	var mesh_instance = _find_mesh_instance(collider)
	
	if not mesh_instance:
		if debug_mode:
			print("[ImprovedBrainInteraction] No mesh instance found from collider")
		_feedback_manager.provide_error_feedback("Selection failed")
		return
	
	var structure_id = _get_structure_id_from_mesh(mesh_instance)
	if structure_id.is_empty():
		if debug_mode:
			print("[ImprovedBrainInteraction] Could not determine structure ID")
		_feedback_manager.provide_error_feedback("Unknown structure")
		return
	
	if debug_mode:
		print("[ImprovedBrainInteraction] Selected structure: ", structure_id)
	
	# Handle selection toggle
	if structure_id in _selected_structures and not add_to_selection:
		deselect_structure(structure_id)
	else:
		if not multi_selection and not add_to_selection:
			clear_all_selections()
		
		select_structure(structure_id, mesh_instance)
		structure_clicked.emit(structure_id, raycast_result.position)

func _handle_structure_highlight(raycast_result: Dictionary) -> void:
	"""Handle structure highlighting from raycast result"""
	var collider = raycast_result.collider
	var mesh_instance = _find_mesh_instance(collider)
	
	if not mesh_instance or mesh_instance == _highlighted_structure:
		return
	
	# Clear previous highlight
	_clear_highlight()
	
	# Don't highlight already selected structures
	var structure_id = _get_structure_id_from_mesh(mesh_instance)
	if structure_id in _selected_structures:
		return
	
	# Apply highlight
	_highlighted_structure = mesh_instance
	_apply_highlight_visual(mesh_instance)
	_feedback_manager.provide_hover_feedback(mesh_instance, structure_id)
	structure_highlighted.emit(structure_id, mesh_instance)

func _clear_highlight() -> void:
	"""Clear current highlight"""
	if _highlighted_structure and is_instance_valid(_highlighted_structure):
		var structure_id = _get_structure_id_from_mesh(_highlighted_structure)
		if not (structure_id in _selected_structures):
			_restore_original_material(_highlighted_structure)
		_highlighted_structure = null

func _apply_selection_visual(mesh_instance: MeshInstance3D) -> void:
	"""Apply selection visual effect to mesh"""
	_store_original_materials(mesh_instance)
	
	for i in range(mesh_instance.get_surface_override_material_count()):
		var material = mesh_instance.get_surface_override_material(i)
		if not material:
			material = mesh_instance.mesh.surface_get_material(i) if mesh_instance.mesh else null
		
		if material:
			var new_material = _create_highlighted_material(material, SELECTED_COLOR)
			mesh_instance.set_surface_override_material(i, new_material)

func _apply_highlight_visual(mesh_instance: MeshInstance3D) -> void:
	"""Apply highlight visual effect to mesh"""
	_store_original_materials(mesh_instance)
	
	for i in range(mesh_instance.get_surface_override_material_count()):
		var material = mesh_instance.get_surface_override_material(i)
		if not material:
			material = mesh_instance.mesh.surface_get_material(i) if mesh_instance.mesh else null
		
		if material:
			var new_material = _create_highlighted_material(material, HOVER_COLOR)
			mesh_instance.set_surface_override_material(i, new_material)

func _create_highlighted_material(base_material: Material, highlight_color: Color) -> Material:
	"""Create a highlighted version of a material"""
	var new_material: StandardMaterial3D
	
	if base_material is StandardMaterial3D:
		new_material = base_material.duplicate()
	else:
		new_material = StandardMaterial3D.new()
	
	# Apply highlight effects
	new_material.albedo_color = highlight_color
	
	if use_emission:
		new_material.emission_enabled = true
		new_material.emission = highlight_color
		new_material.emission_energy_multiplier = emission_strength
	
	if use_outline:
		new_material.grow_amount = outline_width
		new_material.rim_enabled = true
		new_material.rim = 1.0
		new_material.rim_tint = 0.5
	
	return new_material

func _store_original_materials(mesh_instance: MeshInstance3D) -> void:
	"""Store original materials for later restoration"""
	if mesh_instance in _original_materials:
		return
	
	var materials = []
	for i in range(mesh_instance.get_surface_override_material_count()):
		var material = mesh_instance.get_surface_override_material(i)
		if not material and mesh_instance.mesh:
			material = mesh_instance.mesh.surface_get_material(i)
		materials.append(material)
	
	_original_materials[mesh_instance] = materials

func _restore_original_material(mesh_instance: MeshInstance3D) -> void:
	"""Restore original materials to mesh"""
	if not (mesh_instance in _original_materials):
		return
	
	var materials = _original_materials[mesh_instance]
	for i in range(materials.size()):
		mesh_instance.set_surface_override_material(i, materials[i])
	
	_original_materials.erase(mesh_instance)

func _find_mesh_instance(node: Node) -> MeshInstance3D:
	"""Find MeshInstance3D from collider node with improved search"""
	if node is MeshInstance3D:
		return node
	
	# Strategy 1: Check if node has mesh instance reference
	if node.has_method("get_mesh_instance"):
		var mesh = node.get_mesh_instance()
		if mesh is MeshInstance3D:
			return mesh
	
	# Strategy 2: Check parent hierarchy
	var current = node
	var max_depth = 5  # Limit search depth
	var depth = 0
	
	while current and depth < max_depth:
		if current is MeshInstance3D:
			return current
		
		# Check siblings at this level
		if current.get_parent():
			for sibling in current.get_parent().get_children():
				if sibling is MeshInstance3D and sibling != current:
					# Verify this mesh is related to our collider
					if _is_mesh_related_to_collider(sibling, node):
						return sibling
		
		current = current.get_parent()
		depth += 1
	
	# Strategy 3: Deep search children
	return _find_mesh_in_children(node, 3)

func _find_mesh_in_children(node: Node, max_depth: int) -> MeshInstance3D:
	"""Recursively search for MeshInstance3D in children"""
	if max_depth <= 0:
		return null
	
	for child in node.get_children():
		if child is MeshInstance3D:
			return child
		
		var result = _find_mesh_in_children(child, max_depth - 1)
		if result:
			return result
	
	return null

func _is_mesh_related_to_collider(mesh: MeshInstance3D, collider: Node) -> bool:
	"""Check if a mesh instance is related to a collider"""
	# Check if they share a common parent
	var mesh_parent = mesh.get_parent()
	var collider_parent = collider.get_parent()
	
	if mesh_parent == collider_parent:
		return true
	
	# Check if collider is a physics body that contains the mesh
	if collider is StaticBody3D or collider is Area3D:
		return collider.is_ancestor_of(mesh) or mesh.is_ancestor_of(collider)
	
	return false