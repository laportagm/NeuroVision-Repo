extends Node

## Apply NeuroVision M3 Theme Colors to UI
## This script ensures all UI components use the updated color palette

static func apply_neurovision_theme_to_scene(scene_root: Node) -> void:
	"""Apply the NeuroVision color theme to all UI elements in a scene"""
	print("[NeuroVisionTheme] Applying updated color palette to UI")
	
	# Apply to all Controls recursively
	_apply_to_node_recursive(scene_root)
	
	print("[NeuroVisionTheme] Theme application complete")

static func _apply_to_node_recursive(node: Node) -> void:
	"""Recursively apply theme to all nodes"""
	
	# Panel containers - use surface hierarchy
	if node is PanelContainer:
		_apply_panel_theme(node as PanelContainer)
	
	# Labels - use on_surface colors
	elif node is Label:
		_apply_label_theme(node as Label)
	
	# Rich text labels
	elif node is RichTextLabel:
		_apply_rich_text_theme(node as RichTextLabel)
	
	# Buttons - use primary colors
	elif node is Button:
		_apply_button_theme(node as Button)
	
	# Line edits
	elif node is LineEdit:
		_apply_line_edit_theme(node as LineEdit)
	
	# Progress bars
	elif node is ProgressBar:
		_apply_progress_bar_theme(node as ProgressBar)
	
	# Separators
	elif node is HSeparator or node is VSeparator:
		_apply_separator_theme(node)
	
	# Color rects (overlays)
	elif node is ColorRect:
		_apply_color_rect_theme(node as ColorRect)
	
	# Recurse to children
	for child in node.get_children():
		_apply_to_node_recursive(child)

static func _apply_panel_theme(panel: PanelContainer) -> void:
	"""Apply surface hierarchy colors to panels"""
	var style = StyleBoxFlat.new()
	
	# Determine surface level based on node name or hierarchy
	var surface_color: Color
	if "overlay" in panel.name.to_lower() or "modal" in panel.name.to_lower():
		surface_color = M3DesignTokens.get_color("surface_container_highest")
		style.shadow_size = 8
	elif "card" in panel.name.to_lower():
		surface_color = M3DesignTokens.get_color("surface_bright")
		style.shadow_size = 2
	elif "container" in panel.name.to_lower():
		surface_color = M3DesignTokens.get_color("surface_container")
	else:
		surface_color = M3DesignTokens.get_color("surface_variant")
	
	style.bg_color = surface_color
	style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["medium"])
	style.set_content_margin_all(M3DesignTokens.M3_SPACING["medium"])
	
	# Add subtle border
	style.border_color = M3DesignTokens.get_color("outline_variant")
	style.border_color.a = 0.3
	style.set_border_width_all(1)
	
	# Shadow
	style.shadow_color = M3DesignTokens.get_color("shadow")
	
	panel.add_theme_stylebox_override("panel", style)

static func _apply_label_theme(label: Label) -> void:
	"""Apply text colors to labels"""
	# Determine text importance
	if "title" in label.name.to_lower() or "heading" in label.name.to_lower():
		label.add_theme_color_override("font_color", M3DesignTokens.get_color("primary"))
	elif "hint" in label.name.to_lower() or "description" in label.name.to_lower():
		label.add_theme_color_override("font_color", M3DesignTokens.get_color("on_surface_variant"))
	elif "error" in label.name.to_lower():
		label.add_theme_color_override("font_color", M3DesignTokens.get_color("error"))
	elif "success" in label.name.to_lower():
		label.add_theme_color_override("font_color", M3DesignTokens.get_color("success"))
	else:
		label.add_theme_color_override("font_color", M3DesignTokens.get_color("on_surface"))
	
	# Shadow for better readability
	label.add_theme_color_override("font_shadow_color", M3DesignTokens.get_color("shadow"))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)

static func _apply_button_theme(button: Button) -> void:
	"""Apply button styling with NeuroVision colors"""
	# Normal state
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = M3DesignTokens.get_color("primary")
	style_normal.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["button"])
	style_normal.set_content_margin_all(M3DesignTokens.M3_SPACING["medium"])
	
	# Hover state
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = M3DesignTokens.get_color("primary_container")
	style_hover.border_color = M3DesignTokens.get_color("primary")
	style_hover.set_border_width_all(2)
	
	# Pressed state
	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = M3DesignTokens.get_color("primary").darkened(0.2)
	
	# Disabled state
	var style_disabled = style_normal.duplicate()
	style_disabled.bg_color = M3DesignTokens.get_color("surface_variant")
	style_disabled.bg_color.a = 0.38
	
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)
	button.add_theme_stylebox_override("disabled", style_disabled)
	
	# Text color
	button.add_theme_color_override("font_color", M3DesignTokens.get_color("on_primary"))
	button.add_theme_color_override("font_hover_color", M3DesignTokens.get_color("on_primary_container"))
	button.add_theme_color_override("font_pressed_color", M3DesignTokens.get_color("on_primary"))
	button.add_theme_color_override("font_disabled_color", M3DesignTokens.get_color("on_surface_variant"))

static func _apply_line_edit_theme(line_edit: LineEdit) -> void:
	"""Apply text field styling"""
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = M3DesignTokens.get_color("surface_bright")
	style_normal.border_color = M3DesignTokens.get_color("outline")
	style_normal.set_border_width_all(1)
	style_normal.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["text_field"])
	style_normal.set_content_margin_all(M3DesignTokens.M3_SPACING["small"])
	
	var style_focus = style_normal.duplicate()
	style_focus.border_color = M3DesignTokens.get_color("primary")
	style_focus.set_border_width_all(2)
	
	line_edit.add_theme_stylebox_override("normal", style_normal)
	line_edit.add_theme_stylebox_override("focus", style_focus)
	line_edit.add_theme_color_override("font_color", M3DesignTokens.get_color("on_surface"))
	line_edit.add_theme_color_override("font_placeholder_color", M3DesignTokens.get_color("on_surface_variant"))

static func _apply_progress_bar_theme(progress_bar: ProgressBar) -> void:
	"""Apply progress bar styling"""
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = M3DesignTokens.get_color("surface_variant")
	bg_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["full"])
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = M3DesignTokens.get_color("primary")
	fill_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["full"])
	
	progress_bar.add_theme_stylebox_override("background", bg_style)
	progress_bar.add_theme_stylebox_override("fill", fill_style)

static func _apply_separator_theme(separator: Control) -> void:
	"""Apply separator styling"""
	separator.add_theme_color_override("color", M3DesignTokens.get_color("outline_variant"))

static func _apply_color_rect_theme(rect: ColorRect) -> void:
	"""Apply color to overlays and backgrounds"""
	if "loading" in rect.name.to_lower() or "overlay" in rect.name.to_lower():
		rect.color = M3DesignTokens.get_color("scrim")
	elif "background" in rect.name.to_lower():
		rect.color = M3DesignTokens.get_color("background_start")

static func _apply_rich_text_theme(rtl: RichTextLabel) -> void:
	"""Apply rich text label styling"""
	rtl.add_theme_color_override("default_color", M3DesignTokens.get_color("on_surface"))
	rtl.add_theme_color_override("font_shadow_color", M3DesignTokens.get_color("shadow"))
	rtl.add_theme_constant_override("shadow_offset_x", 1)
	rtl.add_theme_constant_override("shadow_offset_y", 1)