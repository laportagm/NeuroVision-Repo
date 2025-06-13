extends Node

## LOD Debug Commands
##
## Provides debug console commands for testing LOD performance.
## Add to autoload or include in your debug system.

# === PRIVATE VARIABLES ===
var _model_loader = null
var _performance_monitor = null

# === PUBLIC METHODS ===

func _ready() -> void:
	# Get references to autoloaded services
	if has_node("/root/ModelLoader"):
		_model_loader = get_node("/root/ModelLoader")
	if has_node("/root/PerformanceMonitor"):
		_performance_monitor = get_node("/root/PerformanceMonitor")
	
	print("[LODDebug] Debug commands initialized")

func register_commands(debug_console) -> void:
	"""Register LOD-specific debug commands"""
	if not debug_console:
		return
	
	# LOD Commands
	debug_console.register_command("lod", _cmd_lod_info, "Show current LOD information")
	debug_console.register_command("lod_set", _cmd_set_lod, "Set LOD level (0=HIGH, 1=MEDIUM, 2=LOW)")
	debug_console.register_command("lod_test", _cmd_test_lod, "Open LOD testing scene")
	debug_console.register_command("lod_list", _cmd_list_models, "List loaded models and their LODs")
	debug_console.register_command("lod_stats", _cmd_lod_stats, "Show LOD performance statistics")
	debug_console.register_command("gpu_info", _cmd_gpu_info, "Show GPU detection results")
	debug_console.register_command("fps_target", _cmd_set_fps_target, "Set target FPS (30-120)")

# === COMMAND IMPLEMENTATIONS ===

func _cmd_lod_info(args: Array) -> String:
	"""Show current LOD information"""
	if not _model_loader:
		return "ERROR: ModelLoader not available"
	
	var result = "=== LOD Information ===\n"
	result += "Current Quality: %s\n" % _get_quality_name()
	
	var models = _model_loader.get_model_list()
	if models.is_empty():
		result += "No models loaded"
	else:
		for model_name in models:
			var metadata = _model_loader.get_model_metadata(model_name)
			var lod_level = metadata.get("lod_level", -1)
			var vertex_count = metadata.get("vertex_count", 0)
			result += "\n%s:\n" % model_name
			result += "  LOD: %s\n" % _get_lod_name(lod_level)
			result += "  Vertices: %s\n" % _format_number(vertex_count)
	
	return result

func _cmd_set_lod(args: Array) -> String:
	"""Set LOD level for all models"""
	if args.is_empty():
		return "Usage: lod_set <level>\n  0 = HIGH\n  1 = MEDIUM\n  2 = LOW"
	
	var level = int(args[0])
	if level < 0 or level > 2:
		return "ERROR: Invalid LOD level. Use 0-2"
	
	if not _model_loader:
		return "ERROR: ModelLoader not available"
	
	# Change LOD for all loaded models
	var models = _model_loader.get_model_list()
	var changed = 0
	
	for model_name in models:
		if _model_loader.change_model_lod(model_name, level):
			changed += 1
	
	return "Changed LOD to %s for %d model(s)" % [_get_lod_name(level), changed]

func _cmd_test_lod(args: Array) -> String:
	"""Open LOD testing scene"""
	var test_scene = load("res://src/debug/LODTestingScene.tscn")
	if test_scene:
		get_tree().change_scene_to_packed(test_scene)
		return "Loading LOD testing scene..."
	else:
		return "ERROR: LOD testing scene not found"

func _cmd_list_models(args: Array) -> String:
	"""List all loaded models"""
	if not _model_loader:
		return "ERROR: ModelLoader not available"
	
	var models = _model_loader.get_model_list()
	if models.is_empty():
		return "No models loaded"
	
	var result = "=== Loaded Models ===\n"
	for i in range(models.size()):
		var model_name = models[i]
		var metadata = _model_loader.get_model_metadata(model_name)
		result += "%d. %s (LOD: %s, Vertices: %s)\n" % [
			i + 1,
			model_name,
			_get_lod_name(metadata.get("lod_level", -1)),
			_format_number(metadata.get("vertex_count", 0))
		]
	
	return result

func _cmd_lod_stats(args: Array) -> String:
	"""Show LOD performance statistics"""
	var result = "=== LOD Performance Stats ===\n"
	
	# Current performance
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var vertices = Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	var draw_calls = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var memory_mb = OS.get_static_memory_usage() / 1048576.0
	
	result += "Current FPS: %.1f\n" % fps
	result += "Vertices: %s\n" % _format_number(int(vertices))
	result += "Draw Calls: %d\n" % int(draw_calls)
	result += "Memory: %.1f MB\n" % memory_mb
	
	# Performance status
	if fps >= 60:
		result += "\nStatus: ✅ Excellent performance"
	elif fps >= 30:
		result += "\nStatus: ✅ Good performance (meets target)"
	elif fps >= 20:
		result += "\nStatus: ⚠️  Acceptable performance"
	else:
		result += "\nStatus: ❌ Poor performance - consider lower LOD"
	
	return result

func _cmd_gpu_info(args: Array) -> String:
	"""Show GPU detection results"""
	if not _model_loader or not _model_loader._gpu_detector:
		return "ERROR: GPU detector not available"
	
	var gpu_info = _model_loader._gpu_detector.get_gpu_info()
	var result = "=== GPU Information ===\n"
	result += "Renderer: %s\n" % gpu_info.get("renderer_name", "Unknown")
	result += "Vendor: %s\n" % gpu_info.get("vendor", "Unknown")
	result += "API: %s\n" % gpu_info.get("renderer_api", "Unknown")
	result += "VRAM: %d MB (estimated)\n" % gpu_info.get("vram_mb", 0)
	result += "Max Texture: %dx%d\n" % [gpu_info.get("max_texture_size", 0), gpu_info.get("max_texture_size", 0)]
	
	# Detected quality
	var quality = _model_loader._gpu_detector.get_recommended_quality()
	result += "\nRecommended Quality: %s" % _get_quality_name_for_level(quality)
	
	return result

func _cmd_set_fps_target(args: Array) -> String:
	"""Set target FPS"""
	if args.is_empty():
		return "Usage: fps_target <fps>\nExample: fps_target 60"
	
	var target = int(args[0])
	if target < 30 or target > 120:
		return "ERROR: Target FPS must be between 30 and 120"
	
	Engine.max_fps = target
	return "Target FPS set to %d" % target

# === UTILITY FUNCTIONS ===

func _get_quality_name() -> String:
	"""Get current quality setting name"""
	if _performance_monitor:
		var level = _performance_monitor.get_current_quality_level()
		return _get_quality_name_for_level(level)
	return "Unknown"

func _get_quality_name_for_level(level: int) -> String:
	"""Convert quality level to name"""
	match level:
		0: return "LOW"
		1: return "MEDIUM"
		2: return "HIGH"
		3: return "ULTRA"
		_: return "Unknown"

func _get_lod_name(level: int) -> String:
	"""Convert LOD level to name"""
	match level:
		0: return "HIGH"
		1: return "MEDIUM"
		2: return "LOW"
		_: return "Unknown"

func _format_number(num: int) -> String:
	"""Format number with commas"""
	var str_num = str(num)
	var result = ""
	var count = 0
	
	for i in range(str_num.length() - 1, -1, -1):
		if count == 3:
			result = "," + result
			count = 0
		result = str_num[i] + result
		count += 1
	
	return result