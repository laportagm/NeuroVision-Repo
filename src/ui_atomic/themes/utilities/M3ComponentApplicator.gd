## Material 3 Component Applicator for NeuroVision
## Provides centralized Material 3 styling for UI components
##
## This class applies Material You design system styling to Godot UI components,
## ensuring consistent appearance across the educational platform.

class_name M3ComponentApplicator
extends RefCounted

# === ENUMS ===
enum PanelVariant {
	SURFACE,
	SURFACE_VARIANT,
	SURFACE_CONTAINER,
	GLASS,
	MODAL,
	CARD
}

enum ButtonVariant {
	PRIMARY,
	SECONDARY,
	TERTIARY,
	ICON,
	FAB
}

enum TypographyScale {
	DISPLAY_LARGE,
	DISPLAY_MEDIUM,
	DISPLAY_SMALL,
	HEADLINE_LARGE,
	HEADLINE_MEDIUM,
	HEADLINE_SMALL,
	TITLE_LARGE,
	TITLE_MEDIUM,
	TITLE_SMALL,
	BODY_LARGE,
	BODY_MEDIUM,
	BODY_SMALL,
	LABEL_LARGE,
	LABEL_MEDIUM,
	LABEL_SMALL
}

# === PANEL STYLING ===

## Apply Material 3 panel styling
static func apply_m3_panel_styling(panel: Control, variant: PanelVariant = PanelVariant.SURFACE) -> void:
	"""Apply Material 3 styling to panel-based components"""
	if not panel:
		push_error("[M3ComponentApplicator] Cannot style null panel")
		return
	
	var style = StyleBoxFlat.new()
	var colors = M3DesignTokens.M3_COLORS
	var corners = M3DesignTokens.M3_CORNER_RADIUS
	var spacing = M3DesignTokens.M3_SPACING
	
	# Configure based on variant
	match variant:
		PanelVariant.SURFACE:
			style.bg_color = colors["surface"]
			style.set_corner_radius_all(corners["medium"])
		
		PanelVariant.SURFACE_VARIANT:
			style.bg_color = colors["surface_variant"]
			style.set_corner_radius_all(corners["medium"])
		
		PanelVariant.SURFACE_CONTAINER:
			style.bg_color = colors["surface_container"]
			style.set_corner_radius_all(corners["large"])
			_add_elevation(style, M3DesignTokens.M3_ELEVATION["card"])
		
		PanelVariant.GLASS:
			style.bg_color = colors["surface"]
			style.bg_color.a = M3DesignTokens.M3_OPACITY["glass"]
			style.set_corner_radius_all(corners["large"])
			# Add subtle border for glass effect
			style.border_color = colors["outline_variant"]
			style.border_color.a = 0.3
			style.set_border_width_all(1)
		
		PanelVariant.MODAL:
			style.bg_color = colors["surface_container_highest"]
			style.set_corner_radius_all(corners["extra_large"])
			_add_elevation(style, M3DesignTokens.M3_ELEVATION["modal"])
		
		PanelVariant.CARD:
			style.bg_color = colors["surface_container"]
			style.set_corner_radius_all(corners["large"])
			_add_elevation(style, M3DesignTokens.M3_ELEVATION["card"])
			# Add border
			style.border_color = colors["outline_variant"]
			style.set_border_width_all(1)
	
	# Apply content margins
	style.set_content_margin_all(spacing["medium"])
	
	# Apply to control
	if panel is Panel or panel is PanelContainer:
		panel.add_theme_stylebox_override("panel", style)
	elif panel.has_method("add_theme_stylebox_override"):
		# Try to apply even if not a Panel - some controls support panel override
		panel.add_theme_stylebox_override("panel", style)

# === BUTTON STYLING ===

## Apply Material 3 button styling
static func apply_m3_button_styling(button: Button, variant: ButtonVariant = ButtonVariant.PRIMARY) -> void:
	"""Apply Material 3 styling to button components"""
	if not button:
		push_error("[M3ComponentApplicator] Cannot style null button")
		return
	
	var colors = M3DesignTokens.M3_COLORS
	var corners = M3DesignTokens.M3_CORNER_RADIUS
	var spacing = M3DesignTokens.M3_SPACING
	var type_scale = M3DesignTokens.M3_TYPE_SCALE
	
	# Create styles for different states
	var normal_style = StyleBoxFlat.new()
	var hover_style = StyleBoxFlat.new()
	var pressed_style = StyleBoxFlat.new()
	var disabled_style = StyleBoxFlat.new()
	var focus_style = StyleBoxFlat.new()
	
	# Configure based on variant
	match variant:
		ButtonVariant.PRIMARY:
			# Normal state
			normal_style.bg_color = colors["primary"]
			normal_style.set_corner_radius_all(corners["button"])
			_add_elevation(normal_style, M3DesignTokens.M3_ELEVATION["button"])
			
			# Text color
			button.add_theme_color_override("font_color", colors["on_primary"])
			button.add_theme_color_override("font_hover_color", colors["on_primary"])
			button.add_theme_color_override("font_pressed_color", colors["on_primary"])
			button.add_theme_color_override("font_disabled_color", colors["on_primary"])
			
			# Hover state
			hover_style = normal_style.duplicate()
			hover_style.bg_color = colors["primary"].lightened(0.08)
			
			# Pressed state
			pressed_style = normal_style.duplicate()
			pressed_style.bg_color = colors["primary"].darkened(0.12)
			_reduce_elevation(pressed_style)
			
		ButtonVariant.SECONDARY:
			# Normal state
			normal_style.bg_color = colors["secondary_container"]
			normal_style.set_corner_radius_all(corners["button"])
			_add_elevation(normal_style, M3DesignTokens.M3_ELEVATION["button"] - 1)
			
			# Text color
			button.add_theme_color_override("font_color", colors["on_secondary_container"])
			button.add_theme_color_override("font_hover_color", colors["on_secondary_container"])
			button.add_theme_color_override("font_pressed_color", colors["on_secondary_container"])
			button.add_theme_color_override("font_disabled_color", colors["on_secondary_container"])
			
			# Hover state
			hover_style = normal_style.duplicate()
			hover_style.bg_color = colors["secondary_container"].lightened(0.08)
			
			# Pressed state
			pressed_style = normal_style.duplicate()
			pressed_style.bg_color = colors["secondary_container"].darkened(0.12)
			
		ButtonVariant.TERTIARY:
			# Normal state - outlined button
			normal_style.bg_color = Color.TRANSPARENT
			normal_style.border_color = colors["outline"]
			normal_style.set_border_width_all(1)
			normal_style.set_corner_radius_all(corners["button"])
			
			# Text color
			button.add_theme_color_override("font_color", colors["primary"])
			button.add_theme_color_override("font_hover_color", colors["primary"])
			button.add_theme_color_override("font_pressed_color", colors["primary"])
			
			# Hover state
			hover_style = normal_style.duplicate()
			hover_style.bg_color = colors["primary"]
			hover_style.bg_color.a = M3DesignTokens.M3_OPACITY["hover"]
			
			# Pressed state
			pressed_style = normal_style.duplicate()
			pressed_style.bg_color = colors["primary"]
			pressed_style.bg_color.a = M3DesignTokens.M3_OPACITY["pressed"]
			
		ButtonVariant.ICON:
			# Icon button - circular/square with minimal styling
			var icon_size = M3DesignTokens.M3_SPACING["extra_large"]
			button.custom_minimum_size = Vector2(icon_size, icon_size)
			
			normal_style.bg_color = Color.TRANSPARENT
			normal_style.set_corner_radius_all(corners["full"])
			
			# Hover state
			hover_style = normal_style.duplicate()
			hover_style.bg_color = colors["on_surface"]
			hover_style.bg_color.a = M3DesignTokens.M3_OPACITY["hover"]
			
			# Pressed state
			pressed_style = normal_style.duplicate()
			pressed_style.bg_color = colors["on_surface"]
			pressed_style.bg_color.a = M3DesignTokens.M3_OPACITY["pressed"]
			
			# Text color
			button.add_theme_color_override("font_color", colors["on_surface"])
			
		ButtonVariant.FAB:
			# Floating Action Button
			normal_style.bg_color = colors["primary_container"]
			normal_style.set_corner_radius_all(corners["large"])
			_add_elevation(normal_style, M3DesignTokens.M3_ELEVATION["level3"])
			
			# Larger size
			button.custom_minimum_size = Vector2(56, 56)
			
			# Text color
			button.add_theme_color_override("font_color", colors["on_primary_container"])
			
			# Hover state
			hover_style = normal_style.duplicate()
			hover_style.bg_color = colors["primary_container"].lightened(0.08)
			_add_elevation(hover_style, M3DesignTokens.M3_ELEVATION["level4"])
			
			# Pressed state
			pressed_style = normal_style.duplicate()
			pressed_style.bg_color = colors["primary_container"].darkened(0.12)
			_add_elevation(pressed_style, M3DesignTokens.M3_ELEVATION["level2"])
	
	# Disabled state (common for all variants)
	disabled_style.bg_color = colors["on_surface"]
	disabled_style.bg_color.a = M3DesignTokens.M3_OPACITY["disabled"]
	disabled_style.set_corner_radius_all(corners["button"])
	button.add_theme_color_override("font_disabled_color", colors["on_surface"])
	
	# Focus state (accessibility)
	focus_style = normal_style.duplicate()
	focus_style.border_color = colors["primary"]
	focus_style.set_border_width_all(M3DesignTokens.M3_ACCESSIBILITY["focus_indicator_width"])
	
	# Apply padding
	for style in [normal_style, hover_style, pressed_style, disabled_style, focus_style]:
		style.set_content_margin_all(spacing["button_padding"])
	
	# Apply styles to button
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("disabled", disabled_style)
	button.add_theme_stylebox_override("focus", focus_style)
	
	# Apply typography
	button.add_theme_font_size_override("font_size", type_scale["label_large"]["size"])

# === TEXT STYLING ===

## Apply Material 3 text styling
static func apply_m3_text_styling(label: Control, scale: TypographyScale = TypographyScale.BODY_MEDIUM) -> void:
	"""Apply Material 3 typography to text components"""
	if not label:
		push_error("[M3ComponentApplicator] Cannot style null label")
		return
	
	var type_scale = M3DesignTokens.M3_TYPE_SCALE
	var scale_key = _get_typography_scale_key(scale)
	
	if not scale_key in type_scale:
		push_error("[M3ComponentApplicator] Invalid typography scale")
		return
	
	var type_spec = type_scale[scale_key]
	
	# Apply font size
	if label is Label:
		label.add_theme_font_size_override("font_size", type_spec["size"])
	elif label is RichTextLabel:
		label.add_theme_font_size_override("normal_font_size", type_spec["size"])
		label.add_theme_font_size_override("bold_font_size", type_spec["size"])
	
	# Set line spacing if applicable
	if "line_height" in type_spec and label is RichTextLabel:
		var line_spacing = type_spec["line_height"] - type_spec["size"]
		label.add_theme_constant_override("line_separation", line_spacing)

# === HELPER METHODS ===

static func _add_elevation(style: StyleBoxFlat, level: int) -> void:
	"""Add elevation shadow to style"""
	var shadow = M3DesignTokens.get_elevation_shadow(level)
	style.shadow_color = shadow["color"]
	style.shadow_size = int(shadow["blur"])
	style.shadow_offset = shadow["offset"]

static func _reduce_elevation(style: StyleBoxFlat) -> void:
	"""Reduce elevation for pressed states"""
	style.shadow_size = int(style.shadow_size * 0.5)
	style.shadow_offset = style.shadow_offset * 0.5

static func _get_typography_scale_key(scale: TypographyScale) -> String:
	"""Convert enum to string key"""
	match scale:
		TypographyScale.DISPLAY_LARGE: return "display_large"
		TypographyScale.DISPLAY_MEDIUM: return "display_medium"
		TypographyScale.DISPLAY_SMALL: return "display_small"
		TypographyScale.HEADLINE_LARGE: return "headline_large"
		TypographyScale.HEADLINE_MEDIUM: return "headline_medium"
		TypographyScale.HEADLINE_SMALL: return "headline_small"
		TypographyScale.TITLE_LARGE: return "title_large"
		TypographyScale.TITLE_MEDIUM: return "title_medium"
		TypographyScale.TITLE_SMALL: return "title_small"
		TypographyScale.BODY_LARGE: return "body_large"
		TypographyScale.BODY_MEDIUM: return "body_medium"
		TypographyScale.BODY_SMALL: return "body_small"
		TypographyScale.LABEL_LARGE: return "label_large"
		TypographyScale.LABEL_MEDIUM: return "label_medium"
		TypographyScale.LABEL_SMALL: return "label_small"
		_: return "body_medium"

# === CONVENIENCE METHODS ===

## Apply full Material 3 theme to a control tree
static func apply_m3_theme_to_tree(root: Control) -> void:
	"""Recursively apply Material 3 styling to control tree"""
	if not root:
		return
	
	# Style based on control type
	if root is PanelContainer or root is Panel:
		apply_m3_panel_styling(root)
	elif root is Button:
		apply_m3_button_styling(root)
	elif root is Label or root is RichTextLabel:
		apply_m3_text_styling(root)
	
	# Recurse to children
	for child in root.get_children():
		if child is Control:
			apply_m3_theme_to_tree(child)

## Create a styled M3 button
static func create_m3_button(text: String, variant: ButtonVariant = ButtonVariant.PRIMARY) -> Button:
	"""Create a new button with Material 3 styling"""
	var button = Button.new()
	button.text = text
	apply_m3_button_styling(button, variant)
	return button

## Create a styled M3 panel
static func create_m3_panel(variant: PanelVariant = PanelVariant.SURFACE) -> PanelContainer:
	"""Create a new panel with Material 3 styling"""
	var panel = PanelContainer.new()
	apply_m3_panel_styling(panel, variant)
	return panel