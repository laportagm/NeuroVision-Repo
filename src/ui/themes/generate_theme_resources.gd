extends Node

## Script to generate .tres theme files from M3DesignTokens
## Run this to update all theme files with proper color token references

func _ready():
	print("\n========== THEME RESOURCE GENERATION ==========")
	
	# Generate standard themes
	_generate_dark_theme()
	_generate_high_contrast_theme()
	_generate_colorblind_theme()
	
	print("\n✅ Theme generation complete!")
	get_tree().quit()

func _generate_dark_theme():
	print("\nGenerating Dark Theme...")
	
	var theme = Theme.new()
	
	# Button styles
	var button_normal = _create_button_style("primary", "on_primary")
	var button_hover = _create_button_style("primary_container", "on_primary_container")
	var button_pressed = _create_button_style("primary", "on_primary", 0.8)
	var button_disabled = _create_button_style("surface_variant", "on_surface", 0.38)
	
	theme.set_stylebox("normal", "Button", button_normal)
	theme.set_stylebox("hover", "Button", button_hover)
	theme.set_stylebox("pressed", "Button", button_pressed)
	theme.set_stylebox("disabled", "Button", button_disabled)
	
	# Panel styles
	var panel_style = _create_panel_style("surface", 0.95)
	theme.set_stylebox("panel", "Panel", panel_style)
	
	# LineEdit styles
	var line_edit_normal = _create_line_edit_style("surface_variant")
	var line_edit_focus = _create_line_edit_style("surface_variant", "primary")
	theme.set_stylebox("normal", "LineEdit", line_edit_normal)
	theme.set_stylebox("focus", "LineEdit", line_edit_focus)
	
	# Label colors
	theme.set_color("font_color", "Label", M3DesignTokens.get_color("on_surface"))
	theme.set_color("font_shadow_color", "Label", M3DesignTokens.get_color("shadow"))
	
	# Font settings
	theme.set_font_size("font_size", "Label", 16)
	theme.set_font_size("font_size", "Button", 16)
	
	# Save theme
	ResourceSaver.save(theme, "res://src/ui/themes/themes/DarkTheme.tres")
	print("✓ Dark theme saved")

func _generate_high_contrast_theme():
	print("\nGenerating High Contrast Theme...")
	
	var theme = Theme.new()
	
	# High contrast button styles
	var button_normal = _create_button_style("surface", "on_surface", 1.0, true)
	var button_hover = _create_button_style("primary", "on_primary")
	var button_pressed = _create_button_style("primary_container", "on_primary_container")
	var button_disabled = _create_button_style("surface_dim", "on_surface", 0.5)
	
	theme.set_stylebox("normal", "Button", button_normal)
	theme.set_stylebox("hover", "Button", button_hover)
	theme.set_stylebox("pressed", "Button", button_pressed)
	theme.set_stylebox("disabled", "Button", button_disabled)
	
	# High contrast panel
	var panel_style = _create_panel_style("background", 1.0, true)
	theme.set_stylebox("panel", "Panel", panel_style)
	
	# High contrast text
	theme.set_color("font_color", "Label", M3DesignTokens.get_color("on_surface"))
	theme.set_color("font_outline_color", "Label", M3DesignTokens.get_color("outline"))
	theme.set_constant("outline_size", "Label", 2)
	
	# Larger fonts for readability
	theme.set_font_size("font_size", "Label", 18)
	theme.set_font_size("font_size", "Button", 18)
	
	# Save theme
	ResourceSaver.save(theme, "res://src/ui/themes/themes/HighContrastTheme.tres")
	print("✓ High contrast theme saved")

func _generate_colorblind_theme():
	print("\nGenerating Colorblind Theme...")
	
	var theme = Theme.new()
	
	# Colorblind-safe button styles (using patterns and high contrast)
	var button_normal = _create_button_style("surface_variant", "on_surface_variant")
	var button_hover = _create_button_style("secondary_container", "on_secondary_container")
	var button_pressed = _create_button_style("secondary", "on_secondary")
	var button_disabled = _create_button_style("surface_dim", "on_surface", 0.38)
	
	theme.set_stylebox("normal", "Button", button_normal)
	theme.set_stylebox("hover", "Button", button_hover)
	theme.set_stylebox("pressed", "Button", button_pressed)
	theme.set_stylebox("disabled", "Button", button_disabled)
	
	# Colorblind-safe panel
	var panel_style = _create_panel_style("surface", 0.98)
	theme.set_stylebox("panel", "Panel", panel_style)
	
	# High contrast text for colorblind users
	theme.set_color("font_color", "Label", M3DesignTokens.get_color("on_surface"))
	theme.set_color("font_shadow_color", "Label", M3DesignTokens.get_color("shadow"))
	
	# Standard fonts
	theme.set_font_size("font_size", "Label", 16)
	theme.set_font_size("font_size", "Button", 16)
	
	# Save theme
	ResourceSaver.save(theme, "res://src/ui/themes/themes/ColorblindTheme.tres")
	print("✓ Colorblind theme saved")

# Helper functions to create styles

func _create_button_style(bg_token: String, fg_token: String, opacity: float = 1.0, with_border: bool = false) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	
	# Background color
	var bg_color = M3DesignTokens.get_color(bg_token)
	bg_color.a *= opacity
	style.bg_color = bg_color
	
	# Rounded corners
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	
	# Padding
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	
	# Optional border
	if with_border:
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = M3DesignTokens.get_color("outline")
	
	return style

func _create_panel_style(bg_token: String, opacity: float = 1.0, with_border: bool = false) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	
	# Background color
	var bg_color = M3DesignTokens.get_color(bg_token)
	bg_color.a *= opacity
	style.bg_color = bg_color
	
	# Rounded corners
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	
	# Padding
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	
	# Optional border
	if with_border:
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_width_top = 1
		style.border_width_bottom = 1
		style.border_color = M3DesignTokens.get_color("outline_variant")
	
	# Shadow
	style.shadow_size = 4
	style.shadow_color = M3DesignTokens.get_color("shadow")
	
	return style

func _create_line_edit_style(bg_token: String, border_token: String = "outline_variant") -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	
	# Background
	style.bg_color = M3DesignTokens.get_color(bg_token)
	
	# Border
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = M3DesignTokens.get_color(border_token)
	
	# Rounded corners
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	
	# Padding
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	
	return style