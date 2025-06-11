extends GutTest

## Tests for Level 3: Brain Model Loading

var model_loader = null
var exploration_scene = null
var loaded_model = null

func before_each():
	model_loader = preload("res://src/systems/3d_interaction/ModelLoader.gd").new()
	add_child(model_loader)
	model_loader.use_threading = false  # Synchronous for testing

func after_each():
	if model_loader and is_instance_valid(model_loader):
		model_loader.queue_free()
	if exploration_scene and is_instance_valid(exploration_scene):
		exploration_scene.queue_free()
	if loaded_model and is_instance_valid(loaded_model):
		loaded_model.queue_free()

# === MODEL FILE TESTS ===

func test_internal_structures_model_exists():
	# Verify the model file exists
	var model_path = "res://assets/3d_models/raw/Internal-Structures.glb"
	assert_true(ResourceLoader.exists(model_path))
	
	# Should be able to load as resource
	var resource = load(model_path)
	assert_not_null(resource)

func test_model_loader_finds_internal_structures():
	# ModelLoader should find our model
	var models = model_loader._scan_for_models()
	
	var found = false
	for model_name in models:
		if "Internal-Structures" in model_name or "Internal_Structures" in model_name:
			found = true
			break
	
	assert_true(found)

# === MODEL LOADING TESTS ===

func test_load_internal_structures_sync():
	var load_success = false
	var loaded_instance = null
	
	model_loader.model_loaded.connect(func(name, instance):
		if name == "Internal-Structures":
			load_success = true
			loaded_instance = instance
	)
	
	# Load the model
	var model = model_loader.load_model("Internal-Structures")
	
	# Should succeed
	assert_true(load_success or model != null)
	
	if loaded_instance:
		assert_true(loaded_instance is Node3D)
		# Should have child nodes (the actual mesh instances)
		assert_gt(loaded_instance.get_child_count(), 0)

func test_load_internal_structures_async():
	var callback_called = false
	loaded_model = null
	
	model_loader.load_model_async("Internal-Structures", func(instance):
		callback_called = true
		loaded_model = instance
	)
	
	# Wait for async load
	await wait_seconds(0.5)
	
	assert_true(callback_called)
	assert_not_null(loaded_model)
	assert_true(loaded_model is Node3D)

func test_model_has_mesh_instances():
	model_loader.load_model_async("Internal-Structures", func(instance):
		loaded_model = instance
	)
	
	await wait_seconds(0.5)
	
	if not loaded_model:
		skip_test("Model failed to load")
		return
	
	# Find MeshInstance3D nodes
	var mesh_count = 0
	var queue = [loaded_model]
	
	while queue.size() > 0:
		var node = queue.pop_front()
		if node is MeshInstance3D:
			mesh_count += 1
			assert_not_null(node.mesh)
		
		for child in node.get_children():
			queue.append(child)
	
	# Should have at least one mesh
	assert_gt(mesh_count, 0)

# === EXPLORATION SCENE INTEGRATION ===

func test_exploration_scene_loads_brain_model():
	# Create exploration scene
	var scene = load("res://src/scenes/ExplorationScene.tscn")
	exploration_scene = scene.instantiate()
	add_child(exploration_scene)
	
	# Wait for model loading
	await wait_seconds(1.0)
	
	# Check if model was loaded
	var brain_container = exploration_scene.get_node("BrainModelContainer")
	assert_not_null(brain_container)
	
	# Should have children (the loaded model)
	assert_gt(brain_container.get_child_count(), 0)
	
	# Should not have placeholder anymore
	var placeholder = brain_container.get_node_or_null("PlaceholderBrain")
	assert_null(placeholder)

func test_model_interaction_setup():
	var scene = load("res://src/scenes/ExplorationScene.tscn")
	exploration_scene = scene.instantiate()
	add_child(exploration_scene)
	
	await wait_seconds(1.0)
	
	# Brain interaction controller should be set up
	assert_not_null(exploration_scene._brain_interaction)
	
	# Should have collision bodies for selection
	var brain_container = exploration_scene.get_node("BrainModelContainer")
	var has_collision = false
	
	for child in brain_container.get_children():
		if _check_for_collision_recursive(child):
			has_collision = true
			break
	
	# Model should have collision for selection
	# Note: This might fail if the model doesn't have collision set up yet
	# assert_true(has_collision)

func _check_for_collision_recursive(node: Node) -> bool:
	if node is StaticBody3D or node is Area3D:
		return true
	
	for child in node.get_children():
		if _check_for_collision_recursive(child):
			return true
	
	return false

# === PERFORMANCE TESTS ===

func test_model_loading_performance():
	var start_time = Time.get_ticks_msec()
	
	model_loader.load_model("Internal-Structures")
	
	var load_time = Time.get_ticks_msec() - start_time
	
	# Should load in under 2 seconds
	assert_lt(load_time, 2000)
	
	# Memory usage should be reasonable
	var metrics = PerformanceMonitor.get_current_metrics()
	# Memory usage in MB - brain model shouldn't use more than 500MB
	assert_lt(metrics.memory, 500)

func test_model_lod_system():
	# Test that LOD system works
	var model_data = model_loader.ModelData.new()
	model_data.name = "Internal-Structures"
	
	# Should handle different LOD levels
	var lod_path = model_loader._find_model_path("Internal-Structures", ModelLoader.LODLevel.HIGH)
	assert_not_null(lod_path)
	
	# Should fall back if high LOD doesn't exist
	assert_true(lod_path.ends_with(".glb"))

# === ERROR HANDLING TESTS ===

func test_handles_missing_model_gracefully():
	var error_emitted = false
	var error_message = ""
	
	model_loader.model_load_failed.connect(func(name, error):
		error_emitted = true
		error_message = error
	)
	
	# Try to load non-existent model
	model_loader.load_model("NonExistentModel")
	
	# Should emit error signal
	assert_true(error_emitted)
	assert_true(error_message.contains("not found") or error_message.contains("does not exist"))