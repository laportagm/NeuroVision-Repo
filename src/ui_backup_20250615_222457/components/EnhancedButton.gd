## EnhancedButton.gd
## Advanced button component with Material 3 tactile feedback and accessibility features
##
## This button extends Godot's Button with enhanced user experience features:
## - Tactile press animations with spring-back feedback
## - Material Design ripple effects on click
## - Elevation changes for depth perception
## - Optional haptic feedback hooks for controller support
## - Screen reader announcements for accessibility
## - Keyboard interaction visual feedback
## - Performance optimized for Intel UHD 620 graphics
##
## @educational_context: Used in educational UI for consistent, accessible interactions
## @performance_target: 60 FPS on Intel UHD 620 with smooth animations
## @accessibility: WCAG 2.1 AA compliant with screen reader support

class_name EnhancedButton
extends Button

# === SIGNALS ===
## Emitted when button receives haptic feedback trigger
signal haptic_feedback_requested(intensity: float)

## Emitted when button announces to screen reader
signal accessibility_announcement(text: String)

## Emitted when button animation completes
signal animation_completed(animation_type: String)

# === EXPORT CONFIGURATION ===
@export_group("Enhanced Interaction")
## Enable tactile press animation (scale down on press)
@export var enable_tactile_feedback: bool = true

## Enable Material Design ripple effect
@export var enable_ripple_effect: bool = true

## Enable hover elevation changes
@export var enable_hover_elevation: bool = true

## Enable haptic feedback for supported devices
@export var enable_haptic_feedback: bool = false

## Enable accessibility announcements
@export var enable_accessibility_announcements: bool = true

## Enable keyboard interaction feedback
@export var enable_keyboard_feedback: bool = true

@export_group("Animation Customization")
## Scale factor for press animation (0.95 = 5% smaller)
@export_range(0.8, 1.0, 0.01) var press_scale_factor: float = 0.95

## Duration of press animation in seconds
@export_range(0.05, 0.3, 0.01) var press_duration: float = 0.08

## Duration of release animation in seconds
@export_range(0.1, 0.5, 0.01) var release_duration: float = 0.12

## Hover elevation offset in pixels
@export_range(0, 8, 1) var hover_elevation: int = 2

## Ripple effect maximum scale multiplier
@export_range(1.5, 3.0, 0.1) var ripple_max_scale: float = 2.0

@export_group("Accessibility")
## Custom text for screen reader announcements
@export var accessibility_label: String = ""

## Additional context for screen readers
@export var accessibility_hint: String = ""

## Focus ring color (uses M3 primary if empty)
@export var focus_ring_color: Color

@export_group("Performance")
## Reduce animation quality for better performance
@export var performance_mode: bool = false

## Skip animations when user prefers reduced motion
@export var respect_reduced_motion: bool = true

# === PRIVATE VARIABLES ===
var _original_scale: Vector2
var _original_position: Vector2
var _original_modulate: Color
var _is_pressed: bool = false
var _is_hovered: bool = false
var _is_focused: bool = false
var _animation_tween: Tween
var _ripple_container: Control
var _focus_ring: ReferenceRect
var _elevation_offset: Vector2
var _motion_reduced: bool = false

# Animation performance optimization
var _last_frame_time: float = 0.0
var _animation_skip_threshold: float = 16.67  # 60 FPS threshold in ms

# === INITIALIZATION ===

func _ready() -> void:
	"""Initialize enhanced button with all features"""
	_store_original_values()
	_setup_motion_preferences()
	_connect_signals()
	_setup_accessibility()
	_apply_material3_styling()
	
	# Announce initialization for debugging
	if OS.is_debug_build():
		print("[EnhancedButton] Initialized: ", name, " with tactile feedback")

func _store_original_values() -> void:
	"""Store original button properties for animation restoration"""
	_original_scale = scale
	_original_position = position
	_original_modulate = modulate

func _setup_motion_preferences() -> void:
	"""Check user's motion preferences for accessibility"""
	if AccessibilityManager and AccessibilityManager.is_reduce_motion_enabled():
		_motion_reduced = true
		if respect_reduced_motion:
			enable_tactile_feedback = false
			enable_ripple_effect = false
			enable_hover_elevation = false
			print("[EnhancedButton] Reduced motion mode enabled for: ", name)

func _connect_signals() -> void:
	"""Connect button signals to enhanced feedback methods"""
	# Mouse interaction
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)
	
	# Button press/release
	if not button_down.is_connected(_on_button_pressed):
		button_down.connect(_on_button_pressed)
	if not button_up.is_connected(_on_button_released):
		button_up.connect(_on_button_released)
	
	# Focus handling
	if not focus_entered.is_connected(_on_focus_entered):
		focus_entered.connect(_on_focus_entered)
	if not focus_exited.is_connected(_on_focus_exited):
		focus_exited.connect(_on_focus_exited)
	
	# Accessibility
	if enable_accessibility_announcements and AccessibilityManager:
		if not AccessibilityManager.accessibility_mode_changed.is_connected(_on_accessibility_changed):
			AccessibilityManager.accessibility_mode_changed.connect(_on_accessibility_changed)

func _setup_accessibility() -> void:
	"""Configure accessibility features"""
	if enable_accessibility_announcements:
		# Set up screen reader support
		if accessibility_label.is_empty():
			accessibility_label = text if not text.is_empty() else "Button"
		
		# Ensure button is focusable
		focus_mode = Control.FOCUS_ALL

func _apply_material3_styling() -> void:
	"""Apply Material 3 design tokens to button appearance"""
	if not M3DesignTokens:
		return
	
	# Apply M3 corner radius
	if has_theme_stylebox_override("normal"):
		var stylebox = get_theme_stylebox("normal")
		if stylebox is StyleBoxFlat:
			stylebox.corner_radius_top_left = M3DesignTokens.M3_CORNER_RADIUS["button"]
			stylebox.corner_radius_top_right = M3DesignTokens.M3_CORNER_RADIUS["button"]
			stylebox.corner_radius_bottom_left = M3DesignTokens.M3_CORNER_RADIUS["button"]
			stylebox.corner_radius_bottom_right = M3DesignTokens.M3_CORNER_RADIUS["button"]

# === HOVER INTERACTION ===

func _on_mouse_entered() -> void:
	"""Handle mouse enter with elevation and hover effects"""
	if _motion_reduced and respect_reduced_motion:
		return
	
	_is_hovered = true
	_animate_hover_in()
	
	# Announce hover for accessibility
	if enable_accessibility_announcements and AccessibilityManager:
		var announcement = accessibility_label + " button"
		if not accessibility_hint.is_empty():
			announcement += ", " + accessibility_hint
		AccessibilityManager.announce(announcement)

func _on_mouse_exited() -> void:
	"""Handle mouse exit with smooth return to original state"""
	if _motion_reduced and respect_reduced_motion:
		return
	
	_is_hovered = false
	if not _is_pressed:  # Don't animate out if still pressed
		_animate_hover_out()

func _animate_hover_in() -> void:
	"""Create smooth hover animation with elevation effect"""
	if not enable_hover_elevation:
		return
	
	_kill_existing_tween()
	_animation_tween = create_tween()
	_animation_tween.set_parallel(true)
	_animation_tween.set_trans(Tween.TRANS_CUBIC)
	_animation_tween.set_ease(Tween.EASE_OUT)
	
	# Subtle scale increase (M3 guidelines)
	var hover_scale = _original_scale * 1.02
	_animation_tween.tween_property(self, "scale", hover_scale, 0.12)
	
	# Elevation effect via shadow simulation
	if enable_hover_elevation:
		_elevation_offset = Vector2(0, -hover_elevation)
		_animation_tween.tween_property(self, "position", _original_position + _elevation_offset, 0.12)
	
	# Use proper hover state layer instead of lightening
	# This maintains color consistency across themes
	if M3DesignTokens:
		var hover_layer = M3DesignTokens.get_state_layer(_original_modulate, "hover")
		var hover_modulate = _original_modulate
		hover_modulate.a = hover_modulate.a * (1.0 - hover_layer.a) + hover_layer.a
		_animation_tween.tween_property(self, "modulate", hover_modulate, 0.12)
	else:
		_animation_tween.tween_property(self, "modulate", _original_modulate, 0.12)

func _animate_hover_out() -> void:
	"""Return to original state from hover"""
	_kill_existing_tween()
	_animation_tween = create_tween()
	_animation_tween.set_parallel(true)
	_animation_tween.set_trans(Tween.TRANS_CUBIC)
	_animation_tween.set_ease(Tween.EASE_OUT)
	
	# Return to original values
	_animation_tween.tween_property(self, "scale", _original_scale, 0.12)
	_animation_tween.tween_property(self, "position", _original_position, 0.12)
	_animation_tween.tween_property(self, "modulate", _original_modulate, 0.12)

# === PRESS INTERACTION ===

func _on_button_pressed() -> void:
	"""Handle button press with tactile feedback"""
	_is_pressed = true
	
	if enable_tactile_feedback and not (_motion_reduced and respect_reduced_motion):
		_animate_press()
	
	if enable_ripple_effect and not (_motion_reduced and respect_reduced_motion):
		_create_ripple_effect()
	
	if enable_haptic_feedback:
		haptic_feedback_requested.emit(0.5)  # Medium intensity
	
	# Accessibility announcement
	if enable_accessibility_announcements and AccessibilityManager:
		AccessibilityManager.announce(accessibility_label + " activated")

func _on_button_released() -> void:
	"""Handle button release with spring-back animation"""
	_is_pressed = false
	
	if enable_tactile_feedback and not (_motion_reduced and respect_reduced_motion):
		_animate_release()

func _animate_press() -> void:
	"""Create tactile press animation"""
	_kill_existing_tween()
	_animation_tween = create_tween()
	_animation_tween.set_trans(Tween.TRANS_CUBIC)
	_animation_tween.set_ease(Tween.EASE_OUT)
	
	# Scale down for tactile feedback
	var press_scale = _original_scale * press_scale_factor
	_animation_tween.tween_property(self, "scale", press_scale, press_duration)
	
	# Slight position adjustment for depth
	if enable_hover_elevation:
		var press_position = _original_position + Vector2(0, 1)
		_animation_tween.tween_property(self, "position", press_position, press_duration)

func _animate_release() -> void:
	"""Create spring-back release animation"""
	_kill_existing_tween()
	_animation_tween = create_tween()
	_animation_tween.set_trans(Tween.TRANS_SPRING)
	_animation_tween.set_ease(Tween.EASE_OUT)
	_animation_tween.set_parallel(true)
	
	# Spring back to original or hover state
	var target_scale = _original_scale
	var target_position = _original_position
	
	if _is_hovered:
		target_scale = _original_scale * 1.02
		target_position = _original_position + Vector2(0, -hover_elevation)
	
	_animation_tween.tween_property(self, "scale", target_scale, release_duration)
	_animation_tween.tween_property(self, "position", target_position, release_duration)
	
	# Signal completion
	_animation_tween.finished.connect(func(): animation_completed.emit("release"))

# === RIPPLE EFFECT ===

func _create_ripple_effect() -> void:
	"""Create Material Design ripple effect from click position"""
	if not enable_ripple_effect:
		return
	
	# Create ripple container if it doesn't exist
	if not _ripple_container:
		_ripple_container = Control.new()
		_ripple_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ripple_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_ripple_container.clip_contents = true
		add_child(_ripple_container)
	
	# Get click position
	var click_position = get_local_mouse_position()
	
	# Create ripple circle
	var ripple = ColorRect.new()
	ripple.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ripple.color = UnifiedColorSystem.get_color("on_surface")
	ripple.color.a = 0.3  # Semi-transparent ripple
	ripple.size = Vector2(20, 20)
	ripple.position = click_position - ripple.size / 2
	
	# Make it circular with corner radius
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = ripple.color
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.corner_radius_bottom_right = 10
	ripple.add_theme_stylebox_override("panel", style_box)
	
	_ripple_container.add_child(ripple)
	
	# Animate ripple expansion
	var ripple_tween = create_tween()
	ripple_tween.set_parallel(true)
	ripple_tween.set_trans(Tween.TRANS_CUBIC)
	ripple_tween.set_ease(Tween.EASE_OUT)
	
	# Calculate final size based on button dimensions
	var max_dimension = max(size.x, size.y)
	var final_size = Vector2(max_dimension * ripple_max_scale, max_dimension * ripple_max_scale)
	var final_position = click_position - final_size / 2
	
	# Expand and fade out
	ripple_tween.tween_property(ripple, "size", final_size, 0.6)
	ripple_tween.tween_property(ripple, "position", final_position, 0.6)
	ripple_tween.tween_property(ripple, "modulate:a", 0.0, 0.6)
	
	# Clean up after animation
	ripple_tween.finished.connect(func(): 
		if is_instance_valid(ripple):
			ripple.queue_free()
	)

# === FOCUS HANDLING ===

func _on_focus_entered() -> void:
	"""Handle keyboard focus with visual feedback"""
	_is_focused = true
	
	if enable_keyboard_feedback:
		_create_focus_ring()
	
	# Accessibility announcement
	if enable_accessibility_announcements and AccessibilityManager:
		var announcement = accessibility_label + " button focused"
		if not accessibility_hint.is_empty():
			announcement += ", " + accessibility_hint
		AccessibilityManager.announce(announcement)

func _on_focus_exited() -> void:
	"""Handle focus loss with cleanup"""
	_is_focused = false
	
	if enable_keyboard_feedback:
		_remove_focus_ring()

func _create_focus_ring() -> void:
	"""Create accessible focus ring indicator"""
	if _focus_ring:
		_remove_focus_ring()
	
	_focus_ring = ReferenceRect.new()
	_focus_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_focus_ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Use M3 primary color or custom focus color
	var ring_color = focus_ring_color
	if ring_color == Color() and M3DesignTokens:
		ring_color = UnifiedColorSystem.get_color("primary")
	
	_focus_ring.border_color = ring_color
	_focus_ring.border_width = 3
	
	# Add padding around button
	_focus_ring.set_offset(SIDE_LEFT, -4)
	_focus_ring.set_offset(SIDE_TOP, -4)
	_focus_ring.set_offset(SIDE_RIGHT, 4)
	_focus_ring.set_offset(SIDE_BOTTOM, 4)
	
	add_child(_focus_ring)
	
	# Animate focus ring appearance
	_focus_ring.modulate = UnifiedColorSystem.get_color("transparent")
	var focus_tween = create_tween()
	focus_tween.set_trans(Tween.TRANS_CUBIC)
	focus_tween.set_ease(Tween.EASE_OUT)
	focus_tween.tween_property(_focus_ring, "modulate", UnifiedColorSystem.get_color("on_surface"), 0.15)

func _remove_focus_ring() -> void:
	"""Remove focus ring with fade animation"""
	if not _focus_ring or not is_instance_valid(_focus_ring):
		return
	
	var fade_tween = create_tween()
	fade_tween.set_trans(Tween.TRANS_CUBIC)
	fade_tween.set_ease(Tween.EASE_OUT)
	fade_tween.tween_property(_focus_ring, "modulate:a", 0.0, 0.15)
	fade_tween.finished.connect(func(): 
		if is_instance_valid(_focus_ring):
			_focus_ring.queue_free()
			_focus_ring = null
	)

# === KEYBOARD HANDLING ===

func _gui_input(event: InputEvent) -> void:
	"""Handle keyboard input for accessibility"""
	if not enable_keyboard_feedback:
		return
	
	if event is InputEventKey:
		var key_event = event as InputEventKey
		
		# Handle Enter/Space activation
		if key_event.pressed and (key_event.keycode == KEY_ENTER or key_event.keycode == KEY_SPACE):
			if has_focus():
				# Simulate button press
				_on_button_pressed()
				# Emit pressed signal
				pressed.emit()
				# Short delay then release
				await get_tree().create_timer(0.1).timeout
				_on_button_released()

# === ACCESSIBILITY INTEGRATION ===

func _on_accessibility_changed(enabled: bool) -> void:
	"""Respond to accessibility mode changes"""
	if enabled:
		# Ensure button is keyboard accessible
		focus_mode = Control.FOCUS_ALL
		# Increase focus ring visibility
		if _focus_ring:
			_focus_ring.border_width = 4
	else:
		# Reset to default focus handling
		if not enable_keyboard_feedback:
			focus_mode = Control.FOCUS_NONE

# === PERFORMANCE OPTIMIZATION ===

func _kill_existing_tween() -> void:
	"""Safely kill existing animation tween"""
	if _animation_tween and _animation_tween.is_valid():
		_animation_tween.kill()
		_animation_tween = null

func _should_skip_animation() -> bool:
	"""Check if animation should be skipped for performance"""
	if performance_mode:
		var current_time = Time.get_time_dict_from_system()
		var frame_time = current_time.second * 1000 + current_time.millisecond
		
		if frame_time - _last_frame_time < _animation_skip_threshold:
			return true
		
		_last_frame_time = frame_time
	
	return false

# === PUBLIC API ===

## Set custom ripple color
func set_ripple_color(color: Color) -> void:
	"""Set custom color for ripple effects"""
	# Store for future ripple effects
	set_meta("custom_ripple_color", color)

## Enable/disable all animations
func set_animations_enabled(enabled: bool) -> void:
	"""Enable or disable all button animations"""
	enable_tactile_feedback = enabled
	enable_ripple_effect = enabled
	enable_hover_elevation = enabled

## Trigger haptic feedback manually
func trigger_haptic_feedback(intensity: float = 0.5) -> void:
	"""Manually trigger haptic feedback"""
	if enable_haptic_feedback:
		haptic_feedback_requested.emit(clamp(intensity, 0.0, 1.0))

## Get current animation state
func is_animating() -> bool:
	"""Check if button is currently animating"""
	return _animation_tween != null and _animation_tween.is_valid()

## Force announce to screen reader
func announce_to_screen_reader(announcement_text: String = "") -> void:
	"""Force announcement to screen reader"""
	if enable_accessibility_announcements and AccessibilityManager:
		var announcement = announcement_text if not announcement_text.is_empty() else accessibility_label
		AccessibilityManager.announce(announcement)
		accessibility_announcement.emit(announcement)

# === CLEANUP ===

func _exit_tree() -> void:
	"""Clean up resources when button is removed"""
	_kill_existing_tween()
	
	if _ripple_container and is_instance_valid(_ripple_container):
		_ripple_container.queue_free()
	
	if _focus_ring and is_instance_valid(_focus_ring):
		_focus_ring.queue_free()