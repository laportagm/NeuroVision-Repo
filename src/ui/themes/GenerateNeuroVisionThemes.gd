@tool
extends EditorScript

## NeuroVision Theme Generation Script
## Generates all NeuroVision theme variations using Material 3 design system
## Run from Godot Editor: Tools > Execute Script

class_name GenerateNeuroVisionThemes

# === CONSTANTS ===
const THEME_OUTPUT_DIR = "res://src/ui/themes/themes/"
const DARK_THEME_PATH = THEME_OUTPUT_DIR + "DarkTheme.tres"
const HIGH_CONTRAST_THEME_PATH = THEME_OUTPUT_DIR + "HighContrastTheme.tres"
const COLORBLIND_THEME_PATH = THEME_OUTPUT_DIR + "ColorblindTheme.tres"

# === MAIN EXECUTION ===
func _run() -> void:
	print("=== NeuroVision Theme Generator ===")
	print("Generating Material 3 compliant themes with NeuroVision color palette...")
	
	# Generate all theme variations
	var themes_generated = 0
	
	# 1. Dark Theme (primary)
	var dark_theme = _generate_dark_theme()
	if _save_theme(dark_theme, DARK_THEME_PATH):
		themes_generated += 1
		print("✅ Dark Theme generated and saved")
	
	# 2. High Contrast Theme (accessibility)
	var high_contrast_theme = _generate_high_contrast_theme()
	if _save_theme(high_contrast_theme, HIGH_CONTRAST_THEME_PATH):
		themes_generated += 1
		print("✅ High Contrast Theme generated and saved")
	
	# 3. Colorblind Safe Theme
	var colorblind_theme = _generate_colorblind_theme()
	if _save_theme(colorblind_theme, COLORBLIND_THEME_PATH):
		themes_generated += 1
		print("✅ Colorblind Safe Theme generated and saved")
	
	print("\n=== Generation Complete ===")
	print("Successfully generated %d themes" % themes_generated)
	print("Themes saved to: %s" % THEME_OUTPUT_DIR)
	
	# Validate all generated themes
	_validate_generated_themes()

# === THEME GENERATION METHODS ===

func _generate_dark_theme() -> Theme:
	"""Generate the primary NeuroVision dark theme"""
	print("Generating Dark Theme with NeuroVision color palette...")
	
	var generator = Material3ThemeGenerator.new()
	generator.setup_dependencies()
	
	var theme = generator.generate_material3_theme("dark_enhanced")
	
	# Apply NeuroVision specific customizations
	_apply_neurovision_customizations(theme)
	_apply_glass_morphism_styles(theme)
	_apply_brain_structure_colors(theme)
	_configure_educational_components(theme)
	
	# Add theme metadata
	theme.set_meta("theme_name", "NeuroVision Dark")
	theme.set_meta("theme_version", "1.0.0")
	theme.set_meta("color_scheme", "dark")
	theme.set_meta("accessibility_level", "WCAG_AAA")
	theme.set_meta("educational_platform", "NeuroVision")
	
	return theme

func _generate_high_contrast_theme() -> Theme:
	"""Generate high contrast theme for accessibility"""
	print("Generating High Contrast Theme for accessibility...")
	
	var generator = Material3ThemeGenerator.new()
	generator.setup_dependencies()
	
	var theme = generator.generate_material3_theme("high_contrast")
	
	# Apply high contrast specific modifications
	_apply_high_contrast_modifications(theme)
	_apply_neurovision_customizations(theme)
	_configure_educational_components(theme)
	
	# Remove glass morphism for clarity
	_remove_transparency_effects(theme)
	
	# Add accessibility metadata
	theme.set_meta("theme_name", "NeuroVision High Contrast")
	theme.set_meta("theme_version", "1.0.0")
	theme.set_meta("color_scheme", "high_contrast")
	theme.set_meta("accessibility_level", "WCAG_AAA_ENHANCED")
	theme.set_meta("educational_platform", "NeuroVision")
	
	return theme

func _generate_colorblind_theme() -> Theme:
	"""Generate colorblind-safe theme variant"""
	print("Generating Colorblind Safe Theme...")
	
	var generator = Material3ThemeGenerator.new()
	generator.setup_dependencies()
	
	var theme = generator.generate_material3_theme("colorblind_safe")
	
	# Apply colorblind-safe modifications
	_apply_colorblind_safe_colors(theme)
	_apply_neurovision_customizations(theme)
	_apply_brain_structure_colors_colorblind_safe(theme)
	_configure_educational_components(theme)
	
	# Add colorblind-safe metadata
	theme.set_meta("theme_name", "NeuroVision Colorblind Safe")
	theme.set_meta("theme_version", "1.0.0")
	theme.set_meta("color_scheme", "colorblind_safe")
	theme.set_meta("accessibility_level", "WCAG_AAA")
	theme.set_meta("educational_platform", "NeuroVision")
	theme.set_meta("colorblind_safe", true)
	
	return theme

# === CUSTOMIZATION METHODS ===

func _apply_neurovision_customizations(theme: Theme) -> void:
	"""Apply NeuroVision specific customizations to theme"""
	var colors = M3DesignTokens.M3_COLORS
	var corners = M3DesignTokens.M3_CORNER_RADIUS
	var spacing = M3DesignTokens.M3_SPACING
	
	# === EDUCATIONAL PANEL STYLING ===
	var info_panel_style = StyleBoxFlat.new()
	info_panel_style.bg_color = colors["surface_container_high"]
	info_panel_style.corner_radius_top_left = corners["large"]
	info_panel_style.corner_radius_top_right = corners["large"]
	info_panel_style.corner_radius_bottom_left = corners["large"]
	info_panel_style.corner_radius_bottom_right = corners["large"]
	info_panel_style.border_color = colors["primary"]
	info_panel_style.border_width_left = 2
	info_panel_style.border_width_right = 2
	info_panel_style.border_width_top = 2
	info_panel_style.border_width_bottom = 2
	info_panel_style.content_margin_left = spacing["large"]
	info_panel_style.content_margin_right = spacing["large"]
	info_panel_style.content_margin_top = spacing["large"]
	info_panel_style.content_margin_bottom = spacing["large"]
	
	theme.set_stylebox("info_panel", "EducationalPanel", info_panel_style)
	
	# === QUIZ PANEL STYLING ===
	var quiz_panel_style = StyleBoxFlat.new()
	quiz_panel_style.bg_color = colors["surface_container"]
	quiz_panel_style.corner_radius_top_left = corners["medium"]
	quiz_panel_style.corner_radius_top_right = corners["medium"]
	quiz_panel_style.corner_radius_bottom_left = corners["medium"]
	quiz_panel_style.corner_radius_bottom_right = corners["medium"]
	quiz_panel_style.border_color = colors["secondary"]
	quiz_panel_style.border_width_left = 1
	quiz_panel_style.border_width_right = 1
	quiz_panel_style.border_width_top = 1
	quiz_panel_style.border_width_bottom = 1
	
	theme.set_stylebox("quiz_panel", "EducationalPanel", quiz_panel_style)
	
	# === STRUCTURE HIGHLIGHT STYLING ===
	var highlight_style = StyleBoxFlat.new()
	highlight_style.bg_color = Color.TRANSPARENT
	highlight_style.corner_radius_top_left = corners["small"]
	highlight_style.corner_radius_top_right = corners["small"]
	highlight_style.corner_radius_bottom_left = corners["small"]
	highlight_style.corner_radius_bottom_right = corners["small"]
	highlight_style.border_color = colors["primary"]
	highlight_style.border_width_left = 3
	highlight_style.border_width_right = 3
	highlight_style.border_width_top = 3
	highlight_style.border_width_bottom = 3
	
	theme.set_stylebox("structure_highlight", "BrainStructure", highlight_style)
	
	# === EDUCATIONAL TYPOGRAPHY ===
	theme.set_color("structure_label_color", "Educational", colors["on_surface"])
	theme.set_color("clinical_note_color", "Educational", colors["tertiary"])
	theme.set_color("learning_objective_color", "Educational", colors["secondary"])
	theme.set_color("assessment_feedback_color", "Educational", colors["success"])

func _apply_glass_morphism_styles(theme: Theme) -> void:
	"""Apply glass morphism effects to appropriate UI elements"""
	var generator = Material3ThemeGenerator.new()
	var colors = M3DesignTokens.M3_COLORS
	
	# Main navigation panel with glass effect
	var nav_glass_style = generator.create_glass_morphism_style(colors["surface"])
	theme.set_stylebox("navigation_glass", "Navigation", nav_glass_style)
	
	# Floating action button with glass effect
	var fab_glass_style = generator.create_glass_morphism_style(colors["primary"])
	fab_glass_style.bg_color.a = 0.9  # Slightly more opaque for buttons
	theme.set_stylebox("fab_glass", "Button", fab_glass_style)
	
	# Modal dialog backdrop
	var modal_glass_style = generator.create_glass_morphism_style(colors["surface_container"])
	theme.set_stylebox("modal_backdrop", "Modal", modal_glass_style)

func _apply_brain_structure_colors(theme: Theme) -> void:
	"""Apply brain structure specific colors to theme"""
	var brain_colors = M3DesignTokens.BRAIN_STRUCTURE_COLORS
	
	# Add each brain structure color to the theme
	for structure_name in brain_colors:
		var color = brain_colors[structure_name]
		theme.set_color(structure_name + "_color", "BrainStructure", color)
		
		# Create structure-specific style with color
		var structure_style = StyleBoxFlat.new()
		structure_style.bg_color = color
		structure_style.bg_color.a = 0.3  # Semi-transparent for overlay
		structure_style.corner_radius_top_left = 8
		structure_style.corner_radius_top_right = 8
		structure_style.corner_radius_bottom_left = 8
		structure_style.corner_radius_bottom_right = 8
		structure_style.border_color = color
		structure_style.border_width_left = 2
		structure_style.border_width_right = 2
		structure_style.border_width_top = 2
		structure_style.border_width_bottom = 2
		
		theme.set_stylebox(structure_name + "_highlight", "BrainStructure", structure_style)

func _configure_educational_components(theme: Theme) -> void:
	"""Configure educational-specific component styling"""
	var colors = M3DesignTokens.M3_COLORS
	var spacing = M3DesignTokens.M3_SPACING
	
	# === QUIZ BUTTON STYLING ===
	var quiz_button_normal = StyleBoxFlat.new()
	quiz_button_normal.bg_color = colors["surface_variant"]
	quiz_button_normal.corner_radius_top_left = 12
	quiz_button_normal.corner_radius_top_right = 12
	quiz_button_normal.corner_radius_bottom_left = 12
	quiz_button_normal.corner_radius_bottom_right = 12
	quiz_button_normal.border_color = colors["outline"]
	quiz_button_normal.border_width_left = 1
	quiz_button_normal.border_width_right = 1
	quiz_button_normal.border_width_top = 1
	quiz_button_normal.border_width_bottom = 1
	quiz_button_normal.content_margin_left = spacing["medium"]
	quiz_button_normal.content_margin_right = spacing["medium"]
	quiz_button_normal.content_margin_top = spacing["small"]
	quiz_button_normal.content_margin_bottom = spacing["small"]
	
	theme.set_stylebox("quiz_option_normal", "QuizButton", quiz_button_normal)
	
	# Quiz button selected state
	var quiz_button_selected = quiz_button_normal.duplicate()
	quiz_button_selected.bg_color = colors["primary_container"]
	quiz_button_selected.border_color = colors["primary"]
	quiz_button_selected.border_width_left = 3
	quiz_button_selected.border_width_right = 3
	quiz_button_selected.border_width_top = 3
	quiz_button_selected.border_width_bottom = 3
	
	theme.set_stylebox("quiz_option_selected", "QuizButton", quiz_button_selected)
	
	# === PROGRESS INDICATOR STYLING ===
	var progress_bg_style = StyleBoxFlat.new()
	progress_bg_style.bg_color = colors["surface_variant"]
	progress_bg_style.corner_radius_top_left = 999  # Fully rounded
	progress_bg_style.corner_radius_top_right = 999
	progress_bg_style.corner_radius_bottom_left = 999
	progress_bg_style.corner_radius_bottom_right = 999
	
	var progress_fill_style = StyleBoxFlat.new()
	progress_fill_style.bg_color = colors["primary"]
	progress_fill_style.corner_radius_top_left = 999
	progress_fill_style.corner_radius_top_right = 999
	progress_fill_style.corner_radius_bottom_left = 999
	progress_fill_style.corner_radius_bottom_right = 999
	
	theme.set_stylebox("progress_bg", "EducationalProgress", progress_bg_style)
	theme.set_stylebox("progress_fill", "EducationalProgress", progress_fill_style)

# === ACCESSIBILITY MODIFICATIONS ===

func _apply_high_contrast_modifications(theme: Theme) -> void:
	"""Apply high contrast specific modifications"""
	# Override with maximum contrast colors
	theme.set_color("font_color", "Label", Color.WHITE)
	theme.set_color("font_color", "Button", Color.BLACK)
	theme.set_color("font_color", "RichTextLabel", Color.WHITE)
	
	# High contrast backgrounds
	theme.set_color("background", "Control", Color.BLACK)
	
	# High contrast borders for focus indicators
	var focus_style = StyleBoxFlat.new()
	focus_style.bg_color = Color.TRANSPARENT
	focus_style.border_color = Color.YELLOW  # High visibility focus color
	focus_style.border_width_left = 4  # Thick border for visibility
	focus_style.border_width_right = 4
	focus_style.border_width_top = 4
	focus_style.border_width_bottom = 4
	focus_style.corner_radius_top_left = 4
	focus_style.corner_radius_top_right = 4
	focus_style.corner_radius_bottom_left = 4
	focus_style.corner_radius_bottom_right = 4
	
	theme.set_stylebox("high_contrast_focus", "Accessibility", focus_style)

func _apply_colorblind_safe_colors(theme: Theme) -> void:
	"""Apply colorblind-safe color palette"""
	# Colorblind-safe palette using blue/orange/green with different luminance
	var colorblind_safe = {
		"primary": Color("#0173B2"),      # Blue
		"secondary": Color("#DE8F05"),    # Orange  
		"tertiary": Color("#029E73"),     # Green
		"error": Color("#CC78BC"),        # Pink (instead of red)
		"success": Color("#029E73"),      # Green
		"warning": Color("#ECE133"),      # Yellow
		"info": Color("#56B4E9")          # Light blue
	}
	
	# Apply colorblind-safe colors
	for color_name in colorblind_safe:
		theme.set_color(color_name, "ColorblindSafe", colorblind_safe[color_name])

func _apply_brain_structure_colors_colorblind_safe(theme: Theme) -> void:
	"""Apply colorblind-safe brain structure colors"""
	# Colorblind-safe brain structure colors with different patterns/shapes
	var colorblind_brain_colors = {
		"hippocampus": Color("#0173B2"),   # Blue
		"amygdala": Color("#DE8F05"),      # Orange
		"cortex": Color("#029E73"),        # Green 
		"thalamus": Color("#56B4E9"),      # Light blue
		"cerebellum": Color("#ECE133"),    # Yellow
		"brainstem": Color("#CC78BC"),     # Pink
		"corpus_callosum": Color("#F0E442"), # Pale yellow
		"frontal_lobe": Color("#0173B2"),   # Blue variant
		"temporal_lobe": Color("#DE8F05"),  # Orange variant
		"parietal_lobe": Color("#029E73"),  # Green variant
		"occipital_lobe": Color("#56B4E9"), # Light blue variant
		"basal_ganglia": Color("#CC78BC"),  # Pink variant
		"limbic_system": Color("#F0E442")   # Pale yellow variant
	}
	
	# Apply colorblind-safe brain structure colors
	for structure_name in colorblind_brain_colors:
		var color = colorblind_brain_colors[structure_name]
		theme.set_color(structure_name + "_colorblind_safe", "BrainStructure", color)

func _remove_transparency_effects(theme: Theme) -> void:
	"""Remove transparency effects for high contrast theme"""
	# Override glass morphism styles with solid colors
	var solid_nav_style = StyleBoxFlat.new()
	solid_nav_style.bg_color = Color("#1A1A1A")  # Solid dark background
	solid_nav_style.corner_radius_top_left = 8
	solid_nav_style.corner_radius_top_right = 8
	solid_nav_style.corner_radius_bottom_left = 8
	solid_nav_style.corner_radius_bottom_right = 8
	solid_nav_style.border_color = Color.WHITE
	solid_nav_style.border_width_left = 2
	solid_nav_style.border_width_right = 2
	solid_nav_style.border_width_top = 2
	solid_nav_style.border_width_bottom = 2
	
	theme.set_stylebox("navigation_solid", "Navigation", solid_nav_style)

# === UTILITY METHODS ===

func _save_theme(theme: Theme, file_path: String) -> bool:
	"""Save theme to specified file path"""
	if not theme:
		push_error("Cannot save null theme to: " + file_path)
		return false
	
	var result = ResourceSaver.save(theme, file_path)
	if result != OK:
		push_error("Failed to save theme to: " + file_path + " (Error: " + str(result) + ")")
		return false
	
	print("Theme saved to: " + file_path)
	return true

func _validate_generated_themes() -> void:
	"""Validate all generated themes for accessibility compliance"""
	print("\n=== Theme Validation ===")
	
	var theme_paths = [
		DARK_THEME_PATH,
		HIGH_CONTRAST_THEME_PATH,
		COLORBLIND_THEME_PATH
	]
	
	var Validator = preload("res://src/ui/themes/M3AccessibilityValidator.gd")
	
	for theme_path in theme_paths:
		var theme = load(theme_path) as Theme
		if theme:
			var validation_result = Validator.validate_theme(theme)
			var theme_name = theme.get_meta("theme_name", "Unknown")
			
			if validation_result.is_compliant:
				print("✅ %s: WCAG AAA Compliant" % theme_name)
			else:
				print("⚠️ %s: Accessibility issues detected" % theme_name)
				print(Validator.generate_accessibility_report(theme))
		else:
			push_error("Failed to load theme: " + theme_path)

# === DEBUGGING METHODS ===

func _debug_theme_colors(theme: Theme) -> void:
	"""Debug method to print theme colors"""
	print("\n=== Theme Color Debug ===")
	var brain_colors = M3DesignTokens.BRAIN_STRUCTURE_COLORS
	
	for structure_name in brain_colors:
		var color_key = structure_name + "_color"
		if theme.has_color(color_key, "BrainStructure"):
			var color = theme.get_color(color_key, "BrainStructure")
			print("%s: %s" % [structure_name, color])

func _debug_theme_styles(theme: Theme) -> void:
	"""Debug method to print theme styleboxes"""
	print("\n=== Theme Style Debug ===")
	
	var style_types = ["Button", "Panel", "EducationalPanel", "BrainStructure"]
	for style_type in style_types:
		print("=== %s Styles ===" % style_type)
		# Note: Theme doesn't have a direct way to enumerate styles
		# This is a placeholder for debugging purposes