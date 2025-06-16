## ButtonAnimator.gd
## Handles advanced button animations and effects
##
## This class encapsulates all animation logic for buttons including:
## - Tactile press animations
## - Material Design ripple effects
## - Elevation changes
## - Spring-back animations
## - Performance optimizations

class_name ButtonAnimator
extends Node

# === EXPORT VARIABLES ===
@export var button: NVBaseButton
@export var press_scale_factor: float = 0.95
@export var press_duration: float = 0.08
@export var release_duration: float = 0.12
@export var hover_elevation: int = 2
@export var ripple_max_scale: float = 2.0
@export var ripple_duration: float = 0.6

# === PRIVATE VARIABLES ===
var _enabled: bool = true
var _original_scale: Vector2
var _original_position: Vector2
var _original_modulate: Color
var _is_animating: bool = false

var _hover_tween: Tween
var _press_tween: Tween
var _ripple_container: Control
var _active_ripples: Array = []

# Performance optimization
var _reduce_motion: bool = false
var _last_animation_time: float = 0.0
var _min_animation_interval: float = 16.67  # 60 FPS

# === INITIALIZATION ===

func _ready() -> void:
	"""Initialize animator"""
	if not button:
		push_error("[ButtonAnimator] No button assigned")
		return
	
	_store_original_values()
	_check_reduce_motion()
	_setup_ripple_container()

func _store_original_values() -> void:
	"""Store button's original values"""
	_original_scale = button.scale
	_original_position = button.position
	_original_modulate = button.modulate

func _check_reduce_motion() -> void:
	"""Check if user prefers reduced motion"""
	# Check OS accessibility settings
	if OS.has_feature("web"):
		# Check browser preference
		if ClassDB.class_exists("JavaScriptBridge"):
			var js = Engine.get_singleton("JavaScriptBridge")
			if js:
				var window = js.get_interface("window")
				if window:
					var media_query = window.matchMedia("(prefers-reduced-motion: reduce)")
					if media_query and media_query.matches:
						_reduce_motion = true

func _setup_ripple_container() -> void:
	"""Create container for ripple effects"""
	_ripple_container = Control.new()
	_ripple_container.name = "RippleContainer"
	_ripple_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ripple_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ripple_container.clip_contents = true
	button.add_child(_ripple_container)
	button.move_child(_ripple_container, 0)  # Put behind button content

# === PUBLIC METHODS ===

func set_enabled(enabled: bool) -> void:
	"""Enable or disable all animations"""
	_enabled = enabled
	if not enabled:
		_kill_all_tweens()

func animate_hover_enter() -> void:
	"""Animate hover enter state"""
	if not _enabled or _reduce_motion:
		return
	
	if not _check_animation_throttle():
		return
	
	_kill_tween(_hover_tween)
	_hover_tween = create_tween()
	_hover_tween.set_parallel(true)
	_hover_tween.set_trans(Tween.TRANS_CUBIC)
	_hover_tween.set_ease(Tween.EASE_OUT)
	
	# Subtle scale increase
	var hover_scale = _original_scale * 1.02
	_hover_tween.tween_property(button, "scale", hover_scale, 0.12)
	
	# Elevation effect
	if hover_elevation > 0:
		var elevated_pos = _original_position + Vector2(0, -hover_elevation)
		_hover_tween.tween_property(button, "position", elevated_pos, 0.12)
		
		# Add shadow effect (simplified for performance)
		var shadow_modulate = _original_modulate
		shadow_modulate = shadow_modulate.lightened(0.05)
		_hover_tween.tween_property(button, "modulate", shadow_modulate, 0.12)

func animate_hover_exit() -> void:
	"""Animate hover exit state"""
	if not _enabled or _reduce_motion:
		return
	
	_kill_tween(_hover_tween)
	_hover_tween = create_tween()
	_hover_tween.set_parallel(true)
	_hover_tween.set_trans(Tween.TRANS_CUBIC)
	_hover_tween.set_ease(Tween.EASE_OUT)
	
	# Return to original state
	_hover_tween.tween_property(button, "scale", _original_scale, 0.12)
	_hover_tween.tween_property(button, "position", _original_position, 0.12)
	_hover_tween.tween_property(button, "modulate", _original_modulate, 0.12)

func animate_press() -> void:
	"""Animate button press"""
	if not _enabled:
		return
	
	# Always allow press animation for tactile feedback
	_kill_tween(_press_tween)
	_press_tween = create_tween()
	_press_tween.set_trans(Tween.TRANS_CUBIC)
	_press_tween.set_ease(Tween.EASE_OUT)
	
	# Scale down for tactile feedback
	var press_scale = _original_scale * press_scale_factor
	_press_tween.tween_property(button, "scale", press_scale, press_duration)
	
	# Start ripple effect
	if not _reduce_motion:
		create_ripple_at_mouse()

func animate_release() -> void:
	"""Animate button release with spring-back"""
	if not _enabled:
		return
	
	_kill_tween(_press_tween)
	_press_tween = create_tween()
	_press_tween.set_trans(Tween.TRANS_SPRING)
	_press_tween.set_ease(Tween.EASE_OUT)
	
	# Spring back to original scale
	_press_tween.tween_property(button, "scale", _original_scale, release_duration)

func create_ripple_at_mouse() -> void:
	"""Create ripple effect at mouse position"""
	if not _enabled or not _ripple_container:
		return
	
	create_ripple_at_position(button.get_local_mouse_position())

func create_ripple_at_position(position: Vector2) -> void:
	"""Create ripple effect at specific position"""
	if not _enabled or not _ripple_container:
		return
	
	# Limit active ripples for performance
	if _active_ripples.size() > 3:
		var oldest = _active_ripples.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()
	
	# Create ripple
	var ripple = ColorRect.new()
	ripple.name = "Ripple"
	ripple.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Get ripple color from theme or use default
	var ripple_color = _get_ripple_color()
	ripple.color = ripple_color
	ripple.modulate.a = 0.3
	
	# Initial size and position
	var initial_size = Vector2(20, 20)
	ripple.size = initial_size
	ripple.position = position - initial_size / 2
	
	# Make it circular
	_apply_circular_style(ripple)
	
	_ripple_container.add_child(ripple)
	_active_ripples.append(ripple)
	
	# Animate ripple
	_animate_ripple(ripple, position)

# === PRIVATE METHODS ===

func _get_ripple_color() -> Color:
	"""Get appropriate ripple color based on button state"""
	# Check for custom ripple color
	if button.has_meta("custom_ripple_color"):
		return button.get_meta("custom_ripple_color")
	
	# Use theme color
	if button._current_theme:
		return button.get_theme_color("font_color", "Button")
	
	return Color.WHITE

func _apply_circular_style(ripple: ColorRect) -> void:
	"""Apply circular style to ripple"""
	var style = StyleBoxFlat.new()
	style.bg_color = ripple.color
	
	# Make it circular
	var radius = int(ripple.size.x / 2)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	
	ripple.add_theme_stylebox_override("panel", style)

func _animate_ripple(ripple: ColorRect, origin: Vector2) -> void:
	"""Animate ripple expansion and fade"""
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	# Calculate final size based on button dimensions
	var button_size = button.size
	var max_distance = origin.distance_to(button_size)
	var final_size = Vector2.ONE * (max_distance * ripple_max_scale)
	
	# Expand ripple
	tween.tween_property(ripple, "size", final_size, ripple_duration)
	tween.tween_property(ripple, "position", origin - final_size / 2, ripple_duration)
	
	# Fade out
	tween.tween_property(ripple, "modulate:a", 0.0, ripple_duration)
	
	# Update circular style as it expands
	var style_tween = create_tween()
	style_tween.tween_method(
		func(progress: float):
			if is_instance_valid(ripple):
				var current_radius = int(ripple.size.x / 2)
				var style = ripple.get_theme_stylebox("panel") as StyleBoxFlat
				if style:
					style.corner_radius_top_left = current_radius
					style.corner_radius_top_right = current_radius
					style.corner_radius_bottom_left = current_radius
					style.corner_radius_bottom_right = current_radius,
		0.0, 1.0, ripple_duration
	)
	
	# Clean up
	tween.finished.connect(func():
		if is_instance_valid(ripple):
			ripple.queue_free()
			_active_ripples.erase(ripple)
	)

func _check_animation_throttle() -> bool:
	"""Check if enough time has passed for smooth animation"""
	var current_time = Time.get_ticks_msec()
	if current_time - _last_animation_time < _min_animation_interval:
		return false
	
	_last_animation_time = current_time
	return true

func _kill_tween(tween: Tween) -> void:
	"""Safely kill a tween"""
	if tween and is_instance_valid(tween):
		tween.kill()

func _kill_all_tweens() -> void:
	"""Kill all active tweens"""
	_kill_tween(_hover_tween)
	_kill_tween(_press_tween)
	
	# Kill ripple tweens
	for ripple in _active_ripples:
		if is_instance_valid(ripple):
			ripple.queue_free()
	_active_ripples.clear()

# === CLEANUP ===

func _exit_tree() -> void:
	"""Clean up when removed from scene"""
	_kill_all_tweens()
	
	if _ripple_container and is_instance_valid(_ripple_container):
		_ripple_container.queue_free()