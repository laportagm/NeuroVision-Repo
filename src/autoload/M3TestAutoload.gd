extends Node

## Material 3 Test Autoload
## Add to project.godot autoloads to test M3 functionality

func _ready() -> void:
	print("\n[M3Test] Material 3 Test Autoload ready")
	print("[M3Test] Press F9 to test Material 3 theme")
	print("[M3Test] Press F10 to cycle through all themes")
	print("[M3Test] Press F11 to show theme info\n")

func _input(event: InputEvent) -> void:
	if not event.is_pressed():
		return
		
	if event is InputEventKey:
		match event.keycode:
			KEY_F9:
				_test_material3()
			KEY_F10:
				_cycle_themes()
			KEY_F11:
				_show_theme_info()

func _test_material3() -> void:
	print("\n[M3Test] Testing Material 3 theme toggle")
	
	if UIThemeManager.is_material3_active():
		print("[M3Test] Switching from M3 to dark theme")
		UIThemeManager.set_theme("dark")
	else:
		print("[M3Test] Switching to Material 3 theme")
		UIThemeManager.set_theme("material3")
		
		# Log theme generation details
		await get_tree().process_frame
		
		var current_theme = UIThemeManager.current_theme_resource
		if current_theme:
			print("[M3Test] Theme generated successfully!")
			print("[M3Test] - Is Material 3: %s" % current_theme.has_meta("is_material3"))
			print("[M3Test] - WCAG validated: %s" % current_theme.get_meta("wcag_aaa_validated", "unknown"))
			print("[M3Test] - Performance optimized: %s" % current_theme.has_meta("m3_performance_level"))

func _cycle_themes() -> void:
	var themes = UIThemeManager.get_available_themes()
	var current = UIThemeManager.get_current_theme()
	var idx = themes.find(current)
	var next_idx = (idx + 1) % themes.size()
	var next_theme = themes[next_idx]
	
	print("\n[M3Test] Cycling theme: %s -> %s" % [current, next_theme])
	UIThemeManager.set_theme(next_theme)

func _show_theme_info() -> void:
	print("\n[M3Test] Current Theme Information:")
	print("[M3Test] - Name: %s" % UIThemeManager.get_current_theme())
	print("[M3Test] - Display: %s" % UIThemeManager.get_theme_display_name(UIThemeManager.get_current_theme()))
	print("[M3Test] - Description: %s" % UIThemeManager.get_theme_description(UIThemeManager.get_current_theme()))
	print("[M3Test] - Is M3: %s" % UIThemeManager.is_material3_active())
	
	var theme = UIThemeManager.current_theme_resource
	if theme:
		print("[M3Test] - Resource loaded: true")
		
		# Sample some theme properties
		if theme.has_color("font_color", "Label"):
			var color = theme.get_color("font_color", "Label")
			print("[M3Test] - Label color: %s" % color)
		
		if theme.has_stylebox("normal", "Button"):
			var style = theme.get_stylebox("normal", "Button")
			if style is StyleBoxFlat:
				print("[M3Test] - Button bg color: %s" % style.bg_color)
				print("[M3Test] - Button corner radius: %d" % style.corner_radius_top_left)