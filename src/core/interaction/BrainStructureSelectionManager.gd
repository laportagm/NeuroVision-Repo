## BrainStructureSelectionManager.gd
## Educational 3D brain structure selection system for NeuroVision
##
## Handles user interaction for selecting anatomical structures with visual feedback,
## educational tooltips, and learning analytics integration.

class_name BrainStructureSelectionManager
extends Node

# === SIGNALS ===
signal structure_selected(structure_name: String, mesh: MeshInstance3D)
signal structure_hovered(structure_name: String, mesh: MeshInstance3D)
signal selection_cleared()
signal educational_interaction(type: String, data: Dictionary)

# === CONSTANTS ===
const MAX_SELECTION_DISTANCE: float = 1000.0
const HIGHLIGHT_FADE_DURATION: float = 0.3
const TOOLTIP_DELAY: float = 0.5

# Selection colors for educational feedback
const HOVER_COLOR: Color = Color(0.3, 0.6, 1.0, 0.3)
const SELECT_COLOR: Color = Color(0.2, 0.8, 0.4, 0.5)
const ERROR_COLOR: Color = Color(1.0, 0.3, 0.3, 0.4)

# === EXPORTS (Educational Configuration) ===
@export var educational_mode: bool = true
@export var highlight_enabled: bool = true
@export var show_tooltips: bool = true
@export var track_interactions: bool = true

# === PRIVATE VARIABLES ===
var _camera: Camera3D
var _selected_mesh: MeshInstance3D
var _hovered_mesh: MeshInstance3D
var _selection_sphere: MeshInstance3D
var _is_initialized: bool = false

# Interaction tracking
var _interaction_start_time: float
var _hover_timer: Timer

# Educational tooltips
var _tooltip_label: Label
var _tooltip_background: PanelContainer

# Material management
var _original_materials: Dictionary = {}
var _highlight_material: StandardMaterial3D

# === PUBLIC METHODS ===

func initialize(camera: Camera3D) -> bool:
	"""Initialize the selection system with camera reference"""
	if not camera:
		push_error("[BrainStructureSelectionManager] Invalid camera provided")
		return false
	
	_camera = camera
	_setup_highlight_materials()
	_setup_educational_ui()
	_is_initialized = true
	
	print("[BrainStructureSelectionManager] Selection system initialized")
	return true

func set_selection_sphere(sphere: MeshInstance3D) -> void:
	"""Set the selection sphere for visual feedback"""
	_selection_sphere = sphere
	if _selection_sphere:
		_selection_sphere.visible = false

func enable_educational_features(enabled: bool) -> void:
	"""Enable or disable educational-specific features"""
	educational_mode = enabled
	show_tooltips = enabled
	track_interactions = enabled
	
	if _tooltip_background:
		_tooltip_background.visible = enabled

func clear_selection() -> void:
	"""Clear current selection and visual feedback"""
	if _selected_mesh:
		_restore_original_material(_selected_mesh)
		_selected_mesh = null
	
	if _selection_sphere:
		_selection_sphere.visible = false
	
	_hide_tooltip()
	selection_cleared.emit()
	
	if educational_mode and track_interactions:
		educational_interaction.emit("selection_cleared", {})

func get_selected_structure() -> Dictionary:
	"""Get information about currently selected structure"""
	if not _selected_mesh:
		return {}
	
	return {
		"name": _get_structure_name(_selected_mesh),
		"mesh": _selected_mesh,
		"position": _selected_mesh.global_position,
		"selection_time": Time.get_unix_time_from_system() - _interaction_start_time
	}

# === INPUT HANDLING ===

func _unhandled_input(event: InputEvent) -> void:
	"""Handle selection input events"""
	if not _is_initialized or not _camera:
		return
	
	# Right-click for structure selection
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_handle_selection_click(event.position)
	
	# Mouse movement for hover detection
	elif event is InputEventMouseMotion:
		_handle_hover_detection(event.position)

# === PRIVATE METHODS ===

func _handle_selection_click(screen_pos: Vector2) -> void:
	"""Handle right-click selection"""
	var space_state = get_viewport().world_3d.direct_space_state
	var from = _camera.project_ray_origin(screen_pos)
	var to = from + _camera.project_ray_normal(screen_pos) * MAX_SELECTION_DISTANCE
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		clear_selection()
		return
	
	var collider = result.get("collider")
	if not collider:
		return
	
	# Find the parent MeshInstance3D
	var mesh_instance = _find_mesh_parent(collider)
	if not mesh_instance:
		return
	
	_select_structure(mesh_instance, result.get("position", Vector3.ZERO))

func _handle_hover_detection(screen_pos: Vector2) -> void:
	"""Handle mouse hover for educational tooltips"""
	if not show_tooltips:
		return
	
	var space_state = get_viewport().world_3d.direct_space_state
	var from = _camera.project_ray_origin(screen_pos)
	var to = from + _camera.project_ray_normal(screen_pos) * MAX_SELECTION_DISTANCE
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	var new_hovered_mesh = null
	if not result.is_empty():
		var collider = result.get("collider")
		if collider:
			new_hovered_mesh = _find_mesh_parent(collider)
	
	# Update hover state
	if new_hovered_mesh != _hovered_mesh:
		_update_hover_state(new_hovered_mesh, screen_pos)

func _select_structure(mesh: MeshInstance3D, world_pos: Vector3) -> void:
	"""Select a brain structure with educational feedback"""
	# Clear previous selection
	clear_selection()
	
	_selected_mesh = mesh
	_interaction_start_time = Time.get_unix_time_from_system()
	
	# Apply selection highlighting
	if highlight_enabled:
		_apply_highlight_material(mesh, SELECT_COLOR)
	
	# Position selection sphere
	if _selection_sphere:
		_selection_sphere.global_position = world_pos
		_selection_sphere.visible = true
	
	# Get structure information
	var structure_name = _get_structure_name(mesh)
	
	# Emit selection signal
	structure_selected.emit(structure_name, mesh)
	
	# Educational analytics
	if educational_mode and track_interactions:
		educational_interaction.emit("structure_selected", {
			"structure_name": structure_name,
			"selection_method": "right_click",
			"world_position": world_pos,
			"timestamp": Time.get_unix_time_from_system()
		})
	
	print("[BrainStructureSelectionManager] Selected: " + structure_name)

func _update_hover_state(new_mesh: MeshInstance3D, screen_pos: Vector2) -> void:
	"""Update hover state and tooltip display"""
	# Clear previous hover
	if _hovered_mesh and _hovered_mesh != _selected_mesh:
		_restore_original_material(_hovered_mesh)
	
	_hovered_mesh = new_mesh
	
	if _hovered_mesh:
		# Apply hover highlighting
		if highlight_enabled and _hovered_mesh != _selected_mesh:
			_apply_highlight_material(_hovered_mesh, HOVER_COLOR)
		
		# Show tooltip after delay
		if show_tooltips:
			_start_tooltip_timer(_hovered_mesh, screen_pos)
		
		# Emit hover signal
		var structure_name = _get_structure_name(_hovered_mesh)
		structure_hovered.emit(structure_name, _hovered_mesh)
	else:
		_hide_tooltip()

func _find_mesh_parent(node: Node) -> MeshInstance3D:
	"""Find the parent MeshInstance3D of a collider"""
	var current = node
	while current:
		if current is MeshInstance3D:
			return current
		current = current.get_parent()
	return null

func _get_structure_name(mesh: MeshInstance3D) -> String:
	"""Extract educational structure name from mesh"""
	if not mesh:
		return "Unknown"
	
	# Check for educational metadata first
	if mesh.has_meta("structure_name"):
		return mesh.get_meta("structure_name")
	
	# Fallback to node name with cleanup
	var structure_name = mesh.name
	structure_name = structure_name.replace("_mesh", "").replace("_Mesh", "")
	structure_name = structure_name.replace("_", " ").strip_edges()
	
	return structure_name if not structure_name.is_empty() else "Brain Structure"

func _setup_highlight_materials() -> void:
	"""Setup materials for educational highlighting"""
	_highlight_material = StandardMaterial3D.new()
	_highlight_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_highlight_material.flags_unshaded = true
	_highlight_material.flags_vertex_lighting = true
	_highlight_material.no_depth_test = true

func _setup_educational_ui() -> void:
	"""Setup educational tooltip UI"""
	if not educational_mode:
		return
	
	# Create tooltip container
	_tooltip_background = PanelContainer.new()
	_tooltip_background.name = "StructureTooltip"
	_tooltip_background.visible = false
	_tooltip_background.z_index = 100
	
	# Create tooltip label
	_tooltip_label = Label.new()
	_tooltip_label.text = ""
	_tooltip_label.add_theme_font_size_override("font_size", 14)
	_tooltip_background.add_child(_tooltip_label)
	
	# Add to scene
	get_viewport().add_child(_tooltip_background)
	
	# Setup hover timer
	_hover_timer = Timer.new()
	_hover_timer.wait_time = TOOLTIP_DELAY
	_hover_timer.one_shot = true
	_hover_timer.timeout.connect(_show_tooltip)
	add_child(_hover_timer)

func _apply_highlight_material(mesh: MeshInstance3D, color: Color) -> void:
	"""Apply educational highlight material to mesh"""
	if not mesh or not highlight_enabled:
		return
	
	# Store original material if not already stored
	if not _original_materials.has(mesh):
		_original_materials[mesh] = mesh.material_override
	
	# Apply highlight
	var highlight = _highlight_material.duplicate()
	highlight.albedo_color = color
	mesh.material_override = highlight

func _restore_original_material(mesh: MeshInstance3D) -> void:
	"""Restore original material for mesh"""
	if not mesh or not _original_materials.has(mesh):
		return
	
	mesh.material_override = _original_materials[mesh]
	_original_materials.erase(mesh)

func _start_tooltip_timer(mesh: MeshInstance3D, screen_pos: Vector2) -> void:
	"""Start timer for tooltip display"""
	_hover_timer.stop()
	
	# Store tooltip data
	set_meta("tooltip_mesh", mesh)
	set_meta("tooltip_position", screen_pos)
	
	_hover_timer.start()

func _show_tooltip() -> void:
	"""Show educational tooltip for hovered structure"""
	if not _tooltip_background or not has_meta("tooltip_mesh"):
		return
	
	var mesh = get_meta("tooltip_mesh")
	var screen_pos = get_meta("tooltip_position")
	
	if not mesh:
		return
	
	var structure_name = _get_structure_name(mesh)
	_tooltip_label.text = structure_name
	
	# Position tooltip near mouse
	_tooltip_background.position = screen_pos + Vector2(10, -30)
	_tooltip_background.visible = true

func _hide_tooltip() -> void:
	"""Hide educational tooltip"""
	if _tooltip_background:
		_tooltip_background.visible = false
	
	if _hover_timer:
		_hover_timer.stop()

func _ready() -> void:
	"""Node ready - setup initial state"""
	print("[BrainStructureSelectionManager] Structure selection manager ready")
	
	# Enable input processing
	set_process_unhandled_input(true)