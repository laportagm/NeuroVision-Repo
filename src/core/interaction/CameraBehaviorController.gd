## CameraBehaviorController.gd
## Educational camera behavior system for NeuroVision brain exploration
##
## Provides smooth camera controls optimized for educational 3D brain model exploration
## with preset views, smooth transitions, and accessibility features.

class_name CameraBehaviorController
extends Node

# === SIGNALS ===
signal camera_moved(new_position: Vector3, new_rotation: Vector3)
signal preset_activated(preset_name: String)
signal focus_completed(target_bounds: AABB)

# === CONSTANTS ===
const DEFAULT_ZOOM_SPEED: float = 5.0
const DEFAULT_ORBIT_SPEED: float = 2.0
const DEFAULT_TRANSITION_DURATION: float = 1.0
const MIN_ZOOM_DISTANCE: float = 2.0
const MAX_ZOOM_DISTANCE: float = 50.0

# Camera presets for educational viewing
const CAMERA_PRESETS = {
	"anterior": {"position": Vector3(0, 0, 10), "rotation": Vector3(0, 0, 0)},
	"posterior": {"position": Vector3(0, 0, -10), "rotation": Vector3(0, 180, 0)},
	"right_lateral": {"position": Vector3(10, 0, 0), "rotation": Vector3(0, 90, 0)},
	"left_lateral": {"position": Vector3(-10, 0, 0), "rotation": Vector3(0, -90, 0)},
	"superior": {"position": Vector3(0, 10, 0), "rotation": Vector3(-90, 0, 0)},
	"inferior": {"position": Vector3(0, -10, 0), "rotation": Vector3(90, 0, 0)},
	"clinical_1": {"position": Vector3(7, 5, 7), "rotation": Vector3(-30, 45, 0)},
	"clinical_2": {"position": Vector3(-7, 5, 7), "rotation": Vector3(-30, -45, 0)}
}

# === PRIVATE VARIABLES ===
var _camera: Camera3D
var _camera_pivot: Node3D
var _is_initialized: bool = false
var _zoom_distance: float = 10.0
var _orbit_speed: float = DEFAULT_ORBIT_SPEED
var _zoom_speed: float = DEFAULT_ZOOM_SPEED
var _transition_tween: Tween

# Mouse interaction state
var _is_orbiting: bool = false
var _last_mouse_position: Vector2

# === PUBLIC METHODS ===

func initialize(camera: Camera3D, pivot: Node3D) -> bool:
	"""Initialize the camera controller with camera and pivot nodes"""
	if not camera or not pivot:
		push_error("[CameraBehaviorController] Invalid camera or pivot node")
		return false
	
	_camera = camera
	_camera_pivot = pivot
	_zoom_distance = _camera.position.length()
	_is_initialized = true
	
	print("[CameraBehaviorController] Initialized with camera and pivot")
	return true

func set_camera_preset(preset_name: String) -> bool:
	"""Apply a named camera preset for educational viewing"""
	if not _is_initialized:
		push_error("[CameraBehaviorController] Not initialized")
		return false
	
	if not CAMERA_PRESETS.has(preset_name):
		push_warning("[CameraBehaviorController] Unknown preset: " + preset_name)
		return false
	
	var preset = CAMERA_PRESETS[preset_name]
	_transition_to_position(preset.position, preset.rotation)
	
	preset_activated.emit(preset_name)
	print("[CameraBehaviorController] Applied preset: " + preset_name)
	return true

func focus_on_bounds(bounds: AABB) -> void:
	"""Focus camera on specific bounds with smooth transition"""
	if not _is_initialized:
		return
	
	var center = bounds.get_center()
	var size = bounds.size.length()
	var distance = size * 1.5  # Comfortable viewing distance
	
	# Calculate optimal camera position
	var camera_pos = Vector3(0, 0, distance)
	
	_camera_pivot.position = center
	_transition_to_position(camera_pos, Vector3.ZERO)
	
	focus_completed.emit(bounds)

func orbit_camera(delta_x: float, delta_y: float) -> void:
	"""Orbit camera around the pivot point"""
	if not _is_initialized:
		return
	
	# Rotate pivot for orbital movement
	_camera_pivot.rotate_y(-delta_x * _orbit_speed * 0.01)
	_camera_pivot.rotate_object_local(Vector3.RIGHT, -delta_y * _orbit_speed * 0.01)
	
	# Clamp vertical rotation to prevent flipping
	var rotation = _camera_pivot.rotation_degrees
	rotation.x = clamp(rotation.x, -85, 85)
	_camera_pivot.rotation_degrees = rotation
	
	camera_moved.emit(_camera.global_position, _camera.global_rotation_degrees)

func zoom_camera(zoom_delta: float) -> void:
	"""Zoom camera in/out with distance limits"""
	if not _is_initialized:
		return
	
	_zoom_distance += zoom_delta * _zoom_speed
	_zoom_distance = clamp(_zoom_distance, MIN_ZOOM_DISTANCE, MAX_ZOOM_DISTANCE)
	
	# Apply zoom by moving camera along its local Z axis
	var camera_local_pos = _camera.position
	camera_local_pos.z = _zoom_distance
	_camera.position = camera_local_pos
	
	camera_moved.emit(_camera.global_position, _camera.global_rotation_degrees)

func reset_camera() -> void:
	"""Reset camera to default educational viewing position"""
	set_camera_preset("anterior")

func set_orbit_speed(speed: float) -> void:
	"""Set camera orbit sensitivity"""
	_orbit_speed = clamp(speed, 0.1, 10.0)

func set_zoom_speed(speed: float) -> void:
	"""Set camera zoom sensitivity"""
	_zoom_speed = clamp(speed, 0.1, 20.0)

func get_camera_info() -> Dictionary:
	"""Get current camera information for educational UI"""
	if not _is_initialized:
		return {}
	
	return {
		"position": _camera.global_position,
		"rotation": _camera.global_rotation_degrees,
		"zoom_distance": _zoom_distance,
		"fov": _camera.fov,
		"is_initialized": _is_initialized
	}

# === INPUT HANDLING ===

func _unhandled_input(event: InputEvent) -> void:
	"""Handle camera input events"""
	if not _is_initialized:
		return
	
	# Mouse orbit controls
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_is_orbiting = event.pressed
			if event.pressed:
				_last_mouse_position = event.position
	
	elif event is InputEventMouseMotion and _is_orbiting:
		var delta = event.position - _last_mouse_position
		orbit_camera(delta.x, delta.y)
		_last_mouse_position = event.position
	
	# Mouse wheel zoom
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(-1.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(1.0)
	
	# Keyboard shortcuts for camera presets
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				set_camera_preset("anterior")
			KEY_2:
				set_camera_preset("posterior")
			KEY_3:
				set_camera_preset("right_lateral")
			KEY_4:
				set_camera_preset("left_lateral")
			KEY_5:
				set_camera_preset("superior")
			KEY_6:
				set_camera_preset("inferior")
			KEY_7:
				set_camera_preset("clinical_1")
			KEY_8:
				set_camera_preset("clinical_2")
			KEY_R:
				reset_camera()

# === PRIVATE METHODS ===

func _transition_to_position(target_pos: Vector3, target_rot: Vector3) -> void:
	"""Smoothly transition camera to target position and rotation"""
	if _transition_tween:
		_transition_tween.kill()
	
	_transition_tween = create_tween()
	_transition_tween.set_parallel(true)
	
	# Animate camera position
	_transition_tween.tween_property(_camera, "position", target_pos, DEFAULT_TRANSITION_DURATION)
	_transition_tween.tween_property(_camera, "rotation_degrees", target_rot, DEFAULT_TRANSITION_DURATION)
	
	# Update zoom distance to match new position
	_zoom_distance = target_pos.length()

func _ready() -> void:
	"""Node ready - setup initial state"""
	print("[CameraBehaviorController] Camera behavior controller ready")
	
	# Enable input processing
	set_process_unhandled_input(true)