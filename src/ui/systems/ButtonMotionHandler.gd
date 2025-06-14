## Button Motion Handler for NeuroVision
## Provides hover animation effects for buttons
##
## This singleton handles button hover animations that are referenced
## throughout the UI components but was missing from the codebase.

class_name ButtonMotionHandler
extends RefCounted

# === STATIC METHODS ===

## Setup hover animation for a button
static func setup_button_hover_animation(button: Button, duration: float = 0.2, scale_factor: float = 1.05) -> void:
	"""Add hover scale animation to button"""
	if not button:
		push_error("[ButtonMotionHandler] Cannot setup animation for null button")
		return
	
	# Store original scale
	var original_scale = button.scale
	button.set_meta("original_scale", original_scale)
	button.set_meta("hover_tween", null)
	
	# Connect hover signals
	if not button.mouse_entered.is_connected(_on_button_mouse_entered.bind(button)):
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button, duration, scale_factor))
	
	if not button.mouse_exited.is_connected(_on_button_mouse_exited.bind(button)):
		button.mouse_exited.connect(_on_button_mouse_exited.bind(button, duration))
	
	# Also handle focus for keyboard navigation
	if not button.focus_entered.is_connected(_on_button_focus_entered.bind(button)):
		button.focus_entered.connect(_on_button_focus_entered.bind(button, duration, scale_factor))
	
	if not button.focus_exited.is_connected(_on_button_focus_exited.bind(button)):
		button.focus_exited.connect(_on_button_focus_exited.bind(button, duration))

## Remove hover animation from a button
static func remove_button_hover_animation(button: Button) -> void:
	"""Remove hover animation from button"""
	if not button:
		return
	
	# Kill any existing tween
	var tween = button.get_meta("hover_tween", null)
	if tween and tween is Tween and tween.is_valid():
		tween.kill()
	
	# Disconnect signals
	if button.mouse_entered.is_connected(_on_button_mouse_entered):
		button.mouse_entered.disconnect(_on_button_mouse_entered)
	
	if button.mouse_exited.is_connected(_on_button_mouse_exited):
		button.mouse_exited.disconnect(_on_button_mouse_exited)
	
	if button.focus_entered.is_connected(_on_button_focus_entered):
		button.focus_entered.disconnect(_on_button_focus_entered)
	
	if button.focus_exited.is_connected(_on_button_focus_exited):
		button.focus_exited.disconnect(_on_button_focus_exited)
	
	# Reset scale
	var original_scale = button.get_meta("original_scale", Vector2.ONE)
	button.scale = original_scale

# === PRIVATE METHODS ===

static func _on_button_mouse_entered(button: Button, duration: float, scale_factor: float) -> void:
	"""Handle mouse enter"""
	_animate_button_scale(button, scale_factor, duration)

static func _on_button_mouse_exited(button: Button, duration: float) -> void:
	"""Handle mouse exit"""
	var original_scale = button.get_meta("original_scale", Vector2.ONE)
	_animate_button_scale(button, 1.0, duration)

static func _on_button_focus_entered(button: Button, duration: float, scale_factor: float) -> void:
	"""Handle focus enter"""
	if not button.is_hovered():
		_animate_button_scale(button, scale_factor, duration)

static func _on_button_focus_exited(button: Button, duration: float) -> void:
	"""Handle focus exit"""
	if not button.is_hovered():
		var original_scale = button.get_meta("original_scale", Vector2.ONE)
		_animate_button_scale(button, 1.0, duration)

static func _animate_button_scale(button: Button, target_scale_factor: float, duration: float) -> void:
	"""Animate button scale"""
	# Kill existing tween
	var existing_tween = button.get_meta("hover_tween", null)
	if existing_tween and existing_tween is Tween and existing_tween.is_valid():
		existing_tween.kill()
	
	# Get original scale
	var original_scale = button.get_meta("original_scale", Vector2.ONE)
	var target_scale = original_scale * target_scale_factor
	
	# Create new tween
	var tween = button.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, duration)
	
	# Store tween reference
	button.set_meta("hover_tween", tween)

## Setup press animation for enhanced feedback
static func setup_button_press_animation(button: Button, press_scale: float = 0.95, duration: float = 0.1) -> void:
	"""Add press scale animation to button"""
	if not button:
		return
	
	# Connect press signals
	if not button.button_down.is_connected(_on_button_pressed.bind(button)):
		button.button_down.connect(_on_button_pressed.bind(button, press_scale, duration))
	
	if not button.button_up.is_connected(_on_button_released.bind(button)):
		button.button_up.connect(_on_button_released.bind(button, duration))

static func _on_button_pressed(button: Button, press_scale: float, duration: float) -> void:
	"""Handle button press"""
	_animate_button_scale(button, press_scale, duration * 0.5)

static func _on_button_released(button: Button, duration: float) -> void:
	"""Handle button release"""
	# Return to hover or normal scale
	var scale_factor = 1.05 if button.is_hovered() else 1.0
	_animate_button_scale(button, scale_factor, duration)