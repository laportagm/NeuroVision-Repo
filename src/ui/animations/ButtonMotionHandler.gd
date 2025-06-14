## ButtonMotionHandler.gd
## Provides sophisticated Material 3 motion design for buttons and UI elements
##
## This class implements Material You motion principles with smooth animations,
## hover effects, press feedback, and ripple effects that enhance user experience
## while maintaining accessibility and performance standards.
##
## @tutorial: Material 3 Motion Guidelines
## @tutorial: Godot Animation Best Practices

class_name ButtonMotionHandler
extends Node

# === CONSTANTS FROM M3 MOTION GUIDELINES ===
# Using M3DesignTokens for consistent motion values
const HOVER_SCALE_FACTOR = 1.02  # 2% scale increase on hover
const PRESS_SCALE = Vector2(0.98, 0.98)
const RIPPLE_MAX_SCALE = 2.5

# Get motion values from M3DesignTokens
static func _get_hover_duration() -> float:
	return M3DesignTokens.M3_DURATION["medium1"] / 1000.0

static func _get_press_duration() -> float:
	return M3DesignTokens.M3_DURATION["short2"] / 1000.0

static func _get_fade_duration() -> float:
	return M3DesignTokens.M3_DURATION["medium2"] / 1000.0

static func _get_ripple_duration() -> float:
	return M3DesignTokens.M3_DURATION["long1"] / 1000.0

# === STATIC METHODS FOR EASY USE ===

## Setup button with hover animation capabilities
static func setup_button_hover_animation(button: Button) -> void:
	"""Configure a button to respond to hover events with Material 3 animations"""
	if not button:
		push_error("[ButtonMotionHandler] Cannot setup animation on null button")
		return
	
	# Store original values as metadata
	button.set_meta("original_position", button.position)
	button.set_meta("original_modulate", button.modulate)
	button.set_meta("original_scale", button.scale)
	
	# Connect hover signals if not already connected
	if not button.mouse_entered.is_connected(_on_button_mouse_entered.bind(button)):
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
	if not button.mouse_exited.is_connected(_on_button_mouse_exited.bind(button)):
		button.mouse_exited.connect(_on_button_mouse_exited.bind(button))
	if not button.button_down.is_connected(_on_button_pressed.bind(button)):
		button.button_down.connect(_on_button_pressed.bind(button))
	if not button.button_up.is_connected(_on_button_released.bind(button)):
		button.button_up.connect(_on_button_released.bind(button))

## Animate button hover in effect
static func animate_button_hover_in(button: Button) -> void:
	"""Apply Material 3 hover animation to button"""
	if not button:
		return
	
	var tween = button.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	# Get original values
	var original_scale = button.get_meta("original_scale", button.scale)
	var original_modulate = button.get_meta("original_modulate", button.modulate)
	
	# Subtle scale effect instead of position (works better with containers)
	var hover_scale = original_scale * HOVER_SCALE_FACTOR
	tween.tween_property(button, "scale", hover_scale, _get_hover_duration())
	
	# Use M3 state layer for proper hover effect
	var hover_color = M3DesignTokens.get_color("on_surface")
	var hover_layer = M3DesignTokens.get_state_layer(hover_color, "hover")
	var hover_modulate = original_modulate.blend(hover_layer)
	tween.tween_property(button, "modulate", hover_modulate, _get_hover_duration())
	
	# Add state layer effect if Material 3 is active
	if _is_material3_active():
		_apply_state_layer_effect(button, "hover")

## Animate button hover out effect
static func animate_button_hover_out(button: Button) -> void:
	"""Remove Material 3 hover animation from button"""
	if not button:
		return
	
	var tween = button.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	# Restore original values
	var original_scale = button.get_meta("original_scale", button.scale)
	var original_modulate = button.get_meta("original_modulate", button.modulate)
	
	tween.tween_property(button, "scale", original_scale, _get_hover_duration())
	tween.tween_property(button, "modulate", original_modulate, _get_hover_duration())
	
	# Remove state layer effect
	if _is_material3_active():
		_remove_state_layer_effect(button)

## Animate button press effect
static func animate_button_press(button: Button) -> void:
	"""Apply Material 3 press animation to button"""
	if not button:
		return
	
	var tween = button.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	# Scale down slightly for tactile feedback
	tween.tween_property(button, "scale", PRESS_SCALE, _get_press_duration())
	
	# Add press state layer
	if _is_material3_active():
		_apply_state_layer_effect(button, "pressed")

## Animate button release effect
static func animate_button_release(button: Button) -> void:
	"""Apply Material 3 release animation to button"""
	if not button:
		return
	
	var tween = button.create_tween()
	tween.set_trans(Tween.TRANS_SPRING)
	tween.set_ease(Tween.EASE_OUT)
	
	# Restore original scale
	var original_scale = button.get_meta("original_scale", Vector2.ONE)
	tween.tween_property(button, "scale", original_scale, _get_press_duration() * 1.5)

## Animate scene fade in effect
static func animate_scene_fade_in(canvas_layer: CanvasLayer) -> void:
	"""Apply Material 3 fade in animation to entire scene"""
	if not canvas_layer:
		return
	
	# Find the first Control node child (usually ColorRect or container)
	var target_control: Control = null
	for child in canvas_layer.get_children():
		if child is Control:
			target_control = child
			break
	
	if not target_control:
		push_warning("[ButtonMotionHandler] No Control node found in CanvasLayer for fade animation")
		return
	
	# Start with transparent
	target_control.modulate = M3DesignTokens.get_color("transparent")
	
	var tween = target_control.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	# Fade in
	tween.tween_property(target_control, "modulate", Color.WHITE, _get_fade_duration())
	
	# Optional: Add stagger effect for child elements
	_stagger_fade_in_children(canvas_layer, tween)

## Create Material 3 ripple effect
static func create_ripple_effect(button: Button, position: Vector2) -> void:
	"""Create expanding ripple effect from click position"""
	if not button:
		return
	
	# Create ripple container
	var ripple_container = Control.new()
	ripple_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ripple_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.add_child(ripple_container)
	
	# Create ripple circle
	var ripple = ColorRect.new()
	ripple.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Use M3 design tokens for ripple color
	var ripple_color = M3DesignTokens.get_color("on_surface")
	ripple_color.a = M3DesignTokens.M3_OPACITY["pressed"]
	ripple.color = ripple_color
	
	ripple.size = Vector2(20, 20)
	ripple.position = position - ripple.size / 2
	
	# Make it circular with a shader or custom draw
	ripple.clip_contents = true
	
	ripple_container.add_child(ripple)
	
	# Animate ripple
	var tween = ripple.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	# Expand and fade
	var final_size = button.size * RIPPLE_MAX_SCALE
	var final_pos = position - final_size / 2
	
	tween.tween_property(ripple, "size", final_size, _get_ripple_duration())
	tween.tween_property(ripple, "position", final_pos, _get_ripple_duration())
	tween.tween_property(ripple, "modulate:a", 0.0, _get_ripple_duration())
	
	# Clean up after animation
	tween.finished.connect(func(): ripple_container.queue_free())

## Apply entrance animation to a button
static func animate_button_entrance(button: Button, delay: float = 0.0) -> void:
	"""Animate button appearing with Material 3 style"""
	if not button:
		return
	
	# Start hidden
	button.modulate = M3DesignTokens.get_color("transparent")
	button.scale = Vector2(0.8, 0.8)
	
	# Wait for delay if specified
	if delay > 0:
		await button.get_tree().create_timer(delay).timeout
	
	var tween = button.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	tween.tween_property(button, "modulate", Color.WHITE, 0.3)
	tween.tween_property(button, "scale", Vector2.ONE, 0.3)

## Setup all buttons in a container with animations
static func setup_container_buttons(container: Control) -> void:
	"""Recursively setup all buttons in a container with M3 animations"""
	if not container:
		return
	
	for child in container.get_children():
		if child is Button:
			setup_button_hover_animation(child)
		elif child is Control:
			setup_container_buttons(child)  # Recursive for nested containers

# === PRIVATE HELPER METHODS ===

static func _on_button_mouse_entered(button: Button) -> void:
	"""Handle button mouse enter"""
	animate_button_hover_in(button)

static func _on_button_mouse_exited(button: Button) -> void:
	"""Handle button mouse exit"""
	animate_button_hover_out(button)

static func _on_button_pressed(button: Button) -> void:
	"""Handle button press"""
	animate_button_press(button)
	# Create ripple at mouse position
	var mouse_pos = button.get_local_mouse_position()
	create_ripple_effect(button, mouse_pos)

static func _on_button_released(button: Button) -> void:
	"""Handle button release"""
	animate_button_release(button)

static func _is_material3_active() -> bool:
	"""Check if Material 3 theme is currently active"""
	# Check if UIThemeManager exists and M3 is active
	var ui_theme_manager = Engine.get_singleton("UIThemeManager") if Engine.has_singleton("UIThemeManager") else null
	if ui_theme_manager and ui_theme_manager.has_method("is_material3_active"):
		return ui_theme_manager.is_material3_active()
	return false

static func _apply_state_layer_effect(_button: Button, _state: String) -> void:
	"""Apply Material 3 state layer visual effect"""
	# This would integrate with M3DesignTokens for proper state layers
	# For now, we'll use modulate adjustments
	pass

static func _remove_state_layer_effect(_button: Button) -> void:
	"""Remove Material 3 state layer visual effect"""
	pass

static func _stagger_fade_in_children(container: Node, parent_tween: Tween) -> void:
	"""Add staggered fade in effect for child elements"""
	var delay_increment = M3DesignTokens.M3_DURATION["short1"] / 1000.0
	var current_delay = M3DesignTokens.M3_DURATION["short3"] / 1000.0
	var fade_duration = M3DesignTokens.M3_DURATION["medium1"] / 1000.0
	
	for child in container.get_children():
		if child is Control and child.visible:
			# Start transparent
			child.modulate = M3DesignTokens.get_color("transparent")
			
			# Create delayed fade in
			parent_tween.chain()
			parent_tween.tween_interval(current_delay)
			parent_tween.tween_property(child, "modulate", Color.WHITE, fade_duration)
			
			current_delay += delay_increment

## Apply focus animation
static func animate_button_focus(button: Button) -> void:
	"""Apply Material 3 focus indicator animation"""
	if not button:
		return
	
	# Create focus ring effect using M3 design tokens
	var focus_ring = ReferenceRect.new()
	var focus_color = M3DesignTokens.get_color("primary")
	focus_color.a = 0.8
	focus_ring.border_color = focus_color
	focus_ring.border_width = 3
	focus_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Add some padding
	focus_ring.set_offsets_preset(Control.PRESET_FULL_RECT)
	focus_ring.set_offset(SIDE_LEFT, -4)
	focus_ring.set_offset(SIDE_TOP, -4)
	focus_ring.set_offset(SIDE_RIGHT, 4)
	focus_ring.set_offset(SIDE_BOTTOM, 4)
	
	button.add_child(focus_ring)
	button.set_meta("focus_ring", focus_ring)
	
	# Animate focus ring appearance
	focus_ring.modulate = M3DesignTokens.get_color("transparent")
	var tween = focus_ring.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	var focus_duration = M3DesignTokens.M3_DURATION["focus"] / 1000.0
	tween.tween_property(focus_ring, "modulate", Color.WHITE, focus_duration)

## Remove focus animation
static func animate_button_unfocus(button: Button) -> void:
	"""Remove Material 3 focus indicator animation"""
	if not button:
		return
	
	var focus_ring = button.get_meta("focus_ring", null)
	if focus_ring and is_instance_valid(focus_ring):
		var tween = focus_ring.create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		var unfocus_duration = M3DesignTokens.M3_DURATION["focus"] / 1000.0
		tween.tween_property(focus_ring, "modulate:a", 0.0, unfocus_duration)
		tween.finished.connect(func(): focus_ring.queue_free())
		button.remove_meta("focus_ring")
