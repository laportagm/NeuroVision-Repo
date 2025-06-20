@tool
extends EditorScript

## Fix critical signal connection issues in key files
## Focus on ButtonMotionHandler, TutorialOverlay, UIThemeManager, and UnifiedColorManager

func _run():
	print("\n=== Fixing Critical Signal Connection Issues ===")
	
	var fixes_applied = 0
	
	# Fix ButtonMotionHandler.gd
	fixes_applied += fix_button_motion_handler()
	
	# Fix TutorialOverlay.gd
	fixes_applied += fix_tutorial_overlay()
	
	# Fix UIThemeManager.gd
	fixes_applied += fix_ui_theme_manager()
	
	# Fix UnifiedColorManager.gd
	fixes_applied += fix_unified_color_manager()
	
	print("\n=== Summary ===")
	print("Total fixes applied: %d" % fixes_applied)
	print("✅ Signal connection fixes complete!")

func fix_button_motion_handler() -> int:
	"""Fix signal connections in ButtonMotionHandler.gd"""
	var file_path = "res://src/ui_atomic/atoms/buttons/ButtonMotionHandler.gd"
	var content = FileAccess.open(file_path, FileAccess.READ)
	if not content:
		print("❌ Could not open %s" % file_path)
		return 0
	
	var code = content.get_as_text()
	content.close()
	
	print("\n📝 Fixing ButtonMotionHandler.gd...")
	
	# Fix setup_button_hover_animation function
	var old_hover_code = """button.mouse_entered.connect(func(): _animate_hover(button, true))
	button.mouse_exited.connect(func(): _animate_hover(button, false))"""
	
	var new_hover_code = """# Safely connect mouse signals
	if button.has_signal("mouse_entered") and not button.mouse_entered.is_connected(_animate_hover.bind(button, true)):
		button.mouse_entered.connect(_animate_hover.bind(button, true))
	if button.has_signal("mouse_exited") and not button.mouse_exited.is_connected(_animate_hover.bind(button, false)):
		button.mouse_exited.connect(_animate_hover.bind(button, false))"""
	
	if code.find(old_hover_code) != -1:
		code = code.replace(old_hover_code, new_hover_code)
		
		# Save the file
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		file.store_string(code)
		file.close()
		print("✅ Fixed mouse signal connections in setup_button_hover_animation")
		return 1
	else:
		print("ℹ️  ButtonMotionHandler.gd already fixed or has different code structure")
		return 0

func fix_tutorial_overlay() -> int:
	"""Fix signal connections in TutorialOverlay.gd"""
	var file_path = "res://src/ui_atomic/molecules/TutorialOverlay.gd"
	var content = FileAccess.open(file_path, FileAccess.READ)
	if not content:
		print("❌ Could not open %s" % file_path)
		return 0
	
	var code = content.get_as_text()
	content.close()
	
	print("\n📝 Fixing TutorialOverlay.gd...")
	var fixes = 0
	
	# Fix _connect_signals function
	var old_connect_signals = """func _connect_signals() -> void:
	\"\"\"Connect button signals\"\"\"
	next_button.pressed.connect(func(): next_pressed.emit())
	skip_button.pressed.connect(func(): skip_pressed.emit())
	previous_button.pressed.connect(func(): previous_pressed.emit())
	close_button.pressed.connect(func(): skip_pressed.emit())"""
	
	var new_connect_signals = """func _connect_signals() -> void:
	\"\"\"Connect button signals with safety checks\"\"\"
	# Safely connect next button
	if next_button and next_button.has_signal("pressed"):
		if not next_button.pressed.is_connected(_on_next_pressed):
			next_button.pressed.connect(_on_next_pressed)
	
	# Safely connect skip button
	if skip_button and skip_button.has_signal("pressed"):
		if not skip_button.pressed.is_connected(_on_skip_pressed):
			skip_button.pressed.connect(_on_skip_pressed)
	
	# Safely connect previous button
	if previous_button and previous_button.has_signal("pressed"):
		if not previous_button.pressed.is_connected(_on_previous_pressed):
			previous_button.pressed.connect(_on_previous_pressed)
	
	# Safely connect close button
	if close_button and close_button.has_signal("pressed"):
		if not close_button.pressed.is_connected(_on_skip_pressed):
			close_button.pressed.connect(_on_skip_pressed)

func _on_next_pressed() -> void:
	next_pressed.emit()

func _on_skip_pressed() -> void:
	skip_pressed.emit()

func _on_previous_pressed() -> void:
	previous_pressed.emit()"""
	
	if code.find(old_connect_signals) != -1:
		code = code.replace(old_connect_signals, new_connect_signals)
		fixes += 1
		print("✅ Fixed button signal connections in _connect_signals")
	
	if fixes > 0:
		# Save the file
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		file.store_string(code)
		file.close()
	else:
		print("ℹ️  TutorialOverlay.gd already fixed or has different code structure")
	
	return fixes

func fix_ui_theme_manager() -> int:
	"""Fix signal connections in UIThemeManager.gd"""
	var file_path = "res://src/autoload/UIThemeManager.gd"
	var content = FileAccess.open(file_path, FileAccess.READ)
	if not content:
		print("❌ Could not open %s" % file_path)
		return 0
	
	var code = content.get_as_text()
	content.close()
	
	print("\n📝 Fixing UIThemeManager.gd...")
	var fixes = 0
	
	# Fix settings_manager connection
	var old_settings_code = """# Connect to settings manager if available
	var settings_manager = get_node_or_null("/root/SettingsManager")
	if settings_manager and settings_manager.has_signal("setting_changed"):
		settings_manager.setting_changed.connect(_on_setting_changed)"""
	
	var new_settings_code = """# Connect to settings manager if available
	var settings_manager = get_node_or_null("/root/SettingsManager")
	if settings_manager and settings_manager.has_signal("setting_changed"):
		if not settings_manager.setting_changed.is_connected(_on_setting_changed):
			settings_manager.setting_changed.connect(_on_setting_changed)"""
	
	if code.find(old_settings_code) != -1:
		code = code.replace(old_settings_code, new_settings_code)
		fixes += 1
		print("✅ Fixed settings_manager signal connection")
	
	# Fix performance_monitor connection
	var old_perf_code = """# Connect to performance monitor for quality-based shader switching
	var performance_monitor = get_node_or_null("/root/PerformanceMonitor")
	if performance_monitor and performance_monitor.has_signal("quality_level_changed"):
		performance_monitor.quality_level_changed.connect(_on_quality_level_changed)"""
	
	var new_perf_code = """# Connect to performance monitor for quality-based shader switching
	var performance_monitor = get_node_or_null("/root/PerformanceMonitor")
	if performance_monitor and performance_monitor.has_signal("quality_level_changed"):
		if not performance_monitor.quality_level_changed.is_connected(_on_quality_level_changed):
			performance_monitor.quality_level_changed.connect(_on_quality_level_changed)"""
	
	if code.find(old_perf_code) != -1:
		code = code.replace(old_perf_code, new_perf_code)
		fixes += 1
		print("✅ Fixed performance_monitor signal connection")
	
	if fixes > 0:
		# Save the file
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		file.store_string(code)
		file.close()
	else:
		print("ℹ️  UIThemeManager.gd already fixed or has different code structure")
	
	return fixes

func fix_unified_color_manager() -> int:
	"""Fix signal connections in UnifiedColorManager.gd"""
	var file_path = "res://src/autoload/UnifiedColorManager.gd"
	var content = FileAccess.open(file_path, FileAccess.READ)
	if not content:
		print("❌ Could not open %s" % file_path)
		return 0
	
	var code = content.get_as_text()
	content.close()
	
	print("\n📝 Fixing UnifiedColorManager.gd...")
	var fixes = 0
	
	# Fix validation_failed signal connection
	var old_validation_code = """if validation_mode:
		UnifiedColorSystem.set_validation_enabled(true)
		
		# Connect validation signals
		if not validation_failed.is_connected(_on_validation_failed):
			validation_failed.connect(_on_validation_failed)"""
	
	var new_validation_code = """if validation_mode:
		UnifiedColorSystem.set_validation_enabled(true)
		
		# Connect validation signals
		if has_signal("validation_failed") and not validation_failed.is_connected(_on_validation_failed):
			validation_failed.connect(_on_validation_failed)"""
	
	if code.find(old_validation_code) != -1:
		code = code.replace(old_validation_code, new_validation_code)
		fixes += 1
		print("✅ Fixed validation_failed signal connection")
	
	# Fix theme_changed signal connection
	var old_theme_code = """if has_node("/root/UIThemeManager"):
		var theme_manager = get_node("/root/UIThemeManager")
		
		# Connect theme change signals
		if theme_manager.has_signal("theme_changed"):
			if not theme_manager.theme_changed.is_connected(_on_theme_manager_changed):
				theme_manager.theme_changed.connect(_on_theme_manager_changed)"""
	
	var new_theme_code = """if has_node("/root/UIThemeManager"):
		var theme_manager = get_node("/root/UIThemeManager")
		
		# Connect theme change signals
		if theme_manager and theme_manager.has_signal("theme_changed"):
			if not theme_manager.theme_changed.is_connected(_on_theme_manager_changed):
				theme_manager.theme_changed.connect(_on_theme_manager_changed)"""
	
	if code.find(old_theme_code) != -1:
		code = code.replace(old_theme_code, new_theme_code)
		fixes += 1
		print("✅ Fixed theme_changed signal connection")
	
	if fixes > 0:
		# Save the file
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		file.store_string(code)
		file.close()
	else:
		print("ℹ️  UnifiedColorManager.gd already fixed or has different code structure")
	
	return fixes