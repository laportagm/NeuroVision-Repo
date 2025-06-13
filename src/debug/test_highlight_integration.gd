extends Node3D

## Test highlight system with actual brain models
##
## This script tests the highlight system integration with the real
## BrainInteractionController and brain models.

signal test_complete

var _model_loader: Node
var _interaction_controller: Node
var _highlight_integration: Node
var _camera: Camera3D
var _brain_model: Node3D

func _ready() -> void:
	print("==================================================")
	print("[IntegrationTest] Testing with Brain Models")
	print("==================================================")
	
	# Setup camera
	_camera = Camera3D.new()
	_camera.position = Vector3(0, 0, 300)
	_camera.fov = 45
	add_child(_camera)
	
	# Add lighting
	var light = DirectionalLight3D.new()
	light.rotation = Vector3(-PI/4, -PI/4, 0)
	add_child(light)
	
	# Load model loader
	_model_loader = preload("res://src/systems/3d_interaction/ModelLoader.gd").new()
	add_child(_model_loader)
	
	# Create interaction controller
	_interaction_controller = preload("res://src/systems/3d_interaction/BrainInteractionController.gd").new()
	_interaction_controller.add_to_group("brain_interaction")
	add_child(_interaction_controller)
	_interaction_controller.initialize(_camera)
	
	# Create highlight integration
	_highlight_integration = preload("res://src/systems/3d_interaction/HighlightSystemIntegration.gd").new()
	add_child(_highlight_integration)
	
	# Load brain model
	await get_tree().process_frame
	_load_brain_model()

func _load_brain_model() -> void:
	print("\n[IntegrationTest] Loading brain model...")
	
	# Try to load Internal Structures model
	var model_data = _model_loader.load_model("Internal_Structures", 1)  # MEDIUM LOD
	if model_data.mesh_instance:
		_brain_model = model_data.mesh_instance
		add_child(_brain_model)
		print("  ✓ Brain model loaded: %s" % _brain_model.name)
		
		# Position model
		_brain_model.position = Vector3.ZERO
		
		# Setup collisions for interaction
		_setup_model_collisions(_brain_model)
		
		# Wait for integration to connect
		await get_tree().create_timer(1.0).timeout
		
		# Run tests
		_run_integration_tests()
	else:
		print("  ✗ Failed to load brain model")
		print("  Error: %s" % model_data.error)

func _setup_model_collisions(model: Node3D) -> void:
	"""Add collision shapes to model children for interaction"""
	print("\n[IntegrationTest] Setting up collisions...")
	var setup_count = 0
	
	for child in model.get_children():
		if child is MeshInstance3D:
			# Check if already has collision
			var has_collision = false
			for subchild in child.get_children():
				if subchild is StaticBody3D:
					has_collision = true
					break
			
			if not has_collision and child.mesh:
				# Create collision
				var static_body = StaticBody3D.new()
				var collision_shape = CollisionShape3D.new()
				
				# Create trimesh collision from mesh
				var shape = child.mesh.create_trimesh_shape()
				collision_shape.shape = shape
				
				child.add_child(static_body)
				static_body.add_child(collision_shape)
				
				# Add metadata for selection
				child.set_meta("structure_name", child.name)
				child.set_meta("brain_structure", true)
				
				setup_count += 1
	
	print("  ✓ Set up collisions for %d structures" % setup_count)

func _run_integration_tests() -> void:
	"""Run integration tests with actual brain structures"""
	print("\n[IntegrationTest] Running integration tests...")
	
	# Find a test structure
	var test_mesh: MeshInstance3D = null
	for child in _brain_model.get_children():
		if child is MeshInstance3D:
			test_mesh = child
			break
	
	if not test_mesh:
		print("  ✗ No mesh instances found in brain model")
		return
	
	print("  Testing with structure: %s" % test_mesh.name)
	
	# Test 1: Hover
	print("\n  [Test 1] Hover highlight...")
	_interaction_controller.structure_highlighted.emit(test_mesh.name, test_mesh)
	await get_tree().create_timer(1.0).timeout
	
	var highlight_manager = get_node("/root/HighlightMaterialManager")
	var state = highlight_manager.get_current_state(test_mesh)
	if state == highlight_manager.HighlightState.HOVERING:
		print("    ✓ Hover state applied")
	else:
		print("    ✗ Hover state not applied (state: %d)" % state)
	
	# Test 2: Selection
	print("\n  [Test 2] Selection highlight...")
	_interaction_controller.structure_selected.emit(test_mesh.name, test_mesh)
	await get_tree().create_timer(1.0).timeout
	
	state = highlight_manager.get_current_state(test_mesh)
	if state == highlight_manager.HighlightState.SELECTED:
		print("    ✓ Selection state applied")
	else:
		print("    ✗ Selection state not applied (state: %d)" % state)
	
	# Test 3: Clear selection
	print("\n  [Test 3] Clear selection...")
	_interaction_controller.selection_cleared.emit()
	await get_tree().create_timer(1.0).timeout
	
	state = highlight_manager.get_current_state(test_mesh)
	if state == highlight_manager.HighlightState.IDLE:
		print("    ✓ Selection cleared")
	else:
		print("    ✗ Selection not cleared (state: %d)" % state)
	
	# Test 4: Performance with multiple highlights
	print("\n  [Test 4] Multiple highlights performance...")
	var start_time = Time.get_ticks_msec()
	var highlight_count = 0
	
	for child in _brain_model.get_children():
		if child is MeshInstance3D and highlight_count < 5:
			_interaction_controller.structure_highlighted.emit(child.name, child)
			highlight_count += 1
			await get_tree().process_frame
	
	var elapsed = Time.get_ticks_msec() - start_time
	print("    ✓ Highlighted %d structures in %dms" % [highlight_count, elapsed])
	print("    - Average: %.2fms per structure" % (float(elapsed) / highlight_count))
	
	# Cleanup
	_interaction_controller.selection_cleared.emit()
	
	print("\n==================================================")
	print("[IntegrationTest] Integration Test Complete")
	print("==================================================")
	
	# Get debug info
	var debug_info = _highlight_integration.get_debug_info()
	print("\nDebug Info:")
	for key in debug_info:
		print("  - %s: %s" % [key, debug_info[key]])
	
	highlight_manager.debug_print_state()
	
	test_complete.emit()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				get_tree().quit()
			KEY_R:
				# Reset test
				get_tree().reload_current_scene()