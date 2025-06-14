class_name ResponsiveLayoutManager
extends Node

## ResponsiveLayoutManager - Adaptive layout system for different screen sizes
##
## Manages responsive layout behavior including:
## - Breakpoint-based layout switching
## - Container sizing and positioning
## - Adaptive margin and padding
## - Component visibility based on screen size

# === CONSTANTS ===
## Layout breakpoints matching typography system
const BREAKPOINTS = {
	"mobile": 640,
	"tablet": 1024, 
	"desktop": 1920,
	"ultra_wide": 2560
}

## Standard margin/padding multipliers for different breakpoints
const SPACING_MULTIPLIERS = {
	"mobile": 0.75,
	"tablet": 1.0,
	"desktop": 1.25,
	"ultra_wide": 1.5
}

## Base spacing values (in pixels)
const BASE_SPACING = {
	"xs": 4,
	"sm": 8,
	"md": 16,
	"lg": 24,
	"xl": 32,
	"xxl": 48
}

# === SIGNALS ===
signal breakpoint_changed(old_breakpoint: String, new_breakpoint: String)
signal layout_updated(breakpoint: String)

# === PRIVATE VARIABLES ===
var _current_breakpoint: String = ""
var _registered_components: Dictionary = {}
var _update_timer: Timer

# === PUBLIC METHODS ===
func _ready() -> void:
	_setup_viewport_monitoring()
	_update_current_breakpoint()
	
	# Setup debounce timer
	_update_timer = Timer.new()
	_update_timer.wait_time = 0.1
	_update_timer.one_shot = true
	_update_timer.timeout.connect(_apply_layout_changes)
	add_child(_update_timer)

## Register a component for responsive layout management
## @param component: The Control node to manage
## @param config: Layout configuration dictionary
func register_component(component: Control, config: Dictionary) -> void:
	if not is_instance_valid(component):
		push_error("[ResponsiveLayoutManager] Invalid component provided")
		return
	
	_registered_components[component.get_instance_id()] = {
		"node": component,
		"config": config
	}
	
	# Apply initial layout
	_apply_component_layout(component, config)

## Unregister a component
## @param component: The Control node to unregister
func unregister_component(component: Control) -> void:
	if is_instance_valid(component):
		_registered_components.erase(component.get_instance_id())

## Get responsive spacing value
## @param size: Spacing size key (xs, sm, md, lg, xl, xxl)
## @returns: Calculated spacing in pixels
func get_responsive_spacing(size: String) -> int:
	if not BASE_SPACING.has(size):
		push_error("[ResponsiveLayoutManager] Unknown spacing size: " + size)
		return BASE_SPACING.md
	
	var multiplier = SPACING_MULTIPLIERS.get(_current_breakpoint, 1.0)
	return int(BASE_SPACING[size] * multiplier)

## Get current breakpoint
## @returns: Current breakpoint name
func get_current_breakpoint() -> String:
	return _current_breakpoint

## Check if current breakpoint matches condition
## @param condition: Breakpoint condition (e.g., ">=tablet", "mobile", "<desktop")
## @returns: Whether condition is met
func matches_breakpoint(condition: String) -> bool:
	var breakpoint_order = ["mobile", "tablet", "desktop", "ultra_wide"]
	var current_index = breakpoint_order.find(_current_breakpoint)
	
	if condition.begins_with(">="):
		var target = condition.substr(2)
		var target_index = breakpoint_order.find(target)
		return current_index >= target_index
	elif condition.begins_with("<="):
		var target = condition.substr(2)
		var target_index = breakpoint_order.find(target)
		return current_index <= target_index
	elif condition.begins_with(">"):
		var target = condition.substr(1)
		var target_index = breakpoint_order.find(target)
		return current_index > target_index
	elif condition.begins_with("<"):
		var target = condition.substr(1)
		var target_index = breakpoint_order.find(target)
		return current_index < target_index
	else:
		return _current_breakpoint == condition

## Apply responsive margins to a control
## @param control: Target control
## @param margins: Margin configuration
func apply_responsive_margins(control: Control, margins: Dictionary) -> void:
	for side in ["left", "top", "right", "bottom"]:
		if margins.has(side):
			var margin_size = get_responsive_spacing(margins[side])
			match side:
				"left":
					control.position.x = margin_size
				"top":
					control.position.y = margin_size
				"right":
					control.size.x = control.get_parent().size.x - control.position.x - margin_size
				"bottom":
					control.size.y = control.get_parent().size.y - control.position.y - margin_size

# === PRIVATE METHODS ===
func _setup_viewport_monitoring() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed() -> void:
	_update_timer.start()

func _apply_layout_changes() -> void:
	var old_breakpoint = _current_breakpoint
	_update_current_breakpoint()
	
	if old_breakpoint != _current_breakpoint:
		breakpoint_changed.emit(old_breakpoint, _current_breakpoint)
	
	_update_all_components()
	layout_updated.emit(_current_breakpoint)

func _update_current_breakpoint() -> void:
	var width = get_viewport().size.x
	
	if width <= BREAKPOINTS.mobile:
		_current_breakpoint = "mobile"
	elif width <= BREAKPOINTS.tablet:
		_current_breakpoint = "tablet"  
	elif width <= BREAKPOINTS.desktop:
		_current_breakpoint = "desktop"
	else:
		_current_breakpoint = "ultra_wide"

func _update_all_components() -> void:
	for component_data in _registered_components.values():
		var component = component_data.node
		var config = component_data.config
		
		if is_instance_valid(component):
			_apply_component_layout(component, config)

func _apply_component_layout(component: Control, config: Dictionary) -> void:
	# Apply breakpoint-specific visibility
	if config.has("visibility"):
		var visibility_config = config.visibility
		var should_show = true
		
		for breakpoint in visibility_config:
			if matches_breakpoint(breakpoint):
				should_show = visibility_config[breakpoint]
				break
		
		component.visible = should_show
	
	# Apply responsive sizing
	if config.has("sizing"):
		_apply_responsive_sizing(component, config.sizing)
	
	# Apply responsive positioning
	if config.has("positioning"):
		_apply_responsive_positioning(component, config.positioning)
	
	# Apply responsive margins/padding
	if config.has("margins"):
		apply_responsive_margins(component, config.margins)

func _apply_responsive_sizing(component: Control, sizing_config: Dictionary) -> void:
	var viewport_size = get_viewport().size
	
	# Handle width
	if sizing_config.has("width"):
		var width_config = sizing_config.width
		if width_config is String:
			if width_config.ends_with("%"):
				var percentage = float(width_config.trim_suffix("%")) / 100.0
				component.size.x = viewport_size.x * percentage
			elif width_config.ends_with("vw"):
				var vw = float(width_config.trim_suffix("vw"))
				component.size.x = viewport_size.x * (vw / 100.0)
		elif width_config is int:
			component.size.x = width_config
	
	# Handle height  
	if sizing_config.has("height"):
		var height_config = sizing_config.height
		if height_config is String:
			if height_config.ends_with("%"):
				var percentage = float(height_config.trim_suffix("%")) / 100.0
				component.size.y = viewport_size.y * percentage
			elif height_config.ends_with("vh"):
				var vh = float(height_config.trim_suffix("vh"))
				component.size.y = viewport_size.y * (vh / 100.0)
		elif height_config is int:
			component.size.y = height_config

func _apply_responsive_positioning(component: Control, positioning_config: Dictionary) -> void:
	var viewport_size = get_viewport().size
	
	# Handle anchoring for responsive positioning
	if positioning_config.has("anchor"):
		var anchor = positioning_config.anchor
		match anchor:
			"center":
				component.position = (viewport_size - component.size) / 2
			"top_left":
				component.position = Vector2.ZERO
			"top_right":
				component.position = Vector2(viewport_size.x - component.size.x, 0)
			"bottom_left":
				component.position = Vector2(0, viewport_size.y - component.size.y)
			"bottom_right":
				component.position = viewport_size - component.size