## ThemePresetManager.gd
## Advanced theme preset management for educational contexts
##
## This system provides pre-configured theme combinations optimized for
## specific educational scenarios, accessibility needs, and institutional requirements.

class_name ThemePresetManager
extends RefCounted

# === EDUCATIONAL PRESET DEFINITIONS ===

const EDUCATIONAL_PRESETS = {
	"medical_student_study": {
		"name": "Medical Student Study",
		"description": "Optimized for long study sessions with reduced eye strain",
		"theme_variant": "enhanced",
		"accessibility_level": "standard",
		"brain_color_intensity": 0.8,
		"glass_morphism_strength": 0.6,
		"typography_scale": 1.0,
		"contrast_boost": 0.0,
		"use_case": "Individual study sessions, interactive learning"
	},
	
	"clinical_training": {
		"name": "Clinical Training",
		"description": "Professional appearance for clinical education settings",
		"theme_variant": "minimal",
		"accessibility_level": "standard", 
		"brain_color_intensity": 0.7,
		"glass_morphism_strength": 0.3,
		"typography_scale": 1.0,
		"contrast_boost": 0.1,
		"use_case": "Hospital training, professional presentations"
	},
	
	"accessibility_max": {
		"name": "Maximum Accessibility",
		"description": "WCAG AAA compliance with enhanced visibility",
		"theme_variant": "high_contrast",
		"accessibility_level": "maximum",
		"brain_color_intensity": 1.0,
		"glass_morphism_strength": 0.0,
		"typography_scale": 1.2,
		"contrast_boost": 0.3,
		"use_case": "Visual impairments, institutional compliance"
	},
	
	"colorblind_optimized": {
		"name": "Colorblind Optimized",
		"description": "Blue-orange palette with shape differentiation",
		"theme_variant": "colorblind_safe",
		"accessibility_level": "colorblind",
		"brain_color_intensity": 0.9,
		"glass_morphism_strength": 0.4,
		"typography_scale": 1.0,
		"contrast_boost": 0.2,
		"use_case": "Color vision deficiencies, universal design"
	},
	
	"presentation_mode": {
		"name": "Presentation Mode",
		"description": "High visibility for classroom projection",
		"theme_variant": "enhanced",
		"accessibility_level": "presentation",
		"brain_color_intensity": 1.0,
		"glass_morphism_strength": 0.2,
		"typography_scale": 1.3,
		"contrast_boost": 0.4,
		"use_case": "Classroom projection, large audiences"
	},
	
	"research_analysis": {
		"name": "Research Analysis",
		"description": "Neutral colors for accurate data visualization",
		"theme_variant": "minimal",
		"accessibility_level": "scientific",
		"brain_color_intensity": 0.6,
		"glass_morphism_strength": 0.1,
		"typography_scale": 0.9,
		"contrast_boost": 0.0,
		"use_case": "Scientific research, data analysis"
	}
}

# === INSTITUTIONAL PRESETS ===

const INSTITUTIONAL_PRESETS = {
	"hospital_system": {
		"name": "Hospital System Standard",
		"base_preset": "clinical_training",
		"brand_colors": {
			"primary_override": Color("#2E5CE6"),  # Medical blue
			"accent_override": Color("#00A86B")    # Medical green
		},
		"compliance_level": "HIPAA_WCAG_AAA"
	},
	
	"medical_school": {
		"name": "Medical School Standard", 
		"base_preset": "medical_student_study",
		"brand_colors": {
			"primary_override": Color("#1B4B7A"),  # Academic blue
			"accent_override": Color("#C8102E")    # Academic red
		},
		"compliance_level": "ADA_SECTION_508"
	},
	
	"research_institution": {
		"name": "Research Institution",
		"base_preset": "research_analysis",
		"brand_colors": {
			"primary_override": Color("#003366"),  # Scientific navy
			"accent_override": Color("#FF6B35")    # Research orange
		},
		"compliance_level": "SCIENTIFIC_PUBLICATION"
	}
}

# === DYNAMIC PRESET MANAGEMENT ===

## Apply educational preset with full system integration
static func apply_educational_preset(preset_name: String) -> bool:
	"""Apply a complete educational preset configuration"""
	
	if not EDUCATIONAL_PRESETS.has(preset_name):
		push_error("[ThemePresetManager] Unknown preset: " + preset_name)
		return false
	
	var preset = EDUCATIONAL_PRESETS[preset_name]
	
	print("[ThemePresetManager] Applying preset: %s" % preset.name)
	
	# Apply base theme variant
	var ucm = Engine.get_singleton("UnifiedColorManager") if Engine.has_singleton("UnifiedColorManager") else null
	if ucm and ucm.has_method("set_theme_variant"):
		ucm.set_theme_variant(preset.theme_variant)
	
	# Configure accessibility level
	_apply_accessibility_level(preset.accessibility_level)
	
	# Adjust brain structure colors
	_adjust_brain_color_intensity(preset.brain_color_intensity)
	
	# Configure glass morphism
	_configure_glass_morphism(preset.glass_morphism_strength)
	
	# Apply typography scaling
	_apply_typography_scaling(preset.typography_scale)
	
	# Apply contrast boost
	_apply_contrast_boost(preset.contrast_boost)
	
	print("[ThemePresetManager] ✅ Preset applied: %s" % preset.name)
	return true

## Apply institutional branding with compliance
static func apply_institutional_preset(institution_name: String) -> bool:
	"""Apply institutional preset with brand colors and compliance"""
	
	if not INSTITUTIONAL_PRESETS.has(institution_name):
		push_error("[ThemePresetManager] Unknown institution: " + institution_name)
		return false
	
	var institution = INSTITUTIONAL_PRESETS[institution_name]
	
	print("[ThemePresetManager] Applying institutional preset: %s" % institution.name)
	
	# Apply base educational preset
	if institution.has("base_preset"):
		apply_educational_preset(institution.base_preset)
	
	# Override with brand colors
	if institution.has("brand_colors"):
		_apply_brand_colors(institution.brand_colors)
	
	# Ensure compliance requirements
	_ensure_compliance(institution.compliance_level)
	
	print("[ThemePresetManager] ✅ Institutional preset applied: %s" % institution.name)
	return true

## Create custom preset from current settings
static func create_custom_preset(name: String, description: String = "") -> Dictionary:
	"""Create a custom preset from current theme settings"""
	
	var current_state = {}
	var ucm = Engine.get_singleton("UnifiedColorManager") if Engine.has_singleton("UnifiedColorManager") else null
	if ucm and ucm.has_method("get_system_status"):
		current_state = ucm.get_system_status()
	
	var custom_preset = {
		"name": name,
		"description": description,
		"theme_variant": current_state.current_theme,
		"accessibility_level": "custom",
		"brain_color_intensity": _get_current_brain_intensity(),
		"glass_morphism_strength": _get_current_glass_strength(), 
		"typography_scale": _get_current_typography_scale(),
		"contrast_boost": _get_current_contrast_boost(),
		"use_case": "Custom configuration",
		"created_timestamp": Time.get_unix_time_from_system()
	}
	
	print("[ThemePresetManager] Custom preset created: %s" % name)
	return custom_preset

## Get all available presets for UI
static func get_available_presets() -> Dictionary:
	"""Get all available presets organized by category"""
	
	return {
		"educational": EDUCATIONAL_PRESETS,
		"institutional": INSTITUTIONAL_PRESETS
	}

## Get preset recommendations based on context
static func get_preset_recommendations(context: Dictionary) -> Array[String]:
	"""Get preset recommendations based on usage context"""
	
	var recommendations: Array[String] = []
	
	# Analyze context parameters
	var user_type = context.get("user_type", "")
	var accessibility_needs = context.get("accessibility_needs", [])
	var environment = context.get("environment", "")
	var duration = context.get("session_duration", 0)
	
	# Recommend based on user type
	match user_type:
		"medical_student":
			recommendations.append("medical_student_study")
		"clinical_instructor":
			recommendations.append("clinical_training")
		"researcher":
			recommendations.append("research_analysis")
		"presenter":
			recommendations.append("presentation_mode")
	
	# Add accessibility recommendations
	if "visual_impairment" in accessibility_needs:
		recommendations.append("accessibility_max")
	if "color_blindness" in accessibility_needs:
		recommendations.append("colorblind_optimized")
	
	# Environment-based recommendations
	match environment:
		"classroom":
			if "presentation_mode" not in recommendations:
				recommendations.append("presentation_mode")
		"hospital":
			if "clinical_training" not in recommendations:
				recommendations.append("clinical_training")
		"laboratory":
			if "research_analysis" not in recommendations:
				recommendations.append("research_analysis")
	
	# Duration-based recommendations
	if duration > 3600:  # More than 1 hour
		if "medical_student_study" not in recommendations:
			recommendations.append("medical_student_study")
	
	return recommendations

# === PRESET CONFIGURATION HELPERS ===

static func _apply_accessibility_level(level: String) -> void:
	"""Apply accessibility configuration based on level"""
	
	match level:
		"maximum":
			var ucm = Engine.get_singleton("UnifiedColorManager") if Engine.has_singleton("UnifiedColorManager") else null
			if ucm:
				ucm.accessibility_validation = true
			# TODO: Enable validation when method is available
			# ColorSystemValidator._validation_enabled = true
		"colorblind":
			# Enable colorblind-specific features
			pass
		"presentation":
			# Configure for projection visibility
			pass
		"scientific":
			# Configure for research accuracy
			pass
		"standard":
			# Default accessibility settings
			pass

static func _adjust_brain_color_intensity(intensity: float) -> void:
	"""Adjust brain structure color intensity"""
	
	# This would modify the brain structure colors globally
	# TODO: Implement brain color intensity adjustment when API is available
	print("[ThemePresetManager] Brain color intensity adjustment requested: %f" % intensity)
	# Note: Direct constant modification not allowed in GDScript
	# for structure_name in M3DesignTokens.BRAIN_STRUCTURE_COLORS:
	#     M3DesignTokens.BRAIN_STRUCTURE_COLORS[structure_name] = adjusted_color

static func _configure_glass_morphism(strength: float) -> void:
	"""Configure glass morphism effect strength"""
	
	# Update opacity values based on strength
	# TODO: Implement glass morphism configuration when API is available
	print("[ThemePresetManager] Glass morphism strength requested: %f" % strength)
	# Note: Direct constant modification not allowed in GDScript
	# for variant in ShaderColorAdapter.GLASS_OPACITY_VARIANTS:
	#     opacity_data["tint_alpha"] *= strength

static func _apply_typography_scaling(scale: float) -> void:
	"""Apply typography scaling across the system"""
	
	# Scale all typography sizes
	# TODO: Implement typography scaling when API is available
	print("[ThemePresetManager] Typography scaling requested: %f" % scale)
	# Note: Direct constant modification not allowed in GDScript
	# for type_name in M3DesignTokens.M3_TYPE_SCALE:
	#     type_data["size"] = int(type_data["size"] * scale)

static func _apply_contrast_boost(boost: float) -> void:
	"""Apply contrast boost to improve visibility"""
	
	if boost <= 0.0:
		return
	
	# Boost contrast for all colors against surface
	# TODO: Implement contrast boost when API is available
	print("[ThemePresetManager] Contrast boost requested: %f" % boost)
	# Note: Direct constant modification not allowed in GDScript
	# var surface_color = M3DesignTokens.get_color("surface")
	# for color_name in M3DesignTokens.M3_COLORS:
	#     M3DesignTokens.M3_COLORS[color_name] = boosted_color

static func _apply_brand_colors(brand_colors: Dictionary) -> void:
	"""Apply institutional brand color overrides"""
	
	# TODO: Implement brand color overrides when API is available
	print("[ThemePresetManager] Brand colors requested: %s" % brand_colors)
	# Note: Direct constant modification not allowed in GDScript
	# for override_name in brand_colors:
	#     var color = brand_colors[override_name]
	#     M3DesignTokens.M3_COLORS["primary"] = color

static func _ensure_compliance(compliance_level: String) -> void:
	"""Ensure compliance with specified standards"""
	
	match compliance_level:
		"HIPAA_WCAG_AAA":
			# Ensure medical privacy and accessibility
			_validate_medical_compliance()
		"ADA_SECTION_508":
			# Ensure government accessibility standards
			_validate_government_compliance()
		"SCIENTIFIC_PUBLICATION":
			# Ensure scientific color accuracy
			_validate_scientific_compliance()

static func _validate_medical_compliance() -> void:
	"""Validate medical/healthcare compliance requirements"""
	
	var validation_result = ColorSystemValidator.validate_accessibility_compliance()
	
	if not validation_result.accessibility_issues.is_empty():
		push_warning("[ThemePresetManager] Medical compliance issues detected")
		for issue in validation_result.accessibility_issues:
			push_warning("  - %s: %s" % [issue.component, issue.issue])

static func _validate_government_compliance() -> void:
	"""Validate government accessibility standards"""
	
	# Ensure all interactive elements meet Section 508 requirements
	var surface = M3DesignTokens.get_color("surface")
	var primary = M3DesignTokens.get_color("primary")
	
	var contrast_ratio = ColorSystemValidator._calculate_contrast_ratio(primary, surface)
	
	if contrast_ratio < 7.0:
		push_warning("[ThemePresetManager] Section 508 compliance: Insufficient contrast ratio")

static func _validate_scientific_compliance() -> void:
	"""Validate scientific publication color standards"""
	
	# Ensure colors are suitable for scientific publication
	# Check for colorblind accessibility in brain structure colors
	var issues = 0
	
	for structure_name in M3DesignTokens.BRAIN_STRUCTURE_COLORS:
		var color = M3DesignTokens.BRAIN_STRUCTURE_COLORS[structure_name]
		var safe_color = UnifiedColorSystem._convert_to_colorblind_safe(color)
		
		if _color_distance(color, safe_color) > 0.3:
			issues += 1
	
	if issues > 0:
		push_warning("[ThemePresetManager] Scientific compliance: %d brain colors need colorblind review" % issues)

# === PRESET PERSISTENCE ===

## Save current settings as named preset
static func save_preset_to_file(preset_name: String, file_path: String = "") -> bool:
	"""Save current theme settings as a preset file"""
	
	if file_path.is_empty():
		file_path = "user://theme_presets/" + preset_name + ".json"
	
	var preset_data = create_custom_preset(preset_name)
	
	# Ensure directory exists
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("theme_presets"):
		dir.make_dir("theme_presets")
	
	# Save preset file
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("[ThemePresetManager] Cannot save preset file: " + file_path)
		return false
	
	var json_string = JSON.stringify(preset_data, "\t")
	file.store_string(json_string)
	file.close()
	
	print("[ThemePresetManager] Preset saved: %s" % file_path)
	return true

## Load preset from file
static func load_preset_from_file(file_path: String) -> Dictionary:
	"""Load preset configuration from file"""
	
	if not FileAccess.file_exists(file_path):
		push_error("[ThemePresetManager] Preset file not found: " + file_path)
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("[ThemePresetManager] Cannot open preset file: " + file_path)
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("[ThemePresetManager] Invalid JSON in preset file: " + file_path)
		return {}
	
	return json.data

# === UTILITY METHODS ===

static func _get_current_brain_intensity() -> float:
	"""Get current brain structure color intensity"""
	# This would calculate based on current brain structure colors
	return 0.8  # Default value

static func _get_current_glass_strength() -> float:
	"""Get current glass morphism strength"""
	# This would calculate based on current shader parameters
	return 0.6  # Default value

static func _get_current_typography_scale() -> float:
	"""Get current typography scale"""
	# This would calculate based on current font sizes
	return 1.0  # Default value

static func _get_current_contrast_boost() -> float:
	"""Get current contrast boost level"""
	# This would calculate based on current color adjustments
	return 0.0  # Default value

static func _boost_contrast(color: Color, background: Color, boost_amount: float) -> Color:
	"""Boost contrast of a color against a background"""
	
	var current_contrast = ColorSystemValidator._calculate_contrast_ratio(color, background)
	var target_contrast = current_contrast * (1.0 + boost_amount)
	
	# Adjust color to meet target contrast
	return UnifiedColorSystem._adjust_contrast(color, background, target_contrast)

static func _color_distance(c1: Color, c2: Color) -> float:
	"""Calculate distance between two colors"""
	
	var dr = c1.r - c2.r
	var dg = c1.g - c2.g
	var db = c1.b - c2.b
	var da = c1.a - c2.a
	
	return sqrt(dr*dr + dg*dg + db*db + da*da)