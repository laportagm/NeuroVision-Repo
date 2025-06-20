## Material 3 Theme Generator for NeuroVision
## Generates Material You themed resources with educational platform integration
##
## This generator creates Material 3 compliant themes that work seamlessly with
## the existing educational infrastructure while providing modern visual polish.

class_name Material3ThemeGenerator
extends RefCounted

# === SIGNALS ===
signal m3_theme_generated(theme: Theme)
signal adaptive_color_generated(structure_name: String, color: Color)

# === PROPERTIES ===
var M3Tokens = preload("res://src/ui_atomic/themes/core/M3DesignTokens.gd")
var accessibility_manager = null  # M3AccessibilityValidator instance
var accessibility_validator = null  # M3AccessibilityValidator instance

# === PHASE 4: ENHANCED MATERIAL 3 PROPERTIES ===
var performance_monitor = null  # Performance monitoring integration
var current_performance_level: String = "good"
var theme_variant_cache: Dictionary = {}  # Cache for theme variants
var educational_context: Dictionary = {}  # Current educational context
var accessibility_compliance_level: String = "WCAG_AAA"  # Target compliance
var hardware_capabilities: Dictionary = {}  # Detected hardware info
var glass_morphism_enabled: bool = true
var dynamic_quality_adjustment: bool = true

# === INITIALIZATION ===
func _init() -> void:
	pass  # M3Tokens is loaded as a class reference, not instantiated
	
func setup_dependencies() -> void:
	# Connect to existing managers if available
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		if tree.root.has_node("AccessibilityManager"):
			accessibility_manager = tree.root.get_node_or_null("AccessibilityManager")
		
		# === PHASE 4: ENHANCED DEPENDENCY SETUP ===
		# Connect to performance monitoring
		if tree.root.has_node("UIThemeManager"):
			performance_monitor = tree.root.get_node("UIThemeManager")
		
		# Detect hardware capabilities
		_detect_hardware_capabilities()
		
		# Initialize performance level
		current_performance_level = _detect_performance_level()
		
		# Configure quality settings based on performance
		_configure_quality_settings()

# === MAIN THEME GENERATION ===

## Generate a complete Material 3 theme (primary entry point)
## Called by UISystemManager for theme switching
func generate_theme(variant: String = "default") -> Theme:
	"""Generate a complete Material 3 theme compatible with NeuroVision educational system"""
	print("[Material3ThemeGenerator] Generating Material 3 theme, variant: %s" % variant)
	
	var theme = generate_material3_theme(variant)
	
	# Add educational brain structure colors integration
	_integrate_brain_structure_colors(theme, variant)
	
	# Store variant metadata for theme switching
	theme.set_meta("theme_variant", variant)
	theme.set_meta("generator_version", "2.1")
	theme.set_meta("educational_compatible", true)
	theme.set_meta("m3_performance_level", _detect_performance_level())
	
	print("[Material3ThemeGenerator] ✅ Material 3 theme generated successfully")
	return theme

## Generate a complete Material 3 theme
func generate_material3_theme(variant: String = "default") -> Theme:
	var theme = Theme.new()
	
	# Apply base Material 3 design tokens
	_apply_m3_colors(theme, variant)
	_apply_m3_typography(theme)
	_apply_m3_spacing(theme)
	_apply_m3_components(theme)
	_apply_m3_effects(theme)
	
	# Ensure educational compatibility
	_ensure_educational_compatibility(theme)
	
	# Apply accessibility overrides if needed
	if accessibility_manager and accessibility_manager.has_method("is_high_contrast_enabled") and accessibility_manager.is_high_contrast_enabled():
		_apply_accessibility_overrides(theme)
	
	# Apply performance optimizations
	# Performance optimizations now handled by M3PerformanceIntegration
	# if performance_adapter:
	_apply_performance_optimizations(theme)
	
	# Validate accessibility compliance
	_validate_and_fix_accessibility(theme)
	
	m3_theme_generated.emit(theme)
	return theme

# === COLOR SYSTEM APPLICATION ===
func _apply_m3_colors(theme: Theme, variant: String) -> void:
	var colors = M3Tokens.M3_COLORS
	
	# Background colors with gradient support
	theme.set_color("background", "Control", colors["background_start"])
	theme.set_color("background_gradient_start", "Control", colors["background_start"])
	theme.set_color("background_gradient_end", "Control", colors["background_end"])
	
	# Primary colors for main interactions
	theme.set_color("font_color", "Button", colors["on_primary"])
	theme.set_color("font_pressed_color", "Button", colors["on_primary"])
	theme.set_color("font_hover_color", "Button", colors["on_primary"])
	theme.set_color("font_focus_color", "Button", colors["on_primary"])
	theme.set_color("font_disabled_color", "Button", colors["on_primary"].darkened(0.6))
	
	# Surface colors for panels and containers
	theme.set_color("panel", "Panel", colors["surface"])
	theme.set_color("panel_variant", "Panel", colors["surface_variant"])
	theme.set_color("dark_color_2", "Editor", colors["surface_container"])
	
	# Text colors with hierarchy
	theme.set_color("font_color", "Label", colors["on_surface"])
	theme.set_color("font_shadow_color", "Label", colors["shadow"])
	theme.set_color("font_outline_color", "Label", Color.TRANSPARENT)
	
	# Semantic colors for educational feedback
	theme.set_color("error_color", "Editor", colors["error"])
	theme.set_color("success_color", "Editor", colors["success"])
	theme.set_color("warning_color", "Editor", colors["warning"])
	
	# Selection and highlight colors
	theme.set_color("selection_color", "RichTextLabel", colors["primary"])
	theme.set_color("font_selected_color", "Tree", colors["on_primary"])
	theme.set_color("caret_color", "LineEdit", colors["primary"])
	
	# Apply variant-specific modifications
	match variant:
		"high_contrast":
			_apply_high_contrast_colors(theme)
		"colorblind_safe":
			_apply_colorblind_safe_colors(theme)
		"dark_enhanced":
			_apply_dark_enhanced_colors(theme)

# === TYPOGRAPHY SYSTEM ===
func _apply_m3_typography(theme: Theme) -> void:
	var type_scale = M3Tokens.M3_TYPE_SCALE
	
	# Create fonts for different scales
	var display_large = _create_font(type_scale["display_large"])
	var headline_medium = _create_font(type_scale["headline_medium"])
	var body_large = _create_font(type_scale["body_large"])
	var label_large = _create_font(type_scale["label_large"])
	
	# Apply to theme
	theme.set_font("title_font", "Window", display_large)
	theme.set_font("font", "Button", label_large)
	theme.set_font("font", "Label", body_large)
	theme.set_font("bold_font", "RichTextLabel", headline_medium)
	
	# Font sizes
	theme.set_font_size("title_font_size", "Window", type_scale["display_large"]["size"])
	theme.set_font_size("font_size", "Button", type_scale["label_large"]["size"])
	theme.set_font_size("font_size", "Label", type_scale["body_large"]["size"])
	
	# Ensure minimum touch target size for buttons
	theme.set_constant("minimum_size_y", "Button", M3Tokens.M3_ACCESSIBILITY["touch_target_size"])

# === SPACING AND LAYOUT ===
func _apply_m3_spacing(theme: Theme) -> void:
	var spacing = M3Tokens.M3_SPACING
	
	# Container margins
	theme.set_constant("margin_left", "MarginContainer", spacing["medium"])
	theme.set_constant("margin_right", "MarginContainer", spacing["medium"])
	theme.set_constant("margin_top", "MarginContainer", spacing["medium"])
	theme.set_constant("margin_bottom", "MarginContainer", spacing["medium"])
	
	# Button padding
	theme.set_constant("h_separation", "Button", spacing["button_padding"])
	
	# List and tree spacing
	theme.set_constant("v_separation", "ItemList", spacing["small"])
	theme.set_constant("item_margin", "Tree", spacing["small"])
	
	# Panel margins
	theme.set_constant("content_margin_left", "PanelContainer", spacing["card_padding"])
	theme.set_constant("content_margin_right", "PanelContainer", spacing["card_padding"])
	theme.set_constant("content_margin_top", "PanelContainer", spacing["card_padding"])
	theme.set_constant("content_margin_bottom", "PanelContainer", spacing["card_padding"])

# === COMPONENT STYLING ===
func _apply_m3_components(theme: Theme) -> void:
	# Buttons with Material 3 styling
	_style_m3_button(theme)
	
	# Panels with elevation and rounded corners
	_style_m3_panel(theme)
	
	# Input fields with Material 3 design
	_style_m3_input(theme)
	
	# Navigation elements
	_style_m3_navigation(theme)
	
	# Tooltips and popups
	_style_m3_tooltip(theme)

func _style_m3_button(theme: Theme) -> void:
	var button_style = StyleBoxFlat.new()
	var colors = M3Tokens.M3_COLORS
	var corners = M3Tokens.M3_CORNER_RADIUS
	var elevation = M3Tokens.M3_ELEVATION
	
	# Normal state
	button_style.bg_color = colors["primary"]
	button_style.corner_radius_top_left = corners["button"]
	button_style.corner_radius_top_right = corners["button"]
	button_style.corner_radius_bottom_left = corners["button"]
	button_style.corner_radius_bottom_right = corners["button"]
	
	# Apply elevation shadow
	var shadow = M3Tokens.get_elevation_shadow(elevation["button"])
	button_style.shadow_color = shadow["color"]
	button_style.shadow_size = int(shadow["blur"])
	button_style.shadow_offset = shadow["offset"]
	
	theme.set_stylebox("normal", "Button", button_style)
	
	# Hover state with state layer
	var hover_style = button_style.duplicate()
	hover_style.bg_color = colors["primary"].lightened(0.08)
	theme.set_stylebox("hover", "Button", hover_style)
	
	# Pressed state
	var pressed_style = button_style.duplicate()
	pressed_style.bg_color = colors["primary"].darkened(0.12)
	pressed_style.shadow_size = int(shadow["blur"] * 0.5)
	theme.set_stylebox("pressed", "Button", pressed_style)
	
	# Disabled state
	var disabled_style = button_style.duplicate()
	disabled_style.bg_color = colors["on_surface"]
	disabled_style.bg_color.a = M3Tokens.M3_OPACITY["disabled"]
	disabled_style.shadow_size = 0
	theme.set_stylebox("disabled", "Button", disabled_style)

func _style_m3_panel(theme: Theme) -> void:
	var panel_style = StyleBoxFlat.new()
	var colors = M3Tokens.M3_COLORS
	var corners = M3Tokens.M3_CORNER_RADIUS
	var elevation = M3Tokens.M3_ELEVATION
	
	# Surface container styling
	panel_style.bg_color = colors["surface_container"]
	panel_style.corner_radius_top_left = corners["card"]
	panel_style.corner_radius_top_right = corners["card"]
	panel_style.corner_radius_bottom_left = corners["card"]
	panel_style.corner_radius_bottom_right = corners["card"]
	
	# Subtle elevation
	var shadow = M3Tokens.get_elevation_shadow(elevation["card"])
	panel_style.shadow_color = shadow["color"]
	panel_style.shadow_size = int(shadow["blur"])
	panel_style.shadow_offset = shadow["offset"]
	
	# Border for definition
	panel_style.border_color = colors["outline_variant"]
	panel_style.border_width_left = 1
	panel_style.border_width_right = 1
	panel_style.border_width_top = 1
	panel_style.border_width_bottom = 1
	
	theme.set_stylebox("panel", "Panel", panel_style)
	theme.set_stylebox("panel", "PanelContainer", panel_style)

func _style_m3_input(theme: Theme) -> void:
	var input_style = StyleBoxFlat.new()
	var colors = M3Tokens.M3_COLORS
	var corners = M3Tokens.M3_CORNER_RADIUS
	
	# Text field styling
	input_style.bg_color = colors["surface_variant"]
	input_style.corner_radius_top_left = corners["text_field"]
	input_style.corner_radius_top_right = corners["text_field"]
	input_style.corner_radius_bottom_left = corners["text_field"]
	input_style.corner_radius_bottom_right = corners["text_field"]
	
	# Border styling
	input_style.border_color = colors["outline"]
	input_style.border_width_left = 1
	input_style.border_width_right = 1
	input_style.border_width_top = 1
	input_style.border_width_bottom = 1
	
	# Content margins
	input_style.content_margin_left = 12
	input_style.content_margin_right = 12
	input_style.content_margin_top = 8
	input_style.content_margin_bottom = 8
	
	theme.set_stylebox("normal", "LineEdit", input_style)
	theme.set_stylebox("normal", "TextEdit", input_style)
	
	# Focus state with WCAG AAA compliant border width
	var focus_style = input_style.duplicate()
	focus_style.border_color = colors["primary"]
	focus_style.border_width_left = M3Tokens.M3_ACCESSIBILITY["focus_indicator_width"]
	focus_style.border_width_right = M3Tokens.M3_ACCESSIBILITY["focus_indicator_width"]
	focus_style.border_width_top = M3Tokens.M3_ACCESSIBILITY["focus_indicator_width"]
	focus_style.border_width_bottom = M3Tokens.M3_ACCESSIBILITY["focus_indicator_width"]
	theme.set_stylebox("focus", "LineEdit", focus_style)
	theme.set_stylebox("focus", "TextEdit", focus_style)

func _style_m3_navigation(theme: Theme) -> void:
	var nav_style = StyleBoxFlat.new()
	var colors = M3Tokens.M3_COLORS
	var corners = M3Tokens.M3_CORNER_RADIUS
	var blur = M3Tokens.M3_BLUR
	
	# Navigation rail/drawer styling with glass morphism
	nav_style.bg_color = colors["surface"]
	nav_style.bg_color.a = M3Tokens.M3_OPACITY["glass"]
	nav_style.corner_radius_top_left = corners["navigation"]
	nav_style.corner_radius_top_right = corners["navigation"]
	nav_style.corner_radius_bottom_left = corners["navigation"]
	nav_style.corner_radius_bottom_right = corners["navigation"]
	
	# Apply blur effect (requires custom shader in actual implementation)
	nav_style.shadow_color = colors["surface"].lightened(0.1)
	nav_style.shadow_size = blur["navigation"]
	
	theme.set_stylebox("panel", "TabContainer", nav_style)
	theme.set_stylebox("panel", "TabBar", nav_style)

func _style_m3_tooltip(theme: Theme) -> void:
	var tooltip_style = StyleBoxFlat.new()
	var colors = M3Tokens.M3_COLORS
	var corners = M3Tokens.M3_CORNER_RADIUS
	var elevation = M3Tokens.M3_ELEVATION
	
	# Tooltip styling
	tooltip_style.bg_color = colors["inverse_surface"]
	tooltip_style.corner_radius_top_left = corners["small"]
	tooltip_style.corner_radius_top_right = corners["small"]
	tooltip_style.corner_radius_bottom_left = corners["small"]
	tooltip_style.corner_radius_bottom_right = corners["small"]
	
	# Elevation for floating effect
	var shadow = M3Tokens.get_elevation_shadow(elevation["tooltip"])
	tooltip_style.shadow_color = shadow["color"]
	tooltip_style.shadow_size = int(shadow["blur"])
	tooltip_style.shadow_offset = shadow["offset"]
	
	# Content padding
	tooltip_style.content_margin_left = 8
	tooltip_style.content_margin_right = 8
	tooltip_style.content_margin_top = 4
	tooltip_style.content_margin_bottom = 4
	
	theme.set_stylebox("panel", "TooltipPanel", tooltip_style)

# === EFFECTS AND ANIMATIONS ===
func _apply_m3_effects(theme: Theme) -> void:
	# Store animation durations as theme constants
	var durations = M3Tokens.M3_DURATION
	
	theme.set_constant("transition_duration_short", "Effects", durations["short4"])
	theme.set_constant("transition_duration_medium", "Effects", durations["medium2"])
	theme.set_constant("transition_duration_long", "Effects", durations["long1"])
	
	# Glass morphism parameters
	theme.set_constant("blur_amount", "Effects", M3Tokens.M3_BLUR["glass_morphism"])
	theme.set_constant("glass_opacity", "Effects", int(M3Tokens.M3_OPACITY["glass"] * 100))

# === EDUCATIONAL COMPATIBILITY ===
func _ensure_educational_compatibility(theme: Theme) -> void:
	# Map educational semantic colors to Material 3 equivalents
	var mapping = M3Tokens.EDUCATIONAL_TO_M3_MAPPING
	var colors = M3Tokens.M3_COLORS
	
	for edu_key in mapping:
		var m3_key = mapping[edu_key]
		if colors.has(m3_key):
			theme.set_color(edu_key, "Educational", colors[m3_key])
	
	# Preserve educational-specific components
	theme.set_constant("info_panel_min_width", "Educational", 320)
	theme.set_constant("structure_label_offset", "Educational", 20)
	theme.set_constant("tooltip_delay", "Educational", 500)

# === ACCESSIBILITY OVERRIDES ===
func _apply_accessibility_overrides(theme: Theme) -> void:
	var a11y = M3Tokens.M3_ACCESSIBILITY
	var colors = M3Tokens.M3_COLORS
	
	# Increase contrast for all text
	var high_contrast_text = Color.WHITE
	var high_contrast_bg = Color.BLACK
	
	# Apply minimum contrast ratios
	theme.set_color("font_color", "Label", high_contrast_text)
	theme.set_color("font_color", "Button", high_contrast_bg)
	theme.set_color("font_color", "LineEdit", high_contrast_text)
	
	# Increase focus indicators
	var focus_style = StyleBoxFlat.new()
	focus_style.border_color = colors["primary"]
	focus_style.border_width_left = a11y["focus_indicator_width"]
	focus_style.border_width_right = a11y["focus_indicator_width"]
	focus_style.border_width_top = a11y["focus_indicator_width"]
	focus_style.border_width_bottom = a11y["focus_indicator_width"]
	
	theme.set_stylebox("focus", "Button", focus_style)
	theme.set_stylebox("focus", "LineEdit", focus_style)
	
	# Ensure touch targets meet minimum size
	theme.set_constant("minimum_size", "Button", a11y["touch_target_size"])

# === PERFORMANCE OPTIMIZATIONS ===
func _apply_performance_optimizations(theme: Theme) -> void:
	# Use M3 Performance Integration for optimization
	var M3Performance = preload("res://src/ui_atomic/themes/utilities/M3PerformanceIntegration.gd")
	
	# Detect optimal performance level
	var performance_level = M3Performance.detect_optimal_performance_level()
	
	# Apply optimizations
	M3Performance.optimize_m3_theme(theme, performance_level)
	
	# Log optimization level
	print("[Material3] Applied performance level: %s" % M3Performance.get_performance_level_description(performance_level))

func _disable_shadows(theme: Theme) -> void:
	# Remove shadows from all styleboxes
	for type in ["Button", "Panel", "PanelContainer", "TooltipPanel"]:
		for state in ["normal", "hover", "pressed", "focus"]:
			var stylebox = theme.get_stylebox(state, type)
			if stylebox and stylebox is StyleBoxFlat:
				stylebox.shadow_size = 0

func _reduce_shadow_quality(theme: Theme) -> void:
	# Reduce shadow size by half
	for type in ["Button", "Panel", "PanelContainer", "TooltipPanel"]:
		for state in ["normal", "hover", "pressed", "focus"]:
			var stylebox = theme.get_stylebox(state, type)
			if stylebox and stylebox is StyleBoxFlat:
				stylebox.shadow_size = int(stylebox.shadow_size * 0.5)

func _reduce_animations(theme: Theme) -> void:
	# Speed up all animations for lower-end devices
	var reduction_factor = M3Tokens.M3_ACCESSIBILITY["animation_reduce_factor"]
	
	theme.set_constant("transition_duration_short", "Effects", 
		int(theme.get_constant("transition_duration_short", "Effects") * reduction_factor))
	theme.set_constant("transition_duration_medium", "Effects", 
		int(theme.get_constant("transition_duration_medium", "Effects") * reduction_factor))
	theme.set_constant("transition_duration_long", "Effects", 
		int(theme.get_constant("transition_duration_long", "Effects") * reduction_factor))

# === VARIANT SPECIFIC MODIFICATIONS ===
func _apply_high_contrast_colors(theme: Theme) -> void:
	# Override with high contrast colors
	theme.set_color("font_color", "Label", Color.WHITE)
	theme.set_color("background", "Control", Color.BLACK)
	theme.set_color("panel", "Panel", Color(0.1, 0.1, 0.1))
	theme.set_color("primary", "Button", Color.YELLOW)

func _apply_colorblind_safe_colors(theme: Theme) -> void:
	# Use colorblind-safe palette
	var colorblind_safe = {
		"primary": Color("#0173B2"),  # Blue
		"secondary": Color("#DE8F05"),  # Orange
		"tertiary": Color("#029E73"),  # Green
		"error": Color("#CC78BC"),  # Pink
		"success": Color("#029E73"),  # Green
		"warning": Color("#ECE133")  # Yellow
	}
	
	for key in colorblind_safe:
		theme.set_color(key, "Colors", colorblind_safe[key])

func _apply_dark_enhanced_colors(theme: Theme) -> void:
	# Enhanced dark mode with deeper blacks and vibrant accents
	theme.set_color("background_start", "Control", Color(0, 0, 0))
	theme.set_color("background_end", "Control", Color(0.05, 0.05, 0.1))
	theme.set_color("primary", "Button", Color("#00F5FF"))  # Bright cyan

# === HELPER METHODS ===
func _create_font(_type_spec: Dictionary) -> Font:
	# In a real implementation, this would load appropriate font resources
	# For now, return null to use default fonts
	return null

## Generate adaptive color based on brain structure
func generate_adaptive_color(structure_name: String, base_hue: float = -1.0) -> Color:
	# Use content-adaptive logic similar to ContentAdaptiveThemeGenerator
	if base_hue < 0:
		base_hue = hash(structure_name) % 360 / 360.0
	
	var color = Color.from_hsv(base_hue, 0.7, 0.9)
	
	# Apply Material 3 tonal adjustments
	var tonal_palette = M3Tokens.generate_tonal_palette(color)
	
	adaptive_color_generated.emit(structure_name, tonal_palette["40"])
	return tonal_palette["40"]

## Create a glass morphism effect style
func create_glass_morphism_style(base_color: Color = Color.WHITE) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	var colors = M3Tokens.M3_COLORS
	
	style.bg_color = base_color
	style.bg_color.a = M3Tokens.M3_OPACITY["glass"]
	
	style.corner_radius_top_left = M3Tokens.M3_CORNER_RADIUS["medium"]
	style.corner_radius_top_right = M3Tokens.M3_CORNER_RADIUS["medium"]
	style.corner_radius_bottom_left = M3Tokens.M3_CORNER_RADIUS["medium"]
	style.corner_radius_bottom_right = M3Tokens.M3_CORNER_RADIUS["medium"]
	
	style.border_color = colors["outline_variant"]
	style.border_color.a = 0.3
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	
	# Note: Actual blur would require a custom shader
	style.shadow_color = base_color.lightened(0.2)
	style.shadow_size = M3Tokens.M3_BLUR["glass_morphism"]
	
	return style

# === ACCESSIBILITY VALIDATION ===

func _validate_and_fix_accessibility(theme: Theme) -> void:
	"""Validate and automatically fix accessibility issues"""
	
	# Load validator
	var Validator = preload("res://src/ui_atomic/themes/validation/M3AccessibilityValidator.gd")
	
	# Validate the theme
	var validation_result = Validator.validate_theme(theme)
	
	if not validation_result.is_compliant:
		print("[Material3] Theme has accessibility issues, attempting fixes...")
		
		# Auto-fix color contrast issues
		_fix_color_contrasts(theme)
		
		# Re-validate
		validation_result = Validator.validate_theme(theme)
		
		if validation_result.is_compliant:
			print("[Material3] Accessibility issues fixed automatically")
		else:
			push_warning("[Material3] Some accessibility issues remain")
			print(Validator.generate_accessibility_report(theme))
	
	# Store validation metadata
	theme.set_meta("wcag_aaa_validated", validation_result.is_compliant)
	theme.set_meta("accessibility_report", Validator.generate_accessibility_report(theme))

func _fix_color_contrasts(theme: Theme) -> void:
	"""Automatically adjust colors to meet WCAG AAA contrast requirements"""
	
	var Validator = preload("res://src/ui_atomic/themes/validation/M3AccessibilityValidator.gd")
	var colors = M3Tokens.M3_COLORS
	
	# Fix text on surface contrast
	var on_surface = theme.get_color("font_color", "Label")
	var surface_color = colors["surface"]
	
	if not Validator.is_color_pair_accessible(on_surface, surface_color):
		var adjusted = Validator.suggest_accessible_color(on_surface, surface_color)
		theme.set_color("font_color", "Label", adjusted)
		theme.set_color("font_color", "RichTextLabel", adjusted)
	
	# Fix button text contrast
	var button_style = theme.get_stylebox("normal", "Button") as StyleBoxFlat
	if button_style:
		var button_text = theme.get_color("font_color", "Button")
		var button_bg = button_style.bg_color
		
		if not Validator.is_color_pair_accessible(button_text, button_bg):
			var adjusted = Validator.suggest_accessible_color(button_text, button_bg)
			theme.set_color("font_color", "Button", adjusted)
			theme.set_color("font_hover_color", "Button", adjusted)
			theme.set_color("font_pressed_color", "Button", adjusted)

# === PHASE 4: EDUCATIONAL THEME VARIANTS ===

func generate_educational_theme_variant(variant: String, context: Dictionary = {}) -> Theme:
	"""Generate educational theme variant with specific optimizations"""
	print("[Material3] Generating educational theme variant: %s" % variant)
	
	# Store educational context
	educational_context = context
	
	# Check cache first
	var cache_key = variant + "_" + str(context.hash())
	if theme_variant_cache.has(cache_key):
		print("[Material3] Using cached theme variant")
		return theme_variant_cache[cache_key]
	
	# Generate base theme
	var theme = generate_material3_theme(variant)
	
	# Apply educational variant-specific enhancements
	match variant:
		"enhanced":
			_apply_enhanced_educational_variant(theme, context)
		"minimal":
			_apply_minimal_educational_variant(theme, context)
		"clinical":
			_apply_clinical_educational_variant(theme, context)
		"accessibility":
			_apply_accessibility_educational_variant(theme, context)
	
	# Cache the theme
	theme_variant_cache[cache_key] = theme
	
	# Add metadata
	theme.set_meta("educational_variant", variant)
	theme.set_meta("educational_context", context)
	theme.set_meta("generation_timestamp", Time.get_unix_time_from_system())
	
	return theme

func _apply_enhanced_educational_variant(theme: Theme, _context: Dictionary) -> void:
	"""Apply enhanced educational variant optimized for student engagement"""
	var colors = M3Tokens.M3_COLORS
	
	# Enhanced colors for better engagement
	theme.set_color("primary_enhanced", "Educational", colors.primary.lightened(0.1))
	theme.set_color("secondary_enhanced", "Educational", colors.secondary.lightened(0.15))
	
	# Vibrant brain structure colors
	var brain_colors = M3Tokens.BRAIN_STRUCTURE_COLORS
	for structure in brain_colors:
		var enhanced_color = brain_colors[structure].lightened(0.1)
		enhanced_color.s = min(enhanced_color.s + 0.1, 1.0)
		theme.set_color("brain_" + structure + "_enhanced", "Educational", enhanced_color)
	
	# Enhanced interactive feedback
	theme.set_constant("hover_scale_factor", "Educational", 105)  # 5% scale increase
	theme.set_constant("selection_glow_intensity", "Educational", 120)  # 20% brighter glow
	
	# Glass morphism effects (if enabled)
	if glass_morphism_enabled:
		theme.set_constant("glass_blur_radius", "Educational", 12)
		theme.set_constant("glass_opacity", "Educational", 85)
	
	print("[Material3] Enhanced educational variant applied")

func _apply_minimal_educational_variant(theme: Theme, _context: Dictionary) -> void:
	"""Apply minimal educational variant optimized for professional medical use"""
	var colors = M3Tokens.M3_COLORS
	
	# Muted professional colors
	theme.set_color("primary_minimal", "Educational", colors.primary.darkened(0.1))
	theme.set_color("secondary_minimal", "Educational", colors.secondary.darkened(0.15))
	
	# Reduced saturation for brain structures
	var brain_colors = M3Tokens.BRAIN_STRUCTURE_COLORS
	for structure in brain_colors:
		var minimal_color = brain_colors[structure]
		minimal_color.s = minimal_color.s * 0.7  # Reduce saturation
		minimal_color.v = minimal_color.v * 0.9  # Slightly darker
		theme.set_color("brain_" + structure + "_minimal", "Educational", minimal_color)
	
	# Subtle interaction feedback
	theme.set_constant("hover_scale_factor", "Educational", 102)  # 2% scale increase
	theme.set_constant("selection_glow_intensity", "Educational", 80)   # 20% dimmer glow
	
	# Minimal effects
	theme.set_constant("glass_blur_radius", "Educational", 4)
	theme.set_constant("glass_opacity", "Educational", 60)
	
	print("[Material3] Minimal educational variant applied")

func _apply_clinical_educational_variant(theme: Theme, _context: Dictionary) -> void:
	"""Apply clinical educational variant optimized for medical professionals"""
	var _colors = M3Tokens.M3_COLORS
	
	# Clinical color scheme - high contrast, medical-grade
	theme.set_color("primary_clinical", "Educational", Color("#0066CC"))  # Medical blue
	theme.set_color("secondary_clinical", "Educational", Color("#006600"))  # Medical green
	theme.set_color("warning_clinical", "Educational", Color("#FF6600"))   # Medical orange
	theme.set_color("error_clinical", "Educational", Color("#CC0000"))     # Medical red
	
	# High-contrast brain structure colors for clinical accuracy
	var brain_colors = M3Tokens.BRAIN_STRUCTURE_COLORS
	for structure in brain_colors:
		var clinical_color = _ensure_clinical_contrast(brain_colors[structure])
		theme.set_color("brain_" + structure + "_clinical", "Educational", clinical_color)
	
	# Professional interaction feedback
	theme.set_constant("hover_scale_factor", "Educational", 101)  # 1% scale increase
	theme.set_constant("selection_outline_width", "Educational", 3)  # 3px outline
	
	# Disable decorative effects for clinical use
	theme.set_constant("glass_blur_radius", "Educational", 0)
	theme.set_constant("glass_opacity", "Educational", 100)
	
	print("[Material3] Clinical educational variant applied")

func _apply_accessibility_educational_variant(theme: Theme, _context: Dictionary) -> void:
	"""Apply accessibility educational variant with WCAG AAA+ compliance"""
	var _colors = M3Tokens.M3_COLORS
	
	# Maximum contrast colors
	theme.set_color("primary_accessible", "Educational", Color.YELLOW)
	theme.set_color("secondary_accessible", "Educational", Color.CYAN)
	theme.set_color("background_accessible", "Educational", Color.BLACK)
	theme.set_color("text_accessible", "Educational", Color.WHITE)
	
	# High-contrast brain structure colors
	var accessible_brain_colors = {
		"hippocampus": Color(1.0, 0.0, 0.0),    # Pure red
		"amygdala": Color(0.0, 1.0, 0.0),       # Pure green  
		"cortex": Color(0.0, 0.0, 1.0),         # Pure blue
		"thalamus": Color(1.0, 1.0, 0.0),       # Pure yellow
		"cerebellum": Color(1.0, 0.0, 1.0),     # Pure magenta
		"brainstem": Color(0.0, 1.0, 1.0)       # Pure cyan
	}
	
	for structure in accessible_brain_colors:
		theme.set_color("brain_" + structure + "_accessible", "Educational", accessible_brain_colors[structure])
	
	# Enhanced interaction feedback for accessibility
	theme.set_constant("hover_scale_factor", "Educational", 110)  # 10% scale increase
	theme.set_constant("selection_outline_width", "Educational", 5)  # 5px outline
	theme.set_constant("focus_indicator_width", "Educational", 4)   # 4px focus ring
	
	# No transparency or blur for accessibility
	theme.set_constant("glass_blur_radius", "Educational", 0)
	theme.set_constant("glass_opacity", "Educational", 100)
	
	print("[Material3] Accessibility educational variant applied")

func _ensure_clinical_contrast(color: Color) -> Color:
	"""Ensure color meets clinical contrast requirements"""
	# Calculate relative luminance
	var luminance = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b
	
	# Adjust for high contrast against dark background
	if luminance < 0.5:
		return color.lightened(0.3)
	else:
		return color

# === ENHANCED EDUCATIONAL SYSTEM INTEGRATION ===

func _integrate_brain_structure_colors(theme: Theme, variant: String) -> void:
	"""Integrate educational brain structure colors with theme variant"""
	
	# Get brain structure colors from M3DesignTokens
	var brain_colors = M3Tokens.BRAIN_STRUCTURE_COLORS
	if brain_colors.is_empty():
		print("[Material3ThemeGenerator] Brain structure colors not available")
		return
	
	# Apply variant-specific color adaptations
	for structure_name in brain_colors:
		var base_color = brain_colors[structure_name]
		var adapted_color = _adapt_brain_color_for_variant(base_color, variant)
		
		# Store in theme for educational components
		theme.set_color("brain_" + structure_name, "Educational", adapted_color)
		
		# Also create hover and selection variants
		theme.set_color("brain_" + structure_name + "_hover", "Educational", adapted_color.lightened(0.2))
		theme.set_color("brain_" + structure_name + "_selected", "Educational", adapted_color.lightened(0.4))
	
	print("[Material3ThemeGenerator] Integrated %d brain structure colors" % brain_colors.size())

func _adapt_brain_color_for_variant(color: Color, variant: String) -> Color:
	"""Adapt brain structure color for specific theme variant"""
	
	match variant:
		"high_contrast":
			# Increase saturation and brightness for high contrast
			return Color.from_hsv(color.h, min(color.s + 0.3, 1.0), min(color.v + 0.2, 1.0))
		
		"colorblind_safe":
			# Adjust colors to be more distinguishable for colorblind users
			var safe_hues = [0.0, 0.15, 0.33, 0.5, 0.66, 0.83]  # Red, Orange, Green, Cyan, Blue, Magenta
			var closest_hue = safe_hues[0]
			var min_distance = abs(color.h - safe_hues[0])
			
			for hue in safe_hues:
				var distance = abs(color.h - hue)
				if distance < min_distance:
					min_distance = distance
					closest_hue = hue
			
			return Color.from_hsv(closest_hue, 0.8, 0.9)
		
		"minimal":
			# Reduce saturation for minimal theme
			return Color.from_hsv(color.h, color.s * 0.6, color.v * 0.8)
		
		"enhanced":
			# Enhance vibrancy for enhanced theme
			return Color.from_hsv(color.h, min(color.s + 0.1, 1.0), min(color.v + 0.1, 1.0))
		
		"educational":
			# Optimize for educational clarity
			return Color.from_hsv(color.h, 0.7, 0.85)
		
		_:
			return color

func _detect_performance_level() -> String:
	"""Detect optimal performance level for M3 theme optimizations"""
	
	# Try to get performance level from CoreSystemManager
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root.has_node("CoreSystemManager"):
		var core_manager = tree.root.get_node("CoreSystemManager")
		if core_manager.has_method("get_performance_level"):
			var level = core_manager.get_performance_level()
			match level:
				0: return "excellent"  # PerformanceLevel.EXCELLENT
				1: return "good"       # PerformanceLevel.GOOD
				2: return "acceptable" # PerformanceLevel.ACCEPTABLE
				3: return "poor"       # PerformanceLevel.POOR
	
	# Fallback performance detection
	var fps = Engine.get_frames_per_second()
	if fps >= 60:
		return "excellent"
	elif fps >= 45:
		return "good"
	elif fps >= 30:
		return "acceptable"
	else:
		return "low"

# === PHASE 4: NEW ENHANCED METHODS ===

func _evaluate_performance_from_metrics(metrics: Dictionary) -> String:
	"""Evaluate performance level from detailed metrics"""
	var fps = metrics.get("fps", 30.0)
	var frame_time = metrics.get("frame_time_ms", 33.0)
	var memory_mb = metrics.get("memory_mb", 500.0)
	var stability = metrics.get("performance_stability", 0.5)
	
	# Weighted scoring system
	var score = 0.0
	
	# FPS score (40%)
	if fps >= 90: score += 0.4
	elif fps >= 60: score += 0.35
	elif fps >= 45: score += 0.25
	elif fps >= 30: score += 0.15
	else: score += 0.05
	
	# Frame time consistency score (30%)
	if frame_time <= 11.0: score += 0.3  # 90+ FPS
	elif frame_time <= 16.7: score += 0.25  # 60 FPS
	elif frame_time <= 22.2: score += 0.15  # 45 FPS
	elif frame_time <= 33.3: score += 0.1   # 30 FPS
	
	# Memory efficiency score (20%)
	if memory_mb <= 200: score += 0.2
	elif memory_mb <= 350: score += 0.15
	elif memory_mb <= 500: score += 0.1
	elif memory_mb <= 750: score += 0.05
	
	# Stability score (10%)
	score += stability * 0.1
	
	# Convert to quality level
	if score >= 0.85: return "maximum"
	elif score >= 0.65: return "high"
	elif score >= 0.45: return "medium"
	else: return "low"

func _detect_hardware_capabilities() -> void:
	"""Detect hardware capabilities for optimal theme configuration"""
	hardware_capabilities = {
		"cpu_cores": OS.get_processor_count(),
		"platform": OS.get_name(),
		"memory_total_mb": OS.get_static_memory_usage() / (1024.0 * 1024.0),
		"renderer": RenderingServer.get_rendering_device().get_device_name() if RenderingServer.get_rendering_device() else "Unknown",
		"supports_compute_shaders": RenderingServer.get_rendering_device() != null,
		"mobile_device": OS.get_name() in ["Android", "iOS"]
	}
	
	# Determine GPU tier based on available information
	var gpu_name = hardware_capabilities.renderer.to_lower()
	if "nvidia" in gpu_name or "amd" in gpu_name or "radeon" in gpu_name:
		hardware_capabilities["gpu_tier"] = "dedicated"
	elif "intel" in gpu_name and ("iris" in gpu_name or "xe" in gpu_name):
		hardware_capabilities["gpu_tier"] = "integrated_modern"
	elif "intel" in gpu_name:
		hardware_capabilities["gpu_tier"] = "integrated_basic"
	else:
		hardware_capabilities["gpu_tier"] = "unknown"
	
	print("[Material3] Hardware capabilities detected: CPU=%d cores, GPU=%s, Platform=%s" % [
		hardware_capabilities.cpu_cores,
		hardware_capabilities.gpu_tier,
		hardware_capabilities.platform
	])

func _configure_quality_settings() -> void:
	"""Configure quality settings based on detected hardware and performance"""
	var gpu_tier = hardware_capabilities.get("gpu_tier", "unknown")
	var is_mobile = hardware_capabilities.get("mobile_device", false)
	
	# Adjust settings based on hardware
	match gpu_tier:
		"dedicated":
			glass_morphism_enabled = true
			dynamic_quality_adjustment = true
		"integrated_modern":
			glass_morphism_enabled = true
			dynamic_quality_adjustment = true
		"integrated_basic":
			glass_morphism_enabled = current_performance_level in ["high", "maximum"]
			dynamic_quality_adjustment = true
		_:
			glass_morphism_enabled = false
			dynamic_quality_adjustment = false
	
	# Mobile-specific adjustments
	if is_mobile:
		glass_morphism_enabled = glass_morphism_enabled and current_performance_level == "maximum"
		dynamic_quality_adjustment = true
	
	print("[Material3] Quality settings configured: Glass=%s, DynamicQuality=%s" % [
		glass_morphism_enabled, dynamic_quality_adjustment
	])

# === PHASE 4: PERFORMANCE-AWARE GLASS MORPHISM ===

func create_performance_aware_glass_style(base_color: Color = Color.WHITE, intensity: float = 0.85) -> StyleBoxFlat:
	"""Create glass morphism style adapted to current performance level"""
	var style = StyleBoxFlat.new()
	var colors = M3Tokens.M3_COLORS
	
	# Base glass configuration
	style.bg_color = base_color
	style.bg_color.a = intensity * M3Tokens.M3_OPACITY["glass"]
	
	# Performance-aware corner radius
	var corner_radius = M3Tokens.M3_CORNER_RADIUS["medium"]
	match current_performance_level:
		"maximum":
			corner_radius = M3Tokens.M3_CORNER_RADIUS["large"]
		"high":
			corner_radius = M3Tokens.M3_CORNER_RADIUS["medium"]
		"medium":
			corner_radius = M3Tokens.M3_CORNER_RADIUS["small"]
		"low":
			corner_radius = M3Tokens.M3_CORNER_RADIUS["extra_small"]
	
	style.set_corner_radius_all(corner_radius)
	
	# Performance-aware border and shadow
	if current_performance_level in ["maximum", "high"]:
		style.border_color = colors["outline_variant"]
		style.border_color.a = 0.3
		style.set_border_width_all(1)
		
		# Enhanced shadow for high performance
		style.shadow_color = base_color.lightened(0.2)
		style.shadow_size = M3Tokens.get_performance_token(current_performance_level, "blur_radius")
		style.shadow_offset = Vector2(0, 2)
	else:
		# Simplified for lower performance
		style.border_color = Color.TRANSPARENT
		style.set_border_width_all(0)
		style.shadow_size = 0
	
	return style
