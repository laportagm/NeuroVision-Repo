class_name LearningProgressManagerClass
extends Node

## Manages learning progress tracking and analytics for the educational platform
##
## This singleton tracks student interactions with brain structures, quiz performance,
## and provides learning path suggestions based on educational objectives.

signal progress_updated(structure_id: String, progress_data: Dictionary)
signal milestone_achieved(milestone_type: String, milestone_data: Dictionary)
signal study_session_started()
signal study_session_ended(session_data: Dictionary)

# === CONSTANTS ===
const SAVE_PATH = "user://learning_progress.save"
const SESSION_SAVE_PATH = "user://study_sessions.save"
const PROGRESS_VERSION = "1.0"

# Progress states for structures
enum ProgressState {
	NOT_VIEWED,
	VIEWED,
	STUDIED,
	TESTED,
	MASTERED
}

# Milestone types
const MILESTONES = {
	"first_structure": {"threshold": 1, "title": "First Steps", "description": "Viewed your first brain structure"},
	"five_structures": {"threshold": 5, "title": "Explorer", "description": "Viewed 5 different structures"},
	"all_major": {"threshold": 10, "title": "Anatomist", "description": "Studied all major brain structures"},
	"quiz_master": {"threshold": 5, "title": "Quiz Master", "description": "Completed 5 quizzes successfully"},
	"perfect_score": {"threshold": 1, "title": "Perfect Score", "description": "Achieved 100% on a quiz"},
	"study_streak_3": {"threshold": 3, "title": "Dedicated Learner", "description": "3-day study streak"},
	"study_streak_7": {"threshold": 7, "title": "Committed Student", "description": "7-day study streak"},
	"deep_dive": {"threshold": 1, "title": "Deep Dive", "description": "Spent 10+ minutes studying a single structure"}
}

# === EXPORTS ===
@export var auto_save_interval: float = 30.0  # Auto-save every 30 seconds
@export var session_timeout: float = 300.0  # 5 minutes of inactivity
@export_group("Learning Path")
@export var suggest_next_structure: bool = true
@export var adaptive_difficulty: bool = true

# === PRIVATE VARIABLES ===
var _progress_data: Dictionary = {}  # structure_id -> progress info
var _session_data: Dictionary = {}
var _current_session_start: float = 0.0
var _last_activity_time: float = 0.0
var _auto_save_timer: Timer
var _session_timer: Timer
var _achieved_milestones: Array = []
var _quiz_history: Array = []
var _study_time_by_structure: Dictionary = {}  # structure_id -> total seconds

# === PUBLIC METHODS ===

func _ready() -> void:
	"""Initialize progress tracking system"""
	_load_progress_data()
	_setup_timers()
	
	# Start new study session
	start_study_session()
	
	print("[LearningProgressManager] Initialized with ", _progress_data.size(), " tracked structures")

func start_study_session() -> void:
	"""Start a new study session"""
	_current_session_start = Time.get_ticks_msec() / 1000.0
	_last_activity_time = _current_session_start
	
	_session_data = {
		"start_time": Time.get_datetime_string_from_system(),
		"structures_viewed": [],
		"structures_studied": [],
		"quizzes_completed": 0,
		"correct_answers": 0,
		"total_answers": 0,
		"duration": 0.0
	}
	
	study_session_started.emit()
	print("[LearningProgressManager] Study session started")

func end_study_session() -> void:
	"""End the current study session"""
	if _current_session_start == 0.0:
		return
	
	var duration = (Time.get_ticks_msec() / 1000.0) - _current_session_start
	_session_data["duration"] = duration
	_session_data["end_time"] = Time.get_datetime_string_from_system()
	
	# Save session
	_save_session()
	
	study_session_ended.emit(_session_data)
	print("[LearningProgressManager] Study session ended. Duration: ", duration, " seconds")
	
	_current_session_start = 0.0

func record_structure_viewed(structure_id: String) -> void:
	"""Record that a structure was viewed"""
	_last_activity_time = Time.get_ticks_msec() / 1000.0
	
	if not _progress_data.has(structure_id):
		_progress_data[structure_id] = _create_structure_progress()
	
	var progress = _progress_data[structure_id]
	progress["view_count"] += 1
	progress["last_viewed"] = Time.get_datetime_string_from_system()
	
	# Update state
	if progress["state"] == ProgressState.NOT_VIEWED:
		progress["state"] = ProgressState.VIEWED
		progress["first_viewed"] = progress["last_viewed"]
	
	# Track in session
	if not structure_id in _session_data["structures_viewed"]:
		_session_data["structures_viewed"].append(structure_id)
	
	# Check milestones
	_check_view_milestones()
	
	progress_updated.emit(structure_id, progress)
	_schedule_save()

func record_structure_studied(structure_id: String, duration: float) -> void:
	"""Record that a structure was studied for a duration"""
	_last_activity_time = Time.get_ticks_msec() / 1000.0
	
	if not _progress_data.has(structure_id):
		_progress_data[structure_id] = _create_structure_progress()
	
	var progress = _progress_data[structure_id]
	progress["study_time"] += duration
	progress["last_studied"] = Time.get_datetime_string_from_system()
	
	# Update total study time
	if not _study_time_by_structure.has(structure_id):
		_study_time_by_structure[structure_id] = 0.0
	_study_time_by_structure[structure_id] += duration
	
	# Update state
	if progress["state"] < ProgressState.STUDIED:
		progress["state"] = ProgressState.STUDIED
	
	# Track in session
	if not structure_id in _session_data["structures_studied"]:
		_session_data["structures_studied"].append(structure_id)
	
	# Check for deep dive milestone (10+ minutes on single structure)
	if _study_time_by_structure[structure_id] >= 600.0 and not "deep_dive" in _achieved_milestones:
		_unlock_milestone("deep_dive", {"structure_id": structure_id})
	
	progress_updated.emit(structure_id, progress)
	_schedule_save()

func record_quiz_attempt(structure_id: String, score: float, total_questions: int) -> void:
	"""Record a quiz attempt for a structure"""
	_last_activity_time = Time.get_ticks_msec() / 1000.0
	
	if not _progress_data.has(structure_id):
		_progress_data[structure_id] = _create_structure_progress()
	
	var progress = _progress_data[structure_id]
	var quiz_data = {
		"timestamp": Time.get_datetime_string_from_system(),
		"score": score,
		"total_questions": total_questions,
		"percentage": (score / total_questions) * 100.0 if total_questions > 0 else 0.0
	}
	
	progress["quiz_attempts"].append(quiz_data)
	progress["best_quiz_score"] = max(progress["best_quiz_score"], quiz_data["percentage"])
	
	# Update state
	if progress["state"] < ProgressState.TESTED:
		progress["state"] = ProgressState.TESTED
	
	# Check for mastery (90%+ score)
	if quiz_data["percentage"] >= 90.0 and progress["state"] < ProgressState.MASTERED:
		progress["state"] = ProgressState.MASTERED
	
	# Track in session
	_session_data["quizzes_completed"] += 1
	_session_data["correct_answers"] += int(score)
	_session_data["total_answers"] += total_questions
	
	# Store in history
	_quiz_history.append({
		"structure_id": structure_id,
		"data": quiz_data
	})
	
	# Check milestones
	_check_quiz_milestones(quiz_data["percentage"])
	
	progress_updated.emit(structure_id, progress)
	_schedule_save()

func get_structure_progress(structure_id: String) -> Dictionary:
	"""Get progress data for a specific structure"""
	if _progress_data.has(structure_id):
		return _progress_data[structure_id].duplicate()
	return _create_structure_progress()

func get_overall_progress() -> Dictionary:
	"""Get overall learning progress statistics"""
	var stats = {
		"total_structures": 0,
		"viewed": 0,
		"studied": 0,
		"tested": 0,
		"mastered": 0,
		"total_study_time": 0.0,
		"average_quiz_score": 0.0,
		"study_streak": _calculate_study_streak(),
		"milestones_unlocked": _achieved_milestones.size()
	}
	
	# Calculate structure statistics
	for structure_id in _progress_data:
		var progress = _progress_data[structure_id]
		stats["total_structures"] += 1
		
		match progress["state"]:
			ProgressState.VIEWED:
				stats["viewed"] += 1
			ProgressState.STUDIED:
				stats["studied"] += 1
			ProgressState.TESTED:
				stats["tested"] += 1
			ProgressState.MASTERED:
				stats["mastered"] += 1
		
		stats["total_study_time"] += progress["study_time"]
	
	# Calculate average quiz score
	if _quiz_history.size() > 0:
		var total_percentage = 0.0
		for quiz in _quiz_history:
			total_percentage += quiz["data"]["percentage"]
		stats["average_quiz_score"] = total_percentage / _quiz_history.size()
	
	return stats

func get_suggested_next_structure() -> String:
	"""Get AI-suggested next structure to study"""
	if not suggest_next_structure:
		return ""
	
	# Priority 1: Not viewed structures
	var not_viewed = []
	var viewed_not_studied = []
	var studied_not_tested = []
	
	# Get known structures from knowledge service
	var all_structures = []
	if has_node("/root/LearningContentManager"):
		var content_manager = get_node_or_null("/root/LearningContentManager")
		if content_manager.has_method("get_all_structure_ids"):
			all_structures = content_manager.get_all_structure_ids()
	
	# Categorize structures
	for structure_id in all_structures:
		if not _progress_data.has(structure_id):
			not_viewed.append(structure_id)
		else:
			var progress = _progress_data[structure_id]
			match progress["state"]:
				ProgressState.VIEWED:
					viewed_not_studied.append(structure_id)
				ProgressState.STUDIED:
					studied_not_tested.append(structure_id)
	
	# Return suggestion based on priority
	if not_viewed.size() > 0:
		return not_viewed[randi() % not_viewed.size()]
	elif viewed_not_studied.size() > 0:
		return viewed_not_studied[0]  # First viewed but not studied
	elif studied_not_tested.size() > 0:
		return studied_not_tested[0]  # Ready for testing
	
	# All structures completed - suggest review of lowest scoring
	var lowest_score_id = ""
	var lowest_score = 100.0
	
	for structure_id in _progress_data:
		var progress = _progress_data[structure_id]
		if progress["best_quiz_score"] < lowest_score:
			lowest_score = progress["best_quiz_score"]
			lowest_score_id = structure_id
	
	return lowest_score_id

func get_learning_path() -> Array:
	"""Get recommended learning path based on prerequisites"""
	# This would integrate with content metadata to suggest optimal order
	# For now, return a basic progression
	var path = []
	
	# Basic structures first
	var basic_structures = ["hippocampus", "amygdala", "thalamus", "cerebellum"]
	var intermediate = ["striatum", "brainstem", "corpus_callosum"]
	var advanced = ["prefrontal_cortex", "motor_cortex", "visual_cortex"]
	
	# Add unviewed basic structures
	for structure in basic_structures:
		if not _progress_data.has(structure) or _progress_data[structure]["state"] < ProgressState.STUDIED:
			path.append(structure)
	
	# Then intermediate
	for structure in intermediate:
		if not _progress_data.has(structure) or _progress_data[structure]["state"] < ProgressState.STUDIED:
			path.append(structure)
	
	# Finally advanced
	for structure in advanced:
		if not _progress_data.has(structure) or _progress_data[structure]["state"] < ProgressState.STUDIED:
			path.append(structure)
	
	return path

func reset_progress() -> void:
	"""Reset all learning progress (for testing or new users)"""
	_progress_data.clear()
	_session_data.clear()
	_achieved_milestones.clear()
	_quiz_history.clear()
	_study_time_by_structure.clear()
	
	# Delete save files
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	if FileAccess.file_exists(SESSION_SAVE_PATH):
		DirAccess.remove_absolute(SESSION_SAVE_PATH)
	
	print("[LearningProgressManager] Progress reset")

# === PRIVATE METHODS ===

func _setup_timers() -> void:
	"""Setup auto-save and session timers"""
	# Auto-save timer
	_auto_save_timer = Timer.new()
	_auto_save_timer.wait_time = auto_save_interval
	_auto_save_timer.timeout.connect(_save_progress_data)
	add_child(_auto_save_timer)
	
	# Session timeout timer
	_session_timer = Timer.new()
	_session_timer.wait_time = 1.0  # Check every second
	_session_timer.timeout.connect(_check_session_timeout)
	add_child(_session_timer)
	_session_timer.start()

func _create_structure_progress() -> Dictionary:
	"""Create default progress data for a structure"""
	return {
		"state": ProgressState.NOT_VIEWED,
		"first_viewed": "",
		"last_viewed": "",
		"last_studied": "",
		"view_count": 0,
		"study_time": 0.0,
		"quiz_attempts": [],
		"best_quiz_score": 0.0
	}

func _check_view_milestones() -> void:
	"""Check for view-related milestones"""
	var viewed_count = 0
	for structure_id in _progress_data:
		if _progress_data[structure_id]["state"] >= ProgressState.VIEWED:
			viewed_count += 1
	
	# Check milestones
	if viewed_count >= 1 and not "first_structure" in _achieved_milestones:
		_unlock_milestone("first_structure", {"count": viewed_count})
	
	if viewed_count >= 5 and not "five_structures" in _achieved_milestones:
		_unlock_milestone("five_structures", {"count": viewed_count})
	
	if viewed_count >= 10 and not "all_major" in _achieved_milestones:
		_unlock_milestone("all_major", {"count": viewed_count})

func _check_quiz_milestones(score_percentage: float) -> void:
	"""Check for quiz-related milestones"""
	var quiz_count = _session_data["quizzes_completed"]
	
	if quiz_count >= 5 and not "quiz_master" in _achieved_milestones:
		_unlock_milestone("quiz_master", {"count": quiz_count})
	
	if score_percentage >= 100.0 and not "perfect_score" in _achieved_milestones:
		_unlock_milestone("perfect_score", {"score": score_percentage})

func _unlock_milestone(milestone_id: String, data: Dictionary = {}) -> void:
	"""Unlock a milestone achievement"""
	if milestone_id in _achieved_milestones:
		return
	
	_achieved_milestones.append(milestone_id)
	
	var milestone_info = MILESTONES[milestone_id].duplicate()
	milestone_info["unlocked_at"] = Time.get_datetime_string_from_system()
	milestone_info["data"] = data
	
	milestone_achieved.emit(milestone_id, milestone_info)
	print("[LearningProgressManager] Milestone unlocked: ", milestone_info["title"])

func _calculate_study_streak() -> int:
	"""Calculate current study streak in days"""
	# This would check daily study sessions
	# For now, return a placeholder
	return 0

func _check_session_timeout() -> void:
	"""Check if session has timed out"""
	if _current_session_start == 0.0:
		return
	
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - _last_activity_time > session_timeout:
		end_study_session()

func _schedule_save() -> void:
	"""Schedule an auto-save"""
	if _auto_save_timer and not _auto_save_timer.is_stopped():
		_auto_save_timer.stop()
	_auto_save_timer.start()

func _save_progress_data() -> void:
	"""Save progress data to disk"""
	var save_dict = {
		"version": PROGRESS_VERSION,
		"progress_data": _progress_data,
		"achieved_milestones": _achieved_milestones,
		"quiz_history": _quiz_history,
		"study_time_by_structure": _study_time_by_structure,
		"last_saved": Time.get_datetime_string_from_system()
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_dict)
		file.store_string(json_string)
		file.close()

func _load_progress_data() -> void:
	"""Load progress data from disk"""
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.data
			if data.has("version") and data["version"] == PROGRESS_VERSION:
				_progress_data = data.get("progress_data", {})
				_achieved_milestones = data.get("achieved_milestones", [])
				_quiz_history = data.get("quiz_history", [])
				_study_time_by_structure = data.get("study_time_by_structure", {})

func _save_session() -> void:
	"""Save session data"""
	var sessions = []
	
	# Load existing sessions
	if FileAccess.file_exists(SESSION_SAVE_PATH):
		var file = FileAccess.open(SESSION_SAVE_PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				sessions = json.data.get("sessions", [])
	
	# Add current session
	sessions.append(_session_data)
	
	# Keep only last 100 sessions
	if sessions.size() > 100:
		sessions = sessions.slice(-100)
	
	# Save
	var file = FileAccess.open(SESSION_SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify({"sessions": sessions})
		file.store_string(json_string)
		file.close()