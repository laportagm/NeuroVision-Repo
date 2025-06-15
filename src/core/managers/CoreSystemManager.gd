extends Node

## Consolidated core system management
## Combines ErrorRecoveryManager, PerformanceMonitor, IntelOptimizer, AccessibilityManager, and SettingsManager

signal error_occurred(error_code: String, message: String)
signal recovery_attempted(error_code: String, success: bool)
signal performance_threshold_exceeded(metric: String, value: float)
signal settings_changed(setting_key: String, new_value)
signal accessibility_setting_changed(feature: String, enabled: bool)

# === CONSTANTS ===

const MAX_RECOVERY_ATTEMPTS: int = 3
const RECOVERY_DELAY: float = 1.0
const PERFORMANCE_UPDATE_INTERVAL: float = 1.0
const SETTINGS_SAVE_PATH: String = "user://settings.save"
const ACCESSIBILITY_SAVE_PATH: String = "user://accessibility.save"

# Performance thresholds
const PERFORMANCE_THRESHOLDS = {
	"fps": 30.0,
	"frame_time": 33.33,  # ms
	"memory_mb": 512.0,
	"draw_calls": 100
}

# Intel UHD 620 specific optimizations
const INTEL_UHD_620_SETTINGS = {
	"msaa_3d": 0,  # Disable MSAA
	"screen_space_aa": 1,  # Use FXAA instead
	"shadow_quality": 1,  # Medium shadows
	"texture_filter": 2,  # Bilinear filtering
	"reflection_quality": 0,  # Disable SSR
	"glow_enabled": false,  # Disable glow
	"ssao_enabled": false  # Disable SSAO
}

# === ENUMS ===

enum ErrorSeverity {
	INFO,
	WARNING,
	ERROR,
	CRITICAL
}

enum PerformanceLevel {
	EXCELLENT,  # 60+ FPS
	GOOD,       # 45-60 FPS
	ACCEPTABLE, # 30-45 FPS
	POOR        # <30 FPS
}

# === PRIVATE VARIABLES ===

# Error Recovery
var _error_history: Array[Dictionary] = []
var _recovery_attempts: Dictionary = {}

# Performance Monitoring
var _performance_timer: Timer
var _frame_times: Array[float] = []
var _current_fps: float = 60.0
var _current_frame_time: float = 16.67
var _memory_usage: float = 0.0
var _draw_calls: int = 0
var _performance_level: PerformanceLevel = PerformanceLevel.EXCELLENT

# Intel Optimization
var _is_intel_gpu: bool = false
var _intel_optimizations_applied: bool = false

# Settings Management
var _settings: Dictionary = {}
var _default_settings: Dictionary = {}

# Accessibility
var _accessibility_features: Dictionary = {}
var _default_accessibility: Dictionary = {}

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[CoreSystemManager] Initializing consolidated core systems")
	_initialize_error_recovery()
	_initialize_performance_monitoring()
	_detect_intel_gpu()
	_initialize_settings()
	_initialize_accessibility()

## Error Recovery Methods

func handle_error(error_code: String, message: String, severity: ErrorSeverity = ErrorSeverity.ERROR, context: Dictionary = {}) -> void:
	"""Handle an error with automatic recovery attempts"""
	var error_level = _get_error_level_string(severity)
	print("[%s] %s: %s" % [error_level, error_code, message])
	
	var error_data = {
		"code": error_code,
		"message": message,
		"severity": severity,
		"context": context,
		"timestamp": Time.get_ticks_msec()
	}
	
	_error_history.append(error_data)
	
	# Keep error history manageable
	if _error_history.size() > 100:
		_error_history = _error_history.slice(-50)
	
	error_occurred.emit(error_code, message)
	
	if severity >= ErrorSeverity.ERROR:
		call_deferred("_attempt_recovery", error_code, context)

func get_error_history() -> Array[Dictionary]:
	"""Get the complete error history"""
	return _error_history.duplicate()

func clear_error_history() -> void:
	"""Clear the error history"""
	_error_history.clear()

## Performance Monitoring Methods

func get_current_fps() -> float:
	"""Get current FPS"""
	return _current_fps

func get_current_frame_time() -> float:
	"""Get current frame time in milliseconds"""
	return _current_frame_time

func get_memory_usage() -> float:
	"""Get current memory usage in MB"""
	return _memory_usage

func get_performance_level() -> PerformanceLevel:
	"""Get current performance level"""
	return _performance_level

func get_performance_stats() -> Dictionary:
	"""Get comprehensive performance statistics"""
	return {
		"fps": _current_fps,
		"frame_time": _current_frame_time,
		"memory_mb": _memory_usage,
		"draw_calls": _draw_calls,
		"performance_level": _performance_level
	}

## Intel Optimization Methods

func apply_intel_optimizations() -> void:
	"""Apply Intel UHD 620 specific optimizations"""
	if _intel_optimizations_applied:
		return
	
	print("[CoreSystemManager] Applying Intel UHD 620 optimizations")
	
	# Apply rendering optimizations
	RenderingServer.viewport_set_msaa_3d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_DISABLED)
	
	# Update project settings
	for setting in INTEL_UHD_620_SETTINGS:
		var value = INTEL_UHD_620_SETTINGS[setting]
		_apply_rendering_setting(setting, value)
	
	_intel_optimizations_applied = true

func is_intel_gpu_detected() -> bool:
	"""Check if Intel GPU was detected"""
	return _is_intel_gpu

## Settings Management Methods

func set_setting(key: String, value) -> void:
	"""Set a setting value"""
	_settings[key] = value
	settings_changed.emit(key, value)
	_save_settings()

func get_setting(key: String, default_value = null):
	"""Get a setting value"""
	return _settings.get(key, default_value)

func reset_setting(key: String) -> void:
	"""Reset a setting to default value"""
	if _default_settings.has(key):
		set_setting(key, _default_settings[key])

func reset_all_settings() -> void:
	"""Reset all settings to defaults"""
	_settings = _default_settings.duplicate()
	_save_settings()
	
	for key in _settings:
		settings_changed.emit(key, _settings[key])

## Accessibility Methods

func set_accessibility_feature(feature: String, enabled: bool) -> void:
	"""Set accessibility feature state"""
	_accessibility_features[feature] = enabled
	accessibility_setting_changed.emit(feature, enabled)
	_save_accessibility_settings()
	_apply_accessibility_feature(feature, enabled)

func get_accessibility_feature(feature: String) -> bool:
	"""Get accessibility feature state"""
	return _accessibility_features.get(feature, false)

func get_all_accessibility_features() -> Dictionary:
	"""Get all accessibility feature states"""
	return _accessibility_features.duplicate()

# === PRIVATE METHODS ===

func _initialize_error_recovery() -> void:
	"""Initialize error recovery system"""
	# Note: Engine doesn't have error_occurred signal, using manual error handling instead
	print("[CoreSystemManager] Error recovery system initialized")

func _initialize_performance_monitoring() -> void:
	"""Initialize performance monitoring"""
	_performance_timer = Timer.new()
	_performance_timer.wait_time = PERFORMANCE_UPDATE_INTERVAL
	_performance_timer.autostart = true
	_performance_timer.timeout.connect(_update_performance_stats)
	add_child(_performance_timer)

func _initialize_settings() -> void:
	"""Initialize settings system"""
	_default_settings = {
		"master_volume": 1.0,
		"sfx_volume": 1.0,
		"music_volume": 0.7,
		"fullscreen": false,
		"vsync": true,
		"auto_save": true,
		"performance_mode": "balanced"
	}
	
	_settings = _default_settings.duplicate()
	_load_settings()

func _initialize_accessibility() -> void:
	"""Initialize accessibility features"""
	_default_accessibility = {
		"high_contrast": false,
		"large_text": false,
		"reduced_motion": false,
		"screen_reader": false,
		"colorblind_friendly": false,
		"subtitles": false
	}
	
	_accessibility_features = _default_accessibility.duplicate()
	_load_accessibility_settings()

func _detect_intel_gpu() -> void:
	"""Detect if running on Intel integrated graphics"""
	var gpu_name = RenderingServer.get_video_adapter_name().to_lower()
	_is_intel_gpu = gpu_name.contains("intel") and (
		gpu_name.contains("uhd") or 
		gpu_name.contains("hd graphics") or
		gpu_name.contains("iris")
	)
	
	if _is_intel_gpu:
		print("[CoreSystemManager] Intel GPU detected: ", RenderingServer.get_video_adapter_name())
		# Auto-apply optimizations for Intel GPUs
		call_deferred("apply_intel_optimizations")

func _attempt_recovery(error_code: String, context: Dictionary) -> void:
	"""Attempt to recover from an error"""
	if not _recovery_attempts.has(error_code):
		_recovery_attempts[error_code] = 0
	
	_recovery_attempts[error_code] += 1
	
	if _recovery_attempts[error_code] > MAX_RECOVERY_ATTEMPTS:
		handle_error("RECOVERY_FAILED", "Max recovery attempts exceeded for: " + error_code, ErrorSeverity.CRITICAL)
		return
	
	var success = false
	
	# Implement specific recovery strategies
	match error_code:
		"MODEL_LOAD_FAILED":
			success = _recover_model_loading(context)
		"UI_THEME_FAILED":
			success = _recover_theme_loading(context)
		"MEMORY_EXCEEDED":
			success = _recover_memory_issue(context)
		_:
			success = await _generic_recovery(error_code, context)
	
	recovery_attempted.emit(error_code, success)
	
	if success:
		_recovery_attempts.erase(error_code)

func _update_performance_stats() -> void:
	"""Update performance statistics"""
	_current_fps = Engine.get_frames_per_second()
	_current_frame_time = 1000.0 / max(_current_fps, 0.001)
	_memory_usage = OS.get_static_memory_usage() / 1024.0 / 1024.0
	
	# Track frame times for analysis
	_frame_times.append(_current_frame_time)
	if _frame_times.size() > 60:  # Keep 1 second of frame times
		_frame_times.pop_front()
	
	# Update performance level
	var _old_level = _performance_level
	if _current_fps >= 60:
		_performance_level = PerformanceLevel.EXCELLENT
	elif _current_fps >= 45:
		_performance_level = PerformanceLevel.GOOD
	elif _current_fps >= 30:
		_performance_level = PerformanceLevel.ACCEPTABLE
	else:
		_performance_level = PerformanceLevel.POOR
	
	# Check thresholds
	if _current_fps < PERFORMANCE_THRESHOLDS.fps:
		performance_threshold_exceeded.emit("fps", _current_fps)
	
	if _current_frame_time > PERFORMANCE_THRESHOLDS.frame_time:
		performance_threshold_exceeded.emit("frame_time", _current_frame_time)
	
	if _memory_usage > PERFORMANCE_THRESHOLDS.memory_mb:
		performance_threshold_exceeded.emit("memory_mb", _memory_usage)

func _apply_rendering_setting(setting: String, value) -> void:
	"""Apply a rendering setting"""
	match setting:
		"msaa_3d":
			var viewport_rid = get_viewport().get_viewport_rid()
			RenderingServer.viewport_set_msaa_3d(viewport_rid, value)
		"screen_space_aa":
			var viewport_rid = get_viewport().get_viewport_rid()
			RenderingServer.viewport_set_screen_space_aa(viewport_rid, value)
		# Add more rendering settings as needed

func _apply_accessibility_feature(feature: String, enabled: bool) -> void:
	"""Apply an accessibility feature"""
	match feature:
		"high_contrast":
			# Notify UI system to switch to high contrast theme
			if has_node("/root/UISystemManager"):
				get_node("/root/UISystemManager").set_accessibility_feature("high_contrast", enabled)
		"large_text":
			if has_node("/root/UISystemManager"):
				get_node("/root/UISystemManager").set_accessibility_feature("large_text", enabled)
		"reduced_motion":
			if has_node("/root/UISystemManager"):
				get_node("/root/UISystemManager").set_accessibility_feature("reduced_motion", enabled)

func _save_settings() -> void:
	"""Save settings to file"""
	var file = FileAccess.open(SETTINGS_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		handle_error("SETTINGS_SAVE_FAILED", "Failed to save settings file", ErrorSeverity.WARNING)
		return
	
	file.store_string(JSON.stringify(_settings))
	file.close()

func _load_settings() -> void:
	"""Load settings from file"""
	if not FileAccess.file_exists(SETTINGS_SAVE_PATH):
		return
	
	var file = FileAccess.open(SETTINGS_SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result == OK:
		_settings = json.data

func _save_accessibility_settings() -> void:
	"""Save accessibility settings to file"""
	var file = FileAccess.open(ACCESSIBILITY_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		handle_error("ACCESSIBILITY_SAVE_FAILED", "Failed to save accessibility file", ErrorSeverity.WARNING)
		return
	
	file.store_string(JSON.stringify(_accessibility_features))
	file.close()

func _load_accessibility_settings() -> void:
	"""Load accessibility settings from file"""
	if not FileAccess.file_exists(ACCESSIBILITY_SAVE_PATH):
		return
	
	var file = FileAccess.open(ACCESSIBILITY_SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result == OK:
		_accessibility_features = json.data

func _get_error_level_string(severity: ErrorSeverity) -> String:
	"""Get error level string"""
	match severity:
		ErrorSeverity.INFO:
			return "INFO"
		ErrorSeverity.WARNING:
			return "WARNING"
		ErrorSeverity.ERROR:
			return "ERROR"
		ErrorSeverity.CRITICAL:
			return "CRITICAL"
		_:
			return "UNKNOWN"

func _recover_model_loading(_context: Dictionary) -> bool:
	"""Recover from model loading failure"""
	# TODO: Implement model loading recovery
	return false

func _recover_theme_loading(_context: Dictionary) -> bool:
	"""Recover from theme loading failure"""
	# TODO: Implement theme loading recovery
	return false

func _recover_memory_issue(_context: Dictionary) -> bool:
	"""Recover from memory issues"""
	# TODO: Implement memory recovery (clear caches, etc.)
	return false

func _generic_recovery(_error_code: String, _context: Dictionary) -> bool:
	"""Generic recovery attempt"""
	await get_tree().create_timer(RECOVERY_DELAY).timeout
	return true

# Engine error handler removed - Engine doesn't have error_occurred signal
