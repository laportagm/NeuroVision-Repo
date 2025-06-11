extends Node

## Manages user settings and preferences

signal setting_changed(key: String, value: Variant)

# === CONSTANTS ===
const SETTINGS_PATH: String = "user://settings.cfg"
const DEFAULT_SETTINGS: Dictionary = {
	"graphics_quality": "high",
	"master_volume": 0.8,
	"sfx_volume": 1.0,
	"music_volume": 0.7,
	"language": "en",
	"theme": "enhanced",
	"accessibility_enabled": false,
	"vsync_enabled": true,
	"fullscreen": false
}

# === PRIVATE VARIABLES ===
var _settings: Dictionary = {}
var _config: ConfigFile

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[Settings] Manager initialized")
	_config = ConfigFile.new()
	_load_settings()

func get_setting(key: String, default_value: Variant = null) -> Variant:
	"""Get a setting value"""
	return _settings.get(key, default_value if default_value != null else DEFAULT_SETTINGS.get(key))

func set_setting(key: String, value: Variant) -> void:
	"""Set a setting value"""
	_settings[key] = value
	setting_changed.emit(key, value)
	_save_settings()

func reset_to_defaults() -> void:
	"""Reset all settings to defaults"""
	_settings = DEFAULT_SETTINGS.duplicate()
	for key in _settings:
		setting_changed.emit(key, _settings[key])
	_save_settings()

# === PRIVATE METHODS ===

func _load_settings() -> void:
	"""Load settings from file"""
	var error = _config.load(SETTINGS_PATH)
	if error != OK:
		print("[Settings] No settings file found, using defaults")
		_settings = DEFAULT_SETTINGS.duplicate()
		return
	
	for key in DEFAULT_SETTINGS:
		_settings[key] = _config.get_value("settings", key, DEFAULT_SETTINGS[key])

func _save_settings() -> void:
	"""Save settings to file"""
	for key in _settings:
		_config.set_value("settings", key, _settings[key])
	
	var error = _config.save(SETTINGS_PATH)
	if error != OK:
		push_error("[Settings] Failed to save settings")
