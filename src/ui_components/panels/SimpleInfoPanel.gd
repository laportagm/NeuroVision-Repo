class_name SimpleInfoPanel
extends BaseEducationalPanel

## Simplified info panel that works with existing NeuroVision systems

signal structure_selected(structure_id: String)
signal quiz_requested(structure_id: String)

@export var panel_width: int = 400

# UI References (created dynamically)
var _content_container: VBoxContainer
var _title_label: Label
var _description_label: RichTextLabel
var _close_button: Button

var _current_structure_id: String = ""

func _setup_panel() -> void:
	# Set panel name for debugging
	panel_name = "SimpleInfoPanel"
	
	# Configure panel size and position
	custom_minimum_size.x = panel_width
	anchor_left = 1.0
	anchor_top = 0.1
	anchor_right = 1.0
	anchor_bottom = 0.9
	offset_left = -panel_width - 20
	offset_right = -20
	
	# Create the UI structure
	_create_ui_structure()
	
	# Apply theme from existing system
	_apply_neurovision_theme()

func _create_ui_structure() -> void:
	# Main container
	_content_container = VBoxContainer.new()
	_content_container.name = "ContentContainer"
	_content_container.add_theme_constant_override("separation", 10)
	add_child(_content_container)
	
	# Header with close button
	var header = HBoxContainer.new()
	header.name = "Header"
	_content_container.add_child(header)
	
	# Title
	_title_label = Label.new()
	_title_label.name = "Title"
	_title_label.text = "Structure Information"
	_title_label.add_theme_font_size_override("font_size", 20)
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_title_label)
	
	# Close button
	_close_button = Button.new()
	_close_button.name = "CloseButton"
	_close_button.text = "✕"
	_close_button.custom_minimum_size = Vector2(30, 30)
	_close_button.flat = true
	_close_button.pressed.connect(hide_panel)
	header.add_child(_close_button)
	
	# Separator
	var separator = HSeparator.new()
	_content_container.add_child(separator)
	
	# Description
	_description_label = RichTextLabel.new()
	_description_label.name = "Description"
	_description_label.bbcode_enabled = true
	_description_label.fit_content = true
	_description_label.custom_minimum_size.y = 200
	_content_container.add_child(_description_label)
	
	# Quiz button
	var quiz_button = Button.new()
	quiz_button.name = "QuizButton"
	quiz_button.text = "Take Quiz"
	quiz_button.pressed.connect(_on_quiz_pressed)
	_content_container.add_child(quiz_button)

func _apply_neurovision_theme() -> void:
	# Use existing theme systems if available
	if UnifiedColorManager:
		var colors = UnifiedColorManager.get_current_theme_colors()
		
		# Panel background
		var panel_style = StyleBoxFlat.new()
		panel_style.bg_color = colors.get("surface_container", Color(0.1, 0.1, 0.15, 0.95))
		panel_style.set_corner_radius_all(8)
		panel_style.set_content_margin_all(16)
		add_theme_stylebox_override("panel", panel_style)
		
		# Title color
		if _title_label:
			_title_label.add_theme_color_override("font_color", colors.get("primary", Color.CYAN))
		
		# Description color
		if _description_label:
			_description_label.add_theme_color_override("default_color", colors.get("on_surface", Color.WHITE))

func _on_data_received(data: Dictionary) -> void:
	# Store structure ID
	_current_structure_id = data.get("id", "")
	
	# Update title
	if _title_label:
		_title_label.text = data.get("displayName", data.get("name", "Unknown Structure"))
	
	# Update description
	if _description_label:
		var description = data.get("description", "No description available.")
		var functions = data.get("functions", [])
		
		var content = "[b]Description:[/b]\n%s\n\n" % description
		
		if functions.size() > 0:
			content += "[b]Functions:[/b]\n"
			for function in functions:
				content += "• %s\n" % function
		
		_description_label.text = content

func _on_quiz_pressed() -> void:
	if _current_structure_id:
		quiz_requested.emit(_current_structure_id)

## Public method to display structure info
func display_structure_info(structure_data: Dictionary) -> void:
	show_panel(structure_data)