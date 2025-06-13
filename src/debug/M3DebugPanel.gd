class_name M3DebugPanel
extends PanelContainer

## Debug panel for testing Material 3 themes
## Add this to your scene to test M3 functionality

@onready var theme_label: Label = $VBox/ThemeLabel
@onready var test_button: Button = $VBox/TestButton
@onready var cycle_button: Button = $VBox/CycleButton
@onready var info_label: RichTextLabel = $VBox/InfoLabel

func _ready() -> void:
	custom_minimum_size = Vector2(300, 200)
	
	# Create UI if nodes don't exist
	if not has_node("VBox"):
		_create_ui()
	
	_update_display()
	
	# Connect signals
	test_button.pressed.connect(_on_test_pressed)
	cycle_button.pressed.connect(_on_cycle_pressed)

func _create_ui() -> void:
	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	add_child(vbox)
	
	# Current theme label
	theme_label = Label.new()
	theme_label.name = "ThemeLabel"
	vbox.add_child(theme_label)
	
	# Test M3 button
	test_button = Button.new()
	test_button.name = "TestButton"
	test_button.text = "Toggle Material 3"
	vbox.add_child(test_button)
	
	# Cycle themes button
	cycle_button = Button.new()
	cycle_button.name = "CycleButton"
	cycle_button.text = "Cycle All Themes"
	vbox.add_child(cycle_button)
	
	# Info display
	info_label = RichTextLabel.new()
	info_label.name = "InfoLabel"
	info_label.fit_content = true
	info_label.custom_minimum_size.y = 100
	vbox.add_child(info_label)

func _update_display() -> void:
	var current = UIThemeManager.get_current_theme()
	theme_label.text = "Current: " + UIThemeManager.get_theme_display_name(current)
	
	# Update info
	info_label.clear()
	info_label.append_text("Theme Info:\n")
	info_label.append_text("- Name: %s\n" % current)
	info_label.append_text("- M3 Active: %s\n" % UIThemeManager.is_material3_active())
	
	if UIThemeManager.current_theme_resource:
		var theme = UIThemeManager.current_theme_resource
		if theme.has_meta("wcag_aaa_validated"):
			info_label.append_text("- WCAG AAA: %s\n" % theme.get_meta("wcag_aaa_validated"))
		if theme.has_meta("m3_performance_level"):
			info_label.append_text("- Perf Level: %s\n" % theme.get_meta("m3_performance_level"))

func _on_test_pressed() -> void:
	if UIThemeManager.is_material3_active():
		UIThemeManager.set_theme("dark")
	else:
		UIThemeManager.set_theme("material3")
	_update_display()

func _on_cycle_pressed() -> void:
	var themes = UIThemeManager.get_available_themes()
	var current = UIThemeManager.get_current_theme()
	var idx = themes.find(current)
	var next_idx = (idx + 1) % themes.size()
	UIThemeManager.set_theme(themes[next_idx])
	_update_display()

func _input(event: InputEvent) -> void:
	# Quick theme switching with number keys
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				UIThemeManager.set_theme("dark")
				_update_display()
			KEY_2:
				UIThemeManager.set_theme("material3")
				_update_display()
			KEY_3:
				UIThemeManager.set_theme("material3_high_contrast")
				_update_display()
			KEY_4:
				UIThemeManager.set_theme("material3_colorblind")
				_update_display()