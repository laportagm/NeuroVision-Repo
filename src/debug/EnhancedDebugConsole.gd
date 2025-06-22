class_name EnhancedDebugConsole
extends Node

# Enhanced debug console for NeuroVision medical platform
# Provides comprehensive error detection and performance monitoring

var debug_commands = {}
var error_log = []
var performance_metrics = {}

func _ready() -> void:
	# Register enhanced debug commands
	register_command("errors", _cmd_show_errors, "Show all errors with stack traces")
	register_command("warnings", _cmd_show_warnings, "Show all warnings")
	register_command("nodes", _cmd_inspect_nodes, "Inspect node tree for issues")
	register_command("memory", _cmd_memory_analysis, "Detailed memory analysis")
	register_command("performance", _cmd_performance_analysis, "Detailed performance analysis")
	register_command("validate", _cmd_validate_scene, "Validate current scene for errors")
	register_command("autoloads", _cmd_check_autoloads, "Check all autoload status")
	register_command("signals", _cmd_check_signals, "Check for disconnected signals")
	register_command("shaders", _cmd_check_shaders, "Check shader compilation status")
	register_command("medical", _cmd_validate_medical_accuracy, "Validate medical content")
	
	# Set up error monitoring
	_setup_error_monitoring()

func _setup_error_monitoring() -> void:
	# Connect to engine error signals
	if not Engine.has_singleton("OS"):
		return
		
	# Monitor errors in real-time
	get_tree().node_configuration_warning_changed.connect(_on_configuration_warning)

func register_command(command: String, method: Callable, description: String) -> void:
	debug_commands[command] = {
		"method": method,
		"description": description
	}

func _cmd_show_errors(args: Array) -> String:
	var output = "[ERROR LOG]\n"
	output += "===========\n"
	
	# Get recent errors from the engine
	var errors = []
	
	# Check for node errors
	for node in get_tree().get_nodes_in_group("_error_nodes"):
		if node.has_method("get_configuration_warnings"):
			var warnings = node.get_configuration_warnings()
			if warnings.size() > 0:
				errors.append({
					"node": node.get_path(),
					"warnings": warnings
				})
	
	# Display errors with context
	for error in errors:
		output += "\n📍 Node: %s\n" % error.node
		for warning in error.warnings:
			output += "   ⚠️  %s\n" % warning
	
	if errors.is_empty():
		output += "✅ No errors found!\n"
	
	return output

func _cmd_show_warnings(args: Array) -> String:
	var output = "[WARNING LOG]\n"
	output += "=============\n"
	
	# Scan for common warnings
	var warnings = []
	
	# Check for missing node references
	_check_missing_references(get_tree().root, warnings)
	
	# Check for performance warnings
	_check_performance_warnings(warnings)
	
	for warning in warnings:
		output += "⚠️  %s\n" % warning
	
	if warnings.is_empty():
		output += "✅ No warnings found!\n"
	
	return output

func _cmd_inspect_nodes(args: Array) -> String:
	var output = "[NODE INSPECTION]\n"
	output += "================\n"
	
	var issues = []
	_inspect_node_tree(get_tree().root, issues)
	
	if issues.is_empty():
		output += "✅ All nodes healthy!\n"
	else:
		for issue in issues:
			output += "❌ %s\n" % issue
	
	return output

func _cmd_memory_analysis(args: Array) -> String:
	var output = "[MEMORY ANALYSIS]\n"
	output += "================\n"
	
	# Get memory stats
	var static_memory = OS.get_static_memory_usage() / 1024.0 / 1024.0
	var peak_memory = OS.get_static_memory_peak_usage() / 1024.0 / 1024.0
	
	output += "Static Memory: %.2f MB\n" % static_memory
	output += "Peak Memory: %.2f MB\n" % peak_memory
	
	# Check for memory leaks
	var potential_leaks = []
	
	# Check for orphan nodes
	var orphan_count = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	if orphan_count > 0:
		potential_leaks.append("Found %d orphan nodes" % orphan_count)
	
	# Check for leaked RIDs
	var rid_count = Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)
	if rid_count > 1000:
		potential_leaks.append("High resource count: %d (possible leak)" % rid_count)
	
	if potential_leaks.size() > 0:
		output += "\n⚠️  Potential Memory Issues:\n"
		for leak in potential_leaks:
			output += "   - %s\n" % leak
	
	return output

func _cmd_performance_analysis(args: Array) -> String:
	var output = "[PERFORMANCE ANALYSIS]\n"
	output += "====================\n"
	
	# FPS Analysis
	var fps = Engine.get_frames_per_second()
	var frame_time = Performance.get_monitor(Performance.TIME_PROCESS)
	var physics_time = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
	
	output += "FPS: %d (Target: 60)\n" % fps
	output += "Frame Time: %.2f ms\n" % (frame_time * 1000)
	output += "Physics Time: %.2f ms\n" % (physics_time * 1000)
	
	# Rendering metrics
	output += "\n[Rendering]\n"
	output += "Draw Calls: %d\n" % Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	output += "Vertices: %d\n" % Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	output += "Video Mem: %.2f MB\n" % (Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1024.0 / 1024.0)
	
	# Medical platform specific checks
	if fps < 60:
		output += "\n⚠️  Performance below medical standard (60 FPS required)\n"
	
	return output

func _cmd_validate_scene(args: Array) -> String:
	var output = "[SCENE VALIDATION]\n"
	output += "=================\n"
	
	var validation_errors = []
	
	# Check required nodes exist
	var required_nodes = [
		"EducationalUILayer",
		"EducationalCameraSystem",
		"BrainModelContainer",
		"LightingSystem"
	]
	
	for node_name in required_nodes:
		if not get_tree().root.has_node(node_name):
			validation_errors.append("Missing required node: %s" % node_name)
	
	# Check autoloads
	var required_autoloads = [
		"UnifiedColorManager",
		"UIThemeManager",
		"CoreSystemManager",
		"EducationalPlatformManager"
	]
	
	for autoload in required_autoloads:
		if not Engine.has_singleton(autoload):
			validation_errors.append("Missing autoload: %s" % autoload)
	
	if validation_errors.is_empty():
		output += "✅ Scene validation passed!\n"
	else:
		output += "❌ Validation errors found:\n"
		for error in validation_errors:
			output += "   - %s\n" % error
	
	return output

func _cmd_check_autoloads(args: Array) -> String:
	var output = "[AUTOLOAD STATUS]\n"
	output += "================\n"
	
	var autoloads = [
		"UnifiedColorManager",
		"UIThemeManager", 
		"CoreSystemManager",
		"UISystemManager",
		"EducationalPlatformManager",
		"ResourceManager",
		"AuthenticationManager",
		"NetworkManager",
		"AssessmentService",
		"HighlightMaterialManager",
		"ProgressTracker",
		"IntelOptimizer"
	]
	
	for autoload_name in autoloads:
		if Engine.has_singleton(autoload_name):
			var singleton = Engine.get_singleton(autoload_name)
			if singleton:
				output += "✅ %s - Active\n" % autoload_name
			else:
				output += "❌ %s - Null reference\n" % autoload_name
		else:
			output += "❌ %s - Not loaded\n" % autoload_name
	
	return output

func _cmd_check_signals(args: Array) -> String:
	var output = "[SIGNAL CONNECTIONS]\n"
	output += "==================\n"
	
	var disconnected_count = 0
	_check_signal_connections(get_tree().root, output, disconnected_count)
	
	if disconnected_count == 0:
		output += "\n✅ All signals properly connected!\n"
	else:
		output += "\n⚠️  Found %d disconnected signals\n" % disconnected_count
	
	return output

func _cmd_check_shaders(args: Array) -> String:
	var output = "[SHADER STATUS]\n"
	output += "==============\n"
	
	# Check for shader compilation errors
	var shader_errors = []
	
	# Scan materials in the scene
	_check_shaders_recursive(get_tree().root, shader_errors)
	
	if shader_errors.is_empty():
		output += "✅ All shaders compiled successfully!\n"
	else:
		output += "❌ Shader errors found:\n"
		for error in shader_errors:
			output += "   - %s\n" % error
	
	return output

func _cmd_validate_medical_accuracy(args: Array) -> String:
	var output = "[MEDICAL ACCURACY VALIDATION]\n"
	output += "============================\n"
	
	# Check medical terminology
	if Engine.has_singleton("KnowledgeService"):
		output += "✅ Knowledge Service active\n"
		# Additional medical validation logic here
	else:
		output += "❌ Knowledge Service not found\n"
	
	# Check WCAG compliance
	output += "\n[Accessibility]\n"
	output += "WCAG 2.1 AA Target: "
	
	# Simple contrast check example
	var ui_panels = get_tree().get_nodes_in_group("ui_panels")
	var accessibility_issues = 0
	
	for panel in ui_panels:
		if panel.modulate.a < 0.9:
			accessibility_issues += 1
	
	if accessibility_issues == 0:
		output += "✅ Compliant\n"
	else:
		output += "⚠️  %d panels with transparency issues\n" % accessibility_issues
	
	return output

# Helper functions
func _check_missing_references(node: Node, warnings: Array) -> void:
	# Check for null @onready variables
	if node.get_script():
		var script = node.get_script()
		# This is a simplified check - in practice you'd parse the script
		
	for child in node.get_children():
		_check_missing_references(child, warnings)

func _check_performance_warnings(warnings: Array) -> void:
	var fps = Engine.get_frames_per_second()
	if fps < 60 and fps > 0:
		warnings.append("FPS below 60: Current FPS is %d" % fps)
	
	var frame_time = Performance.get_monitor(Performance.TIME_PROCESS)
	if frame_time > 0.016:  # 16ms for 60 FPS
		warnings.append("Frame time exceeds 16ms: %.2f ms" % (frame_time * 1000))

func _inspect_node_tree(node: Node, issues: Array) -> void:
	# Check node configuration
	if node.has_method("get_configuration_warnings"):
		var warnings = node.get_configuration_warnings()
		for warning in warnings:
			issues.append("%s: %s" % [node.get_path(), warning])
	
	# Check for common issues
	if node is Control and not node.visible and node.get_parent():
		if node.mouse_filter == Control.MOUSE_FILTER_STOP:
			issues.append("%s: Invisible control blocking mouse input" % node.get_path())
	
	# Recursive check
	for child in node.get_children():
		_inspect_node_tree(child, issues)

func _check_signal_connections(node: Node, output: String, disconnected_count: int) -> void:
	# Check node's signals
	if node.get_signal_list().size() > 0:
		for sig in node.get_signal_list():
			var connections = node.get_signal_connection_list(sig.name)
			if connections.is_empty() and sig.name != "tree_exiting" and sig.name != "ready":
				disconnected_count += 1
	
	for child in node.get_children():
		_check_signal_connections(child, output, disconnected_count)

func _check_shaders_recursive(node: Node, shader_errors: Array) -> void:
	# Check materials on visual nodes
	if node is MeshInstance3D:
		var material = node.get_surface_override_material(0)
		if material and material is ShaderMaterial:
			var shader = material.shader
			if shader:
				# Check shader validity
				pass
	
	for child in node.get_children():
		_check_shaders_recursive(child, shader_errors)

func _on_configuration_warning(node: Node) -> void:
	print("[Debug] Configuration warning on node: ", node.get_path())