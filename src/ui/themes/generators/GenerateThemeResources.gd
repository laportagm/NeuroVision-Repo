## NeuroVision Theme Resource Generator
## Generates actual theme resource files programmatically

class_name GenerateThemeResources
extends RefCounted

# === CONSTANTS ===
const THEME_OUTPUT_DIR = "res://src/ui/themes/themes/"

## Generate all NeuroVision theme resources
static func generate_all_themes() -> bool:
	print("=== Generating NeuroVision Theme Resources ===")
	
	var success_count = 0
	
	# Generate Dark Theme
	var dark_theme = _create_dark_theme()
	if _save_theme_resource(dark_theme, THEME_OUTPUT_DIR + "DarkTheme.tres"):
		success_count += 1
		print("✅ Dark Theme generated")
	
	# Generate High Contrast Theme  
	var high_contrast_theme = _create_high_contrast_theme()
	if _save_theme_resource(high_contrast_theme, THEME_OUTPUT_DIR + "HighContrastTheme.tres"):
		success_count += 1
		print("✅ High Contrast Theme generated")
	
	# Generate Colorblind Theme
	var colorblind_theme = _create_colorblind_theme()
	if _save_theme_resource(colorblind_theme, THEME_OUTPUT_DIR + "ColorblindTheme.tres"):
		success_count += 1
		print("✅ Colorblind Safe Theme generated")
	
	print("Generated %d theme resources successfully" % success_count)
	return success_count == 3

## Create the main NeuroVision dark theme
static func _create_dark_theme() -> Theme:
	var theme = Theme.new()
	var colors = M3DesignTokens.M3_COLORS
	var corners = M3DesignTokens.M3_CORNER_RADIUS
	var spacing = M3DesignTokens.M3_SPACING
	
	# === BUTTON STYLING ===
	_setup_button_styles(theme, colors, corners, spacing)
	
	# === PANEL STYLING ===
	_setup_panel_styles(theme, colors, corners, spacing)
	
	# === TEXT STYLING ===
	_setup_text_styles(theme, colors)
	
	# === EDUCATIONAL COMPONENTS ===
	_setup_educational_styles(theme, colors, corners, spacing)
	
	# === BRAIN STRUCTURE COLORS ===
	_setup_brain_structure_colors(theme)
	
	# Add metadata
	theme.set_meta("theme_name", "NeuroVision Dark")
	theme.set_meta("theme_version", "1.0.0")
	theme.set_meta("color_scheme", "dark")
	theme.set_meta("accessibility_level", "WCAG_AAA")
	
	return theme

## Create high contrast accessibility theme
static func _create_high_contrast_theme() -> Theme:
	var theme = _create_dark_theme()  # Start with dark theme
	
	# Override with high contrast colors
	theme.set_color("font_color", "Label", Color.WHITE)
	theme.set_color("font_color", "Button", Color.BLACK)
	theme.set_color("font_color", "RichTextLabel", Color.WHITE)
	theme.set_color("background", "Control", Color.BLACK)
	
	# High contrast focus indicators
	var focus_style = StyleBoxFlat.new()
	focus_style.bg_color = Color.TRANSPARENT
	focus_style.border_color = Color.YELLOW
	focus_style.set_border_width_all(4)
	focus_style.set_corner_radius_all(4)
	
	theme.set_stylebox("focus", "Button", focus_style)
	theme.set_stylebox("focus", "LineEdit", focus_style)
	
	# Update metadata
	theme.set_meta("theme_name", "NeuroVision High Contrast")
	theme.set_meta("accessibility_level", "WCAG_AAA_ENHANCED")
	
	return theme

## Create colorblind-safe theme
static func _create_colorblind_theme() -> Theme:
	var theme = _create_dark_theme()  # Start with dark theme
	
	# Apply colorblind-safe colors
	var colorblind_colors = {
		"primary": Color("#0173B2"),      # Blue
		"secondary": Color("#DE8F05"),    # Orange  
		"tertiary": Color("#029E73"),     # Green
		"error": Color("#CC78BC"),        # Pink
		"success": Color("#029E73"),      # Green
		"warning": Color("#ECE133"),      # Yellow
		"info": Color("#56B4E9")          # Light blue
	}
	
	# Override brain structure colors with colorblind-safe variants
	var colorblind_brain_colors = {
		"hippocampus": Color("#0173B2"),   # Blue
		"amygdala": Color("#DE8F05"),      # Orange
		"cortex": Color("#029E73"),        # Green 
		"thalamus": Color("#56B4E9"),      # Light blue
		"cerebellum": Color("#ECE133"),    # Yellow
		"brainstem": Color("#CC78BC"),     # Pink
	}
	
	# Apply colorblind-safe brain structure colors
	for structure_name in colorblind_brain_colors:
		var color = colorblind_brain_colors[structure_name]
		theme.set_color(structure_name + "_color", "BrainStructure", color)
	
	# Update metadata
	theme.set_meta("theme_name", "NeuroVision Colorblind Safe")
	theme.set_meta("colorblind_safe", true)
	
	return theme

# === STYLING HELPER METHODS ===

static func _setup_button_styles(theme: Theme, colors: Dictionary, corners: Dictionary, spacing: Dictionary) -> void:
	# Primary button (normal state)
	var button_normal = StyleBoxFlat.new()
	button_normal.bg_color = colors["primary"]
	button_normal.set_corner_radius_all(corners["button"])
	button_normal.content_margin_left = spacing["button_padding"]
	button_normal.content_margin_right = spacing["button_padding"]
	button_normal.content_margin_top = spacing["small"]
	button_normal.content_margin_bottom = spacing["small"]
	
	theme.set_stylebox("normal", "Button", button_normal)
	
	# Button hover state
	var button_hover = button_normal.duplicate()
	button_hover.bg_color = colors["primary"].lightened(0.1)
	theme.set_stylebox("hover", "Button", button_hover)
	
	# Button pressed state
	var button_pressed = button_normal.duplicate()
	button_pressed.bg_color = colors["primary"].darkened(0.1)
	theme.set_stylebox("pressed", "Button", button_pressed)
	
	# Button disabled state
	var button_disabled = button_normal.duplicate()
	button_disabled.bg_color = colors["on_surface"]
	button_disabled.bg_color.a = 0.38
	theme.set_stylebox("disabled", "Button", button_disabled)
	
	# Button colors
	theme.set_color("font_color", "Button", colors["on_primary"])
	theme.set_color("font_hover_color", "Button", colors["on_primary"])
	theme.set_color("font_pressed_color", "Button", colors["on_primary"])
	theme.set_color("font_disabled_color", "Button", colors["on_primary"].darkened(0.6))

static func _setup_panel_styles(theme: Theme, colors: Dictionary, corners: Dictionary, spacing: Dictionary) -> void:
	# Main panel style
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = colors["surface_container"]
	panel_style.set_corner_radius_all(corners["card"])
	panel_style.border_color = colors["outline_variant"]
	panel_style.set_border_width_all(1)
	panel_style.content_margin_left = spacing["card_padding"]
	panel_style.content_margin_right = spacing["card_padding"]
	panel_style.content_margin_top = spacing["card_padding"]
	panel_style.content_margin_bottom = spacing["card_padding"]
	
	theme.set_stylebox("panel", "Panel", panel_style)
	theme.set_stylebox("panel", "PanelContainer", panel_style)

static func _setup_text_styles(theme: Theme, colors: Dictionary) -> void:
	# Label colors
	theme.set_color("font_color", "Label", colors["on_surface"])
	theme.set_color("font_shadow_color", "Label", colors["shadow"])
	
	# RichTextLabel colors
	theme.set_color("default_color", "RichTextLabel", colors["on_surface"])
	theme.set_color("selection_color", "RichTextLabel", colors["primary"])

static func _setup_educational_styles(theme: Theme, colors: Dictionary, corners: Dictionary, spacing: Dictionary) -> void:
	# Educational info panel
	var info_panel_style = StyleBoxFlat.new()
	info_panel_style.bg_color = colors["surface_container_high"]
	info_panel_style.set_corner_radius_all(corners["large"])
	info_panel_style.border_color = colors["primary"]
	info_panel_style.set_border_width_all(2)
	info_panel_style.content_margin_left = spacing["large"]
	info_panel_style.content_margin_right = spacing["large"]
	info_panel_style.content_margin_top = spacing["large"]
	info_panel_style.content_margin_bottom = spacing["large"]
	
	theme.set_stylebox("info_panel", "EducationalPanel", info_panel_style)
	
	# Quiz panel
	var quiz_panel_style = StyleBoxFlat.new()
	quiz_panel_style.bg_color = colors["surface_container"]
	quiz_panel_style.set_corner_radius_all(corners["medium"])
	quiz_panel_style.border_color = colors["secondary"]
	quiz_panel_style.set_border_width_all(1)
	
	theme.set_stylebox("quiz_panel", "EducationalPanel", quiz_panel_style)
	
	# Educational colors
	theme.set_color("structure_label_color", "Educational", colors["on_surface"])
	theme.set_color("clinical_note_color", "Educational", colors["tertiary"])
	theme.set_color("learning_objective_color", "Educational", colors["secondary"])
	theme.set_color("assessment_feedback_color", "Educational", colors["success"])

static func _setup_brain_structure_colors(theme: Theme) -> void:
	var brain_colors = M3DesignTokens.BRAIN_STRUCTURE_COLORS
	
	for structure_name in brain_colors:
		var color = brain_colors[structure_name]
		theme.set_color(structure_name + "_color", "BrainStructure", color)
		
		# Create highlight style for each structure
		var highlight_style = StyleBoxFlat.new()
		highlight_style.bg_color = color
		highlight_style.bg_color.a = 0.3
		highlight_style.set_corner_radius_all(8)
		highlight_style.border_color = color
		highlight_style.set_border_width_all(2)
		
		theme.set_stylebox(structure_name + "_highlight", "BrainStructure", highlight_style)

static func _save_theme_resource(theme: Theme, file_path: String) -> bool:
	if not theme:
		push_error("Cannot save null theme to: " + file_path)
		return false
	
	var result = ResourceSaver.save(theme, file_path)
	if result != OK:
		push_error("Failed to save theme to: " + file_path + " (Error: " + str(result) + ")")
		return false
	
	return true