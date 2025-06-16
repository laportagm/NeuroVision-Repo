## LayoutManager.gd
## Responsive layout management system for NeuroVision
##
## This manager handles:
## - Responsive breakpoint detection and management
## - Dynamic layout switching based on viewport size
## - Grid and flexbox layout systems
## - Component repositioning and resizing
## - Orientation change handling
## - Multi-window support

class_name LayoutManager
extends Node

# === SIGNALS ===
signal breakpoint_changed(old_breakpoint: String, new_breakpoint: String)
signal orientation_changed(orientation: String)
signal viewport_resized(new_size: Vector2)
signal layout_updated(layout_name: String)
signal density_changed(density: String)

# === CONSTANTS ===
# Breakpoint definitions (in pixels)
const BREAKPOINTS = {
	"xs": 0,      # Extra small (phones)
	"sm": 600,    # Small (large phones)
	"md": 960,    # Medium (tablets)
	"lg": 1280,   # Large (laptops)
	"xl": 1920,   # Extra large (desktops)
	"xxl": 2560   # Ultra wide (4K+)
}

# Layout spacing scale
const SPACING_SCALE = {
	"none": 0,
	"xs": 4,
	"sm": 8,
	"md": 16,
	"lg": 24,
	"xl": 32,
	"xxl": 48
}

# Grid system
const GRID_COLUMNS = 12
const GRID_GUTTER_DEFAULT = 16

# === ENUMS ===
enum Orientation {
	PORTRAIT,
	LANDSCAPE,
	SQUARE
}

enum LayoutType {
	NONE,
	FLEX,
	GRID,
	ABSOLUTE,
	RESPONSIVE
}

enum FlexDirection {
	ROW,
	ROW_REVERSE,
	COLUMN,
	COLUMN_REVERSE
}

enum AlignItems {
	START,
	CENTER,
	END,
	STRETCH,
	BASELINE
}

enum JustifyContent {
	START,
	CENTER,
	END,
	SPACE_BETWEEN,
	SPACE_AROUND,
	SPACE_EVENLY
}

# === PRIVATE VARIABLES ===
var _current_breakpoint: String = "md"
var _current_orientation: Orientation = Orientation.LANDSCAPE
var _current_density: String = "comfortable"  # compact, comfortable, spacious
var _viewport_size: Vector2
var _last_viewport_size: Vector2

# Layout configurations per breakpoint
var _layouts: Dictionary = {}  # layout_name: LayoutConfig
var _active_layouts: Dictionary = {}  # node: LayoutConfig

# Responsive rules
var _responsive_rules: Array[ResponsiveRule] = []

# Performance
var _update_timer: Timer
var _pending_updates: Array[Node] = []
var _is_batch_updating: bool = false

# Configuration
var _config: Dictionary = {
	"enable_auto_layout": true,
	"update_delay": 0.1,  # Debounce resize events
	"enable_orientation_detection": true,
	"enable_density_scaling": true,
	"default_transition_duration": 0.3
}

# === INNER CLASSES ===

class LayoutConfig:
	var type: LayoutType = LayoutType.NONE
	var properties: Dictionary = {}
	var breakpoint_overrides: Dictionary = {}  # breakpoint: properties
	
	func get_properties_for_breakpoint(breakpoint: String) -> Dictionary:
		if breakpoint_overrides.has(breakpoint):
			var props = properties.duplicate()
			props.merge(breakpoint_overrides[breakpoint], true)
			return props
		return properties

class ResponsiveRule:
	var target_property: String
	var breakpoint_values: Dictionary = {}  # breakpoint: value
	var interpolate: bool = false
	var transition_duration: float = 0.3

class GridLayoutConfig extends LayoutConfig:
	func _init() -> void:
		type = LayoutType.GRID
		properties = {
			"columns": GRID_COLUMNS,
			"rows": "auto",
			"gap": GRID_GUTTER_DEFAULT,
			"align_items": AlignItems.STRETCH,
			"justify_items": JustifyContent.START
		}

class FlexLayoutConfig extends LayoutConfig:
	func _init() -> void:
		type = LayoutType.FLEX
		properties = {
			"direction": FlexDirection.ROW,
			"wrap": true,
			"align_items": AlignItems.STRETCH,
			"justify_content": JustifyContent.START,
			"gap": SPACING_SCALE.sm
		}

# === INITIALIZATION ===

func _ready() -> void:
	_setup_viewport_monitoring()
	_setup_update_timer()
	_initialize_default_layouts()
	
	# Get initial viewport size
	_viewport_size = get_viewport().get_visible_rect().size
	_update_breakpoint()
	_update_orientation()
	
	print("[LayoutManager] Responsive layout system initialized")

func _setup_viewport_monitoring() -> void:
	"""Set up viewport size monitoring"""
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	# Also monitor window events if available
	if OS.has_feature("pc"):
		get_window().size_changed.connect(_on_viewport_size_changed)

func _setup_update_timer() -> void:
	"""Set up debounced update timer"""
	_update_timer = Timer.new()
	_update_timer.wait_time = _config.update_delay
	_update_timer.one_shot = true
	_update_timer.timeout.connect(_process_pending_updates)
	add_child(_update_timer)

func _initialize_default_layouts() -> void:
	"""Register default layout configurations"""
	# Default grid layout
	register_layout("default_grid", GridLayoutConfig.new())
	
	# Default flex layout
	register_layout("default_flex", FlexLayoutConfig.new())
	
	# Mobile-first responsive layout
	var mobile_layout = FlexLayoutConfig.new()
	mobile_layout.properties.direction = FlexDirection.COLUMN
	mobile_layout.breakpoint_overrides = {
		"md": {"direction": FlexDirection.ROW},
		"lg": {"direction": FlexDirection.ROW, "gap": SPACING_SCALE.lg}
	}
	register_layout("mobile_first", mobile_layout)

# === PUBLIC API ===

## Breakpoint Management

func get_current_breakpoint() -> String:
	"""Get the current responsive breakpoint"""
	return _current_breakpoint

func get_breakpoint_for_width(width: float) -> String:
	"""Get breakpoint name for a given width"""
	var result = "xs"
	for bp in BREAKPOINTS:
		if width >= BREAKPOINTS[bp]:
			result = bp
		else:
			break
	return result

func is_breakpoint_active(breakpoint: String) -> bool:
	"""Check if viewport is at or above a breakpoint"""
	var current_width = _viewport_size.x
	var breakpoint_width = BREAKPOINTS.get(breakpoint, 0)
	return current_width >= breakpoint_width

func get_breakpoint_range() -> Dictionary:
	"""Get min and max width for current breakpoint"""
	var current_idx = BREAKPOINTS.keys().find(_current_breakpoint)
	var min_width = BREAKPOINTS[_current_breakpoint]
	var max_width = INF
	
	if current_idx < BREAKPOINTS.size() - 1:
		var next_bp = BREAKPOINTS.keys()[current_idx + 1]
		max_width = BREAKPOINTS[next_bp] - 1
	
	return {"min": min_width, "max": max_width}

## Layout Registration and Application

func register_layout(name: String, config: LayoutConfig) -> void:
	"""Register a layout configuration"""
	_layouts[name] = config
	print("[LayoutManager] Registered layout: %s" % name)

func apply_layout(node: Control, layout_name: String) -> void:
	"""Apply a layout configuration to a node"""
	if not _layouts.has(layout_name):
		push_error("[LayoutManager] Unknown layout: %s" % layout_name)
		return
	
	var config = _layouts[layout_name]
	_active_layouts[node] = config
	
	# Apply layout based on type
	match config.type:
		LayoutType.GRID:
			_apply_grid_layout(node, config)
		LayoutType.FLEX:
			_apply_flex_layout(node, config)
		LayoutType.RESPONSIVE:
			_apply_responsive_layout(node, config)
	
	# Connect to node signals
	if not node.tree_exited.is_connected(_on_node_exited):
		node.tree_exited.connect(_on_node_exited.bind(node))

func remove_layout(node: Control) -> void:
	"""Remove layout from a node"""
	_active_layouts.erase(node)
	_pending_updates.erase(node)

## Grid System

func create_grid_container(columns: int = GRID_COLUMNS, gap: float = GRID_GUTTER_DEFAULT) -> Control:
	"""Create a grid container"""
	var container = Control.new()
	container.set_script(preload("res://src/ui_new/core/managers/GridContainer.gd"))
	
	var grid_config = GridLayoutConfig.new()
	grid_config.properties.columns = columns
	grid_config.properties.gap = gap
	
	apply_layout(container, "custom_grid")
	return container

func set_grid_column(node: Control, column: int, span: int = 1) -> void:
	"""Set grid column position for a node"""
	node.set_meta("grid_column", column)
	node.set_meta("grid_column_span", span)
	_queue_layout_update(node.get_parent())

func set_grid_row(node: Control, row: int, span: int = 1) -> void:
	"""Set grid row position for a node"""
	node.set_meta("grid_row", row)
	node.set_meta("grid_row_span", span)
	_queue_layout_update(node.get_parent())

## Flex System

func create_flex_container(direction: FlexDirection = FlexDirection.ROW) -> Control:
	"""Create a flex container"""
	var container = Control.new()
	
	var flex_config = FlexLayoutConfig.new()
	flex_config.properties.direction = direction
	
	apply_layout(container, "custom_flex")
	return container

func set_flex_grow(node: Control, grow: float) -> void:
	"""Set flex grow factor for a node"""
	node.set_meta("flex_grow", grow)
	_queue_layout_update(node.get_parent())

func set_flex_shrink(node: Control, shrink: float) -> void:
	"""Set flex shrink factor for a node"""
	node.set_meta("flex_shrink", shrink)
	_queue_layout_update(node.get_parent())

func set_flex_basis(node: Control, basis: float) -> void:
	"""Set flex basis for a node"""
	node.set_meta("flex_basis", basis)
	_queue_layout_update(node.get_parent())

## Responsive Rules

func add_responsive_rule(node: Control, property: String, values: Dictionary, interpolate: bool = false) -> void:
	"""Add a responsive rule for a node property"""
	var rule = ResponsiveRule.new()
	rule.target_property = property
	rule.breakpoint_values = values
	rule.interpolate = interpolate
	
	if not node.has_meta("responsive_rules"):
		node.set_meta("responsive_rules", [])
	
	var rules: Array = node.get_meta("responsive_rules")
	rules.append(rule)
	
	# Apply immediately
	_apply_responsive_rules(node)

func set_responsive_visibility(node: Control, breakpoints: Array[String]) -> void:
	"""Set node visibility for specific breakpoints"""
	var values = {}
	for bp in BREAKPOINTS:
		values[bp] = bp in breakpoints
	
	add_responsive_rule(node, "visible", values)

## Spacing and Sizing

func get_spacing(size: String) -> float:
	"""Get spacing value from scale"""
	return SPACING_SCALE.get(size, SPACING_SCALE.md)

func get_responsive_value(base_value: float, breakpoint: String = "") -> float:
	"""Get value adjusted for current breakpoint"""
	if breakpoint.is_empty():
		breakpoint = _current_breakpoint
	
	# Scale based on breakpoint
	var scale_factors = {
		"xs": 0.85,
		"sm": 0.9,
		"md": 1.0,
		"lg": 1.1,
		"xl": 1.2,
		"xxl": 1.3
	}
	
	return base_value * scale_factors.get(breakpoint, 1.0)

## Orientation and Density

func get_orientation() -> String:
	"""Get current orientation"""
	return Orientation.keys()[_current_orientation]

func get_density() -> String:
	"""Get current density setting"""
	return _current_density

func set_density(density: String) -> void:
	"""Set UI density (compact, comfortable, spacious)"""
	if density in ["compact", "comfortable", "spacious"]:
		_current_density = density
		density_changed.emit(density)
		_update_all_layouts()

# === PRIVATE METHODS ===

func _on_viewport_size_changed() -> void:
	"""Handle viewport size change"""
	_viewport_size = get_viewport().get_visible_rect().size
	
	# Debounce updates
	_update_timer.stop()
	_update_timer.start()
	
	# Check for breakpoint change
	var new_breakpoint = get_breakpoint_for_width(_viewport_size.x)
	if new_breakpoint != _current_breakpoint:
		var old_breakpoint = _current_breakpoint
		_current_breakpoint = new_breakpoint
		breakpoint_changed.emit(old_breakpoint, new_breakpoint)
		_update_all_layouts()
	
	# Check for orientation change
	_update_orientation()
	
	viewport_resized.emit(_viewport_size)

func _update_breakpoint() -> void:
	"""Update current breakpoint based on viewport width"""
	_current_breakpoint = get_breakpoint_for_width(_viewport_size.x)

func _update_orientation() -> void:
	"""Update current orientation"""
	var old_orientation = _current_orientation
	
	if abs(_viewport_size.x - _viewport_size.y) < 100:
		_current_orientation = Orientation.SQUARE
	elif _viewport_size.x > _viewport_size.y:
		_current_orientation = Orientation.LANDSCAPE
	else:
		_current_orientation = Orientation.PORTRAIT
	
	if old_orientation != _current_orientation:
		orientation_changed.emit(Orientation.keys()[_current_orientation])

func _queue_layout_update(node: Node) -> void:
	"""Queue a layout update for a node"""
	if not node in _pending_updates:
		_pending_updates.append(node)
	
	if not _is_batch_updating:
		_update_timer.stop()
		_update_timer.start()

func _process_pending_updates() -> void:
	"""Process all pending layout updates"""
	_is_batch_updating = true
	
	for node in _pending_updates:
		if is_instance_valid(node) and _active_layouts.has(node):
			var config = _active_layouts[node]
			match config.type:
				LayoutType.GRID:
					_apply_grid_layout(node, config)
				LayoutType.FLEX:
					_apply_flex_layout(node, config)
				LayoutType.RESPONSIVE:
					_apply_responsive_layout(node, config)
	
	_pending_updates.clear()
	_is_batch_updating = false

func _update_all_layouts() -> void:
	"""Update all active layouts"""
	for node in _active_layouts:
		if is_instance_valid(node):
			_queue_layout_update(node)

func _apply_grid_layout(container: Control, config: LayoutConfig) -> void:
	"""Apply grid layout to container children"""
	var props = config.get_properties_for_breakpoint(_current_breakpoint)
	var columns = props.get("columns", GRID_COLUMNS)
	var gap = props.get("gap", GRID_GUTTER_DEFAULT)
	
	var column_width = (container.size.x - gap * (columns - 1)) / columns
	var current_row = 0
	var current_col = 0
	
	for child in container.get_children():
		if not child is Control or not child.visible:
			continue
		
		# Get grid position from metadata
		var col = child.get_meta("grid_column", current_col)
		var col_span = child.get_meta("grid_column_span", 1)
		var row = child.get_meta("grid_row", current_row)
		var row_span = child.get_meta("grid_row_span", 1)
		
		# Calculate position and size
		var x = col * (column_width + gap)
		var y = row * (child.size.y + gap)
		var width = column_width * col_span + gap * (col_span - 1)
		
		# Apply with animation if enabled
		_animate_layout_change(child, Vector2(x, y), Vector2(width, child.size.y))
		
		# Auto-flow to next position
		current_col += col_span
		if current_col >= columns:
			current_col = 0
			current_row += 1

func _apply_flex_layout(container: Control, config: LayoutConfig) -> void:
	"""Apply flex layout to container children"""
	var props = config.get_properties_for_breakpoint(_current_breakpoint)
	var direction = props.get("direction", FlexDirection.ROW)
	var wrap = props.get("wrap", true)
	var gap = props.get("gap", SPACING_SCALE.sm)
	var align = props.get("align_items", AlignItems.STRETCH)
	var justify = props.get("justify_content", JustifyContent.START)
	
	# Calculate flex layout
	var is_horizontal = direction in [FlexDirection.ROW, FlexDirection.ROW_REVERSE]
	var main_size = container.size.x if is_horizontal else container.size.y
	var cross_size = container.size.y if is_horizontal else container.size.x
	
	# Group children into lines for wrapping
	var lines = _calculate_flex_lines(container, main_size, gap, is_horizontal, wrap)
	
	# Apply layout to each line
	var cross_position = 0
	for line in lines:
		_layout_flex_line(line, main_size, cross_size, gap, align, justify, is_horizontal)
		cross_position += line.cross_size + gap

func _calculate_flex_lines(container: Control, main_size: float, gap: float, is_horizontal: bool, wrap: bool) -> Array:
	"""Calculate flex lines for wrapping"""
	var lines = []
	var current_line = {"children": [], "main_size": 0, "cross_size": 0}
	
	for child in container.get_children():
		if not child is Control or not child.visible:
			continue
		
		var child_main_size = child.size.x if is_horizontal else child.size.y
		var child_cross_size = child.size.y if is_horizontal else child.size.x
		
		# Check if child fits in current line
		if wrap and current_line.main_size + child_main_size + gap > main_size and current_line.children.size() > 0:
			lines.append(current_line)
			current_line = {"children": [], "main_size": 0, "cross_size": 0}
		
		current_line.children.append(child)
		current_line.main_size += child_main_size + gap
		current_line.cross_size = max(current_line.cross_size, child_cross_size)
	
	if current_line.children.size() > 0:
		lines.append(current_line)
	
	return lines

func _layout_flex_line(line: Dictionary, main_size: float, cross_size: float, gap: float, align: int, justify: int, is_horizontal: bool) -> void:
	"""Layout a single flex line"""
	# Implementation would calculate positions based on justify and align
	# This is a simplified version
	var main_position = 0
	
	for child in line.children:
		var pos = Vector2()
		if is_horizontal:
			pos.x = main_position
			pos.y = 0  # Would be calculated based on align
		else:
			pos.x = 0  # Would be calculated based on align
			pos.y = main_position
		
		_animate_layout_change(child, pos, child.size)
		
		var child_main_size = child.size.x if is_horizontal else child.size.y
		main_position += child_main_size + gap

func _apply_responsive_layout(node: Control, config: LayoutConfig) -> void:
	"""Apply responsive layout rules"""
	_apply_responsive_rules(node)

func _apply_responsive_rules(node: Control) -> void:
	"""Apply responsive rules to a node"""
	if not node.has_meta("responsive_rules"):
		return
	
	var rules: Array = node.get_meta("responsive_rules")
	for rule in rules:
		if rule is ResponsiveRule:
			var value = _get_responsive_value_for_rule(rule)
			_apply_property_value(node, rule.target_property, value, rule.transition_duration)

func _get_responsive_value_for_rule(rule: ResponsiveRule) -> Variant:
	"""Get value for current breakpoint from rule"""
	# Find the appropriate value for current breakpoint
	var value = null
	var found = false
	
	for bp in BREAKPOINTS.keys():
		if rule.breakpoint_values.has(bp):
			value = rule.breakpoint_values[bp]
		
		if bp == _current_breakpoint:
			found = true
			break
	
	return value

func _apply_property_value(node: Control, property: String, value: Variant, duration: float) -> void:
	"""Apply a property value to a node"""
	if property in node:
		if duration > 0 and _config.enable_auto_layout:
			_animate_property_change(node, property, value, duration)
		else:
			node.set(property, value)

func _animate_layout_change(node: Control, new_position: Vector2, new_size: Vector2) -> void:
	"""Animate position and size changes"""
	if not _config.enable_auto_layout:
		node.position = new_position
		node.size = new_size
		return
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(node, "position", new_position, _config.default_transition_duration)
	tween.tween_property(node, "size", new_size, _config.default_transition_duration)

func _animate_property_change(node: Control, property: String, value: Variant, duration: float) -> void:
	"""Animate a property change"""
	var tween = create_tween()
	tween.tween_property(node, property, value, duration)

func _on_node_exited(node: Node) -> void:
	"""Clean up when a node exits the tree"""
	remove_layout(node)

# === UTILITY METHODS ===

func get_viewport_info() -> Dictionary:
	"""Get current viewport information"""
	return {
		"size": _viewport_size,
		"breakpoint": _current_breakpoint,
		"orientation": Orientation.keys()[_current_orientation],
		"density": _current_density,
		"breakpoint_range": get_breakpoint_range()
	}

func get_debug_info() -> Dictionary:
	"""Get debug information"""
	return {
		"viewport_size": _viewport_size,
		"current_breakpoint": _current_breakpoint,
		"current_orientation": Orientation.keys()[_current_orientation],
		"current_density": _current_density,
		"active_layouts": _active_layouts.size(),
		"pending_updates": _pending_updates.size(),
		"registered_layouts": _layouts.keys()
	}