class_name MainMenu
extends Control

## Main menu screen for NeuroVision

# === SIGNALS ===
signal exploration_requested()
signal settings_requested()

# === NODES ===
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var professional_button: Button = $VBoxContainer/ProfessionalButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

# === PUBLIC METHODS ===

func _ready() -> void:
	"""Initialize the main menu"""
	print("[MainMenu] Initialized")
	_setup_ui()
	_connect_signals()

# === PRIVATE METHODS ===

func _setup_ui() -> void:
	"""Setup UI appearance"""
	# Apply enhanced theme styling immediately
	if UIThemeManager and UIThemeManager.has_method("apply_enhanced_styling_immediately"):
		print("[MainMenu] Applying enhanced theme styling")
		UIThemeManager.apply_enhanced_styling_immediately()
	
	# Add title
	var title = Label.new()
	title.text = "NeuroVision"
	title.add_theme_font_size_override("font_size", 48)
	title.modulate = Color.CYAN
	
	var subtitle = Label.new()
	subtitle.text = "Educational Neuroanatomy Explorer"
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.modulate = Color(0.7, 0.7, 0.7)
	
	# Add to container above buttons
	var vbox = $VBoxContainer
	vbox.add_child(title)
	vbox.move_child(title, 0)
	vbox.add_child(subtitle)
	vbox.move_child(subtitle, 1)
	
	# Add spacing
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 40
	vbox.add_child(spacer)
	vbox.move_child(spacer, 2)

func _connect_signals() -> void:
	"""Connect button signals"""
	start_button.pressed.connect(_on_start_pressed)
	if professional_button:
		professional_button.pressed.connect(_on_professional_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
	"""Handle start button press"""
	print("[MainMenu] Start exploration requested")
	
	# Load the exploration scene (use enhanced version if available)
	var _enhanced_scene_path = "res://src/scenes/EnhancedExplorationScene.tscn"
	var _standard_scene_path = "res://src/scenes/ExplorationScene.tscn"
	
	# Use enhanced scene for better UI and controls
	var exploration_scene = preload("res://src/scenes/EnhancedExplorationScene.tscn")
	# For standard scene, use:
	# var exploration_scene = preload("res://src/scenes/ExplorationScene.tscn")
	
	get_tree().change_scene_to_packed(exploration_scene)
	
	exploration_requested.emit()

func _on_professional_pressed() -> void:
	"""Handle professional UI button press"""
	print("[MainMenu] Professional UI requested")
	
	# Professional scene has missing dependencies, use enhanced scene instead
	print("[MainMenu] Professional scene not available, loading enhanced scene")
	_on_start_pressed()  # Load the enhanced scene instead

func _on_settings_pressed() -> void:
	"""Handle settings button press"""
	print("[MainMenu] Settings requested")
	settings_requested.emit()
	
	# TODO: Implement settings screen

func _on_quit_pressed() -> void:
	"""Handle quit button press"""
	print("[MainMenu] Quit requested")
	get_tree().quit()

func _on_explore_pressed() -> void:
	"""Compatibility method for tests"""
	_on_start_pressed()