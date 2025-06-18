## Material 3 Animation Helper for NeuroVision
## Provides Material You motion system integration for educational UI
##
## This helper manages Material 3 animation curves, durations, and transitions
## while respecting accessibility preferences and educational context.

class_name M3AnimationHelper
extends Resource

# Preload Material 3 tokens
const M3Tokens = preload("res://src/ui_atomic/themes/core/M3DesignTokens.gd")

# === ANIMATION PRESETS ===

## Apply Material 3 entrance animation to control
static func animate_entrance(control: Control, delay: float = 0.0) -> void:
	"""Animate control entrance with Material 3 emphasized motion"""
	
	if not control or not control.is_inside_tree():
		return
	
	# Check for reduced motion preference
	if _should_reduce_motion():
		control.modulate.a = 1.0
		return
	
	# Set initial state
	control.modulate.a = 0.0
	control.scale = Vector2(0.92, 0.92)
	
	# Create tween
	var tween = control.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	if delay > 0:
		tween.tween_interval(delay)
	
	# Animate entrance
	tween.parallel().tween_property(control, "modulate:a", 1.0, M3Tokens.M3_DURATION["medium2"] / 1000.0)
	tween.parallel().tween_property(control, "scale", Vector2.ONE, M3Tokens.M3_DURATION["medium2"] / 1000.0)

## Apply Material 3 exit animation to control
static func animate_exit(control: Control, callback: Callable = Callable()) -> void:
	"""Animate control exit with Material 3 emphasized motion"""
	
	if not control or not control.is_inside_tree():
		return
	
	# Check for reduced motion preference
	if _should_reduce_motion():
		control.visible = false
		if callback.is_valid():
			callback.call()
		return
	
	# Create tween
	var tween = control.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	
	# Animate exit
	tween.parallel().tween_property(control, "modulate:a", 0.0, M3Tokens.M3_DURATION["short4"] / 1000.0)
	tween.parallel().tween_property(control, "scale", Vector2(0.92, 0.92), M3Tokens.M3_DURATION["short4"] / 1000.0)
	
	# Hide and call callback
	tween.tween_callback(func(): 
		control.visible = false
		if callback.is_valid():
			callback.call()
	)

## Apply Material 3 state layer animation
static func animate_state_layer(control: Control, state: String) -> void:
	"""Animate state layer changes (hover, focus, pressed)"""
	
	if not control or not M3Tokens.M3_STATE_LAYERS.has(state):
		return
	
	var state_data = M3Tokens.M3_STATE_LAYERS[state]
	var duration = state_data["duration"] / 1000.0
	
	# Check for reduced motion
	if _should_reduce_motion():
		duration *= M3Tokens.M3_ACCESSIBILITY["animation_reduce_factor"]
	
	# Get or create overlay
	var overlay = _get_or_create_state_overlay(control)
	
	# Animate overlay opacity
	var tween = overlay.create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(overlay, "modulate:a", state_data["opacity"], duration)

## Remove state layer animation
static func remove_state_layer(control: Control) -> void:
	"""Remove state layer with animation"""
	
	var overlay = _get_state_overlay(control)
	if not overlay:
		return
	
	var duration = M3Tokens.M3_DURATION["short2"] / 1000.0
	
	if _should_reduce_motion():
		overlay.queue_free()
		return
	
	var tween = overlay.create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(overlay, "modulate:a", 0.0, duration)
	tween.tween_callback(overlay.queue_free)

## Animate focus ring appearance
static func animate_focus_ring(control: Control, show: bool = true) -> void:
	"""Animate Material 3 focus ring"""
	
	if not control:
		return
	
	var focus_width = M3Tokens.M3_ACCESSIBILITY["focus_indicator_width"]
	var duration = M3Tokens.M3_DURATION["short3"] / 1000.0
	
	if _should_reduce_motion():
		duration = 0.0
	
	# This would typically modify the control's stylebox border
	# For demonstration, we'll use a property animation
	if control.has_method("set_focus_mode"):
		var tween = control.create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		
		if show:
			tween.tween_method(
				func(value): _update_focus_border(control, value),
				0.0, focus_width, duration
			)
		else:
			tween.tween_method(
				func(value): _update_focus_border(control, value),
				focus_width, 0.0, duration
			)

## Animate panel expansion/collapse
static func animate_panel_expand(panel: Control, expanded: bool = true) -> void:
	"""Animate Material 3 panel expansion with container transform"""
	
	if not panel:
		return
	
	var duration = M3Tokens.M3_DURATION["medium3"] / 1000.0
	
	if _should_reduce_motion():
		panel.visible = expanded
		return
	
	var tween = panel.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	if expanded:
		# Expand animation
		panel.visible = true
		panel.scale.y = 0.0
		tween.tween_property(panel, "scale:y", 1.0, duration)
	else:
		# Collapse animation
		tween.tween_property(panel, "scale:y", 0.0, duration)
		tween.tween_callback(func(): panel.visible = false)

## Animate value change with number morphing
static func animate_value_change(label: Label, from_value: float, to_value: float) -> void:
	"""Animate numeric value changes with Material 3 timing"""
	
	if not label:
		return
	
	var duration = M3Tokens.M3_DURATION["medium2"] / 1000.0
	
	if _should_reduce_motion():
		label.text = str(int(to_value))
		return
	
	var tween = label.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_method(
		func(value): label.text = str(int(value)),
		from_value, to_value, duration
	)

## Create ripple effect at position
static func create_ripple_effect(parent: Control, position: Vector2, color: Color = Color.WHITE) -> void:
	"""Create Material 3 ripple effect"""
	
	if not parent or _should_reduce_motion():
		return
	
	# Create ripple node
	var ripple = ColorRect.new()
	ripple.custom_minimum_size = Vector2(20, 20)
	ripple.size = Vector2(20, 20)
	ripple.position = position - ripple.size / 2
	ripple.color = color
	ripple.color.a = M3Tokens.M3_OPACITY["pressed"]
	ripple.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Make it circular
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.bg_color = color
	ripple.add_theme_stylebox_override("panel", style)
	
	parent.add_child(ripple)
	
	# Animate ripple
	var tween = ripple.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	var duration = M3Tokens.M3_DURATION["medium3"] / 1000.0
	var max_size = max(parent.size.x, parent.size.y) * 2
	
	tween.parallel().tween_property(ripple, "size", Vector2(max_size, max_size), duration)
	tween.parallel().tween_property(ripple, "position", position - Vector2(max_size, max_size) / 2, duration)
	tween.parallel().tween_property(ripple, "modulate:a", 0.0, duration)
	
	tween.tween_callback(ripple.queue_free)

# === EDUCATIONAL ANIMATIONS ===

## Animate educational highlight
static func animate_educational_highlight(control: Control, color: Color) -> void:
	"""Highlight control for educational emphasis"""
	
	if not control:
		return
	
	var duration = M3Tokens.M3_DURATION["medium4"] / 1000.0
	var original_modulate = control.modulate
	
	var tween = control.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Pulse effect
	tween.tween_property(control, "modulate", color, duration * 0.5)
	tween.tween_property(control, "modulate", original_modulate, duration * 0.5)

## Animate quiz feedback
static func animate_quiz_feedback(control: Control, correct: bool) -> void:
	"""Animate quiz answer feedback"""
	
	if not control:
		return
	
	var color = M3Tokens.M3_COLORS["success" if correct else "error"]
	var duration = M3Tokens.M3_DURATION["short4"] / 1000.0
	
	# Quick shake for incorrect
	if not correct and not _should_reduce_motion():
		var tween = control.create_tween()
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.set_ease(Tween.EASE_OUT)
		
		var original_pos = control.position
		tween.tween_property(control, "position:x", original_pos.x + 10, duration * 0.25)
		tween.tween_property(control, "position:x", original_pos.x - 10, duration * 0.25)
		tween.tween_property(control, "position:x", original_pos.x, duration * 0.5)
	
	# Color feedback
	animate_educational_highlight(control, color)

# === HELPER METHODS ===

static func _should_reduce_motion() -> bool:
	"""Check if animations should be reduced"""
	# This would check user preferences and accessibility settings
	# For now, return false
	return false

static func _get_or_create_state_overlay(control: Control) -> Control:
	"""Get or create state layer overlay for control"""
	
	var overlay = _get_state_overlay(control)
	if overlay:
		return overlay
	
	# Create new overlay
	overlay = ColorRect.new()
	overlay.name = "StateOverlay"
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.color = M3Tokens.M3_COLORS["on_surface"]
	overlay.modulate.a = 0.0
	
	control.add_child(overlay)
	control.move_child(overlay, 0)  # Move to back
	
	return overlay

static func _get_state_overlay(control: Control) -> Control:
	"""Get existing state overlay"""
	if control.has_node("StateOverlay"):
		return control.get_node("StateOverlay")
	return null

static func _update_focus_border(control: Control, width: float) -> void:
	"""Update control's focus border width"""
	# This is a placeholder - actual implementation would modify styleboxes
	if control.has_method("set_focus_border_width"):
		control.set_focus_border_width(width)

# === TRANSITION HELPERS ===

## Get appropriate easing curve for animation type
static func get_easing_curve(animation_type: String) -> Tween.EaseType:
	"""Get Material 3 easing curve for animation type"""
	
	match animation_type:
		"entrance":
			return Tween.EASE_OUT
		"exit":
			return Tween.EASE_IN
		"transition":
			return Tween.EASE_IN_OUT
		"emphasis":
			return Tween.EASE_OUT
		_:
			return Tween.EASE_IN_OUT

## Get appropriate transition type for animation
static func get_transition_type(animation_type: String) -> Tween.TransitionType:
	"""Get Material 3 transition type for animation"""
	
	match animation_type:
		"entrance", "exit":
			return Tween.TRANS_CUBIC
		"bounce":
			return Tween.TRANS_ELASTIC
		"smooth":
			return Tween.TRANS_SINE
		_:
			return Tween.TRANS_CUBIC