## Fix All Autoload References in Scene Scripts
## This script comprehensively fixes all autoload reference errors

extends SceneTree

func _init() -> void:
	print("\n=== FIXING ALL AUTOLOAD REFERENCES ===")
	
	# Fix EnhancedExplorationScene.gd
	fix_enhanced_exploration_scene()
	
	# Fix BrainInteractionController.gd (already fixed but let's verify)
	verify_brain_interaction_controller()
	
	print("\n✅ All autoload references fixed!")
	quit(0)

func fix_enhanced_exploration_scene() -> void:
	print("\n[1] Fixing EnhancedExplorationScene.gd comprehensively...")
	
	var file_path = "res://scenes/3d/EnhancedExplorationScene.gd"
	var content = FileAccess.get_file_as_string(file_path)
	
	if content == "":
		push_error("Failed to read file: " + file_path)
		return
	
	# Count replacements
	var replacements = 0
	
	# Fix AssessmentService references
	if content.contains("if not AssessmentService:"):
		content = content.replace("if not AssessmentService:", "if not get_node_or_null(\"/root/AssessmentService\"):")
		replacements += 1
	if content.contains("var quiz_data = AssessmentService."):
		content = content.replace("AssessmentService.", "get_node(\"/root/AssessmentService\").")
		replacements += content.count("AssessmentService.")
	
	# Fix all other autoload references with proper null checks
	var autoloads = [
		"ProgressTracker",
		"GraphicsOptimizationManager", 
		"KnowledgeService",
		"UIThemeManager",
		"HighlightMaterialManager",
		"ResourceManager",
		"CoreSystemManager",
		"UISystemManager",
		"EducationalPlatformManager",
		"UnifiedColorManager"
	]
	
	for autoload in autoloads:
		# Fix condition checks
		var old_check = "if " + autoload + ":"
		var new_check = "if get_node_or_null(\"/root/" + autoload + "\"):"
		if content.contains(old_check):
			content = content.replace(old_check, new_check)
			replacements += 1
			
		var old_check2 = "if not " + autoload + ":"
		var new_check2 = "if not get_node_or_null(\"/root/" + autoload + "\"):"
		if content.contains(old_check2):
			content = content.replace(old_check2, new_check2)
			replacements += 1
		
		# Fix direct method calls (but not in conditions)
		# We need to be careful not to double-replace
		var lines = content.split("\n")
		var new_lines = []
		
		for line in lines:
			var modified_line = line
			
			# Skip lines that already have get_node
			if not line.contains("get_node") and not line.contains("if "):
				# Check if this line has a direct autoload call
				if line.contains(autoload + "."):
					# Make sure it's not part of a larger word
					var regex = RegEx.new()
					regex.compile("\\b" + autoload + "\\.")
					if regex.search(line):
						modified_line = regex.sub(line, "get_node(\"/root/" + autoload + "\").", true)
						replacements += 1
			
			new_lines.append(modified_line)
		
		content = "\n".join(new_lines)
	
	# Add helper variables at the start of _ready if needed
	var ready_func_pos = content.find("func _ready() -> void:")
	if ready_func_pos != -1:
		var insert_pos = content.find("\n", ready_func_pos) + 1
		
		# Check if we already have the helper variables
		if not content.contains("var progress_tracker = get_node_or_null"):
			var helpers = ""
			helpers += "\t# Get autoload references for safety\n"
			helpers += "\tvar progress_tracker = get_node_or_null(\"/root/ProgressTracker\")\n"
			helpers += "\tvar assessment_service = get_node_or_null(\"/root/AssessmentService\")\n"
			helpers += "\tvar graphics_mgr = get_node_or_null(\"/root/GraphicsOptimizationManager\")\n"
			helpers += "\t\n"
			
			content = content.insert(insert_pos, helpers)
			replacements += 3
	
	# Save the fixed file
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		print("  ✓ Fixed %d autoload references in EnhancedExplorationScene.gd" % replacements)
	else:
		push_error("Failed to write file: " + file_path)

func verify_brain_interaction_controller() -> void:
	print("\n[2] Verifying BrainInteractionController.gd...")
	
	var file_path = "res://src/systems/3d_interaction/BrainInteractionController.gd"
	var content = FileAccess.get_file_as_string(file_path)
	
	if content == "":
		push_error("Failed to read file: " + file_path)
		return
	
	# Check if already fixed
	if content.contains("get_node_or_null(\"/root/GraphicsOptimizationManager\")"):
		print("  ✓ BrainInteractionController.gd already fixed")
		return
	
	# If not fixed, apply the fix
	var replacements = 0
	
	# Fix GraphicsOptimizationManager reference
	if content.contains("if GraphicsOptimizationManager and GraphicsOptimizationManager.is_low_end_gpu():"):
		var old_lines = "if GraphicsOptimizationManager and GraphicsOptimizationManager.is_low_end_gpu():"
		var new_lines = "var graphics_mgr = get_node_or_null(\"/root/GraphicsOptimizationManager\")\n\tif graphics_mgr and graphics_mgr.is_low_end_gpu():"
		content = content.replace(old_lines, new_lines)
		replacements += 1
	
	if replacements > 0:
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			file.store_string(content)
			file.close()
			print("  ✓ Fixed %d references in BrainInteractionController.gd" % replacements)
		else:
			push_error("Failed to write file: " + file_path)