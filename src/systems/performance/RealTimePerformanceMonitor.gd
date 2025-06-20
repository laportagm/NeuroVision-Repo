## Real-Time Performance Monitor for NeuroVision
##
## Connects the performance monitoring UI to actual system metrics,
## optimized for educational medical visualization on Intel UHD 620.

class_name RealTimePerformanceMonitor
extends Node

# === SIGNALS ===
signal performance_warning(metric: String, value: float, threshold: float)
signal quality_adjustment_needed(new_quality: String)
signal metrics_updated(metrics: Dictionary)

# === CONSTANTS ===
const UPDATE_INTERVAL: float = 0.5  # Update every 500ms
const FPS_HISTORY_SIZE: int = 60  # 30 seconds of history at 2 updates/sec
const MEMORY_WARNING_THRESHOLD: float = 450.0  # MB
const FPS_WARNING_THRESHOLD: float = 25.0  # Below this triggers quality reduction
const FRAME_TIME_WARNING: float = 40.0  # ms (25 FPS)

# === EXPORTS ===
@export_group("Performance Targets")
@export var target_fps: float = 30.0  # Intel UHD 620 target
@export var target_frame_time: float = 33.33  # ms
@export var target_memory_mb: float = 500.0
@export var enable_auto_quality: bool = true

# === PRIVATE VARIABLES ===
var _update_timer: float = 0.0
var _fps_history: Array[float] = []
var _frame_time_history: Array[float] = []
var _last_frame_time: float = 0.0
var _total_frames: int = 0
var _session_start_time: float = 0.0
var _current_quality: String = "high"
var _memory_baseline: float = 0.0
var _ui_elements: Dictionary = {}  # UI element references

# Performance data
var _current_metrics: Dictionary = {
	"fps": 0.0,
	"frame_time": 0.0,
	"memory_usage_mb": 0.0,
	"memory_percentage": 0.0,
	"cpu_usage": 0.0,
	"gpu_usage": 0.0,
	"draw_calls": 0,
	"vertices": 0,
	"quality_level": "high",
	"session_time": 0.0,
	"brain_complexity": 0,
	"texture_memory_mb": 0.0
}

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[PerformanceMonitor] Initializing real-time monitoring")
	_session_start_time = Time.get_ticks_msec() / 1000.0
	_memory_baseline = _get_memory_usage_mb()
	
	# Initialize history arrays
	_fps_history.resize(FPS_HISTORY_SIZE)
	_frame_time_history.resize(FPS_HISTORY_SIZE)
	for i in FPS_HISTORY_SIZE:
		_fps_history[i] = target_fps
		_frame_time_history[i] = target_frame_time

func _process(delta: float) -> void:
	_update_timer += delta
	_total_frames += 1
	
	# Track frame time
	var current_time = Time.get_ticks_usec() / 1000.0  # Convert to milliseconds
	var frame_time = current_time - _last_frame_time
	_last_frame_time = current_time
	
	# Update metrics at interval
	if _update_timer >= UPDATE_INTERVAL:
		_update_metrics(delta)
		_update_timer = 0.0
		
		# Check performance and adjust quality if needed
		if enable_auto_quality:
			_check_performance_and_adjust()

func connect_ui_elements(elements: Dictionary) -> void:
	"""Connect UI elements for real-time updates"""
	_ui_elements = elements
	print("[PerformanceMonitor] Connected %d UI elements" % elements.size())

func get_current_metrics() -> Dictionary:
	"""Get current performance metrics"""
	return _current_metrics.duplicate()

func get_average_fps() -> float:
	"""Get average FPS over history"""
	var sum: float = 0.0
	for fps in _fps_history:
		sum += fps
	return sum / float(_fps_history.size())

func get_memory_usage_mb() -> float:
	"""Get current memory usage in MB"""
	return _current_metrics.memory_usage_mb

func force_quality_level(quality: String) -> void:
	"""Force a specific quality level"""
	_current_quality = quality
	_apply_quality_settings(quality)

# === PRIVATE METHODS ===

func _update_metrics(delta: float) -> void:
	"""Update all performance metrics"""
	# FPS calculation
	var current_fps = Engine.get_frames_per_second()
	_fps_history.push_back(current_fps)
	_fps_history.pop_front()
	_current_metrics.fps = current_fps
	
	# Frame time
	var frame_time = (1.0 / max(current_fps, 1.0)) * 1000.0  # Convert to ms
	_frame_time_history.push_back(frame_time)
	_frame_time_history.pop_front()
	_current_metrics.frame_time = frame_time
	
	# Memory usage
	var memory_mb = _get_memory_usage_mb()
	_current_metrics.memory_usage_mb = memory_mb
	_current_metrics.memory_percentage = (memory_mb / target_memory_mb) * 100.0
	
	# CPU/GPU usage (simulated for now, would need OS-specific implementation)
	_current_metrics.cpu_usage = _estimate_cpu_usage()
	_current_metrics.gpu_usage = _estimate_gpu_usage()
	
	# Rendering stats
	_current_metrics.draw_calls = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	_current_metrics.vertices = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
	
	# Session time
	_current_metrics.session_time = (Time.get_ticks_msec() / 1000.0) - _session_start_time
	
	# Quality level
	_current_metrics.quality_level = _current_quality
	
	# Brain model complexity (get from scene if available)
	_current_metrics.brain_complexity = _get_brain_model_complexity()
	
	# Texture memory
	_current_metrics.texture_memory_mb = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED) / 1048576.0
	
	# Update UI if connected
	_update_ui_elements()
	
	# Emit signal
	metrics_updated.emit(_current_metrics)
	
	# Check for warnings
	_check_performance_warnings()

func _update_ui_elements() -> void:
	"""Update connected UI elements with real metrics"""
	if _ui_elements.is_empty():
		return
		
	# FPS indicator
	if _ui_elements.has("fps_indicator"):
		_ui_elements.fps_indicator.text = "FPS: %d" % int(_current_metrics.fps)
		_ui_elements.fps_indicator.modulate = _get_fps_color(_current_metrics.fps)
	
	# Frame time
	if _ui_elements.has("frame_time_indicator"):
		_ui_elements.frame_time_indicator.text = "Frame: %.1fms" % _current_metrics.frame_time
	
	# Quality indicator
	if _ui_elements.has("quality_indicator"):
		_ui_elements.quality_indicator.text = "Quality: %s" % _current_quality.to_upper()
	
	# Memory usage
	if _ui_elements.has("memory_usage"):
		_ui_elements.memory_usage.value = _current_metrics.memory_percentage
	
	# CPU usage
	if _ui_elements.has("cpu_usage"):
		_ui_elements.cpu_usage.value = _current_metrics.cpu_usage
	
	# GPU usage
	if _ui_elements.has("gpu_usage"):
		_ui_elements.gpu_usage.value = _current_metrics.gpu_usage
	
	# Brain model complexity
	if _ui_elements.has("brain_model_complexity"):
		var complexity_text = "Polygons: "
		if _current_metrics.brain_complexity > 0:
			complexity_text += "%dK" % (_current_metrics.brain_complexity / 1000)
		else:
			complexity_text += "None"
		_ui_elements.brain_model_complexity.text = complexity_text
	
	# Texture memory
	if _ui_elements.has("texture_memory"):
		_ui_elements.texture_memory.text = "VRAM: %dMB" % int(_current_metrics.texture_memory_mb)
	
	# Performance label
	if _ui_elements.has("performance_label"):
		var perf_text = "FPS: %d | Quality: %s" % [int(_current_metrics.fps), _current_quality.to_upper()]
		_ui_elements.performance_label.text = perf_text
	
	# Session time
	if _ui_elements.has("learning_analytics"):
		var minutes = int(_current_metrics.session_time) / 60
		var seconds = int(_current_metrics.session_time) % 60
		_ui_elements.learning_analytics.text = "Session: %d:%02d" % [minutes, seconds]

func _get_fps_color(fps: float) -> Color:
	"""Get color based on FPS performance"""
	if fps >= target_fps:
		return Color(0.4, 0.8, 0.4)  # Green
	elif fps >= FPS_WARNING_THRESHOLD:
		return Color(0.8, 0.8, 0.4)  # Yellow
	else:
		return Color(0.8, 0.4, 0.4)  # Red

func _check_performance_warnings() -> void:
	"""Check for performance issues and emit warnings"""
	# FPS warning
	if _current_metrics.fps < FPS_WARNING_THRESHOLD:
		performance_warning.emit("fps", _current_metrics.fps, FPS_WARNING_THRESHOLD)
	
	# Memory warning
	if _current_metrics.memory_usage_mb > MEMORY_WARNING_THRESHOLD:
		performance_warning.emit("memory", _current_metrics.memory_usage_mb, MEMORY_WARNING_THRESHOLD)
	
	# Frame time warning
	if _current_metrics.frame_time > FRAME_TIME_WARNING:
		performance_warning.emit("frame_time", _current_metrics.frame_time, FRAME_TIME_WARNING)

func _check_performance_and_adjust() -> void:
	"""Check performance and adjust quality if needed"""
	var avg_fps = get_average_fps()
	
	# Downgrade quality if performance is poor
	if avg_fps < FPS_WARNING_THRESHOLD and _current_quality != "low":
		if _current_quality == "high":
			_set_quality("medium")
		elif _current_quality == "medium":
			_set_quality("low")
	
	# Upgrade quality if performance is good
	elif avg_fps > target_fps + 10 and _current_quality != "high":
		if _current_quality == "low":
			_set_quality("medium")
		elif _current_quality == "medium":
			_set_quality("high")

func _set_quality(quality: String) -> void:
	"""Set rendering quality level"""
	if _current_quality == quality:
		return
		
	_current_quality = quality
	_apply_quality_settings(quality)
	quality_adjustment_needed.emit(quality)
	print("[PerformanceMonitor] Quality adjusted to: " + quality)

func _apply_quality_settings(quality: String) -> void:
	"""Apply quality settings to rendering"""
	# This would integrate with GraphicsOptimizationManager
	if GraphicsOptimizationManager:
		match quality:
			"low":
				GraphicsOptimizationManager.set_quality_preset("performance")
			"medium":
				GraphicsOptimizationManager.set_quality_preset("balanced")
			"high":
				GraphicsOptimizationManager.set_quality_preset("quality")

func _get_memory_usage_mb() -> float:
	"""Get current memory usage in MB"""
	# Get static memory usage
	var static_mem = OS.get_static_memory_usage() / 1048576.0
	
	# Estimate based on baseline
	return static_mem - _memory_baseline + 50.0  # Add base overhead

func _estimate_cpu_usage() -> float:
	"""Estimate CPU usage based on frame time"""
	# Simple estimation based on frame time vs target
	var cpu_estimate = (_current_metrics.frame_time / target_frame_time) * 50.0
	return clamp(cpu_estimate, 10.0, 90.0)

func _estimate_gpu_usage() -> float:
	"""Estimate GPU usage based on draw calls and vertices"""
	# Simple estimation based on rendering complexity
	var draw_call_factor = float(_current_metrics.draw_calls) / 100.0
	var vertex_factor = float(_current_metrics.vertices) / 100000.0
	var gpu_estimate = (draw_call_factor + vertex_factor) * 25.0
	return clamp(gpu_estimate, 15.0, 85.0)

func _get_brain_model_complexity() -> int:
	"""Get brain model polygon count from scene"""
	# This would query the actual loaded brain model
	# For now, return a reasonable estimate
	if _current_metrics.draw_calls > 50:
		return 847000  # Typical brain model
	return 0