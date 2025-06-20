extends CanvasLayer

## In-game debug console for NeuroVision
## Press ` (backtick) to toggle console

signal command_executed(command: String, result: String)

@onready var console_panel := PanelContainer.new()
@onready var console_output := RichTextLabel.new()
@onready var console_input := LineEdit.new()
@onready var suggestions_panel := ItemList.new()

var command_history: Array[String] = []
var history_index: int = 0
var is_visible: bool = false

# Available commands
var commands := {
	# System commands
	"help": _cmd_help,
	"clear": _cmd_clear,
	"exit": _cmd_exit,
	"quit": _cmd_exit,
	
	# Debug commands
	"fps": _cmd_fps,
	"memory": _cmd_memory,
	"nodes": _cmd_nodes,
	"errors": _cmd_errors,
	"autoloads": _cmd_autoloads,
	"performance": _cmd_performance,
	
	# Scene commands
	"scene": _cmd_scene,
	"reload": _cmd_reload,
	"screenshot": _cmd_screenshot,
	
	# Educational commands
	"brain": _cmd_brain,
	"theme": _cmd_theme,
	"knowledge": _cmd_knowledge,
	"validate": _cmd_validate,
	
	# Testing commands
	"test": _cmd_test,
	"stress": _cmd_stress,
	"profile": _cmd_profile
}

func _ready() -> void:
	_setup_console()
	hide()
	
	# Connect to debug system if available
	if has_node("/root/DebugSystem"):
		var debug_system = get_node("/root/DebugSystem")
		debug_system.debug_message.connect(_on_debug_message)
		debug_system.error_detected.connect(_on_error_detected)

func _setup_console() -> void:
	# Setup console panel
	console_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	console_panel.size.y = 400
	console_panel.modulate.a = 0.95
	add_child(console_panel)
	
	var vbox = VBoxContainer.new()
	console_panel.add_child(vbox)
	
	# Title bar
	var title_bar = HBoxContainer.new()
	vbox.add_child(title_bar)
	
	var title = Label.new()
	title.text = "NeuroVision Debug Console"
	title.add_theme_font_size_override("font_size", 16)
	title_bar.add_child(title)
	
	title_bar.add_spacer(false)
	
	var close_btn = Button.new()
	close_btn.text = "X"
	close_btn.pressed.connect(toggle_console)
	title_bar.add_child(close_btn)
	
	# Output area
	console_output.bbcode_enabled = true
	console_output.scroll_following = true
	console_output.custom_minimum_size.y = 300
	console_output.add_theme_color_override("default_color", Color.WHITE)
	console_output.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(console_output)
	
	# Input area
	var input_container = HBoxContainer.new()
	vbox.add_child(input_container)
	
	var prompt = Label.new()
	prompt.text = "> "
	input_container.add_child(prompt)
	
	console_input.expand_to_text_length = true
	console_input.text_submitted.connect(_on_command_submitted)
	console_input.text_changed.connect(_on_input_changed)
	console_input.gui_input.connect(_on_input_gui_event)
	input_container.add_child(console_input)
	
	# Suggestions panel (hidden by default)
	suggestions_panel.hide()
	suggestions_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	suggestions_panel.position.y = 400
	suggestions_panel.size.y = 200
	suggestions_panel.item_selected.connect(_on_suggestion_selected)
	add_child(suggestions_panel)
	
	# Initial message
	print_line("[color=cyan]NeuroVision Debug Console v2.0[/color]")
	print_line("Type 'help' for available commands")
	print_line("")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug_console"):
		toggle_console()

func _on_input_gui_event(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP:
				_navigate_history(-1)
				get_viewport().set_input_as_handled()
			KEY_DOWN:
				_navigate_history(1)
				get_viewport().set_input_as_handled()
			KEY_TAB:
				_autocomplete()
				get_viewport().set_input_as_handled()

func toggle_console() -> void:
	is_visible = !is_visible
	if is_visible:
		show()
		console_input.grab_focus()
	else:
		hide()

func _on_command_submitted(text: String) -> void:
	if text.strip_edges() == "":
		return
	
	# Add to history
	command_history.append(text)
	history_index = command_history.size()
	
	# Echo command
	print_line("[color=yellow]> " + text + "[/color]")
	
	# Execute command
	_execute_command(text)
	
	# Clear input
	console_input.clear()

func _execute_command(text: String) -> void:
	var parts = text.split(" ", false)
	if parts.is_empty():
		return
	
	var cmd = parts[0].to_lower()
	var args = parts.slice(1)
	
	if commands.has(cmd):
		var result = commands[cmd].call(args)
		if result != null and result != "":
			print_line(str(result))
		command_executed.emit(cmd, str(result))
	else:
		print_line("[color=red]Unknown command: " + cmd + "[/color]")
		print_line("Type 'help' for available commands")

func _on_input_changed(text: String) -> void:
	if text == "":
		suggestions_panel.hide()
		return
	
	# Show command suggestions
	var suggestions = []
	for cmd in commands.keys():
		if cmd.begins_with(text.to_lower()):
			suggestions.append(cmd)
	
	if suggestions.size() > 0:
		suggestions_panel.clear()
		for sug in suggestions:
			suggestions_panel.add_item(sug)
		suggestions_panel.show()
	else:
		suggestions_panel.hide()

func _on_suggestion_selected(index: int) -> void:
	var suggestion = suggestions_panel.get_item_text(index)
	console_input.text = suggestion + " "
	console_input.caret_column = console_input.text.length()
	suggestions_panel.hide()
	console_input.grab_focus()

func _navigate_history(direction: int) -> void:
	if command_history.is_empty():
		return
	
	history_index = clamp(history_index + direction, 0, command_history.size())
	
	if history_index < command_history.size():
		console_input.text = command_history[history_index]
		console_input.caret_column = console_input.text.length()
	else:
		console_input.clear()

func _autocomplete() -> void:
	var text = console_input.text
	if text == "":
		return
	
	for cmd in commands.keys():
		if cmd.begins_with(text.to_lower()) and cmd != text:
			console_input.text = cmd + " "
			console_input.caret_column = console_input.text.length()
			break

func print_line(text: String) -> void:
	console_output.append_text(text + "\n")

func _on_debug_message(category: String, message: String) -> void:
	print_line("[color=gray][%s] %s[/color]" % [category, message])

func _on_error_detected(error_type: String, details: Dictionary) -> void:
	print_line("[color=red][ERROR] %s: %s[/color]" % [error_type, details.get("message", "")])

# Command implementations
func _cmd_help(args: Array) -> String:
	var help_text = "[color=cyan]Available Commands:[/color]\n"
	help_text += "  help - Show this help\n"
	help_text += "  clear - Clear console\n"
	help_text += "  exit/quit - Close console\n"
	help_text += "\n[color=cyan]Debug Commands:[/color]\n"
	help_text += "  fps - Show FPS info\n"
	help_text += "  memory - Show memory usage\n"
	help_text += "  nodes - Show node count\n"
	help_text += "  errors - Show error summary\n"
	help_text += "  autoloads - Check autoload status\n"
	help_text += "  performance - Show performance metrics\n"
	help_text += "\n[color=cyan]Scene Commands:[/color]\n"
	help_text += "  scene [name] - Load scene or show current\n"
	help_text += "  reload - Reload current scene\n"
	help_text += "  screenshot - Take screenshot\n"
	help_text += "\n[color=cyan]Educational Commands:[/color]\n"
	help_text += "  brain [structure] - Show brain structure info\n"
	help_text += "  theme [name] - Change theme\n"
	help_text += "  knowledge [query] - Search knowledge base\n"
	help_text += "  validate - Validate educational content\n"
	help_text += "\n[color=cyan]Testing Commands:[/color]\n"
	help_text += "  test [component] - Run component tests\n"
	help_text += "  stress [type] - Run stress test\n"
	help_text += "  profile [function] - Profile function"
	return help_text

func _cmd_clear(args: Array) -> String:
	console_output.clear()
	return ""

func _cmd_exit(args: Array) -> String:
	toggle_console()
	return ""

func _cmd_fps(args: Array) -> String:
	var fps = Engine.get_frames_per_second()
	var frame_time = 1000.0 / fps if fps > 0 else 0
	return "FPS: %d (%.2fms)" % [fps, frame_time]

func _cmd_memory(args: Array) -> String:
	var static_mem = Performance.get_monitor(Performance.MEMORY_STATIC) / 1024.0 / 1024.0
	var dynamic_mem = Performance.get_monitor(Performance.MEMORY_MESSAGE_BUFFER_MAX) / 1024.0 / 1024.0
	var total = static_mem + dynamic_mem
	return "Memory - Static: %.2f MB, Dynamic: %.2f MB, Total: %.2f MB" % [static_mem, dynamic_mem, total]

func _cmd_nodes(args: Array) -> String:
	return "Active nodes: %d" % get_tree().get_node_count()

func _cmd_errors(args: Array) -> String:
	if has_node("/root/DebugSystem"):
		var debug_system = get_node("/root/DebugSystem")
		debug_system.execute_debug_command("errors")
		return "See error summary above"
	return "Debug system not available"

func _cmd_autoloads(args: Array) -> String:
	var autoloads = [
		"UnifiedColorManager",
		"CoreSystemManager", 
		"UISystemManager",
		"EducationalPlatformManager",
		"ResourceManager",
		"AuthenticationManager",
		"ProgressTracker",
		"AssessmentService"
	]
	
	var result = "[color=cyan]Autoload Status:[/color]\n"
	for autoload in autoloads:
		var node = get_node_or_null("/root/" + autoload)
		if node:
			result += "  ✓ %s\n" % autoload
		else:
			result += "  [color=red]✗ %s (missing)[/color]\n" % autoload
	
	return result

func _cmd_performance(args: Array) -> String:
	var result = "[color=cyan]Performance Metrics:[/color]\n"
	result += "  FPS: %d\n" % Engine.get_frames_per_second()
	result += "  Physics FPS: %d\n" % Engine.physics_ticks_per_second
	result += "  Draw Calls: %d\n" % Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	result += "  Vertex Count: %d\n" % Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	result += "  Video Memory: %.2f MB\n" % (Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1024.0 / 1024.0)
	return result

func _cmd_scene(args: Array) -> String:
	if args.is_empty():
		var current = get_tree().current_scene
		if current:
			return "Current scene: " + current.scene_file_path
		return "No scene loaded"
	else:
		var scene_name = args[0]
		var scene_path = "res://scenes/%s.tscn" % scene_name
		if ResourceLoader.exists(scene_path):
			get_tree().change_scene_to_file(scene_path)
			return "Loading scene: " + scene_path
		return "[color=red]Scene not found: " + scene_path + "[/color]"

func _cmd_reload(args: Array) -> String:
	get_tree().reload_current_scene()
	return "Reloading current scene..."

func _cmd_screenshot(args: Array) -> String:
	var image = get_viewport().get_texture().get_image()
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	var path = "user://screenshot_%s.png" % timestamp
	image.save_png(path)
	return "Screenshot saved to: " + path

func _cmd_brain(args: Array) -> String:
	if args.is_empty():
		return "Usage: brain [structure_name]"
	
	var structure = args[0]
	if has_node("/root/KnowledgeService"):
		var knowledge = get_node("/root/KnowledgeService")
		var data = knowledge.get_structure(structure)
		if not data.is_empty():
			var result = "[color=cyan]%s:[/color]\n" % data.get("display_name", structure)
			result += "  Description: %s\n" % data.get("description", "N/A")
			result += "  Location: %s\n" % data.get("anatomical_location", "N/A")
			result += "  Functions: %s" % ", ".join(data.get("functions", []))
			return result
		return "[color=red]Structure not found: " + structure + "[/color]"
	return "Knowledge service not available"

func _cmd_theme(args: Array) -> String:
	if args.is_empty():
		return "Usage: theme [enhanced|minimal|high_contrast|colorblind]"
	
	var theme_name = args[0]
	if has_node("/root/UIThemeManager"):
		var theme_manager = get_node("/root/UIThemeManager")
		match theme_name:
			"enhanced":
				theme_manager.set_theme_mode(theme_manager.ThemeMode.ENHANCED)
			"minimal":
				theme_manager.set_theme_mode(theme_manager.ThemeMode.MINIMAL)
			_:
				theme_manager.apply_preset_theme(theme_name)
		return "Theme changed to: " + theme_name
	return "Theme manager not available"

func _cmd_knowledge(args: Array) -> String:
	if args.is_empty():
		return "Usage: knowledge [search_query]"
	
	var query = " ".join(args)
	if has_node("/root/KnowledgeService"):
		var knowledge = get_node("/root/KnowledgeService")
		var results = knowledge.search_structures(query)
		if results.size() > 0:
			var result = "[color=cyan]Search results for '%s':[/color]\n" % query
			for i in min(5, results.size()):
				result += "  • %s\n" % results[i].display_name
			return result
		return "No results found for: " + query
	return "Knowledge service not available"

func _cmd_validate(args: Array) -> String:
	var result = "[color=cyan]Validation Results:[/color]\n"
	
	# Check autoloads
	var autoload_count = 0
	var missing_autoloads = []
	for autoload in ["UnifiedColorManager", "CoreSystemManager", "UISystemManager"]:
		if get_node_or_null("/root/" + autoload):
			autoload_count += 1
		else:
			missing_autoloads.append(autoload)
	
	result += "  Autoloads: %d/3 loaded\n" % autoload_count
	if missing_autoloads.size() > 0:
		result += "    Missing: %s\n" % ", ".join(missing_autoloads)
	
	# Check performance
	var fps = Engine.get_frames_per_second()
	result += "  Performance: %s\n" % ("✓ Good" if fps >= 60 else "[color=yellow]⚠ Low FPS[/color]")
	
	# Check memory
	var memory_mb = (Performance.get_monitor(Performance.MEMORY_STATIC) + Performance.get_monitor(Performance.MEMORY_MESSAGE_BUFFER_MAX)) / 1024.0 / 1024.0
	result += "  Memory: %s\n" % ("✓ OK" if memory_mb < 500 else "[color=yellow]⚠ High usage[/color]")
	
	return result

func _cmd_test(args: Array) -> String:
	if args.is_empty():
		return "Usage: test [autoloads|ui|performance|all]"
	
	var test_type = args[0]
	match test_type:
		"autoloads":
			return _test_autoloads()
		"ui":
			return _test_ui()
		"performance":
			return _test_performance()
		"all":
			var result = _test_autoloads() + "\n"
			result += _test_ui() + "\n"
			result += _test_performance()
			return result
		_:
			return "[color=red]Unknown test type: " + test_type + "[/color]"

func _cmd_stress(args: Array) -> String:
	if args.is_empty():
		return "Usage: stress [nodes|memory|rendering]"
	
	var stress_type = args[0]
	match stress_type:
		"nodes":
			return _stress_test_nodes()
		"memory":
			return _stress_test_memory()
		"rendering":
			return _stress_test_rendering()
		_:
			return "[color=red]Unknown stress test: " + stress_type + "[/color]"

func _cmd_profile(args: Array) -> String:
	if has_node("/root/DebugSystem"):
		var debug_system = get_node("/root/DebugSystem")
		if args.is_empty():
			return "Usage: profile [function_name]"
		
		var func_name = args[0]
		debug_system.start_profiling(func_name)
		return "Profiling started for: " + func_name + "\nCall 'profile " + func_name + "' again to see results"
	return "Debug system not available"

# Test implementations
func _test_autoloads() -> String:
	var result = "[color=cyan]Testing Autoloads:[/color]\n"
	var passed = 0
	var total = 0
	
	var autoloads = {
		"UnifiedColorManager": func(): return get_node("/root/UnifiedColorManager").get_current_theme() != null,
		"UIThemeManager": func(): return get_node("/root/UIThemeManager").get_current_theme_mode() != null,
		"CoreSystemManager": func(): return get_node("/root/CoreSystemManager").is_ready,
		"UISystemManager": func(): return get_node("/root/UISystemManager").is_ready
	}
	
	for autoload in autoloads:
		total += 1
		var node = get_node_or_null("/root/" + autoload)
		if node and autoloads[autoload].call():
			result += "  ✓ %s\n" % autoload
			passed += 1
		else:
			result += "  [color=red]✗ %s[/color]\n" % autoload
	
	result += "Passed: %d/%d" % [passed, total]
	return result

func _test_ui() -> String:
	return "[color=cyan]Testing UI:[/color]\n  UI test implementation pending..."

func _test_performance() -> String:
	var result = "[color=cyan]Testing Performance:[/color]\n"
	result += "  FPS: %d %s\n" % [Engine.get_frames_per_second(), "✓" if Engine.get_frames_per_second() >= 60 else "[color=red]✗[/color]"]
	result += "  Frame time: %.2fms %s\n" % [1000.0 / Engine.get_frames_per_second(), "✓" if 1000.0 / Engine.get_frames_per_second() < 16.67 else "[color=red]✗[/color]"]
	return result

func _stress_test_nodes() -> String:
	var start_count = get_tree().get_node_count()
	var test_parent = Node.new()
	test_parent.name = "StressTestNodes"
	get_tree().root.add_child(test_parent)
	
	for i in 1000:
		var node = Node.new()
		node.name = "TestNode%d" % i
		test_parent.add_child(node)
	
	var end_count = get_tree().get_node_count()
	test_parent.queue_free()
	
	return "Node stress test: Created 1000 nodes. Count went from %d to %d" % [start_count, end_count]

func _stress_test_memory() -> String:
	var start_mem = Performance.get_monitor(Performance.MEMORY_MESSAGE_BUFFER_MAX)
	var arrays = []
	
	for i in 100:
		var big_array = []
		big_array.resize(10000)
		arrays.append(big_array)
	
	var end_mem = Performance.get_monitor(Performance.MEMORY_MESSAGE_BUFFER_MAX)
	var diff_mb = (end_mem - start_mem) / 1024.0 / 1024.0
	
	return "Memory stress test: Allocated %.2f MB" % diff_mb

func _stress_test_rendering() -> String:
	return "Rendering stress test: Implementation pending..."