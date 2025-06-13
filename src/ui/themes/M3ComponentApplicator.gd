## M3ComponentApplicator.gd
## Universal Material 3 component styling applicator for NeuroVision
##
## This class provides centralized methods to apply Material 3 design system
## styling to any UI component in the educational platform. It ensures
## consistent visual design while maintaining educational context.
##
## @tutorial: Material 3 Design System
## @tutorial: Educational UI Patterns

class_name M3ComponentApplicator
extends Node

# === COMPONENT STYLE VARIANTS ===
enum ButtonVariant {
	PRIMARY,
	SECONDARY,
	TERTIARY,
	FAB,
	ICON
}

enum PanelVariant {
	SURFACE,
	SURFACE_VARIANT,
	SURFACE_CONTAINER,
	MODAL,
	CARD,
	GLASS
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

# === UNIVERSAL M3 STYLING APPLICATION ===

## Apply M3 styling to any component based on its type and context
static func apply_m3_to_component(component: Control, context: String = "default") -> void:
	"""Apply appropriate Material 3 styling to any UI component"""
	if not component:
		push_error("[M3ComponentApplicator] Cannot apply styling to null component")
		return
	
	# Determine component type and apply appropriate styling
	if component is Button:
		apply_m3_button_styling(component, ButtonVariant.PRIMARY)
	elif component is PanelContainer:
		apply_m3_panel_styling(component, PanelVariant.SURFACE)
	elif component is Label:
		apply_m3_text_styling(component, TypographyScale.BODY_MEDIUM)
	elif component is LineEdit:
		_apply_m3_text_field_styling(component)
	elif component is ProgressBar:
		_apply_m3_progress_styling(component)
	elif component is CheckBox or component is CheckButton:
		_apply_m3_checkbox_styling(component)
	elif component is OptionButton:
		_apply_m3_dropdown_styling(component)
	elif component is TabContainer:
		_apply_m3_tab_styling(component)
	elif component is ScrollContainer:
		_apply_m3_scroll_styling(component)
	
	# Apply educational context overrides if needed
	_apply_educational_context(component, context)

## Apply M3 button styling with specific variant
static func apply_m3_button_styling(button: Button, variant: ButtonVariant = ButtonVariant.PRIMARY) -> void:
	"""Apply Material 3 button styling based on variant"""
	if not button:
		return
	
	var style := StyleBoxFlat.new()
	
	match variant:
		ButtonVariant.PRIMARY:
			style.bg_color = M3DesignTokens.M3_COLORS["primary"]
			style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["button"])
			style.set_content_margin_all(M3DesignTokens.M3_SPACING["button_padding"])
			style.shadow_size = M3DesignTokens.M3_ELEVATION["button"]
			style.shadow_color = M3DesignTokens.M3_COLORS["shadow"]
			style.shadow_offset = Vector2(0, 2)
			
			button.add_theme_stylebox_override("normal", style)
			button.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_primary"])
			button.add_theme_font_size_override("font_size", M3DesignTokens.M3_TYPE_SCALE["label_large"]["size"])
			
			# Hover state
			var hover_style = style.duplicate()
			hover_style.bg_color = hover_style.bg_color.lightened(0.1)
			hover_style.shadow_size = M3DesignTokens.M3_ELEVATION["level3"]
			button.add_theme_stylebox_override("hover", hover_style)
			
			# Pressed state
			var pressed_style = style.duplicate()
			pressed_style.bg_color = pressed_style.bg_color.darkened(0.1)
			pressed_style.shadow_size = M3DesignTokens.M3_ELEVATION["level1"]
			button.add_theme_stylebox_override("pressed", pressed_style)
			
		ButtonVariant.SECONDARY:
			style.bg_color = M3DesignTokens.M3_COLORS["secondary_container"]
			style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["button"])
			style.set_content_margin_all(M3DesignTokens.M3_SPACING["button_padding"])
			
			button.add_theme_stylebox_override("normal", style)
			button.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_secondary_container"])
			button.add_theme_font_size_override("font_size", M3DesignTokens.M3_TYPE_SCALE["label_large"]["size"])
			
		ButtonVariant.TERTIARY:
			style.bg_color = Color.TRANSPARENT
			style.border_width_left = 1
			style.border_width_right = 1
			style.border_width_top = 1
			style.border_width_bottom = 1
			style.border_color = M3DesignTokens.M3_COLORS["outline"]
			style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["button"])
			style.set_content_margin_all(M3DesignTokens.M3_SPACING["button_padding"])
			
			button.add_theme_stylebox_override("normal", style)
			button.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["primary"])
			button.add_theme_font_size_override("font_size", M3DesignTokens.M3_TYPE_SCALE["label_large"]["size"])
			
		ButtonVariant.FAB:
			style.bg_color = M3DesignTokens.M3_COLORS["tertiary_container"]
			style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["large"])
			style.set_content_margin_all(16)
			style.shadow_size = M3DesignTokens.M3_ELEVATION["level3"]
			style.shadow_color = M3DesignTokens.M3_COLORS["shadow"]
			style.shadow_offset = Vector2(0, 4)
			
			button.add_theme_stylebox_override("normal", style)
			button.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_tertiary_container"])
			
		ButtonVariant.ICON:
			button.flat = true
			button.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface_variant"])
			button.add_theme_font_size_override("font_size", 24)
	
	# Setup motion if available
	if ClassDB.class_exists("ButtonMotionHandler"):
		ButtonMotionHandler.setup_button_hover_animation(button)

## Apply M3 panel styling with specific variant
static func apply_m3_panel_styling(panel: PanelContainer, variant: PanelVariant = PanelVariant.SURFACE) -> void:
	"""Apply Material 3 panel styling based on variant"""
	if not panel:
		return
	
	var style := StyleBoxFlat.new()
	
	match variant:
		PanelVariant.SURFACE:
			style.bg_color = M3DesignTokens.M3_COLORS["surface"]
			style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["medium"])
			style.set_content_margin_all(M3DesignTokens.M3_SPACING["card_padding"])
			
		PanelVariant.SURFACE_VARIANT:
			style.bg_color = M3DesignTokens.M3_COLORS["surface_variant"]
			style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["medium"])
			style.set_content_margin_all(M3DesignTokens.M3_SPACING["card_padding"])
			
		PanelVariant.SURFACE_CONTAINER:
			style.bg_color = M3DesignTokens.M3_COLORS["surface_container"]
			style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["large"])
			style.set_content_margin_all(M3DesignTokens.M3_SPACING["dialog_padding"])
			style.shadow_size = M3DesignTokens.M3_ELEVATION["card"]
			style.shadow_color = M3DesignTokens.M3_COLORS["shadow"]
			
		PanelVariant.MODAL:
			style.bg_color = M3DesignTokens.M3_COLORS["surface_container_high"]
			style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["dialog"])
			style.set_content_margin_all(M3DesignTokens.M3_SPACING["dialog_padding"])
			style.shadow_size = M3DesignTokens.M3_ELEVATION["modal"]
			style.shadow_color = M3DesignTokens.M3_COLORS["shadow"]
			style.shadow_offset = Vector2(0, 8)
			
		PanelVariant.CARD:
			style.bg_color = M3DesignTokens.M3_COLORS["surface_container"]
			style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["card"])
			style.set_content_margin_all(M3DesignTokens.M3_SPACING["card_padding"])
			style.shadow_size = M3DesignTokens.M3_ELEVATION["card"]
			style.shadow_color = M3DesignTokens.M3_COLORS["shadow"]
			
		PanelVariant.GLASS:
			# Glass morphism effect for educational overlays
			style.bg_color = M3DesignTokens.M3_COLORS["surface"]
			style.bg_color.a = M3DesignTokens.M3_OPACITY["glass"]
			style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["large"])
			style.set_content_margin_all(M3DesignTokens.M3_SPACING["card_padding"])
			
			# Check if we're on Metal renderer (macOS) to avoid LOD bias issues
			var renderer_name = RenderingServer.get_rendering_device().get_device_name()
			if not renderer_name.contains("Metal"):
				style.border_width_left = 1
				style.border_width_right = 1
				style.border_width_top = 1
				style.border_width_bottom = 1
				style.border_color = M3DesignTokens.M3_COLORS["outline_variant"]
				style.border_color.a = 0.2
			# Would need shader for proper blur effect
	
	panel.add_theme_stylebox_override("panel", style)

## Apply M3 text styling with typography scale
static func apply_m3_text_styling(label: Label, typography: TypographyScale = TypographyScale.BODY_MEDIUM) -> void:
	"""Apply Material 3 typography to text elements"""
	if not label:
		return
	
	var type_key := ""
	match typography:
		TypographyScale.DISPLAY_LARGE: type_key = "display_large"
		TypographyScale.DISPLAY_MEDIUM: type_key = "display_medium"
		TypographyScale.DISPLAY_SMALL: type_key = "display_small"
		TypographyScale.HEADLINE_LARGE: type_key = "headline_large"
		TypographyScale.HEADLINE_MEDIUM: type_key = "headline_medium"
		TypographyScale.HEADLINE_SMALL: type_key = "headline_small"
		TypographyScale.TITLE_LARGE: type_key = "title_large"
		TypographyScale.TITLE_MEDIUM: type_key = "title_medium"
		TypographyScale.TITLE_SMALL: type_key = "title_small"
		TypographyScale.BODY_LARGE: type_key = "body_large"
		TypographyScale.BODY_MEDIUM: type_key = "body_medium"
		TypographyScale.BODY_SMALL: type_key = "body_small"
		TypographyScale.LABEL_LARGE: type_key = "label_large"
		TypographyScale.LABEL_MEDIUM: type_key = "label_medium"
		TypographyScale.LABEL_SMALL: type_key = "label_small"
	
	if M3DesignTokens.M3_TYPE_SCALE.has(type_key):
		var type_data = M3DesignTokens.M3_TYPE_SCALE[type_key]
		label.add_theme_font_size_override("font_size", type_data["size"])
		# Would also set line height, weight, and tracking if supported
	
	# Set appropriate text color based on context
	if label.get_parent() and label.get_parent().has_meta("m3_surface_type"):
		var surface_type = label.get_parent().get_meta("m3_surface_type")
		if surface_type == "primary":
			label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_primary"])
		elif surface_type == "secondary":
			label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_secondary"])
		else:
			label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface"])
	else:
		label.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface"])

## Scan and apply M3 styling to entire scene tree
static func scan_and_apply_m3_to_scene(root: Node) -> void:
	"""Recursively apply Material 3 styling to all components in a scene"""
	if not root:
		return
	
	var nodes_styled := 0
	var queue := [root]
	
	while not queue.is_empty():
		var node = queue.pop_front()
		
		if node is Control:
			# Apply context from metadata if available
			var context = node.get_meta("m3_context", "default")
			apply_m3_to_component(node, context)
			nodes_styled += 1
		
		# Add children to queue
		for child in node.get_children():
			queue.append(child)
	
	print("[M3ComponentApplicator] Applied M3 styling to %d components" % nodes_styled)

# === PRIVATE HELPER METHODS ===

static func _apply_m3_text_field_styling(text_field: LineEdit) -> void:
	"""Apply Material 3 text field styling"""
	var style := StyleBoxFlat.new()
	style.bg_color = M3DesignTokens.M3_COLORS["surface_variant"]
	style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["text_field"])
	style.set_content_margin_all(12)
	style.border_width_bottom = 2
	style.border_color = M3DesignTokens.M3_COLORS["primary"]
	
	text_field.add_theme_stylebox_override("normal", style)
	text_field.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface"])
	text_field.add_theme_color_override("font_placeholder_color", M3DesignTokens.M3_COLORS["on_surface_variant"])
	text_field.add_theme_font_size_override("font_size", M3DesignTokens.M3_TYPE_SCALE["body_large"]["size"])
	
	# Focus state
	var focus_style = style.duplicate()
	focus_style.border_color = M3DesignTokens.M3_COLORS["primary"]
	focus_style.border_width_bottom = 3
	text_field.add_theme_stylebox_override("focus", focus_style)

static func _apply_m3_progress_styling(progress: ProgressBar) -> void:
	"""Apply Material 3 progress bar styling"""
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = M3DesignTokens.M3_COLORS["surface_variant"]
	bg_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["full"])
	
	var fg_style := StyleBoxFlat.new()
	fg_style.bg_color = M3DesignTokens.M3_COLORS["primary"]
	fg_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["full"])
	
	progress.add_theme_stylebox_override("background", bg_style)
	progress.add_theme_stylebox_override("fill", fg_style)

static func _apply_m3_checkbox_styling(checkbox: BaseButton) -> void:
	"""Apply Material 3 checkbox styling"""
	checkbox.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface"])
	checkbox.add_theme_font_size_override("font_size", M3DesignTokens.M3_TYPE_SCALE["body_medium"]["size"])
	# Would need custom icons for proper M3 checkbox appearance

static func _apply_m3_dropdown_styling(dropdown: OptionButton) -> void:
	"""Apply Material 3 dropdown styling"""
	apply_m3_button_styling(dropdown, ButtonVariant.SECONDARY)
	dropdown.add_theme_icon_override("arrow", preload("res://icon.svg"))  # Would need M3 arrow icon

static func _apply_m3_tab_styling(tabs: TabContainer) -> void:
	"""Apply Material 3 tab styling"""
	var tab_style := StyleBoxFlat.new()
	tab_style.bg_color = Color.TRANSPARENT
	tab_style.border_width_bottom = 2
	tab_style.border_color = M3DesignTokens.M3_COLORS["primary"]
	tab_style.set_content_margin_all(M3DesignTokens.M3_SPACING["medium"])
	
	tabs.add_theme_stylebox_override("tab_selected", tab_style)
	tabs.add_theme_color_override("font_selected_color", M3DesignTokens.M3_COLORS["primary"])
	tabs.add_theme_color_override("font_unselected_color", M3DesignTokens.M3_COLORS["on_surface_variant"])

static func _apply_m3_scroll_styling(scroll: ScrollContainer) -> void:
	"""Apply Material 3 scroll container styling"""
	# Set scroll bar width
	scroll.get_v_scroll_bar().custom_minimum_size.x = 8
	scroll.get_h_scroll_bar().custom_minimum_size.y = 8
	
	# Style scroll bars (would need custom theme resource)
	var scrollbar_style := StyleBoxFlat.new()
	scrollbar_style.bg_color = M3DesignTokens.M3_COLORS["outline_variant"]
	scrollbar_style.set_corner_radius_all(4)

static func _apply_educational_context(component: Control, context: String) -> void:
	"""Apply educational context-specific overrides"""
	match context:
		"quiz":
			if component is Button:
				component.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_primary"])
		"clinical":
			if component is Label:
				component.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["tertiary"])
		"warning":
			if component is PanelContainer:
				var style = component.get_theme_stylebox("panel")
				if style and style is StyleBoxFlat:
					style.bg_color = M3DesignTokens.M3_COLORS["warning_container"]
		"success":
			if component is Label:
				component.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["success"])

## Apply M3 theme to specific UI patterns
static func apply_m3_header_bar(container: Control) -> void:
	"""Apply Material 3 top app bar styling"""
	if container is PanelContainer:
		apply_m3_panel_styling(container, PanelVariant.SURFACE)
		var style = container.get_theme_stylebox("panel")
		if style and style is StyleBoxFlat:
			style.set_corner_radius_all(0)  # No rounded corners for app bar
			style.shadow_size = M3DesignTokens.M3_ELEVATION["navigation"]
			style.shadow_offset = Vector2(0, 2)

## Apply M3 theme to modal dialogs
static func apply_m3_modal_dialog(dialog: Control) -> void:
	"""Apply Material 3 modal dialog styling"""
	if dialog is PanelContainer:
		apply_m3_panel_styling(dialog, PanelVariant.MODAL)
	
	# Find and style child buttons
	for child in dialog.get_children():
		if child is Button:
			if child.text.to_lower() in ["ok", "yes", "confirm", "save"]:
				apply_m3_button_styling(child, ButtonVariant.PRIMARY)
			elif child.text.to_lower() in ["cancel", "no", "close"]:
				apply_m3_button_styling(child, ButtonVariant.TERTIARY)

## Helper to get appropriate button variant from string
static func get_button_variant_from_string(variant_str: String) -> ButtonVariant:
	"""Convert string to ButtonVariant enum"""
	match variant_str.to_lower():
		"primary": return ButtonVariant.PRIMARY
		"secondary": return ButtonVariant.SECONDARY
		"tertiary": return ButtonVariant.TERTIARY
		"fab": return ButtonVariant.FAB
		"icon": return ButtonVariant.ICON
		_: return ButtonVariant.PRIMARY

## Helper to get appropriate panel variant from string
static func get_panel_variant_from_string(variant_str: String) -> PanelVariant:
	"""Convert string to PanelVariant enum"""
	match variant_str.to_lower():
		"surface": return PanelVariant.SURFACE
		"surface_variant": return PanelVariant.SURFACE_VARIANT
		"surface_container": return PanelVariant.SURFACE_CONTAINER
		"modal": return PanelVariant.MODAL
		"card": return PanelVariant.CARD
		"glass": return PanelVariant.GLASS
		_: return PanelVariant.SURFACE
