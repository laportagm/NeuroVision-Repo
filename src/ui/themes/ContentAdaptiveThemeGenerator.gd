class_name ContentAdaptiveThemeGenerator
extends Resource

## Content-Adaptive Theme Generator for NeuroVision
## Dynamically generates themes based on educational content and brain regions

# Preload the ColorSystem and DesignTokens for direct access
const ColorSystem = preload("res://src/ui/themes/EducationalColorSystem.gd")
const DesignTokensRef = preload("res://src/ui/themes/DesignTokens.gd")
const M3Tokens = preload("res://src/ui/themes/M3DesignTokens.gd")
const Material3Generator = preload("res://src/ui/themes/Material3ThemeGenerator.gd")

# === LEARNING CONTEXT STRUCTURE ===

class LearningContext:
	var current_topic: String = ""
	var difficulty_level: int = 1  # 0=beginner, 1=intermediate, 2=advanced
	var user_performance: float = 0.0  # 0.0 to 1.0
	var time_spent: float = 0.0  # seconds
	var interaction_count: int = 0
	var preferred_contrast: String = "standard"  # standard, high, low
	var color_vision_mode: String = "normal"  # normal, protanopia, deuteranopia, tritanopia

# === BRAIN REGION THEME GENERATION ===

## Generate theme customized for specific brain region
static func generate_brain_region_theme(region_name: String, complexity_level: int, use_material3: bool = false) -> Theme:
	"""Generate theme optimized for studying specific brain regions"""
	
	var base_theme: Theme
	
	if use_material3:
		# Use Material 3 theme generator for modern visual polish
		var m3_generator = Material3Generator.new()
		base_theme = m3_generator.generate_material3_theme("default")
		
		# Apply Material 3 adaptive color based on brain region
		var adaptive_color = m3_generator.generate_adaptive_color(region_name)
		_apply_m3_region_colors(base_theme, region_name, adaptive_color)
	else:
		# Import EducationalThemeGenerator for base theme generation
		var EducationalThemeGen = preload("res://src/ui/themes/EducationalThemeGenerator.gd")
		base_theme = EducationalThemeGen.generate_educational_theme(
			EducationalThemeGen.ThemeVariant.DARK, complexity_level
		)
	
	# Apply region-specific modifications
	_apply_region_specific_colors(base_theme, region_name)
	_apply_region_specific_emphasis(base_theme, region_name, complexity_level)
	_add_region_metadata(base_theme, region_name, complexity_level)
	
	return base_theme

static func _apply_region_specific_colors(theme: Theme, region_name: String) -> void:
	"""Apply color scheme based on brain region characteristics"""
	
	# Define region-specific color palettes
	var region_palettes = {
		"cortex": {
			"primary": Color("#42A5F5"),  # Blue for higher cognitive functions
			"secondary": Color("#66BB6A"),  # Green for processing
			"accent": Color("#AB47BC")     # Purple for complexity
		},
		"hippocampus": {
			"primary": Color("#FF9800"),  # Orange for memory
			"secondary": Color("#FFB74D"),  # Light orange for learning
			"accent": Color("#FFA726")     # Medium orange for recall
		},
		"amygdala": {
			"primary": Color("#EF5350"),  # Red for emotion
			"secondary": Color("#EC407A"),  # Pink for arousal
			"accent": Color("#AB47BC")     # Purple for fear/anxiety
		},
		"brainstem": {
			"primary": Color("#26A69A"),  # Teal for vital functions
			"secondary": Color("#66BB6A"),  # Green for autonomic
			"accent": Color("#42A5F5")     # Blue for regulation
		},
		"cerebellum": {
			"primary": Color("#5C6BC0"),  # Indigo for coordination
			"secondary": Color("#7E57C2"),  # Deep purple for balance
			"accent": Color("#9575CD")     # Light purple for motor
		},
		"thalamus": {
			"primary": Color("#AB47BC"),  # Purple for relay
			"secondary": Color("#7E57C2"),  # Deep purple for integration
			"accent": Color("#5C6BC0")     # Indigo for sensory
		}
	}
	
	# Get palette for region or use default
	var palette = region_palettes.get(region_name.to_lower(), {
		"primary": Color("#42A5F5"),
		"secondary": Color("#66BB6A"),
		"accent": Color("#AB47BC")
	})
	
	# Apply colors to interactive elements
	var button_normal = theme.get_stylebox("normal", "Button") as StyleBoxFlat
	if button_normal:
		button_normal.bg_color = palette.primary
		theme.set_stylebox("normal", "Button", button_normal)
	
	# Apply to focus states
	theme.set_color("font_focus_color", "Button", palette.accent)
	theme.set_color("font_hover_color", "Button", palette.secondary)
	
	# Apply to selection highlights
	theme.set_color("selection_color", "LineEdit", palette.primary)
	theme.set_color("cursor_color", "LineEdit", palette.accent)

static func _apply_region_specific_emphasis(theme: Theme, region_name: String, complexity_level: int) -> void:
	"""Apply visual emphasis based on region importance and complexity"""
	
	# Define emphasis levels for different regions
	var emphasis_config = {
		"cortex": {"border_width": 2, "shadow_size": 12, "corner_radius": 8},
		"hippocampus": {"border_width": 3, "shadow_size": 16, "corner_radius": 12},
		"amygdala": {"border_width": 4, "shadow_size": 20, "corner_radius": 10},
		"brainstem": {"border_width": 2, "shadow_size": 8, "corner_radius": 6},
		"cerebellum": {"border_width": 2, "shadow_size": 10, "corner_radius": 8},
		"thalamus": {"border_width": 3, "shadow_size": 14, "corner_radius": 10}
	}
	
	var config = emphasis_config.get(region_name.to_lower(), {
		"border_width": 2, "shadow_size": 10, "corner_radius": 8
	})
	
	# Adjust for complexity level
	config.border_width = max(1, config.border_width - complexity_level)
	config.shadow_size = config.shadow_size + complexity_level * 4
	
	# Apply to panel styles
	var panel_types = ["PanelContainer", "StructureInfoPanel"]
	for panel_type in panel_types:
		var panel = theme.get_stylebox("panel", panel_type) as StyleBoxFlat
		if panel:
			panel.border_width_left = config.border_width
			panel.border_width_top = config.border_width
			panel.border_width_right = config.border_width
			panel.border_width_bottom = config.border_width
			panel.shadow_size = config.shadow_size
			panel.corner_radius_top_left = config.corner_radius
			panel.corner_radius_top_right = config.corner_radius
			panel.corner_radius_bottom_left = config.corner_radius
			panel.corner_radius_bottom_right = config.corner_radius
			theme.set_stylebox("panel", panel_type, panel)

static func _add_region_metadata(theme: Theme, region_name: String, complexity_level: int) -> void:
	"""Add metadata about region-specific theme adaptations"""
	theme.set_meta("brain_region", region_name)
	theme.set_meta("region_complexity", complexity_level)
	theme.set_meta("region_theme_version", "1.0")

static func _apply_m3_region_colors(theme: Theme, _region_name: String, adaptive_color: Color) -> void:
	"""Apply Material 3 adaptive colors based on brain region"""
	
	# Generate tonal palette from adaptive color
	var tonal_palette = M3Tokens.generate_tonal_palette(adaptive_color)
	
	# Apply to primary interactive elements
	var primary_button = theme.get_stylebox("normal", "Button") as StyleBoxFlat
	if primary_button:
		primary_button.bg_color = tonal_palette["40"]  # Primary container
		theme.set_stylebox("normal", "Button", primary_button)
	
	# Apply to surfaces
	var panel = theme.get_stylebox("panel", "Panel") as StyleBoxFlat
	if panel:
		panel.bg_color = tonal_palette["10"]  # Surface container
		panel.border_color = tonal_palette["50"]  # Outline variant
		theme.set_stylebox("panel", "Panel", panel)
	
	# Update text colors for contrast
	theme.set_color("font_color", "Label", tonal_palette["90"])  # On surface
	theme.set_color("font_color", "Button", tonal_palette["10"])  # On primary
	
	# Apply to selection and highlights
	theme.set_color("selection_color", "RichTextLabel", tonal_palette["80"])
	theme.set_color("caret_color", "LineEdit", tonal_palette["60"])
	
	# Store M3 metadata
	theme.set_meta("material3_enabled", true)
	theme.set_meta("m3_adaptive_color", adaptive_color)
	theme.set_meta("m3_tonal_palette", tonal_palette)

# === STRUCTURE-SPECIFIC PALETTE GENERATION ===

## Create color palette specific to anatomical structure data
static func create_structure_specific_palette(structure_data: Dictionary) -> Dictionary:
	"""Generate color palette based on structure characteristics"""
	
	var palette = {
		"primary": Color.WHITE,
		"secondary": Color.GRAY,
		"accent": Color.CYAN,
		"background": Color.BLACK,
		"text": Color.WHITE,
		"highlights": []
	}
	
	# Analyze structure data
	var structure_type = structure_data.get("type", "unknown")
	var function_count = structure_data.get("functions", []).size()
	var clinical_relevance = structure_data.get("clinical_relevance", "").length()
	var pathology_count = structure_data.get("pathologies", []).size()
	
	# Generate primary color based on structure type
	match structure_type:
		"gray_matter":
			palette.primary = Color("#757575")  # Gray for gray matter
		"white_matter":
			palette.primary = Color("#E0E0E0")  # Light gray for white matter
		"nucleus":
			palette.primary = Color("#5C6BC0")  # Indigo for nuclei
		"pathway":
			palette.primary = Color("#42A5F5")  # Blue for pathways
		"vessel":
			palette.primary = Color("#E53935")  # Red for blood vessels
		_:
			palette.primary = Color("#00ACC1")  # Cyan default
	
	# Adjust secondary based on function count
	var function_intensity = clamp(function_count / 10.0, 0.0, 1.0)
	palette.secondary = palette.primary.lightened(0.2 + function_intensity * 0.3)
	
	# Set accent based on clinical relevance
	if clinical_relevance > 100:
		palette.accent = Color("#FF5722")  # Deep orange for high clinical relevance
	elif clinical_relevance > 50:
		palette.accent = Color("#FF9800")  # Orange for moderate relevance
	else:
		palette.accent = Color("#FFC107")  # Amber for low relevance
	
	# Add pathology highlights
	for i in range(min(pathology_count, 3)):
		palette.highlights.append(Color("#F44336").lightened(i * 0.2))
	
	# Set appropriate text color for contrast
	var bg_luminance = palette.primary.get_luminance()
	palette.text = Color.WHITE if bg_luminance < 0.5 else Color.BLACK
	palette.background = palette.primary.darkened(0.8)
	
	return palette

# === ADAPTIVE THEME GENERATION ===

## Adapt theme to current learning context
static func adapt_theme_to_learning_context(context: LearningContext, base_theme: Theme) -> Theme:
	"""Dynamically adjust theme based on user's learning progress and preferences"""
	
	var adapted_theme = base_theme.duplicate(true)
	
	# Adjust contrast based on preference
	_apply_contrast_preference(adapted_theme, context.preferred_contrast)
	
	# Adapt colors for color vision deficiency
	_apply_color_vision_mode(adapted_theme, context.color_vision_mode)
	
	# Adjust visual complexity based on performance
	_adapt_to_user_performance(adapted_theme, context.user_performance, context.difficulty_level)
	
	# Add learning context metadata
	adapted_theme.set_meta("learning_context", {
		"topic": context.current_topic,
		"difficulty": context.difficulty_level,
		"performance": context.user_performance,
		"adaptation_time": Time.get_ticks_msec()
	})
	
	return adapted_theme

static func _apply_contrast_preference(theme: Theme, contrast_preference: String) -> void:
	"""Apply user's contrast preference to theme"""
	
	match contrast_preference:
		"high":
			# Increase contrast for all text
			theme.set_color("font_color", "Label", Color.WHITE)
			theme.set_color("font_color", "Button", Color.BLACK)
			
			# Darken backgrounds
			var panel = theme.get_stylebox("panel", "PanelContainer") as StyleBoxFlat
			if panel:
				panel.bg_color = panel.bg_color.darkened(0.3)
				
		"low":
			# Reduce contrast for comfort
			theme.set_color("font_color", "Label", Color("#E0E0E0"))
			
			# Lighten backgrounds
			var panel = theme.get_stylebox("panel", "PanelContainer") as StyleBoxFlat
			if panel:
				panel.bg_color = panel.bg_color.lightened(0.2)

static func _apply_color_vision_mode(theme: Theme, mode: String) -> void:
	"""Adapt colors for color vision deficiencies"""
	
	# Color transformation matrices for different types of color blindness
	match mode:
		"protanopia":  # Red-blind
			_transform_theme_colors(theme, "protanopia")
		"deuteranopia":  # Green-blind
			_transform_theme_colors(theme, "deuteranopia")
		"tritanopia":  # Blue-blind
			_transform_theme_colors(theme, "tritanopia")

static func _transform_theme_colors(theme: Theme, vision_type: String) -> void:
	"""Transform theme colors for specific color vision deficiency"""
	
	# This is a simplified implementation
	# In production, use proper color transformation algorithms
	
	match vision_type:
		"protanopia":
			# Replace reds with blues
			theme.set_color("font_color_error", "Label", Color("#2196F3"))
			theme.set_color("error", "Button", Color("#2196F3"))
			
		"deuteranopia":
			# Replace greens with yellows
			theme.set_color("font_color_success", "Label", Color("#FFC107"))
			theme.set_color("success", "Button", Color("#FFC107"))
			
		"tritanopia":
			# Replace blues with greens
			theme.set_color("font_color_info", "Label", Color("#4CAF50"))
			theme.set_color("info", "Button", Color("#4CAF50"))

static func _adapt_to_user_performance(theme: Theme, performance: float, difficulty: int) -> void:
	"""Adjust theme based on user's learning performance"""
	
	# If user is struggling, simplify visual complexity
	if performance < 0.5:
		# Increase spacing for better readability
		var panel = theme.get_stylebox("panel", "PanelContainer") as StyleBoxFlat
		if panel:
			panel.content_margin_left = int(panel.content_margin_left * 1.2)
			panel.content_margin_right = int(panel.content_margin_right * 1.2)
			panel.content_margin_top = int(panel.content_margin_top * 1.2)
			panel.content_margin_bottom = int(panel.content_margin_bottom * 1.2)
		
		# Reduce visual noise
		theme.set_color("font_shadow_color", "Label", Color.TRANSPARENT)
	
	# If user is excelling, add more visual interest
	elif performance > 0.8 and difficulty >= 1:
		# Add subtle animations metadata
		theme.set_meta("enable_micro_animations", true)
		theme.set_meta("animation_speed_multiplier", 1.2)

# === MODEL-AWARE COLOR GENERATION ===

## Generate colors based on 3D model characteristics
static func generate_model_aware_colors(model_path: String) -> Array[Color]:
	"""Generate color palette based on 3D model properties"""
	
	var colors: Array[Color] = []
	
	# Extract model type from path
	var model_name = model_path.get_file().get_basename().to_lower()
	
	# Define model-specific color schemes
	if model_name.contains("cortex"):
		colors = [
			Color("#E3F2FD"),  # Very light blue
			Color("#90CAF9"),  # Light blue
			Color("#42A5F5"),  # Blue
			Color("#1E88E5"),  # Dark blue
			Color("#1565C0")   # Very dark blue
		]
	elif model_name.contains("hippocampus"):
		colors = [
			Color("#FFF3E0"),  # Very light orange
			Color("#FFCC80"),  # Light orange
			Color("#FF9800"),  # Orange
			Color("#F57C00"),  # Dark orange
			Color("#E65100")   # Very dark orange
		]
	elif model_name.contains("brainstem"):
		colors = [
			Color("#E0F2F1"),  # Very light teal
			Color("#80CBC4"),  # Light teal
			Color("#26A69A"),  # Teal
			Color("#00897B"),  # Dark teal
			Color("#00695C")   # Very dark teal
		]
	elif model_name.contains("cerebellum"):
		colors = [
			Color("#EDE7F6"),  # Very light purple
			Color("#B39DDB"),  # Light purple
			Color("#7E57C2"),  # Purple
			Color("#5E35B1"),  # Dark purple
			Color("#4527A0")   # Very dark purple
		]
	else:
		# Default neutral palette
		colors = [
			Color("#FAFAFA"),  # Very light gray
			Color("#E0E0E0"),  # Light gray
			Color("#9E9E9E"),  # Gray
			Color("#616161"),  # Dark gray
			Color("#424242")   # Very dark gray
		]
	
	return colors

# === EDUCATIONAL HIERARCHY STYLES ===

## Create styles based on educational content hierarchy
static func create_educational_hierarchy_styles(learning_level: int) -> Dictionary:
	"""Generate visual hierarchy styles for different learning levels"""
	
	var styles = {
		"primary_heading": {},
		"secondary_heading": {},
		"body_text": {},
		"detail_text": {},
		"emphasis_text": {},
		"interactive_element": {},
		"feedback_element": {}
	}
	
	# Base sizes adjusted for learning level
	var base_size = 14 + learning_level * 2
	
	# Primary heading style
	styles.primary_heading = {
		"font_size": base_size + 10,
		"font_weight": "bold",
		"color": ColorSystem.get_educational_color("dark", "critical_concept"),
		"margin_bottom": 16,
		"text_shadow": learning_level > 0
	}
	
	# Secondary heading style
	styles.secondary_heading = {
		"font_size": base_size + 6,
		"font_weight": "semibold",
		"color": ColorSystem.get_educational_color("dark", "function_category"),
		"margin_bottom": 12,
		"text_shadow": false
	}
	
	# Body text style
	styles.body_text = {
		"font_size": base_size,
		"font_weight": "normal",
		"color": ColorSystem.get_educational_color("dark", "text_primary"),
		"line_height": 1.6,
		"margin_bottom": 8
	}
	
	# Detail text style
	styles.detail_text = {
		"font_size": base_size - 2,
		"font_weight": "normal",
		"color": ColorSystem.get_educational_color("dark", "text_secondary"),
		"line_height": 1.4,
		"margin_bottom": 4
	}
	
	# Emphasis text style
	styles.emphasis_text = {
		"font_size": base_size,
		"font_weight": "semibold",
		"color": ColorSystem.get_educational_color("dark", "learning_objective"),
		"background_highlight": learning_level > 1,
		"underline": learning_level == 0
	}
	
	# Interactive element style
	styles.interactive_element = {
		"min_height": 40 + learning_level * 4,
		"padding": 12 + learning_level * 2,
		"border_radius": 6 + learning_level * 2,
		"hover_scale": 1.02 + learning_level * 0.01,
		"click_feedback": true
	}
	
	# Feedback element style
	styles.feedback_element = {
		"animation_duration": 0.3 - learning_level * 0.05,
		"particle_effects": learning_level > 0,
		"sound_feedback": true,
		"haptic_feedback": learning_level > 1
	}
	
	return styles

# === UTILITY FUNCTIONS ===

## Get recommended theme settings for specific content
static func get_content_theme_recommendations(content_type: String, user_level: int) -> Dictionary:
	"""Provide theme recommendations based on content type and user level"""
	
	var recommendations = {
		"theme_variant": "",
		"glass_intensity": 0.5,
		"animation_speed": 1.0,
		"contrast_level": "standard",
		"color_adjustments": {},
		"ui_scale": 1.0
	}
	
	match content_type:
		"anatomical_overview":
			recommendations.theme_variant = "light" if user_level == 0 else "dark"
			recommendations.glass_intensity = 0.3
			recommendations.ui_scale = 1.1 if user_level == 0 else 1.0
			
		"clinical_cases":
			recommendations.theme_variant = "dark"
			recommendations.glass_intensity = 0.1
			recommendations.contrast_level = "high"
			recommendations.color_adjustments = {"pathology_emphasis": 1.5}
			
		"interactive_quiz":
			recommendations.theme_variant = "dark"
			recommendations.glass_intensity = 0.6
			recommendations.animation_speed = 1.2
			recommendations.color_adjustments = {"feedback_intensity": 2.0}
			
		"detailed_study":
			recommendations.theme_variant = "light"
			recommendations.glass_intensity = 0.0
			recommendations.contrast_level = "standard"
			recommendations.ui_scale = 0.95
	
	return recommendations

## Generate preview data for theme customization UI
static func generate_theme_preview_data(base_theme: Theme) -> Dictionary:
	"""Generate preview data for theme customization interface"""
	
	return {
		"preview_panels": [
			{"type": "structure_info", "title": "Hippocampus", "content": "Memory center"},
			{"type": "function", "title": "Functions", "content": "Memory formation"},
			{"type": "clinical", "title": "Clinical", "content": "Alzheimer's disease"},
			{"type": "quiz", "title": "Quiz", "content": "Test your knowledge"}
		],
		"preview_buttons": [
			{"label": "Select", "style": "primary"},
			{"label": "Learn More", "style": "secondary"},
			{"label": "Quiz Me", "style": "accent"}
		],
		"color_swatches": _extract_theme_colors(base_theme),
		"typography_samples": _extract_typography_samples(base_theme)
	}

static func _extract_theme_colors(theme: Theme) -> Array:
	"""Extract main colors from theme for preview"""
	var colors = []
	
	# Try to extract common colors
	var color_properties = ["font_color", "font_hover_color", "font_pressed_color"]
	var node_types = ["Button", "Label", "LineEdit"]
	
	for node_type in node_types:
		for prop in color_properties:
			if theme.has_color(prop, node_type):
				var color = theme.get_color(prop, node_type)
				if not _color_in_array(color, colors):
					colors.append({"color": color, "name": prop, "node": node_type})
	
	return colors

static func _extract_typography_samples(_theme: Theme) -> Array:
	"""Extract typography samples from theme"""
	return [
		{"text": "Large Heading", "size": 24, "weight": "bold"},
		{"text": "Section Title", "size": 18, "weight": "semibold"},
		{"text": "Body Text", "size": 14, "weight": "normal"},
		{"text": "Caption", "size": 12, "weight": "normal"}
	]

static func _color_in_array(color: Color, array: Array) -> bool:
	"""Check if color already exists in array"""
	for item in array:
		if item.color.is_equal_approx(color):
			return true
	return false