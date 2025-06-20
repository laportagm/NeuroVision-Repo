## Contextual Color Generation System for NeuroVision
## Phase 4: Advanced Material 3 Theme Integration
##
## This system generates dynamic, context-aware colors for brain structures
## based on educational context, user preferences, and accessibility requirements.

class_name ContextualColorGenerator
extends RefCounted

# === SIGNALS ===
signal color_palette_generated(context: String, palette: Dictionary)
signal accessibility_adjustment_applied(original: Color, adjusted: Color)
signal learning_context_updated(context: Dictionary)

# === CONSTANTS ===
const LEARNING_LEVELS = ["beginner", "intermediate", "advanced", "expert"]
const CLINICAL_CONTEXTS = ["anatomical", "pathological", "functional", "developmental"]
const ACCESSIBILITY_MODES = ["standard", "high_contrast", "colorblind_safe", "wcag_aaa"]

# Brain region categories for color coordination
const BRAIN_REGION_CATEGORIES = {
	"cerebral_cortex": ["frontal_lobe", "parietal_lobe", "temporal_lobe", "occipital_lobe"],
	"subcortical": ["thalamus", "hypothalamus", "basal_ganglia", "amygdala", "hippocampus"],
	"brainstem": ["midbrain", "pons", "medulla"],
	"cerebellum": ["cerebellar_cortex", "cerebellar_nuclei"],
	"limbic": ["hippocampus", "amygdala", "cingulate", "fornix"],
	"motor": ["motor_cortex", "basal_ganglia", "cerebellum", "spinal_cord"],
	"sensory": ["somatosensory_cortex", "visual_cortex", "auditory_cortex", "thalamus"]
}

# === PROPERTIES ===
var M3Tokens = preload("res://src/ui_atomic/themes/core/M3DesignTokens.gd")
var current_learning_context: Dictionary = {}
var accessibility_mode: String = "standard"
var user_preferences: Dictionary = {}
var color_cache: Dictionary = {}
var palette_cache: Dictionary = {}
var last_cache_clear: float = 0.0

# Color harmony algorithms
var harmony_algorithms = {
	"complementary": "_generate_complementary_colors",
	"analogous": "_generate_analogous_colors", 
	"triadic": "_generate_triadic_colors",
	"split_complementary": "_generate_split_complementary_colors",
	"monochromatic": "_generate_monochromatic_colors"
}

# === INITIALIZATION ===

func _init():
	_initialize_default_context()
	_load_user_preferences()

func _initialize_default_context() -> void:
	"""Initialize default learning context"""
	current_learning_context = {
		"learning_level": "intermediate",
		"clinical_context": "anatomical",
		"focus_structure": "",
		"related_structures": [],
		"pathology_highlight": false,
		"functional_emphasis": false,
		"user_skill_level": "medical_student",
		"accessibility_requirements": [],
		"session_timestamp": Time.get_unix_time_from_system()
	}

func _load_user_preferences() -> void:
	"""Load user color preferences"""
	var tree = Engine.get_main_loop() as SceneTree
	var settings_manager = null
	if tree and tree.root and tree.root.has_node("SettingsManager"):
		settings_manager = tree.root.get_node_or_null("SettingsManager")
	
	if settings_manager and settings_manager.has_method("get_setting"):
		user_preferences = {
			"preferred_saturation": settings_manager.get_setting("color_saturation", 0.8),
			"preferred_brightness": settings_manager.get_setting("color_brightness", 0.9),
			"contrast_preference": settings_manager.get_setting("contrast_preference", "standard"),
			"colorblind_type": settings_manager.get_setting("colorblind_type", "none"),
			"animation_preference": settings_manager.get_setting("animation_preference", "standard")
		}
	else:
		user_preferences = {
			"preferred_saturation": 0.8,
			"preferred_brightness": 0.9,
			"contrast_preference": "standard",
			"colorblind_type": "none",
			"animation_preference": "standard"
		}

# === MAIN COLOR GENERATION ===

func generate_contextual_color(structure_name: String, context: Dictionary = {}) -> Color:
	"""Generate a contextual color for a brain structure"""
	var merged_context = _merge_contexts(current_learning_context, context)
	var cache_key = _generate_cache_key(structure_name, merged_context)
	
	# Check cache first
	if color_cache.has(cache_key):
		return color_cache[cache_key]
	
	# Get base color from M3 design tokens
	var base_color = M3Tokens.BRAIN_STRUCTURE_COLORS.get(structure_name, Color.CYAN)
	
	# Apply contextual modifications
	var contextual_color = _apply_contextual_modifications(base_color, structure_name, merged_context)
	
	# Apply accessibility adjustments
	var accessible_color = _apply_accessibility_adjustments(contextual_color, merged_context)
	
	# Apply user preferences
	var final_color = _apply_user_preferences(accessible_color)
	
	# Cache the result
	color_cache[cache_key] = final_color
	
	return final_color

func generate_contextual_palette(primary_structure: String, context: Dictionary = {}) -> Dictionary:
	"""Generate a harmonious color palette for related brain structures"""
	var merged_context = _merge_contexts(current_learning_context, context)
	var cache_key = "palette_" + _generate_cache_key(primary_structure, merged_context)
	
	# Check cache first
	if palette_cache.has(cache_key):
		return palette_cache[cache_key]
	
	# Get related structures based on context
	var related_structures = _get_related_structures(primary_structure, merged_context)
	
	# Choose harmony algorithm based on context
	var harmony_type = _determine_harmony_type(merged_context)
	
	# Generate base palette
	var primary_color = generate_contextual_color(primary_structure, merged_context)
	var palette = _generate_harmonious_palette(primary_color, related_structures, harmony_type)
	
	# Apply contextual adjustments to entire palette
	var contextual_palette = _apply_palette_context(palette, merged_context)
	
	# Cache the result
	palette_cache[cache_key] = contextual_palette
	
	color_palette_generated.emit(primary_structure, contextual_palette)
	return contextual_palette

# === CONTEXTUAL MODIFICATIONS ===

func _apply_contextual_modifications(base_color: Color, structure_name: String, context: Dictionary) -> Color:
	"""Apply context-specific color modifications"""
	var modified_color = base_color
	
	# Learning level adjustments
	var learning_level = context.get("learning_level", "intermediate")
	match learning_level:
		"beginner":
			# Increase saturation and brightness for better visibility
			modified_color.s = min(modified_color.s + 0.2, 1.0)
			modified_color.v = min(modified_color.v + 0.15, 1.0)
		"advanced":
			# More subdued colors for advanced users
			modified_color.s = modified_color.s * 0.85
			modified_color.v = modified_color.v * 0.95
		"expert":
			# Clinical accuracy over visual appeal
			modified_color = _ensure_clinical_accuracy(modified_color, structure_name)
	
	# Clinical context adjustments
	var clinical_context = context.get("clinical_context", "anatomical")
	match clinical_context:
		"pathological":
			# Shift toward warning colors for pathology
			modified_color = _apply_pathological_shift(modified_color)
		"functional":
			# Enhance colors based on functional activity
			modified_color = _apply_functional_enhancement(modified_color, structure_name)
		"developmental":
			# Use developmental color scheme
			modified_color = _apply_developmental_coloring(modified_color, structure_name)
	
	# Focus and emphasis adjustments
	if context.get("pathology_highlight", false):
		modified_color = _apply_pathology_highlighting(modified_color)
	
	if context.get("functional_emphasis", false):
		modified_color = _apply_functional_emphasis(modified_color)
	
	return modified_color

func _apply_pathological_shift(color: Color) -> Color:
	"""Shift color toward pathological indication colors"""
	# Blend with warning/error colors
	var warning_color = M3Tokens.M3_COLORS.get("warning", Color.ORANGE)
	return color.lerp(warning_color, 0.3)

func _apply_functional_enhancement(color: Color, structure_name: String) -> Color:
	"""Enhance color based on functional activity"""
	# Increase brightness and saturation for active regions
	var enhanced = color
	enhanced.s = min(enhanced.s + 0.15, 1.0)
	enhanced.v = min(enhanced.v + 0.1, 1.0)
	return enhanced

func _apply_developmental_coloring(color: Color, structure_name: String) -> Color:
	"""Apply developmental stage appropriate coloring"""
	# Use softer, more muted colors for developmental context
	var developmental = color
	developmental.s = developmental.s * 0.7
	developmental.v = developmental.v * 0.9
	return developmental

func _apply_pathology_highlighting(color: Color) -> Color:
	"""Apply pathology highlighting to color"""
	# Increase saturation and add slight red shift
	var highlighted = color
	highlighted.s = min(highlighted.s + 0.25, 1.0)
	highlighted.r = min(highlighted.r + 0.1, 1.0)
	return highlighted

func _apply_functional_emphasis(color: Color) -> Color:
	"""Apply functional emphasis to color"""
	# Increase brightness and add slight blue shift for neural activity
	var emphasized = color
	emphasized.v = min(emphasized.v + 0.15, 1.0)
	emphasized.b = min(emphasized.b + 0.05, 1.0)
	return emphasized

func _ensure_clinical_accuracy(color: Color, structure_name: String) -> Color:
	"""Ensure color maintains clinical accuracy standards"""
	# For clinical use, prioritize accuracy over aesthetics
	var clinical_colors = {
		"hippocampus": Color("#8B4513"),  # Clinical brown
		"amygdala": Color("#483D8B"),     # Clinical slate blue
		"cortex": Color("#696969"),       # Clinical gray
		"thalamus": Color("#2F4F4F"),     # Clinical dark slate gray
		"cerebellum": Color("#8FBC8F"),   # Clinical dark sea green
		"brainstem": Color("#A0522D")     # Clinical sienna
	}
	
	return clinical_colors.get(structure_name, color)

# === ACCESSIBILITY ADJUSTMENTS ===

func _apply_accessibility_adjustments(color: Color, context: Dictionary) -> Color:
	"""Apply accessibility adjustments based on user needs"""
	var adjusted_color = color
	
	# Apply colorblind adjustments
	var colorblind_type = user_preferences.get("colorblind_type", "none")
	if colorblind_type != "none":
		adjusted_color = _apply_colorblind_adjustments(adjusted_color, colorblind_type)
	
	# Apply contrast requirements
	var contrast_preference = user_preferences.get("contrast_preference", "standard")
	if contrast_preference == "high":
		adjusted_color = _enhance_contrast(adjusted_color)
	
	# Apply WCAG AAA compliance if required
	if accessibility_mode == "wcag_aaa":
		adjusted_color = _ensure_wcag_aaa_compliance(adjusted_color)
	
	accessibility_adjustment_applied.emit(color, adjusted_color)
	return adjusted_color

func _apply_colorblind_adjustments(color: Color, colorblind_type: String) -> Color:
	"""Adjust colors for different types of color blindness"""
	match colorblind_type:
		"protanopia":
			# Red-blind: enhance green and blue components
			return Color(color.r * 0.3, color.g * 1.2, color.b * 1.1, color.a)
		"deuteranopia":
			# Green-blind: enhance red and blue components
			return Color(color.r * 1.2, color.g * 0.3, color.b * 1.1, color.a)
		"tritanopia":
			# Blue-blind: enhance red and green components
			return Color(color.r * 1.1, color.g * 1.1, color.b * 0.3, color.a)
		"achromatopsia":
			# Complete color blindness: convert to high-contrast grayscale
			var gray = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b
			return Color(gray, gray, gray, color.a)
		_:
			return color

func _enhance_contrast(color: Color) -> Color:
	"""Enhance contrast for better visibility"""
	# Increase saturation and adjust brightness
	var enhanced = color
	enhanced.s = min(enhanced.s + 0.3, 1.0)
	
	# Push toward extremes for better contrast
	if enhanced.v < 0.5:
		enhanced.v = max(enhanced.v - 0.2, 0.0)
	else:
		enhanced.v = min(enhanced.v + 0.2, 1.0)
	
	return enhanced

func _ensure_wcag_aaa_compliance(color: Color) -> Color:
	"""Ensure color meets WCAG AAA contrast requirements"""
	var background = M3Tokens.M3_COLORS.get("surface", Color.BLACK)
	var contrast_ratio = _calculate_contrast_ratio(color, background)
	
	# WCAG AAA requires 7:1 contrast ratio for normal text
	if contrast_ratio < 7.0:
		return _adjust_for_contrast_ratio(color, background, 7.0)
	
	return color

func _calculate_contrast_ratio(foreground: Color, background: Color) -> float:
	"""Calculate WCAG contrast ratio between two colors"""
	var l1 = _get_relative_luminance(foreground)
	var l2 = _get_relative_luminance(background)
	
	var lighter = max(l1, l2)
	var darker = min(l1, l2)
	
	return (lighter + 0.05) / (darker + 0.05)

func _get_relative_luminance(color: Color) -> float:
	"""Calculate relative luminance for WCAG calculations"""
	var r = _linearize_rgb_component(color.r)
	var g = _linearize_rgb_component(color.g)
	var b = _linearize_rgb_component(color.b)
	
	return 0.2126 * r + 0.7152 * g + 0.0722 * b

func _linearize_rgb_component(component: float) -> float:
	"""Linearize RGB component for luminance calculation"""
	if component <= 0.03928:
		return component / 12.92
	else:
		return pow((component + 0.055) / 1.055, 2.4)

func _adjust_for_contrast_ratio(foreground: Color, background: Color, target_ratio: float) -> Color:
	"""Adjust foreground color to meet target contrast ratio"""
	var adjusted = foreground
	var step = 0.01
	var iterations = 0
	var max_iterations = 100
	
	while _calculate_contrast_ratio(adjusted, background) < target_ratio and iterations < max_iterations:
		# Try making it lighter or darker
		if adjusted.v < 0.5:
			adjusted.v = max(adjusted.v - step, 0.0)
		else:
			adjusted.v = min(adjusted.v + step, 1.0)
		
		iterations += 1
	
	return adjusted

# === COLOR HARMONY GENERATION ===

func _generate_harmonious_palette(primary_color: Color, structures: Array, harmony_type: String) -> Dictionary:
	"""Generate harmonious color palette using specified harmony algorithm"""
	var palette = {"primary": primary_color}
	
	if harmony_algorithms.has(harmony_type):
		var method_name = harmony_algorithms[harmony_type]
		if has_method(method_name):
			var harmonious_colors = call(method_name, primary_color, structures.size())
			for i in range(min(structures.size(), harmonious_colors.size())):
				palette[structures[i]] = harmonious_colors[i]
	else:
		# Fallback: generate colors with hue shifts
		var hue_step = 360.0 / (structures.size() + 1)
		for i in range(structures.size()):
			var new_hue = fmod(primary_color.h + (hue_step * (i + 1)) / 360.0, 1.0)
			palette[structures[i]] = Color.from_hsv(new_hue, primary_color.s * 0.9, primary_color.v * 0.95)
	
	return palette

func _generate_complementary_colors(base_color: Color, count: int) -> Array:
	"""Generate complementary color scheme"""
	var colors = []
	var complement_hue = fmod(base_color.h + 0.5, 1.0)
	
	colors.append(Color.from_hsv(complement_hue, base_color.s, base_color.v))
	
	# Add variations if more colors needed
	for i in range(1, count):
		var variation = 0.1 * i
		colors.append(Color.from_hsv(complement_hue, base_color.s - variation, base_color.v - variation * 0.5))
	
	return colors

func _generate_analogous_colors(base_color: Color, count: int) -> Array:
	"""Generate analogous color scheme"""
	var colors = []
	var hue_step = 30.0 / 360.0  # 30 degree steps
	
	for i in range(count):
		var new_hue = fmod(base_color.h + (hue_step * (i + 1)), 1.0)
		colors.append(Color.from_hsv(new_hue, base_color.s * 0.9, base_color.v * 0.95))
	
	return colors

func _generate_triadic_colors(base_color: Color, count: int) -> Array:
	"""Generate triadic color scheme"""
	var colors = []
	var hue_steps = [120.0 / 360.0, 240.0 / 360.0]  # 120 degree intervals
	
	for step in hue_steps:
		var new_hue = fmod(base_color.h + step, 1.0)
		colors.append(Color.from_hsv(new_hue, base_color.s, base_color.v))
		if colors.size() >= count:
			break
	
	# Add variations if more colors needed
	while colors.size() < count:
		var base_index = colors.size() % 2
		var variation = (colors.size() / 2) * 0.1
		var base_triadic = colors[base_index]
		colors.append(Color.from_hsv(base_triadic.h, base_triadic.s - variation, base_triadic.v - variation * 0.5))
	
	return colors

func _generate_split_complementary_colors(base_color: Color, count: int) -> Array:
	"""Generate split complementary color scheme"""
	var colors = []
	var complement_hue = fmod(base_color.h + 0.5, 1.0)
	var split_angle = 30.0 / 360.0
	
	# Add split complements
	colors.append(Color.from_hsv(fmod(complement_hue + split_angle, 1.0), base_color.s, base_color.v))
	colors.append(Color.from_hsv(fmod(complement_hue - split_angle, 1.0), base_color.s, base_color.v))
	
	# Add variations if more colors needed
	while colors.size() < count:
		var base_index = colors.size() % 2
		var variation = (colors.size() / 2) * 0.1
		var base_split = colors[base_index]
		colors.append(Color.from_hsv(base_split.h, base_split.s - variation, base_split.v - variation * 0.5))
	
	return colors

func _generate_monochromatic_colors(base_color: Color, count: int) -> Array:
	"""Generate monochromatic color scheme"""
	var colors = []
	var saturation_step = 0.15
	var value_step = 0.1
	
	for i in range(count):
		var new_saturation = max(base_color.s - (saturation_step * i), 0.2)
		var new_value = min(base_color.v + (value_step * (i % 2) * (1 if i % 4 < 2 else -1)), 1.0)
		colors.append(Color.from_hsv(base_color.h, new_saturation, new_value))
	
	return colors

# === UTILITY METHODS ===

func _merge_contexts(base_context: Dictionary, override_context: Dictionary) -> Dictionary:
	"""Merge learning contexts with override taking precedence"""
	var merged = base_context.duplicate()
	for key in override_context:
		merged[key] = override_context[key]
	return merged

func _generate_cache_key(structure_name: String, context: Dictionary) -> String:
	"""Generate cache key for color/palette lookup"""
	var key_parts = [
		structure_name,
		context.get("learning_level", ""),
		context.get("clinical_context", ""),
		accessibility_mode,
		str(user_preferences.hash())
	]
	return "_".join(key_parts)

func _get_related_structures(primary_structure: String, context: Dictionary) -> Array:
	"""Get related brain structures based on context"""
	var related = context.get("related_structures", [])
	
	if related.is_empty():
		# Find related structures by category
		for category in BRAIN_REGION_CATEGORIES:
			if primary_structure in BRAIN_REGION_CATEGORIES[category]:
				related = BRAIN_REGION_CATEGORIES[category].duplicate()
				related.erase(primary_structure)
				break
	
	return related

func _determine_harmony_type(context: Dictionary) -> String:
	"""Determine appropriate color harmony type for context"""
	var clinical_context = context.get("clinical_context", "anatomical")
	var learning_level = context.get("learning_level", "intermediate")
	
	match clinical_context:
		"pathological":
			return "split_complementary"  # More dramatic for pathology
		"functional":
			return "analogous"  # Related functions use related colors
		"developmental":
			return "monochromatic"  # Subtle variations for development
		_:
			match learning_level:
				"beginner":
					return "complementary"  # High contrast for beginners
				"advanced", "expert":
					return "analogous"  # Subtle harmony for experts
				_:
					return "triadic"  # Balanced approach

func _apply_palette_context(palette: Dictionary, context: Dictionary) -> Dictionary:
	"""Apply contextual adjustments to entire palette"""
	var contextual_palette = {}
	
	for structure in palette:
		var color = palette[structure]
		contextual_palette[structure] = _apply_contextual_modifications(color, structure, context)
	
	return contextual_palette

func _apply_user_preferences(color: Color) -> Color:
	"""Apply user preferences to color"""
	var preferred_color = color
	
	# Apply saturation preference
	var sat_preference = user_preferences.get("preferred_saturation", 0.8)
	preferred_color.s = preferred_color.s * sat_preference
	
	# Apply brightness preference
	var brightness_preference = user_preferences.get("preferred_brightness", 0.9)
	preferred_color.v = preferred_color.v * brightness_preference
	
	return preferred_color

# === PUBLIC API ===

func set_learning_context(context: Dictionary) -> void:
	"""Set current learning context"""
	current_learning_context = context
	learning_context_updated.emit(context)
	# Clear caches when context changes
	_clear_expired_cache()

func set_accessibility_mode(mode: String) -> void:
	"""Set accessibility mode"""
	if mode in ACCESSIBILITY_MODES:
		accessibility_mode = mode
		_clear_expired_cache()

func clear_all_caches() -> void:
	"""Clear all color and palette caches"""
	color_cache.clear()
	palette_cache.clear()
	last_cache_clear = Time.get_unix_time_from_system()

func _clear_expired_cache() -> void:
	"""Clear cache if it's older than 5 minutes"""
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_cache_clear > 300:  # 5 minutes
		clear_all_caches()

func get_diagnostic_info() -> Dictionary:
	"""Get diagnostic information about color generation"""
	return {
		"cached_colors": color_cache.size(),
		"cached_palettes": palette_cache.size(),
		"current_context": current_learning_context,
		"accessibility_mode": accessibility_mode,
		"user_preferences": user_preferences,
		"last_cache_clear": last_cache_clear
	}