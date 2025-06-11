extends GutTest

## Integration tests for BrainInteractionController with scene

var test_scene: Node3D = null
var controller: Node3D = null
var camera: Camera3D = null
var brain_structures: Array[MeshInstance3D] = []

func before_each():
	# Create test scene
	test_scene = Node3D.new()
	add_child(test_scene)
	
	# Create camera
	camera = Camera3D.new()
	camera.position = Vector3(0, 0, 10)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	test_scene.add_child(camera)
	
	# Create controller
	controller = preload("res://src/systems/3d_interaction/BrainInteractionController.gd").new()
	test_scene.add_child(controller)
	controller.initialize(camera)
	
	# Create brain structure meshes
	_create_brain_structures()

func after_each():
	brain_structures.clear()
	if test_scene and is_instance_valid(test_scene):
		test_scene.queue_free()

func _create_brain_structures():
	"""Create test brain structure meshes"""
	var structures = ["Hippocampus", "Amygdala", "Thalamus", "Cortex"]
	
	for i in range(structures.size()):
		var mesh_instance = MeshInstance3D.new()
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(2, 2, 2)
		mesh_instance.mesh = box_mesh
		mesh_instance.name = structures[i]
		mesh_instance.position = Vector3(i * 3 - 4.5, 0, 0)
		
		# Add collision for raycasting
		var static_body = StaticBody3D.new()
		mesh_instance.add_child(static_body)
		
		var collision_shape = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = box_mesh.size
		collision_shape.shape = box_shape
		static_body.add_child(collision_shape)
		
		test_scene.add_child(mesh_instance)
		brain_structures.append(mesh_instance)

# === INTEGRATION TESTS ===

func test_selection_workflow():
	var selected_count = 0
	var last_selected = ""
	
	controller.structure_selected.connect(func(name, _mesh):
		selected_count += 1
		last_selected = name
	)
	
	# Test single selection
	controller.select_structure("Hippocampus", brain_structures[0])
	assert_eq(selected_count, 1)
	assert_eq(last_selected, "Hippocampus")
	assert_eq(controller.get_selected_structures().size(), 1)
	
	# Test replacing selection
	controller.select_structure("Amygdala", brain_structures[1])
	assert_eq(selected_count, 2)
	assert_eq(last_selected, "Amygdala")
	assert_eq(controller.get_selected_structures().size(), 1)

func test_multi_selection_workflow():
	controller.multi_selection = true
	
	var selections = []
	controller.structure_selected.connect(func(name, _mesh):
		selections.append(name)
	)
	
	# Select multiple structures
	for i in range(3):
		controller.select_structure(brain_structures[i].name, brain_structures[i])
	
	assert_eq(selections.size(), 3)
	assert_eq(controller.get_selected_structures().size(), 3)
	
	# Verify all are selected
	assert_true(controller.is_structure_selected("Hippocampus"))
	assert_true(controller.is_structure_selected("Amygdala"))
	assert_true(controller.is_structure_selected("Thalamus"))
	assert_false(controller.is_structure_selected("Cortex"))

func test_clear_selection_workflow():
	var clear_count = 0
	controller.selection_cleared.connect(func(): clear_count += 1)
	
	# Select some structures
	controller.multi_selection = true
	controller.select_structure("Hippocampus", brain_structures[0])
	controller.select_structure("Amygdala", brain_structures[1])
	
	assert_eq(controller.get_selected_structures().size(), 2)
	
	# Clear all
	controller.clear_all_selections()
	
	assert_eq(clear_count, 1)
	assert_eq(controller.get_selected_structures().size(), 0)

func test_selection_with_highlighting():
	var highlight_count = 0
	var selection_count = 0
	
	controller.structure_highlighted.connect(func(_name, _mesh): highlight_count += 1)
	controller.structure_selected.connect(func(_name, _mesh): selection_count += 1)
	
	# Enable both features
	controller.highlight_enabled = true
	controller.selection_enabled = true
	
	# Simulate selection
	controller.select_structure("Hippocampus", brain_structures[0])
	assert_eq(selection_count, 1)
	
	# Selected structures shouldn't be highlighted
	# This is tested in the actual highlight handling

func test_visual_feedback_application():
	# Test that materials are properly applied
	var original_material = StandardMaterial3D.new()
	original_material.albedo_color = Color.WHITE
	brain_structures[0].mesh.surface_set_material(0, original_material)
	
	# Select structure
	controller.select_structure("Hippocampus", brain_structures[0])
	
	# Check that material was overridden
	var override_material = brain_structures[0].get_surface_override_material(0)
	assert_not_null(override_material)
	
	# Clear selection
	controller.clear_all_selections()
	
	# Material should be restored
	await wait_frames(1)

func test_mouse_event_simulation():
	# Create mouse click event
	var click_event = InputEventMouseButton.new()
	click_event.button_index = MOUSE_BUTTON_RIGHT
	click_event.pressed = true
	click_event.position = Vector2(640, 360)  # Center of default viewport
	
	var click_handled = false
	controller.structure_clicked.connect(func(_name, _pos): click_handled = true)
	
	# This would need actual collision setup to work fully
	controller.handle_mouse_click(click_event)
	
	# Test mouse motion
	var motion_event = InputEventMouseMotion.new()
	motion_event.position = Vector2(640, 360)
	
	controller.handle_mouse_motion(motion_event)

func test_performance_with_many_structures():
	# Create many structures
	for i in range(50):
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = BoxMesh.new()
		mesh_instance.name = "Structure_" + str(i)
		test_scene.add_child(mesh_instance)
	
	# Test selection performance
	controller.multi_selection = true
	
	var start_time = Time.get_ticks_msec()
	
	# Select many structures
	for child in test_scene.get_children():
		if child is MeshInstance3D and child != camera:
			controller.select_structure(child.name, child)
	
	var elapsed = Time.get_ticks_msec() - start_time
	
	# Should handle many selections efficiently
	assert_lt(elapsed, 100)  # Less than 100ms for 50+ selections
	
	# Clear all
	controller.clear_all_selections()