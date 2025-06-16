## Material 3 Performance Integration for NeuroVision
## Ensures Material 3 themes work seamlessly with performance optimization
##
## This integration layer adapts Material 3 visual effects based on
## hardware capabilities while maintaining design system integrity.

class_name M3PerformanceIntegration
extends Resource

# Preload dependencies
const M3Tokens = preload("res://src/ui/themes/core/M3DesignTokens.gd")
const PerformanceAdapter = preload("res://src/ui/themes/utilities/PerformanceThemeAdapter.gd")

# === PERFORMANCE PROFILES FOR M3 ===
enum M3PerformanceLevel {
	FULL,      # All Material 3 effects enabled
	BALANCED,  # Reduced shadows and blur
	EFFICIENT, # Minimal effects, focus on performance
	BATTERY    # Maximum battery savings
}

# === OPTIMIZATION STRATEGIES ===

## Optimize Material 3 theme for performance
static func optimize_m3_theme(theme: Theme, performance_level: M3PerformanceLevel) -> void:
	"""Adapt Material 3 theme based on performance requirements"""
	
	match performance_level:
		M3PerformanceLevel.FULL:
			# No changes - full Material 3 experience
			pass
			
		M3PerformanceLevel.BALANCED:
			_apply_balanced_optimizations(theme)
			
		M3PerformanceLevel.EFFICIENT:
			_apply_efficient_optimizations(theme)
			
		M3PerformanceLevel.BATTERY:
			_apply_battery_optimizations(theme)
	
	# Store optimization metadata
	theme.set_meta("m3_performance_level", performance_level)
	theme.set_meta("m3_optimized", performance_level != M3PerformanceLevel.FULL)

static func _apply_balanced_optimizations(theme: Theme) -> void:
	"""Apply balanced performance optimizations"""
	
	# Reduce shadow complexity
	_reduce_shadow_quality(theme, 0.7)
	
	# Simplify gradients
	_simplify_gradients(theme)
	
	# Reduce animation durations slightly
	_scale_animation_durations(theme, 0.8)
	
	# Disable non-essential blur effects
	theme.set_constant("blur_amount", "Effects", M3Tokens.M3_BLUR["small"])

static func _apply_efficient_optimizations(theme: Theme) -> void:
	"""Apply aggressive performance optimizations"""
	
	# Remove all shadows
	_disable_all_shadows(theme)
	
	# Replace gradients with solid colors
	_remove_all_gradients(theme)
	
	# Minimize animation durations
	_scale_animation_durations(theme, 0.5)
	
	# Disable all blur effects
	theme.set_constant("blur_amount", "Effects", 0)
	
	# Reduce transparency usage
	_reduce_transparency(theme)

static func _apply_battery_optimizations(theme: Theme) -> void:
	"""Apply maximum battery saving optimizations"""
	
	# Apply all efficient optimizations
	_apply_efficient_optimizations(theme)
	
	# Use darker colors to save OLED power
	_apply_oled_optimizations(theme)
	
	# Disable all animations
	_disable_all_animations(theme)
	
	# Remove all decorative elements
	_remove_decorative_elements(theme)

# === OPTIMIZATION HELPERS ===

static func _reduce_shadow_quality(theme: Theme, quality_factor: float) -> void:
	"""Reduce shadow quality by factor (0.0 - 1.0)"""
	
	var control_types = ["Button", "Panel", "PanelContainer", "TooltipPanel"]
	var states = ["normal", "hover", "pressed", "focus"]
	
	for control in control_types:
		for state in states:
			if theme.has_stylebox(state, control):
				var stylebox = theme.get_stylebox(state, control)
				if stylebox is StyleBoxFlat:
					stylebox.shadow_size = int(stylebox.shadow_size * quality_factor)
					stylebox.shadow_offset *= quality_factor

static func _simplify_gradients(theme: Theme) -> void:
	"""Convert complex gradients to simple two-color gradients"""
	
	# For M3, gradients are mainly used in backgrounds
	if theme.has_color("background_gradient_start", "Control"):
		var start_color = theme.get_color("background_gradient_start", "Control")
		var end_color = theme.get_color("background_gradient_end", "Control")
		
		# Make gradient more subtle
		var averaged = start_color.lerp(end_color, 0.7)
		theme.set_color("background_gradient_end", "Control", averaged)

static func _scale_animation_durations(theme: Theme, scale: float) -> void:
	"""Scale all animation durations by factor"""
	
	var duration_keys = ["short", "medium", "long"]
	
	for key in duration_keys:
		var constant_name = "transition_duration_" + key
		if theme.has_constant(constant_name, "Effects"):
			var duration = theme.get_constant(constant_name, "Effects")
			theme.set_constant(constant_name, "Effects", int(duration * scale))

static func _disable_all_shadows(theme: Theme) -> void:
	"""Remove all shadows from theme"""
	
	var control_types = ["Button", "Panel", "PanelContainer", "TooltipPanel", "TabContainer"]
	var states = ["normal", "hover", "pressed", "focus", "disabled"]
	
	for control in control_types:
		for state in states:
			if theme.has_stylebox(state, control):
				var stylebox = theme.get_stylebox(state, control)
				if stylebox is StyleBoxFlat:
					stylebox.shadow_size = 0
					stylebox.shadow_offset = Vector2.ZERO

static func _remove_all_gradients(theme: Theme) -> void:
	"""Replace all gradients with solid colors"""
	
	if theme.has_color("background_gradient_start", "Control"):
		var start_color = theme.get_color("background_gradient_start", "Control")
		theme.set_color("background_gradient_end", "Control", start_color)

static func _reduce_transparency(theme: Theme) -> void:
	"""Reduce transparency usage for better performance"""
	
	var control_types = ["Panel", "PanelContainer", "Button"]
	
	for control in control_types:
		if theme.has_stylebox("panel", control) or theme.has_stylebox("normal", control):
			var style_name = "panel" if control in ["Panel", "PanelContainer"] else "normal"
			var stylebox = theme.get_stylebox(style_name, control)
			
			if stylebox is StyleBoxFlat and stylebox.bg_color.a < 1.0:
				# Increase opacity to at least 0.95
				stylebox.bg_color.a = max(stylebox.bg_color.a, 0.95)

static func _apply_oled_optimizations(theme: Theme) -> void:
	"""Apply pure black backgrounds for OLED displays"""
	
	var pure_black = Color(0, 0, 0, 1)
	
	# Set backgrounds to pure black
	theme.set_color("background", "Control", pure_black)
	theme.set_color("background_gradient_start", "Control", pure_black)
	theme.set_color("background_gradient_end", "Control", Color(0.05, 0.05, 0.05, 1))
	
	# Darken surface colors
	var surface_controls = ["Panel", "PanelContainer"]
	for control in surface_controls:
		if theme.has_stylebox("panel", control):
			var stylebox = theme.get_stylebox("panel", control)
			if stylebox is StyleBoxFlat:
				stylebox.bg_color = stylebox.bg_color.darkened(0.5)

static func _disable_all_animations(theme: Theme) -> void:
	"""Set all animation durations to zero"""
	
	var duration_constants = [
		"transition_duration_short",
		"transition_duration_medium", 
		"transition_duration_long"
	]
	
	for constant in duration_constants:
		if theme.has_constant(constant, "Effects"):
			theme.set_constant(constant, "Effects", 0)
	
	# Disable animation metadata
	theme.set_meta("animations_enabled", false)

static func _remove_decorative_elements(theme: Theme) -> void:
	"""Remove purely decorative elements for performance"""
	
	# Remove border decorations
	var control_types = ["Panel", "PanelContainer", "Button"]
	
	for control in control_types:
		var styleboxes = theme.get_stylebox_list(control)
		for stylebox_name in styleboxes:
			var stylebox = theme.get_stylebox(stylebox_name, control)
			if stylebox is StyleBoxFlat:
				# Keep functional borders, remove decorative ones
				if stylebox.border_color.a < 0.5:  # Decorative border
					stylebox.border_width_left = 0
					stylebox.border_width_right = 0
					stylebox.border_width_top = 0
					stylebox.border_width_bottom = 0

# === PERFORMANCE DETECTION ===

## Detect optimal M3 performance level for current hardware
static func detect_optimal_performance_level() -> M3PerformanceLevel:
	"""Analyze system and recommend performance level"""
	
	var gpu_name = RenderingServer.get_video_adapter_name()
	var memory_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / 1024 / 1024
	
	# Simple heuristics - can be expanded
	if gpu_name.to_lower().contains("intel") and not gpu_name.contains("arc"):
		return M3PerformanceLevel.EFFICIENT
	elif memory_mb < 4096:
		return M3PerformanceLevel.BALANCED
	elif OS.has_feature("mobile"):
		return M3PerformanceLevel.BATTERY
	else:
		return M3PerformanceLevel.FULL

## Get performance impact description
static func get_performance_level_description(level: M3PerformanceLevel) -> String:
	"""Get human-readable description of performance level"""
	
	match level:
		M3PerformanceLevel.FULL:
			return "Full Material 3 experience with all visual effects"
		M3PerformanceLevel.BALANCED:
			return "Balanced performance with reduced effects"
		M3PerformanceLevel.EFFICIENT:
			return "Optimized for smooth performance on all hardware"
		M3PerformanceLevel.BATTERY:
			return "Maximum battery life with minimal effects"
		_:
			return "Unknown performance level"

## Check if effect is supported at performance level
static func is_effect_supported(effect: String, level: M3PerformanceLevel) -> bool:
	"""Check if a specific M3 effect is supported at performance level"""
	
	var effect_support = {
		"shadows": level <= M3PerformanceLevel.BALANCED,
		"blur": level == M3PerformanceLevel.FULL,
		"gradients": level <= M3PerformanceLevel.BALANCED,
		"animations": level < M3PerformanceLevel.BATTERY,
		"transparency": level <= M3PerformanceLevel.EFFICIENT,
		"glass_morphism": level == M3PerformanceLevel.FULL
	}
	
	return effect_support.get(effect, false)