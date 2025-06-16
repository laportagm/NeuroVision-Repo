class_name ResponsiveContainer
extends Container

## ResponsiveContainer - Adaptive container with fluid sizing and responsive behavior
##
## A container that automatically adapts its size, layout, and child positioning
## based on viewport dimensions and breakpoints.

# === CONSTANTS ===
## Responsive sizing modes
enum SizingMode {
    FIXED,          # Fixed pixel size
    PERCENTAGE,     # Percentage of parent
    VIEWPORT,       # Percentage of viewport
    CONTENT,        # Size to fit content
    FLUID           # Fluid between min/max
}

## Layout directions for responsive behavior
enum ResponsiveDirection {
    HORIZONTAL,     # Arrange children horizontally
    VERTICAL,       # Arrange children vertically
    GRID,           # Grid layout
    FLEX            # Flexible layout
}

# === EXPORTS ===
@export_group("Responsive Sizing")
@export var width_mode: SizingMode = SizingMode.PERCENTAGE
@export var height_mode: SizingMode = SizingMode.CONTENT
@export var width_value: float = 100.0
@export var height_value: float = 0.0
@export var min_width: float = 0.0
@export var max_width: float = 0.0
@export var min_height: float = 0.0
@export var max_height: float = 0.0

@export_group("Responsive Layout")
@export var layout_direction: ResponsiveDirection = ResponsiveDirection.VERTICAL
@export var responsive_columns: int = 1
@export var adaptive_columns: bool = true
@export var column_gap: float = 16.0
@export var row_gap: float = 16.0

@export_group("Responsive Breakpoints")
@export var mobile_columns: int = 1
@export var tablet_columns: int = 2
@export var desktop_columns: int = 3
@export var ultrawide_columns: int = 4

@export_group("Responsive Padding")
@export var responsive_padding: bool = true
@export var padding_left: String = "md"
@export var padding_top: String = "md"
@export var padding_right: String = "md"
@export var padding_bottom: String = "md"

# === SIGNALS ===
signal container_resized(new_size: Vector2)
signal layout_changed(direction: ResponsiveDirection, columns: int)
signal breakpoint_adapted(new_breakpoint: String)

# === PRIVATE VARIABLES ===
var _typography_system: ResponsiveTypography
var _layout_manager: ResponsiveLayoutManager
var _viewport_adapter: ViewportAdapter
var _current_columns: int = 1
var _is_adapting: bool = false

# === PUBLIC METHODS ===
func _ready() -> void:
    _initialize_responsive_systems()
    _setup_container_monitoring()
    _apply_initial_layout()

## Force container to recalculate and apply responsive layout
func refresh_layout() -> void:
    if _is_adapting:
        return
    
    _is_adapting = true
    _apply_responsive_sizing()
    _apply_responsive_layout()
    _apply_responsive_spacing()
    _is_adapting = false

## Set responsive sizing for width
## @param mode: Sizing mode (FIXED, PERCENTAGE, VIEWPORT, CONTENT, FLUID)
## @param value: Size value based on mode
## @param min_val: Minimum size constraint (optional)
## @param max_val: Maximum size constraint (optional)
func set_responsive_width(mode: SizingMode, value: float, min_val: float = 0.0, max_val: float = 0.0) -> void:
    width_mode = mode
    width_value = value
    min_width = min_val
    max_width = max_val
    refresh_layout()

## Set responsive sizing for height
## @param mode: Sizing mode (FIXED, PERCENTAGE, VIEWPORT, CONTENT, FLUID)
## @param value: Size value based on mode
## @param min_val: Minimum size constraint (optional)
## @param max_val: Maximum size constraint (optional)
func set_responsive_height(mode: SizingMode, value: float, min_val: float = 0.0, max_val: float = 0.0) -> void:
    height_mode = mode
    height_value = value
    min_height = min_val
    max_height = max_val
    refresh_layout()

## Get current responsive columns based on breakpoint
## @returns: Number of columns for current breakpoint
func get_current_columns() -> int:
    return _current_columns

## Add child with responsive configuration
## @param child: Child node to add
## @param config: Responsive configuration dictionary
func add_responsive_child(child: Control, config: Dictionary = {}) -> void:
    add_child(child)
    
    # Apply responsive configuration to child
    if config.has("width_mode"):
        child.set_meta("responsive_width_mode", config.width_mode)
    if config.has("height_mode"):
        child.set_meta("responsive_height_mode", config.height_mode)
    if config.has("min_width"):
        child.set_meta("responsive_min_width", config.min_width)
    if config.has("max_width"):
        child.set_meta("responsive_max_width", config.max_width)
    
    refresh_layout()

## Remove child and refresh layout
## @param child: Child node to remove
func remove_responsive_child(child: Control) -> void:
    if child.get_parent() == self:
        remove_child(child)
        refresh_layout()

## Set layout direction with animation
## @param direction: New layout direction
## @param animate: Whether to animate the transition
func set_layout_direction(direction: ResponsiveDirection, animate: bool = false) -> void:
    if layout_direction == direction:
        return
    
    layout_direction = direction
    
    if animate:
        _animate_layout_change()
    else:
        refresh_layout()
    
    layout_changed.emit(direction, _current_columns)

# === PRIVATE METHODS ===
func _initialize_responsive_systems() -> void:
    # Get or create responsive systems
    _typography_system = _get_or_create_system("ResponsiveTypography")
    _layout_manager = _get_or_create_system("ResponsiveLayoutManager")
    _viewport_adapter = _get_or_create_system("ViewportAdapter")
    
    # Connect to system signals
    if _layout_manager:
        _layout_manager.breakpoint_changed.connect(_on_breakpoint_changed)
    if _viewport_adapter:
        _viewport_adapter.viewport_adapted.connect(_on_viewport_adapted)

func _get_or_create_system(system_name: String) -> Node:
    # Try to find existing system in scene tree
    var existing = get_tree().get_first_node_in_group(system_name.to_lower())
    if existing:
        return existing
    
    # Create new system if needed
    match system_name:
        "ResponsiveTypography":
            var system = ResponsiveTypography.new()
            system.name = "ResponsiveTypography"
            get_tree().get_first_node_in_group("autoload").add_child(system)
            return system
        "ResponsiveLayoutManager":
            var system = ResponsiveLayoutManager.new()
            system.name = "ResponsiveLayoutManager"
            get_tree().get_first_node_in_group("autoload").add_child(system)
            return system
        "ViewportAdapter":
            var system = ViewportAdapter.new()
            system.name = "ViewportAdapter"
            get_tree().get_first_node_in_group("autoload").add_child(system)
            return system
    
    return null

func _setup_container_monitoring() -> void:
    # Monitor parent size changes
    if get_parent():
        if get_parent().has_signal("resized"):
            get_parent().resized.connect(_on_parent_resized)
    
    # Monitor own size changes
    resized.connect(_on_container_resized)

func _apply_initial_layout() -> void:
    call_deferred("refresh_layout")

func _on_breakpoint_changed(old_breakpoint: String, new_breakpoint: String) -> void:
    _update_responsive_columns(new_breakpoint)
    refresh_layout()
    breakpoint_adapted.emit(new_breakpoint)

func _on_viewport_adapted(scale_factor: float, dpi: float) -> void:
    refresh_layout()

func _on_parent_resized() -> void:
    refresh_layout()

func _on_container_resized() -> void:
    container_resized.emit(size)

func _update_responsive_columns(breakpoint: String) -> void:
    if not adaptive_columns:
        _current_columns = responsive_columns
        return
    
    match breakpoint:
        "mobile":
            _current_columns = mobile_columns
        "tablet":
            _current_columns = tablet_columns
        "desktop":
            _current_columns = desktop_columns
        "ultra_wide":
            _current_columns = ultrawide_columns
        _:
            _current_columns = responsive_columns

func _apply_responsive_sizing() -> void:
    var new_size = Vector2()
    
    # Calculate responsive width
    new_size.x = _calculate_responsive_dimension(
        width_mode, width_value, min_width, max_width, true
    )
    
    # Calculate responsive height
    new_size.y = _calculate_responsive_dimension(
        height_mode, height_value, min_height, max_height, false
    )
    
    # Apply the new size
    if new_size != size:
        size = new_size

func _calculate_responsive_dimension(mode: SizingMode, value: float, min_val: float, max_val: float, is_width: bool) -> float:
    var result: float = 0.0
    var viewport_size = get_viewport().size
    var parent_size = get_parent().size if get_parent() else viewport_size
    
    match mode:
        SizingMode.FIXED:
            result = value
        
        SizingMode.PERCENTAGE:
            var parent_dimension = parent_size.x if is_width else parent_size.y
            result = parent_dimension * (value / 100.0)
        
        SizingMode.VIEWPORT:
            var viewport_dimension = viewport_size.x if is_width else viewport_size.y
            result = viewport_dimension * (value / 100.0)
        
        SizingMode.CONTENT:
            result = _calculate_content_size(is_width)
        
        SizingMode.FLUID:
            # Fluid sizing between min and max based on parent size
            var parent_dimension = parent_size.x if is_width else parent_size.y
            var fluid_factor = clamp(parent_dimension / 1920.0, 0.0, 1.0)  # Use 1920 as reference
            result = min_val + (max_val - min_val) * fluid_factor
    
    # Apply constraints
    if min_val > 0:
        result = max(result, min_val)
    if max_val > 0:
        result = min(result, max_val)
    
    return result

func _calculate_content_size(is_width: bool) -> float:
    var content_size: float = 0.0
    
    for child in get_children():
        if child is Control and child.visible:
            if is_width:
                content_size = max(content_size, child.size.x + child.position.x)
            else:
                content_size += child.size.y
                if child != get_children()[-1]:  # Add gap except for last child
                    content_size += row_gap
    
    return content_size

func _apply_responsive_layout() -> void:
    match layout_direction:
        ResponsiveDirection.HORIZONTAL:
            _apply_horizontal_layout()
        ResponsiveDirection.VERTICAL:
            _apply_vertical_layout()
        ResponsiveDirection.GRID:
            _apply_grid_layout()
        ResponsiveDirection.FLEX:
            _apply_flex_layout()

func _apply_horizontal_layout() -> void:
    var children = _get_visible_children()
    var current_x: float = 0.0
    
    for i in range(children.size()):
        var child = children[i]
        child.position.x = current_x
        current_x += child.size.x
        
        if i < children.size() - 1:
            current_x += column_gap

func _apply_vertical_layout() -> void:
    var children = _get_visible_children()
    var current_y: float = 0.0
    
    for i in range(children.size()):
        var child = children[i]
        child.position.y = current_y
        current_y += child.size.y
        
        if i < children.size() - 1:
            current_y += row_gap

func _apply_grid_layout() -> void:
    var children = _get_visible_children()
    var columns = _current_columns
    var current_x: float = 0.0
    var current_y: float = 0.0
    var column_width = (size.x - (columns - 1) * column_gap) / columns
    var row_height: float = 0.0
    
    for i in range(children.size()):
        var child = children[i]
        var col = i % columns
        var row = i / columns
        
        # Position child
        child.position.x = col * (column_width + column_gap)
        child.position.y = current_y
        
        # Resize child to fit column
        child.size.x = column_width
        
        # Track row height
        row_height = max(row_height, child.size.y)
        
        # Move to next row if needed
        if col == columns - 1 or i == children.size() - 1:
            current_y += row_height + row_gap
            row_height = 0.0

func _apply_flex_layout() -> void:
    var children = _get_visible_children()
    if children.is_empty():
        return
    
    var available_width = size.x - (children.size() - 1) * column_gap
    var child_width = available_width / children.size()
    var current_x: float = 0.0
    
    for i in range(children.size()):
        var child = children[i]
        child.position.x = current_x
        child.size.x = child_width
        current_x += child_width + column_gap

func _apply_responsive_spacing() -> void:
    if not responsive_padding or not _layout_manager:
        return
    
    # Apply responsive padding
    var left_padding = _layout_manager.get_responsive_spacing(padding_left)
    var top_padding = _layout_manager.get_responsive_spacing(padding_top)
    var right_padding = _layout_manager.get_responsive_spacing(padding_right)
    var bottom_padding = _layout_manager.get_responsive_spacing(padding_bottom)
    
    # Apply padding to children positions
    for child in _get_visible_children():
        child.position.x += left_padding
        child.position.y += top_padding

func _get_visible_children() -> Array[Control]:
    var visible_children: Array[Control] = []
    
    for child in get_children():
        if child is Control and child.visible:
            visible_children.append(child)
    
    return visible_children

func _animate_layout_change() -> void:
    var tween = create_tween()
    tween.set_parallel(true)
    
    # Store current positions
    var old_positions: Dictionary = {}
    for child in get_children():
        if child is Control:
            old_positions[child] = child.position
    
    # Calculate new layout
    refresh_layout()
    
    # Animate to new positions
    for child in get_children():
        if child is Control and old_positions.has(child):
            var old_pos = old_positions[child]
            var new_pos = child.position
            
            child.position = old_pos
            tween.tween_property(child, "position", new_pos, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)