class_name PerformanceThemeAdapter
extends Resource

## Performance Theme Adapter for NeuroVision
## Optimizes themes based on hardware capabilities and performance requirements

# Performance profiles
enum PerformanceProfile {
	ULTRA_LOW,   # Mobile or very low-end hardware
	LOW,         # Intel integrated graphics
	MEDIUM,      # Mid-range discrete GPU
	HIGH,        # High-end GPU
	ULTRA        # Enthusiast hardware
}

# Hardware capability flags
const HardwareCapability = {
	"SHADER_SUPPORT": 1 << 0,
	"BLUR_SUPPORT": 1 << 1,
	"PARTICLE_SUPPORT": 1 << 2,
	"TRANSPARENCY_SUPPORT": 1 << 3,
	"SHADOW_SUPPORT": 1 << 4,
	"ANIMATION_SUPPORT": 1 << 5,
	"HIGH_DPI_SUPPORT": 1 << 6
}

# Performance thresholds
const PERFORMANCE_THRESHOLDS = {
	"min_fps": 30,
	"target_fps": 60,
	"max_draw_calls": 100,
	"max_memory_mb": 500,
	"max_texture_memory_mb": 256
}

# === PUBLIC METHODS ===

## Optimize theme for current hardware
static func optimize_theme_for_hardware(theme: Theme, gpu_info: Dictionary) -> Theme:
	"""Analyze hardware and optimize theme accordingly"""
	
	# Determine performance profile
	var profile = _determine_performance_profile(gpu_info)
	
	# Get hardware capabilities
	var capabilities = _analyze_hardware_capabilities(gpu_info)
	
	# Create optimized theme copy
	var optimized_theme = theme.duplicate(true)
	
	# Apply optimizations based on profile
	match profile:
		PerformanceProfile.ULTRA_LOW:
			_apply_ultra_low_optimizations(optimized_theme, capabilities)
		PerformanceProfile.LOW:
			_apply_low_optimizations(optimized_theme, capabilities)
		PerformanceProfile.MEDIUM:
			_apply_medium_optimizations(optimized_theme, capabilities)
		PerformanceProfile.HIGH:
			_apply_high_optimizations(optimized_theme, capabilities)
		PerformanceProfile.ULTRA:
			_apply_ultra_optimizations(optimized_theme, capabilities)
	
	# Add performance metadata
	_add_performance_metadata(optimized_theme, profile, capabilities)
	
	return optimized_theme

## Create low performance variant of theme
static func create_low_performance_variant(theme: Theme) -> Theme:
	"""Create a stripped-down version for maximum performance"""
	
	var low_perf_theme = theme.duplicate(true)
	
	# Remove all visual effects
	_remove_all_effects(low_perf_theme)
	
	# Simplify colors (reduce transparency)
	_simplify_colors(low_perf_theme)
	
	# Reduce element complexity
	_reduce_complexity(low_perf_theme)
	
	# Disable animations
	low_perf_theme.set_meta("animations_enabled", false)
	low_perf_theme.set_meta("transitions_enabled", false)
	low_perf_theme.set_meta("particles_enabled", false)
	
	return low_perf_theme

## Monitor theme performance impact in real-time
static func monitor_theme_performance_impact() -> Dictionary:
	"""Analyze current theme's performance impact"""
	
	var metrics = {
		"fps": Engine.get_frames_per_second(),
		"frame_time": Performance.get_monitor(Performance.TIME_PROCESS),
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"vertex_count": Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
		"material_changes": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"texture_memory": OS.get_static_memory_usage() / 1024.0 / 1024.0,
		"video_memory": OS.get_static_memory_usage() / 1024.0 / 1024.0,
		"performance_score": 0.0,
		"bottlenecks": [],
		"recommendations": []
	}
	
	# Calculate performance score (0-100)
	metrics.performance_score = _calculate_performance_score(metrics)
	
	# Identify bottlenecks
	metrics.bottlenecks = _identify_bottlenecks(metrics)
	
	# Generate recommendations
	metrics.recommendations = _generate_recommendations(metrics)
	
	return metrics

## Dynamically adjust theme quality based on performance
static func auto_adjust_theme_quality(current_theme: Theme, target_fps: int = 60) -> Theme:
	"""Automatically adjust theme quality to maintain target FPS"""
	
	var current_fps = Engine.get_frames_per_second()
	
	if current_fps >= target_fps:
		# Performance is good, no changes needed
		return current_theme
	
	# Create adjusted theme
	var adjusted_theme = current_theme.duplicate(true)
	
	# Calculate quality reduction needed
	var quality_reduction = 1.0 - (float(current_fps) / float(target_fps))
	quality_reduction = clamp(quality_reduction, 0.0, 0.8)  # Max 80% reduction
	
	# Apply progressive optimizations
	if quality_reduction > 0.1:
		_reduce_shadow_quality(adjusted_theme, 1.0 - quality_reduction)
	
	if quality_reduction > 0.3:
		_reduce_transparency(adjusted_theme, 0.5)
		_disable_blur_effects(adjusted_theme)
	
	if quality_reduction > 0.5:
		_disable_animations(adjusted_theme)
		_simplify_gradients(adjusted_theme)
	
	if quality_reduction > 0.7:
		_remove_all_effects(adjusted_theme)
	
	# Mark as auto-adjusted
	adjusted_theme.set_meta("auto_adjusted", true)
	adjusted_theme.set_meta("quality_level", 1.0 - quality_reduction)
	
	return adjusted_theme

# === PERFORMANCE PROFILE DETECTION ===

static func _determine_performance_profile(gpu_info: Dictionary) -> PerformanceProfile:
	"""Determine performance profile based on GPU info"""
	
	# Check for specific GPU vendors and models
	var gpu_name = gpu_info.get("name", "").to_lower()
	var vram_mb = gpu_info.get("vram_mb", 0)
	var _compute_units = gpu_info.get("compute_units", 0)
	
	# Intel integrated graphics
	if gpu_name.contains("intel") and (gpu_name.contains("uhd") or gpu_name.contains("iris")):
		if gpu_name.contains("iris xe") or gpu_name.contains("iris plus"):
			return PerformanceProfile.LOW
		else:
			return PerformanceProfile.ULTRA_LOW
	
	# NVIDIA GPUs
	elif gpu_name.contains("nvidia") or gpu_name.contains("geforce"):
		if gpu_name.contains("rtx 40") or gpu_name.contains("rtx 4090") or gpu_name.contains("rtx 4080"):
			return PerformanceProfile.ULTRA
		elif gpu_name.contains("rtx 30") or gpu_name.contains("rtx 20"):
			return PerformanceProfile.HIGH
		elif gpu_name.contains("gtx 16") or gpu_name.contains("rtx"):
			return PerformanceProfile.MEDIUM
		else:
			return PerformanceProfile.LOW
	
	# AMD GPUs
	elif gpu_name.contains("amd") or gpu_name.contains("radeon"):
		if gpu_name.contains("rx 7900") or gpu_name.contains("rx 6900"):
			return PerformanceProfile.ULTRA
		elif gpu_name.contains("rx 6800") or gpu_name.contains("rx 6700"):
			return PerformanceProfile.HIGH
		elif gpu_name.contains("rx 6600") or gpu_name.contains("rx 5700"):
			return PerformanceProfile.MEDIUM
		else:
			return PerformanceProfile.LOW
	
	# Apple Silicon
	elif gpu_name.contains("apple") or gpu_name.contains("m1") or gpu_name.contains("m2"):
		if gpu_name.contains("m2 pro") or gpu_name.contains("m2 max") or gpu_name.contains("m2 ultra"):
			return PerformanceProfile.HIGH
		elif gpu_name.contains("m2") or gpu_name.contains("m1 pro") or gpu_name.contains("m1 max"):
			return PerformanceProfile.MEDIUM
		else:
			return PerformanceProfile.LOW
	
	# Fallback based on VRAM
	elif vram_mb >= 8192:
		return PerformanceProfile.HIGH
	elif vram_mb >= 4096:
		return PerformanceProfile.MEDIUM
	elif vram_mb >= 2048:
		return PerformanceProfile.LOW
	else:
		return PerformanceProfile.ULTRA_LOW

static func _analyze_hardware_capabilities(gpu_info: Dictionary) -> int:
	"""Analyze and return hardware capabilities as flags"""
	
	var capabilities = 0
	
	# Basic capabilities (most modern GPUs support these)
	capabilities |= HardwareCapability.SHADER_SUPPORT
	capabilities |= HardwareCapability.TRANSPARENCY_SUPPORT
	
	# Check for advanced features
	var gpu_name = gpu_info.get("name", "").to_lower()
	var vram_mb = gpu_info.get("vram_mb", 0)
	
	# Blur support (requires decent GPU)
	if vram_mb >= 2048 and not gpu_name.contains("intel"):
		capabilities |= HardwareCapability.BLUR_SUPPORT
	
	# Particle support
	if vram_mb >= 1024:
		capabilities |= HardwareCapability.PARTICLE_SUPPORT
	
	# Shadow support
	if vram_mb >= 2048:
		capabilities |= HardwareCapability.SHADOW_SUPPORT
	
	# Animation support (almost always available)
	capabilities |= HardwareCapability.ANIMATION_SUPPORT
	
	# High DPI support
	if gpu_info.get("supports_high_dpi", true):
		capabilities |= HardwareCapability.HIGH_DPI_SUPPORT
	
	return capabilities

# === OPTIMIZATION METHODS ===

static func _apply_ultra_low_optimizations(theme: Theme, _capabilities: int) -> void:
	"""Apply maximum optimizations for ultra-low-end hardware"""
	
	# Remove all effects
	_remove_all_effects(theme)
	
	# Use solid colors only
	_convert_to_solid_colors(theme)
	
	# Disable all animations
	theme.set_meta("animations_enabled", false)
	theme.set_meta("transitions_enabled", false)
	
	# Reduce font sizes slightly for performance
	_reduce_font_complexity(theme)
	
	# Use minimal corner radius
	_minimize_corner_radius(theme)

static func _apply_low_optimizations(theme: Theme, capabilities: int) -> void:
	"""Apply optimizations for low-end hardware"""
	
	# Disable blur effects
	if not (capabilities & HardwareCapability.BLUR_SUPPORT):
		_disable_blur_effects(theme)
	
	# Reduce shadow quality
	_reduce_shadow_quality(theme, 0.3)
	
	# Simplify gradients
	_simplify_gradients(theme)
	
	# Limit transparency
	_reduce_transparency(theme, 0.7)
	
	# Reduce animation complexity
	theme.set_meta("animation_speed_multiplier", 0.5)

static func _apply_medium_optimizations(theme: Theme, capabilities: int) -> void:
	"""Apply moderate optimizations"""
	
	# Reduce shadow quality slightly
	_reduce_shadow_quality(theme, 0.7)
	
	# Optimize blur if not fully supported
	if not (capabilities & HardwareCapability.BLUR_SUPPORT):
		theme.set_meta("blur_quality", 1)  # Low quality
	else:
		theme.set_meta("blur_quality", 2)  # Medium quality

static func _apply_high_optimizations(theme: Theme, capabilities: int) -> void:
	"""Apply minimal optimizations for high-end hardware"""
	
	# Enable most features
	theme.set_meta("blur_quality", 3)  # High quality
	theme.set_meta("shadow_quality", "high")
	theme.set_meta("enable_particles", true)
	
	# Only optimize if specific features aren't supported
	if not (capabilities & HardwareCapability.BLUR_SUPPORT):
		theme.set_meta("blur_quality", 2)

static func _apply_ultra_optimizations(theme: Theme, _capabilities: int) -> void:
	"""Enable all features for ultra-high-end hardware"""
	
	# Enable everything at maximum quality
	theme.set_meta("blur_quality", 3)
	theme.set_meta("shadow_quality", "ultra")
	theme.set_meta("enable_particles", true)
	theme.set_meta("enable_advanced_effects", true)
	theme.set_meta("animation_quality", "high")

# === EFFECT REMOVAL AND SIMPLIFICATION ===

static func _remove_all_effects(theme: Theme) -> void:
	"""Remove all visual effects from theme"""
	
	var types = ["PanelContainer", "Button", "LineEdit", "TextEdit", "ItemList", "Tree"]
	var styleboxes = ["panel", "normal", "hover", "pressed", "focus", "disabled"]
	
	for type in types:
		for stylebox_name in styleboxes:
			if theme.has_stylebox(stylebox_name, type):
				var stylebox = theme.get_stylebox(stylebox_name, type)
				if stylebox is StyleBoxFlat:
					# Remove shadows
					stylebox.shadow_size = 0
					stylebox.shadow_color.a = 0
					
					# Remove anti-aliasing
					stylebox.anti_aliasing = false
					
					# Ensure opaque backgrounds
					if stylebox.bg_color.a < 1.0:
						stylebox.bg_color.a = 1.0

static func _simplify_colors(theme: Theme) -> void:
	"""Simplify colors by removing transparency"""
	
	# Simplify all color properties
	var color_properties = ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]
	var types = ["Button", "Label", "LineEdit", "RichTextLabel"]
	
	for type in types:
		for prop in color_properties:
			if theme.has_color(prop, type):
				var color = theme.get_color(prop, type)
				if color.a < 1.0:
					color.a = 1.0
					theme.set_color(prop, type, color)

static func _reduce_complexity(theme: Theme) -> void:
	"""Reduce overall visual complexity"""
	
	# Reduce border widths
	var types = ["PanelContainer", "Button", "LineEdit"]
	var styleboxes = ["panel", "normal", "hover", "pressed", "focus"]
	
	for type in types:
		for stylebox_name in styleboxes:
			if theme.has_stylebox(stylebox_name, type):
				var stylebox = theme.get_stylebox(stylebox_name, type)
				if stylebox is StyleBoxFlat:
					if stylebox.border_width_left > 1:
						stylebox.border_width_left = 1
						stylebox.border_width_top = 1
						stylebox.border_width_right = 1
						stylebox.border_width_bottom = 1

static func _reduce_shadow_quality(theme: Theme, quality: float) -> void:
	"""Reduce shadow quality by specified amount"""
	
	var types = ["PanelContainer", "Button", "LineEdit", "PopupPanel"]
	var styleboxes = ["panel", "normal", "hover", "pressed"]
	
	for type in types:
		for stylebox_name in styleboxes:
			if theme.has_stylebox(stylebox_name, type):
				var stylebox = theme.get_stylebox(stylebox_name, type)
				if stylebox is StyleBoxFlat and stylebox.shadow_size > 0:
					stylebox.shadow_size = int(stylebox.shadow_size * quality)
					stylebox.shadow_color.a *= quality

static func _disable_blur_effects(theme: Theme) -> void:
	"""Disable blur effects in theme"""
	theme.set_meta("blur_enabled", false)
	theme.set_meta("blur_quality", 0)

static func _reduce_transparency(theme: Theme, max_alpha: float) -> void:
	"""Limit transparency to improve performance"""
	
	var types = ["PanelContainer", "Button", "PopupPanel"]
	var styleboxes = ["panel", "normal", "hover"]
	
	for type in types:
		for stylebox_name in styleboxes:
			if theme.has_stylebox(stylebox_name, type):
				var stylebox = theme.get_stylebox(stylebox_name, type)
				if stylebox is StyleBoxFlat and stylebox.bg_color.a < max_alpha:
					stylebox.bg_color.a = max_alpha

static func _disable_animations(theme: Theme) -> void:
	"""Disable all animations"""
	theme.set_meta("animations_enabled", false)
	theme.set_meta("transition_duration", 0.0)
	theme.set_meta("animation_speed_multiplier", 0.0)

static func _simplify_gradients(theme: Theme) -> void:
	"""Convert gradients to solid colors"""
	# Note: Godot StyleBoxFlat doesn't support gradients directly,
	# but this would handle custom gradient implementations
	theme.set_meta("gradients_enabled", false)

static func _convert_to_solid_colors(theme: Theme) -> void:
	"""Convert all colors to fully opaque"""
	_simplify_colors(theme)
	_reduce_transparency(theme, 1.0)

static func _reduce_font_complexity(theme: Theme) -> void:
	"""Simplify font rendering settings"""
	theme.set_meta("font_antialiasing", false)
	theme.set_meta("font_hinting", "normal")

static func _minimize_corner_radius(theme: Theme) -> void:
	"""Reduce corner radius for performance"""
	
	var types = ["PanelContainer", "Button", "LineEdit"]
	var styleboxes = ["panel", "normal", "hover", "pressed", "focus"]
	
	for type in types:
		for stylebox_name in styleboxes:
			if theme.has_stylebox(stylebox_name, type):
				var stylebox = theme.get_stylebox(stylebox_name, type)
				if stylebox is StyleBoxFlat:
					var max_radius = 4
					stylebox.corner_radius_top_left = min(stylebox.corner_radius_top_left, max_radius)
					stylebox.corner_radius_top_right = min(stylebox.corner_radius_top_right, max_radius)
					stylebox.corner_radius_bottom_left = min(stylebox.corner_radius_bottom_left, max_radius)
					stylebox.corner_radius_bottom_right = min(stylebox.corner_radius_bottom_right, max_radius)

# === PERFORMANCE MONITORING ===

static func _calculate_performance_score(metrics: Dictionary) -> float:
	"""Calculate overall performance score (0-100)"""
	
	var score = 100.0
	
	# FPS impact (40% weight)
	var fps = metrics.get("fps", 60)
	var fps_score = clamp(fps / 60.0, 0.0, 1.0) * 40.0
	score = fps_score
	
	# Draw calls impact (30% weight)
	var draw_calls = metrics.get("draw_calls", 0)
	var draw_score = clamp(1.0 - (draw_calls / 200.0), 0.0, 1.0) * 30.0
	score += draw_score
	
	# Memory impact (20% weight)
	var memory = metrics.get("video_memory", 0)
	var mem_score = clamp(1.0 - (memory / 500.0), 0.0, 1.0) * 20.0
	score += mem_score
	
	# Frame time consistency (10% weight)
	var frame_time = metrics.get("frame_time", 16.67)
	var time_score = clamp(1.0 - (frame_time / 33.33), 0.0, 1.0) * 10.0
	score += time_score
	
	return score

static func _identify_bottlenecks(metrics: Dictionary) -> Array:
	"""Identify performance bottlenecks"""
	
	var bottlenecks = []
	
	if metrics.get("fps", 60) < 30:
		bottlenecks.append("Low FPS - Consider reducing visual effects")
	
	if metrics.get("draw_calls", 0) > 150:
		bottlenecks.append("High draw calls - Too many UI elements visible")
	
	if metrics.get("video_memory", 0) > 400:
		bottlenecks.append("High VRAM usage - Reduce texture quality or count")
	
	if metrics.get("material_changes", 0) > 50:
		bottlenecks.append("Excessive material changes - Optimize theme consistency")
	
	return bottlenecks

static func _generate_recommendations(metrics: Dictionary) -> Array:
	"""Generate performance improvement recommendations"""
	
	var recommendations = []
	var score = metrics.get("performance_score", 100)
	
	if score < 30:
		recommendations.append("Switch to low performance theme variant")
		recommendations.append("Disable all visual effects")
		recommendations.append("Reduce UI complexity")
	elif score < 60:
		recommendations.append("Disable blur and transparency effects")
		recommendations.append("Reduce shadow quality")
		recommendations.append("Limit animations")
	elif score < 80:
		recommendations.append("Consider reducing shadow quality")
		recommendations.append("Optimize transparent panels")
	
	return recommendations

# === METADATA ===

static func _add_performance_metadata(theme: Theme, profile: PerformanceProfile, capabilities: int) -> void:
	"""Add performance-related metadata to theme"""
	
	theme.set_meta("performance_profile", profile)
	theme.set_meta("hardware_capabilities", capabilities)
	theme.set_meta("optimization_timestamp", Time.get_unix_time_from_system())
	
	# Profile names for UI display
	var profile_names = {
		PerformanceProfile.ULTRA_LOW: "Ultra Low",
		PerformanceProfile.LOW: "Low",
		PerformanceProfile.MEDIUM: "Medium", 
		PerformanceProfile.HIGH: "High",
		PerformanceProfile.ULTRA: "Ultra"
	}
	
	theme.set_meta("performance_profile_name", profile_names.get(profile, "Unknown"))
