extends Node

## Manages educational content hierarchy and progressive disclosure based on learning levels
## Provides filtered content based on UIAdaptationManager's current learning level

signal content_filtered(structure_id: String, filtered_content: Dictionary)
signal learning_level_content_updated(level: int)
signal content_disclosure_changed(structure_id: String, disclosure_level: int)

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

## Content hierarchy mapping based on learning levels (using integer keys)
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
		"content_complexity": "complete"
	}
}

## Progressive disclosure steps for smooth transitions
const DISCLOSURE_STEPS = {
	DisclosureLevel.MINIMAL: ["displayName", "keyFacts"],
	DisclosureLevel.BASIC: ["displayName", "keyFacts", "function"],
	DisclosureLevel.DETAILED: ["displayName", "keyFacts", "function", "description", "clinicalRelevance"],
	DisclosureLevel.COMPREHENSIVE: ["displayName", "keyFacts", "function", "description", "clinicalRelevance", "connections", "learningObjectives", "alternateNames"]
}

## Content field priorities for filtering
const FIELD_PRIORITIES = {
	"displayName": ContentPriority.ESSENTIAL,
	"keyFacts": ContentPriority.ESSENTIAL,
	"function": ContentPriority.IMPORTANT,
	"description": ContentPriority.IMPORTANT,
	"clinicalRelevance": ContentPriority.IMPORTANT,
	"learningObjectives": ContentPriority.SUPPLEMENTARY,
	"category": ContentPriority.SUPPLEMENTARY,
	"connections": ContentPriority.ADVANCED,
	"alternateNames": ContentPriority.ADVANCED,
	"modelNames": ContentPriority.ADVANCED
}

# === PRIVATE VARIABLES ===
# var _current_learning_level: UIAdaptationManager.LearningLevel = UIAdaptationManager.LearningLevel.INTERMEDIATE
var _current_learning_level: int = 1  # INTERMEDIATE
var _filtered_content_cache: Dictionary = {}
var _disclosure_levels: Dictionary = {}  # Track disclosure level per structure
var _content_metadata_cache: Dictionary = {}

# === PUBLIC METHODS ===

func _ready() -> void:
	"""Initialize learning content manager"""
	print("[LearningContentManager] Initializing content hierarchy system")
	
	# Connect to UIAdaptationManager for learning level changes
	if has_node("/root/UIAdaptationManager"):
		var ui_mgr = get_node("/root/UIAdaptationManager")
		ui_mgr.learning_level_changed.connect(_on_learning_level_changed)
		_current_learning_level = ui_mgr.get_learning_level()
		print("[LearningContentManager] Connected to UIAdaptationManager - Level: " + str(_current_learning_level))
	
	# Connect to StructureContentService for content updates
	if has_node("/root/StructureContentService"):
		var content_svc = get_node("/root/StructureContentService")
		content_svc.content_ready.connect(_on_structure_content_ready)
		print("[LearningContentManager] Connected to StructureContentService")
	
	# Initialize content hierarchy for current level
	_update_content_hierarchy()
	
	print("[LearningContentManager] Content hierarchy system ready")

func get_filtered_content(structure_id: String) -> Dictionary:
	"""Get content filtered for current learning level"""
	if not EducationalPlatformManager:
		push_warning("[LearningContentManager] EducationalPlatformManager not available")
		return {}
	
	# Check cache first
	var cache_key = structure_id + "_" + str(_current_learning_level)
	if _filtered_content_cache.has(cache_key):
		return _filtered_content_cache[cache_key].duplicate(true)
	
	# Get raw content from EducationalPlatformManager
	var raw_content = EducationalPlatformManager.get_content(structure_id)
	if raw_content.is_empty():
		push_warning("[LearningContentManager] No content found for structure: " + structure_id)
		return {}
	
	# Filter content based on current learning level
	var filtered_content = _filter_content_by_level(raw_content, _current_learning_level)
	
	# Cache the filtered content
	_filtered_content_cache[cache_key] = filtered_content.duplicate(true)
	
	# Emit signal
	content_filtered.emit(structure_id, filtered_content)
	
	print("[LearningContentManager] Filtered content for '" + structure_id + "' at level " + str(_current_learning_level))
	return filtered_content

func get_progressive_content(structure_id: String, disclosure_level: DisclosureLevel) -> Dictionary:
	"""Get content with specific disclosure level for progressive reveal"""
	# Use EducationalPlatformManager for content management
	if not EducationalPlatformManager:
		push_error("[LearningContentManager] EducationalPlatformManager not available")
		return {}
	
	var raw_content = EducationalPlatformManager.get_content(structure_id)
	if raw_content.is_empty():
		return {}
	
	var progressive_content = _filter_content_by_disclosure(raw_content, disclosure_level)
	
	# Track disclosure level for this structure
	_disclosure_levels[structure_id] = disclosure_level
	
	# Emit signal
	content_disclosure_changed.emit(structure_id, disclosure_level)
	
	return progressive_content

func advance_disclosure_level(structure_id: String) -> Dictionary:
	"""Advance to next disclosure level for progressive reveal"""
	var current_level = _disclosure_levels.get(structure_id, DisclosureLevel.MINIMAL)
	var next_level = min(current_level + 1, DisclosureLevel.COMPREHENSIVE)
	
	if next_level != current_level:
		return get_progressive_content(structure_id, next_level)
	else:
		# Already at maximum disclosure
		return get_filtered_content(structure_id)

func get_content_metadata(structure_id: String) -> Dictionary:
	"""Get metadata about content filtering and availability"""
	var cache_key = structure_id + "_meta"
	if _content_metadata_cache.has(cache_key):
		return _content_metadata_cache[cache_key]
	
	var raw_content = StructureContentService.get_structure_content(structure_id)
	if raw_content.is_empty():
		return {}
	
	var metadata = _generate_content_metadata(raw_content)
	_content_metadata_cache[cache_key] = metadata
	
	return metadata

func get_learning_level_summary() -> Dictionary:
	"""Get summary of content available at current learning level"""
	var hierarchy = CONTENT_HIERARCHY.get(_current_learning_level, {})
	
	return {
		"learning_level": _current_learning_level,
		"available_fields": hierarchy.get("fields", []),
		"max_key_facts": hierarchy.get("max_key_facts", 0),
		"max_learning_objectives": hierarchy.get("max_learning_objectives", 0),
		"content_complexity": hierarchy.get("content_complexity", "unknown"),
		"disclosure_level": hierarchy.get("disclosure_level", DisclosureLevel.BASIC)
	}

func is_field_available_at_level(field_name: String, level: int = _current_learning_level) -> bool:
	"""Check if a field is available at the specified learning level"""
	var hierarchy = CONTENT_HIERARCHY.get(level, {})
	var available_fields = hierarchy.get("fields", [])
	return field_name in available_fields

func get_field_priority(field_name: String) -> ContentPriority:
	"""Get the priority level of a content field"""
	return FIELD_PRIORITIES.get(field_name, ContentPriority.SUPPLEMENTARY)

func clear_content_cache() -> void:
	"""Clear all cached filtered content"""
	_filtered_content_cache.clear()
	_content_metadata_cache.clear()
	print("[LearningContentManager] Content cache cleared")

func get_content_complexity_description(level: int = _current_learning_level) -> String:
	"""Get description of content complexity for learning level"""
	match level:
		0:  # BEGINNER
			return "Essential concepts with simplified explanations"
		1:  # INTERMEDIATE
			return "Standard educational content with clinical context"
		2:  # ADVANCED
			return "Comprehensive information including research details"
		_:
			return "Unknown complexity level"

# === PRIVATE METHODS ===

func _filter_content_by_level(raw_content: Dictionary, level: int) -> Dictionary:
	"""Filter content based on learning level hierarchy"""
	var hierarchy = CONTENT_HIERARCHY.get(level, {})
	if hierarchy.is_empty():
		push_warning("[LearningContentManager] No hierarchy defined for level: " + str(level))
		return raw_content
	
	var filtered = {}
	var available_fields = hierarchy.get("fields", [])
	
	# Copy available fields
	for field in available_fields:
		if raw_content.has(field):
			var field_content = raw_content[field]
			
			# Apply field-specific filtering
			match field:
				"keyFacts":
					field_content = _filter_key_facts(field_content, hierarchy.get("max_key_facts", -1))
				"learningObjectives":
					field_content = _filter_learning_objectives(field_content, hierarchy.get("max_learning_objectives", -1))
				"function":
					if level == 0:  # BEGINNER
						field_content = _simplify_function_description(field_content)
			
			filtered[field] = field_content
	
	# Add metadata about filtering
	filtered["_metadata"] = {
		"learning_level": level,
		"content_complexity": hierarchy.get("content_complexity", "unknown"),
		"filtered_fields": available_fields.size(),
		"total_fields": raw_content.size(),
		"disclosure_level": hierarchy.get("disclosure_level", DisclosureLevel.BASIC)
	}
	
	return filtered

func _filter_content_by_disclosure(raw_content: Dictionary, disclosure_level: DisclosureLevel) -> Dictionary:
	"""Filter content based on progressive disclosure level"""
	var available_fields = DISCLOSURE_STEPS.get(disclosure_level, [])
	var filtered = {}
	
	for field in available_fields:
		if raw_content.has(field):
			filtered[field] = raw_content[field]
	
	# Add disclosure metadata
	filtered["_metadata"] = {
		"disclosure_level": disclosure_level,
		"available_fields": available_fields,
		"can_advance": disclosure_level < DisclosureLevel.COMPREHENSIVE
	}
	
	return filtered

func _filter_key_facts(key_facts: Array, max_count: int) -> Array:
	"""Filter key facts based on priority and count limit"""
	if max_count == -1 or key_facts.size() <= max_count:
		return key_facts
	
	# For now, just take the first max_count items
	# TODO: Implement priority-based filtering
	return key_facts.slice(0, max_count)

func _filter_learning_objectives(objectives: Array, max_count: int) -> Array:
	"""Filter learning objectives based on complexity and count limit"""
	if max_count == -1 or objectives.size() <= max_count:
		return objectives
	
	# For now, just take the first max_count items
	# TODO: Implement complexity-based filtering
	return objectives.slice(0, max_count)

func _simplify_function_description(function_text: String) -> String:
	"""Simplify function description for beginner level"""
	# Split into sentences and take first sentence or two
	var sentences = function_text.split(". ")
	if sentences.size() <= 2:
		return function_text
	
	# Return first two sentences for beginners
	return sentences[0] + ". " + sentences[1] + "."

func _generate_content_metadata(raw_content: Dictionary) -> Dictionary:
	"""Generate metadata about content structure and availability"""
	var metadata = {
		"total_fields": raw_content.size(),
		"available_at_beginner": 0,
		"available_at_intermediate": 0,
		"available_at_advanced": 0,
		"field_priorities": {},
		"content_types": []
	}
	
	# Analyze field availability at each level
	for field in raw_content:
		if field.begins_with("_"):  # Skip metadata fields
			continue
			
		var priority = get_field_priority(field)
		metadata.field_priorities[field] = priority
		
		# Check availability at each level
		if is_field_available_at_level(field, 0):  # BEGINNER
			metadata.available_at_beginner += 1
		if is_field_available_at_level(field, 1):  # INTERMEDIATE
			metadata.available_at_intermediate += 1
		if is_field_available_at_level(field, 2):  # ADVANCED
			metadata.available_at_advanced += 1
		
		# Categorize content types
		if field in ["keyFacts", "learningObjectives"]:
			metadata.content_types.append("educational")
		elif field in ["clinicalRelevance", "connections"]:
			metadata.content_types.append("clinical")
		elif field in ["function", "description"]:
			metadata.content_types.append("functional")
	
	return metadata

func _update_content_hierarchy() -> void:
	"""Update content hierarchy based on current learning level"""
	# Clear caches to force regeneration
	clear_content_cache()
	
	# Emit signal to notify UI components
	learning_level_content_updated.emit(_current_learning_level)
	
	print("[LearningContentManager] Content hierarchy updated for level: " + str(_current_learning_level))

# === SIGNAL HANDLERS ===

func _on_learning_level_changed(new_level: int) -> void:
	"""Handle learning level changes"""
	if new_level != _current_learning_level:
		print("[LearningContentManager] Learning level changed from " + str(_current_learning_level) + " to " + str(new_level))
		_current_learning_level = new_level
		_update_content_hierarchy()

func _on_structure_content_ready(structure_id: String, _content: Dictionary) -> void:
	"""Handle new structure content from StructureContentService"""
	# Clear cached content for this structure
	var cache_keys_to_remove = []
	for cache_key in _filtered_content_cache:
		if cache_key.begins_with(structure_id + "_"):
			cache_keys_to_remove.append(cache_key)
	
	for key in cache_keys_to_remove:
		_filtered_content_cache.erase(key)
	
	# Clear metadata cache for this structure
	var meta_key = structure_id + "_meta"
	_content_metadata_cache.erase(meta_key)
	
	print("[LearningContentManager] Content updated for structure: " + structure_id)

# === UTILITY METHODS ===

func get_available_disclosure_levels() -> Array:
	"""Get all available disclosure levels"""
	return [DisclosureLevel.MINIMAL, DisclosureLevel.BASIC, DisclosureLevel.DETAILED, DisclosureLevel.COMPREHENSIVE]

func get_disclosure_level_description(level: DisclosureLevel) -> String:
	"""Get description of disclosure level"""
	match level:
		DisclosureLevel.MINIMAL:
			return "Essential information only"
		DisclosureLevel.BASIC:
			return "Basic educational content"
		DisclosureLevel.DETAILED:
			return "Detailed information with context"
		DisclosureLevel.COMPREHENSIVE:
			return "Complete information available"
		_:
			return "Unknown disclosure level"

func debug_content_filtering(structure_id: String) -> Dictionary:
	"""Debug information about content filtering for a structure"""
	var raw_content = EducationalPlatformManager.get_content(structure_id) if EducationalPlatformManager else {}
	var filtered_content = get_filtered_content(structure_id)
	var metadata = get_content_metadata(structure_id)
	
	return {
		"structure_id": structure_id,
		"learning_level": _current_learning_level,
		"raw_fields": raw_content.keys().size(),
		"filtered_fields": filtered_content.keys().size(),
		"available_fields": CONTENT_HIERARCHY.get(_current_learning_level, {}).get("fields", []),
		"metadata": metadata,
		"raw_content_sample": raw_content.get("displayName", "N/A"),
		"filtered_content_sample": filtered_content.get("displayName", "N/A")
	}