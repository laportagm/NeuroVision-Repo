extends SceneTree

# Script to check for parse errors in all GDScript files
func _init():
	print("Checking for parse errors in all GDScript files...")
	var errors_found = false
	
	_check_directory("res://", errors_found)
	
	if not errors_found:
		print("✅ No parse errors found!")
	else:
		print("❌ Parse errors found - check output above")
	
	quit(1 if errors_found else 0)

func _check_directory(path: String, errors_found: bool) -> void:
	var dir = DirAccess.open(path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			_check_directory(full_path, errors_found)
		elif file_name.ends_with(".gd"):
			_check_script(full_path, errors_found)
		
		file_name = dir.get_next()

func _check_script(path: String, errors_found: bool) -> void:
	var script = load(path)
	if script == null:
		print("ERROR: Failed to load script: " + path)
		errors_found = true