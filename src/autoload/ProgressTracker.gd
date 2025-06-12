extends Node

## Tracks user learning progress and achievements
##
## This service manages all learning progress and achievement tracking for the NeuroVision
## educational platform. It uses a JSON-based persistence system (SimplePersistence.gd)
## with automatic saving every 30 seconds and on application exit.
##
## Features:
## - Progress tracking per brain structure
## - Achievement system with timestamps
## - Automatic saving with backup protection
## - Thread-safe operations
## - Graceful corruption recovery
##
## The persistence system saves to:
## - Main file: user://progress_data.save
## - Backup: user://progress_data.save.backup

signal progress_updated(category: String, progress: float)
signal achievement_unlocked(achievement_id: String)
signal save_completed(success: bool)
signal load_completed(success: bool)

# === CONSTANTS ===
const SAVE_PATH: String = "user://progress.save"  # Legacy path, kept for reference
const PERSISTENCE_ENABLED: bool = true  # Feature flag for easy enable/disable
const AUTOSAVE_INTERVAL: float = 30.0  # Save every 30 seconds

# Preload the SimplePersistence class
const SimplePersistenceClass = preload("res://src/systems/persistence/SimplePersistence.gd")

# === PRIVATE VARIABLES ===
var _user_progress: Dictionary = {}
var _achievements: Dictionary = {}
var _persistence
var _autosave_timer: Timer
var _last_save_time: float = 0.0

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[Progress] Tracker initialized")
	
	# Initialize persistence system
	if PERSISTENCE_ENABLED:
		_persistence = SimplePersistenceClass.new()
		add_child(_persistence)
		_setup_autosave()
		print("[Progress] Persistence enabled with autosave every %.0f seconds" % AUTOSAVE_INTERVAL)
	else:
		print("[Progress] Persistence disabled by feature flag")
	
	_load_progress()

func update_progress(category: String, amount: float) -> void:
	"""Update progress in a specific category"""
	if not _user_progress.has(category):
		_user_progress[category] = 0.0
	
	_user_progress[category] = clamp(_user_progress[category] + amount, 0.0, 100.0)
	progress_updated.emit(category, _user_progress[category])
	_save_progress()

func get_progress(category: String) -> float:
	"""Get progress for a specific category"""
	return _user_progress.get(category, 0.0)

func unlock_achievement(achievement_id: String) -> void:
	"""Unlock an achievement"""
	if not _achievements.has(achievement_id):
		_achievements[achievement_id] = Time.get_ticks_msec()
		achievement_unlocked.emit(achievement_id)
		_save_progress()

func get_all_progress() -> Dictionary:
	"""Get all progress data"""
	return _user_progress.duplicate()

func get_all_achievements() -> Dictionary:
	"""Get all achievements"""
	return _achievements.duplicate()

func has_achievement(achievement_id: String) -> bool:
	"""Check if an achievement is unlocked"""
	return _achievements.has(achievement_id)

func reset_all_progress() -> void:
	"""Reset all progress (use with caution!)"""
	_user_progress.clear()
	_achievements.clear()
	_save_progress()
	print("[Progress] All progress has been reset")

# === PRIVATE METHODS ===

func _setup_autosave() -> void:
	"""Setup autosave timer"""
	_autosave_timer = Timer.new()
	_autosave_timer.wait_time = AUTOSAVE_INTERVAL
	_autosave_timer.timeout.connect(_on_autosave_timeout)
	_autosave_timer.autostart = true
	add_child(_autosave_timer)

func _on_autosave_timeout() -> void:
	"""Called when autosave timer triggers"""
	_save_progress()

func _load_progress() -> void:
	"""Load progress from save file"""
	if not PERSISTENCE_ENABLED or not _persistence:
		print("[Progress] Skipping load - persistence disabled or not initialized")
		load_completed.emit(false)
		return
	
	print("[Progress] Loading saved progress...")
	
	# Load from persistence system
	var success = _persistence.load_from_file()
	
	if success:
		# Load user progress
		var saved_progress = _persistence.load_data("user_progress")
		if saved_progress != null and saved_progress is Dictionary:
			_user_progress = saved_progress
			print("[Progress] Loaded progress for %d categories" % _user_progress.size())
			
			# Debug: Print loaded progress
			for category in _user_progress:
				print("[Progress]   - %s: %.1f%%" % [category, _user_progress[category]])
		else:
			print("[Progress] No saved progress data found, starting fresh")
		
		# Load achievements
		var saved_achievements = _persistence.load_data("achievements")
		if saved_achievements != null and saved_achievements is Dictionary:
			_achievements = saved_achievements
			print("[Progress] Loaded %d achievements" % _achievements.size())
		else:
			print("[Progress] No saved achievements found")
		
		# Load metadata
		var save_metadata = _persistence.load_data("metadata")
		if save_metadata != null and save_metadata is Dictionary:
			_last_save_time = save_metadata.get("last_save_time", 0.0)
			var last_save_date = Time.get_datetime_string_from_unix_time(int(_last_save_time))
			print("[Progress] Last save was at: " + last_save_date)
	else:
		print("[Progress] Failed to load progress, starting with empty data")
	
	load_completed.emit(success)

func _save_progress() -> void:
	"""Save progress to file"""
	if not PERSISTENCE_ENABLED or not _persistence:
		print("[Progress] Skipping save - persistence disabled or not initialized")
		save_completed.emit(false)
		return
	
	print("[Progress] Saving progress...")
	
	# Save user progress
	_persistence.save_data("user_progress", _user_progress)
	
	# Save achievements
	_persistence.save_data("achievements", _achievements)
	
	# Save metadata
	var metadata = {
		"last_save_time": Time.get_unix_time_from_system(),
		"godot_version": Engine.get_version_info(),
		"total_categories": _user_progress.size(),
		"total_achievements": _achievements.size()
	}
	_persistence.save_data("metadata", metadata)
	
	# Actually write to file
	var success = _persistence.save_to_file()
	
	if success:
		_last_save_time = Time.get_unix_time_from_system()
		print("[Progress] Progress saved successfully")
		
		# Debug: Show what was saved
		print("[Progress] Saved data summary:")
		print("[Progress]   - Categories: %d" % _user_progress.size())
		print("[Progress]   - Achievements: %d" % _achievements.size())
		print("[Progress]   - File size: %d bytes" % _persistence.get_save_file_size())
	else:
		push_error("[Progress] Failed to save progress!")
	
	save_completed.emit(success)

func _notification(what: int) -> void:
	"""Handle node notifications"""
	if what == NOTIFICATION_PREDELETE:
		# Save one final time before the node is destroyed
		if PERSISTENCE_ENABLED and _persistence:
			print("[Progress] Performing final save before exit...")
			_save_progress()
