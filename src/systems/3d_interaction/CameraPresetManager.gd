extends Node

## Manages educational camera presets for optimal viewing angles

signal preset_changed(preset_name: String)
signal transition_complete()

# === CONSTANTS ===
const TRANSITION_DURATION: float = 1.0
const CAMERA_DISTANCE: float = 7.0

enum CameraPreset {
	ANTERIOR,      # Front view
	POSTERIOR,     # Back view
	LATERAL_RIGHT, # Right side
	LATERAL_LEFT,  # Left side
	SUPERIOR,      # Top view
	INFERIOR,      # Bottom view
	OBLIQUE_1,     # Clinical angle 1
	OBLIQUE_2,     # Clinical angle 2
	FOCUS_CURRENT  # Focus on selected structure
}

# === PRESET CONFIGURATIONS ===
const PRESET_DATA = {
	CameraPreset.ANTERIOR: {
		"name": "Anterior (Front)",
		"position": Vector3(0, 0, CAMERA_DISTANCE),
		"rotation": Vector3(0, 0, 0),
		"description": "Standard frontal view showing frontal lobes and anterior structures"
	},
	CameraPreset.POSTERIOR: {
		"name": "Posterior (Back)",
		"position": Vector3(0, 0, -CAMERA_DISTANCE),
		"rotation": Vector3(0, PI, 0),
		"description": "Rear view showing occipital lobes and posterior structures"
	},
	CameraPreset.LATERAL_RIGHT: {
		"name": "Right Lateral",
		"position": Vector3(CAMERA_DISTANCE, 0, 0),
		"rotation": Vector3(0, PI/2, 0),
		"description": "Right hemisphere view showing temporal and parietal regions"
	},
	CameraPreset.LATERAL_LEFT: {
		"name": "Left Lateral",
		"position": Vector3(-CAMERA_DISTANCE, 0, 0),
		"rotation": Vector3(0, -PI/2, 0),
		"description": "Left hemisphere view, traditional for language areas"
	},
	CameraPreset.SUPERIOR: {
		"name": "Superior (Top)",
		"position": Vector3(0, CAMERA_DISTANCE, 0),
		"rotation": Vector3(-PI/2, 0, 0),
		"description": "Top-down view showing both hemispheres and longitudinal fissure"
	},
	CameraPreset.INFERIOR: {
		"name": "Inferior (Bottom)",
		"position": Vector3(0, -CAMERA_DISTANCE, 0),
		"rotation": Vector3(PI/2, 0, 0),
		"description": "Bottom view showing brainstem and cranial nerve origins"
	},
	CameraPreset.OBLIQUE_1: {
		"name": "Clinical View 1",
		"position": Vector3(5, 3, 4),
		"rotation": Vector3(-0.4, 0.6, 0),
		"description": "Three-quarter view commonly used in clinical imaging"
	},
	CameraPreset.OBLIQUE_2: {
		"name": "Clinical View 2",
		"position": Vector3(-5, 2, -4),
		"rotation": Vector3(-0.3, -2.4, 0),
		"description": "Alternative clinical angle for structure relationships"
	}
}

# === PRIVATE VARIABLES ===
var _camera: Camera3D = null
var _target_position: Vector3 = Vector3.ZERO
var _current_preset: CameraPreset = CameraPreset.ANTERIOR
var _tween: Tween = null
var _is_transitioning: bool = false
var _camera_pivot: Node3D = null

# === PUBLIC METHODS ===

func initialize(camera: Camera3D, target: Node3D = null) -> void:
	"""Initialize the camera preset manager"""
	_camera = camera
	_target_position = target.global_position if target else Vector3.ZERO
	
	# Create a pivot node for camera rotation
	_camera_pivot = Node3D.new()
	_camera_pivot.name = "CameraPivot"
	_camera_pivot.position = _target_position
	
	if _camera.get_parent():
		_camera.get_parent().add_child(_camera_pivot)
		_camera.get_parent().remove_child(_camera)
		_camera_pivot.add_child(_camera)
	
	print("[CameraPresets] Initialized with %d presets" % PRESET_DATA.size())

func apply_preset(preset: CameraPreset, instant: bool = false) -> void:
	"""Apply a camera preset"""
	if not _camera or _is_transitioning:
		return
	
	if not PRESET_DATA.has(preset):
		push_error("[CameraPresets] Invalid preset: " + str(preset))
		return
	
	var preset_data = PRESET_DATA[preset]
	_current_preset = preset
	
	if instant:
		_apply_preset_instant(preset_data)
	else:
		_apply_preset_smooth(preset_data)
	
	preset_changed.emit(preset_data.name)

func focus_on_structure(structure_node: Node3D, distance: float = 5.0) -> void:
	"""Focus camera on a specific structure"""
	if not _camera or not structure_node:
		return
	
	# Calculate bounding box
	var aabb = _calculate_node_aabb(structure_node)
	var center = aabb.get_center()
	var size = aabb.size.length()
	
	# Calculate optimal distance
	var fov_rad = deg_to_rad(_camera.fov)
	var optimal_distance = (size * 0.5) / tan(fov_rad * 0.5) * 1.5
	optimal_distance = max(optimal_distance, distance)
	
	# Set target position
	_target_position = structure_node.global_position + center
	_camera_pivot.position = _target_position
	
	# Apply focus preset
	var focus_data = {
		"name": "Focus: " + structure_node.name,
		"position": Vector3(0, optimal_distance * 0.3, optimal_distance),
		"rotation": Vector3(-0.3, 0, 0),
		"description": "Focused view on selected structure"
	}
	
	_apply_preset_smooth(focus_data)

func get_current_preset() -> CameraPreset:
	"""Get the current camera preset"""
	return _current_preset

func get_preset_name(preset: CameraPreset) -> String:
	"""Get the display name for a preset"""
	if PRESET_DATA.has(preset):
		return PRESET_DATA[preset].name
	return "Unknown"

func get_preset_description(preset: CameraPreset) -> String:
	"""Get the educational description for a preset"""
	if PRESET_DATA.has(preset):
		return PRESET_DATA[preset].description
	return ""

func cycle_presets(forward: bool = true) -> void:
	"""Cycle through camera presets"""
	var preset_values = CameraPreset.values()
	preset_values.erase(CameraPreset.FOCUS_CURRENT)  # Don't cycle to focus
	
	var current_index = preset_values.find(_current_preset)
	if current_index == -1:
		current_index = 0
	
	if forward:
		current_index = (current_index + 1) % preset_values.size()
	else:
		current_index = (current_index - 1) % preset_values.size()
	
	apply_preset(preset_values[current_index])

# === PRIVATE METHODS ===

func _apply_preset_instant(preset_data: Dictionary) -> void:
	"""Apply preset immediately"""
	_camera.position = preset_data.position
	_camera_pivot.rotation = preset_data.rotation
	_camera.look_at(_target_position, Vector3.UP)

func _apply_preset_smooth(preset_data: Dictionary) -> void:
	"""Apply preset with smooth transition"""
	if _tween:
		_tween.kill()
	
	_is_transitioning = true
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	
	# Animate position and rotation
	_tween.parallel().tween_property(_camera, "position", preset_data.position, TRANSITION_DURATION)
	_tween.parallel().tween_property(_camera_pivot, "rotation", preset_data.rotation, TRANSITION_DURATION)
	
	# Look at target during transition
	_tween.tween_method(_update_camera_look_at, 0.0, 1.0, TRANSITION_DURATION)
	
	# Signal completion
	_tween.tween_callback(func():
		_is_transitioning = false
		transition_complete.emit()
	)

func _update_camera_look_at(_progress: float) -> void:
	"""Update camera look at during transition"""
	if _camera:
		_camera.look_at(_target_position, Vector3.UP)

func _calculate_node_aabb(node: Node3D) -> AABB:
	"""Calculate the AABB of a node and its children"""
	var aabb = AABB()
	var first = true
	
	var queue = [node]
	while queue.size() > 0:
		var current = queue.pop_front()
		
		if current is MeshInstance3D and current.mesh:
			var mesh_aabb = current.mesh.get_aabb()
			mesh_aabb = current.global_transform * mesh_aabb
			
			if first:
				aabb = mesh_aabb
				first = false
			else:
				aabb = aabb.merge(mesh_aabb)
		
		for child in current.get_children():
			if child is Node3D:
				queue.append(child)
	
	return aabb