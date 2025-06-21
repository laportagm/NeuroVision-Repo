extends Node

## Manages educational content loading and caching

signal content_loaded(content_id: String)
signal content_load_failed(content_id: String, error: String)

# === CONSTANTS ===
const CONTENT_PATH: String = "res://content/"
const CACHE_SIZE_MB: int = 100

# === PRIVATE VARIABLES ===
var _content_cache: Dictionary = {}
var _loading_queue: Array[String] = []

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[Content] Manager initialized")

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

func preload_essential_content() -> void:
	"""Preload essential educational content"""
	# TODO: Implement preloading logic
	pass

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
		if not file:
			content_load_failed.emit(content_id, "Failed to open content file")
			continue
		
		var json_text = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		if parse_result != OK:
			content_load_failed.emit(content_id, "Failed to parse JSON: " + json.get_error_message())
			continue
		
		_content_cache[content_id] = json.data
		content_loaded.emit(content_id)
