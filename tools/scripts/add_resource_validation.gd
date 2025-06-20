extends Node

## Script to add resource validation to critical preload/load calls

func _ready():
	print("=== Adding Resource Validation ===")
	add_resource_validation()
	get_tree().quit()

func add_resource_validation():
	# Critical files that dynamically load resources
	var files_to_fix = {
		"res://scenes/3d/EnhancedExplorationScene.gd": [
			{
				"old": "\tvar NeuroVisionTheme = preload(\"res://src/ui_atomic/themes/utilities/apply_neurovision_theme.gd\")",
				"new": "\t# Validate theme script exists\n\tif not ResourceLoader.exists(\"res://src/ui_atomic/themes/utilities/apply_neurovision_theme.gd\"):\n\t\tpush_error(\"[EnhancedExploration] NeuroVision theme script not found\")\n\t\treturn\n\tvar NeuroVisionTheme = preload(\"res://src/ui_atomic/themes/utilities/apply_neurovision_theme.gd\")"
			},
			{
				"old": "\tvar QuizPanelScene = preload(\"res://src/ui_atomic/organisms/QuizPanel.tscn\")",
				"new": "\t# Validate quiz panel scene\n\tif not ResourceLoader.exists(\"res://src/ui_atomic/organisms/QuizPanel.tscn\"):\n\t\tpush_error(\"[EnhancedExploration] Quiz panel scene not found\")\n\t\treturn\n\tvar QuizPanelScene = preload(\"res://src/ui_atomic/organisms/QuizPanel.tscn\")"
			}
		],
		"res://src/autoload/OnboardingManager.gd": [
			{
				"old": "\tvar tutorial_scene = load(\"res://src/ui/components/TutorialOverlay.tscn\")",
				"new": "\t# Validate tutorial overlay scene\n\tif not ResourceLoader.exists(\"res://src/ui/components/TutorialOverlay.tscn\"):\n\t\tpush_error(\"[OnboardingManager] Tutorial overlay scene not found\")\n\t\treturn\n\tvar tutorial_scene = load(\"res://src/ui/components/TutorialOverlay.tscn\")"
			}
		],
		"res://src/ui_atomic/effects/materials/MedicalGlassMaterial.gd": [
			{
				"old": "\tshader = preload(\"res://src/ui_atomic/effects/shaders/medical_glass.gdshader\")",
				"new": "\t# Validate medical glass shader\n\tif ResourceLoader.exists(\"res://src/ui_atomic/effects/shaders/medical_glass.gdshader\"):\n\t\tshader = preload(\"res://src/ui_atomic/effects/shaders/medical_glass.gdshader\")\n\telse:\n\t\tpush_error(\"[MedicalGlassMaterial] Medical glass shader not found\")"
			}
		]
	}
	
	for file_path in files_to_fix:
		if ResourceLoader.exists(file_path):
			fix_file_validation(file_path, files_to_fix[file_path])
		else:
			push_warning("File not found: " + file_path)
	
	print("=== Resource Validation Complete ===")

func fix_file_validation(file_path: String, replacements: Array):
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
			print("  Added validation in " + file_path)
	
	if modified:
		file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			file.store_string(content)
			file.close()
			print("Updated: " + file_path)
		else:
			push_error("Failed to write to file: " + file_path)