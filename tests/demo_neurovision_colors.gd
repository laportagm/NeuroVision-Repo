extends Control

## Demo scene showing the NeuroVision color palette in action

func _ready():
	print("\n========== NEUROVISION COLOR PALETTE DEMO ==========")
	
	# Apply comprehensive theme to entire scene
	var NeuroVisionTheme = preload("res://src/ui/themes/apply_neurovision_theme.gd")
	NeuroVisionTheme.apply_neurovision_theme_to_scene(self)
	
	# Set up full screen
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Create dark background
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = M3DesignTokens.get_color("background_start")
	add_child(bg)
	
	# Main container
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.add_theme_constant_override("separation", 20)
	add_child(main_container)
	
	# Title
	var title = Label.new()
	title.text = "NeuroVision M3 Color Palette"
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", M3DesignTokens.get_color("primary"))
	title.add_theme_color_override("font_shadow_color", M3DesignTokens.get_color("shadow"))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	main_container.add_child(title)
	
	# Surface hierarchy demo
	_create_surface_hierarchy_demo(main_container)
	
	# Primary colors demo
	_create_primary_colors_demo(main_container)
	
	# Semantic colors demo
	_create_semantic_colors_demo(main_container)
	
	# Brain structure colors demo
	_create_brain_colors_demo(main_container)
	
	print("\nNeuroVision color palette demo complete!")
	print("All colors are from M3DesignTokens")

func _create_surface_hierarchy_demo(container: Control):
	var section = _create_section("Surface Hierarchy", container)
	
	var surfaces_container = HBoxContainer.new()
	surfaces_container.add_theme_constant_override("separation", 15)
	section.add_child(surfaces_container)
	
	# Surface levels
	var surface_levels = [
		{"name": "Surface", "color": "surface"},
		{"name": "Surface Variant", "color": "surface_variant"},
		{"name": "Surface Bright", "color": "surface_bright"},
		{"name": "Surface Container", "color": "surface_container"},
		{"name": "Surface Container High", "color": "surface_container_high"},
		{"name": "Surface Container Highest", "color": "surface_container_highest"}
	]
	
	for level in surface_levels:
		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(150, 100)
		
		var style = StyleBoxFlat.new()
		style.bg_color = M3DesignTokens.get_color(level.color)
		style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["medium"])
		style.set_content_margin_all(M3DesignTokens.M3_SPACING["medium"])
		style.border_color = M3DesignTokens.get_color("outline_variant")
		style.border_color.a = 0.3
		style.set_border_width_all(1)
		panel.add_theme_stylebox_override("panel", style)
		
		var label = Label.new()
		label.text = level.name
		label.add_theme_color_override("font_color", M3DesignTokens.get_color("on_surface"))
		panel.add_child(label)
		
		surfaces_container.add_child(panel)

func _create_primary_colors_demo(container: Control):
	var section = _create_section("Primary Colors", container)
	
	var colors_container = HBoxContainer.new()
	colors_container.add_theme_constant_override("separation", 15)
	section.add_child(colors_container)
	
	# Primary color variants
	var primary_colors = [
		{"name": "Primary\n#00CCC0", "bg": "primary", "fg": "on_primary"},
		{"name": "Primary Container\n#003E3A", "bg": "primary_container", "fg": "on_primary_container"},
		{"name": "Secondary\n#2E7CD6", "bg": "secondary", "fg": "on_secondary"},
		{"name": "Tertiary\n#7B61FF", "bg": "tertiary", "fg": "on_tertiary"}
	]
	
	for color_info in primary_colors:
		var card = _create_color_card(color_info.name, color_info.bg, color_info.fg)
		colors_container.add_child(card)

func _create_semantic_colors_demo(container: Control):
	var section = _create_section("Semantic Colors", container)
	
	var colors_container = HBoxContainer.new()
	colors_container.add_theme_constant_override("separation", 15)
	section.add_child(colors_container)
	
	# Semantic colors
	var semantic_colors = [
		{"name": "Error\n#FF6B6B", "bg": "error", "fg": "on_error"},
		{"name": "Success\n#51CF66", "bg": "success", "fg": "on_success"},
		{"name": "Warning\n#FFD43B", "bg": "warning", "fg": "on_warning"},
		{"name": "Info\n#4DABF7", "bg": "info", "fg": "on_info"}
	]
	
	for color_info in semantic_colors:
		var card = _create_color_card(color_info.name, color_info.bg, color_info.fg)
		colors_container.add_child(card)

func _create_brain_colors_demo(container: Control):
	var section = _create_section("Brain Structure Colors", container)
	
	var colors_container = GridContainer.new()
	colors_container.columns = 4
	colors_container.add_theme_constant_override("h_separation", 15)
	colors_container.add_theme_constant_override("v_separation", 15)
	section.add_child(colors_container)
	
	# Brain structure colors
	var brain_colors = [
		"hippocampus", "amygdala", "cortex", "thalamus",
		"cerebellum", "brainstem", "corpus_callosum", "frontal_lobe",
		"temporal_lobe", "parietal_lobe", "occipital_lobe", "basal_ganglia",
		"limbic_system", "striatum", "ventricles"
	]
	
	for structure in brain_colors:
		var card = _create_brain_color_card(structure)
		colors_container.add_child(card)

func _create_color_card(text: String, bg_color: String, fg_color: String) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(140, 80)
	
	var style = StyleBoxFlat.new()
	style.bg_color = M3DesignTokens.get_color(bg_color)
	style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["medium"])
	style.set_content_margin_all(M3DesignTokens.M3_SPACING["medium"])
	card.add_theme_stylebox_override("panel", style)
	
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", M3DesignTokens.get_color(fg_color))
	label.add_theme_font_size_override("font_size", 14)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.add_child(label)
	
	return card

func _create_brain_color_card(structure: String) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(140, 60)
	
	var style = StyleBoxFlat.new()
	style.bg_color = M3DesignTokens.get_color(structure)
	style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["small"])
	style.set_content_margin_all(M3DesignTokens.M3_SPACING["small"])
	card.add_theme_stylebox_override("panel", style)
	
	var label = Label.new()
	label.text = structure.capitalize()
	# Use white or black text based on background brightness
	var bg_color = M3DesignTokens.get_color(structure)
	var brightness = (bg_color.r * 0.299 + bg_color.g * 0.587 + bg_color.b * 0.114)
	label.add_theme_color_override("font_color", Color.WHITE if brightness < 0.5 else Color.BLACK)
	label.add_theme_font_size_override("font_size", 12)
	card.add_child(label)
	
	return card

func _create_section(title: String, parent: Control) -> VBoxContainer:
	var section = VBoxContainer.new()
	section.add_theme_constant_override("separation", 10)
	
	var label = Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", M3DesignTokens.get_color("primary"))
	section.add_child(label)
	
	var separator = HSeparator.new()
	separator.add_theme_color_override("separator", M3DesignTokens.get_color("outline_variant"))
	section.add_child(separator)
	
	parent.add_child(section)
	return section