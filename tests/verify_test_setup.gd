extends Node

## Script to verify test setup is working

func _ready():
	print("=== Verifying Test Setup ===")
	
	# Check if GutTest class is available
	var test_script = load("res://tests/GutTest.gd")
	if test_script:
		print("✓ GutTest.gd loaded successfully")
	else:
		print("✗ Failed to load GutTest.gd")
	
	# Try to create a test instance
	var test_instance = GutTest.new()
	if test_instance:
		print("✓ GutTest instance created successfully")
		test_instance.queue_free()
	else:
		print("✗ Failed to create GutTest instance")
	
	# Check if TestBase is available
	if ClassDB.class_exists("TestBase"):
		print("✓ TestBase class registered")
	else:
		print("✗ TestBase class not found")
	
	# Check if GutTest is available
	if ClassDB.class_exists("GutTest"):
		print("✓ GutTest class registered")
	else:
		print("✗ GutTest class not found")
	
	print("\n=== Checking Test Files ===")
	
	# List test files
	var test_files = [
		"res://tests/unit/test_autoload_fixes.gd",
		"res://tests/unit/test_brain_interaction_controller.gd",
		"res://tests/unit/test_level3_brain_model.gd",
		"res://tests/unit/test_level5_content_management.gd",
		"res://tests/unit/test_level6_enhanced_interaction.gd",
		"res://tests/unit/test_level7_assessment_system.gd"
	]
	
	for test_file in test_files:
		if ResourceLoader.exists(test_file):
			print("✓ Found: " + test_file)
			var script = load(test_file)
			if script:
				print("  → Loaded successfully")
			else:
				print("  → Failed to load!")
		else:
			print("✗ Missing: " + test_file)
	
	print("\n=== Setup Complete ===")
	get_tree().quit()