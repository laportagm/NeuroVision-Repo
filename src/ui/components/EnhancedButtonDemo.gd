## EnhancedButtonDemo.gd
## Demo scene controller for showcasing NeuroVision Soft Aurora palette and EnhancedButton
##
## This demo provides:
## - NeuroVision Soft Aurora color palette showcase
## - Enhanced button tactile feedback demonstration
## - Dark mode UI composition with proper accessibility
## - Brain structure color mapping visualization
##
## @educational_context: Demonstrates UI design system for NeuroVision
## @design_context: Showcases Soft Aurora palette in dark mode composition

extends Control

# === DEMO STATE ===
var demo_initialized: bool = false
var button_interaction_count: int = 0
var performance_stats: Dictionary = {}

# === NODE REFERENCES ===
@onready var primary_button: Button = $MainContainer/DemoPanel/VBoxContainer/ButtonSection/PrimaryButton
@onready var secondary_button: Button = $MainContainer/DemoPanel/VBoxContainer/ButtonSection/SecondaryButton

# Performance monitoring
var performance_timer: Timer

# === INITIALIZATION ===

func _ready() -> void:
	"""Initialize the Soft Aurora palette demo"""
	print("[NeuroVision Demo] Initializing Soft Aurora palette showcase")
	
	_setup_button_connections()
	_setup_performance_monitoring()
	_announce_demo_ready()
	
	demo_initialized = true

func _setup_button_connections() -> void:
	"""Setup the demo button connections"""
	# Primary button
	if primary_button:
		if not primary_button.pressed.is_connected(_on_primary_button_pressed):
			primary_button.pressed.connect(_on_primary_button_pressed)
		if primary_button.has_signal("haptic_feedback_requested") and not primary_button.haptic_feedback_requested.is_connected(_on_haptic_feedback):
			primary_button.haptic_feedback_requested.connect(_on_haptic_feedback)
		if primary_button.has_signal("accessibility_announcement") and not primary_button.accessibility_announcement.is_connected(_on_accessibility_announcement):
			primary_button.accessibility_announcement.connect(_on_accessibility_announcement)
	
	# Secondary button
	if secondary_button:
		if not secondary_button.pressed.is_connected(_on_secondary_button_pressed):
			secondary_button.pressed.connect(_on_secondary_button_pressed)
		if secondary_button.has_signal("haptic_feedback_requested") and not secondary_button.haptic_feedback_requested.is_connected(_on_haptic_feedback):
			secondary_button.haptic_feedback_requested.connect(_on_haptic_feedback)
		if secondary_button.has_signal("accessibility_announcement") and not secondary_button.accessibility_announcement.is_connected(_on_accessibility_announcement):
			secondary_button.accessibility_announcement.connect(_on_accessibility_announcement)

func _setup_performance_monitoring() -> void:
	"""Setup performance monitoring for the demo"""
	performance_timer = Timer.new()
	performance_timer.wait_time = 2.0  # Update every 2 seconds
	performance_timer.timeout.connect(_update_performance_stats)
	performance_timer.autostart = true
	add_child(performance_timer)
	
	# Initialize performance tracking
	performance_stats = {
		"fps": 60.0,
		"frame_time": 16.67,
		"button_interactions": 0,
		"demo_uptime": 0.0
	}

func _announce_demo_ready() -> void:
	"""Announce that the demo is ready for accessibility"""
	if AccessibilityManager:
		AccessibilityManager.announce("NeuroVision Soft Aurora palette demo loaded. Showcasing 8 color swatches, brain structure mapping, and enhanced button interactions.")

# === EVENT HANDLERS ===

func _on_primary_button_pressed() -> void:
	"""Handle primary button press"""
	button_interaction_count += 1
	performance_stats["button_interactions"] = button_interaction_count
	
	print("[NeuroVision Demo] Primary action button pressed - demonstrating tactile feedback")
	print("[NeuroVision Demo] Using Primary color: #5A9FE2 (Soft Aurora)")
	
	if AccessibilityManager:
		AccessibilityManager.announce("Primary action executed using NeuroVision primary color")

func _on_secondary_button_pressed() -> void:
	"""Handle secondary button press"""
	button_interaction_count += 1
	performance_stats["button_interactions"] = button_interaction_count
	
	print("[NeuroVision Demo] Secondary action button pressed - demonstrating tactile feedback")
	print("[NeuroVision Demo] Using Secondary color: #4FAF9E (Soft Aurora)")
	
	if AccessibilityManager:
		AccessibilityManager.announce("Secondary action executed using NeuroVision secondary color")

func _on_haptic_feedback(intensity: float) -> void:
	"""Handle haptic feedback requests from enhanced buttons"""
	print("[NeuroVision Demo] Haptic feedback triggered: intensity ", intensity)
	print("[NeuroVision Demo] Enhanced button tactile response active")

func _on_accessibility_announcement(text: String) -> void:
	"""Handle accessibility announcements from enhanced buttons"""
	print("[NeuroVision Demo] Accessibility: ", text)

# === PERFORMANCE MONITORING ===

func _update_performance_stats() -> void:
	"""Update performance statistics for the demo"""
	performance_stats["fps"] = Engine.get_frames_per_second()
	performance_stats["frame_time"] = 1000.0 / performance_stats["fps"] if performance_stats["fps"] > 0 else 0.0
	performance_stats["demo_uptime"] += 2.0
	
	# Log performance status
	var fps_status = "EXCELLENT" if performance_stats["fps"] >= 58.0 else "NEEDS_OPTIMIZATION"
	print("[NeuroVision Demo] Performance: ", fps_status, " - FPS: ", performance_stats["fps"], " - Interactions: ", button_interaction_count)

# === INPUT HANDLING ===

func _gui_input(event: InputEvent) -> void:
	"""Handle global input for demo navigation"""
	if event is InputEventKey and event.pressed:
		var key_event = event as InputEventKey
		
		# Demo information hotkeys
		match key_event.keycode:
			KEY_F1:
				_show_palette_info()
			KEY_F2:
				_show_accessibility_info()
			KEY_F3:
				_show_performance_info()
			KEY_ESCAPE:
				if AccessibilityManager:
					AccessibilityManager.announce("NeuroVision demo navigation: F1 for palette info, F2 for accessibility info, F3 for performance info")

func _show_palette_info() -> void:
	"""Show information about the Soft Aurora palette"""
	print("[NeuroVision Demo] === SOFT AURORA PALETTE INFO ===")
	print("[NeuroVision Demo] Primary: #5A9FE2 - Calm, professional blue")
	print("[NeuroVision Demo] Secondary: #4FAF9E - Trustworthy teal")
	print("[NeuroVision Demo] Tertiary: #8D7FD9 - Creative purple")
	print("[NeuroVision Demo] Quaternary: #C6AA6E - Warm accent gold")
	print("[NeuroVision Demo] Surface: #1F2730 - Dark surface")
	print("[NeuroVision Demo] Outline: #45505F - Subtle boundaries")
	print("[NeuroVision Demo] Success: #28B87D - Positive feedback")
	print("[NeuroVision Demo] Error: #EA6C6C - Alert/warning")
	
	if AccessibilityManager:
		AccessibilityManager.announce("Soft Aurora palette contains 8 carefully chosen colors for educational neuroscience interfaces")

func _show_accessibility_info() -> void:
	"""Show accessibility features information"""
	print("[NeuroVision Demo] === ACCESSIBILITY FEATURES ===")
	print("[NeuroVision Demo] - WCAG 2.1 AA compliant color contrast")
	print("[NeuroVision Demo] - Screen reader announcements")
	print("[NeuroVision Demo] - Keyboard navigation support")
	print("[NeuroVision Demo] - Tactile button feedback")
	print("[NeuroVision Demo] - Reduced motion respect")
	print("[NeuroVision Demo] - Focus ring indicators")
	
	if AccessibilityManager:
		AccessibilityManager.announce("All accessibility features active including screen reader support, keyboard navigation, and tactile feedback")

func _show_performance_info() -> void:
	"""Show current performance information"""
	print("[NeuroVision Demo] === PERFORMANCE INFO ===")
	print("[NeuroVision Demo] Current FPS: ", performance_stats.get("fps", 0))
	print("[NeuroVision Demo] Frame time: ", performance_stats.get("frame_time", 0), " ms")
	print("[NeuroVision Demo] Button interactions: ", performance_stats.get("button_interactions", 0))
	print("[NeuroVision Demo] Demo uptime: ", performance_stats.get("demo_uptime", 0), " seconds")
	print("[NeuroVision Demo] Target: 60 FPS for smooth educational interactions")
	
	if AccessibilityManager:
		var fps = performance_stats.get("fps", 0)
		var status = "excellent" if fps >= 58.0 else "needs optimization"
		AccessibilityManager.announce("Performance status: " + status + ". Current frame rate: " + str(fps) + " frames per second")

# === UTILITY FUNCTIONS ===

func get_demo_stats() -> Dictionary:
	"""Get comprehensive demo statistics"""
	return {
		"initialized": demo_initialized,
		"button_interactions": button_interaction_count,
		"performance": performance_stats,
		"palette_colors": 8,
		"brain_structure_chips": 9,
		"accessibility_compliant": true
	}

# === CLEANUP ===

func _exit_tree() -> void:
	"""Clean up demo resources"""
	if performance_timer and is_instance_valid(performance_timer):
		performance_timer.queue_free()
	
	print("[NeuroVision Demo] Soft Aurora palette demo cleanup completed")