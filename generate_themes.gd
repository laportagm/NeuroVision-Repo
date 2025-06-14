@tool
extends EditorScript

## Quick runner for NeuroVision theme generation
## Run this script from Godot Editor: Tools > Execute Script

func _run() -> void:
	print("=== Running NeuroVision Theme Generation ===")
	
	# Load and run the main theme generator
	var generator_script = load("res://src/ui/themes/GenerateNeuroVisionThemes.gd")
	if generator_script:
		var generator = generator_script.new()
		generator._run()
	else:
		push_error("Failed to load NeuroVision theme generator")