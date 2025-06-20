## Fix Autoload References in Scripts
## This script updates references to use get_node_or_null for safer autoload access

extends SceneTree

func _init() -> void:
	print("\n=== FIXING AUTOLOAD REFERENCES ===")
	
	# Fix EnhancedExplorationScene.gd
	fix_enhanced_exploration_scene()
	
	# Fix BrainInteractionController.gd
	fix_brain_interaction_controller()
	
	print("\n✅ Autoload references fixed!")
	quit(0)

func fix_enhanced_exploration_scene() -> void:
	print("\n[1] Fixing EnhancedExplorationScene.gd...")
	
	var file_path = "res://scenes/3d/EnhancedExplorationScene.gd"
	var content = FileAccess.get_file_as_string(file_path)
	
	if content == "":
		push_error("Failed to read file: " + file_path)
		return
	
	# Fix ProgressTracker references
	content = content.replace("if ProgressTracker:", "if get_node_or_null(\"/root/ProgressTracker\"):")
	content = content.replace("ProgressTracker.track_", "get_node(\"/root/ProgressTracker\").track_")
	content = content.replace("ProgressTracker.record_", "get_node(\"/root/ProgressTracker\").record_")
	
	# Add variable declaration at the top of _ready if needed
	if not content.contains("var progress_tracker"):
		var ready_pos = content.find("func _ready() -> void:")
		if ready_pos != -1:
			var insert_pos = content.find("\n", ready_pos) + 1
			var indent = "\t"
			var new_line = indent + "var progress_tracker = get_node_or_null(\"/root/ProgressTracker\")\n"
			content = content.insert(insert_pos, new_line)
	
	# Save the fixed file
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		print("  ✓ Fixed ProgressTracker references")
	else:
		push_error("Failed to write file: " + file_path)

func fix_brain_interaction_controller() -> void:
	print("\n[2] Fixing BrainInteractionController.gd...")
	
	var file_path = "res://src/systems/3d_interaction/BrainInteractionController.gd"
	var content = FileAccess.get_file_as_string(file_path)
	
	if content == "":
		push_error("Failed to read file: " + file_path)
		return
	
	# Fix GraphicsOptimizationManager reference
	var old_line = "if GraphicsOptimizationManager and GraphicsOptimizationManager.is_low_end_gpu():"
	var new_line = "var graphics_mgr = get_node_or_null(\"/root/GraphicsOptimizationManager\")\n\tif graphics_mgr and graphics_mgr.is_low_end_gpu():"
	
	content = content.replace(old_line, new_line)
	
	# Save the fixed file
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		print("  ✓ Fixed GraphicsOptimizationManager reference")
	else:
		push_error("Failed to write file: " + file_path)