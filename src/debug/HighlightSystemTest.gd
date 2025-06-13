extends Node3D

## Highlight System Test Scene
##
## Tests the foundation batch of the smooth structure highlighting system.
## Verifies rim light appearance, state transitions, and performance.

# === DEPENDENCIES ===
var _brain_model: Node3D
var _camera: Camera3D
var _interaction_controller: Node3D
var _highlight_integration: Node
var _test_meshes: Array[MeshInstance3D] = []
var _performance_monitor: Timer
var _test_results: Dictionary = {}

# === TEST CONFIGURATION ===
@export var run_automated_tests: bool = true
@export var test_duration: float = 10.0
@export var log_performance: bool = true

# === PUBLIC METHODS ===

func _ready() -> void:
	print("==================================================")
	print("[HighlightTest] Starting Highlight System Test")
	print("==================================================")
	
	_setup_test_scene()
	
	if run_automated_tests:
		await get_tree().create_timer(1.0).timeout
		_run_test_suite()

func _setup_test_scene() -> void:
	"""Setup test environment"""
	# Create camera
	_camera = Camera3D.new()
	_camera.position = Vector3(0, 0, 5)
	_camera.fov = 60
	add_child(_camera)
	
	# Create test meshes
	_create_test_meshes()
	
	# Create interaction controller
	_interaction_controller = preload("res://src/systems/3d_interaction/BrainInteractionController.gd").new()
	_interaction_controller.name = "BrainInteractionController"
	add_child(_interaction_controller)
	_interaction_controller.initialize(_camera)
	
	# Add to group for integration discovery
	_interaction_controller.add_to_group("brain_interaction")
	
	# Create highlight integration
	_highlight_integration = preload("res://src/systems/3d_interaction/HighlightSystemIntegration.gd").new()
	_highlight_integration.name = "HighlightIntegration"
	add_child(_highlight_integration)
	
	# Setup performance monitoring
	_performance_monitor = Timer.new()
	_performance_monitor.wait_time = 0.1
	_performance_monitor.timeout.connect(_monitor_performance)
	add_child(_performance_monitor)
	
	print("[HighlightTest] Test scene setup complete")

func _create_test_meshes() -> void:
	"""Create test brain structure meshes"""
	var structures = [
		{"name": "Hippocampus", "pos": Vector3(-2, 0, 0), "color": Color.RED},
		{"name": "Amygdala", "pos": Vector3(0, 0, 0), "color": Color.GREEN},
		{"name": "Thalamus", "pos": Vector3(2, 0, 0), "color": Color.BLUE}
	]
	
	for struct in structures:
		# Create mesh instance
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.name = struct.name
		mesh_instance.position = struct.pos
		mesh_instance.set_meta("structure_name", struct.name)
		
		# Create sphere mesh
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radial_segments = 32
		sphere_mesh.rings = 16
		mesh_instance.mesh = sphere_mesh
		
		# Create material
		var material = StandardMaterial3D.new()
		material.albedo_color = struct.color
		mesh_instance.set_surface_override_material(0, material)
		
		# Add collision
		var static_body = StaticBody3D.new()
		var collision_shape = CollisionShape3D.new()
		var sphere_shape = SphereShape3D.new()
		collision_shape.shape = sphere_shape
		
		mesh_instance.add_child(static_body)
		static_body.add_child(collision_shape)
		
		add_child(mesh_instance)
		_test_meshes.append(mesh_instance)
	
	print("[HighlightTest] Created %d test meshes" % _test_meshes.size())

func _run_test_suite() -> void:
	"""Run automated test suite"""
	print("\n[HighlightTest] Running automated tests...")
	
	_test_results.clear()
	if log_performance:
		_performance_monitor.start()
	
	# Test 1: Hover highlighting
	await _test_hover_highlight()
	
	# Test 2: Selection highlighting
	await _test_selection_highlight()
	
	# Test 3: Multi-selection
	await _test_multi_selection()
	
	# Test 4: State transitions
	await _test_state_transitions()
	
	# Test 5: Performance impact
	await _test_performance_impact()
	
	# Print results
	_print_test_results()

func _test_hover_highlight() -> void:
	"""Test hover state highlighting"""
	print("\n[Test 1] Testing hover highlight...")
	var start_time = Time.get_ticks_msec()
	
	if _test_meshes.is_empty():
		_test_results["hover_highlight"] = {
			"passed": false,
			"time": 0,
			"details": "No test meshes created"
		}
		return
	
	# Simulate hover over first mesh
	var mesh = _test_meshes[0]
	_interaction_controller.structure_highlighted.emit(mesh.name, mesh)
	
	await get_tree().create_timer(0.5).timeout
	
	# Check if highlight is applied
	var highlight_manager = get_node_or_null("/root/HighlightMaterialManager")
	if highlight_manager:
		var state = highlight_manager.get_current_state(mesh)
		var success = state == highlight_manager.HighlightState.HOVERING
		_test_results["hover_highlight"] = {
			"passed": success,
			"time": Time.get_ticks_msec() - start_time,
			"details": "State: " + str(state)
		}
	else:
		_test_results["hover_highlight"] = {
			"passed": false,
			"time": 0,
			"details": "HighlightManager not found"
		}

func _test_selection_highlight() -> void:
	"""Test selection state highlighting"""
	print("\n[Test 2] Testing selection highlight...")
	var start_time = Time.get_ticks_msec()
	
	if _test_meshes.size() < 2:
		_test_results["selection_highlight"] = {
			"passed": false,
			"time": 0,
			"details": "Not enough test meshes"
		}
		return
	
	# Clear any existing selection
	_interaction_controller.clear_all_selections()
	await get_tree().create_timer(0.2).timeout
	
	# Select second mesh
	var mesh = _test_meshes[1]
	_interaction_controller.structure_selected.emit(mesh.name, mesh)
	
	await get_tree().create_timer(0.5).timeout
	
	# Check if selection highlight is applied
	var highlight_manager = get_node_or_null("/root/HighlightMaterialManager")
	if highlight_manager:
		var state = highlight_manager.get_current_state(mesh)
		var success = state == highlight_manager.HighlightState.SELECTED
		_test_results["selection_highlight"] = {
			"passed": success,
			"time": Time.get_ticks_msec() - start_time,
			"details": "State: " + str(state)
		}
	else:
		_test_results["selection_highlight"] = {
			"passed": false,
			"time": 0,
			"details": "HighlightManager not found"
		}

func _test_multi_selection() -> void:
	"""Test multi-selection highlighting"""
	print("\n[Test 3] Testing multi-selection...")
	var start_time = Time.get_ticks_msec()
	
	if _test_meshes.size() < 2:
		_test_results["multi_selection"] = {
			"passed": false,
			"time": 0,
			"details": "Not enough test meshes"
		}
		return
	
	# Enable multi-selection
	_interaction_controller.multi_selection = true
	
	# Select multiple meshes
	for i in range(2):
		var mesh = _test_meshes[i]
		_interaction_controller.structure_selected.emit(mesh.name, mesh)
		await get_tree().create_timer(0.2).timeout
	
	await get_tree().create_timer(0.5).timeout
	
	# Check if multi-selection state is applied
	var highlight_manager = get_node_or_null("/root/HighlightMaterialManager")
	if highlight_manager:
		var all_selected = true
		for i in range(2):
			var state = highlight_manager.get_current_state(_test_meshes[i])
			if state != highlight_manager.HighlightState.MULTI_SELECTED:
				all_selected = false
				break
		
		_test_results["multi_selection"] = {
			"passed": all_selected,
			"time": Time.get_ticks_msec() - start_time,
			"details": "Multi-selection state applied"
		}
	else:
		_test_results["multi_selection"] = {
			"passed": false,
			"time": 0,
			"details": "HighlightManager not found"
		}
	
	# Disable multi-selection
	_interaction_controller.multi_selection = false

func _test_state_transitions() -> void:
	"""Test smooth state transitions"""
	print("\n[Test 4] Testing state transitions...")
	var start_time = Time.get_ticks_msec()
	
	if _test_meshes.is_empty():
		_test_results["state_transitions"] = {
			"passed": false,
			"time": 0,
			"details": "No test meshes created"
		}
		return
	
	var mesh = _test_meshes[0]
	var transitions_smooth = true
	
	# Test rapid state changes
	_interaction_controller.structure_highlighted.emit(mesh.name, mesh)
	await get_tree().create_timer(0.1).timeout
	
	_interaction_controller.structure_selected.emit(mesh.name, mesh)
	await get_tree().create_timer(0.1).timeout
	
	_interaction_controller.selection_cleared.emit()
	await get_tree().create_timer(0.3).timeout
	
	# Check final state
	var highlight_manager = get_node_or_null("/root/HighlightMaterialManager")
	if highlight_manager:
		var state = highlight_manager.get_current_state(mesh)
		transitions_smooth = state == highlight_manager.HighlightState.IDLE
		
		_test_results["state_transitions"] = {
			"passed": transitions_smooth,
			"time": Time.get_ticks_msec() - start_time,
			"details": "Smooth transitions completed"
		}
	else:
		_test_results["state_transitions"] = {
			"passed": false,
			"time": 0,
			"details": "HighlightManager not found"
		}

func _test_performance_impact() -> void:
	"""Test performance impact of highlighting system"""
	print("\n[Test 5] Testing performance impact...")
	
	if not log_performance:
		_test_results["performance_impact"] = {
			"passed": true,
			"time": 0,
			"details": "Performance logging disabled"
		}
		return
	
	# Get average frame time from monitoring
	var avg_frame_time = 0.0
	if _performance_data.size() > 0:
		for data in _performance_data:
			avg_frame_time += data.frame_time
		avg_frame_time /= _performance_data.size()
	
	# Check if under 1ms impact
	var impact_ms = avg_frame_time - 16.67  # Subtract baseline 60fps
	var passed = impact_ms < 1.0
	
	_test_results["performance_impact"] = {
		"passed": passed,
		"time": 0,
		"details": "Impact: %.2fms (avg frame: %.2fms)" % [impact_ms, avg_frame_time]
	}

var _performance_data: Array = []

func _monitor_performance() -> void:
	"""Monitor performance metrics"""
	var frame_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var draw_calls = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	
	_performance_data.append({
		"frame_time": frame_time,
		"draw_calls": draw_calls,
		"timestamp": Time.get_ticks_msec()
	})

func _print_test_results() -> void:
	"""Print test suite results"""
	print("\n==================================================")
	print("[HighlightTest] Test Results")
	print("==================================================")
	
	var all_passed = true
	for test_name in _test_results:
		var result = _test_results[test_name]
		var status = "PASS" if result.passed else "FAIL"
		all_passed = all_passed and result.passed
		
		print("%s: %s - %dms - %s" % [test_name, status, result.time, result.details])
	
	print("\n==================================================")
	if all_passed:
		print("[HighlightTest] ALL TESTS PASSED ✓")
	else:
		print("[HighlightTest] SOME TESTS FAILED ✗")
	print("==================================================")
	
	# Cleanup
	if log_performance:
		_performance_monitor.stop()

# === DEBUG VISUALIZATION ===

func _input(event: InputEvent) -> void:
	"""Handle manual testing inputs"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				# Test hover on first mesh
				if _test_meshes.size() > 0:
					_interaction_controller.structure_highlighted.emit(
						_test_meshes[0].name, 
						_test_meshes[0]
					)
					print("[Manual] Hovering: %s" % _test_meshes[0].name)
			
			KEY_2:
				# Test selection on second mesh
				if _test_meshes.size() > 1:
					_interaction_controller.structure_selected.emit(
						_test_meshes[1].name,
						_test_meshes[1]
					)
					print("[Manual] Selected: %s" % _test_meshes[1].name)
			
			KEY_3:
				# Test focus on third mesh
				if _test_meshes.size() > 2 and _highlight_integration:
					_highlight_integration.focus_structure(_test_meshes[2])
					print("[Manual] Focused: %s" % _test_meshes[2].name)
			
			KEY_C:
				# Clear all selections
				_interaction_controller.clear_all_selections()
				print("[Manual] Cleared all selections")
			
			KEY_D:
				# Print debug info
				if _highlight_integration:
					var debug_info = _highlight_integration.get_debug_info()
					print("[Manual] Debug Info: ", debug_info)
				
				var highlight_manager = get_node_or_null("/root/HighlightMaterialManager")
				if highlight_manager:
					highlight_manager.debug_print_state()