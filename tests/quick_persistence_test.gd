extends SceneTree

func _init():
	print("\n=== QUICK PERSISTENCE TEST ===\n")
	
	# Wait for autoloads
	await create_timer(0.1).timeout
	
	# Add some test progress
	print("Adding test progress...")
	ProgressTracker.update_progress("hippocampus", 75.0)
	ProgressTracker.update_progress("thalamus", 50.0)
	ProgressTracker.update_progress("striatum", 25.0)
	
	# Add some achievements
	print("Unlocking achievements...")
	ProgressTracker.unlock_achievement("first_structure_explored")
	ProgressTracker.unlock_achievement("quiz_master")
	
	# Force save
	print("Forcing save...")
	ProgressTracker._save_progress()
	
	# Wait a moment
	await create_timer(0.5).timeout
	
	print("\nTest complete! Progress should be saved.")
	quit()