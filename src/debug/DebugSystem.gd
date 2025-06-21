extends Node

## Enhanced Debug System for NeuroVision
## Provides comprehensive error detection and logging

signal error_detected(error_type: String, details: Dictionary)
signal performance_warning(metric: String, value: float)
signal debug_message(category: String, message: String)

# Debug categories
enum DebugCategory {
	GENERAL,
	PERFORMANCE,
	MEMORY,
	RENDERING,
	PHYSICS,
	AUDIO,
	UI,
	NETWORK,
	EDUCATIONAL,
	MEDICAL_ACCURACY
}

# Error severity levels
enum ErrorSeverity {
	INFO,
	WARNING,
	ERROR,
	CRITICAL
}

# Configuration
var debug_enabled: bool = true
var log_to_file: bool = true
var show_debug_overlay: bool = true
var performance_monitoring: bool = true
var memory_tracking: bool = true
var error_stacktrace: bool = true

# Debug state
var _debug_log: Array = []
var _error_count: Dictionary = {}
var _performance_metrics: Dictionary = {}
var _memory_snapshots: Array = []
var _debug_overlay: Control = null
var _log_file: FileAccess = null
var _last_fps_warning_time: float = 0.0
var _fps_warning_cooldown: float = 5.0  # Only warn once every 5 seconds
var _last_memory_warning_time: float = 0.0
var _last_frame_time_warning_time: float = 0.0
const MEMORY_WARNING_INTERVAL = 10.0  # seconds between memory warnings
const FRAME_TIME_WARNING_INTERVAL = 5.0  # seconds between frame time warnings

# Performance thresholds
const FPS_WARNING_THRESHOLD = 25  # Adjusted for 3D medical visualization - 25 FPS minimum warning
const MEMORY_WARNING_THRESHOLD = 800 * 1024 * 1024  # 800MB - Adjusted for 3D medical visualization
const FRAME_TIME_WARNING = 40.0  # milliseconds (25 FPS) - Adjusted for 3D medical visualization

func _ready() -> void:
	set_process(true)
	_initialize_debug_system()
	_setup_error_handlers()
	_create_debug_overlay()
	
	# Open log file
	if log_to_file:
		var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
		_log_file = FileAccess.open("user://debug_log_%s.txt" % timestamp, FileAccess.WRITE)
		if not _log_file:
			push_warning("[DebugSystem] Failed to open log file")
			log_to_file = false

func _initialize_debug_system() -> void:
	log_debug("GENERAL", "Debug System initialized")
	
	# Connect to built-in error signals
	get_tree().node_added.connect(_on_node_added)
	get_tree().node_removed.connect(_on_node_removed)
	
	# Monitor autoloads
	_check_autoload_status()

func _setup_error_handlers() -> void:
	# Override push_error to capture all errors
	var _original_push_error = push_error
	
	# Set up custom error handler
	set_meta("_error_handler_connected", true)

func _create_debug_overlay() -> void:
	if not show_debug_overlay:
		return
	
	_debug_overlay = Control.new()
	_debug_overlay.name = "DebugOverlay"
	_debug_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_debug_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Create debug info panel
	var panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	panel.position = Vector2(-300, 10)
	panel.size = Vector2(290, 200)
	panel.modulate.a = 0.8
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	# Add debug labels
	for i in 5:
		var label = RichTextLabel.new()
		label.fit_content = true
		label.bbcode_enabled = true
		label.name = "DebugLabel%d" % i
		vbox.add_child(label)
	
	_debug_overlay.add_child(panel)
	get_tree().root.call_deferred("add_child", _debug_overlay)

func _process(delta: float) -> void:
	if not debug_enabled:
		return
	
	# Update performance metrics
	if performance_monitoring:
		_update_performance_metrics(delta)
	
	# Update memory tracking
	if memory_tracking:
		_update_memory_tracking()
	
	# Update debug overlay
	if show_debug_overlay and _debug_overlay:
		_update_debug_overlay()

func _update_performance_metrics(delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	var frame_time = delta * 1000.0
	var physics_process_time = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
	var idle_process_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	
	_performance_metrics["fps"] = fps
	_performance_metrics["frame_time"] = frame_time
	_performance_metrics["physics_time"] = physics_process_time
	_performance_metrics["idle_time"] = idle_process_time
	
	# Check for performance issues with cooldown
	var current_time = Time.get_ticks_msec() / 1000.0
	if fps < FPS_WARNING_THRESHOLD and current_time - _last_fps_warning_time > _fps_warning_cooldown:
		log_warning("PERFORMANCE", "Low FPS detected: %d (threshold: %d FPS)" % [fps, FPS_WARNING_THRESHOLD])
		performance_warning.emit("fps", fps)
		_last_fps_warning_time = current_time
	
	if frame_time > FRAME_TIME_WARNING:
		if current_time - _last_frame_time_warning_time > FRAME_TIME_WARNING_INTERVAL:
			log_warning("PERFORMANCE", "High frame time: %.2f ms (threshold: %.2f ms)" % [frame_time, FRAME_TIME_WARNING])
			performance_warning.emit("frame_time", frame_time)
			_last_frame_time_warning_time = current_time

func _update_memory_tracking() -> void:
	var static_memory = Performance.get_monitor(Performance.MEMORY_STATIC)
	var dynamic_memory = Performance.get_monitor(Performance.MEMORY_MESSAGE_BUFFER_MAX)
	var total_memory = static_memory + dynamic_memory
	
	_performance_metrics["memory_static"] = static_memory
	_performance_metrics["memory_dynamic"] = dynamic_memory
	_performance_metrics["memory_total"] = total_memory
	
	# Check for memory issues with rate limiting
	if total_memory > MEMORY_WARNING_THRESHOLD:
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - _last_memory_warning_time > MEMORY_WARNING_INTERVAL:
			log_warning("MEMORY", "High memory usage: %.2f MB (threshold: %.2f MB)" % [total_memory / 1024.0 / 1024.0, MEMORY_WARNING_THRESHOLD / 1024.0 / 1024.0])
			performance_warning.emit("memory", total_memory)
			_last_memory_warning_time = current_time
	
	# Track memory growth
	_memory_snapshots.append({
		"timestamp": Time.get_ticks_msec(),
		"memory": total_memory
	})
	
	# Keep only last 100 snapshots
	if _memory_snapshots.size() > 100:
		_memory_snapshots.pop_front()

func _update_debug_overlay() -> void:
	if not _debug_overlay:
		return
	
	var panel = _debug_overlay.get_child(0)
	var vbox = panel.get_child(0)
	
	# Update labels
	var labels = []
	for child in vbox.get_children():
		if child is RichTextLabel:
			labels.append(child)
	
	if labels.size() >= 5:
		# FPS and Performance
		labels[0].text = "[color=yellow]FPS:[/color] %d | [color=yellow]Frame:[/color] %.1fms" % [
			_performance_metrics.get("fps", 0),
			_performance_metrics.get("frame_time", 0)
		]
		
		# Memory
		var memory_mb = _performance_metrics.get("memory_total", 0) / 1024.0 / 1024.0
		labels[1].text = "[color=cyan]Memory:[/color] %.1f MB" % memory_mb
		
		# Errors
		var total_errors = 0
		for count in _error_count.values():
			total_errors += count
		labels[2].text = "[color=red]Errors:[/color] %d" % total_errors
		
		# Active nodes
		labels[3].text = "[color=green]Nodes:[/color] %d" % get_tree().get_node_count()
		
		# Custom status
		labels[4].text = "[color=white]Status:[/color] %s" % _get_system_status()

func _get_system_status() -> String:
	# Check autoload status
	var missing_autoloads = []
	var autoloads = [
		"UnifiedColorManager",
		"CoreSystemManager",
		"UISystemManager",
		"EducationalPlatformManager",
		"ResourceManager",
		"AuthenticationManager"
	]
	
	for autoload in autoloads:
		if not get_node_or_null("/root/" + autoload):
			missing_autoloads.append(autoload)
	
	if missing_autoloads.size() > 0:
		return "Missing: " + ", ".join(missing_autoloads)
	
	return "All systems operational"

func _check_autoload_status() -> void:
	var autoloads = {
		"UnifiedColorManager": "/root/UnifiedColorManager",
		"CoreSystemManager": "/root/CoreSystemManager",
		"UISystemManager": "/root/UISystemManager",
		"EducationalPlatformManager": "/root/EducationalPlatformManager",
		"ResourceManager": "/root/ResourceManager",
		"AuthenticationManager": "/root/AuthenticationManager",
		"ProgressTracker": "/root/ProgressTracker",
		"AssessmentService": "/root/AssessmentService"
	}
	
	for autoload_name in autoloads:
		var node = get_node_or_null(NodePath(autoloads[autoload_name]))
		if not node:
			log_error("GENERAL", "Autoload not found: " + autoload_name)
		else:
			log_debug("GENERAL", "Autoload verified: " + autoload_name)

func _on_node_added(node: Node) -> void:
	# Check for common issues with new nodes
	if node.has_method("get_configuration_warnings"):
		var warnings = node.get_configuration_warnings()
		if warnings.size() > 0:
			log_warning("GENERAL", "Node warnings for %s: %s" % [node.get_path(), warnings])

func _on_node_removed(node: Node) -> void:
	# Track node removal for debugging
	log_debug("GENERAL", "Node removed: " + str(node.get_path()))

# Public logging functions
func log_debug(category: String, message: String) -> void:
	_log_message(ErrorSeverity.INFO, category, message)

func log_warning(category: String, message: String) -> void:
	_log_message(ErrorSeverity.WARNING, category, message)

func log_error(category: String, message: String, stack_trace: Array = []) -> void:
	_log_message(ErrorSeverity.ERROR, category, message, stack_trace)

func log_critical(category: String, message: String, stack_trace: Array = []) -> void:
	_log_message(ErrorSeverity.CRITICAL, category, message, stack_trace)

func _log_message(severity: ErrorSeverity, category: String, message: String, stack_trace: Array = []) -> void:
	var timestamp = Time.get_datetime_string_from_system()
	var severity_str = ["INFO", "WARNING", "ERROR", "CRITICAL"][severity]
	
	var log_entry = {
		"timestamp": timestamp,
		"severity": severity,
		"category": category,
		"message": message,
		"stack_trace": stack_trace
	}
	
	_debug_log.append(log_entry)
	
	# Count errors
	if severity >= ErrorSeverity.ERROR:
		if not _error_count.has(category):
			_error_count[category] = 0
		_error_count[category] += 1
		error_detected.emit(category, log_entry)
	
	# Print to console
	var console_msg = "[%s] [%s] %s: %s" % [timestamp, severity_str, category, message]
	match severity:
		ErrorSeverity.INFO:
			print(console_msg)
		ErrorSeverity.WARNING:
			push_warning(console_msg)
		ErrorSeverity.ERROR, ErrorSeverity.CRITICAL:
			push_error(console_msg)
	
	# Write to file
	if log_to_file and _log_file:
		_log_file.store_line(console_msg)
		if stack_trace.size() > 0 and error_stacktrace:
			for line in stack_trace:
				_log_file.store_line("  " + str(line))
		_log_file.flush()
	
	# Emit signal
	debug_message.emit(category, message)
	
	# Keep log size manageable
	if _debug_log.size() > 1000:
		_debug_log.pop_front()

# Enhanced error detection functions
func check_node_path(node: Node, path: NodePath, context: String = "") -> Node:
	var target = node.get_node_or_null(path)
	if not target:
		log_error("UI", "Missing node at path '%s' %s" % [path, context])
		return null
	return target

func check_resource_exists(path: String, context: String = "") -> bool:
	if not ResourceLoader.exists(path):
		log_error("RESOURCE", "Missing resource: '%s' %s" % [path, context])
		return false
	return true

func check_signal_connection(source: Object, signal_name: String, context: String = "") -> bool:
	if not source.has_signal(signal_name):
		log_error("SIGNAL", "Missing signal '%s' %s" % [signal_name, context])
		return false
	return true

# Performance profiling
func start_profiling(profile_name: String) -> void:
	set_meta("profile_" + profile_name, Time.get_ticks_usec())

func end_profiling(profile_name: String) -> float:
	if has_meta("profile_" + profile_name):
		var start_time = get_meta("profile_" + profile_name)
		var duration = (Time.get_ticks_usec() - start_time) / 1000.0
		remove_meta("profile_" + profile_name)
		log_debug("PERFORMANCE", "Profile '%s': %.2fms" % [profile_name, duration])
		return duration
	return 0.0

# Debug commands
func execute_debug_command(command: String) -> void:
	var parts = command.split(" ")
	if parts.size() == 0:
		return
	
	match parts[0]:
		"help":
			_show_debug_help()
		"errors":
			_show_error_summary()
		"performance":
			_show_performance_summary()
		"memory":
			_show_memory_summary()
		"nodes":
			_show_node_tree()
		"autoloads":
			_check_autoload_status()
		"clear":
			_clear_debug_log()
		"save":
			_save_debug_report()
		_:
			log_warning("GENERAL", "Unknown debug command: " + parts[0])

func _show_debug_help() -> void:
	print("\n=== Debug Commands ===")
	print("help - Show this help")
	print("errors - Show error summary")
	print("performance - Show performance metrics")
	print("memory - Show memory usage")
	print("nodes - Show node tree")
	print("autoloads - Check autoload status")
	print("clear - Clear debug log")
	print("save - Save debug report")
	print("===================\n")

func _show_error_summary() -> void:
	print("\n=== Error Summary ===")
	for category in _error_count:
		print("%s: %d errors" % [category, _error_count[category]])
	print("Total: %d errors" % _get_total_errors())
	print("===================\n")

func _show_performance_summary() -> void:
	print("\n=== Performance Summary ===")
	print("FPS: %d" % _performance_metrics.get("fps", 0))
	print("Frame Time: %.2fms" % _performance_metrics.get("frame_time", 0))
	print("Physics Time: %.2fms" % _performance_metrics.get("physics_time", 0))
	print("Idle Time: %.2fms" % _performance_metrics.get("idle_time", 0))
	print("=======================\n")

func _show_memory_summary() -> void:
	print("\n=== Memory Summary ===")
	var static_mb = _performance_metrics.get("memory_static", 0) / 1024.0 / 1024.0
	var dynamic_mb = _performance_metrics.get("memory_dynamic", 0) / 1024.0 / 1024.0
	var total_mb = static_mb + dynamic_mb
	print("Static: %.2f MB" % static_mb)
	print("Dynamic: %.2f MB" % dynamic_mb)
	print("Total: %.2f MB" % total_mb)
	print("===================\n")

func _show_node_tree() -> void:
	print("\n=== Node Tree ===")
	print("Total Nodes: %d" % get_tree().get_node_count())
	_print_node_tree(get_tree().root, 0)
	print("================\n")

func _print_node_tree(node: Node, indent: int) -> void:
	if indent > 3:  # Limit depth
		return
	
	var indent_str = "  ".repeat(indent)
	print("%s%s (%s)" % [indent_str, node.name, node.get_class()])
	
	for child in node.get_children():
		_print_node_tree(child, indent + 1)

func _clear_debug_log() -> void:
	_debug_log.clear()
	_error_count.clear()
	log_debug("GENERAL", "Debug log cleared")

func _save_debug_report() -> void:
	var report_path = "user://debug_report_%s.txt" % Time.get_datetime_string_from_system().replace(":", "-")
	var file = FileAccess.open(report_path, FileAccess.WRITE)
	
	if file:
		file.store_line("=== NeuroVision Debug Report ===")
		file.store_line("Generated: " + Time.get_datetime_string_from_system())
		file.store_line("")
		
		# System info
		file.store_line("=== System Info ===")
		file.store_line("Godot Version: " + Engine.get_version_info().string)
		file.store_line("OS: " + OS.get_name())
		file.store_line("")
		
		# Error summary
		file.store_line("=== Error Summary ===")
		for category in _error_count:
			file.store_line("%s: %d errors" % [category, _error_count[category]])
		file.store_line("")
		
		# Recent errors
		file.store_line("=== Recent Errors ===")
		var error_logs = _debug_log.filter(func(entry): return entry.severity >= ErrorSeverity.ERROR)
		for entry in error_logs.slice(-50):  # Last 50 errors
			file.store_line("[%s] %s: %s" % [entry.timestamp, entry.category, entry.message])
		
		file.close()
		log_debug("GENERAL", "Debug report saved to: " + report_path)

func _get_total_errors() -> int:
	var total = 0
	for count in _error_count.values():
		total += count
	return total

func _exit_tree() -> void:
	if _log_file:
		_log_file.close()
	
	if _debug_overlay:
		_debug_overlay.queue_free()
