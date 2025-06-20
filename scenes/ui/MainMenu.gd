class_name MainMenu
extends Control

const ButtonMotionHandlerScript = preload("res://src/ui_atomic/atoms/buttons/ButtonMotionHandler.gd")

## Main menu screen for NeuroVision with Material 3 design and motion
##
## This screen provides the entry point to the educational neuroanatomy platform
## with sophisticated Material 3 animations and smooth transitions.

# === SIGNALS ===
signal exploration_requested()
signal settings_requested()

# === CONSTANTS ===
const M3_TEST_ENABLED = true  # Enable Material 3 testing
const BUTTON_ENTRANCE_DELAY = 0.05  # Stagger delay for button animations

# === NODES ===
@onready var canvas_layer: CanvasLayer = $MenuCanvasLayer
@onready var color_rect: ColorRect = $MenuCanvasLayer/BackgroundGradient
@onready var top_bar: PanelContainer = $MenuCanvasLayer/ApplicationHeader
@onready var start_button: Button = $MenuCanvasLayer/MenuCenterContainer/MenuButtonContainer/BeginExplorationButton
@onready var professional_button: Button = $MenuCanvasLayer/MenuCenterContainer/MenuButtonContainer/ProfessionalUIThemeButton
@onready var settings_button: Button = $MenuCanvasLayer/MenuCenterContainer/MenuButtonContainer/ApplicationSettingsButton
@onready var quit_button: Button = $MenuCanvasLayer/MenuCenterContainer/MenuButtonContainer/ExitApplicationButton
@onready var title_label: Label = $MenuCanvasLayer/MenuCenterContainer/MenuButtonContainer/MainTitleLabel
@onready var subtitle_label: Label = $MenuCanvasLayer/MenuCenterContainer/MenuButtonContainer/EducationalSubtitleLabel

# === PUBLIC METHODS ===

func _ready() -> void:
	"""Initialize the main menu with Material 3 styling and animations"""
	print("[MainMenu] Initializing with Material 3 design")
	
	# Apply Material 3 theme immediately
	_apply_material3_theme()
	
	# Setup UI with animations
	_setup_ui()
	_connect_signals()
	_setup_animations()
	
	# Animate entrance
	_animate_entrance()
	
	# Enable keyboard shortcuts for testing
	set_process_input(true)
	print("[MainMenu] Press F9 to test Material 3, F10 to cycle themes")
	
	# Run M3 test automatically on first load (remove in production)
	if OS.is_debug_build() and M3_TEST_ENABLED:
		await get_tree().create_timer(2.0).timeout
		_run_m3_test()

# === PRIVATE METHODS ===

func _apply_material3_theme() -> void:
	"""Apply Material 3 design tokens and styling"""
	# Apply M3 background gradient
	if color_rect:
		color_rect.color = UnifiedColorManager.get_color("background_start")
	
	# Apply M3 styling to top bar
	if top_bar:
		var style = StyleBoxFlat.new()
		style.bg_color = UnifiedColorManager.get_color("surface")
		style.bg_color.a = 0.95  # Slight transparency
		style.set_corner_radius_all(0)
		style.set_content_margin_all(16)  # Medium spacing
		
		# Add subtle shadow
		style.shadow_size = 3  # Navigation elevation
		style.shadow_color = UnifiedColorManager.get_color("shadow")
		style.shadow_offset = Vector2(0, 2)
		
		top_bar.add_theme_stylebox_override("panel", style)
	
	# Apply M3 typography
	if title_label:
		title_label.add_theme_color_override("font_color", UnifiedColorManager.get_color("primary"))
		title_label.add_theme_font_size_override("font_size", 57)  # display_large
	
	if subtitle_label:
		subtitle_label.add_theme_color_override("font_color", UnifiedColorManager.get_color("on_surface_variant"))
		subtitle_label.add_theme_font_size_override("font_size", 16)  # body_large
	
	# Apply M3 button styling
	_style_button_primary(start_button)
	_style_button_secondary(professional_button)
	_style_button_tertiary(settings_button)
	_style_button_tertiary(quit_button)

func _style_button_primary(button: Button) -> void:
	"""Apply Material 3 primary button styling"""
	if not button:
		return
	
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = UnifiedColorManager.get_color("primary")
	normal_style.set_corner_radius_all(12)  # button corner radius
	normal_style.set_content_margin_all(24)  # button padding
	
	# Add elevation shadow
	normal_style.shadow_size = 2  # button elevation
	normal_style.shadow_color = UnifiedColorManager.get_color("shadow")
	normal_style.shadow_offset = Vector2(0, 2)
	
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_color_override("font_color", UnifiedColorManager.get_color("on_primary"))
	button.add_theme_font_size_override("font_size", 14)  # label_large
	
	# Hover state
	var hover_style = normal_style.duplicate()
	hover_style.bg_color = UnifiedColorManager.get_color("primary_container")
	hover_style.shadow_size = 3  # level3 elevation
	button.add_theme_stylebox_override("hover", hover_style)
	
	# Pressed state
	var pressed_style = normal_style.duplicate()
	pressed_style.bg_color = UnifiedColorManager.get_color("primary")
	pressed_style.bg_color.a = 0.9  # Slightly transparent for pressed state
	pressed_style.shadow_size = 1  # level1 elevation
	button.add_theme_stylebox_override("pressed", pressed_style)

func _style_button_secondary(button: Button) -> void:
	"""Apply Material 3 secondary button styling"""
	if not button:
		return
	
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = UnifiedColorManager.get_color("secondary_container")
	normal_style.set_corner_radius_all(12)  # button corner radius
	normal_style.set_content_margin_all(24)  # button padding
	
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_color_override("font_color", UnifiedColorManager.get_color("on_secondary_container"))
	button.add_theme_font_size_override("font_size", 14)  # label_large
	
	# Hover state
	var hover_style = normal_style.duplicate()
	hover_style.bg_color = UnifiedColorManager.get_color("secondary")
	hover_style.bg_color.a = 0.15  # Subtle hover overlay
	button.add_theme_stylebox_override("hover", hover_style)

func _style_button_tertiary(button: Button) -> void:
	"""Apply Material 3 tertiary/text button styling"""
	if not button:
		return
	
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = UnifiedColorManager.get_color("transparent")
	normal_style.set_corner_radius_all(12)  # button corner radius
	normal_style.set_content_margin_all(24)  # button padding
	
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_color_override("font_color", UnifiedColorManager.get_color("primary"))
	button.add_theme_font_size_override("font_size", 14)  # label_large
	
	# Hover state with subtle background
	var hover_style = normal_style.duplicate()
	hover_style.bg_color = UnifiedColorManager.get_color("primary")
	hover_style.bg_color.a = 0.08  # hover opacity
	button.add_theme_stylebox_override("hover", hover_style)

func _setup_ui() -> void:
	"""Setup UI appearance and structure"""
	# Use scene-defined styling - themes are managed globally by UIThemeManager
	# Removed aggressive theme override to preserve editor appearance
	print("[MainMenu] Using global theme management")

func _connect_signals() -> void:
	## Connect button signals with error handling
	if is_instance_valid(start_button) and not start_button.pressed.is_connected(_on_start_pressed):
		start_button.pressed.connect(_on_start_pressed)
	
	if is_instance_valid(professional_button) and not professional_button.pressed.is_connected(_on_professional_pressed):
		professional_button.pressed.connect(_on_professional_pressed)
		
	if is_instance_valid(settings_button) and not settings_button.pressed.is_connected(_on_settings_pressed):
		settings_button.pressed.connect(_on_settings_pressed)
		
	if is_instance_valid(quit_button) and not quit_button.pressed.is_connected(_on_quit_pressed):
		quit_button.pressed.connect(_on_quit_pressed)

func _setup_animations() -> void:
	## Setup Material 3 motion animations for all buttons with error handling
	if not ButtonMotionHandlerScript:
		push_error("[MainMenu] ButtonMotionHandlerScript not loaded")
		return
		
	# Setup hover animations for all buttons
	if is_instance_valid(start_button):
		ButtonMotionHandlerScript.setup_button_hover_animation(start_button)
	if is_instance_valid(professional_button):
		ButtonMotionHandlerScript.setup_button_hover_animation(professional_button)
	if is_instance_valid(settings_button):
		ButtonMotionHandlerScript.setup_button_hover_animation(settings_button)
	if is_instance_valid(quit_button):
		ButtonMotionHandlerScript.setup_button_hover_animation(quit_button)
	
	# Setup focus animations with safe connections
	_setup_button_focus_animation(start_button)
	_setup_button_focus_animation(professional_button)
	_setup_button_focus_animation(settings_button)
	_setup_button_focus_animation(quit_button)

func _setup_button_focus_animation(button: Button) -> void:
	## Safely setup focus animations for a button
	if not is_instance_valid(button):
		return
		
	if button.has_signal("focus_entered") and not button.focus_entered.is_connected(_on_button_focus_entered.bind(button)):
		button.focus_entered.connect(_on_button_focus_entered.bind(button))
		
	if button.has_signal("focus_exited") and not button.focus_exited.is_connected(_on_button_focus_exited.bind(button)):
		button.focus_exited.connect(_on_button_focus_exited.bind(button))

func _on_button_focus_entered(button: Button) -> void:
	if ButtonMotionHandlerScript:
		ButtonMotionHandlerScript.animate_button_focus(button)

func _on_button_focus_exited(button: Button) -> void:
	if ButtonMotionHandlerScript:
		ButtonMotionHandlerScript.animate_button_unfocus(button)

func _animate_entrance() -> void:
	"""Animate the main menu entrance with Material 3 motion"""
	# Fade in the entire scene
	ButtonMotionHandlerScript.animate_scene_fade_in(canvas_layer)
	
	# Stagger button entrances
	await get_tree().create_timer(0.1).timeout
	ButtonMotionHandlerScript.animate_button_entrance(start_button, 0.0)
	ButtonMotionHandlerScript.animate_button_entrance(professional_button, BUTTON_ENTRANCE_DELAY)
	ButtonMotionHandlerScript.animate_button_entrance(settings_button, BUTTON_ENTRANCE_DELAY * 2)
	ButtonMotionHandlerScript.animate_button_entrance(quit_button, BUTTON_ENTRANCE_DELAY * 3)

func _on_start_pressed() -> void:
	"""Handle start button press with transition animation"""
	print("[MainMenu] Start exploration requested")
	
	# Animate transition (fade out the ColorRect)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	if color_rect:
		tween.tween_property(color_rect, "modulate:a", 0.0, 0.3)
	
	tween.finished.connect(func():
		# Load the exploration scene
		var exploration_scene_path = "res://scenes/3d/EnhancedExplorationScene.tscn"
		get_tree().change_scene_to_file(exploration_scene_path)
	)
	
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
	
	# TODO: Implement settings screen with Material 3 design

func _on_quit_pressed() -> void:
	"""Handle quit button press with exit animation"""
	print("[MainMenu] Quit requested")
	
	# Animate exit (fade out the ColorRect)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	if color_rect:
		tween.tween_property(color_rect, "modulate:a", 0.0, 0.2)
	
	tween.finished.connect(func():
		get_tree().quit()
	)

func _on_explore_pressed() -> void:
	"""Compatibility method for tests"""
	_on_start_pressed()

func _input(event: InputEvent) -> void:
	"""Handle keyboard shortcuts for Material 3 testing"""
	if not event.is_pressed() or not event is InputEventKey:
		return
		
	match event.keycode:
		KEY_F9:
			print("[MainMenu] F9 pressed - Testing Material 3")
			_on_m3_test_pressed()
		KEY_F10:
			print("[MainMenu] F10 pressed - Cycling themes")
			_on_cycle_themes_pressed()
		KEY_F11:
			print("[MainMenu] F11 pressed - Showing theme info")
			_show_theme_info()

func _show_theme_info() -> void:
	"""Display current theme information"""
	var current = UISystemManager.get_current_theme()
	print("\n[MainMenu] === CURRENT THEME INFO ===")
	print("  Name: %s" % current)
	print("  Display: %s" % UISystemManager.get_theme_display_name(current))
	print("  Description: %s" % UISystemManager.get_theme_description(current))
	print("  Is Material 3: %s" % UISystemManager.is_material3_active())
	
	var current_theme_res = UISystemManager.current_theme_resource
	if current_theme_res:
		print("  Theme resource loaded: YES")
		if current_theme_res.has_meta("wcag_aaa_validated"):
			print("  WCAG AAA: %s" % current_theme_res.get_meta("wcag_aaa_validated"))
		if current_theme_res.has_meta("m3_performance_level"):
			print("  Performance Level: %s" % current_theme_res.get_meta("m3_performance_level"))
	else:
		print("  Theme resource loaded: NO")
	print("============================\n")

func _exit_tree() -> void:
	"""Clean up resources to prevent RID leaks"""
	# Clean up button styles to free StyleBoxFlat RIDs
	var buttons = [start_button, professional_button, settings_button, quit_button]
	for button in buttons:
		if button and is_instance_valid(button):
			# Remove style overrides without setting null
			button.remove_theme_stylebox_override("normal")
			button.remove_theme_stylebox_override("hover")
			button.remove_theme_stylebox_override("pressed")
			button.remove_theme_stylebox_override("focus")
			button.remove_theme_stylebox_override("disabled")
	
	# Clean up any materials
	if is_instance_valid(self):
		material = null

func _on_m3_test_pressed() -> void:
	"""Test Material 3 theme"""
	print("[MainMenu] Testing Material 3 theme")
	
	# Toggle between default and Material 3
	if UISystemManager.is_material3_active():
		UISystemManager.set_theme("dark")
		print("[MainMenu] Switched to dark theme")
	else:
		UISystemManager.set_theme("material3")
		print("[MainMenu] Switched to Material 3 theme")
		# Reapply M3 styling when switching
		_apply_material3_theme()

func _on_cycle_themes_pressed() -> void:
	"""Cycle through all available themes"""
	var themes = UISystemManager.get_available_themes()
	var current = UISystemManager.get_current_theme()
	var current_index = themes.find(current)
	var next_index = (current_index + 1) % themes.size()
	
	var next_theme = themes[next_index]
	print("[MainMenu] Cycling to theme: %s" % next_theme)
	UISystemManager.set_theme(next_theme)
	
	# Reapply M3 styling if switching to material3
	if next_theme == "material3":
		_apply_material3_theme()

func _run_m3_test() -> void:
	"""Run Material 3 functionality test"""
	print("\n[MainMenu] Running Material 3 test...")
	
	# Quick test of M3 theme generation
	print("[MainMenu] Switching to Material 3...")
	UISystemManager.set_theme("material3")
	_apply_material3_theme()
	await get_tree().create_timer(0.5).timeout
	
	if UISystemManager.is_material3_active():
		print("[MainMenu] ✓ Material 3 activated successfully!")
		
		# Log some theme details
		var theme_res = UISystemManager.current_theme_resource
		if theme_res and theme_res.has_meta("wcag_aaa_validated"):
			print("[MainMenu] ✓ WCAG AAA validated: %s" % theme_res.get_meta("wcag_aaa_validated"))
		if theme_res and theme_res.has_meta("m3_performance_level"):
			print("[MainMenu] ✓ Performance optimized")
		
		# Test button animations
		print("[MainMenu] Testing button animations...")
		ButtonMotionHandlerScript.animate_button_entrance(start_button, 0.0)
		await get_tree().create_timer(0.5).timeout
		
		# Switch back to default after test
		await get_tree().create_timer(2.0).timeout
		print("[MainMenu] Switching back to default theme...")
		UISystemManager.set_theme("dark")
	else:
		print("[MainMenu] ✗ Material 3 activation failed")
	
	print("[MainMenu] Test complete.\n")
