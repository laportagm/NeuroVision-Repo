## ResponsiveLabel.gd
## Responsive label that adapts to container size and screen dimensions
##
## Extends BaseLabel with responsive features:
## - Automatic font size scaling based on container
## - Breakpoint-based typography changes
## - Dynamic line clamping
## - Performance-optimized resizing
## - Viewport-aware text sizing
## - Accessibility-preserving scaling

class_name ResponsiveLabel
extends BaseLabel

# === SIGNALS ===
signal breakpoint_changed(breakpoint: String)
signal font_size_adjusted(new_size: int)
signal responsive_mode_changed(mode: ResponsiveMode)

# === CONSTANTS ===
const MIN_SCALE_FACTOR := 0.5
const MAX_SCALE_FACTOR := 2.0
const RESIZE_DEBOUNCE_TIME := 0.1
const VIEWPORT_BASE_WIDTH := 1920.0
const VIEWPORT_BASE_HEIGHT := 1080.0

# Default breakpoints (can be customized)
const DEFAULT_BREAKPOINTS = {
	"xs": 0,      # Extra small (mobile)
	"sm": 640,    # Small (tablet portrait)
	"md": 768,    # Medium (tablet landscape)
	"lg": 1024,   # Large (desktop)
	"xl": 1280,   # Extra large (wide desktop)
	"2xl": 1536   # 2X large (ultra-wide)
}

# === ENUMS ===
enum ResponsiveMode {
	NONE,              # No responsive behavior
	CONTAINER_FIT,     # Scale to fit container
	VIEWPORT_SCALE,    # Scale based on viewport size
	BREAKPOINT_BASED,  # Change based on breakpoints
	FLUID,             # Continuous scaling
	HYBRID             # Combination of methods
}

enum ScaleReference {
	WIDTH,      # Scale based on width only
	HEIGHT,     # Scale based on height only
	MINIMUM,    # Use smaller of width/height scale
	MAXIMUM,    # Use larger of width/height scale
	AVERAGE     # Use average of width/height scale
}

# === EXPORT VARIABLES ===
@export_group("Responsive Settings")
@export var responsive_mode: ResponsiveMode = ResponsiveMode.CONTAINER_FIT : set = set_responsive_mode
@export var scale_reference: ScaleReference = ScaleReference.MINIMUM : set = set_scale_reference
@export var maintain_aspect_ratio: bool = true
@export var scale_factor: float = 1.0 : set = set_scale_factor
@export var enable_smooth_scaling: bool = true

@export_group("Container Fit")
@export var fit_margin: Vector2 = Vector2(8, 8)
@export var max_scale_up: float = 1.5
@export var min_scale_down: float = 0.7
@export var prefer_wrap_over_shrink: bool = true

@export_group("Viewport Scaling")
@export var viewport_reference_size: Vector2 = Vector2(VIEWPORT_BASE_WIDTH, VIEWPORT_BASE_HEIGHT)
@export var viewport_scale_curve: Curve
@export var use_dpi_scaling: bool = true

@export_group("Breakpoints")
@export var use_custom_breakpoints: bool = false
@export var custom_breakpoints: Dictionary = {}
@export var breakpoint_presets: Dictionary = {
	"xs": TypographyPreset.BODY_SMALL,
	"sm": TypographyPreset.BODY_SMALL,
	"md": TypographyPreset.BODY_MEDIUM,
	"lg": TypographyPreset.BODY_LARGE,
	"xl": TypographyPreset.TITLE_MEDIUM,
	"2xl": TypographyPreset.TITLE_LARGE
}

@export_group("Performance")
@export var update_on_resize: bool = true
@export var resize_debounce: float = RESIZE_DEBOUNCE_TIME
@export var cache_calculations: bool = true
@export var update_frequency: float = 0.0  # 0 = every frame, > 0 = interval

# === PRIVATE VARIABLES ===
var _base_font_size: int
var _current_breakpoint: String = "md"
var _viewport_size: Vector2
var _container_size: Vector2
var _last_calculated_size: int
var _resize_timer: Timer
var _update_timer: Timer
var _size_cache: Dictionary = {}
var _is_resizing: bool = false
var _scale_animation_tween: Tween

# Responsive calculations
var _current_scale_factor: float = 1.0
var _target_scale_factor: float = 1.0
var _dpi_scale: float = 1.0

# === LIFECYCLE ===

func _on_ready() -> void:
	"""Initialize responsive label"""
	super._on_ready()
	
	_base_font_size = font_size
	_setup_responsive_system()
	_calculate_initial_scale()
	
	# Connect to viewport changes
	if update_on_resize:
		get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	print("[ResponsiveLabel] Initialized with mode: ", ResponsiveMode.keys()[responsive_mode])

func _on_resized() -> void:
	"""Handle container resize"""
	super._on_resized()
	
	if not update_on_resize or _is_resizing:
		return
	
	_container_size = size
	
	# Debounce resize updates
	if _resize_timer:
		_resize_timer.start(resize_debounce)
	else:
		_update_responsive_size()

# === SETUP ===

func _setup_responsive_system() -> void:
	"""Set up timers and initial values"""
	# Resize debounce timer
	_resize_timer = Timer.new()
	_resize_timer.wait_time = resize_debounce
	_resize_timer.one_shot = true
	_resize_timer.timeout.connect(_update_responsive_size)
	add_child(_resize_timer)
	
	# Update frequency timer
	if update_frequency > 0:
		_update_timer = Timer.new()
		_update_timer.wait_time = update_frequency
		_update_timer.timeout.connect(_update_responsive_size)
		add_child(_update_timer)
		_update_timer.start()
	
	# Get initial sizes
	_viewport_size = get_viewport().size
	_container_size = size
	
	# Calculate DPI scale
	if use_dpi_scaling:
		if OS.has_feature("pc") or OS.has_feature("mobile"):
			_dpi_scale = DisplayServer.screen_get_scale()
		else:
			_dpi_scale = 1.0

func _calculate_initial_scale() -> void:
	"""Calculate initial scale based on current conditions"""
	match responsive_mode:
		ResponsiveMode.CONTAINER_FIT:
			_calculate_container_fit_scale()
		ResponsiveMode.VIEWPORT_SCALE:
			_calculate_viewport_scale()
		ResponsiveMode.BREAKPOINT_BASED:
			_update_breakpoint()
		ResponsiveMode.FLUID:
			_calculate_fluid_scale()
		ResponsiveMode.HYBRID:
			_calculate_hybrid_scale()

# === PUBLIC METHODS ===

func set_responsive_mode(mode: ResponsiveMode) -> void:
	"""Set responsive behavior mode"""
	responsive_mode = mode
	responsive_mode_changed.emit(mode)
	
	if is_inside_tree():
		_update_responsive_size()

func set_scale_reference(reference: ScaleReference) -> void:
	"""Set how scale is calculated from dimensions"""
	scale_reference = reference
	
	if is_inside_tree():
		_update_responsive_size()

func set_scale_factor(factor: float) -> void:
	"""Set manual scale factor"""
	scale_factor = clamp(factor, MIN_SCALE_FACTOR, MAX_SCALE_FACTOR)
	_target_scale_factor = scale_factor
	
	if enable_smooth_scaling:
		_animate_scale_change()
	else:
		_apply_scale_factor(scale_factor)

func set_breakpoints(breakpoints: Dictionary) -> void:
	"""Set custom breakpoints"""
	custom_breakpoints = breakpoints
	use_custom_breakpoints = true
	
	if is_inside_tree():
		_update_breakpoint()

func force_update() -> void:
	"""Force immediate responsive update"""
	_update_responsive_size()

func get_current_breakpoint() -> String:
	"""Get the current active breakpoint"""
	return _current_breakpoint

func get_effective_font_size() -> int:
	"""Get the current calculated font size"""
	return _last_calculated_size

# === PRIVATE RESPONSIVE METHODS ===

func _update_responsive_size() -> void:
	"""Main responsive update method"""
	if not is_inside_tree() or responsive_mode == ResponsiveMode.NONE:
		return
	
	_is_resizing = true
	
	# Update current sizes
	_viewport_size = get_viewport().size
	_container_size = size
	
	# Check cache
	if cache_calculations:
		var cache_key = "%s_%s_%s" % [_viewport_size, _container_size, responsive_mode]
		if _size_cache.has(cache_key):
			_apply_cached_size(_size_cache[cache_key])
			_is_resizing = false
			return
	
	# Calculate new size based on mode
	match responsive_mode:
		ResponsiveMode.CONTAINER_FIT:
			_calculate_container_fit_scale()
		ResponsiveMode.VIEWPORT_SCALE:
			_calculate_viewport_scale()
		ResponsiveMode.BREAKPOINT_BASED:
			_update_breakpoint()
		ResponsiveMode.FLUID:
			_calculate_fluid_scale()
		ResponsiveMode.HYBRID:
			_calculate_hybrid_scale()
	
	_is_resizing = false

func _calculate_container_fit_scale() -> void:
	"""Calculate scale to fit text within container"""
	if text.is_empty():
		return
	
	# Get available space
	var available_size = _container_size - fit_margin * 2
	
	# Estimate required size at base font size
	var test_font = get_theme_font("font", "Label")
	if not test_font:
		return
	
	var text_size = test_font.get_string_size(
		text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		_base_font_size
	)
	
	# Calculate scale needed
	var width_scale = available_size.x / text_size.x if text_size.x > 0 else 1.0
	var height_scale = available_size.y / text_size.y if text_size.y > 0 else 1.0
	
	var target_scale = _get_scale_from_reference(width_scale, height_scale)
	
	# Apply limits
	target_scale = clamp(target_scale, min_scale_down, max_scale_up)
	
	# Check if wrapping would be better
	if prefer_wrap_over_shrink and target_scale < 1.0:
		if overflow_mode != OverflowMode.WRAP:
			set_overflow_mode(OverflowMode.WRAP)
			return
	
	_set_responsive_font_size(int(_base_font_size * target_scale))

func _calculate_viewport_scale() -> void:
	"""Calculate scale based on viewport size"""
	var viewport_scale_x = _viewport_size.x / viewport_reference_size.x
	var viewport_scale_y = _viewport_size.y / viewport_reference_size.y
	
	var viewport_scale = _get_scale_from_reference(viewport_scale_x, viewport_scale_y)
	
	# Apply DPI scaling
	if use_dpi_scaling:
		viewport_scale *= _dpi_scale
	
	# Apply curve if available
	if viewport_scale_curve:
		viewport_scale = viewport_scale_curve.sample(viewport_scale)
	
	_set_responsive_font_size(int(_base_font_size * viewport_scale))

func _update_breakpoint() -> void:
	"""Update typography based on current breakpoint"""
	var breakpoints = custom_breakpoints if use_custom_breakpoints else DEFAULT_BREAKPOINTS
	var viewport_width = _viewport_size.x
	
	var new_breakpoint = "xs"
	var largest_threshold = 0
	
	# Find current breakpoint
	for bp_name in breakpoints:
		var threshold = breakpoints[bp_name]
		if viewport_width >= threshold and threshold > largest_threshold:
			new_breakpoint = bp_name
			largest_threshold = threshold
	
	# Check if breakpoint changed
	if new_breakpoint != _current_breakpoint:
		_current_breakpoint = new_breakpoint
		breakpoint_changed.emit(new_breakpoint)
		
		# Apply breakpoint preset
		if breakpoint_presets.has(new_breakpoint):
			set_typography_preset(breakpoint_presets[new_breakpoint])

func _calculate_fluid_scale() -> void:
	"""Calculate continuous fluid scaling"""
	# Fluid typography formula: font-size = min + (max - min) * ((viewport - min_vw) / (max_vw - min_vw))
	var min_font = _base_font_size * min_scale_down
	var max_font = _base_font_size * max_scale_up
	var min_viewport = 320.0  # Mobile minimum
	var max_viewport = 1920.0  # Desktop maximum
	
	var viewport_width = _viewport_size.x
	var scale_progress = (viewport_width - min_viewport) / (max_viewport - min_viewport)
	scale_progress = clamp(scale_progress, 0.0, 1.0)
	
	var fluid_size = min_font + (max_font - min_font) * scale_progress
	_set_responsive_font_size(int(fluid_size))

func _calculate_hybrid_scale() -> void:
	"""Calculate scale using multiple methods"""
	# Start with breakpoint
	_update_breakpoint()
	
	# Then apply viewport scaling on top
	var viewport_scale_x = _viewport_size.x / viewport_reference_size.x
	var viewport_scale_y = _viewport_size.y / viewport_reference_size.y
	var viewport_scale = _get_scale_from_reference(viewport_scale_x, viewport_scale_y)
	
	# Combine with container fit if text is overflowing
	if _is_overflowing:
		_calculate_container_fit_scale()

func _get_scale_from_reference(scale_x: float, scale_y: float) -> float:
	"""Get final scale based on reference setting"""
	match scale_reference:
		ScaleReference.WIDTH:
			return scale_x
		ScaleReference.HEIGHT:
			return scale_y
		ScaleReference.MINIMUM:
			return min(scale_x, scale_y)
		ScaleReference.MAXIMUM:
			return max(scale_x, scale_y)
		ScaleReference.AVERAGE:
			return (scale_x + scale_y) / 2.0
	
	return 1.0

func _set_responsive_font_size(new_size: int) -> void:
	"""Set font size with caching and animation"""
	new_size = clamp(new_size, MIN_FONT_SIZE, MAX_FONT_SIZE)
	
	if new_size == _last_calculated_size:
		return
	
	_last_calculated_size = new_size
	
	# Cache result
	if cache_calculations:
		var cache_key = "%s_%s_%s" % [_viewport_size, _container_size, responsive_mode]
		_size_cache[cache_key] = new_size
		
		# Limit cache size
		if _size_cache.size() > 100:
			_size_cache.clear()
	
	# Apply size
	if enable_smooth_scaling:
		_animate_font_size_change(new_size)
	else:
		set_font_size(new_size)
	
	font_size_adjusted.emit(new_size)

func _apply_cached_size(cached_size: int) -> void:
	"""Apply cached size calculation"""
	if cached_size != _last_calculated_size:
		_last_calculated_size = cached_size
		set_font_size(cached_size)
		font_size_adjusted.emit(cached_size)

func _apply_scale_factor(factor: float) -> void:
	"""Apply scale factor to current font size"""
	_current_scale_factor = factor
	var scaled_size = int(_base_font_size * factor)
	set_font_size(scaled_size)

# === ANIMATION METHODS ===

func _animate_scale_change() -> void:
	"""Animate scale factor change"""
	if _scale_animation_tween:
		_scale_animation_tween.kill()
	
	_scale_animation_tween = create_tween()
	_scale_animation_tween.tween_method(
		_apply_scale_factor,
		_current_scale_factor,
		_target_scale_factor,
		0.3
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _animate_font_size_change(target_size: int) -> void:
	"""Animate font size change"""
	var tween = create_tween()
	tween.tween_property(self, "font_size", target_size, 0.2).set_trans(Tween.TRANS_CUBIC)

# === SIGNAL HANDLERS ===

func _on_viewport_size_changed() -> void:
	"""Handle viewport resize"""
	_viewport_size = get_viewport().size
	
	# Debounce if timer exists
	if _resize_timer and _resize_timer.wait_time > 0:
		_resize_timer.start()
	else:
		_update_responsive_size()

# === UTILITY METHODS ===

func get_responsive_info() -> Dictionary:
	"""Get current responsive state information"""
	return {
		"mode": ResponsiveMode.keys()[responsive_mode],
		"current_breakpoint": _current_breakpoint,
		"base_font_size": _base_font_size,
		"current_font_size": _last_calculated_size,
		"scale_factor": _current_scale_factor,
		"viewport_size": _viewport_size,
		"container_size": _container_size,
		"is_overflowing": _is_overflowing,
		"dpi_scale": _dpi_scale
	}

# === STATIC FACTORY METHODS ===

static func create_heading(text: String, level: int = 1) -> ResponsiveLabel:
	"""Create a responsive heading"""
	var label = ResponsiveLabel.new()
	label.text = text
	
	match level:
		1:
			label.typography_preset = TypographyPreset.DISPLAY_LARGE
			label.breakpoint_presets = {
				"xs": TypographyPreset.HEADLINE_LARGE,
				"sm": TypographyPreset.DISPLAY_SMALL,
				"md": TypographyPreset.DISPLAY_MEDIUM,
				"lg": TypographyPreset.DISPLAY_LARGE
			}
		2:
			label.typography_preset = TypographyPreset.DISPLAY_MEDIUM
			label.breakpoint_presets = {
				"xs": TypographyPreset.HEADLINE_MEDIUM,
				"sm": TypographyPreset.HEADLINE_LARGE,
				"md": TypographyPreset.DISPLAY_SMALL,
				"lg": TypographyPreset.DISPLAY_MEDIUM
			}
		3:
			label.typography_preset = TypographyPreset.DISPLAY_SMALL
			label.breakpoint_presets = {
				"xs": TypographyPreset.HEADLINE_SMALL,
				"sm": TypographyPreset.HEADLINE_MEDIUM,
				"md": TypographyPreset.HEADLINE_LARGE,
				"lg": TypographyPreset.DISPLAY_SMALL
			}
		_:
			label.typography_preset = TypographyPreset.HEADLINE_MEDIUM
	
	label.responsive_mode = ResponsiveMode.BREAKPOINT_BASED
	return label

static func create_body_text(text: String) -> ResponsiveLabel:
	"""Create responsive body text"""
	var label = ResponsiveLabel.new()
	label.text = text
	label.typography_preset = TypographyPreset.BODY_MEDIUM
	label.responsive_mode = ResponsiveMode.CONTAINER_FIT
	label.overflow_mode = OverflowMode.WRAP
	return label

static func create_adaptive_label(text: String) -> ResponsiveLabel:
	"""Create a fully adaptive label"""
	var label = ResponsiveLabel.new()
	label.text = text
	label.responsive_mode = ResponsiveMode.HYBRID
	label.enable_smooth_scaling = true
	label.use_dpi_scaling = true
	return label