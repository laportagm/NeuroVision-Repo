## BaseComponent.gd
## Base class for all UI components in NeuroVision
##
## This class provides common functionality for all UI elements including:
## - Theme management and application
## - Lifecycle hooks for proper initialization and cleanup
## - Memory management and resource tracking
## - Analytics integration for usage tracking
## - Accessibility features
##
## All UI components should extend this class to ensure consistency

class_name BaseComponent
extends Control

# === SIGNALS ===
signal component_ready()
signal component_shown()
signal component_hidden()
signal theme_changed(new_theme: Theme)
signal analytics_event(event_name: String, properties: Dictionary)

# === CONSTANTS ===
const ANIMATION_DURATION: float = 0.3
const MEMORY_POOL_SIZE: int = 10

# === EXPORT VARIABLES ===
@export_group("Component Settings")
@export var component_id: String = ""
@export var track_analytics: bool = true
@export var enable_animations: bool = true
@export var auto_cleanup: bool = true

@export_group("Accessibility")
@export var screen_reader_label: String = ""
@export var keyboard_navigable: bool = true
@export var high_contrast_support: bool = true

# === PRIVATE VARIABLES ===
var _is_initialized: bool = false
var _current_theme: Theme
var _analytics_properties: Dictionary = {}
var _resource_tracker: Array = []
var _tween: Tween

# === LIFECYCLE METHODS ===

func _ready() -> void:
	"""Initialize the component with proper setup sequence"""
	if _is_initialized:
		return
		
	# Set component ID if not provided
	if component_id.is_empty():
		component_id = get_class() + "_" + str(get_instance_id())
	
	# Initialize core systems
	_setup_accessibility()
	_setup_theme()
	_setup_analytics()
	
	# Call child implementation
	_on_ready()
	
	_is_initialized = true
	component_ready.emit()

func _enter_tree() -> void:
	"""Handle component entering the scene tree"""
	_on_enter_tree()
	if track_analytics:
		_track_event("component_entered_tree")

func _exit_tree() -> void:
	"""Handle component exiting the scene tree with cleanup"""
	_on_exit_tree()
	if auto_cleanup:
		_cleanup_resources()
	if track_analytics:
		_track_event("component_exited_tree")

# === VIRTUAL LIFECYCLE HOOKS ===

func _on_ready() -> void:
	"""Override this to add custom initialization logic"""
	pass

func _on_enter_tree() -> void:
	"""Override this to handle entering scene tree"""
	pass

func _on_exit_tree() -> void:
	"""Override this to handle exiting scene tree"""
	pass

func _on_show() -> void:
	"""Override this to handle component becoming visible"""
	pass

func _on_hide() -> void:
	"""Override this to handle component becoming hidden"""
	pass

func _on_theme_changed(theme: Theme) -> void:
	"""Override this to handle theme changes"""
	pass

# === PUBLIC METHODS ===

func show_component(animated: bool = true) -> void:
	"""Show the component with optional animation"""
	if animated and enable_animations:
		_animate_show()
	else:
		show()
		modulate.a = 1.0
	
	_on_show()
	component_shown.emit()
	if track_analytics:
		_track_event("component_shown")

func hide_component(animated: bool = true) -> void:
	"""Hide the component with optional animation"""
	if animated and enable_animations:
		_animate_hide()
	else:
		hide()
	
	_on_hide()
	component_hidden.emit()
	if track_analytics:
		_track_event("component_hidden")

func apply_theme(theme: Theme) -> void:
	"""Apply a theme to this component and its children"""
	_current_theme = theme
	set_theme(theme)
	
	# Apply to all themeable children
	for child in get_children():
		if child.has_method("apply_theme"):
			child.apply_theme(theme)
	
	_on_theme_changed(theme)
	theme_changed.emit(theme)

func track_resource(resource: Resource) -> void:
	"""Track a resource for cleanup"""
	if not resource in _resource_tracker:
		_resource_tracker.append(resource)

func get_component_info() -> Dictionary:
	"""Get component information for debugging/analytics"""
	return {
		"id": component_id,
		"class": get_class(),
		"visible": visible,
		"position": global_position,
		"size": size,
		"theme": _current_theme.resource_path if _current_theme else "none",
		"analytics_enabled": track_analytics,
		"memory_usage": _get_memory_usage()
	}

# === PRIVATE METHODS ===

func _setup_accessibility() -> void:
	"""Configure accessibility features"""
	# Set up screen reader hints
	if not screen_reader_label.is_empty():
		set_meta("screen_reader_text", screen_reader_label)
	
	# Configure keyboard navigation
	if keyboard_navigable:
		focus_mode = Control.FOCUS_ALL
		
	# Set up high contrast support
	if high_contrast_support:
		set_meta("supports_high_contrast", true)

func _setup_theme() -> void:
	"""Initialize theme management"""
	# Connect to global theme manager if available
	if has_node("/root/UIThemeManager"):
		var theme_mgr = get_node("/root/UIThemeManager")
		if theme_mgr.has_signal("theme_changed"):
			theme_mgr.theme_changed.connect(_on_global_theme_changed)

func _setup_analytics() -> void:
	"""Initialize analytics tracking"""
	_analytics_properties = {
		"component_id": component_id,
		"component_class": get_class(),
		"timestamp": Time.get_ticks_msec()
	}

func _animate_show() -> void:
	"""Animate component appearing"""
	if _tween:
		_tween.kill()
	
	show()
	modulate.a = 0.0
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, ANIMATION_DURATION)

func _animate_hide() -> void:
	"""Animate component disappearing"""
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, ANIMATION_DURATION)
	_tween.tween_callback(hide)

func _cleanup_resources() -> void:
	"""Clean up tracked resources"""
	for resource in _resource_tracker:
		if is_instance_valid(resource) and resource.has_method("queue_free"):
			resource.queue_free()
	_resource_tracker.clear()
	
	# Kill any running tweens
	if _tween:
		_tween.kill()
		_tween = null

func _track_event(event_name: String, properties: Dictionary = {}) -> void:
	"""Track an analytics event"""
	if not track_analytics:
		return
	
	var event_data = _analytics_properties.duplicate()
	event_data.merge(properties)
	event_data["event_time"] = Time.get_ticks_msec()
	
	analytics_event.emit(event_name, event_data)

func _get_memory_usage() -> int:
	"""Estimate memory usage of this component"""
	# Basic estimation - can be overridden for more accurate measurement
	var usage = 0
	usage += _resource_tracker.size() * 1024  # Rough estimate per resource
	return usage

func _on_global_theme_changed(theme_name: String) -> void:
	"""Handle global theme changes"""
	# This will be called by the global theme manager
	# Child classes can override to handle specific theme changes
	pass

# === STATIC HELPER METHODS ===

static func create_with_config(config: Dictionary) -> BaseComponent:
	"""Factory method to create component with configuration"""
	var component = BaseComponent.new()
	
	if config.has("id"):
		component.component_id = config.id
	if config.has("analytics"):
		component.track_analytics = config.analytics
	if config.has("animations"):
		component.enable_animations = config.animations
	
	return component