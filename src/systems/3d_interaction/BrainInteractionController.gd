extends Node3D

## Controller for 3D brain structure interaction and selection

signal structure_selected(structure_name: String, mesh_instance: MeshInstance3D)
signal structure_highlighted(structure_name: String, mesh_instance: MeshInstance3D)
signal selection_cleared()
signal structure_clicked(structure_name: String, position: Vector3)

# === CONSTANTS ===
const HIGHLIGHT_COLOR: Color = Color.CYAN
const SELECTED_COLOR: Color = Color.YELLOW
const HOVER_COLOR: Color = Color(0.5, 0.8, 1.0)
const ORIGINAL_COLOR: Color = Color.WHITE
const HIGHLIGHT_INTENSITY: float = 1.5
const SELECTION_FADE_TIME: float = 0.3

# === EXPORTS ===
@export var selection_enabled: bool = true
@export var highlight_enabled: bool = true
@export var multi_selection: bool = false
@export var max_selection_distance: float = 100.0
@export_group("Visual Feedback")
@export var use_outline: bool = true
@export var outline_width: float = 2.0
@export var use_emission: bool = true
@export var emission_strength: float = 0.5

# === PRIVATE VARIABLES ===
var _camera: Camera3D
var _selected_structures: Dictionary = {}  # structure_name -> MeshInstance3D
var _highlighted_structure: MeshInstance3D = null
var _original_materials: Dictionary = {}  # MeshInstance3D -> Array[Material]
var _raycast_enabled: bool = true

# === PUBLIC METHODS ===

func initialize(camera: Camera3D) -> void:
	"""Initialize the interaction controller with a camera"""
	_camera = camera
	if not _camera:
		push_error("[BrainInteraction] Camera is required for interaction")
		return
	
	print("[BrainInteraction] Controller initialized")

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
	return result

func handle_mouse_click(event: InputEventMouseButton) -> void:
	"""Handle mouse click for structure selection"""
	if not selection_enabled or not event.pressed:
		return
	
	# Handle RIGHT mouse button for selection (as per UI conventions)
	if event.button_index == MOUSE_BUTTON_RIGHT:
		print("[BrainInteraction] Right click detected at position: ", event.position)
		var result = perform_raycast(event.position)
		if result.has("collider"):
			print("[BrainInteraction] Raycast hit: ", result.collider.get_path())
			# Check for multi-selection
			var add_to_selection = event.shift_pressed and multi_selection
			_handle_structure_selection(result, add_to_selection)
		else:
			print("[BrainInteraction] Raycast missed - no collider hit")
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

func select_structure(structure_name: String, mesh_instance: MeshInstance3D) -> void:
	"""Programmatically select a structure"""
	if not selection_enabled:
		return
	
	if not multi_selection:
		clear_all_selections()
	
	_apply_selection_visual(mesh_instance)
	_selected_structures[structure_name] = mesh_instance
	structure_selected.emit(structure_name, mesh_instance)

func select_structure_by_mesh(mesh_instance: MeshInstance3D) -> void:
	"""Select a structure by its mesh instance"""
	if not mesh_instance:
		return
		
	var structure_name = _get_structure_name(mesh_instance)
	select_structure(structure_name, mesh_instance)

func deselect_structure(structure_name: String) -> void:
	"""Deselect a specific structure"""
	if structure_name in _selected_structures:
		var mesh = _selected_structures[structure_name]
		_restore_original_material(mesh)
		_selected_structures.erase(structure_name)

func clear_all_selections() -> void:
	"""Clear all selected structures"""
	for structure_name in _selected_structures:
		var mesh = _selected_structures[structure_name]
		_restore_original_material(mesh)
	
	_selected_structures.clear()
	selection_cleared.emit()

func get_selected_structures() -> Array:
	"""Get array of selected structure names"""
	return _selected_structures.keys()

func is_structure_selected(structure_name: String) -> bool:
	"""Check if a structure is selected"""
	return structure_name in _selected_structures

# === PRIVATE METHODS ===

func _handle_structure_selection(raycast_result: Dictionary, add_to_selection: bool = false) -> void:
	"""Handle structure selection from raycast result"""
	var collider = raycast_result.collider
	print("[BrainInteraction] Finding mesh instance from collider: ", collider)
	var mesh_instance = _find_mesh_instance(collider)
	
	if not mesh_instance:
		print("[BrainInteraction] Could not find mesh instance from collider")
		return
	
	print("[BrainInteraction] Found mesh instance: ", mesh_instance.get_path())
	var structure_name = _get_structure_name(mesh_instance)
	print("[BrainInteraction] Structure name: ", structure_name)
	if structure_name == "":
		return
	
	# Handle selection
	if structure_name in _selected_structures and not add_to_selection:
		# Deselect if already selected
		deselect_structure(structure_name)
	else:
		# Select structure
		if not multi_selection and not add_to_selection:
			clear_all_selections()
		
		select_structure(structure_name, mesh_instance)
		structure_clicked.emit(structure_name, raycast_result.position)

func _handle_structure_highlight(raycast_result: Dictionary) -> void:
	"""Handle structure highlighting from raycast result"""
	var collider = raycast_result.collider
	var mesh_instance = _find_mesh_instance(collider)
	
	if not mesh_instance or mesh_instance == _highlighted_structure:
		return
	
	# Clear previous highlight
	_clear_highlight()
	
	# Don't highlight already selected structures
	var structure_name = _get_structure_name(mesh_instance)
	if structure_name in _selected_structures:
		return
	
	# Apply highlight
	_highlighted_structure = mesh_instance
	_apply_highlight_visual(mesh_instance)
	structure_highlighted.emit(structure_name, mesh_instance)

func _clear_highlight() -> void:
	"""Clear current highlight"""
	if _highlighted_structure and is_instance_valid(_highlighted_structure):
		var structure_name = _get_structure_name(_highlighted_structure)
		if not (structure_name in _selected_structures):
			_restore_original_material(_highlighted_structure)
		_highlighted_structure = null

func _apply_selection_visual(mesh_instance: MeshInstance3D) -> void:
	"""Apply selection visual effect to mesh"""
	_store_original_materials(mesh_instance)
	
	for i in range(mesh_instance.get_surface_override_material_count()):
		var material = mesh_instance.get_surface_override_material(i)
		if not material:
			material = mesh_instance.mesh.surface_get_material(i)
		
		if material:
			var new_material = _create_highlighted_material(material, SELECTED_COLOR)
			mesh_instance.set_surface_override_material(i, new_material)

func _apply_highlight_visual(mesh_instance: MeshInstance3D) -> void:
	"""Apply highlight visual effect to mesh"""
	_store_original_materials(mesh_instance)
	
	for i in range(mesh_instance.get_surface_override_material_count()):
		var material = mesh_instance.get_surface_override_material(i)
		if not material:
			material = mesh_instance.mesh.surface_get_material(i)
		
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
		new_material.emission_energy = emission_strength
	
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
		if not material:
			material = mesh_instance.mesh.surface_get_material(i) if mesh_instance.mesh else null
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
	"""Find MeshInstance3D from collider node"""
	if node is MeshInstance3D:
		return node
	
	# Check parent hierarchy
	var current = node
	while current:
		if current is MeshInstance3D:
			return current
		current = current.get_parent()
	
	# Check children
	for child in node.get_children():
		if child is MeshInstance3D:
			return child
	
	return null

func _get_structure_name(mesh_instance: MeshInstance3D) -> String:
	"""Get structure name from mesh instance"""
	# Try to get name from node name
	var structure_name = mesh_instance.name
	
	# Check for metadata
	if mesh_instance.has_meta("structure_name"):
		structure_name = mesh_instance.get_meta("structure_name")
	elif mesh_instance.has_meta("brain_structure"):
		structure_name = mesh_instance.get_meta("brain_structure")
	
	# Clean up the name
	structure_name = structure_name.replace("_", " ").capitalize()
	
	return structure_name