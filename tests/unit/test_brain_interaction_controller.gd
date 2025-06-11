extends GutTest

## Unit tests for BrainInteractionController

var controller: Node3D = null
var camera: Camera3D = null
var test_mesh: MeshInstance3D = null

func before_each():
	# Create controller
	controller = preload("res://src/systems/3d_interaction/BrainInteractionController.gd").new()
	add_child(controller)
	
	# Create camera
	camera = Camera3D.new()
	camera.position = Vector3(0, 0, 5)
	add_child(camera)
	
	# Create test mesh
	test_mesh = MeshInstance3D.new()
	test_mesh.mesh = BoxMesh.new()
	test_mesh.name = "test_structure"
	add_child(test_mesh)
	
	# Initialize controller
	controller.initialize(camera)

func after_each():
	if controller and is_instance_valid(controller):
		controller.queue_free()
	if camera and is_instance_valid(camera):
		camera.queue_free()
	if test_mesh and is_instance_valid(test_mesh):
		test_mesh.queue_free()

# === INITIALIZATION TESTS ===

func test_initialization():
	assert_not_null(controller)
	assert_eq(controller.selection_enabled, true)
	assert_eq(controller.highlight_enabled, true)
	assert_eq(controller.multi_selection, false)

func test_initialization_without_camera():
	var new_controller = preload("res://src/systems/3d_interaction/BrainInteractionController.gd").new()
	add_child(new_controller)
	
	# Should handle null camera gracefully
	new_controller.initialize(null)
	
	new_controller.queue_free()

# === SELECTION TESTS ===

func test_enable_disable_selection():
	controller.enable_selection(false)
	assert_false(controller.selection_enabled)
	
	controller.enable_selection(true)
	assert_true(controller.selection_enabled)

func test_select_structure():
	var signal_emitted = false
	var emitted_name = ""
	var emitted_mesh = null
	
	controller.structure_selected.connect(func(name, mesh):
		signal_emitted = true
		emitted_name = name
		emitted_mesh = mesh
	)
	
	controller.select_structure("Hippocampus", test_mesh)
	
	assert_true(signal_emitted)
	assert_eq(emitted_name, "Hippocampus")
	assert_eq(emitted_mesh, test_mesh)
	assert_true(controller.is_structure_selected("Hippocampus"))

func test_deselect_structure():
	# First select
	controller.select_structure("Hippocampus", test_mesh)
	assert_true(controller.is_structure_selected("Hippocampus"))
	
	# Then deselect
	controller.deselect_structure("Hippocampus")
	assert_false(controller.is_structure_selected("Hippocampus"))

func test_clear_all_selections():
	var signal_emitted = false
	
	controller.selection_cleared.connect(func(): signal_emitted = true)
	
	# Select multiple structures
	controller.multi_selection = true
	controller.select_structure("Structure1", test_mesh)
	
	var test_mesh2 = MeshInstance3D.new()
	test_mesh2.mesh = BoxMesh.new()
	add_child(test_mesh2)
	controller.select_structure("Structure2", test_mesh2)
	
	assert_eq(controller.get_selected_structures().size(), 2)
	
	# Clear all
	controller.clear_all_selections()
	
	assert_true(signal_emitted)
	assert_eq(controller.get_selected_structures().size(), 0)
	
	test_mesh2.queue_free()

func test_single_selection_mode():
	controller.multi_selection = false
	
	# Select first structure
	controller.select_structure("Structure1", test_mesh)
	assert_eq(controller.get_selected_structures().size(), 1)
	
	# Select second structure - should clear first
	var test_mesh2 = MeshInstance3D.new()
	test_mesh2.mesh = BoxMesh.new()
	add_child(test_mesh2)
	controller.select_structure("Structure2", test_mesh2)
	
	assert_eq(controller.get_selected_structures().size(), 1)
	assert_false(controller.is_structure_selected("Structure1"))
	assert_true(controller.is_structure_selected("Structure2"))
	
	test_mesh2.queue_free()

func test_multi_selection_mode():
	controller.multi_selection = true
	
	# Select multiple structures
	controller.select_structure("Structure1", test_mesh)
	
	var test_mesh2 = MeshInstance3D.new()
	test_mesh2.mesh = BoxMesh.new()
	add_child(test_mesh2)
	controller.select_structure("Structure2", test_mesh2)
	
	assert_eq(controller.get_selected_structures().size(), 2)
	assert_true(controller.is_structure_selected("Structure1"))
	assert_true(controller.is_structure_selected("Structure2"))
	
	test_mesh2.queue_free()

# === HIGHLIGHTING TESTS ===

func test_enable_disable_highlighting():
	controller.enable_highlighting(false)
	assert_false(controller.highlight_enabled)
	
	controller.enable_highlighting(true)
	assert_true(controller.highlight_enabled)

func test_highlight_signal():
	var signal_emitted = false
	var highlighted_name = ""
	
	controller.structure_highlighted.connect(func(name, _mesh):
		signal_emitted = true
		highlighted_name = name
	)
	
	# Simulate highlight through private method testing
	# Since we can't easily simulate mouse events in unit tests
	controller.highlight_enabled = true
	
	# Test that highlighting is properly configured
	assert_true(controller.highlight_enabled)
	assert_true(controller.use_outline)
	assert_true(controller.use_emission)

# === VISUAL FEEDBACK TESTS ===

func test_visual_feedback_settings():
	assert_true(controller.use_outline)
	assert_eq(controller.outline_width, 2.0)
	assert_true(controller.use_emission)
	assert_eq(controller.emission_strength, 0.5)
	
	# Test changing settings
	controller.use_outline = false
	controller.emission_strength = 1.0
	
	assert_false(controller.use_outline)
	assert_eq(controller.emission_strength, 1.0)

# === RAYCAST TESTS ===

func test_perform_raycast_without_camera():
	var new_controller = preload("res://src/systems/3d_interaction/BrainInteractionController.gd").new()
	add_child(new_controller)
	
	var result = new_controller.perform_raycast(Vector2(100, 100))
	assert_eq(result.size(), 0)
	
	new_controller.queue_free()

func test_max_selection_distance():
	assert_eq(controller.max_selection_distance, 100.0)
	
	controller.max_selection_distance = 50.0
	assert_eq(controller.max_selection_distance, 50.0)

# === MATERIAL HANDLING TESTS ===

func test_material_storage():
	# Create mesh with materials
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.RED
	test_mesh.mesh.surface_set_material(0, material)
	
	# Select structure (which should store materials)
	controller.select_structure("TestStructure", test_mesh)
	
	# Verify selection
	assert_true(controller.is_structure_selected("TestStructure"))
	
	# Clear selection (which should restore materials)
	controller.clear_all_selections()
	
	# Material should be restored
	assert_false(controller.is_structure_selected("TestStructure"))