extends Node
class_name SimplePersistence

## Simple persistence system for saving user progress
## Uses JSON format for easy debugging and human readability
## Handles corrupted saves gracefully without crashing

# === CONSTANTS ===
const SAVE_FILE_PATH: String = "user://progress_data.save"
const BACKUP_FILE_PATH: String = "user://progress_data.save.backup"
const SAVE_VERSION: int = 1

# === PRIVATE VARIABLES ===
var _data_cache: Dictionary = {}
var _is_dirty: bool = false
var _save_mutex: Mutex = Mutex.new()

# === PUBLIC METHODS ===

## Save a value with a unique key
## Returns true if successful, false otherwise
func save_data(key: String, value: Variant) -> bool:
	if key.is_empty():
		push_error("[SimplePersistence] Cannot save with empty key")
		return false
	
	_save_mutex.lock()
	_data_cache[key] = value
	_is_dirty = true
	_save_mutex.unlock()
	
	return true

## Load a value by key
## Returns the value if found, null otherwise
func load_data(key: String) -> Variant:
	_save_mutex.lock()
	var result = _data_cache.get(key, null)
	_save_mutex.unlock()
	
	return result

## Save all cached data to file
## Creates a backup of existing save before writing
func save_to_file() -> bool:
	if not _is_dirty:
		return true  # Nothing to save
	
	_save_mutex.lock()
	
	# Create save data structure
	var data_to_save = {
		"version": SAVE_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"data": _data_cache.duplicate()
	}
	
	# Convert to JSON
	var json_string = JSON.stringify(data_to_save, "\t")
	
	# Backup existing save file if it exists
	if FileAccess.file_exists(SAVE_FILE_PATH):
		_create_backup()
	
	# Write new save file
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("[SimplePersistence] Failed to open save file for writing: " + str(FileAccess.get_open_error()))
		_save_mutex.unlock()
		return false
	
	file.store_string(json_string)
	file.close()
	
	_is_dirty = false
	_save_mutex.unlock()
	
	print("[SimplePersistence] Progress saved successfully")
	return true

## Load all data from file
## Returns true if successful, false if failed (but won't crash)
func load_from_file() -> bool:
	_save_mutex.lock()
	
	# Check if save file exists
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("[SimplePersistence] No save file found, starting fresh")
		_save_mutex.unlock()
		return true  # Not an error, just no previous save
	
	# Try to load the save file
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		push_error("[SimplePersistence] Failed to open save file for reading")
		_save_mutex.unlock()
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	# Parse JSON
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("[SimplePersistence] Failed to parse save file: " + json.get_error_message())
		# Try to restore from backup
		var backup_loaded = _restore_from_backup()
		_save_mutex.unlock()
		return backup_loaded
	
	var loaded_data = json.data
	
	# Validate save data structure
	if not _validate_save_data(loaded_data):
		push_error("[SimplePersistence] Invalid save data structure")
		# Try to restore from backup
		var backup_loaded = _restore_from_backup()
		_save_mutex.unlock()
		return backup_loaded
	
	# Load the data
	_data_cache = loaded_data.data.duplicate()
	_is_dirty = false
	
	_save_mutex.unlock()
	
	print("[SimplePersistence] Progress loaded successfully from save")
	return true

## Clear all saved data (use with caution!)
func clear_all_data() -> void:
	_save_mutex.lock()
	_data_cache.clear()
	_is_dirty = true
	_save_mutex.unlock()
	save_to_file()

## Get all keys currently stored
func get_all_keys() -> Array:
	_save_mutex.lock()
	var keys = _data_cache.keys()
	_save_mutex.unlock()
	return keys

## Check if a key exists in the cache
func has_key(key: String) -> bool:
	_save_mutex.lock()
	var exists = _data_cache.has(key)
	_save_mutex.unlock()
	return exists

# === PRIVATE METHODS ===

## Create a backup of the current save file
func _create_backup() -> void:
	var dir = DirAccess.open("user://")
	if dir and FileAccess.file_exists(SAVE_FILE_PATH):
		dir.copy(SAVE_FILE_PATH, BACKUP_FILE_PATH)
		print("[SimplePersistence] Backup created")

## Restore data from backup file
func _restore_from_backup() -> bool:
	if not FileAccess.file_exists(BACKUP_FILE_PATH):
		push_error("[SimplePersistence] No backup file available")
		return false
	
	print("[SimplePersistence] Attempting to restore from backup...")
	
	# Copy backup to main save file
	var dir = DirAccess.open("user://")
	if dir:
		dir.copy(BACKUP_FILE_PATH, SAVE_FILE_PATH)
		# Try loading again (without recursion)
		return _load_backup_directly()
	
	return false

## Load backup file directly
func _load_backup_directly() -> bool:
	var file = FileAccess.open(BACKUP_FILE_PATH, FileAccess.READ)
	if file == null:
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		return false
	
	var backup_data = json.data
	if _validate_save_data(backup_data):
		_data_cache = backup_data.data.duplicate()
		_is_dirty = false
		print("[SimplePersistence] Successfully restored from backup")
		return true
	
	return false

## Validate the structure of save data
func _validate_save_data(data: Variant) -> bool:
	if not data is Dictionary:
		return false
	
	if not data.has("version") or not data.has("data"):
		return false
	
	if not data.data is Dictionary:
		return false
	
	# Check version compatibility
	if data.version > SAVE_VERSION:
		push_warning("[SimplePersistence] Save file from newer version, may have compatibility issues")
	
	return true

## Get file size in bytes (for monitoring)
func get_save_file_size() -> int:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return 0
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		return 0
	
	var size = file.get_length()
	file.close()
	return size