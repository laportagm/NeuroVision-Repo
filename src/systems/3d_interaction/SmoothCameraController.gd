extends Node3D
class_name SmoothCameraController

## Professional smooth camera controller with inertia and advanced features

signal zoom_changed(distance: float)
signal rotation_changed(rotation: Vector2)

# === CONSTANTS ===
const MIN_ZOOM: float = 5.0
const MAX_ZOOM: float = 50.0
const ZOOM_SPEED: float = 0.1
const ROTATION_SPEED: float = 0.003
const PAN_SPEED: float = 0.001
const VERTICAL_ANGLE_LIMIT: float = 85.0

# === EXPORTS ===
@export_group("Camera Settings")
@export var initial_distance: float = 20.0
@export var initial_rotation: Vector2 = Vector2(deg_to_rad(-45), deg_to_rad(-30))
@export var fov: float = 45.0

@export_group("Smoothing")
@export var rotation_smoothing: float = 0.15
@export var zoom_smoothing: float = 0.2
@export var pan_smoothing: float = 0.15
@export var enable_inertia: bool = true
@export var inertia_decay: float = 0.85

@export_group("Input Settings")
@export var invert_x: bool = false
@export var invert_y: bool = false
@export var mouse_sensitivity: float = 1.0
@export var zoom_sensitivity: float = 1.0

# === NODES ===
@onready var camera: Camera3D = $Camera3D
@onready var pivot: Node3D = $Pivot

# === PRIVATE VARIABLES ===
var _current_distance: float
var _target_distance: float
var _current_rotation: Vector2
var _target_rotation: Vector2
var _current_pan: Vector3
var _target_pan: Vector3

var _rotation_velocity: Vector2 = Vector2.ZERO
var _pan_velocity: Vector3 = Vector3.ZERO
var _zoom_velocity: float = 0.0

var _is_rotating: bool = false
var _is_panning: bool = false
var _last_mouse_position: Vector2

var _focus_target: Node3D = null
var _is_focusing: bool = false
var _focus_progress: float = 0.0

# === PUBLIC METHODS ===

func _ready() -> void:
	_setup_camera()
	_current_distance = initial_distance
	_target_distance = initial_distance
	_current_rotation = initial_rotation
	_target_rotation = initial_rotation
	_current_pan = Vector3.ZERO
	_target_pan = Vector3.ZERO
	
	if not camera:
		camera = Camera3D.new()
		add_child(camera)
	
	if not pivot:
		pivot = Node3D.new()
		pivot.name = "Pivot"
		add_child(pivot)
		camera.reparent(pivot)
	
	camera.fov = fov
	_update_camera_transform()

func _process(delta: float) -> void:
	_handle_smooth_movement(delta)
	_handle_focus_animation(delta)
	_update_camera_transform()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event is InputEventMagnifyGesture:
		_handle_magnify_gesture(event)
	elif event is InputEventPanGesture:
		_handle_pan_gesture(event)

func reset_camera() -> void:
	"""Reset camera to initial position"""
	_target_distance = initial_distance
	_target_rotation = initial_rotation
	_target_pan = Vector3.ZERO
	_rotation_velocity = Vector2.ZERO
	_pan_velocity = Vector3.ZERO
	_zoom_velocity = 0.0
	_is_focusing = false

func focus_on_target(target: Node3D, distance: float = -1.0) -> void:
	"""Smoothly focus camera on target"""
	if not target:
		return
	
	_focus_target = target
	_is_focusing = true
	_focus_progress = 0.0
	
	# Calculate target position
	var target_pos = target.global_position
	_target_pan = target_pos
	
	# Calculate optimal distance if not specified
	if distance < 0:
		if target.has_method("get_aabb"):
			var aabb = target.get_aabb()
			var size = aabb.size.length()
			distance = size * 2.0
		else:
			distance = 15.0
	
	_target_distance = clamp(distance, MIN_ZOOM, MAX_ZOOM)

func set_rotation_limits(horizontal: float, vertical: float) -> void:
	"""Set rotation limits in degrees"""
	# Implementation for rotation limits if needed
	pass

func get_camera() -> Camera3D:
	"""Get the camera node"""
	return camera

func get_current_distance() -> float:
	"""Get current zoom distance"""
	return _current_distance

func get_current_rotation() -> Vector2:
	"""Get current rotation angles"""
	return _current_rotation

# === PRIVATE METHODS ===

func _setup_camera() -> void:
	"""Setup camera initial state"""
	set_process_unhandled_input(true)
	set_process(true)

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	"""Handle mouse button input"""
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			_is_rotating = event.pressed
			if event.pressed:
				_last_mouse_position = event.position
				Input.set_default_cursor_shape(Input.CURSOR_DRAG)
			else:
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		
		MOUSE_BUTTON_MIDDLE:
			_is_panning = event.pressed
			if event.pressed:
				_last_mouse_position = event.position
				Input.set_default_cursor_shape(Input.CURSOR_MOVE)
			else:
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		
		MOUSE_BUTTON_WHEEL_UP:
			if event.pressed:
				_zoom_velocity -= ZOOM_SPEED * zoom_sensitivity
		
		MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed:
				_zoom_velocity += ZOOM_SPEED * zoom_sensitivity

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	"""Handle mouse motion input"""
	var delta = event.position - _last_mouse_position
	_last_mouse_position = event.position
	
	if _is_rotating:
		var rotation_delta = delta * ROTATION_SPEED * mouse_sensitivity
		if invert_x:
			rotation_delta.x *= -1
		if invert_y:
			rotation_delta.y *= -1
		
		_rotation_velocity = rotation_delta
		_target_rotation.x -= rotation_delta.x
		_target_rotation.y -= rotation_delta.y
		_target_rotation.y = clamp(_target_rotation.y, -deg_to_rad(VERTICAL_ANGLE_LIMIT), deg_to_rad(VERTICAL_ANGLE_LIMIT))
	
	elif _is_panning:
		var pan_delta = delta * PAN_SPEED * _current_distance
		var right = camera.global_transform.basis.x
		var up = camera.global_transform.basis.y
		
		_pan_velocity = -right * pan_delta.x + up * pan_delta.y
		_target_pan += _pan_velocity

func _handle_magnify_gesture(event: InputEventMagnifyGesture) -> void:
	"""Handle trackpad pinch zoom"""
	var zoom_delta = (1.0 - event.factor) * zoom_sensitivity
	_zoom_velocity += zoom_delta * 10.0

func _handle_pan_gesture(event: InputEventPanGesture) -> void:
	"""Handle trackpad pan gesture"""
	var rotation_delta = event.delta * ROTATION_SPEED * mouse_sensitivity * 0.5
	if invert_x:
		rotation_delta.x *= -1
	if invert_y:
		rotation_delta.y *= -1
	
	_rotation_velocity = rotation_delta
	_target_rotation.x -= rotation_delta.x
	_target_rotation.y += rotation_delta.y
	_target_rotation.y = clamp(_target_rotation.y, -deg_to_rad(VERTICAL_ANGLE_LIMIT), deg_to_rad(VERTICAL_ANGLE_LIMIT))

func _handle_smooth_movement(delta: float) -> void:
	"""Handle smooth camera movement with inertia"""
	# Apply zoom velocity
	if abs(_zoom_velocity) > 0.001:
		_target_distance += _zoom_velocity
		_target_distance = clamp(_target_distance, MIN_ZOOM, MAX_ZOOM)
		
		if enable_inertia and not Input.is_action_pressed("ui_accept"):
			_zoom_velocity *= inertia_decay
		else:
			_zoom_velocity = 0.0
	
	# Apply rotation velocity with inertia
	if enable_inertia and not _is_rotating and _rotation_velocity.length() > 0.001:
		_target_rotation -= _rotation_velocity
		_target_rotation.y = clamp(_target_rotation.y, -deg_to_rad(VERTICAL_ANGLE_LIMIT), deg_to_rad(VERTICAL_ANGLE_LIMIT))
		_rotation_velocity *= inertia_decay
	elif not _is_rotating:
		_rotation_velocity = Vector2.ZERO
	
	# Apply pan velocity with inertia
	if enable_inertia and not _is_panning and _pan_velocity.length() > 0.001:
		_target_pan += _pan_velocity * delta * 60.0
		_pan_velocity *= inertia_decay
	elif not _is_panning:
		_pan_velocity = Vector3.ZERO
	
	# Smooth interpolation
	_current_distance = lerp(_current_distance, _target_distance, zoom_smoothing)
	_current_rotation = _current_rotation.lerp(_target_rotation, rotation_smoothing)
	_current_pan = _current_pan.lerp(_target_pan, pan_smoothing)
	
	# Emit signals
	zoom_changed.emit(_current_distance)
	rotation_changed.emit(_current_rotation)

func _handle_focus_animation(delta: float) -> void:
	"""Handle smooth focus animation"""
	if not _is_focusing:
		return
	
	_focus_progress += delta * 2.0
	if _focus_progress >= 1.0:
		_focus_progress = 1.0
		_is_focusing = false
	
	# Smooth ease-in-out curve
	var t = _focus_progress * _focus_progress * (3.0 - 2.0 * _focus_progress)
	
	if _focus_target and is_instance_valid(_focus_target):
		var target_pos = _focus_target.global_position
		_target_pan = _target_pan.lerp(target_pos, t)

func _update_camera_transform() -> void:
	"""Update camera position and rotation"""
	# Update pivot position
	pivot.position = _current_pan
	
	# Update pivot rotation
	pivot.rotation = Vector3(_current_rotation.y, _current_rotation.x, 0)
	
	# Update camera distance
	camera.position = Vector3(0, 0, _current_distance)