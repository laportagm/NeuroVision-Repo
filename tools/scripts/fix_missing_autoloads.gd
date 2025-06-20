extends Node

## Script to fix missing autoload references in the codebase
## This will replace get_node("/root/AutoloadName") with proper null checks

func _ready():
	print("=== Fixing Missing Autoload References ===")
	fix_missing_autoloads()
	get_tree().quit()

func fix_missing_autoloads():
	# List of autoloads that are NOT registered but are being referenced
	var missing_autoloads = [
		"LearningContentManager",
		"KnowledgeService",
		"StructureContentService",
		"AccessibilityManager",
		"SettingsManager",
		"UIAdaptationManager",
		"OnboardingManager",
		"ContentManager",
		"UIPoolManager",
		"ErrorRecoveryManager",
		"LearningProgressManager"
	]
	
	# List of files to fix based on the error report
	var files_to_fix = [
		"res://scenes/3d/EnhancedExplorationScene.gd",
		"res://src/core/managers/CoreSystemManager.gd",
		"res://src/core/interaction/SelectionFeedbackManager.gd",
		"res://src/ui_atomic/themes/utilities/ContextualColorGenerator.gd",
		"res://src/ui_atomic/themes/utilities/PerformanceAwareShaderManager.gd",
		"res://src/ui_atomic/themes/generators/Material3ThemeGenerator.gd",
		"res://src/autoload/LearningProgressManager.gd",
		"res://src/autoload/UIAdaptationManager.gd",
		"res://src/autoload/LearningContentManager.gd",
		"res://src/autoload/UnifiedColorManager.gd",
		"res://src/debug/DebugConsole.gd"
	]
	
	for file_path in files_to_fix:
		if ResourceLoader.exists(file_path):
			fix_file(file_path, missing_autoloads)
	
	print("=== Autoload Reference Fixes Complete ===")

func fix_file(file_path: String, missing_autoloads: Array):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open file: " + file_path)
		return
		
	var content = file.get_as_text()
	file.close()
	
	var modified = false
	var lines = content.split("\n")
	var new_lines = []
	
	for i in range(lines.size()):
		var line = lines[i]
		var new_line = line
		
		# Check for each missing autoload
		for autoload in missing_autoloads:
			# Pattern 1: get_node("/root/AutoloadName")
			var pattern1 = 'get_node("/root/' + autoload + '")'
			var replacement1 = 'get_node_or_null("/root/' + autoload + '")'
			
			if line.contains(pattern1):
				new_line = new_line.replace(pattern1, replacement1)
				modified = true
				print("  Fixed " + autoload + " reference in " + file_path + " (line " + str(i + 1) + ")")
			
			# Pattern 2: tree.root.get_node("AutoloadName")
			var pattern2 = 'tree.root.get_node("' + autoload + '")'
			var replacement2 = 'tree.root.get_node_or_null("' + autoload + '")'
			
			if line.contains(pattern2):
				new_line = new_line.replace(pattern2, replacement2)
				modified = true
				print("  Fixed " + autoload + " reference in " + file_path + " (line " + str(i + 1) + ")")
		
		new_lines.append(new_line)
	
	if modified:
		# Write the modified content back
		file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			file.store_string("\n".join(new_lines))
			file.close()
			print("Updated: " + file_path)
		else:
			push_error("Failed to write to file: " + file_path)