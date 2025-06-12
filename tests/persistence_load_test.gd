extends Node

func _ready() -> void:
	print("\n=== LOADING SAVED PROGRESS ===\n")
	
	# Give time for autoloads to initialize and load
	await get_tree().create_timer(0.5).timeout
	
	# Show loaded progress
	print("Loaded progress:")
	var progress = ProgressTracker.get_all_progress()
	if progress.is_empty():
		print("  No progress data found!")
	else:
		for key in progress:
			print("  %s: %.1f%%" % [key, progress[key]])
	
	print("\nLoaded achievements:")
	var achievements = ProgressTracker.get_all_achievements()
	if achievements.is_empty():
		print("  No achievements found!")
	else:
		for achievement in achievements:
			print("  - %s" % achievement)
	
	# Check specific values
	print("\nVerifying specific values:")
	print("  Hippocampus progress: %.1f%% (expected: 75.0%%)" % ProgressTracker.get_progress("hippocampus"))
	print("  Thalamus progress: %.1f%% (expected: 50.0%%)" % ProgressTracker.get_progress("thalamus"))
	print("  Has 'quiz_master' achievement: %s (expected: true)" % ProgressTracker.has_achievement("quiz_master"))
	
	# Wait then quit
	await get_tree().create_timer(0.5).timeout
	print("\nTest complete! Exiting...")
	get_tree().quit()