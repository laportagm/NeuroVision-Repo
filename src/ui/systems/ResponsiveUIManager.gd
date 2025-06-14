class_name ResponsiveUIManager
extends Node

## ResponsiveUIManager - Central coordinator for responsive design systems
##
## Autoload that manages all responsive UI systems including typography,
## layout management, and viewport adaptation for resolution independence.

# === SIGNALS ===
signal responsive_systems_ready()
signal breakpoint_changed(new_breakpoint: String)
signal ui_scale_changed(new_scale: float)

# === PRIVATE VARIABLES ===
var typography: ResponsiveTypography
var layout_manager: ResponsiveLayoutManager  
var viewport_adapter: ViewportAdapter
var _systems_initialized: bool = false

# === PUBLIC METHODS ===
func _ready() -> void:
	name = "ResponsiveUI"
	_initialize_systems()
	_connect_system_signals()
	
	# Ensure we're in the autoload group
	add_to_group("responsive_ui_autoload")
	
	print("[ResponsiveUI] Responsive design systems initialized")

## Get the typography system
## @returns: ResponsiveTypography instance
func get_typography() -> ResponsiveTypography:
	return typography

## Get the layout manager
## @returns: ResponsiveLayoutManager instance  
func get_layout_manager() -> ResponsiveLayoutManager:
	return layout_manager

## Get the viewport adapter
## @returns: ViewportAdapter instance
func get_viewport_adapter() -> ViewportAdapter:
	return viewport_adapter

## Check if all responsive systems are ready
## @returns: True if all systems are initialized
func are_systems_ready() -> bool:
	return _systems_initialized

## Apply responsive design to a Control node
## @param control: Target control node
## @param config: Responsive configuration dictionary
func apply_responsive_design(control: Control, config: Dictionary) -> void:
	if not _systems_initialized:
		push_error("[ResponsiveUI] Systems not ready yet")
		return
	
	# Apply typography if specified
	if config.has("font_style"):
		typography.apply_to_control(control, config.font_style)
	
	# Apply layout management if specified
	if config.has("layout"):
		layout_manager.register_component(control, config.layout)
	
	# Apply responsive sizing if it's a ResponsiveContainer
	if control is ResponsiveContainer and config.has("container"):
		_apply_container_config(control, config.container)

## Get current breakpoint across all systems
## @returns: Current breakpoint name
func get_current_breakpoint() -> String:
	if layout_manager:
		return layout_manager.get_current_breakpoint()
	return "desktop"  # fallback

## Get current UI scale
## @returns: Current UI scale factor
func get_current_ui_scale() -> float:
	if viewport_adapter:
		return viewport_adapter.get_ui_scale()
	return 1.0  # fallback

## Set UI scale across all systems
## @param scale: New UI scale factor
## @param animate: Whether to animate the transition
func set_ui_scale(scale: float, animate: bool = false) -> void:
	if viewport_adapter:
		viewport_adapter.set_ui_scale(scale, animate)

## Auto-adapt all systems to current display
func auto_adapt_all() -> void:
	if viewport_adapter:
		viewport_adapter.auto_adapt()

## Get responsive spacing value
## @param size: Spacing size name (xs, sm, md, lg, xl, xxl)
## @returns: Spacing value in pixels
func get_spacing(size: String) -> int:
	if layout_manager:
		return layout_manager.get_responsive_spacing(size)
	return 16  # fallback

## Get fluid font size for text style
## @param style: Font style name
## @returns: Font size in pixels
func get_font_size(style: String) -> int:
	if typography:
		return typography.get_fluid_font_size(style)
	return 16  # fallback

## Create a responsive container with configuration
## @param config: Container configuration
## @returns: Configured ResponsiveContainer instance
func create_responsive_container(config: Dictionary = {}) -> ResponsiveContainer:
	var container = ResponsiveContainer.new()
	
	if config.has("width_mode"):
		container.width_mode = config.width_mode
	if config.has("height_mode"):
		container.height_mode = config.height_mode
	if config.has("layout_direction"):
		container.layout_direction = config.layout_direction
	if config.has("responsive_columns"):
		container.responsive_columns = config.responsive_columns
	
	return container

## Enable responsive design for an entire scene tree
## @param root: Root node of the scene
## @param recursive: Whether to apply recursively to children
func enable_responsive_scene(root: Node, recursive: bool = true) -> void:
	if not root:
		return
	
	# Apply to root if it's a Control
	if root is Control:
		_auto_configure_control(root)
	
	# Apply recursively if requested
	if recursive:
		for child in root.get_children():
			enable_responsive_scene(child, true)

## Get comprehensive system status
## @returns: Dictionary with system information
func get_system_status() -> Dictionary:
	return {
		"initialized": _systems_initialized,
		"breakpoint": get_current_breakpoint(),
		"ui_scale": get_current_ui_scale(),
		"dpi": viewport_adapter.get_current_dpi() if viewport_adapter else 96.0,
		"viewport_size": get_viewport().size,
		"systems": {
			"typography": typography != null,
			"layout_manager": layout_manager != null,
			"viewport_adapter": viewport_adapter != null
		}
	}

# === PRIVATE METHODS ===
func _initialize_systems() -> void:
	# Create typography system
	typography = ResponsiveTypography.new()
	typography.name = "ResponsiveTypography"
	add_child(typography)
	
	# Create layout manager
	layout_manager = ResponsiveLayoutManager.new()
	layout_manager.name = "ResponsiveLayoutManager"
	add_child(layout_manager)
	
	# Create viewport adapter
	viewport_adapter = ViewportAdapter.new()
	viewport_adapter.name = "ViewportAdapter"
	add_child(viewport_adapter)
	
	_systems_initialized = true
	responsive_systems_ready.emit()

func _connect_system_signals() -> void:
	if layout_manager:
		layout_manager.breakpoint_changed.connect(_on_breakpoint_changed)
	
	if viewport_adapter:
		viewport_adapter.ui_scale_changed.connect(_on_ui_scale_changed)

func _on_breakpoint_changed(old_breakpoint: String, new_breakpoint: String) -> void:
	breakpoint_changed.emit(new_breakpoint)

func _on_ui_scale_changed(old_scale: float, new_scale: float) -> void:
	ui_scale_changed.emit(new_scale)

func _apply_container_config(container: ResponsiveContainer, config: Dictionary) -> void:
	if config.has("width"):
		var width_config = config.width
		container.set_responsive_width(
			width_config.get("mode", ResponsiveContainer.SizingMode.PERCENTAGE),
			width_config.get("value", 100.0),
			width_config.get("min", 0.0),
			width_config.get("max", 0.0)
		)
	
	if config.has("height"):
		var height_config = config.height
		container.set_responsive_height(
			height_config.get("mode", ResponsiveContainer.SizingMode.CONTENT),
			height_config.get("value", 0.0),
			height_config.get("min", 0.0),
			height_config.get("max", 0.0)
		)

func _auto_configure_control(control: Control) -> void:
	# Auto-configure common control types with responsive design
	
	if control is Label:
		var style = "body"
		if control.name.to_lower().contains("title"):
			style = "title"
		elif control.name.to_lower().contains("headline"):
			style = "headline"
		
		typography.apply_to_control(control, style)
	
	elif control is Button:
		typography.apply_to_control(control, "body")
		
		# Add responsive button behavior
		var button_config = {
			"layout": {
				"sizing": {
					"width": "auto",
					"height": "auto"
				},
				"margins": {
					"left": "sm",
					"right": "sm",
					"top": "xs",
					"bottom": "xs"
				}
			}
		}
		layout_manager.register_component(control, button_config.layout)
	
	elif control is Container:
		# Convert regular containers to responsive containers if beneficial
		if control.get_child_count() > 1:
			var layout_config = {
				"sizing": {
					"width": "100%",
					"height": "auto"
				}
			}
			layout_manager.register_component(control, layout_config)