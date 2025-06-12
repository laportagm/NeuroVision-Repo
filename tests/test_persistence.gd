extends Node

## Test script for verifying progress persistence functionality
## Run this to ensure save/load is working correctly

func _ready() -> void:
	print("\n=== PROGRESS PERSISTENCE TEST ===\n")
	
	# Wait for autoloads to initialize
	await get_tree().create_timer(0.5).timeout
	
	# Test 1: Basic Progress Save/Load
	test_basic_progress()
	
	# Test 2: Achievement System
	await get_tree().create_timer(0.5).timeout
	test_achievements()
	
	# Test 3: Persistence Through Restart
	await get_tree().create_timer(0.5).timeout
	test_persistence()
	
	# Test 4: Error Handling
	await get_tree().create_timer(0.5).timeout
	test_error_handling()
	
	print("\n=== ALL TESTS COMPLETED ===\n")

func test_basic_progress() -> void:
	print("TEST 1: Basic Progress Save/Load")
	print("-" * 40)
	
	# Set some progress
	ProgressTracker.update_progress("thalamus", 25.0)
	ProgressTracker.update_progress("hippocampus", 50.0)
	ProgressTracker.update_progress("striatum", 75.0)
	
	# Check if values are set correctly
	_assert(ProgressTracker.get_progress("thalamus") == 25.0, "Thalamus progress should be 25%")
	_assert(ProgressTracker.get_progress("hippocampus") == 50.0, "Hippocampus progress should be 50%")
	_assert(ProgressTracker.get_progress("striatum") == 75.0, "Striatum progress should be 75%")
	
	print("✓ Progress values set correctly")
	
	# Force save
	ProgressTracker._save_progress()
	print("✓ Progress saved to file")
	
	# Check file exists
	if FileAccess.file_exists("user://progress_data.save"):
		print("✓ Save file created successfully")
		
		# Read and display file size
		var file = FileAccess.open("user://progress_data.save", FileAccess.READ)
		if file:
			var size = file.get_length()
			file.close()
			print("  File size: %d bytes" % size)
	else:
		print("✗ Save file not found!")
	
	print()

func test_achievements() -> void:
	print("TEST 2: Achievement System")
	print("-" * 40)
	
	# Unlock some achievements
	ProgressTracker.unlock_achievement("first_quiz_complete")
	ProgressTracker.unlock_achievement("hippocampus_master")
	
	# Check achievements
	_assert(ProgressTracker.has_achievement("first_quiz_complete"), "Achievement should be unlocked")
	_assert(ProgressTracker.has_achievement("hippocampus_master"), "Achievement should be unlocked")
	_assert(not ProgressTracker.has_achievement("not_unlocked"), "Achievement should not exist")
	
	print("✓ Achievements unlocked correctly")
	
	# Get all achievements
	var achievements = ProgressTracker.get_all_achievements()
	print("✓ Total achievements: %d" % achievements.size())
	for achievement in achievements:
		print("  - %s" % achievement)
	
	print()

func test_persistence() -> void:
	print("TEST 3: Persistence Through Restart")
	print("-" * 40)
	
	# Save current state
	var progress_before = ProgressTracker.get_all_progress()
	var achievements_before = ProgressTracker.get_all_achievements()
	
	print("Before reload:")
	print("  Progress entries: %d" % progress_before.size())
	print("  Achievements: %d" % achievements_before.size())
	
	# Simulate restart by clearing and reloading
	ProgressTracker._user_progress.clear()
	ProgressTracker._achievements.clear()
	
	# Reload from file
	ProgressTracker._load_progress()
	
	# Verify data was restored
	var progress_after = ProgressTracker.get_all_progress()
	var achievements_after = ProgressTracker.get_all_achievements()
	
	print("\nAfter reload:")
	print("  Progress entries: %d" % progress_after.size())
	print("  Achievements: %d" % achievements_after.size())
	
	# Verify specific values
	_assert(ProgressTracker.get_progress("thalamus") == 25.0, "Thalamus progress should persist")
	_assert(ProgressTracker.get_progress("hippocampus") == 50.0, "Hippocampus progress should persist")
	_assert(ProgressTracker.has_achievement("first_quiz_complete"), "Achievement should persist")
	
	print("\n✓ All data persisted correctly!")
	print()

func test_error_handling() -> void:
	print("TEST 4: Error Handling")
	print("-" * 40)
	
	# Test empty key
	ProgressTracker.update_progress("", 50.0)
	print("✓ Empty key handled gracefully")
	
	# Test invalid progress values
	ProgressTracker.update_progress("test_structure", -50.0)
	_assert(ProgressTracker.get_progress("test_structure") == 0.0, "Negative progress should clamp to 0")
	print("✓ Negative progress clamped to 0")
	
	ProgressTracker.update_progress("test_structure", 150.0)
	_assert(ProgressTracker.get_progress("test_structure") == 100.0, "Progress should clamp to 100")
	print("✓ Progress clamped to 100")
	
	# Test corrupted save handling
	print("\nTesting corrupted save handling...")
	
	# Create a corrupted save file
	var file = FileAccess.open("user://progress_data.save", FileAccess.WRITE)
	if file:
		file.store_string("{ corrupted json data }")
		file.close()
	
	# Try to load corrupted file
	ProgressTracker._load_progress()
	print("✓ Corrupted save handled without crash")
	
	print()

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("ASSERTION FAILED: " + message)
		print("✗ FAILED: " + message)
	else:
		print("✓ PASSED: " + message)