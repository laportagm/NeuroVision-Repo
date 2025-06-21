## Brain Interaction Controller for NeuroVision
##
## Manages user interactions with 3D brain structures including selection,
## highlighting, and educational information display. Optimized for Intel UHD 620.

class_name BrainInteractionController
extends Node3D

# === SIGNALS ===
signal structure_selected(structure_id: String, world_position: Vector3)
signal structure_highlighted(structure_id: String)
signal structure_unhighlighted(structure_id: String)
signal interaction_started()
signal interaction_ended()

# === CONSTANTS ===
const RAY_LENGTH: float = 1000.0
const HOVER_HIGHLIGHT_INTENSITY: float = 0.3
const SELECTION_HIGHLIGHT_INTENSITY: float = 0.6
const INTERACTION_COOLDOWN: float = 0.1  # Prevent rapid selections

# === EXPORTS ===
@export_group("Interaction Settings")
@export var enable_hover_highlight: bool = true
@export var enable_selection_feedback: bool = true
@export var enable_accessibility_announcements: bool = true
@export var interaction_distance_limit: float = 50.0

@export_group("Performance")
@export var use_simplified_raycasts: bool = false  # For Intel UHD 620
@export var max_raycast_per_frame: int = 1  # Limit raycasts for performance

# === PRIVATE VARIABLES ===
var _camera: Camera3D
var _current_highlighted_structure: String = ""
var _current_selected_structure: String = ""
var _interaction_cooldown_timer: float = 0.0
var _raycast_accumulator: float = 0.0
var _brain_structures: Dictionary = {}  # structure_id -> Node3D
var _is_interaction_enabled: bool = true
var _last_mouse_position: Vector2 = Vector2.ZERO

# === AUTOLOAD REFERENCES ===
var _highlight_manager: Node
var _knowledge_service: Node
var _progress_tracker: Node

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[BrainInteractionController] Initializing interaction system")
	
	# Get autoload references
	_highlight_manager = get_node_or_null("/root/HighlightMaterialManager")
	_knowledge_service = get_node_or_null("/root/KnowledgeService")
	_progress_tracker = get_node_or_null("/root/ProgressTracker")
	
	# Validate dependencies
	if not _highlight_manager:
		push_error("[BrainInteraction] HighlightMaterialManager not found!")
		return
	
	# Performance optimization for Intel UHD 620
	var graphics_mgr = get_node_or_null("/root/GraphicsOptimizationManager")
	if graphics_mgr:
		var settings = graphics_mgr.get_current_settings()
		# Check if using integrated graphics quality preset (0 = INTEGRATED_LOW, 1 = INTEGRATED_MEDIUM)
		if settings.has("quality_preset") and settings.quality_preset <= 1:
			use_simplified_raycasts = true
			max_raycast_per_frame = 1
			print("[BrainInteraction] Low quality preset detected - using simplified raycasts")

func _process(delta: float) -> void:
	if not _is_interaction_enabled:
		return
		
	# Update cooldown timer
	if _interaction_cooldown_timer > 0:
		_interaction_cooldown_timer -= delta
	
	# Accumulate time for raycast throttling (performance optimization)
	_raycast_accumulator += delta
	if _raycast_accumulator >= (1.0 / float(max_raycast_per_frame)):
		_process_hover_detection()
		_raycast_accumulator = 0.0

func initialize(camera: Camera3D, brain_structures: Dictionary) -> void:
	"""Initialize the interaction system with camera and brain structures"""
	_camera = camera
	_brain_structures = brain_structures
	_is_interaction_enabled = true
	
	print("[BrainInteraction] Initialized with %d brain structures" % brain_structures.size())

func set_interaction_enabled(enabled: bool) -> void:
	"""Enable or disable all interactions"""
	_is_interaction_enabled = enabled
	if not enabled:
		clear_highlights()

func handle_selection_input(mouse_position: Vector2) -> bool:
	"""Handle structure selection from mouse click"""
	if not _is_interaction_enabled or _interaction_cooldown_timer > 0:
		return false
		
	var result = _perform_raycast(mouse_position)
	if result.is_empty():
		# Clicked on empty space - deselect
		if _current_selected_structure != "":
			_deselect_current_structure()
		return false
	
	var structure_id = _get_structure_id_from_collision(result.collider)
	if structure_id == "":
		return false
		
	# Select the structure
	_select_structure(structure_id, result.position)
	_interaction_cooldown_timer = INTERACTION_COOLDOWN
	
	return true

func get_current_selection() -> String:
	"""Get the currently selected structure ID"""
	return _current_selected_structure

func select_structure_by_id(structure_id: String) -> void:
	"""Programmatically select a structure by its ID"""
	if not _brain_structures.has(structure_id):
		push_warning("[BrainInteraction] Unknown structure ID: " + structure_id)
		return
		
	var structure_node = _brain_structures[structure_id]
	if structure_node:
		var world_pos = structure_node.global_transform.origin
		_select_structure(structure_id, world_pos)

func clear_highlights() -> void:
	"""Clear all highlights and selections"""
	if _current_highlighted_structure != "":
		_unhighlight_structure(_current_highlighted_structure)
	if _current_selected_structure != "":
		_deselect_current_structure()

# === PRIVATE METHODS ===

func _process_hover_detection() -> void:
	"""Process hover detection with mouse movement"""
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Only process if mouse moved significantly (performance optimization)
	if mouse_pos.distance_to(_last_mouse_position) < 2.0:
		return
	_last_mouse_position = mouse_pos
	
	if not enable_hover_highlight:
		return
		
	var result = _perform_raycast(mouse_pos)
	if result.is_empty():
		# No hit - clear highlight
		if _current_highlighted_structure != "":
			_unhighlight_structure(_current_highlighted_structure)
		return
	
	var structure_id = _get_structure_id_from_collision(result.collider)
	if structure_id == "" or structure_id == _current_selected_structure:
		return
		
	# Update highlight
	if structure_id != _current_highlighted_structure:
		if _current_highlighted_structure != "":
			_unhighlight_structure(_current_highlighted_structure)
		_highlight_structure(structure_id)

func _perform_raycast(mouse_position: Vector2) -> Dictionary:
	"""Perform a raycast from camera through mouse position"""
	if not _camera:
		return {}
		
	var from = _camera.project_ray_origin(mouse_position)
	var to = from + _camera.project_ray_normal(mouse_position) * RAY_LENGTH
	
	# Use simplified raycast for low-end GPUs
	if use_simplified_raycasts:
		return _perform_simplified_raycast(from, to)
	else:
		return _perform_full_raycast(from, to)

func _perform_full_raycast(from: Vector3, to: Vector3) -> Dictionary:
	"""Perform full physics raycast"""
	var space_state = _camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1  # Only check layer 1 (brain structures)
	query.collide_with_areas = true
	
	return space_state.intersect_ray(query)

func _perform_simplified_raycast(from: Vector3, to: Vector3) -> Dictionary:
	"""Perform simplified raycast for better performance"""
	# For low-end GPUs, we check against bounding boxes first
	var closest_distance = INF
	var closest_structure = null
	
	for structure_id in _brain_structures:
		var structure = _brain_structures[structure_id]
		if not structure:
			continue
			
		# Simple distance check first
		var distance = structure.global_position.distance_to(from)
		if distance > interaction_distance_limit:
			continue
			
		# Simplified bounding box check
		if _is_ray_intersecting_structure(from, to, structure):
			if distance < closest_distance:
				closest_distance = distance
				closest_structure = structure
	
	if closest_structure:
		return {
			"collider": closest_structure,
			"position": closest_structure.global_position
		}
	
	return {}

func _is_ray_intersecting_structure(from: Vector3, to: Vector3, structure: Node3D) -> bool:
	"""Simplified ray-structure intersection test"""
	# This is a simplified check - just checks if ray passes near the structure
	var structure_pos = structure.global_position
	var ray_dir = (to - from).normalized()
	var to_structure = structure_pos - from
	
	# Project structure position onto ray
	var projection = to_structure.dot(ray_dir)
	if projection < 0 or projection > from.distance_to(to):
		return false
		
	# Check perpendicular distance
	var closest_point = from + ray_dir * projection
	var distance = closest_point.distance_to(structure_pos)
	
	# Use a generous threshold for simplified detection
	return distance < 2.0

func _get_structure_id_from_collision(collider: Node) -> String:
	"""Extract structure ID from collision object"""
	if not collider:
		return ""
		
	# Check if collider has structure_id metadata
	if collider.has_meta("structure_id"):
		return collider.get_meta("structure_id")
	
	# Check parent nodes
	var parent = collider.get_parent()
	while parent:
		if parent.has_meta("structure_id"):
			return parent.get_meta("structure_id")
		parent = parent.get_parent()
	
	# Fallback: try to match by name
	for structure_id in _brain_structures:
		if _brain_structures[structure_id] == collider or collider.is_ancestor_of(_brain_structures[structure_id]):
			return structure_id
	
	return ""

func _select_structure(structure_id: String, world_position: Vector3) -> void:
	"""Select a brain structure"""
	# Deselect previous
	if _current_selected_structure != "":
		_deselect_current_structure()
	
	_current_selected_structure = structure_id
	
	# Apply selection highlight
	if _highlight_manager:
		_highlight_manager.highlight_structure(structure_id, SELECTION_HIGHLIGHT_INTENSITY)
	
	# Track interaction
	if _progress_tracker:
		_progress_tracker.track_structure_interaction(structure_id)
	
	# Announce for accessibility
	if enable_accessibility_announcements:
		_announce_structure_selection(structure_id)
	
	# Emit signals
	interaction_started.emit()
	structure_selected.emit(structure_id, world_position)
	
	print("[BrainInteraction] Selected structure: " + structure_id)

func _deselect_current_structure() -> void:
	"""Deselect the current structure"""
	if _current_selected_structure == "":
		return
		
	var structure_id = _current_selected_structure
	_current_selected_structure = ""
	
	# Remove highlight
	if _highlight_manager:
		_highlight_manager.remove_highlight(structure_id)
	
	# Re-apply hover highlight if still hovering
	if _current_highlighted_structure == structure_id and enable_hover_highlight:
		_highlight_structure(structure_id)
	
	# Emit interaction ended signal
	interaction_ended.emit()

func _highlight_structure(structure_id: String) -> void:
	"""Apply hover highlight to structure"""
	_current_highlighted_structure = structure_id
	
	if _highlight_manager and structure_id != _current_selected_structure:
		_highlight_manager.highlight_structure(structure_id, HOVER_HIGHLIGHT_INTENSITY)
	
	structure_highlighted.emit(structure_id)

func _unhighlight_structure(structure_id: String) -> void:
	"""Remove hover highlight from structure"""
	if structure_id == _current_highlighted_structure:
		_current_highlighted_structure = ""
	
	if _highlight_manager and structure_id != _current_selected_structure:
		_highlight_manager.remove_highlight(structure_id)
	
	structure_unhighlighted.emit(structure_id)

func _announce_structure_selection(structure_id: String) -> void:
	"""Announce structure selection for screen readers"""
	if not OS.has_feature("web"):  # Godot's accessibility is limited
		return
		
	var structure_name = structure_id.replace("_", " ").capitalize()
	
	# Try to get proper name from knowledge service
	if _knowledge_service:
		var data = _knowledge_service.get_structure(structure_id)
		if data and data.has("display_name"):
			structure_name = data.display_name
	
	# This would integrate with screen reader in a full implementation
	print("[Accessibility] Selected: " + structure_name)