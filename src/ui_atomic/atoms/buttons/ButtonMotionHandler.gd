## ButtonMotionHandler.gd
##
## Static utility functions for button motion effects and animations.
## Used by various UI components for consistent Material 3 button behaviors.

class_name ButtonMotionHandler

# === STATIC UTILITY FUNCTIONS ===

## Calculate smooth easing for button press animations
static func calculate_press_scale(progress: float) -> float:
	"""Calculate scale factor for button press animation using Material 3 easing"""
	return 1.0 - (0.05 * ease_in_out(progress))

## Calculate hover elevation for Material 3 buttons
static func calculate_hover_elevation(progress: float) -> float:
	"""Calculate elevation offset for hover state"""
	return 2.0 * ease_out(progress)

## Get Material 3 standard easing curve
static func ease_in_out(t: float) -> float:
	"""Material 3 standard easing curve"""
	if t < 0.5:
		return 2.0 * t * t
	else:
		return -1.0 + (4.0 - 2.0 * t) * t

## Get ease out curve for animations
static func ease_out(t: float) -> float:
	"""Ease out curve for smooth endings"""
	return 1.0 - pow(1.0 - t, 2.0)

## Calculate ripple effect parameters
static func calculate_ripple_params(button_size: Vector2, touch_position: Vector2) -> Dictionary:
	"""Calculate ripple effect parameters for Material 3 buttons"""
	var center_distance = touch_position.distance_to(button_size * 0.5)
	var max_radius = button_size.length() * 0.6
	
	return {
		"center": touch_position,
		"max_radius": max_radius,
		"initial_radius": center_distance * 0.1
	}

## Setup hover animations for buttons
static func setup_button_hover_animation(button: Button) -> void:
	"""Setup hover animation for Material 3 button"""
	if not button:
		return
	
	button.mouse_entered.connect(func(): _animate_hover(button, true))
	button.mouse_exited.connect(func(): _animate_hover(button, false))

## Animate button focus state
static func animate_button_focus(button: Button) -> void:
	"""Animate button gaining focus"""
	if not button:
		return
	
	var tween = button.create_tween()
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.15)

## Animate button unfocus state  
static func animate_button_unfocus(button: Button) -> void:
	"""Animate button losing focus"""
	if not button:
		return
	
	var tween = button.create_tween()
	tween.tween_property(button, "scale", Vector2.ONE, 0.15)

## Animate scene fade in
static func animate_scene_fade_in(canvas_layer: CanvasLayer) -> void:
	"""Animate scene fade in effect"""
	if not canvas_layer:
		return
	
	# CanvasLayer doesn't have modulate, so animate its children instead
	for child in canvas_layer.get_children():
		if child is Control:
			child.modulate.a = 0.0
			var tween = child.create_tween()
			tween.tween_property(child, "modulate:a", 1.0, 0.5)

## Animate button entrance
static func animate_button_entrance(button: Button, delay: float = 0.0) -> void:
	"""Animate button entrance with delay"""
	if not button:
		return
	
	button.position.y += 20
	button.modulate.a = 0.0
	
	await button.get_tree().create_timer(delay).timeout
	
	var tween = button.create_tween()
	tween.parallel().tween_property(button, "position:y", button.position.y - 20, 0.3)
	tween.parallel().tween_property(button, "modulate:a", 1.0, 0.3)

## Private helper for hover animation
static func _animate_hover(button: Button, is_hovering: bool) -> void:
	"""Private helper for hover animation"""
	if not button:
		return
	
	var tween = button.create_tween()
	var target_scale = Vector2(1.02, 1.02) if is_hovering else Vector2.ONE
	tween.tween_property(button, "scale", target_scale, 0.15)