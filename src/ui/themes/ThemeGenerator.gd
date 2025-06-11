class_name ThemeGenerator
extends RefCounted

## Dynamic theme generation utility for NeuroVis
## Creates consistent themes based on design tokens

# === STATIC METHODS ===

static func generate_theme(base_name: String = "dark") -> Theme:
	"""Generate a complete theme based on design tokens"""
	var theme = Theme.new()
	
	# Set theme colors based on base
	var colors = _get_color_scheme(base_name)
	
	# Generate all component styles
	_generate_button_styles(theme, colors)
	_generate_panel_styles(theme, colors)
	_generate_label_styles(theme, colors)
	_generate_line_edit_styles(theme, colors)
	_generate_option_button_styles(theme, colors)
	_generate_tab_styles(theme, colors)
	_generate_scroll_styles(theme, colors)
	_generate_slider_styles(theme, colors)
	_generate_checkbox_styles(theme, colors)
	_generate_tooltip_styles(theme, colors)
	
	# Set global theme properties
	_set_global_properties(theme, colors)
	
	return theme

static func _get_color_scheme(base_name: String) -> Dictionary:
	"""Get color scheme for theme base"""
	var scheme = {}
	
	match base_name:
		"dark":
			scheme = {
				"bg_primary": DesignTokens.COLORS.background.primary,
				"bg_secondary": DesignTokens.COLORS.background.secondary,
				"bg_tertiary": DesignTokens.COLORS.background.tertiary,
				"accent": DesignTokens.COLORS.accent.primary,
				"text_primary": DesignTokens.COLORS.text.primary,
				"text_secondary": DesignTokens.COLORS.text.secondary,
				"border": DesignTokens.COLORS.border.default,
				"border_hover": DesignTokens.COLORS.border.hover
			}
		"high_contrast":
			scheme = {
				"bg_primary": Color.BLACK,
				"bg_secondary": Color("#0A0A0A"),
				"bg_tertiary": Color("#1A1A1A"),
				"accent": Color("#00FF00"),
				"text_primary": Color.WHITE,
				"text_secondary": Color("#CCCCCC"),
				"border": Color.WHITE,
				"border_hover": Color("#00FF00")
			}
		"colorblind":
			scheme = {
				"bg_primary": DesignTokens.COLORS.background.primary,
				"bg_secondary": DesignTokens.COLORS.background.secondary,
				"bg_tertiary": DesignTokens.COLORS.background.tertiary,
				"accent": Color("#0099FF"),  # Blue instead of cyan
				"text_primary": DesignTokens.COLORS.text.primary,
				"text_secondary": DesignTokens.COLORS.text.secondary,
				"border": DesignTokens.COLORS.border.default,
				"border_hover": Color("#0099FF")
			}
		_:
			scheme = _get_color_scheme("dark")  # Default to dark
			
	return scheme

static func _generate_button_styles(theme: Theme, colors: Dictionary) -> void:
	"""Generate button styles"""
	# Normal state
	var button_normal = StyleBoxFlat.new()
	button_normal.bg_color = Color(1, 1, 1, 0.05)
	button_normal.corner_radius_top_left = DesignTokens.BORDERS.radius.md
	button_normal.corner_radius_top_right = DesignTokens.BORDERS.radius.md
	button_normal.corner_radius_bottom_left = DesignTokens.BORDERS.radius.md
	button_normal.corner_radius_bottom_right = DesignTokens.BORDERS.radius.md
	button_normal.border_color = colors.border
	button_normal.border_width_left = 1
	button_normal.border_width_top = 1
	button_normal.border_width_right = 1
	button_normal.border_width_bottom = 1
	button_normal.content_margin_left = DesignTokens.SPACING.md
	button_normal.content_margin_right = DesignTokens.SPACING.md
	button_normal.content_margin_top = DesignTokens.SPACING.sm
	button_normal.content_margin_bottom = DesignTokens.SPACING.sm
	
	# Hover state
	var button_hover = button_normal.duplicate()
	button_hover.bg_color = Color(1, 1, 1, 0.1)
	button_hover.border_color = colors.accent
	
	# Pressed state
	var button_pressed = button_normal.duplicate()
	button_pressed.bg_color = colors.accent
	button_pressed.bg_color.a = 0.2
	button_pressed.border_color = colors.accent
	
	# Disabled state
	var button_disabled = button_normal.duplicate()
	button_disabled.bg_color = Color(1, 1, 1, 0.02)
	button_disabled.border_color = Color(1, 1, 1, 0.05)
	
	theme.set_stylebox("normal", "Button", button_normal)
	theme.set_stylebox("hover", "Button", button_hover)
	theme.set_stylebox("pressed", "Button", button_pressed)
	theme.set_stylebox("disabled", "Button", button_disabled)
	theme.set_stylebox("focus", "Button", button_hover)
	
	# Button colors
	theme.set_color("font_color", "Button", colors.text_primary)
	theme.set_color("font_hover_color", "Button", colors.accent)
	theme.set_color("font_pressed_color", "Button", colors.text_primary)
	theme.set_color("font_disabled_color", "Button", DesignTokens.COLORS.text.disabled)
	
	# Button font
	theme.set_font_size("font_size", "Button", DesignTokens.TYPOGRAPHY.button.size)

static func _generate_panel_styles(theme: Theme, colors: Dictionary) -> void:
	"""Generate panel styles"""
	# Default panel
	var panel = StyleBoxFlat.new()
	panel.bg_color = colors.bg_tertiary
	panel.corner_radius_top_left = DesignTokens.BORDERS.radius.lg
	panel.corner_radius_top_right = DesignTokens.BORDERS.radius.lg
	panel.corner_radius_bottom_left = DesignTokens.BORDERS.radius.lg
	panel.corner_radius_bottom_right = DesignTokens.BORDERS.radius.lg
	panel.border_color = colors.border
	panel.border_width_left = 1
	panel.border_width_top = 1
	panel.border_width_right = 1
	panel.border_width_bottom = 1
	panel.content_margin_left = DesignTokens.SPACING.lg
	panel.content_margin_right = DesignTokens.SPACING.lg
	panel.content_margin_top = DesignTokens.SPACING.lg
	panel.content_margin_bottom = DesignTokens.SPACING.lg
	panel.shadow_color = Color(0, 0, 0, 0.3)
	panel.shadow_size = 16
	panel.shadow_offset = Vector2(0, 8)
	
	theme.set_stylebox("panel", "Panel", panel)
	theme.set_stylebox("panel", "PanelContainer", panel)

static func _generate_label_styles(theme: Theme, colors: Dictionary) -> void:
	"""Generate label styles"""
	theme.set_color("font_color", "Label", colors.text_primary)
	theme.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0.5))
	theme.set_constant("shadow_offset_x", "Label", 0)
	theme.set_constant("shadow_offset_y", "Label", 1)
	theme.set_font_size("font_size", "Label", DesignTokens.TYPOGRAPHY.body.size)

static func _generate_line_edit_styles(theme: Theme, colors: Dictionary) -> void:
	"""Generate LineEdit styles"""
	var line_edit_normal = StyleBoxFlat.new()
	line_edit_normal.bg_color = Color(0, 0, 0, 0.3)
	line_edit_normal.corner_radius_top_left = DesignTokens.BORDERS.radius.sm
	line_edit_normal.corner_radius_top_right = DesignTokens.BORDERS.radius.sm
	line_edit_normal.corner_radius_bottom_left = DesignTokens.BORDERS.radius.sm
	line_edit_normal.corner_radius_bottom_right = DesignTokens.BORDERS.radius.sm
	line_edit_normal.border_color = colors.border
	line_edit_normal.border_width_left = 1
	line_edit_normal.border_width_top = 1
	line_edit_normal.border_width_right = 1
	line_edit_normal.border_width_bottom = 1
	line_edit_normal.content_margin_left = DesignTokens.SPACING.md
	line_edit_normal.content_margin_right = DesignTokens.SPACING.md
	line_edit_normal.content_margin_top = DesignTokens.SPACING.sm
	line_edit_normal.content_margin_bottom = DesignTokens.SPACING.sm
	
	var line_edit_focus = line_edit_normal.duplicate()
	line_edit_focus.border_color = colors.accent
	line_edit_focus.border_width_left = 2
	line_edit_focus.border_width_top = 2
	line_edit_focus.border_width_right = 2
	line_edit_focus.border_width_bottom = 2
	
	theme.set_stylebox("normal", "LineEdit", line_edit_normal)
	theme.set_stylebox("focus", "LineEdit", line_edit_focus)
	theme.set_stylebox("read_only", "LineEdit", line_edit_normal)
	
	theme.set_color("font_color", "LineEdit", colors.text_primary)
	theme.set_color("font_placeholder_color", "LineEdit", colors.text_secondary)
	theme.set_color("caret_color", "LineEdit", colors.accent)
	theme.set_color("selection_color", "LineEdit", colors.accent)
	theme.set_font_size("font_size", "LineEdit", DesignTokens.TYPOGRAPHY.body.size)

static func _generate_option_button_styles(theme: Theme, colors: Dictionary) -> void:
	"""Generate OptionButton styles"""
	# Reuse button styles for consistency
	var button_normal = theme.get_stylebox("normal", "Button")
	var button_hover = theme.get_stylebox("hover", "Button")
	var button_pressed = theme.get_stylebox("pressed", "Button")
	
	theme.set_stylebox("normal", "OptionButton", button_normal)
	theme.set_stylebox("hover", "OptionButton", button_hover)
	theme.set_stylebox("pressed", "OptionButton", button_pressed)
	theme.set_stylebox("disabled", "OptionButton", theme.get_stylebox("disabled", "Button"))
	theme.set_stylebox("focus", "OptionButton", button_hover)
	
	theme.set_color("font_color", "OptionButton", colors.text_primary)
	theme.set_color("font_hover_color", "OptionButton", colors.accent)
	theme.set_color("font_pressed_color", "OptionButton", colors.text_primary)
	theme.set_color("font_disabled_color", "OptionButton", DesignTokens.COLORS.text.disabled)
	theme.set_font_size("font_size", "OptionButton", DesignTokens.TYPOGRAPHY.body.size)

static func _generate_tab_styles(theme: Theme, colors: Dictionary) -> void:
	"""Generate Tab styles"""
	var tab_unselected = StyleBoxFlat.new()
	tab_unselected.bg_color = Color(1, 1, 1, 0.02)
	tab_unselected.corner_radius_top_left = DesignTokens.BORDERS.radius.md
	tab_unselected.corner_radius_top_right = DesignTokens.BORDERS.radius.md
	tab_unselected.content_margin_left = DesignTokens.SPACING.md
	tab_unselected.content_margin_right = DesignTokens.SPACING.md
	tab_unselected.content_margin_top = DesignTokens.SPACING.sm
	tab_unselected.content_margin_bottom = DesignTokens.SPACING.sm
	
	var tab_selected = tab_unselected.duplicate()
	tab_selected.bg_color = colors.accent
	tab_selected.bg_color.a = 0.1
	tab_selected.border_color = colors.accent
	tab_selected.border_width_bottom = 2
	
	theme.set_stylebox("tab_unselected", "TabContainer", tab_unselected)
	theme.set_stylebox("tab_selected", "TabContainer", tab_selected)
	theme.set_stylebox("tab_disabled", "TabContainer", tab_unselected)
	
	theme.set_color("font_unselected_color", "TabContainer", colors.text_secondary)
	theme.set_color("font_selected_color", "TabContainer", colors.accent)
	theme.set_color("font_disabled_color", "TabContainer", DesignTokens.COLORS.text.disabled)

static func _generate_scroll_styles(theme: Theme, colors: Dictionary) -> void:
	"""Generate ScrollBar styles"""
	var scrollbar_bg = StyleBoxFlat.new()
	scrollbar_bg.bg_color = Color(0, 0, 0, 0.2)
	scrollbar_bg.corner_radius_top_left = 4
	scrollbar_bg.corner_radius_top_right = 4
	scrollbar_bg.corner_radius_bottom_left = 4
	scrollbar_bg.corner_radius_bottom_right = 4
	
	var scrollbar_grabber = StyleBoxFlat.new()
	scrollbar_grabber.bg_color = Color(1, 1, 1, 0.3)
	scrollbar_grabber.corner_radius_top_left = 4
	scrollbar_grabber.corner_radius_top_right = 4
	scrollbar_grabber.corner_radius_bottom_left = 4
	scrollbar_grabber.corner_radius_bottom_right = 4
	
	var scrollbar_grabber_hover = scrollbar_grabber.duplicate()
	scrollbar_grabber_hover.bg_color = colors.accent
	scrollbar_grabber_hover.bg_color.a = 0.5
	
	theme.set_stylebox("scroll", "HScrollBar", scrollbar_bg)
	theme.set_stylebox("scroll", "VScrollBar", scrollbar_bg)
	theme.set_stylebox("grabber", "HScrollBar", scrollbar_grabber)
	theme.set_stylebox("grabber", "VScrollBar", scrollbar_grabber)
	theme.set_stylebox("grabber_highlight", "HScrollBar", scrollbar_grabber_hover)
	theme.set_stylebox("grabber_highlight", "VScrollBar", scrollbar_grabber_hover)
	theme.set_stylebox("grabber_pressed", "HScrollBar", scrollbar_grabber_hover)
	theme.set_stylebox("grabber_pressed", "VScrollBar", scrollbar_grabber_hover)

static func _generate_slider_styles(theme: Theme, colors: Dictionary) -> void:
	"""Generate Slider styles"""
	var slider_bg = StyleBoxFlat.new()
	slider_bg.bg_color = Color(1, 1, 1, 0.1)
	slider_bg.corner_radius_top_left = 2
	slider_bg.corner_radius_top_right = 2
	slider_bg.corner_radius_bottom_left = 2
	slider_bg.corner_radius_bottom_right = 2
	slider_bg.content_margin_top = 4
	slider_bg.content_margin_bottom = 4
	
	var slider_grabber = StyleBoxFlat.new()
	slider_grabber.bg_color = colors.accent
	slider_grabber.corner_radius_top_left = 8
	slider_grabber.corner_radius_top_right = 8
	slider_grabber.corner_radius_bottom_left = 8
	slider_grabber.corner_radius_bottom_right = 8
	slider_grabber.content_margin_left = 8
	slider_grabber.content_margin_right = 8
	slider_grabber.content_margin_top = 8
	slider_grabber.content_margin_bottom = 8
	
	theme.set_stylebox("slider", "HSlider", slider_bg)
	theme.set_stylebox("grabber_area", "HSlider", slider_grabber)
	theme.set_stylebox("grabber_area_highlight", "HSlider", slider_grabber)

static func _generate_checkbox_styles(theme: Theme, colors: Dictionary) -> void:
	"""Generate CheckBox styles"""
	theme.set_color("font_color", "CheckBox", colors.text_primary)
	theme.set_color("font_hover_color", "CheckBox", colors.accent)
	theme.set_color("font_pressed_color", "CheckBox", colors.text_primary)
	theme.set_color("font_disabled_color", "CheckBox", DesignTokens.COLORS.text.disabled)
	theme.set_font_size("font_size", "CheckBox", DesignTokens.TYPOGRAPHY.body.size)

static func _generate_tooltip_styles(theme: Theme, colors: Dictionary) -> void:
	"""Generate Tooltip styles"""
	var tooltip = StyleBoxFlat.new()
	tooltip.bg_color = colors.bg_secondary
	tooltip.corner_radius_top_left = DesignTokens.BORDERS.radius.sm
	tooltip.corner_radius_top_right = DesignTokens.BORDERS.radius.sm
	tooltip.corner_radius_bottom_left = DesignTokens.BORDERS.radius.sm
	tooltip.corner_radius_bottom_right = DesignTokens.BORDERS.radius.sm
	tooltip.border_color = colors.border
	tooltip.border_width_left = 1
	tooltip.border_width_top = 1
	tooltip.border_width_right = 1
	tooltip.border_width_bottom = 1
	tooltip.content_margin_left = DesignTokens.SPACING.sm
	tooltip.content_margin_right = DesignTokens.SPACING.sm
	tooltip.content_margin_top = DesignTokens.SPACING.xs
	tooltip.content_margin_bottom = DesignTokens.SPACING.xs
	tooltip.shadow_color = Color(0, 0, 0, 0.5)
	tooltip.shadow_size = 8
	tooltip.shadow_offset = Vector2(2, 2)
	
	theme.set_stylebox("panel", "TooltipPanel", tooltip)
	theme.set_color("font_color", "TooltipLabel", colors.text_primary)
	theme.set_font_size("font_size", "TooltipLabel", DesignTokens.TYPOGRAPHY.caption.size)

static func _set_global_properties(theme: Theme, colors: Dictionary) -> void:
	"""Set global theme properties"""
	# Global colors
	theme.set_color("font_color", "Control", colors.text_primary)
	theme.set_color("accent_color", "Control", colors.accent)
	
	# Global constants
	theme.set_constant("margin", "Control", DesignTokens.SPACING.md)
	theme.set_constant("h_separation", "Control", DesignTokens.SPACING.sm)
	theme.set_constant("v_separation", "Control", DesignTokens.SPACING.sm)