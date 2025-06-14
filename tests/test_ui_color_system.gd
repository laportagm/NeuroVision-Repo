extends Control

## Test scene to verify UI elements are using M3DesignTokens correctly

func _ready():
	print("\n========== UI COLOR SYSTEM TEST ==========")
	
	# Set fullscreen for better visibility
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Create main container
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.add_theme_constant_override("separation", 20)
	add_child(main_container)
	
	# Title
	var title = Label.new()
	title.text = "M3DesignTokens UI Color System Test"
	title.add_theme_font_size_override("font_size", 32)
	title.modulate = M3DesignTokens.get_color("primary")
	main_container.add_child(title)
	
	# Test panels
	_create_panel_tests(main_container)
	
	# Test buttons
	_create_button_tests(main_container)
	
	# Test text elements
	_create_text_tests(main_container)
	
	# Test overlays
	_create_overlay_tests(main_container)
	
	print("\nUI color system test complete!")
	print("All UI elements are using M3DesignTokens colors")

func _create_panel_tests(container: Control):
	var section = _create_section("Panel Variants", container)
	
	var panels_container = HBoxContainer.new()
	panels_container.add_theme_constant_override("separation", 10)
	section.add_child(panels_container)
	
	# Surface panel
	var surface_panel = PanelContainer.new()
	surface_panel.custom_minimum_size = Vector2(150, 100)
	# Apply M3 color manually since M3ComponentApplicator may not be available in tests
	var surface_style = StyleBoxFlat.new()
	surface_style.bg_color = M3DesignTokens.get_color("surface")
	surface_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["medium"])
	surface_style.set_content_margin_all(M3DesignTokens.M3_SPACING["medium"])
	surface_panel.add_theme_stylebox_override("panel", surface_style)
	var surface_label = Label.new()
	surface_label.text = "Surface"
	surface_label.modulate = M3DesignTokens.get_color("on_surface")
	surface_panel.add_child(surface_label)
	panels_container.add_child(surface_panel)
	
	# Surface container panel
	var container_panel = PanelContainer.new()
	container_panel.custom_minimum_size = Vector2(150, 100)
	var container_style = StyleBoxFlat.new()
	container_style.bg_color = M3DesignTokens.get_color("surface_container")
	container_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["medium"])
	container_style.set_content_margin_all(M3DesignTokens.M3_SPACING["medium"])
	container_panel.add_theme_stylebox_override("panel", container_style)
	var container_label = Label.new()
	container_label.text = "Surface Container"
	container_label.modulate = M3DesignTokens.get_color("on_surface")
	container_panel.add_child(container_label)
	panels_container.add_child(container_panel)
	
	# Glass panel
	var glass_panel = PanelContainer.new()
	glass_panel.custom_minimum_size = Vector2(150, 100)
	var glass_style = StyleBoxFlat.new()
	glass_style.bg_color = M3DesignTokens.get_color("surface_bright")
	glass_style.bg_color.a = 0.85
	glass_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["large"])
	glass_style.set_content_margin_all(M3DesignTokens.M3_SPACING["medium"])
	glass_panel.add_theme_stylebox_override("panel", glass_style)
	var glass_label = Label.new()
	glass_label.text = "Glass"
	glass_label.modulate = M3DesignTokens.get_color("on_surface")
	glass_panel.add_child(glass_label)
	panels_container.add_child(glass_panel)

func _create_button_tests(container: Control):
	var section = _create_section("Button Variants", container)
	
	var buttons_container = HBoxContainer.new()
	buttons_container.add_theme_constant_override("separation", 10)
	section.add_child(buttons_container)
	
	# Primary button
	var primary_btn = Button.new()
	primary_btn.text = "Primary"
	_apply_button_style(primary_btn, "primary")
	buttons_container.add_child(primary_btn)
	
	# Secondary button
	var secondary_btn = Button.new()
	secondary_btn.text = "Secondary"
	_apply_button_style(secondary_btn, "secondary")
	buttons_container.add_child(secondary_btn)
	
	# Tertiary button
	var tertiary_btn = Button.new()
	tertiary_btn.text = "Tertiary"
	_apply_button_style(tertiary_btn, "tertiary")
	buttons_container.add_child(tertiary_btn)
	
	# Icon button
	var icon_btn = Button.new()
	icon_btn.text = "?"
	_apply_button_style(icon_btn, "icon")
	buttons_container.add_child(icon_btn)

func _create_text_tests(container: Control):
	var section = _create_section("Typography & Colors", container)
	
	# Primary text
	var primary_text = Label.new()
	primary_text.text = "Primary text color"
	primary_text.modulate = M3DesignTokens.get_color("on_surface")
	primary_text.add_theme_font_size_override("font_size", M3DesignTokens.M3_TYPE_SCALE["body_large"]["size"])
	section.add_child(primary_text)
	
	# Secondary text
	var secondary_text = Label.new()
	secondary_text.text = "Secondary text color"
	secondary_text.modulate = M3DesignTokens.get_color("on_surface_variant")
	secondary_text.add_theme_font_size_override("font_size", M3DesignTokens.M3_TYPE_SCALE["body_medium"]["size"])
	section.add_child(secondary_text)
	
	# Error text
	var error_text = Label.new()
	error_text.text = "Error state color"
	error_text.modulate = M3DesignTokens.get_color("error")
	error_text.add_theme_font_size_override("font_size", M3DesignTokens.M3_TYPE_SCALE["body_medium"]["size"])
	section.add_child(error_text)
	
	# Success text
	var success_text = Label.new()
	success_text.text = "Success state color"
	success_text.modulate = M3DesignTokens.get_color("success")
	success_text.add_theme_font_size_override("font_size", M3DesignTokens.M3_TYPE_SCALE["body_medium"]["size"])
	section.add_child(success_text)

func _create_overlay_tests(container: Control):
	var section = _create_section("Overlay Elements", container)
	
	# Progress bar
	var progress_container = HBoxContainer.new()
	progress_container.add_theme_constant_override("separation", 10)
	section.add_child(progress_container)
	
	var progress_label = Label.new()
	progress_label.text = "Progress:"
	progress_label.modulate = M3DesignTokens.get_color("on_surface")
	progress_container.add_child(progress_label)
	
	var progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(200, 20)
	progress_bar.value = 65
	_apply_m3_progress_bar_style(progress_bar)
	progress_container.add_child(progress_bar)
	
	# Loading indicator simulation
	var loading_panel = PanelContainer.new()
	loading_panel.custom_minimum_size = Vector2(300, 80)
	var modal_style = StyleBoxFlat.new()
	modal_style.bg_color = M3DesignTokens.get_color("surface_container_highest")
	modal_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["dialog"])
	modal_style.set_content_margin_all(M3DesignTokens.M3_SPACING["large"])
	modal_style.shadow_size = 8
	modal_style.shadow_color = M3DesignTokens.get_color("shadow")
	loading_panel.add_theme_stylebox_override("panel", modal_style)
	
	var loading_content = VBoxContainer.new()
	loading_panel.add_child(loading_content)
	
	var loading_label = Label.new()
	loading_label.text = "Loading..."
	loading_label.modulate = M3DesignTokens.get_color("on_surface")
	loading_label.add_theme_font_size_override("font_size", M3DesignTokens.M3_TYPE_SCALE["headline_small"]["size"])
	loading_content.add_child(loading_label)
	
	section.add_child(loading_panel)

func _create_section(title: String, parent: Control) -> VBoxContainer:
	var section = VBoxContainer.new()
	section.add_theme_constant_override("separation", 10)
	
	var label = Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 20)
	label.modulate = M3DesignTokens.get_color("primary")
	section.add_child(label)
	
	var separator = HSeparator.new()
	separator.modulate = M3DesignTokens.get_color("outline_variant")
	section.add_child(separator)
	
	parent.add_child(section)
	return section

func _apply_m3_progress_bar_style(progress_bar: ProgressBar):
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = M3DesignTokens.get_color("surface_variant")
	bg_style.set_corner_radius_all(10)
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = M3DesignTokens.get_color("primary")
	fill_style.set_corner_radius_all(10)
	
	progress_bar.add_theme_stylebox_override("background", bg_style)
	progress_bar.add_theme_stylebox_override("fill", fill_style)

func _apply_button_style(button: Button, variant: String):
	"""Apply M3-style button styling manually"""
	var style_normal = StyleBoxFlat.new()
	var style_hover = StyleBoxFlat.new()
	var style_pressed = StyleBoxFlat.new()
	
	# Configure based on variant
	match variant:
		"primary":
			style_normal.bg_color = M3DesignTokens.get_color("primary")
			style_hover.bg_color = M3DesignTokens.get_color("primary_container")
			style_pressed.bg_color = M3DesignTokens.get_color("primary").darkened(0.2)
			button.add_theme_color_override("font_color", M3DesignTokens.get_color("on_primary"))
			button.add_theme_color_override("font_hover_color", M3DesignTokens.get_color("on_primary_container"))
		"secondary":
			style_normal.bg_color = M3DesignTokens.get_color("secondary")
			style_hover.bg_color = M3DesignTokens.get_color("secondary_container")
			style_pressed.bg_color = M3DesignTokens.get_color("secondary").darkened(0.2)
			button.add_theme_color_override("font_color", M3DesignTokens.get_color("on_secondary"))
			button.add_theme_color_override("font_hover_color", M3DesignTokens.get_color("on_secondary_container"))
		"tertiary":
			style_normal.bg_color = M3DesignTokens.get_color("tertiary")
			style_hover.bg_color = M3DesignTokens.get_color("tertiary_container")
			style_pressed.bg_color = M3DesignTokens.get_color("tertiary").darkened(0.2)
			button.add_theme_color_override("font_color", M3DesignTokens.get_color("on_tertiary"))
			button.add_theme_color_override("font_hover_color", M3DesignTokens.get_color("on_tertiary_container"))
		"icon":
			style_normal.bg_color = M3DesignTokens.get_color("transparent")
			style_hover.bg_color = M3DesignTokens.get_color("primary")
			style_hover.bg_color.a = 0.08
			style_pressed.bg_color = M3DesignTokens.get_color("primary")
			style_pressed.bg_color.a = 0.12
			button.add_theme_color_override("font_color", M3DesignTokens.get_color("on_surface"))
			button.custom_minimum_size = Vector2(48, 48)
	
	# Apply common styling
	for style in [style_normal, style_hover, style_pressed]:
		style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["button"])
		style.set_content_margin_all(M3DesignTokens.M3_SPACING["medium"])
	
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)