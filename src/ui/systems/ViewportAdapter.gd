class_name ViewportAdapter
extends Node

## ViewportAdapter - High-DPI and resolution adaptation system
##
## Handles viewport scaling, DPI adaptation, and window resize management
## for crisp rendering across all display densities and resolutions.

# === CONSTANTS ===
## Standard UI scale presets
const UI_SCALE_PRESETS = {
    "tiny": 0.75,
    "small": 0.9,
    "normal": 1.0,
    "large": 1.25,
    "huge": 1.5,
    "giant": 2.0
}

## Minimum and maximum scale limits
const MIN_UI_SCALE = 0.5
const MAX_UI_SCALE = 3.0

## Target frame rates for different quality levels
const TARGET_FRAMERATES = {
    "performance": 30,
    "balanced": 60,
    "quality": 120
}

# === SIGNALS ===
signal viewport_adapted(scale_factor: float, dpi: float)
signal ui_scale_changed(old_scale: float, new_scale: float)
signal performance_mode_changed(mode: String)

# === EXPORTS ===
@export var auto_adapt_on_resize: bool = true
@export var maintain_aspect_ratio: bool = true
@export var adaptive_quality: bool = true
@export var target_fps: int = 60

# === PRIVATE VARIABLES ===
var _current_ui_scale: float = 1.0
var _base_resolution: Vector2 = Vector2(1920, 1080)
var _current_dpi: float = 96.0
var _performance_mode: String = "balanced"
var _adaptation_timer: Timer
var _frame_counter: int = 0
var _fps_samples: Array[float] = []

# === PUBLIC METHODS ===
func _ready() -> void:
    _setup_viewport_adaptation()
    _setup_performance_monitoring()
    
    # Create adaptation timer for smooth transitions
    _adaptation_timer = Timer.new()
    _adaptation_timer.wait_time = 0.2
    _adaptation_timer.one_shot = true
    _adaptation_timer.timeout.connect(_apply_adaptation)
    add_child(_adaptation_timer)
    
    # Initial adaptation
    _apply_adaptation()

## Set UI scale factor
## @param scale: Scale multiplier (0.5 to 3.0)
## @param animate: Whether to animate the transition
func set_ui_scale(scale: float, animate: bool = false) -> void:
    var old_scale = _current_ui_scale
    _current_ui_scale = clamp(scale, MIN_UI_SCALE, MAX_UI_SCALE)
    
    if animate:
        _animate_scale_change(old_scale, _current_ui_scale)
    else:
        get_viewport().set_snap_2d_transforms_to_pixel(true)
        get_viewport().set_snap_2d_vertices_to_pixel(true)
    
    ui_scale_changed.emit(old_scale, _current_ui_scale)
    _apply_adaptation()

## Get current UI scale
## @returns: Current UI scale factor
func get_ui_scale() -> float:
    return _current_ui_scale

## Set UI scale from preset
## @param preset: Preset name (tiny, small, normal, large, huge, giant)
func set_ui_scale_preset(preset: String) -> void:
    if UI_SCALE_PRESETS.has(preset):
        set_ui_scale(UI_SCALE_PRESETS[preset])
    else:
        push_error("[ViewportAdapter] Unknown UI scale preset: " + preset)

## Get optimal UI scale for current display
## @returns: Recommended UI scale factor
func get_optimal_ui_scale() -> float:
    var screen = DisplayServer.window_get_current_screen()
    var dpi = DisplayServer.screen_get_dpi(screen)
    var viewport_size = get_viewport().size
    
    # Base scale on DPI
    var dpi_scale = dpi / 96.0  # 96 DPI is baseline
    
    # Adjust for viewport size
    var size_factor = min(viewport_size.x / _base_resolution.x, viewport_size.y / _base_resolution.y)
    
    # Combine factors with preference for readability
    var optimal_scale = sqrt(dpi_scale * size_factor)
    
    return clamp(optimal_scale, MIN_UI_SCALE, MAX_UI_SCALE)

## Auto-adapt UI scale to current display
func auto_adapt() -> void:
    var optimal_scale = get_optimal_ui_scale()
    set_ui_scale(optimal_scale, true)

## Set performance mode
## @param mode: Performance mode (performance, balanced, quality)
func set_performance_mode(mode: String) -> void:
    if not TARGET_FRAMERATES.has(mode):
        push_error("[ViewportAdapter] Unknown performance mode: " + mode)
        return
    
    _performance_mode = mode
    target_fps = TARGET_FRAMERATES[mode]
    performance_mode_changed.emit(mode)
    
    _apply_performance_settings()

## Get current performance mode
## @returns: Current performance mode name
func get_performance_mode() -> String:
    return _performance_mode

## Get current DPI
## @returns: Current screen DPI
func get_current_dpi() -> float:
    return _current_dpi

## Get viewport scaling information
## @returns: Dictionary with scaling details
func get_scaling_info() -> Dictionary:
    var viewport = get_viewport()
    return {
        "ui_scale": _current_ui_scale,
        "dpi": _current_dpi,
        "viewport_size": viewport.size,
        "render_size": viewport.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_CANVAS_ITEM_COUNT),
        "performance_mode": _performance_mode,
        "fps": Engine.get_frames_per_second()
    }

## Enable or disable adaptive quality
## @param enabled: Whether to enable adaptive quality
func set_adaptive_quality(enabled: bool) -> void:
    adaptive_quality = enabled
    if enabled:
        _setup_performance_monitoring()
    else:
        _fps_samples.clear()

# === PRIVATE METHODS ===
func _setup_viewport_adaptation() -> void:
    # Monitor viewport changes
    get_viewport().size_changed.connect(_on_viewport_size_changed)
    
    # Monitor DPI changes
    DisplayServer.window_set_window_event_callback(_on_window_event)
    
    # Update current DPI
    _update_dpi()

func _setup_performance_monitoring() -> void:
    if not adaptive_quality:
        return
    
    # Clear existing samples
    _fps_samples.clear()
    _frame_counter = 0

func _on_viewport_size_changed() -> void:
    if auto_adapt_on_resize:
        _adaptation_timer.start()

func _on_window_event(event: DisplayServer.WindowEvent) -> void:
    match event:
        DisplayServer.WINDOW_EVENT_DPI_CHANGE:
            _update_dpi()
            _adaptation_timer.start()
        DisplayServer.WINDOW_EVENT_RESIZED:
            if auto_adapt_on_resize:
                _adaptation_timer.start()

func _apply_adaptation() -> void:
    _update_dpi()
    
    var viewport = get_viewport()
    var scaling_factor = _current_ui_scale
    
    # Apply high-DPI scaling
    if _current_dpi > 120:  # High DPI threshold
        viewport.set_snap_2d_transforms_to_pixel(true)
        viewport.set_snap_2d_vertices_to_pixel(true)
    
    # Maintain crisp rendering
    viewport.set_snap_2d_transforms_to_pixel(true)
    viewport.set_snap_2d_vertices_to_pixel(true)
    
    # Update render scaling if needed
    if maintain_aspect_ratio:
        _maintain_aspect_ratio()
    
    viewport_adapted.emit(scaling_factor, _current_dpi)

func _update_dpi() -> void:
    var screen = DisplayServer.window_get_current_screen()
    _current_dpi = DisplayServer.screen_get_dpi(screen)

func _maintain_aspect_ratio() -> void:
    var viewport = get_viewport()
    var current_size = viewport.size
    var target_aspect = _base_resolution.x / _base_resolution.y
    var current_aspect = current_size.x / current_size.y
    
    if not is_equal_approx(target_aspect, current_aspect):
        # Calculate letterbox/pillarbox if needed
        var scale_x = current_size.x / _base_resolution.x
        var scale_y = current_size.y / _base_resolution.y
        var scale = min(scale_x, scale_y)
        
        # Apply uniform scaling
        var scaled_size = _base_resolution * scale
        var offset = (current_size - scaled_size) / 2
        
        # This would typically be handled by the UI layout system
        # Store the offset for UI components to use
        viewport.set_meta("letterbox_offset", offset)
        viewport.set_meta("ui_scale", scale)

func _apply_performance_settings() -> void:
    match _performance_mode:
        "performance":
            # Optimize for performance
            get_viewport().set_snap_2d_transforms_to_pixel(false)
            get_viewport().set_snap_2d_vertices_to_pixel(false)
        "balanced":
            # Balance between quality and performance
            get_viewport().set_snap_2d_transforms_to_pixel(true)
            get_viewport().set_snap_2d_vertices_to_pixel(false)
        "quality":
            # Optimize for visual quality
            get_viewport().set_snap_2d_transforms_to_pixel(true)
            get_viewport().set_snap_2d_vertices_to_pixel(true)

func _animate_scale_change(from_scale: float, to_scale: float) -> void:
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_CUBIC)
    
    tween.tween_method(_interpolate_scale, from_scale, to_scale, 0.3)

func _interpolate_scale(scale: float) -> void:
    # Apply smooth scaling transition
    _current_ui_scale = scale
    _apply_adaptation()

func _process(_delta: float) -> void:
    if adaptive_quality:
        _monitor_performance()

func _monitor_performance() -> void:
    _frame_counter += 1
    
    # Sample FPS every second
    if _frame_counter % 60 == 0:
        var current_fps = Engine.get_frames_per_second()
        _fps_samples.append(current_fps)
        
        # Keep only last 5 samples
        if _fps_samples.size() > 5:
            _fps_samples.pop_front()
        
        # Check if we need to adjust performance
        if _fps_samples.size() >= 3:
            var avg_fps = _fps_samples.reduce(func(a, b): return a + b) / _fps_samples.size()
            
            if avg_fps < target_fps * 0.8:  # 20% below target
                _downgrade_performance()
            elif avg_fps > target_fps * 1.1:  # 10% above target
                _upgrade_performance()

func _downgrade_performance() -> void:
    # Automatically reduce quality to maintain target FPS
    match _performance_mode:
        "quality":
            set_performance_mode("balanced")
        "balanced":
            set_performance_mode("performance")

func _upgrade_performance() -> void:
    # Automatically increase quality when performance allows
    match _performance_mode:
        "performance":
            set_performance_mode("balanced")
        "balanced":
            set_performance_mode("quality")