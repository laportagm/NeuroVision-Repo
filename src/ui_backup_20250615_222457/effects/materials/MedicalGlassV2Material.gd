## MedicalGlassV2Material.gd
## Material wrapper for the Medical Glass v2 shader with NeuroVision integration
##
## This class provides easy integration of the medical glass effect with the unified
## color system and Material3 design tokens, ensuring consistent theming across
## the educational platform.

class_name MedicalGlassV2Material
extends ShaderMaterial

## Medical glass visual intensity levels
enum GlassIntensity {
	SUBTLE,      # 0.1 - Minimal glass effect for text-heavy panels
	NORMAL,      # 0.15 - Standard medical interface appearance
	PROMINENT,   # 0.25 - Enhanced glass for featured panels
	DRAMATIC     # 0.35 - Maximum effect for hero elements
}

## Performance optimization profiles
enum PerformanceProfile {
	PERFORMANCE,  # Optimized for Intel UHD 620 and similar
	BALANCED,     # Default - good quality with solid performance
	QUALITY       # Maximum visual quality for high-end GPUs
}

# === INITIALIZATION ===

func _init():
	"""Initialize medical glass material with NeuroVision defaults"""
	shader = preload("res://src/ui/effects/shaders/medical_glass_v2.gdshader")
	_apply_default_medical_settings()
	_connect_to_theme_system()

func _apply_default_medical_settings() -> void:
	"""Apply medical-grade default settings for educational interface"""
	# Medical glass appearance
	set_shader_parameter("glass_intensity", 0.15)
	set_shader_parameter("glass_blur", 8.0)
	set_shader_parameter("glass_opacity", 0.9)
	set_shader_parameter("surface_roughness", 0.1)
	set_shader_parameter("depth_intensity", 0.5)
	set_shader_parameter("frosting_amount", 0.3)
	
	# Performance optimization
	set_shader_parameter("high_quality_mode", true)
	set_shader_parameter("blur_samples", 8)
	
	# Animation settings
	set_shader_parameter("hover_intensity", 1.0)
	set_shader_parameter("animation_speed", 1.0)
	set_shader_parameter("enable_shimmer", true)
	
	# Apply theme colors
	_update_theme_colors()

func _connect_to_theme_system() -> void:
	"""Connect to NeuroVision's unified theme system for automatic updates"""
	if UnifiedColorManager:
		UnifiedColorManager.theme_changed.connect(_on_theme_changed)

# === THEME INTEGRATION ===

func _update_theme_colors() -> void:
	"""Update shader colors based on current Material3 theme"""
	
	# Try to get colors from unified color manager first
	if UnifiedColorManager:
		var primary_color = UnifiedColorManager.get_color("primary")
		var _surface_color = UnifiedColorManager.get_color("surface_container")
		
		# Create medical glass tint (subtle primary color overlay)
		var glass_tint = Color(primary_color.r, primary_color.g, primary_color.b, 0.1)
		set_shader_parameter("glass_tint", glass_tint)
		
		# Professional border using primary container
		var border_color = UnifiedColorManager.get_color("primary_container")
		border_color.a = 0.3  # Semi-transparent for subtle effect
		set_shader_parameter("border_color", border_color)
		return
	
	# Fallback if systems not available
	push_warning("[MedicalGlass] Color systems not available, using fallback colors")
	_apply_fallback_colors()

func _apply_fallback_colors() -> void:
	"""Apply fallback medical colors if theme system unavailable"""
	set_shader_parameter("glass_tint", Color(0.35, 0.65, 1.0, 0.1))  # Medical blue
	set_shader_parameter("border_color", Color(0.35, 0.65, 1.0, 0.3))

func _on_theme_changed(theme_name: String) -> void:
	"""Handle theme changes from unified color system"""
	_update_theme_colors()
	print("[MedicalGlass] Updated for theme: ", theme_name)

# === PUBLIC CONFIGURATION API ===

## Configure glass intensity for different UI contexts
func set_glass_intensity(intensity: GlassIntensity) -> void:
	"""Set glass effect intensity based on educational context"""
	var intensity_values = {
		GlassIntensity.SUBTLE: 0.1,
		GlassIntensity.NORMAL: 0.15,
		GlassIntensity.PROMINENT: 0.25,
		GlassIntensity.DRAMATIC: 0.35
	}
	
	set_shader_parameter("glass_intensity", intensity_values[intensity])

## Optimize performance for different hardware profiles
func set_performance_profile(profile: PerformanceProfile) -> void:
	"""Optimize shader for different hardware capabilities"""
	match profile:
		PerformanceProfile.PERFORMANCE:
			set_shader_parameter("high_quality_mode", false)
			set_shader_parameter("blur_samples", 4)
			set_shader_parameter("glass_blur", 4.0)
			set_shader_parameter("enable_shimmer", false)
			
		PerformanceProfile.BALANCED:
			set_shader_parameter("high_quality_mode", true)
			set_shader_parameter("blur_samples", 8)
			set_shader_parameter("glass_blur", 8.0)
			set_shader_parameter("enable_shimmer", true)
			
		PerformanceProfile.QUALITY:
			set_shader_parameter("high_quality_mode", true)
			set_shader_parameter("blur_samples", 16)
			set_shader_parameter("glass_blur", 12.0)
			set_shader_parameter("enable_shimmer", true)

## Configure for medical interface context
func configure_for_medical_panel(panel_type: String = "standard") -> void:
	"""Configure shader specifically for medical education panels"""
	match panel_type.to_lower():
		"info_panel":
			set_glass_intensity(GlassIntensity.NORMAL)
			set_shader_parameter("border_width", 0.002)
			
		"assessment_panel":
			set_glass_intensity(GlassIntensity.PROMINENT)
			set_shader_parameter("border_width", 0.003)
			set_shader_parameter("hover_intensity", 1.2)
			
		"teacher_dashboard":
			set_glass_intensity(GlassIntensity.SUBTLE)
			set_shader_parameter("border_width", 0.001)
			set_shader_parameter("enable_shimmer", false)
			
		"hero_panel":
			set_glass_intensity(GlassIntensity.DRAMATIC)
			set_shader_parameter("border_width", 0.004)
			set_shader_parameter("hover_intensity", 1.5)
			
		_:  # standard
			set_glass_intensity(GlassIntensity.NORMAL)

## Enable/disable interactive effects
func set_interactive_mode(enabled: bool) -> void:
	"""Enable or disable interactive shimmer effects"""
	set_shader_parameter("enable_shimmer", enabled)
	set_shader_parameter("hover_intensity", 1.0 if enabled else 0.0)

## Configure for accessibility requirements
func configure_for_accessibility(high_contrast: bool = false, reduced_motion: bool = false) -> void:
	"""Adjust shader for accessibility compliance"""
	if high_contrast:
		# Reduce glass effects for better text contrast
		set_shader_parameter("glass_intensity", 0.05)
		set_shader_parameter("glass_opacity", 0.95)
		set_shader_parameter("frosting_amount", 0.1)
	
	if reduced_motion:
		# Disable animations for users sensitive to motion
		set_shader_parameter("enable_shimmer", false)
		set_shader_parameter("animation_speed", 0.0)
		set_shader_parameter("hover_intensity", 0.0)

# === UTILITY FUNCTIONS ===

## Get current shader performance cost estimate
func get_performance_cost() -> String:
	"""Return estimated performance cost description"""
	var high_quality = get_shader_parameter("high_quality_mode")
	var blur_samples = get_shader_parameter("blur_samples")
	
	if not high_quality:
		return "Low (~0.6ms per frame)"
	elif blur_samples <= 8:
		return "Medium (~1.2ms per frame)"
	else:
		return "High (~1.8ms per frame)"

## Validate theme integration
func validate_theme_integration() -> bool:
	"""Check if material is properly integrated with theme system"""
	return UnifiedColorManager != null

## Create material configured for specific educational component
static func create_for_component(component_type: String) -> MedicalGlassV2Material:
	"""Factory method to create pre-configured materials for common components"""
	var material = MedicalGlassV2Material.new()
	material.configure_for_medical_panel(component_type)
	
	# Optimize for current hardware (fallback to balanced if PerformanceMonitor unavailable)
	material.set_performance_profile(PerformanceProfile.BALANCED)
	
	return material