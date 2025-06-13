extends Control

## Model Performance Monitor
##
## Debug overlay that shows current LOD level, FPS, and GPU info
## Add this to your main scene to monitor optimization effectiveness

# === UI ELEMENTS ===
var info_label: RichTextLabel
var background: ColorRect

# === MONITORING DATA ===
var current_fps: float = 0.0
var fps_history: Array[float] = []
var gpu_info: Dictionary = {}
var current_lod: String = "Unknown"
var model_stats: Dictionary = {}

# === CONSTANTS ===
const UPDATE_INTERVAL: float = 0.5
const FPS_HISTORY_SIZE: int = 10

func _ready() -> void:
	# Set up UI
	_create_ui()
	
	# Get GPU info
	if has_node("/root/ModelLoader"):
		var model_loader = get_node("/root/ModelLoader")
		if model_loader.has_method("get_property") and model_loader.get("_gpu_detector"):
			var gpu_detector = model_loader.get("_gpu_detector")
			if gpu_detector and gpu_detector.has_method("get_gpu_info"):
				gpu_info = gpu_detector.get_gpu_info()
	
	# Start update timer
	var timer = Timer.new()
	timer.wait_time = UPDATE_INTERVAL
	timer.timeout.connect(_update_display)
	timer.autostart = true
	add_child(timer)

func _create_ui() -> void:
	"""Create the monitoring UI"""
	# Background
	background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.7)
	background.size = Vector2(400, 200)
	background.position = Vector2(10, 10)
	add_child(background)
	
	# Info label
	info_label = RichTextLabel.new()
	info_label.size = Vector2(380, 180)
	info_label.position = Vector2(20, 20)
	info_label.bbcode_enabled = true
	info_label.fit_content = true
	add_child(info_label)

func _update_display() -> void:
	"""Update the performance display"""
	# Get current FPS
	current_fps = Performance.get_monitor(Performance.TIME_FPS)
	fps_history.append(current_fps)
	if fps_history.size() > FPS_HISTORY_SIZE:
		fps_history.pop_front()
	
	# Calculate average FPS
	var avg_fps = 0.0
	for fps in fps_history:
		avg_fps += fps
	avg_fps /= fps_history.size()
	
	# Get current metrics
	var metrics = {
		"fps": current_fps,
		"avg_fps": avg_fps,
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"vertices": Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
		"memory_mb": OS.get_static_memory_usage() / 1048576.0
	}
	
	# Get LOD info from ModelLoader
	if has_node("/root/ModelLoader"):
		var model_loader = get_node("/root/ModelLoader")
		var models = model_loader.get_model_list()
		if models.size() > 0:
			var first_model = models[0]
			var metadata = model_loader.get_model_metadata(first_model)
			current_lod = _get_lod_name(metadata.get("lod_level", -1))
			model_stats = metadata
	
	# Build display text
	var text = "[b][color=cyan]NeuroVision Performance Monitor[/color][/b]\n"
	text += "[color=gray]────────────────────────────────[/color]\n\n"
	
	# GPU Info
	text += "[b]GPU:[/b] %s\n" % gpu_info.get("renderer_name", "Unknown")
	text += "[b]VRAM:[/b] %d MB (estimated)\n\n" % gpu_info.get("vram_mb", 0)
	
	# Performance
	text += "[b]FPS:[/b] %d (avg: %d)\n" % [int(metrics.fps), int(metrics.avg_fps)]
	text += _get_fps_color_tag(metrics.avg_fps)
	
	# Model Info with visual indicator
	var lod_indicator = _get_lod_indicator(current_lod)
	text += "\n[b]Current LOD:[/b] %s %s\n" % [current_lod, lod_indicator]
	if model_stats.has("vertex_count"):
		text += "[b]Vertices:[/b] %s\n" % _format_number(model_stats.vertex_count)
	
	# System
	text += "\n[b]Draw Calls:[/b] %d\n" % int(metrics.draw_calls)
	text += "[b]Memory:[/b] %.1f MB\n" % metrics.memory_mb
	
	info_label.text = text

func _get_lod_name(lod_level: int) -> String:
	"""Convert LOD level to name"""
	match lod_level:
		0: return "HIGH"
		1: return "MEDIUM"
		2: return "LOW"
		_: return "Unknown"

func _get_fps_color_tag(fps: float) -> String:
	"""Get color tag based on FPS"""
	if fps >= 60:
		return "[color=green]Excellent[/color]"
	elif fps >= 30:
		return "[color=yellow]Good[/color]"
	elif fps >= 20:
		return "[color=orange]Acceptable[/color]"
	else:
		return "[color=red]Poor - Needs Optimization[/color]"

func _get_lod_indicator(lod_name: String) -> String:
	"""Get visual indicator for LOD level"""
	match lod_name:
		"LOW":
			return "[color=green]▣[/color] (Performance)"
		"MEDIUM":
			return "[color=yellow]▣▣[/color] (Balanced)"
		"HIGH":
			return "[color=red]▣▣▣[/color] (Quality)"
		_:
			return ""

func _format_number(num: int) -> String:
	"""Format large numbers with commas"""
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
	"""Handle input to toggle visibility"""
	if event.is_action_pressed("ui_page_up"):  # PageUp key
		visible = !visible