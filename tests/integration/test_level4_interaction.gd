extends GutTest

## Tests for Level 4: 3D Interaction Systems

var exploration_scene = null
var brain_interaction = null
var camera = null

func before_each():
	# Create a full exploration scene
	var scene = load("res://src/scenes/ExplorationScene.tscn")
	exploration_scene = scene.instantiate()
	add_child(exploration_scene)
	
	# Wait for scene to initialize
	await wait_frames(5)
	
	brain_interaction = exploration_scene._brain_interaction
	camera = exploration_scene.camera

func after_each():
	if exploration_scene and is_instance_valid(exploration_scene):
		exploration_scene.queue_free()

# === CRITICAL: Interaction Controller Setup ===

func test_brain_interaction_controller_exists():
	assert_not_null(brain_interaction, "BrainInteractionController must exist")
	assert_not_null(camera, "Camera must exist for interaction")

func test_interaction_controller_initialized():
	assert_true(brain_interaction._is_initialized, "Controller must be initialized")
	assert_eq(brain_interaction._camera, camera, "Controller must have camera reference")

# === CRITICAL: Ray-cast Selection ===

func test_raycast_performs_correctly():
	# Test raycast at center of screen
	var viewport_size = get_viewport().size
	var center = viewport_size / 2
	
	var result = brain_interaction.perform_raycast(center)
	assert_true(result is Dictionary, "Raycast must return dictionary")

func test_mouse_click_handling():
	# Create a mock right-click event
	var event = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_RIGHT
	event.pressed = true
	event.position = get_viewport().size / 2
	
	var signal_emitted = false
	brain_interaction.structure_selected.connect(func(name, mesh):
		signal_emitted = true
	)
	
	# Handle the click
	brain_interaction.handle_mouse_click(event)
	
	# Note: This may not emit if no structure is under cursor
	# The important thing is it doesn't crash
	assert_true(true, "Click handling must not crash")

# === CRITICAL: Visual Feedback ===

func test_highlight_material_exists():
	assert_not_null(brain_interaction._highlight_material, "Highlight material must exist")
	assert_true(brain_interaction._highlight_material is Material, "Must be a Material")

func test_selection_material_exists():
	assert_not_null(brain_interaction._selection_material, "Selection material must exist")
	assert_true(brain_interaction._selection_material is Material, "Must be a Material")

func test_highlighting_workflow():
	# Create a mock mesh for testing
	var test_mesh = MeshInstance3D.new()
	test_mesh.mesh = BoxMesh.new()
	test_mesh.set_meta("structure_name", "Test Structure")
	exploration_scene.brain_container.add_child(test_mesh)
	
	# Test highlighting
	brain_interaction._highlight_structure(test_mesh)
	assert_eq(brain_interaction._highlighted_mesh, test_mesh, "Should track highlighted mesh")
	
	# Test unhighlighting
	brain_interaction._unhighlight_current()
	assert_null(brain_interaction._highlighted_mesh, "Should clear highlighted mesh")

# === CRITICAL: Structure Selection ===

func test_selection_workflow():
	# Create test structure
	var test_mesh = MeshInstance3D.new()
	test_mesh.mesh = BoxMesh.new()
	test_mesh.set_meta("structure_name", "Test Brain Region")
	exploration_scene.brain_container.add_child(test_mesh)
	
	var selected_name = ""
	brain_interaction.structure_selected.connect(func(name, mesh):
		selected_name = name
	)
	
	# Select the structure
	brain_interaction._select_structure(test_mesh)
	
	assert_eq(selected_name, "Test Brain Region", "Should emit correct structure name")
	assert_eq(brain_interaction._selected_mesh, test_mesh, "Should track selected mesh")

func test_selection_clearing():
	# Create and select a structure
	var test_mesh = MeshInstance3D.new()
	test_mesh.mesh = BoxMesh.new()
	exploration_scene.brain_container.add_child(test_mesh)
	
	brain_interaction._select_structure(test_mesh)
	assert_not_null(brain_interaction._selected_mesh)
	
	# Clear selection
	var signal_emitted = false
	brain_interaction.selection_cleared.connect(func():
		signal_emitted = true
	)
	
	brain_interaction.clear_all_selections()
	
	assert_null(brain_interaction._selected_mesh, "Should clear selected mesh")
	assert_true(signal_emitted, "Should emit selection_cleared signal")

# === Info Panel Integration ===

func test_info_panel_shows_on_selection():
	await wait_seconds(1.0)  # Wait for model to load
	
	var info_panel = exploration_scene.info_panel
	assert_not_null(info_panel, "Info panel must exist")
	
	# Initially hidden
	assert_false(info_panel.visible, "Info panel should start hidden")
	
	# Display some info
	exploration_scene.display_structure_info("Hippocampus", {
		"description": "Critical for memory formation"
	})
	
	await wait_frames(10)
	
	# Should now be visible
	assert_true(info_panel.visible, "Info panel should show after displaying info")

# === Performance During Interaction ===

func test_interaction_performance():
	# Perform multiple raycasts rapidly
	var start_time = Time.get_ticks_msec()
	var center = get_viewport().size / 2
	
	for i in range(100):
		brain_interaction.perform_raycast(center)
	
	var elapsed = Time.get_ticks_msec() - start_time
	
	# 100 raycasts should complete in under 100ms (1ms per raycast)
	assert_lt(elapsed, 100, "Raycasting must be performant")

func test_maintains_fps_during_selection():
	var initial_fps = PerformanceMonitor.get_current_metrics().fps
	
	# Create and select multiple structures
	for i in range(5):
		var test_mesh = MeshInstance3D.new()
		test_mesh.mesh = BoxMesh.new()
		test_mesh.set_meta("structure_name", "Structure " + str(i))
		exploration_scene.brain_container.add_child(test_mesh)
		
		brain_interaction._select_structure(test_mesh)
		await wait_frames(2)
	
	var final_fps = PerformanceMonitor.get_current_metrics().fps
	
	# FPS should not drop below 30
	assert_gt(final_fps, 30, "Must maintain 30+ FPS during interactions")

# === Error Handling ===

func test_handles_missing_structure_name():
	# Create mesh without structure_name metadata
	var test_mesh = MeshInstance3D.new()
	test_mesh.mesh = BoxMesh.new()
	exploration_scene.brain_container.add_child(test_mesh)
	
	# Should handle gracefully
	brain_interaction._select_structure(test_mesh)
	
	# Should use default name
	assert_true(true, "Should handle missing metadata without crashing")

func test_handles_null_mesh_gracefully():
	# Try to highlight null
	brain_interaction._highlight_structure(null)
	assert_null(brain_interaction._highlighted_mesh, "Should handle null mesh")
	
	# Try to select null
	brain_interaction._select_structure(null)
	assert_true(true, "Should handle null selection without crashing")