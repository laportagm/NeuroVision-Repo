extends Node

## Consolidated educational platform management system
## Combines ContentManager, LearningContentManager, StructureContentService, and LearningProgressManager

signal content_loaded(content_id: String)
signal content_load_failed(content_id: String, error: String)
signal content_filtered(structure_id: String, filtered_content: Dictionary)
signal learning_level_content_updated(level: int)
signal progress_updated(structure_id: String, progress_data: Dictionary)
signal achievement_unlocked(achievement_id: String)

# === ENUMS ===

enum DisclosureLevel {
	MINIMAL,      ## Show only essential information
	BASIC,        ## Show basic educational content
	DETAILED,     ## Show detailed information
	COMPREHENSIVE ## Show all available content
}

enum ContentPriority {
	ESSENTIAL = 1,    ## Must-know information
	IMPORTANT = 2,    ## Should-know information  
	SUPPLEMENTARY = 3,## Nice-to-know information
	ADVANCED = 4      ## Specialized/research information
}

# === CONSTANTS ===

const CONTENT_PATH: String = "res://content/"
const CACHE_SIZE_MB: int = 100
const PROGRESS_SAVE_PATH: String = "user://learning_progress.save"

## Content hierarchy mapping based on learning levels
const CONTENT_HIERARCHY = {
	0: {  # BEGINNER
		"fields": ["displayName", "keyFacts", "basicFunction"],
		"max_key_facts": 3,
		"max_learning_objectives": 2,
		"priority_threshold": ContentPriority.ESSENTIAL,
		"disclosure_level": DisclosureLevel.MINIMAL,
		"content_complexity": "simplified"
	},
	1: {  # INTERMEDIATE
		"fields": ["displayName", "description", "function", "keyFacts", "learningObjectives", "clinicalRelevance", "category"],
		"max_key_facts": 6,
		"max_learning_objectives": 4,
		"priority_threshold": ContentPriority.IMPORTANT,
		"disclosure_level": DisclosureLevel.DETAILED,
		"content_complexity": "standard"
	},
	2: {  # ADVANCED
		"fields": ["displayName", "alternateNames", "description", "function", "clinicalRelevance", "connections", "learningObjectives", "keyFacts", "category", "modelNames"],
		"max_key_facts": -1,  # unlimited
		"max_learning_objectives": -1,  # unlimited
		"priority_threshold": ContentPriority.ADVANCED,
		"disclosure_level": DisclosureLevel.COMPREHENSIVE,
		"content_complexity": "detailed"
	}
}

# === PRIVATE VARIABLES ===

# Content Management
var _content_cache: Dictionary = {}
var _loading_queue: Array[String] = []
# Removed unused _structure_content_map variable

# Learning Progress
var _learning_progress: Dictionary = {}
var _current_learning_level: int = 1
var _achievements: Array[String] = []
var _study_sessions: Array[Dictionary] = []

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[EducationalPlatformManager] Initializing consolidated educational platform")
	_load_learning_progress()
	preload_essential_content()

## Content Management Methods

func load_content(content_id: String) -> void:
	"""Load educational content by ID"""
	if _content_cache.has(content_id):
		content_loaded.emit(content_id)
		return
	
	_loading_queue.append(content_id)
	_process_loading_queue()

func get_content(content_id: String) -> Dictionary:
	"""Get loaded content by ID"""
	return _content_cache.get(content_id, {})

func get_filtered_content(structure_id: String, learning_level: int = -1) -> Dictionary:
	"""Get content filtered by learning level"""
	if learning_level == -1:
		learning_level = _current_learning_level
	
	var raw_content = get_content(structure_id)
	if raw_content.is_empty():
		return {}
	
	var filtered = _filter_content_by_level(raw_content, learning_level)
	content_filtered.emit(structure_id, filtered)
	return filtered

func preload_essential_content() -> void:
	"""Preload essential educational content"""
	var essential_structures = [
		"hippocampus", "amygdala", "prefrontal_cortex", "cerebellum",
		"brainstem", "thalamus", "hypothalamus", "corpus_callosum"
	]
	
	for structure in essential_structures:
		load_content(structure)

## Learning Progress Methods

func update_progress(structure_id: String, interaction_type: String, data: Dictionary = {}) -> void:
	"""Update learning progress for a structure"""
	if not _learning_progress.has(structure_id):
		_learning_progress[structure_id] = {
			"interactions": 0,
			"time_spent": 0.0,
			"quiz_scores": [],
			"mastery_level": 0,
			"last_accessed": Time.get_unix_time_from_system()
		}
	
	var progress = _learning_progress[structure_id]
	progress.interactions += 1
	progress.last_accessed = Time.get_unix_time_from_system()
	
	match interaction_type:
		"view":
			progress.time_spent += data.get("duration", 0.0)
		"quiz":
			progress.quiz_scores.append(data.get("score", 0))
			_check_mastery_level(structure_id)
		"explore":
			progress.time_spent += data.get("duration", 0.0)
	
	progress_updated.emit(structure_id, progress)
	_save_learning_progress()

func get_progress(structure_id: String) -> Dictionary:
	"""Get learning progress for a structure"""
	return _learning_progress.get(structure_id, {})

func get_mastery_level(structure_id: String) -> int:
	"""Get mastery level for a structure (0-3)"""
	var progress = get_progress(structure_id)
	return progress.get("mastery_level", 0)

func set_learning_level(level: int) -> void:
	"""Set current learning level"""
	_current_learning_level = clamp(level, 0, 2)
	learning_level_content_updated.emit(_current_learning_level)

func get_learning_level() -> int:
	"""Get current learning level"""
	return _current_learning_level

## Achievement Methods

func unlock_achievement(achievement_id: String) -> void:
	"""Unlock an achievement"""
	if achievement_id not in _achievements:
		_achievements.append(achievement_id)
		achievement_unlocked.emit(achievement_id)
		_save_learning_progress()

func has_achievement(achievement_id: String) -> bool:
	"""Check if achievement is unlocked"""
	return achievement_id in _achievements

# === PRIVATE METHODS ===

func _process_loading_queue() -> void:
	"""Process the content loading queue"""
	while _loading_queue.size() > 0:
		var content_id = _loading_queue.pop_front()
		var content_path = CONTENT_PATH + content_id + ".json"
		
		if not FileAccess.file_exists(content_path):
			content_load_failed.emit(content_id, "Content file not found: " + content_path)
			continue
		
		var file = FileAccess.open(content_path, FileAccess.READ)
		if file == null:
			content_load_failed.emit(content_id, "Failed to open content file: " + content_path)
			continue
		
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result != OK:
			content_load_failed.emit(content_id, "Invalid JSON in content file: " + content_path)
			continue
		
		_content_cache[content_id] = json.data
		content_loaded.emit(content_id)

func _filter_content_by_level(content: Dictionary, level: int) -> Dictionary:
	"""Filter content based on learning level"""
	var hierarchy = CONTENT_HIERARCHY.get(level, CONTENT_HIERARCHY[1])
	var filtered = {}
	
	# Include only fields allowed for this level
	for field in hierarchy.fields:
		if content.has(field):
			filtered[field] = content[field]
	
	# Limit array sizes based on level
	if filtered.has("keyFacts") and hierarchy.max_key_facts > 0:
		var facts = filtered.keyFacts
		if facts is Array and facts.size() > hierarchy.max_key_facts:
			filtered.keyFacts = facts.slice(0, hierarchy.max_key_facts)
	
	if filtered.has("learningObjectives") and hierarchy.max_learning_objectives > 0:
		var objectives = filtered.learningObjectives
		if objectives is Array and objectives.size() > hierarchy.max_learning_objectives:
			filtered.learningObjectives = objectives.slice(0, hierarchy.max_learning_objectives)
	
	# Add level metadata
	filtered["_learning_level"] = level
	filtered["_disclosure_level"] = hierarchy.disclosure_level
	filtered["_content_complexity"] = hierarchy.content_complexity
	
	return filtered

func _check_mastery_level(structure_id: String) -> void:
	"""Check and update mastery level based on progress"""
	var progress = _learning_progress[structure_id]
	var interactions = progress.interactions
	var quiz_scores = progress.quiz_scores
	
	var mastery = 0
	
	# Basic mastery: 5+ interactions
	if interactions >= 5:
		mastery = 1
	
	# Intermediate mastery: 10+ interactions + average quiz score > 70%
	if interactions >= 10 and quiz_scores.size() > 0:
		var avg_score = 0.0
		for score in quiz_scores:
			avg_score += score
		avg_score /= quiz_scores.size()
		
		if avg_score >= 0.7:
			mastery = 2
	
	# Advanced mastery: 20+ interactions + average quiz score > 85%
	if interactions >= 20 and quiz_scores.size() >= 3:
		var avg_score = 0.0
		for score in quiz_scores:
			avg_score += score
		avg_score /= quiz_scores.size()
		
		if avg_score >= 0.85:
			mastery = 3
	
	progress.mastery_level = mastery

func _load_learning_progress() -> void:
	"""Load learning progress from save file"""
	if not FileAccess.file_exists(PROGRESS_SAVE_PATH):
		return
	
	var file = FileAccess.open(PROGRESS_SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("[EducationalPlatformManager] Failed to load progress file")
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result == OK:
		var data = json.data
		_learning_progress = data.get("progress", {})
		_current_learning_level = data.get("learning_level", 1)
		_achievements = data.get("achievements", [])
		_study_sessions = data.get("study_sessions", [])

func _save_learning_progress() -> void:
	"""Save learning progress to file"""
	var save_data = {
		"progress": _learning_progress,
		"learning_level": _current_learning_level,
		"achievements": _achievements,
		"study_sessions": _study_sessions,
		"last_saved": Time.get_unix_time_from_system()
	}
	
	var file = FileAccess.open(PROGRESS_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("[EducationalPlatformManager] Failed to save progress file")
		return
	
	file.store_string(JSON.stringify(save_data))
	file.close()