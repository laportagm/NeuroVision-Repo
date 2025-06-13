extends Node

## Service for managing educational content about brain structures

signal content_ready(structure_id: String, content: Dictionary)
signal content_error(structure_id: String, error: String)

# === CONSTANTS ===
const CONTENT_FILE_PATH = "res://content/brain_structures.json"
const CACHE_DURATION = 3600.0  # 1 hour

# === PRIVATE VARIABLES ===
var _content_data: Dictionary = {}
var _model_name_map: Dictionary = {}  # Maps model names to structure IDs
var _is_loaded: bool = false

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[StructureContent] Service initializing...")
	_load_content_data()

func get_structure_content(structure_id_or_name: String) -> Dictionary:
	"""Get educational content for a brain structure by ID or model name"""
	if not _is_loaded:
		push_error("[StructureContent] Content not loaded yet")
		return {}
	
	print("[StructureContent] Looking up content for: '", structure_id_or_name, "'")
	
	# Try direct ID lookup first
	var structure_id = structure_id_or_name.to_lower().replace(" ", "_")
	if _content_data.has(structure_id):
		print("[StructureContent] Found by direct ID lookup: ", structure_id)
		return _content_data[structure_id].duplicate(true)
	
	# Try model name mapping
	var normalized_name = _normalize_model_name(structure_id_or_name)
	print("[StructureContent] Normalized name: '", normalized_name, "'")
	
	if _model_name_map.has(normalized_name):
		structure_id = _model_name_map[normalized_name]
		print("[StructureContent] Found by model name mapping: ", structure_id)
		return _content_data[structure_id].duplicate(true)
	
	# Try exact match without normalization
	for map_key in _model_name_map:
		if map_key == structure_id_or_name.to_lower():
			structure_id = _model_name_map[map_key]
			print("[StructureContent] Found by exact match: ", structure_id)
			return _content_data[structure_id].duplicate(true)
	
	# Fuzzy search as fallback
	print("[StructureContent] Falling back to fuzzy search")
	return _fuzzy_search_structure(structure_id_or_name)

func search_structures(query: String) -> Array:
	"""Search for structures matching a query"""
	var results = []
	var query_lower = query.to_lower()
	
	for structure_id in _content_data:
		var structure = _content_data[structure_id]
		var score = 0
		
		# Check display name
		if structure.displayName.to_lower().contains(query_lower):
			score += 10
		
		# Check alternate names
		for alt_name in structure.get("alternateNames", []):
			if alt_name.to_lower().contains(query_lower):
				score += 8
				break
		
		# Check description
		if structure.description.to_lower().contains(query_lower):
			score += 5
		
		# Check function
		if structure.function.to_lower().contains(query_lower):
			score += 3
		
		if score > 0:
			results.append({
				"structure": structure,
				"score": score
			})
	
	# Sort by score
	results.sort_custom(func(a, b): return a.score > b.score)
	
	# Return just the structures
	var structures = []
	for result in results:
		structures.append(result.structure)
	
	return structures

func get_all_structure_ids() -> Array:
	"""Get all available structure IDs"""
	return _content_data.keys()

func get_structures_by_category(category: String) -> Array:
	"""Get all structures in a specific category"""
	var structures = []
	
	for structure_id in _content_data:
		var structure = _content_data[structure_id]
		if structure.get("category", "") == category:
			structures.append(structure)
	
	return structures

func is_content_loaded() -> bool:
	"""Check if content is loaded and ready"""
	return _is_loaded

# === PRIVATE METHODS ===

func _load_content_data() -> void:
	"""Load brain structure content from JSON file"""
	if not FileAccess.file_exists(CONTENT_FILE_PATH):
		push_error("[StructureContent] Content file not found: " + CONTENT_FILE_PATH)
		content_error.emit("", "Content file not found")
		return
	
	var file = FileAccess.open(CONTENT_FILE_PATH, FileAccess.READ)
	if not file:
		push_error("[StructureContent] Failed to open content file")
		content_error.emit("", "Failed to open content file")
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		push_error("[StructureContent] Failed to parse JSON: " + json.get_error_message())
		content_error.emit("", "Failed to parse content data")
		return
	
	var data = json.data
	if not data.has("structures"):
		push_error("[StructureContent] Invalid content format - missing 'structures'")
		content_error.emit("", "Invalid content format")
		return
	
	# Load structure data
	_content_data = data.structures
	
	# Build model name mappings
	_build_model_name_mappings()
	
	_is_loaded = true
	print("[StructureContent] Loaded %d brain structures" % _content_data.size())
	
	# Emit ready signal for each structure
	for structure_id in _content_data:
		content_ready.emit(structure_id, _content_data[structure_id])

func _build_model_name_mappings() -> void:
	"""Build mapping from model names to structure IDs"""
	_model_name_map.clear()
	
	for structure_id in _content_data:
		var structure = _content_data[structure_id]
		
		# Map all model name variants
		for model_name in structure.get("modelNames", []):
			var normalized = _normalize_model_name(model_name)
			_model_name_map[normalized] = structure_id
			print("[StructureContent] Mapped '", model_name, "' -> '", normalized, "' -> '", structure_id, "'")
		
		# Also map display name
		var normalized_display = _normalize_model_name(structure.displayName)
		_model_name_map[normalized_display] = structure_id

func _normalize_model_name(model_name: String) -> String:
	"""Normalize a model name for matching"""
	var normalized = model_name.to_lower().strip_edges()
	normalized = normalized.replace(" (good)", "")
	normalized = normalized.replace("(good)", "")
	normalized = normalized.replace("_", " ")
	normalized = normalized.strip_edges()  # Remove any trailing spaces
	
	# Special handling for known variations
	if normalized == "hipp and others":
		normalized = "hippocampus"
	
	return normalized

func _fuzzy_search_structure(query: String) -> Dictionary:
	"""Fuzzy search for a structure when exact match fails"""
	var query_lower = query.to_lower()
	var best_match = {}
	var best_score = 0
	
	for structure_id in _content_data:
		var structure = _content_data[structure_id]
		var score = 0
		
		# Check if query is contained in display name
		if structure.displayName.to_lower().contains(query_lower):
			score = 10
		
		# Check alternate names
		for alt_name in structure.get("alternateNames", []):
			if alt_name.to_lower().contains(query_lower):
				score = max(score, 8)
		
		# Check model names
		for model_name in structure.get("modelNames", []):
			if model_name.to_lower().contains(query_lower):
				score = max(score, 9)
		
		if score > best_score:
			best_score = score
			best_match = structure
	
	return best_match.duplicate(true) if best_match.size() > 0 else {}