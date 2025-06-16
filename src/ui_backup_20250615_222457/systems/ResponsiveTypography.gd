class_name ResponsiveTypography
extends Node

## ResponsiveTypography - Dynamic font scaling system for resolution independence
##
## This system provides fluid typography that scales smoothly between minimum and maximum
## sizes based on viewport dimensions, ensuring readability across all screen sizes.
##
## @tutorial: https://docs.godotengine.org/en/stable/tutorials/ui/size_and_anchors.html

# === CONSTANTS ===
## Base font sizes with min, preferred, and max values for fluid scaling
const BASE_FONT_SIZES = {
    "display_large": {"min": 32, "preferred": 48, "max": 64},
    "display_medium": {"min": 28, "preferred": 40, "max": 56},
    "headline": {"min": 24, "preferred": 32, "max": 40},
    "title": {"min": 18, "preferred": 24, "max": 32},
    "body_large": {"min": 16, "preferred": 18, "max": 20},
    "body": {"min": 14, "preferred": 16, "max": 18},
    "caption": {"min": 12, "preferred": 14, "max": 16}
}

## Viewport breakpoints for responsive scaling
const VIEWPORT_BREAKPOINTS = {
    "mobile": 640,
    "tablet": 1024,
    "desktop": 1920,
    "ultra_wide": 2560
}

## DPI scaling factors
const DPI_SCALE_FACTORS = {
    "ldpi": 0.75,     # Low density (~120 DPI)
    "mdpi": 1.0,      # Medium density (~160 DPI)
    "hdpi": 1.5,      # High density (~240 DPI)
    "xhdpi": 2.0,     # Extra high density (~320 DPI)
    "xxhdpi": 3.0     # Extra extra high density (~480 DPI)
}

# === SIGNALS ===
## Emitted when font sizes need to be updated due to viewport changes
signal font_sizes_changed(sizes: Dictionary)

## Emitted when DPI scale factor changes
signal dpi_scale_changed(scale: float)

# === PRIVATE VARIABLES ===
var _current_sizes: Dictionary = {}
var _current_dpi_scale: float = 1.0
var _viewport_size: Vector2 = Vector2.ZERO
var _update_timer: Timer

# === PUBLIC METHODS ===
## Initialize the responsive typography system
func _ready() -> void:
    _setup_viewport_monitoring()
    _update_font_sizes()
    
    # Create debounce timer for resize events
    _update_timer = Timer.new()
    _update_timer.wait_time = 0.1
    _update_timer.one_shot = true
    _update_timer.timeout.connect(_on_update_timer_timeout)
    add_child(_update_timer)

## Get fluid font size for a specific text style
## @param style: The text style name (e.g., "headline", "body")
## @param apply_dpi_scale: Whether to apply DPI scaling
## @returns: The calculated font size in pixels
func get_fluid_font_size(style: String, apply_dpi_scale: bool = true) -> int:
    if not BASE_FONT_SIZES.has(style):
        push_error("[ResponsiveTypography] Unknown font style: " + style)
        return 16  # Fallback size
    
    var vw = get_viewport().size.x
    var sizes = BASE_FONT_SIZES[style]
    
    # Calculate fluid size using viewport width
    # Formula: min + (max - min) * ((vw - mobile) / (desktop - mobile))
    var mobile_width = float(VIEWPORT_BREAKPOINTS.mobile)
    var desktop_width = float(VIEWPORT_BREAKPOINTS.desktop)
    var factor = clamp((vw - mobile_width) / (desktop_width - mobile_width), 0.0, 1.0)
    
    var base_size = sizes.min + (sizes.max - sizes.min) * factor
    
    # Apply DPI scaling if requested
    if apply_dpi_scale:
        base_size *= _current_dpi_scale
    
    return int(round(base_size))

## Get all current font sizes
## @returns: Dictionary of style names to font sizes
func get_all_font_sizes() -> Dictionary:
    return _current_sizes.duplicate()

## Get the current viewport breakpoint
## @returns: String name of the current breakpoint
func get_current_breakpoint() -> String:
    var width = get_viewport().size.x
    
    if width <= VIEWPORT_BREAKPOINTS.mobile:
        return "mobile"
    elif width <= VIEWPORT_BREAKPOINTS.tablet:
        return "tablet"
    elif width <= VIEWPORT_BREAKPOINTS.desktop:
        return "desktop"
    else:
        return "ultra_wide"

## Get the current DPI scale factor
## @returns: Current DPI scale multiplier
func get_dpi_scale() -> float:
    return _current_dpi_scale

## Calculate DPI scale factor based on screen DPI
## @param screen: Screen index (-1 for current screen)
## @returns: Calculated DPI scale factor
func calculate_dpi_scale(screen: int = -1) -> float:
    if screen == -1:
        screen = DisplayServer.window_get_current_screen()
    
    var dpi = DisplayServer.screen_get_dpi(screen)
    
    # Calculate scale factor based on DPI ranges
    if dpi <= 120:
        return DPI_SCALE_FACTORS.ldpi
    elif dpi <= 160:
        return DPI_SCALE_FACTORS.mdpi
    elif dpi <= 240:
        return DPI_SCALE_FACTORS.hdpi
    elif dpi <= 320:
        return DPI_SCALE_FACTORS.xhdpi
    else:
        return DPI_SCALE_FACTORS.xxhdpi

## Apply responsive font to a Control node
## @param control: The Control node to apply font to
## @param style: The text style to use
## @param theme_variation: Optional theme variation name
func apply_to_control(control: Control, style: String, theme_variation: String = "") -> void:
    if not is_instance_valid(control):
        push_error("[ResponsiveTypography] Invalid control provided")
        return
    
    var font_size = get_fluid_font_size(style)
    
    # Apply font size based on control type
    if control is Label or control is Button or control is LineEdit:
        control.add_theme_font_size_override("font_size", font_size)
    elif control is RichTextLabel:
        control.add_theme_font_size_override("normal_font_size", font_size)
        control.add_theme_font_size_override("bold_font_size", font_size)
        control.add_theme_font_size_override("italics_font_size", font_size)
    
    # Store the style for future updates
    control.set_meta("responsive_font_style", style)

## Force update all font sizes
func force_update() -> void:
    _update_font_sizes()

# === PRIVATE METHODS ===
func _setup_viewport_monitoring() -> void:
    """Setup viewport size change monitoring"""
    get_viewport().size_changed.connect(_on_viewport_size_changed)
    
    # Monitor DPI changes when window moves between screens
    DisplayServer.window_set_window_event_callback(_on_window_event)

func _on_viewport_size_changed() -> void:
    """Handle viewport size changes with debouncing"""
    _update_timer.start()

func _on_update_timer_timeout() -> void:
    """Update font sizes after debounce timer"""
    _update_font_sizes()

func _on_window_event(event: DisplayServer.WindowEvent) -> void:
    """Handle window events for DPI changes"""
    if event == DisplayServer.WINDOW_EVENT_DPI_CHANGE:
        _update_dpi_scale()
        _update_font_sizes()

func _update_font_sizes() -> void:
    """Recalculate all font sizes based on current viewport"""
    var old_sizes = _current_sizes.duplicate()
    _current_sizes.clear()
    
    # Update all font sizes
    for style in BASE_FONT_SIZES:
        _current_sizes[style] = get_fluid_font_size(style, false)
    
    # Emit signal if sizes changed
    if old_sizes.hash() != _current_sizes.hash():
        font_sizes_changed.emit(_current_sizes)
        _update_registered_controls()

func _update_dpi_scale() -> void:
    """Update DPI scale factor"""
    var old_scale = _current_dpi_scale
    _current_dpi_scale = calculate_dpi_scale()
    
    if not is_equal_approx(old_scale, _current_dpi_scale):
        dpi_scale_changed.emit(_current_dpi_scale)

func _update_registered_controls() -> void:
    """Update all controls that have been registered with the system"""
    # Find all nodes with responsive font metadata
    var all_nodes = get_tree().get_nodes_in_group("_responsive_typography")
    
    for node in all_nodes:
        if node.has_meta("responsive_font_style"):
            var style = node.get_meta("responsive_font_style")
            apply_to_control(node, style)

## Register this as an autoload for global access
func _enter_tree() -> void:
    if not get_tree().has_group("_responsive_typography"):
        get_tree().add_group("_responsive_typography")