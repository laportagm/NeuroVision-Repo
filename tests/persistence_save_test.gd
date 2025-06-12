extends Node

func _ready() -> void:
	print("\n=== SAVING TEST PROGRESS ===\n")
	
	# Add some test progress
	print("Adding test progress...")
	ProgressTracker.update_progress("hippocampus", 75.0)
	ProgressTracker.update_progress("thalamus", 50.0)
	ProgressTracker.update_progress("striatum", 25.0)
	
	# Add some achievements
	print("Unlocking achievements...")
	ProgressTracker.unlock_achievement("first_structure_explored")
	ProgressTracker.unlock_achievement("quiz_master")
	
	# Show current state
	print("\nCurrent progress:")
	var progress = ProgressTracker.get_all_progress()
	for key in progress:
		print("  %s: %.1f%%" % [key, progress[key]])
	
	print("\nCurrent achievements:")
	var achievements = ProgressTracker.get_all_achievements()
	for achievement in achievements:
		print("  - %s" % achievement)
	
	# Force save
	print("\nForcing save...")
	ProgressTracker._save_progress()
	
	# Wait then quit
	await get_tree().create_timer(0.5).timeout
	print("\nTest complete! Exiting...")
	get_tree().quit()