extends Node

## Tracks user learning progress and achievements

signal progress_updated(category: String, progress: float)
signal achievement_unlocked(achievement_id: String)

# === CONSTANTS ===
const SAVE_PATH: String = "user://progress.save"

# === PRIVATE VARIABLES ===
var _user_progress: Dictionary = {}
var _achievements: Dictionary = {}

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[Progress] Tracker initialized")
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

# === PRIVATE METHODS ===

func _load_progress() -> void:
	"""Load progress from save file"""
	# TODO: Implement save/load system
	pass

func _save_progress() -> void:
	"""Save progress to file"""
	# TODO: Implement save system
	pass
