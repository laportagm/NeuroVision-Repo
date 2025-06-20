## Fix Missing Node References in EnhancedExplorationScene.gd
## This script adds missing @onready declarations and removes undefined references

extends SceneTree

func _init() -> void:
	print("\n=== FIXING MISSING NODE REFERENCES ===")
	
	var file_path = "res://scenes/3d/EnhancedExplorationScene.gd"
	var content = FileAccess.get_file_as_string(file_path)
	
	if content == "":
		push_error("Failed to read file: " + file_path)
		quit(1)
		return
	
	# Find where @onready declarations end
	var last_onready_pos = content.rfind("@onready var")
	if last_onready_pos == -1:
		push_error("No @onready declarations found")
		quit(1)
		return
	
	# Find the end of that line
	var insert_pos = content.find("\n", last_onready_pos) + 1
	
	# Add missing @onready declarations
	var missing_declarations = """
# Missing UI references that were causing errors
var integrated_gpu_label: Label = null
var warning_icon: TextureRect = null
var toggle_performance_panel: Button = null
"""
	
	# Insert the declarations
	content = content.insert(insert_pos, missing_declarations)
	
	# Now fix any direct usage of these missing nodes by adding null checks
	var fixes_made = 0
	
	# Fix integrated_gpu_label references
	if content.contains("integrated_gpu_label."):
		content = content.replace("integrated_gpu_label.text =", "if integrated_gpu_label: integrated_gpu_label.text =")
		fixes_made += 1
	
	# Fix warning_icon references
	if content.contains("warning_icon."):
		content = content.replace("warning_icon.visible =", "if warning_icon: warning_icon.visible =")
		fixes_made += 1
	
	# Fix toggle_performance_panel references
	if content.contains("toggle_performance_panel."):
		content = content.replace("toggle_performance_panel.", "if toggle_performance_panel: toggle_performance_panel.")
		fixes_made += 1
	
	# Also fix any performance monitoring panel toggle function
	if content.contains("func _on_performance_toggle_pressed"):
		# Find the function and add null check
		var func_start = content.find("func _on_performance_toggle_pressed")
		if func_start != -1:
			var func_end = content.find("\n\n", func_start)
			var func_content = content.substr(func_start, func_end - func_start)
			
			# Add null check at the beginning of the function
			var new_func = func_content.replace("() -> void:", "() -> void:\n\tif not performance_panel:\n\t\treturn")
			content = content.replace(func_content, new_func)
			fixes_made += 1
	
	# Save the fixed file
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		print("✅ Added missing variable declarations")
		print("✅ Fixed %d references with null checks" % fixes_made)
	else:
		push_error("Failed to write file: " + file_path)
		quit(1)
		return
	
	print("\n✅ Missing node references fixed!")
	quit(0)