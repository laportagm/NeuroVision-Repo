## ThemeSelector.gd
## Interactive theme selection UI component for NeuroVision
##
## Provides educators and students with easy access to theme presets
## optimized for different educational contexts and accessibility needs.

class_name ThemeSelector
extends PanelContainer

# === SIGNALS ===

## Emitted when user selects a new theme preset
signal theme_preset_selected(preset_name: String)

## Emitted when user requests accessibility information
signal accessibility_info_requested(preset_name: String)

## Emitted when user creates a custom preset
signal custom_preset_created(preset_name: String, preset_data: Dictionary)

# === UI NODES ===

@onready var preset_grid: GridContainer = $VBox/ScrollContainer/PresetGrid
@onready var preview_panel: PanelContainer = $VBox/PreviewPanel
@onready var apply_button: Button = $VBox/ButtonRow/ApplyButton
@onready var save_button: Button = $VBox/ButtonRow/SaveButton
@onready var accessibility_info: RichTextLabel = $VBox/AccessibilityInfo

# === STATE ===

var current_selected_preset: String = ""
var preview_colors: Dictionary = {}
var preset_buttons: Array[Button] = []

# === INITIALIZATION ===

func _ready() -> void:
	"""Initialize the theme selector UI"""
	
	_setup_ui()
	_populate_presets()
	_connect_signals()
	
	# Set initial selection
	var current_variant = UnifiedColorManager.get_current_theme_variant()
	_select_preset_for_variant(current_variant)

func _setup_ui() -> void:
	"""Setup the basic UI structure"""
	
	# Configure grid layout
	preset_grid.columns = 2
	
	# Style the preview panel
	var preview_style = UnifiedColorSystem.create_stylebox("panel", "default")
	preview_panel.add_theme_stylebox_override("panel", preview_style)
	
	# Configure buttons
	apply_button.text = "Apply Theme"
	save_button.text = "Save Custom"
	apply_button.disabled = true
	
	# Setup accessibility info
	accessibility_info.bbcode_enabled = true
	accessibility_info.fit_content = true

func _populate_presets() -> void:
	"""Populate the preset grid with available options"""
	
	var presets = ThemePresetManager.get_available_presets()
	
	# Add educational presets
	_add_preset_category("Educational Presets", presets.educational)
	
	# Add institutional presets  
	_add_preset_category("Institutional Presets", presets.institutional)
	
	# Add custom presets from user directory
	_add_custom_presets()

func _add_preset_category(category_name: String, preset_dict: Dictionary) -> void:
	"""Add a category of presets to the UI"""
	
	# Add category header
	var header = Label.new()
	header.text = category_name
	header.add_theme_font_size_override("font_size", 18)
	header.add_theme_color_override("font_color", UnifiedColorSystem.get_color("primary"))
	preset_grid.add_child(header)
	
	# Add spacer for grid alignment
	var spacer = Control.new()
	preset_grid.add_child(spacer)
	
	# Add preset buttons
	for preset_name in preset_dict:
		var preset_data = preset_dict[preset_name]
		_create_preset_button(preset_name, preset_data)

func _create_preset_button(preset_name: String, preset_data: Dictionary) -> void:
	"""Create a button for a theme preset"""
	
	var button = Button.new()
	button.text = preset_data.name
	button.tooltip_text = preset_data.description
	button.custom_minimum_size = Vector2(200, 80)
	button.flat = false
	
	# Style the button
	var button_style = UnifiedColorSystem.create_stylebox("button", "secondary")
	button.add_theme_stylebox_override("normal", button_style)
	
	# Store preset data in button metadata
	button.set_meta("preset_name", preset_name)
	button.set_meta("preset_data", preset_data)
	
	# Connect button signal
	button.pressed.connect(_on_preset_button_pressed.bind(preset_name, preset_data))
	
	# Add to grid
	preset_grid.add_child(button)
	preset_buttons.append(button)
	
	# Add info panel for this preset
	_create_preset_info_panel(preset_name, preset_data)

func _create_preset_info_panel(preset_name: String, preset_data: Dictionary) -> void:
	"""Create an information panel for a preset"""
	
	var info_panel = PanelContainer.new()
	info_panel.custom_minimum_size = Vector2(200, 80)
	
	var vbox = VBoxContainer.new()
	info_panel.add_child(vbox)
	
	# Use case label
	var use_case = Label.new()
	use_case.text = preset_data.get("use_case", "General use")
	use_case.add_theme_font_size_override("font_size", 12)
	use_case.add_theme_color_override("font_color", UnifiedColorSystem.get_color("on_surface"))
	use_case.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(use_case)
	
	# Accessibility level
	var accessibility = Label.new()
	var level = preset_data.get("accessibility_level", "standard")
	accessibility.text = "Accessibility: " + level.capitalize()
	accessibility.add_theme_font_size_override("font_size", 10)
	accessibility.add_theme_color_override("font_color", UnifiedColorSystem.get_color("on_surface_variant"))
	vbox.add_child(accessibility)
	
	# Theme variant
	var variant = Label.new()
	variant.text = "Theme: " + preset_data.get("theme_variant", "enhanced").capitalize()
	variant.add_theme_font_size_override("font_size", 10)
	variant.add_theme_color_override("font_color", UnifiedColorSystem.get_color("on_surface_variant"))
	vbox.add_child(variant)
	
	preset_grid.add_child(info_panel)

func _add_custom_presets() -> void:
	"""Add custom presets from user directory"""
	
	var custom_dir = "user://theme_presets/"
	var dir = DirAccess.open(custom_dir)
	
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	var has_custom = false
	while file_name != "":
		if file_name.ends_with(".json"):
			if not has_custom:
				# Add custom category header
				_add_preset_category("Custom Presets", {})
				has_custom = true
			
			var preset_path = custom_dir + file_name
			var preset_data = ThemePresetManager.load_preset_from_file(preset_path)
			
			if not preset_data.is_empty():
				var preset_name = file_name.get_basename()
				_create_preset_button(preset_name, preset_data)
		
		file_name = dir.get_next()

func _connect_signals() -> void:
	"""Connect UI signals"""
	
	apply_button.pressed.connect(_on_apply_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)

# === EVENT HANDLERS ===

func _on_preset_button_pressed(preset_name: String, preset_data: Dictionary) -> void:
	"""Handle preset button press"""
	
	current_selected_preset = preset_name
	
	# Update button states
	_update_button_selection()
	
	# Generate preview
	_generate_preview(preset_data)
	
	# Update accessibility info
	_update_accessibility_info(preset_data)
	
	# Enable apply button
	apply_button.disabled = false
	
	print("[ThemeSelector] Selected preset: %s" % preset_data.name)

func _on_apply_button_pressed() -> void:
	"""Apply the selected theme preset"""
	
	if current_selected_preset.is_empty():
		return
	
	print("[ThemeSelector] Applying preset: %s" % current_selected_preset)
	
	# Check if it's an educational or institutional preset
	var educational_presets = ThemePresetManager.EDUCATIONAL_PRESETS
	var institutional_presets = ThemePresetManager.INSTITUTIONAL_PRESETS
	
	var success = false
	
	if educational_presets.has(current_selected_preset):
		success = ThemePresetManager.apply_educational_preset(current_selected_preset)
	elif institutional_presets.has(current_selected_preset):
		success = ThemePresetManager.apply_institutional_preset(current_selected_preset)
	else:
		# Try loading as custom preset
		var preset_path = "user://theme_presets/" + current_selected_preset + ".json"
		var preset_data = ThemePresetManager.load_preset_from_file(preset_path)
		if not preset_data.is_empty():
			success = _apply_custom_preset(preset_data)
	
	if success:
		theme_preset_selected.emit(current_selected_preset)
		_show_success_message()
	else:
		_show_error_message("Failed to apply theme preset")

func _on_save_button_pressed() -> void:
	"""Save current settings as custom preset"""
	
	_show_save_dialog()

func _apply_custom_preset(preset_data: Dictionary) -> bool:
	"""Apply a custom preset configuration"""
	
	# Apply theme variant
	var theme_variant = preset_data.get("theme_variant", "enhanced")
	UnifiedColorManager.set_theme_variant(theme_variant)
	
	# Apply other custom settings
	if preset_data.has("brain_color_intensity"):
		ThemePresetManager._adjust_brain_color_intensity(preset_data.brain_color_intensity)
	
	if preset_data.has("glass_morphism_strength"):
		ThemePresetManager._configure_glass_morphism(preset_data.glass_morphism_strength)
	
	return true

# === UI UPDATES ===

func _update_button_selection() -> void:
	"""Update visual selection state of preset buttons"""
	
	for button in preset_buttons:
		var preset_name = button.get_meta("preset_name", "")
		
		if preset_name == current_selected_preset:
			# Selected style
			var selected_style = UnifiedColorSystem.create_stylebox("button", "primary")
			button.add_theme_stylebox_override("normal", selected_style)
			button.add_theme_color_override("font_color", UnifiedColorSystem.get_color("on_primary"))
		else:
			# Normal style
			var normal_style = UnifiedColorSystem.create_stylebox("button", "secondary")
			button.add_theme_stylebox_override("normal", normal_style)
			button.add_theme_color_override("font_color", UnifiedColorSystem.get_color("on_surface"))

func _generate_preview(preset_data: Dictionary) -> void:
	"""Generate color preview for the selected preset"""
	
	var theme_variant = preset_data.get("theme_variant", "enhanced")
	preview_colors = UnifiedColorManager.preview_theme_colors(theme_variant)
	
	# Clear existing preview
	for child in preview_panel.get_children():
		child.queue_free()
	
	# Wait for children to be freed
	await get_tree().process_frame
	
	# Create preview swatches
	var preview_grid = GridContainer.new()
	preview_grid.columns = 4
	preview_panel.add_child(preview_grid)
	
	for color_name in preview_colors:
		var color = preview_colors[color_name]
		_create_color_swatch(preview_grid, color_name, color)

func _create_color_swatch(parent: Control, color_name: String, color: Color) -> void:
	"""Create a color swatch for preview"""
	
	var swatch_container = VBoxContainer.new()
	swatch_container.custom_minimum_size = Vector2(60, 80)
	
	# Color rectangle
	var color_rect = ColorRect.new()
	color_rect.color = color
	color_rect.custom_minimum_size = Vector2(50, 50)
	swatch_container.add_child(color_rect)
	
	# Color name label
	var name_label = Label.new()
	name_label.text = color_name.replace("_", " ").capitalize()
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.add_theme_color_override("font_color", UnifiedColorSystem.get_color("on_surface"))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	swatch_container.add_child(name_label)
	
	parent.add_child(swatch_container)

func _update_accessibility_info(preset_data: Dictionary) -> void:
	"""Update accessibility information display"""
	
	var accessibility_level = preset_data.get("accessibility_level", "standard")
	var theme_variant = preset_data.get("theme_variant", "enhanced")
	
	var info_text = "[b]Accessibility Information[/b]\n\n"
	
	# Accessibility level info
	match accessibility_level:
		"maximum":
			info_text += "[color=green]✓[/color] WCAG AAA Compliant (7:1 contrast)\n"
			info_text += "[color=green]✓[/color] High contrast mode enabled\n"
			info_text += "[color=green]✓[/color] Screen reader optimized\n"
		"colorblind":
			info_text += "[color=green]✓[/color] Colorblind safe palette\n"
			info_text += "[color=green]✓[/color] Blue-orange color scheme\n"
			info_text += "[color=green]✓[/color] Shape differentiation enabled\n"
		"presentation":
			info_text += "[color=green]✓[/color] High visibility for projection\n"
			info_text += "[color=green]✓[/color] Increased font sizes\n"
			info_text += "[color=green]✓[/color] Enhanced contrast\n"
		"standard":
			info_text += "[color=green]✓[/color] WCAG AA Compliant (4.5:1 contrast)\n"
			info_text += "[color=green]✓[/color] Standard accessibility features\n"
	
	# Theme-specific info
	info_text += "\n[b]Theme Features[/b]\n"
	match theme_variant:
		"enhanced":
			info_text += "• Glass morphism effects\n"
			info_text += "• Vibrant educational colors\n"
			info_text += "• Engaging visual design\n"
		"minimal":
			info_text += "• Clean professional appearance\n"
			info_text += "• Reduced visual effects\n"
			info_text += "• Clinical color accuracy\n"
		"high_contrast":
			info_text += "• Maximum contrast ratios\n"
			info_text += "• Bold visual indicators\n"
			info_text += "• Accessibility optimized\n"
	
	accessibility_info.text = info_text

# === UTILITY METHODS ===

func _select_preset_for_variant(variant: String) -> void:
	"""Select the preset that matches a theme variant"""
	
	var educational_presets = ThemePresetManager.EDUCATIONAL_PRESETS
	
	for preset_name in educational_presets:
		var preset_data = educational_presets[preset_name]
		if preset_data.theme_variant == variant:
			current_selected_preset = preset_name
			_update_button_selection()
			_generate_preview(preset_data)
			_update_accessibility_info(preset_data)
			break

func _show_success_message() -> void:
	"""Show success message when theme is applied"""
	
	# Create temporary success notification
	var notification = Label.new()
	notification.text = "✓ Theme applied successfully!"
	notification.add_theme_color_override("font_color", UnifiedColorSystem.get_color("success"))
	notification.position = Vector2(10, 10)
	add_child(notification)
	
	# Fade out after 2 seconds
	var tween = create_tween()
	tween.tween_property(notification, "modulate:a", 0.0, 1.0)
	tween.tween_callback(notification.queue_free)

func _show_error_message(message: String) -> void:
	"""Show error message"""
	
	var notification = Label.new()
	notification.text = "✗ " + message
	notification.add_theme_color_override("font_color", UnifiedColorSystem.get_color("error"))
	notification.position = Vector2(10, 10)
	add_child(notification)
	
	var tween = create_tween()
	tween.tween_property(notification, "modulate:a", 0.0, 2.0)
	tween.tween_callback(notification.queue_free)

func _show_save_dialog() -> void:
	"""Show dialog for saving custom preset"""
	
	var dialog = AcceptDialog.new()
	dialog.title = "Save Custom Preset"
	dialog.size = Vector2(400, 200)
	
	var vbox = VBoxContainer.new()
	dialog.add_child(vbox)
	
	var name_input = LineEdit.new()
	name_input.placeholder_text = "Enter preset name..."
	vbox.add_child(name_input)
	
	var desc_input = TextEdit.new()
	desc_input.placeholder_text = "Enter description (optional)..."
	desc_input.custom_minimum_size = Vector2(0, 60)
	vbox.add_child(desc_input)
	
	add_child(dialog)
	dialog.popup_centered()
	
	# Handle save action
	dialog.confirmed.connect(func():
		var preset_name = name_input.text.strip_edges()
		var description = desc_input.text.strip_edges()
		
		if preset_name.is_empty():
			_show_error_message("Preset name cannot be empty")
			return
		
		var preset_data = ThemePresetManager.create_custom_preset(preset_name, description)
		var saved = ThemePresetManager.save_preset_to_file(preset_name)
		
		if saved:
			custom_preset_created.emit(preset_name, preset_data)
			_show_success_message()
			# Refresh the preset list
			_populate_presets()
		else:
			_show_error_message("Failed to save preset")
		
		dialog.queue_free()
	)
	
	dialog.canceled.connect(dialog.queue_free)