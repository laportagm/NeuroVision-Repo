extends Node3D

## LOD Testing Scene for Performance Optimization
##
## This scene provides tools to test and optimize LOD loading performance,
## specifically targeting 30-60 FPS on Intel UHD 620 graphics.

signal lod_changed(new_level: int)
signal performance_report_ready(report: Dictionary)

# === CONSTANTS ===
const TARGET_FPS_MIN: float = 30.0
const TARGET_FPS_MAX: float = 60.0
const TEST_DURATION: float = 10.0  # Seconds per LOD level test
const WARMUP_TIME: float = 2.0     # Seconds to wait before measuring

# === NODES ===
@onready var camera: Camera3D = $Camera3D
@onready var model_container: Node3D = $ModelContainer
@onready var ui_container: Control = $UI
@onready var fps_label: Label = $UI/PerformancePanel/VBox/FPSLabel
@onready var lod_label: Label = $UI/PerformancePanel/VBox/LODLabel
@onready var gpu_label: Label = $UI/PerformancePanel/VBox/GPULabel
@onready var vertices_label: Label = $UI/PerformancePanel/VBox/VerticesLabel
@onready var memory_label: Label = $UI/PerformancePanel/VBox/MemoryLabel
@onready var status_label: Label = $UI/StatusPanel/StatusLabel
@onready var results_text: RichTextLabel = $UI/ResultsPanel/ScrollContainer/ResultsText

# === PRIVATE VARIABLES ===
var _current_model = null
var _current_lod: int = -1
var _model_loader = null
var _gpu_detector = null
var _is_testing: bool = false
var _test_results: Dictionary = {}
var _fps_samples: Array[float] = []
var _test_timer: float = 0.0
var _warmup_timer: float = 0.0
var _current_test_lod: int = 2  # Start with LOW
var _rotation_enabled: bool = true

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[LODTesting] Scene initialized")
	
	# Get autoloaded services
	if has_node("/root/ModelLoader"):
		_model_loader = get_node("/root/ModelLoader")
	else:
		push_error("[LODTesting] ModelLoader not found!")
		
	# Initialize GPU detector
	var GPUDetectorScript = preload("res://src/systems/3d_interaction/GPUDetector.gd")
	_gpu_detector = GPUDetectorScript.new()
	add_child(_gpu_detector)
	
	# Detect GPU
	var gpu_info = _gpu_detector.detect_gpu()
	gpu_label.text = "GPU: %s (%d MB)" % [gpu_info.get("renderer_name", "Unknown"), gpu_info.get("vram_mb", 0)]
	
	# Setup camera
	camera.position = Vector3(0, 5, 15)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	
	# Start with manual testing
	_load_model_at_lod(2)  # Start with LOW

func start_automated_test() -> void:
	"""Start automated testing of all LOD levels"""
	if _is_testing:
		print("[LODTesting] Test already in progress")
		return
		
	_is_testing = true
	_test_results.clear()
	_current_test_lod = 2  # Start with LOW
	_warmup_timer = WARMUP_TIME
	_test_timer = 0.0
	_fps_samples.clear()
	
	status_label.text = "Starting automated LOD test..."
	results_text.clear()
	results_text.append_text("[b]LOD Performance Test Results[/b]\n")
	results_text.append_text("Target: %d-%d FPS on Intel UHD 620\n\n" % [TARGET_FPS_MIN, TARGET_FPS_MAX])

func stop_test() -> void:
	"""Stop the current test"""
	_is_testing = false
	status_label.text = "Test stopped"

func toggle_rotation(enabled: bool) -> void:
	"""Toggle model rotation during testing"""
	_rotation_enabled = enabled

func force_lod_level(lod_level: int) -> void:
	"""Manually force a specific LOD level"""
	_load_model_at_lod(lod_level)

# === PRIVATE METHODS ===

func _process(delta: float) -> void:
	# Update FPS display
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	fps_label.text = "FPS: %.1f" % fps
	
	# Update other metrics
	var vertices = Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	vertices_label.text = "Vertices: %s" % _format_number(int(vertices))
	
	var memory_mb = OS.get_static_memory_usage() / 1048576.0
	memory_label.text = "Memory: %.1f MB" % memory_mb
	
	# Rotate model if enabled
	if _rotation_enabled and _current_model:
		_current_model.rotate_y(delta * 0.5)
	
	# Handle automated testing
	if _is_testing:
		_handle_automated_test(delta, fps)

func _handle_automated_test(delta: float, fps: float) -> void:
	"""Handle the automated testing process"""
	if _warmup_timer > 0:
		_warmup_timer -= delta
		status_label.text = "Warming up LOD %s... %.1fs" % [_get_lod_name(_current_test_lod), _warmup_timer]
		return
	
	# Collect FPS samples
	_fps_samples.append(fps)
	_test_timer += delta
	
	status_label.text = "Testing LOD %s... %.1fs/%.1fs" % [_get_lod_name(_current_test_lod), _test_timer, TEST_DURATION]
	
	if _test_timer >= TEST_DURATION:
		# Test complete for this LOD
		_record_test_results()
		
		# Move to next LOD
		_current_test_lod -= 1
		if _current_test_lod >= 0:
			_load_model_at_lod(_current_test_lod)
			_warmup_timer = WARMUP_TIME
			_test_timer = 0.0
			_fps_samples.clear()
		else:
			# All tests complete
			_finalize_test_results()

func _load_model_at_lod(lod_level: int) -> void:
	"""Load the Internal-Structures model at specific LOD"""
	# Clear existing model
	if _current_model:
		_current_model.queue_free()
		_current_model = null
	
	_current_lod = lod_level
	lod_label.text = "LOD: %s" % _get_lod_name(lod_level)
	
	# Load new model
	if _model_loader:
		_model_loader.load_model_async("Internal-Structures", _on_model_loaded, lod_level)
	
	lod_changed.emit(lod_level)

func _on_model_loaded(model_instance) -> void:
	"""Handle model loaded callback"""
	if model_instance:
		_current_model = model_instance
		model_container.add_child(model_instance)
		
		# Center and scale model
		model_instance.position = Vector3.ZERO
		model_instance.scale = Vector3.ONE * 0.1  # Scale down brain model
		
		print("[LODTesting] Model loaded at LOD: ", _current_lod)
	else:
		push_error("[LODTesting] Failed to load model")
		status_label.text = "Failed to load model"

func _record_test_results() -> void:
	"""Record results for current LOD test"""
	if _fps_samples.is_empty():
		return
	
	# Calculate statistics
	var avg_fps = 0.0
	var min_fps = _fps_samples[0]
	var max_fps = _fps_samples[0]
	
	for fps in _fps_samples:
		avg_fps += fps
		min_fps = min(min_fps, fps)
		max_fps = max(max_fps, fps)
	
	avg_fps /= _fps_samples.size()
	
	# Calculate percentiles
	var sorted_samples = _fps_samples.duplicate()
	sorted_samples.sort()
	var p1_index = int(sorted_samples.size() * 0.01)
	var p99_index = int(sorted_samples.size() * 0.99)
	var fps_1_percent = sorted_samples[p1_index]
	var fps_99_percent = sorted_samples[p99_index]
	
	# Store results
	var lod_name = _get_lod_name(_current_test_lod)
	_test_results[lod_name] = {
		"avg_fps": avg_fps,
		"min_fps": min_fps,
		"max_fps": max_fps,
		"1_percent": fps_1_percent,
		"99_percent": fps_99_percent,
		"samples": _fps_samples.size(),
		"meets_target": avg_fps >= TARGET_FPS_MIN
	}
	
	# Add to results display
	var color = "green" if avg_fps >= TARGET_FPS_MIN else "red"
	results_text.append_text("\n[b]%s LOD Results:[/b]\n" % lod_name)
	results_text.append_text("  Average FPS: [color=%s]%.1f[/color]\n" % [color, avg_fps])
	results_text.append_text("  Min/Max: %.1f / %.1f\n" % [min_fps, max_fps])
	results_text.append_text("  1%%/99%%: %.1f / %.1f\n" % [fps_1_percent, fps_99_percent])
	results_text.append_text("  Target Met: %s\n" % ("✅" if avg_fps >= TARGET_FPS_MIN else "❌"))

func _finalize_test_results() -> void:
	"""Finalize and display all test results"""
	_is_testing = false
	status_label.text = "Test complete!"
	
	# Generate recommendations
	results_text.append_text("\n[b]Recommendations:[/b]\n")
	
	var recommended_lod = -1
	for i in range(3):
		var lod_name = _get_lod_name(i)
		if _test_results.has(lod_name) and _test_results[lod_name].meets_target:
			recommended_lod = i
			break
	
	if recommended_lod >= 0:
		results_text.append_text("✅ Recommended LOD: %s\n" % _get_lod_name(recommended_lod))
		results_text.append_text("   Achieves %.1f FPS average\n" % _test_results[_get_lod_name(recommended_lod)].avg_fps)
	else:
		results_text.append_text("⚠️  No LOD meets target FPS!\n")
		results_text.append_text("   Consider further optimization\n")
	
	# Emit signal with results
	performance_report_ready.emit(_test_results)

func _get_lod_name(lod_level: int) -> String:
	"""Convert LOD level to name"""
	match lod_level:
		0: return "HIGH"
		1: return "MEDIUM"
		2: return "LOW"
		_: return "UNKNOWN"

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

func _input(event: InputEvent) -> void:
	"""Handle input events"""
	if event.is_action_pressed("ui_select"):  # Space
		toggle_rotation(!_rotation_enabled)
	elif event.is_action_pressed("ui_accept"):  # Enter
		start_automated_test()
	elif event.is_action_pressed("ui_cancel"):  # Escape
		stop_test()
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				force_lod_level(2)  # LOW
			KEY_2:
				force_lod_level(1)  # MEDIUM
			KEY_3:
				force_lod_level(0)  # HIGH