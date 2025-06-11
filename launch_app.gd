extends Node

## Simple launcher to start the app and report what happens

func _ready():
	print("\n=== NeuroVision App Launch Test ===\n")
	
	print("Starting from MainMenu...")
	
	# Load and switch to main menu
	var menu_scene = load("res://src/ui/screens/MainMenu.tscn")
	if menu_scene:
		print("✓ MainMenu loaded")
		get_tree().change_scene_to_packed(menu_scene)
		
		# Wait a moment
		await get_tree().create_timer(1.0).timeout
		
		print("\nApp should now be showing the main menu.")
		print("Click 'Start Exploration' to load the 3D brain model.")
		print("\nThe brain model should replace the placeholder cube.")
		print("You should see 5 brain structures:")
		print("  - Thalami")
		print("  - Hippocampus")
		print("  - Striatum")
		print("  - Ventricles")
		print("  - Corpus Callosum")
		print("\nControls:")
		print("  - Right-click: Select structures")
		print("  - Left-click + drag: Rotate view")
		print("  - Mouse wheel: Zoom")
		print("  - Keys 1-8: Camera presets")
		print("  - L: Toggle labels")
		print("  - Q: Open quiz")
		
	else:
		print("✗ Failed to load MainMenu")
		get_tree().quit(1)