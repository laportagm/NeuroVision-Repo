@tool
extends EditorScript

## Script to add error handling to signal connections

func _run():
	print("=== Fixing Signal Connections ===")
	fix_signal_connections()
	print("=== Done ===")

func fix_signal_connections():
	# Files with direct signal connections that need error handling
	var files_to_fix = {
		"res://src/ui_atomic/atoms/buttons/ButtonMotionHandler.gd": [
			{
				"old": "\tbutton.mouse_entered.connect(func(): _animate_hover(button, true))",
				"new": "\tif button.has_signal(\"mouse_entered\"):\n\t\tbutton.mouse_entered.connect(func(): _animate_hover(button, true))"
			},
			{
				"old": "\tbutton.mouse_exited.connect(func(): _animate_hover(button, false))",
				"new": "\tif button.has_signal(\"mouse_exited\"):\n\t\tbutton.mouse_exited.connect(func(): _animate_hover(button, false))"
			}
		],
		"res://src/ui_atomic/molecules/TutorialOverlay.gd": [
			{
				"old": "\tnext_button.pressed.connect(func(): next_pressed.emit())",
				"new": "\tif next_button and next_button.has_signal(\"pressed\"):\n\t\tnext_button.pressed.connect(func(): next_pressed.emit())"
			},
			{
				"old": "\tskip_button.pressed.connect(func(): skip_pressed.emit())",
				"new": "\tif skip_button and skip_button.has_signal(\"pressed\"):\n\t\tskip_button.pressed.connect(func(): skip_pressed.emit())"
			},
			{
				"old": "\tprevious_button.pressed.connect(func(): previous_pressed.emit())",
				"new": "\tif previous_button and previous_button.has_signal(\"pressed\"):\n\t\tprevious_button.pressed.connect(func(): previous_pressed.emit())"
			},
			{
				"old": "\tclose_button.pressed.connect(func(): skip_pressed.emit())",
				"new": "\tif close_button and close_button.has_signal(\"pressed\"):\n\t\tclose_button.pressed.connect(func(): skip_pressed.emit())"
			}
		],
		"res://src/autoload/UIThemeManager.gd": [
			{
				"old": "\t\tsettings_manager.setting_changed.connect(_on_setting_changed)",
				"new": "\t\tif settings_manager.has_signal(\"setting_changed\"):\n\t\t\tsettings_manager.setting_changed.connect(_on_setting_changed)"
			},
			{
				"old": "\t\tperformance_monitor.quality_level_changed.connect(_on_quality_level_changed)",
				"new": "\t\tif performance_monitor.has_signal(\"quality_level_changed\"):\n\t\t\tperformance_monitor.quality_level_changed.connect(_on_quality_level_changed)"
			}
		],
		"res://src/autoload/UnifiedColorManager.gd": [
			{
				"old": "\t\t\tvalidation_failed.connect(_on_validation_failed)",
				"new": "\t\t\tif has_signal(\"validation_failed\"):\n\t\t\t\tvalidation_failed.connect(_on_validation_failed)"
			},
			{
				"old": "\t\t\t\ttheme_manager.theme_changed.connect(_on_theme_manager_changed)",
				"new": "\t\t\t\tif theme_manager.has_signal(\"theme_changed\"):\n\t\t\t\t\ttheme_manager.theme_changed.connect(_on_theme_manager_changed)"
			}
		]
	}
	
	for file_path in files_to_fix:
		fix_file_signals(file_path, files_to_fix[file_path])
	
	print("=== Signal Connection Fixes Complete ===")

func fix_file_signals(file_path: String, replacements: Array):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open file: " + file_path)
		return
		
	var content = file.get_as_text()
	file.close()
	
	var modified = false
	
	for replacement in replacements:
		if content.contains(replacement.old):
			content = content.replace(replacement.old, replacement.new)
			modified = true
			print("  Added signal validation in " + file_path)
	
	if modified:
		file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			file.store_string(content)
			file.close()
			print("Updated: " + file_path)
		else:
			push_error("Failed to write to file: " + file_path)