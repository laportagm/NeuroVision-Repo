extends Node

## Monitors and reports performance metrics with automatic quality adjustment

signal performance_warning(metric: String, value: float, threshold: float)
signal performance_report_ready(report: Dictionary)
signal quality_level_changed(new_level: QualityLevel)
signal performance_critical(metric: String, value: float)

# === ENUMS ===
enum QualityLevel {
	LOW,
	MEDIUM,
	HIGH,
	ULTRA
}

# === CONSTANTS ===
const FPS_WARNING_THRESHOLD: float = 30.0
const FPS_CRITICAL_THRESHOLD: float = 20.0
const MEMORY_WARNING_THRESHOLD: float = 500.0  # MB
const MEMORY_CRITICAL_THRESHOLD: float = 800.0  # MB
const UPDATE_INTERVAL: float = 1.0
const QUALITY_CHECK_INTERVAL: float = 5.0
const FPS_HISTORY_SIZE: int = 10

# Quality adjustment thresholds
const QUALITY_UP_FPS_THRESHOLD: float = 50.0
const QUALITY_DOWN_FPS_THRESHOLD: float = 25.0
const QUALITY_STABILITY_THRESHOLD: float = 5.0  # FPS variance

# === PRIVATE VARIABLES ===
var _is_monitoring: bool = false
var _performance_data: Dictionary = {}
var _update_timer: Timer
var _quality_timer: Timer
var _current_quality: QualityLevel = QualityLevel.MEDIUM
var _fps_history: Array[float] = []
var _average_fps: float = 60.0
var _fps_variance: float = 0.0
var _quality_locked: bool = false
var _startup_grace_period: float = 10.0
var _time_since_start: float = 0.0

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[Performance] Monitor initialized")
	_register_global_shader_parameters()
	_setup_timers()
	_initialize_quality_settings()
	start_monitoring()

func start_monitoring() -> void:
	"""Start performance monitoring"""
	_is_monitoring = true
	_update_timer.start()
	_quality_timer.start()
	print("[Performance] Monitoring started")

func stop_monitoring() -> void:
	"""Stop performance monitoring"""
	_is_monitoring = false
	_update_timer.stop()
	_quality_timer.stop()
	print("[Performance] Monitoring stopped")

func get_current_metrics() -> Dictionary:
	"""Get current performance metrics"""
	return {
		"fps": Performance.get_monitor(Performance.TIME_FPS),
		"memory": OS.get_static_memory_usage() / 1048576.0,  # Convert to MB
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"vertex_count": Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
		"physics_time": Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS),
		"render_time": Performance.get_monitor(Performance.TIME_PROCESS),
		"quality_level": _current_quality,
		"average_fps": _average_fps,
		"fps_variance": _fps_variance
	}

func get_average_fps() -> float:
	"""Get average FPS over recent history"""
	return _average_fps

func get_current_quality_level() -> QualityLevel:
	"""Get current quality level"""
	return _current_quality

func set_quality_level(level: QualityLevel) -> void:
	"""Manually set quality level"""
	if _current_quality == level:
		return
		
	_current_quality = level
	_apply_quality_settings()
	quality_level_changed.emit(level)
	print("[Performance] Quality level set to: ", QualityLevel.keys()[level])

func lock_quality(locked: bool) -> void:
	"""Lock/unlock automatic quality adjustment"""
	_quality_locked = locked
	print("[Performance] Quality adjustment ", "locked" if locked else "unlocked")

func force_quality_check() -> void:
	"""Force an immediate quality adjustment check"""
	_check_and_adjust_quality()

# === PRIVATE METHODS ===

func _setup_timers() -> void:
	"""Setup the update timers"""
	# Performance update timer
	_update_timer = Timer.new()
	_update_timer.wait_time = UPDATE_INTERVAL
	_update_timer.timeout.connect(_update_metrics)
	add_child(_update_timer)
	
	# Quality adjustment timer
	_quality_timer = Timer.new()
	_quality_timer.wait_time = QUALITY_CHECK_INTERVAL
	_quality_timer.timeout.connect(_check_and_adjust_quality)
	add_child(_quality_timer)

func _initialize_quality_settings() -> void:
	"""Initialize quality based on hardware detection"""
	var renderer = RenderingServer.get_video_adapter_name().to_lower()
	var vendor = RenderingServer.get_video_adapter_vendor().to_lower()
	
	print("[Performance] GPU Detection - Renderer: %s, Vendor: %s" % [renderer, vendor])
	
	# Prioritize Intel detection for Intel UHD 620 optimization
	if "intel" in vendor or "intel" in renderer:
		_current_quality = QualityLevel.LOW
		print("[Performance] Detected Intel graphics (UHD 620 optimization), starting with LOW quality")
	elif ("uhd" in renderer or "hd graphics" in renderer or "iris" in renderer):
		_current_quality = QualityLevel.LOW  
		print("[Performance] Detected integrated graphics, starting with LOW quality")
	elif "nvidia" in renderer or "amd" in renderer or "radeon" in renderer:
		_current_quality = QualityLevel.HIGH
		print("[Performance] Detected dedicated graphics, starting with HIGH quality")
	else:
		_current_quality = QualityLevel.MEDIUM
		print("[Performance] Unknown graphics, starting with MEDIUM quality")
	
	_apply_quality_settings()

func _update_metrics() -> void:
	"""Update performance metrics"""
	if not _is_monitoring:
		return
	
	_time_since_start += UPDATE_INTERVAL
	
	var metrics = get_current_metrics()
	_performance_data = metrics
	
	# Update FPS history
	_fps_history.append(metrics.fps)
	if _fps_history.size() > FPS_HISTORY_SIZE:
		_fps_history.pop_front()
	
	# Calculate average and variance
	_calculate_fps_statistics()
	
	# Check thresholds
	if metrics.fps < FPS_CRITICAL_THRESHOLD:
		performance_critical.emit("fps", metrics.fps)
	elif metrics.fps < FPS_WARNING_THRESHOLD:
		performance_warning.emit("fps", metrics.fps, FPS_WARNING_THRESHOLD)
	
	if metrics.memory > MEMORY_CRITICAL_THRESHOLD:
		performance_critical.emit("memory", metrics.memory)
	elif metrics.memory > MEMORY_WARNING_THRESHOLD:
		performance_warning.emit("memory", metrics.memory, MEMORY_WARNING_THRESHOLD)
	
	# Emit updated metrics
	metrics["average_fps"] = _average_fps
	metrics["fps_variance"] = _fps_variance
	performance_report_ready.emit(metrics)

func _calculate_fps_statistics() -> void:
	"""Calculate FPS average and variance"""
	if _fps_history.is_empty():
		return
	
	# Calculate average
	var sum: float = 0.0
	for fps in _fps_history:
		sum += fps
	_average_fps = sum / _fps_history.size()
	
	# Calculate variance
	var variance_sum: float = 0.0
	for fps in _fps_history:
		variance_sum += pow(fps - _average_fps, 2)
	_fps_variance = sqrt(variance_sum / _fps_history.size())

func _check_and_adjust_quality() -> void:
	"""Check performance and adjust quality if needed"""
	if _quality_locked or _time_since_start < _startup_grace_period:
		return
	
	if _fps_history.size() < FPS_HISTORY_SIZE:
		return  # Not enough data yet
	
	# Check if we should adjust quality
	var should_increase = (_average_fps > QUALITY_UP_FPS_THRESHOLD and 
						  _fps_variance < QUALITY_STABILITY_THRESHOLD and
						  _current_quality < QualityLevel.ULTRA)
	
	var should_decrease = (_average_fps < QUALITY_DOWN_FPS_THRESHOLD and
						  _current_quality > QualityLevel.LOW)
	
	if should_decrease:
		# Decrease quality
		var new_quality = _current_quality - 1
		set_quality_level(new_quality)
		print("[Performance] Decreasing quality due to low FPS: ", _average_fps)
	elif should_increase:
		# Increase quality
		var new_quality = _current_quality + 1
		set_quality_level(new_quality)
		print("[Performance] Increasing quality due to high FPS: ", _average_fps)

func _apply_quality_settings() -> void:
	"""Apply quality settings to the engine"""
	match _current_quality:
		QualityLevel.LOW:
			_apply_low_quality()
		QualityLevel.MEDIUM:
			_apply_medium_quality()
		QualityLevel.HIGH:
			_apply_high_quality()
		QualityLevel.ULTRA:
			_apply_ultra_quality()

func _apply_low_quality() -> void:
	"""Apply low quality settings for Intel UHD 620 level hardware"""
	# Get the main viewport
	var viewport = get_viewport()
	if not viewport:
		viewport = get_tree().root
	
	if viewport:
		var viewport_rid = viewport.get_viewport_rid()
		RenderingServer.viewport_set_msaa_3d(viewport_rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
		RenderingServer.viewport_set_screen_space_aa(viewport_rid, RenderingServer.VIEWPORT_SCREEN_SPACE_AA_DISABLED)
	
	RenderingServer.directional_shadow_atlas_set_size(1024, true)
	
	# Reduce texture quality globally
	_safe_set_shader_param("texture_lod_bias", 2.0)
	
	# Disable post-processing effects globally
	_safe_set_shader_param("glow_enabled", false)
	_safe_set_shader_param("ssr_enabled", false)
	
	print("[Performance] Applied LOW quality settings")

func _apply_medium_quality() -> void:
	"""Apply medium quality settings"""
	var viewport = get_viewport()
	if not viewport:
		viewport = get_tree().root
	
	if viewport:
		var viewport_rid = viewport.get_viewport_rid()
		RenderingServer.viewport_set_msaa_3d(viewport_rid, RenderingServer.VIEWPORT_MSAA_2X)
		RenderingServer.viewport_set_screen_space_aa(viewport_rid, RenderingServer.VIEWPORT_SCREEN_SPACE_AA_FXAA)
	
	RenderingServer.directional_shadow_atlas_set_size(2048, true)
	
	_safe_set_shader_param("texture_lod_bias", 1.0)
	_safe_set_shader_param("glow_enabled", false)
	_safe_set_shader_param("ssr_enabled", false)
	
	print("[Performance] Applied MEDIUM quality settings")

func _apply_high_quality() -> void:
	"""Apply high quality settings"""
	var viewport = get_viewport()
	if not viewport:
		viewport = get_tree().root
	
	if viewport:
		var viewport_rid = viewport.get_viewport_rid()
		RenderingServer.viewport_set_msaa_3d(viewport_rid, RenderingServer.VIEWPORT_MSAA_4X)
		RenderingServer.viewport_set_screen_space_aa(viewport_rid, RenderingServer.VIEWPORT_SCREEN_SPACE_AA_FXAA)
	
	RenderingServer.directional_shadow_atlas_set_size(4096, true)
	
	_safe_set_shader_param("texture_lod_bias", 0.0)
	_safe_set_shader_param("glow_enabled", true)
	_safe_set_shader_param("ssr_enabled", true)
	
	print("[Performance] Applied HIGH quality settings")

func _apply_ultra_quality() -> void:
	"""Apply ultra quality settings"""
	var viewport = get_viewport()
	if not viewport:
		viewport = get_tree().root
	
	if viewport:
		var viewport_rid = viewport.get_viewport_rid()
		RenderingServer.viewport_set_msaa_3d(viewport_rid, RenderingServer.VIEWPORT_MSAA_8X)
		RenderingServer.viewport_set_screen_space_aa(viewport_rid, RenderingServer.VIEWPORT_SCREEN_SPACE_AA_FXAA)
	
	RenderingServer.directional_shadow_atlas_set_size(8192, true)
	
	_safe_set_shader_param("texture_lod_bias", -0.5)
	_safe_set_shader_param("glow_enabled", true)
	_safe_set_shader_param("ssr_enabled", true)
	
	print("[Performance] Applied ULTRA quality settings")

func _register_global_shader_parameters() -> void:
	"""Register global shader parameters with safe defaults"""
	# For Godot 4.x, global shader parameters need to be defined in project settings
	# We'll use placeholder values for now to avoid errors
	# In production, these should be defined in Project Settings > Shader Globals
	
	print("[Performance] Note: Global shader parameters not yet defined in project")
	print("[Performance] Visual quality settings will use engine defaults")
	print("[Performance] To enable advanced visual effects, define these in Project Settings:")
	print("[Performance]   - texture_lod_bias (float)")
	print("[Performance]   - glow_enabled (bool)")
	print("[Performance]   - ssr_enabled (bool)")

func report_custom_metric(metric_name: String, value: float) -> void:
	"""Report a custom metric from external systems"""
	if not _is_monitoring:
		return
		
	# Store custom metric in performance data
	if not _performance_data.has("custom_metrics"):
		_performance_data["custom_metrics"] = {}
		
	_performance_data["custom_metrics"][metric_name] = value
	
	# Log significant metrics
	if "efficiency" in metric_name.to_lower():
		print("[Performance] Custom metric - %s: %.2f" % [metric_name, value])

func _safe_set_shader_param(_param_name: String, _value: Variant) -> void:
	"""Safely set a global shader parameter, handling missing parameters gracefully"""
	# Note: In Godot 4.x, global shader parameters must be defined in Project Settings
	# Since they're not defined yet, we'll skip setting them to avoid errors
	# This maintains 30+ FPS performance without visual enhancements
	
	# For now, we'll just log the intended setting without actually applying it
	# This prevents the error spam while maintaining system stability
	
	if Engine.is_editor_hint():
		# In editor, show what would be set
		print("[Performance] Would set shader param '%s' to %s (skipped - not defined in project)" % [_param_name, str(_value)])
	
	# Once shader parameters are defined in Project Settings > Shader Globals,
	# uncomment this line:
	# RenderingServer.global_shader_parameter_set(_param_name, _value)
	
	# Silent operation - shader params are optional visual enhancements
	# The system works fine without them, just with reduced visual quality
	# No need to log warnings for optional features
	pass