## Test Enhanced Exploration Scene
## This script runs the scene and reports on its functionality

extends SceneTree

func _init() -> void:
	print("\n=== TESTING ENHANCED EXPLORATION SCENE ===")
	
	# Load and instantiate the scene
	var scene = load("res://scenes/3d/EnhancedExplorationScene.tscn")
	if not scene:
		push_error("Failed to load scene!")
		quit(1)
		return
	
	var instance = scene.instantiate()
	if not instance:
		push_error("Failed to instantiate scene!")
		quit(1)
		return
	
	# Add to tree
	root.add_child(instance)
	
	# Wait a frame for scene to initialize
	await process_frame
	
	# Run diagnostics
	print("\n[Scene Structure]")
	_check_node_structure(instance)
	
	print("\n[Lighting Status]")
	_check_lighting(instance)
	
	print("\n[UI Components]")
	_check_ui_components(instance)
	
	print("\n[Systems Status]")
	_check_systems(instance)
	
	print("\n[Performance]")
	_check_performance()
	
	# Let it run for a moment
	await create_timer(2.0).timeout
	
	print("\n✅ Scene test complete!")
	quit(0)

func _check_node_structure(root: Node) -> void:
	# Check critical nodes exist
	var critical_nodes = [
		"EnvironmentSystem/MedicalLightingSystem/KeyLight",
		"EnvironmentSystem/MedicalLightingSystem/RimLight",
		"AnatomicalModelContainer/BrainModelHolder/BrainModelLoader",
		"EducationalSystemsContainer/BrainInteractionSystem/InteractionController",
		"EducationalSystemsContainer/AccessibilityManager",
		"EducationalAudioSystem"
	]
	
	for node_path in critical_nodes:
		var node = root.find_child(node_path.get_file(), true, false)
		if node:
			print("  ✓ " + node_path + " exists")
		else:
			print("  ✗ " + node_path + " MISSING")

func _check_lighting(root: Node) -> void:
	var key_light = root.find_child("KeyLight", true, false) as DirectionalLight3D
	if key_light:
		print("  KeyLight: visible=%s, energy=%.1f" % [key_light.visible, key_light.light_energy])
	
	var rim_light = root.find_child("RimLight", true, false) as DirectionalLight3D
	if rim_light:
		print("  RimLight: visible=%s, energy=%.1f" % [rim_light.visible, rim_light.light_energy])
	
	var fill_light = root.find_child("FillLight", true, false) as DirectionalLight3D
	if fill_light:
		print("  FillLight: visible=%s, energy=%.1f" % [fill_light.visible, fill_light.light_energy])

func _check_ui_components(root: Node) -> void:
	var components = {
		"EducationalTopBar": "Top navigation",
		"AnatomicalStructurePanel": "Structure list",
		"EducationalStatusBar": "Status bar",
		"AnatomicalInfoPanel": "Info panel",
		"PerformanceMonitoringPanel": "Performance panel"
	}
	
	for comp_name in components:
		var comp = root.find_child(comp_name, true, false)
		if comp:
			var visibility = "visible" if comp.visible else "hidden"
			print("  ✓ %s (%s) - %s" % [comp_name, components[comp_name], visibility])
		else:
			print("  ✗ %s MISSING" % comp_name)

func _check_systems(root: Node) -> void:
	# Check if InteractionController has script
	var controller = root.find_child("InteractionController", true, false)
	if controller:
		if controller.get_script():
			print("  ✓ InteractionController has script attached")
		else:
			print("  ✗ InteractionController missing script")
	
	# Check rendering system
	var render_sys = root.find_child("MedicalRenderingSystem", true, false)
	if render_sys and render_sys.get_script():
		print("  ✓ MedicalRenderingSystem configured")

func _check_performance() -> void:
	print("  FPS: %d" % Engine.get_frames_per_second())
	print("  Memory: %.1f MB" % (OS.get_static_memory_usage() / 1048576.0))
	print("  Draw calls: %d" % RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME))
	
	# Check if environment is optimized
	var viewport = root.get_viewport()
	if viewport:
		var env = viewport.get_camera_3d()
		if env:
			print("  Camera FOV: %.1f" % env.fov if env else "N/A")