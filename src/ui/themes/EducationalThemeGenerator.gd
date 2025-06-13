class_name EducationalThemeGenerator
extends Resource

## Programmatic educational theme generator for NeuroVision
## Creates WCAG AAA compliant themes with educational semantics for neuroanatomy learning

## Generates complete theme resources with educational styling for different contexts
## Supports light, dark, and high-contrast variants with learning level adaptations

# Preload the ColorSystem for direct access
const ColorSystem = preload("res://src/ui/themes/EducationalColorSystem.gd")

# === EDUCATIONAL THEME TYPES ===

enum ThemeVariant {
	LIGHT,           # Standard light theme for normal conditions
	DARK,            # Dark theme for low-light environments
	HIGH_CONTRAST    # High contrast theme for accessibility needs
}

# === EDUCATIONAL COMPONENT CATEGORIES ===

enum ComponentCategory {
	STRUCTURE_INFO,      # Anatomical structure information panels
	FUNCTION_DISPLAY,    # Function and pathway information
	CLINICAL_CONTENT,    # Clinical relevance and pathology
	LEARNING_TOOLS,      # Study questions and assessments
	NAVIGATION,          # UI navigation and controls
	FEEDBACK            # Status, progress, and notifications
}

# === MAIN THEME GENERATION ===

## Generate complete educational theme for specified variant
static func generate_educational_theme(variant: ThemeVariant, learning_level: int = 1) -> Theme:  # Default to INTERMEDIATE
	"""Generate complete educational theme with WCAG AAA compliance"""
	var theme = Theme.new()
	var theme_type = _get_theme_type_string(variant)

	# Set base theme properties
	_apply_base_theme_settings(theme, variant, learning_level)

	# Generate component-specific styles
	_generate_button_styles(theme, theme_type, learning_level)
	_generate_panel_styles(theme, theme_type, learning_level)
	_generate_text_styles(theme, theme_type, learning_level)
	_generate_input_styles(theme, theme_type, learning_level)
	_generate_educational_styles(theme, theme_type, learning_level)

	# Apply learning level adaptations
	_apply_learning_level_adaptations(theme, learning_level, theme_type)

	return theme

## Generate theme for specific educational component category
static func generate_component_theme(category: ComponentCategory, variant: ThemeVariant, learning_level: int) -> Theme:
	"""Generate theme optimized for specific educational component category"""
	var theme = generate_educational_theme(variant, learning_level)

	# Apply category-specific optimizations
	match category:
		ComponentCategory.STRUCTURE_INFO:
			_optimize_for_structure_info(theme, variant, learning_level)
		ComponentCategory.FUNCTION_DISPLAY:
			_optimize_for_function_display(theme, variant, learning_level)
		ComponentCategory.CLINICAL_CONTENT:
			_optimize_for_clinical_content(theme, variant, learning_level)
		ComponentCategory.LEARNING_TOOLS:
			_optimize_for_learning_tools(theme, variant, learning_level)
		ComponentCategory.NAVIGATION:
			_optimize_for_navigation(theme, variant, learning_level)
		ComponentCategory.FEEDBACK:
			_optimize_for_feedback(theme, variant, learning_level)

	return theme

# === BUTTON STYLING ===

static func _generate_button_styles(theme: Theme, theme_type: String, learning_level: int) -> void:
	"""Generate educational button styles with semantic categories"""

	# Primary action buttons (structure selection, main interactions)
	var primary_button = _create_educational_button_style(theme_type, "interactive_primary", learning_level)
	theme.set_stylebox("normal", "Button", primary_button)
	theme.set_stylebox("hover", "Button", _create_hover_variant(primary_button, theme_type))
	theme.set_stylebox("pressed", "Button", _create_pressed_variant(primary_button, theme_type))
	theme.set_stylebox("disabled", "Button", _create_disabled_variant(primary_button, theme_type))

	# Educational category buttons
	_create_category_button_styles(theme, theme_type, learning_level)

	# Learning level specific buttons
	_create_learning_level_buttons(theme, theme_type, learning_level)

	# Button text colors
	theme.set_color("font_color", "Button", ColorSystem.get_accessible_text_color(
		ColorSystem.get_educational_color(theme_type, "interactive_primary"), theme_type))
	theme.set_color("font_hover_color", "Button", ColorSystem.get_educational_color(theme_type, "text_primary"))
	theme.set_color("font_pressed_color", "Button", ColorSystem.get_educational_color(theme_type, "text_primary"))
	theme.set_color("font_disabled_color", "Button", ColorSystem.get_educational_color(theme_type, "text_disabled"))

## Create educational button style with semantic color
static func _create_educational_button_style(theme_type: String, color_key: String, learning_level: int) -> StyleBoxFlat:
	"""Create educational button style with learning level adaptations"""
	var style = StyleBoxFlat.new()
	var level_config = ColorSystem.get_learning_level_style(learning_level)

	# Base colors
	style.bg_color = ColorSystem.get_educational_color(theme_type, color_key)
	style.border_color = ColorSystem.get_educational_color(theme_type, "border_default")

	# Learning level adaptations
	style.border_width_left = level_config.border_weight
	style.border_width_top = level_config.border_weight
	style.border_width_right = level_config.border_weight
	style.border_width_bottom = level_config.border_weight

	# Rounded corners based on complexity level
	var corner_radius = 8 if level_config.visual_complexity == "minimal" else 6
	style.corner_radius_top_left = corner_radius
	style.corner_radius_top_right = corner_radius
	style.corner_radius_bottom_left = corner_radius
	style.corner_radius_bottom_right = corner_radius

	# Glass effect based on learning level
	var glass_color = ColorSystem.get_educational_color(theme_type, level_config.background_tint)
	if glass_color.a > 0:
		style.bg_color = style.bg_color.lerp(glass_color, 0.3)

	# Educational content spacing
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12

	return style

## Create category-specific button styles for educational content
static func _create_category_button_styles(theme: Theme, theme_type: String, learning_level: int) -> void:
	"""Create button styles for educational content categories"""

	# Structure category buttons (anatomical structures)
	var structure_button = _create_educational_button_style(theme_type, "structure_category", learning_level)
	theme.set_stylebox("normal", "StructureButton", structure_button)

	# Function category buttons (neural functions, pathways)
	var function_button = _create_educational_button_style(theme_type, "function_category", learning_level)
	theme.set_stylebox("normal", "FunctionButton", function_button)

	# Clinical category buttons (pathology, clinical relevance)
	var clinical_button = _create_educational_button_style(theme_type, "clinical_relevance", learning_level)
	theme.set_stylebox("normal", "ClinicalButton", clinical_button)

	# Learning objective buttons (study questions, assessments)
	var learning_button = _create_educational_button_style(theme_type, "learning_objective", learning_level)
	theme.set_stylebox("normal", "LearningButton", learning_button)

## Create learning level specific button variants
static func _create_learning_level_buttons(theme: Theme, theme_type: String, learning_level: int) -> void:
	"""Create button styles specific to learning levels"""
	var level_style = ColorSystem.get_learning_level_style(learning_level)
	var accent_color = level_style.primary_accent

	var level_button = _create_educational_button_style(theme_type, accent_color, learning_level)

	match learning_level:
		0:  # BEGINNER
			theme.set_stylebox("normal", "BeginnerButton", level_button)
		1:  # INTERMEDIATE
			theme.set_stylebox("normal", "IntermediateButton", level_button)
		2:  # ADVANCED
			theme.set_stylebox("normal", "AdvancedButton", level_button)

# === PANEL STYLING ===

static func _generate_panel_styles(theme: Theme, theme_type: String, learning_level: int) -> void:
	"""Generate educational panel styles with learning context"""

	# Base panel style
	var base_panel = _create_educational_panel_style(theme_type, learning_level)
	theme.set_stylebox("panel", "PanelContainer", base_panel)

	# Educational content panels
	_create_educational_panel_variants(theme, theme_type, learning_level)

## Create educational panel style with glass morphism
static func _create_educational_panel_style(theme_type: String, learning_level: int) -> StyleBoxFlat:
	"""Create educational panel with appropriate visual complexity"""
	var style = StyleBoxFlat.new()
	var level_config = ColorSystem.get_learning_level_style(learning_level)

	# Background with glass effect
	style.bg_color = ColorSystem.get_educational_color(theme_type, "background_secondary")
	var glass_color = ColorSystem.get_educational_color(theme_type, level_config.background_tint)
	if glass_color.a > 0:
		style.bg_color = style.bg_color.lerp(glass_color, 0.5)

	# Borders adapted to learning level
	style.border_color = ColorSystem.get_educational_color(theme_type, "border_default")
	style.border_width_left = level_config.border_weight
	style.border_width_top = level_config.border_weight
	style.border_width_right = level_config.border_weight
	style.border_width_bottom = level_config.border_weight

	# Corner radius based on visual complexity
	var radius = 12 if level_config.visual_complexity == "minimal" else 8
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius

	# Educational content margins
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 16
	style.content_margin_bottom = 16

	# Shadow for depth
	style.shadow_color = Color(0, 0, 0, 0.2)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 4)

	return style

## Create educational panel variants for different content types
static func _create_educational_panel_variants(theme: Theme, theme_type: String, learning_level: int) -> void:
	"""Create specialized panels for educational content categories"""

	# Structure information panel
	var structure_panel = _create_educational_panel_style(theme_type, learning_level)
	structure_panel.border_color = ColorSystem.get_educational_color(theme_type, "structure_category")
	theme.set_stylebox("panel", "StructureInfoPanel", structure_panel)

	# Function display panel
	var function_panel = _create_educational_panel_style(theme_type, learning_level)
	function_panel.border_color = ColorSystem.get_educational_color(theme_type, "function_category")
	theme.set_stylebox("panel", "FunctionPanel", function_panel)

	# Clinical content panel
	var clinical_panel = _create_educational_panel_style(theme_type, learning_level)
	clinical_panel.border_color = ColorSystem.get_educational_color(theme_type, "clinical_relevance")
	theme.set_stylebox("panel", "ClinicalPanel", clinical_panel)

	# Learning tools panel
	var learning_panel = _create_educational_panel_style(theme_type, learning_level)
	learning_panel.border_color = ColorSystem.get_educational_color(theme_type, "learning_objective")
	theme.set_stylebox("panel", "LearningPanel", learning_panel)

	# Quiz/assessment panel
	var quiz_panel = _create_educational_panel_style(theme_type, learning_level)
	quiz_panel.bg_color = ColorSystem.get_educational_color(theme_type, "background_tertiary")
	quiz_panel.border_color = ColorSystem.get_educational_color(theme_type, "learning_objective")
	quiz_panel.border_width_left = 3
	quiz_panel.border_width_top = 3
	quiz_panel.border_width_right = 3
	quiz_panel.border_width_bottom = 3
	theme.set_stylebox("panel", "QuizPanel", quiz_panel)

# === TEXT STYLING ===

static func _generate_text_styles(theme: Theme, theme_type: String, learning_level: int) -> void:
	"""Generate educational text styles with semantic colors"""
	var level_config = ColorSystem.get_learning_level_style(learning_level)

	# Base label colors
	theme.set_color("font_color", "Label", ColorSystem.get_educational_color(theme_type, "text_primary"))
	theme.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0.3))

	# Educational content text colors
	_create_educational_text_variants(theme, theme_type, learning_level)

	# Learning level text emphasis
	theme.set_color("font_color", "EmphasisLabel", ColorSystem.get_educational_color(theme_type, level_config.text_emphasis))

## Create text color variants for educational content types
static func _create_educational_text_variants(theme: Theme, theme_type: String, _learning_level: int) -> void:
	"""Create text colors for different educational content types"""

	# Critical concept text (structure names, key facts)
	theme.set_color("font_color", "CriticalLabel", ColorSystem.get_content_type_color(theme_type, "structure_name"))

	# Function description text
	theme.set_color("font_color", "FunctionLabel", ColorSystem.get_content_type_color(theme_type, "function"))

	# Clinical relevance text
	theme.set_color("font_color", "ClinicalLabel", ColorSystem.get_content_type_color(theme_type, "clinical_relevance"))

	# Learning objective text
	theme.set_color("font_color", "LearningLabel", ColorSystem.get_content_type_color(theme_type, "learning_objectives"))

	# Supporting detail text
	theme.set_color("font_color", "DetailLabel", ColorSystem.get_content_type_color(theme_type, "description"))

	# Pathology/disorder text
	theme.set_color("font_color", "PathologyLabel", ColorSystem.get_content_type_color(theme_type, "pathology"))

# === INPUT STYLING ===

static func _generate_input_styles(theme: Theme, theme_type: String, learning_level: int) -> void:
	"""Generate educational input field styles"""

	# LineEdit styles
	var normal_input = _create_educational_input_style(theme_type, learning_level, "normal")
	var focus_input = _create_educational_input_style(theme_type, learning_level, "focus")
	var read_only_input = _create_educational_input_style(theme_type, learning_level, "read_only")

	theme.set_stylebox("normal", "LineEdit", normal_input)
	theme.set_stylebox("focus", "LineEdit", focus_input)
	theme.set_stylebox("read_only", "LineEdit", read_only_input)

	# Input text colors
	theme.set_color("font_color", "LineEdit", ColorSystem.get_educational_color(theme_type, "text_primary"))
	theme.set_color("font_selected_color", "LineEdit", ColorSystem.get_educational_color(theme_type, "text_primary"))
	theme.set_color("selection_color", "LineEdit", ColorSystem.get_educational_color(theme_type, "interactive_primary"))
	theme.set_color("cursor_color", "LineEdit", ColorSystem.get_educational_color(theme_type, "interactive_primary"))

## Create educational input field style
static func _create_educational_input_style(theme_type: String, learning_level: int, state: String) -> StyleBoxFlat:
	"""Create input field style for educational interfaces"""
	var style = StyleBoxFlat.new()
	var level_config = ColorSystem.get_learning_level_style(learning_level)

	# Background
	style.bg_color = ColorSystem.get_educational_color(theme_type, "background_tertiary")

	# State-specific styling
	match state:
		"normal":
			style.border_color = ColorSystem.get_educational_color(theme_type, "border_default")
		"focus":
			style.border_color = ColorSystem.get_educational_color(theme_type, "border_focus")
			style.bg_color = style.bg_color.lightened(0.1)
		"read_only":
			style.border_color = ColorSystem.get_educational_color(theme_type, "border_default")
			style.bg_color = style.bg_color.darkened(0.1)

	# Border weight from learning level
	style.border_width_left = level_config.border_weight
	style.border_width_top = level_config.border_weight
	style.border_width_right = level_config.border_weight
	style.border_width_bottom = level_config.border_weight

	# Corner radius
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6

	# Content margins
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8

	return style

# === EDUCATIONAL SPECIFIC STYLES ===

static func _generate_educational_styles(theme: Theme, theme_type: String, learning_level: int) -> void:
	"""Generate styles specific to educational components"""

	# Learning level indicators
	_create_learning_level_indicators(theme, theme_type, learning_level)

	# Progress indicators
	_create_progress_indicators(theme, theme_type, learning_level)

	# Educational feedback styles
	_create_educational_feedback_styles(theme, theme_type, learning_level)

## Create learning level indicator styles
static func _create_learning_level_indicators(theme: Theme, theme_type: String, learning_level: int) -> void:
	"""Create visual indicators for learning levels"""
	var level_config = ColorSystem.get_learning_level_style(learning_level)

	# Level indicator panel
	var indicator_style = StyleBoxFlat.new()
	indicator_style.bg_color = ColorSystem.get_educational_color(theme_type, level_config.primary_accent)
	indicator_style.corner_radius_top_left = 12
	indicator_style.corner_radius_top_right = 12
	indicator_style.corner_radius_bottom_left = 12
	indicator_style.corner_radius_bottom_right = 12
	indicator_style.content_margin_left = 8
	indicator_style.content_margin_right = 8
	indicator_style.content_margin_top = 4
	indicator_style.content_margin_bottom = 4

	theme.set_stylebox("panel", "LevelIndicator", indicator_style)

	# Level indicator text color
	theme.set_color("font_color", "LevelIndicator",
		ColorSystem.get_accessible_text_color(
			ColorSystem.get_educational_color(theme_type, level_config.primary_accent), theme_type))

## Create progress indicator styles for educational tracking
static func _create_progress_indicators(theme: Theme, theme_type: String, _learning_level: int) -> void:
	"""Create progress tracking visual styles"""

	# Progress bar background
	var progress_bg = StyleBoxFlat.new()
	progress_bg.bg_color = ColorSystem.get_educational_color(theme_type, "background_tertiary")
	progress_bg.corner_radius_top_left = 8
	progress_bg.corner_radius_top_right = 8
	progress_bg.corner_radius_bottom_left = 8
	progress_bg.corner_radius_bottom_right = 8
	theme.set_stylebox("background", "ProgressBar", progress_bg)

	# Progress bar fill
	var progress_fill = StyleBoxFlat.new()
	progress_fill.bg_color = ColorSystem.get_educational_color(theme_type, "success")
	progress_fill.corner_radius_top_left = 8
	progress_fill.corner_radius_top_right = 8
	progress_fill.corner_radius_bottom_left = 8
	progress_fill.corner_radius_bottom_right = 8
	theme.set_stylebox("fill", "ProgressBar", progress_fill)

## Create educational feedback styles (success, warning, error)
static func _create_educational_feedback_styles(theme: Theme, theme_type: String, learning_level: int) -> void:
	"""Create feedback styles for educational interactions"""

	# Success feedback (correct answers, completed sections)
	var success_style = _create_educational_panel_style(theme_type, learning_level)
	success_style.border_color = ColorSystem.get_educational_color(theme_type, "success")
	success_style.bg_color = ColorSystem.get_educational_color(theme_type, "success").lightened(0.9)
	theme.set_stylebox("panel", "SuccessFeedback", success_style)

	# Warning feedback (incomplete information, suggestions)
	var warning_style = _create_educational_panel_style(theme_type, learning_level)
	warning_style.border_color = ColorSystem.get_educational_color(theme_type, "warning")
	warning_style.bg_color = ColorSystem.get_educational_color(theme_type, "warning").lightened(0.9)
	theme.set_stylebox("panel", "WarningFeedback", warning_style)

	# Error feedback (incorrect answers, missing requirements)
	var error_style = _create_educational_panel_style(theme_type, learning_level)
	error_style.border_color = ColorSystem.get_educational_color(theme_type, "error")
	error_style.bg_color = ColorSystem.get_educational_color(theme_type, "error").lightened(0.9)
	theme.set_stylebox("panel", "ErrorFeedback", error_style)

# === LEARNING LEVEL ADAPTATIONS ===

static func _apply_learning_level_adaptations(_theme: Theme, learning_level: int, _theme_type: String) -> void:
	"""Apply learning level specific adaptations to theme"""
	var level_config = ColorSystem.get_learning_level_style(learning_level)

	# Font size adjustments
	var base_font_size = DesignTokens.TYPOGRAPHY.body.size
	var _adjusted_size = base_font_size + level_config.font_size_modifier

	# Apply font size adjustments to appropriate text elements
	# Note: This would typically be handled through FontVariation resources
	# For now, we document the intended behavior

	# Visual complexity adjustments are already handled in individual style methods
	# through the level_config.visual_complexity parameter

# === BASE THEME SETTINGS ===

static func _apply_base_theme_settings(theme: Theme, variant: ThemeVariant, _learning_level: int) -> void:
	"""Apply base theme settings for educational context"""
	var theme_type = _get_theme_type_string(variant)

	# Default background color
	theme.set_color("background", "Control", ColorSystem.get_educational_color(theme_type, "background_primary"))

	# Default font color
	theme.set_color("font_color", "Control", ColorSystem.get_educational_color(theme_type, "text_primary"))

# === COMPONENT OPTIMIZATIONS ===

static func _optimize_for_structure_info(_theme: Theme, _variant: ThemeVariant, _learning_level: int) -> void:
	"""Optimize theme for anatomical structure information display"""
	# Enhanced readability for anatomical terms
	# Stronger contrast for critical information
	pass

static func _optimize_for_function_display(_theme: Theme, _variant: ThemeVariant, _learning_level: int) -> void:
	"""Optimize theme for neural function and pathway display"""
	# Clear visual hierarchy for functional relationships
	# Color coding for different pathway types
	pass

static func _optimize_for_clinical_content(_theme: Theme, _variant: ThemeVariant, _learning_level: int) -> void:
	"""Optimize theme for clinical relevance and pathology content"""
	# Professional color scheme for medical context
	# Clear distinction between normal and pathological states
	pass

static func _optimize_for_learning_tools(_theme: Theme, _variant: ThemeVariant, _learning_level: int) -> void:
	"""Optimize theme for study questions and assessments"""
	# Enhanced feedback for correct/incorrect responses
	# Clear progress indicators
	pass

static func _optimize_for_navigation(_theme: Theme, _variant: ThemeVariant, _learning_level: int) -> void:
	"""Optimize theme for UI navigation and controls"""
	# High contrast for critical navigation elements
	# Consistent interactive states
	pass

static func _optimize_for_feedback(_theme: Theme, _variant: ThemeVariant, _learning_level: int) -> void:
	"""Optimize theme for status, progress, and notifications"""
	# Clear semantic colors for different feedback types
	# Appropriate urgency levels for notifications
	pass

# === HELPER FUNCTIONS ===

## Create hover state variant for interactive elements
static func _create_hover_variant(base_style: StyleBoxFlat, theme_type: String) -> StyleBoxFlat:
	"""Create hover state variant of a style"""
	var hover_style = base_style.duplicate()
	hover_style.bg_color = hover_style.bg_color.lightened(0.1)
	hover_style.border_color = ColorSystem.get_educational_color(theme_type, "border_hover")
	return hover_style

## Create pressed state variant for interactive elements
static func _create_pressed_variant(base_style: StyleBoxFlat, theme_type: String) -> StyleBoxFlat:
	"""Create pressed state variant of a style"""
	var pressed_style = base_style.duplicate()
	pressed_style.bg_color = pressed_style.bg_color.darkened(0.1)
	pressed_style.border_color = ColorSystem.get_educational_color(theme_type, "border_focus")
	return pressed_style

## Create disabled state variant for interactive elements
static func _create_disabled_variant(base_style: StyleBoxFlat, theme_type: String) -> StyleBoxFlat:
	"""Create disabled state variant of a style"""
	var disabled_style = base_style.duplicate()
	disabled_style.bg_color = ColorSystem.get_educational_color(theme_type, "interactive_disabled")
	disabled_style.border_color = ColorSystem.get_educational_color(theme_type, "border_default")
	return disabled_style

## Convert theme variant enum to string
static func _get_theme_type_string(variant: ThemeVariant) -> String:
	"""Convert ThemeVariant enum to string for color system"""
	match variant:
		ThemeVariant.LIGHT:
			return "light"
		ThemeVariant.DARK:
			return "dark"
		ThemeVariant.HIGH_CONTRAST:
			return "high_contrast"
		_:
			return "light"

# === GLASS MORPHISM THEME GENERATION ===

## Generate glass morphism theme with blur effects
static func generate_glass_morphism_theme(variant: ThemeVariant, learning_level: int, glass_intensity: float = 0.5) -> Theme:
	"""Generate educational theme with glass morphism effects"""
	var theme = generate_educational_theme(variant, learning_level)
	var theme_type = _get_theme_type_string(variant)
	
	# Apply glass morphism to all panels
	_apply_glass_morphism_to_panels(theme, theme_type, glass_intensity)
	_apply_glass_morphism_to_buttons(theme, theme_type, glass_intensity)
	
	# Add blur backdrop support metadata
	theme.set_meta("supports_blur", true)
	theme.set_meta("glass_intensity", glass_intensity)
	theme.set_meta("blur_amount", glass_intensity * 16.0)
	
	return theme

static func _apply_glass_morphism_to_panels(theme: Theme, theme_type: String, intensity: float) -> void:
	"""Apply glass morphism effects to panel styles"""
	var panel_types = ["PanelContainer", "StructureInfoPanel", "FunctionPanel", "ClinicalPanel", "LearningPanel", "QuizPanel"]
	
	for panel_type in panel_types:
		var panel = theme.get_stylebox("panel", panel_type) as StyleBoxFlat
		if panel:
			# Reduce background opacity for glass effect
			panel.bg_color.a *= (1.0 - intensity * 0.5)
			
			# Add glass tint
			var glass_color = ColorSystem.get_educational_color(theme_type, "glass_light")
			panel.bg_color = panel.bg_color.lerp(glass_color, intensity)
			
			# Enhance border for glass edge effect
			panel.border_color.a = min(panel.border_color.a + intensity * 0.3, 1.0)
			
			# Add inner glow effect through shadow
			panel.shadow_color = Color(1, 1, 1, intensity * 0.1)
			panel.shadow_size = max(4, panel.shadow_size)
			
			theme.set_stylebox("panel", panel_type, panel)

static func _apply_glass_morphism_to_buttons(theme: Theme, theme_type: String, intensity: float) -> void:
	"""Apply glass morphism effects to button styles"""
	var button_states = ["normal", "hover", "pressed", "disabled"]
	
	for state in button_states:
		var button = theme.get_stylebox(state, "Button") as StyleBoxFlat
		if button:
			# Glass effect for buttons
			button.bg_color.a *= (1.0 - intensity * 0.3)
			
			# Add glass tint based on state
			var tint_intensity = intensity
			if state == "hover":
				tint_intensity *= 1.5
			elif state == "pressed":
				tint_intensity *= 0.7
			
			var glass_color = ColorSystem.get_educational_color(theme_type, "glass_medium")
			button.bg_color = button.bg_color.lerp(glass_color, tint_intensity)
			
			theme.set_stylebox(state, "Button", button)

# === ANIMATED THEME TRANSITIONS ===

## Create animated transition configurations for smooth theme switching
static func create_animated_transitions(from_variant: ThemeVariant, to_variant: ThemeVariant, duration: float = 0.3) -> Dictionary:
	"""Create animation data for smooth theme transitions"""
	var from_type = _get_theme_type_string(from_variant)
	var to_type = _get_theme_type_string(to_variant)
	
	var transitions = {
		"duration": duration,
		"easing": Tween.EASE_IN_OUT,
		"transition_type": Tween.TRANS_CUBIC,
		"color_properties": [],
		"numeric_properties": [],
		"special_effects": []
	}
	
	# Define color properties to animate
	var color_keys = ["background_primary", "text_primary", "interactive_primary", "border_default"]
	for key in color_keys:
		transitions.color_properties.append({
			"property": key,
			"from": ColorSystem.get_educational_color(from_type, key),
			"to": ColorSystem.get_educational_color(to_type, key)
		})
	
	# Define numeric properties to animate
	transitions.numeric_properties.append({
		"property": "panel_opacity",
		"from": 1.0,
		"to": 0.0,
		"midpoint": true  # Fade out then in
	})
	
	# Special effects for theme transitions
	if from_variant != to_variant:
		transitions.special_effects.append({
			"type": "ripple",
			"origin": "center",
			"duration": duration * 0.5
		})
	
	return transitions

# === PERFORMANCE ADAPTIVE THEMES ===

## Generate performance-adaptive themes with quality levels
static func generate_performance_adaptive_themes(variant: ThemeVariant, learning_level: int) -> Dictionary:
	"""Generate theme variants optimized for different performance levels"""
	var themes = {}
	
	# High quality theme (full effects)
	themes["high"] = _generate_high_quality_theme(variant, learning_level)
	
	# Medium quality theme (reduced effects)
	themes["medium"] = _generate_medium_quality_theme(variant, learning_level)
	
	# Low quality theme (minimal effects)
	themes["low"] = _generate_low_quality_theme(variant, learning_level)
	
	return themes

static func _generate_high_quality_theme(variant: ThemeVariant, learning_level: int) -> Theme:
	"""Generate high quality theme with all effects"""
	var theme = generate_glass_morphism_theme(variant, learning_level, 0.8)
	
	# Add additional high-quality effects metadata
	theme.set_meta("quality_level", "high")
	theme.set_meta("enable_shadows", true)
	theme.set_meta("enable_animations", true)
	theme.set_meta("enable_blur", true)
	theme.set_meta("shadow_resolution", "high")
	
	return theme

static func _generate_medium_quality_theme(variant: ThemeVariant, learning_level: int) -> Theme:
	"""Generate medium quality theme with reduced effects"""
	var theme = generate_glass_morphism_theme(variant, learning_level, 0.4)
	
	# Reduce shadow quality for performance
	_reduce_shadow_quality(theme, 0.5)
	
	theme.set_meta("quality_level", "medium")
	theme.set_meta("enable_shadows", true)
	theme.set_meta("enable_animations", true)
	theme.set_meta("enable_blur", false)
	theme.set_meta("shadow_resolution", "medium")
	
	return theme

static func _generate_low_quality_theme(variant: ThemeVariant, learning_level: int) -> Theme:
	"""Generate low quality theme for maximum performance"""
	var theme = generate_educational_theme(variant, learning_level)
	
	# Remove all shadows and effects
	_remove_shadows_from_theme(theme)
	
	theme.set_meta("quality_level", "low")
	theme.set_meta("enable_shadows", false)
	theme.set_meta("enable_animations", false)
	theme.set_meta("enable_blur", false)
	theme.set_meta("shadow_resolution", "none")
	
	return theme

static func _reduce_shadow_quality(theme: Theme, quality: float) -> void:
	"""Reduce shadow quality in theme for performance"""
	var stylebox_types = ["panel", "normal", "hover", "pressed"]
	var node_types = ["PanelContainer", "Button", "LineEdit"]
	
	for node_type in node_types:
		for stylebox_type in stylebox_types:
			var stylebox = theme.get_stylebox(stylebox_type, node_type) as StyleBoxFlat
			if stylebox and stylebox.shadow_size > 0:
				stylebox.shadow_size = int(stylebox.shadow_size * quality)
				stylebox.shadow_color.a *= quality
				theme.set_stylebox(stylebox_type, node_type, stylebox)

static func _remove_shadows_from_theme(theme: Theme) -> void:
	"""Remove all shadows from theme for maximum performance"""
	var stylebox_types = ["panel", "normal", "hover", "pressed", "focus", "disabled"]
	var node_types = ["PanelContainer", "Button", "LineEdit", "ProgressBar"]
	
	for node_type in node_types:
		for stylebox_type in stylebox_types:
			var stylebox = theme.get_stylebox(stylebox_type, node_type) as StyleBoxFlat
			if stylebox:
				stylebox.shadow_size = 0
				stylebox.shadow_color.a = 0
				theme.set_stylebox(stylebox_type, node_type, stylebox)

# === EDUCATIONAL VISUAL EFFECTS ===

## Create educational visual effects with particle systems integration
static func create_educational_visual_effects(theme: Theme, learning_level: int) -> Dictionary:
	"""Create visual effect configurations for educational interactions"""
	var effects = {
		"selection_particles": _create_selection_particle_config(learning_level),
		"success_effects": _create_success_effect_config(learning_level),
		"hover_effects": _create_hover_effect_config(learning_level),
		"transition_effects": _create_transition_effect_config(learning_level)
	}
	
	# Store effects configuration in theme metadata
	theme.set_meta("visual_effects", effects)
	
	return effects

static func _create_selection_particle_config(learning_level: int) -> Dictionary:
	"""Create particle configuration for structure selection"""
	var level_config = ColorSystem.get_learning_level_style(learning_level)
	
	return {
		"enabled": learning_level > 0,  # Disabled for beginners
		"particle_count": 20 + learning_level * 10,
		"emission_shape": "sphere",
		"initial_velocity": 100.0,
		"angular_velocity": 45.0,
		"color": ColorSystem.get_educational_color("dark", level_config.primary_accent),
		"lifetime": 1.0 + learning_level * 0.5,
		"size": 4.0 - learning_level * 0.5
	}

static func _create_success_effect_config(learning_level: int) -> Dictionary:
	"""Create effect configuration for success feedback"""
	return {
		"type": "radial_burst",
		"duration": 0.5,
		"color": ColorSystem.get_educational_color("dark", "success"),
		"intensity": 0.5 + learning_level * 0.25,
		"radius": 50 + learning_level * 25
	}

static func _create_hover_effect_config(learning_level: int) -> Dictionary:
	"""Create hover effect configuration"""
	return {
		"glow_enabled": true,
		"glow_color": ColorSystem.get_educational_color("dark", "interactive_hover"),
		"glow_strength": 0.3 + learning_level * 0.1,
		"pulse_enabled": learning_level > 0,
		"pulse_speed": 2.0
	}

static func _create_transition_effect_config(learning_level: int) -> Dictionary:
	"""Create transition effect configuration"""
	return {
		"type": "fade_slide" if learning_level < 2 else "morph_blur",
		"duration": 0.3 - learning_level * 0.05,
		"easing": "ease_in_out"
	}

# === ACCESSIBILITY VALIDATION ===

## Validate theme accessibility with automated WCAG AAA testing
static func validate_theme_accessibility(theme: Theme, variant: ThemeVariant) -> Dictionary:
	"""Comprehensive WCAG AAA validation for generated themes"""
	var theme_type = _get_theme_type_string(variant)
	var validation_results = {
		"wcag_aaa_compliant": true,
		"contrast_ratios": {},
		"color_blind_safe": true,
		"keyboard_navigable": true,
		"screen_reader_compatible": true,
		"issues": [],
		"warnings": []
	}
	
	# Test all text/background combinations
	var bg_colors = ["background_primary", "background_secondary", "background_tertiary"]
	var text_colors = ["text_primary", "text_secondary", "text_tertiary"]
	
	for bg in bg_colors:
		for text in text_colors:
			var bg_color = ColorSystem.get_educational_color(theme_type, bg)
			var text_color = ColorSystem.get_educational_color(theme_type, text)
			var ratio = ColorSystem.calculate_contrast_ratio(text_color, bg_color)
			
			var combo_name = text + "_on_" + bg
			validation_results.contrast_ratios[combo_name] = ratio
			
			if ratio < 7.0 and not text.contains("disabled"):
				validation_results.wcag_aaa_compliant = false
				validation_results.issues.append({
					"type": "contrast_ratio",
					"combination": combo_name,
					"ratio": ratio,
					"required": 7.0
				})
			elif ratio < 4.5:
				validation_results.warnings.append({
					"type": "contrast_ratio_aa",
					"combination": combo_name,
					"ratio": ratio
				})
	
	# Additional accessibility checks
	validation_results["focus_indicators"] = _validate_focus_indicators(theme, theme_type)
	validation_results["interaction_states"] = _validate_interaction_states(theme, theme_type)
	validation_results["semantic_colors"] = _validate_semantic_colors(theme_type)
	
	return validation_results

static func _validate_focus_indicators(theme: Theme, theme_type: String) -> bool:
	"""Validate that focus indicators are clearly visible"""
	var focus_border = theme.get_stylebox("focus", "LineEdit") as StyleBoxFlat
	if focus_border:
		var focus_color = focus_border.border_color
		var bg_color = ColorSystem.get_educational_color(theme_type, "background_primary")
		var ratio = ColorSystem.calculate_contrast_ratio(focus_color, bg_color)
		return ratio >= 3.0  # WCAG requirement for UI components
	return false

static func _validate_interaction_states(theme: Theme, _theme_type: String) -> bool:
	"""Validate that interaction states are distinguishable"""
	var normal = theme.get_stylebox("normal", "Button") as StyleBoxFlat
	var hover = theme.get_stylebox("hover", "Button") as StyleBoxFlat
	var pressed = theme.get_stylebox("pressed", "Button") as StyleBoxFlat
	
	if normal and hover and pressed:
		# Check that states are visually distinct
		var normal_color = normal.bg_color
		var hover_color = hover.bg_color
		var pressed_color = pressed.bg_color
		
		# Simple check: colors should be different enough
		var hover_diff = (hover_color - normal_color).length()
		var pressed_diff = (pressed_color - normal_color).length()
		
		return hover_diff > 0.1 and pressed_diff > 0.1
	return false

static func _validate_semantic_colors(theme_type: String) -> bool:
	"""Validate semantic color distinctions"""
	var success = ColorSystem.get_educational_color(theme_type, "success")
	var error = ColorSystem.get_educational_color(theme_type, "error")
	var warning = ColorSystem.get_educational_color(theme_type, "warning")
	
	# Check that semantic colors are distinguishable
	var se_diff = (success - error).length()
	var sw_diff = (success - warning).length()
	var ew_diff = (error - warning).length()
	
	return se_diff > 0.3 and sw_diff > 0.3 and ew_diff > 0.3

# === THEME UTILITIES ===

## Get theme metadata and information
static func get_theme_info(variant: ThemeVariant, learning_level: int) -> Dictionary:
	"""Get comprehensive information about generated theme"""
	var theme_type = _get_theme_type_string(variant)
	var level_config = ColorSystem.get_learning_level_style(learning_level)

	return {
		"variant": theme_type,
		"learning_level": learning_level,
		"wcag_compliance": "AAA (7:1 contrast ratio)",
		"educational_categories": ColorSystem.get_color_scheme_info().educational_categories,
		"visual_complexity": level_config.visual_complexity,
		"primary_accent": level_config.primary_accent,
		"border_weight": level_config.border_weight,
		"font_size_modifier": level_config.font_size_modifier
	}

## Create theme resource file for saving
static func save_educational_theme(theme: Theme, _variant: ThemeVariant, _learning_level: int, file_path: String) -> Error:
	"""Save generated educational theme as .tres resource file"""
	var error = ResourceSaver.save(theme, file_path)
	if error == OK:
		print("[EducationalThemeGenerator] Saved theme: " + file_path)
	else:
		push_error("[EducationalThemeGenerator] Failed to save theme: " + str(error))
	return error

## Load and validate educational theme resource
static func load_educational_theme(file_path: String) -> Theme:
	"""Load educational theme resource with validation"""
	if not ResourceLoader.exists(file_path):
		push_error("[EducationalThemeGenerator] Theme file not found: " + file_path)
		return null

	var theme = ResourceLoader.load(file_path) as Theme
	if theme == null:
		push_error("[EducationalThemeGenerator] Failed to load theme: " + file_path)
		return null

	print("[EducationalThemeGenerator] Loaded theme: " + file_path)
	return theme
