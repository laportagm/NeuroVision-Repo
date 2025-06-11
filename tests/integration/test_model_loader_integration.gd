extends GutTest

## Integration tests for ModelLoader with actual model files

var model_loader: Node = null
var test_scene: Node3D = null

func before_each():
	test_scene = Node3D.new()
	add_child(test_scene)
	
	model_loader = preload("res://src/systems/3d_interaction/ModelLoader.gd").new()
	test_scene.add_child(model_loader)

func after_each():
	if test_scene and is_instance_valid(test_scene):
		test_scene.queue_free()
		test_scene = null

# === INTEGRATION TESTS ===

func test_load_internal_structures_model():
	# Try to load our known model
	var loaded = false
	var loaded_instance = null
	
	model_loader.model_loaded.connect(func(name, instance):
		if name == "Internal-Structures":
			loaded = true
			loaded_instance = instance
	)
	
	model_loader.model_load_failed.connect(func(name, error):
		if name == "Internal-Structures":
			print("[Test] Failed to load Internal-Structures: ", error)
	)
	
	# Disable threading for predictable testing
	model_loader.use_threading = false
	
	# Try to load the model
	var model = model_loader.load_model("Internal-Structures")
	
	# If model exists, it should load
	if ResourceLoader.exists("res://assets/3d_models/raw/Internal-Structures.glb"):
		assert_true(loaded or model != null)
		if loaded_instance:
			assert_not_null(loaded_instance)
			assert_true(loaded_instance is Node3D)
	else:
		# Model doesn't exist, which is fine for unit tests
		print("[Test] Internal-Structures.glb not found, skipping load test")

func test_async_model_loading():
	var callback_called = false
	var loaded_model = null
	
	model_loader.use_threading = false
	
	model_loader.load_model_async("Internal-Structures", func(instance):
		callback_called = true
		loaded_model = instance
	)
	
	# Wait a bit for async operation
	await wait_seconds(0.5)
	
	# Callback should have been called
	if ResourceLoader.exists("res://assets/3d_models/raw/Internal-Structures.glb"):
		assert_true(callback_called)

func test_model_metadata():
	model_loader.use_threading = false
	
	# Create a test model data
	var model_data = ModelLoader.ModelData.new()
	model_data.name = "TestModel"
	model_data.metadata = {
		"vertex_count": 1000,
		"material_count": 2,
		"has_collision": true
	}
	
	# Register it
	model_loader._loaded_models["TestModel"] = model_data
	
	# Get metadata
	var metadata = model_loader.get_model_metadata("TestModel")
	assert_eq(metadata.vertex_count, 1000)
	assert_eq(metadata.material_count, 2)
	assert_true(metadata.has_collision)

func test_lod_change_workflow():
	var lod_changed_emitted = false
	var new_lod_level = -1
	
	model_loader.lod_changed.connect(func(name, lod):
		lod_changed_emitted = true
		new_lod_level = lod
	)
	
	# Create dummy model data
	var model_data = ModelLoader.ModelData.new()
	model_data.name = "TestModel"
	model_data.current_lod = ModelLoader.LODLevel.MEDIUM
	
	# Add some dummy instances
	model_data.instances[ModelLoader.LODLevel.LOW] = Node3D.new()
	model_data.instances[ModelLoader.LODLevel.MEDIUM] = Node3D.new()
	model_data.instances[ModelLoader.LODLevel.HIGH] = Node3D.new()
	
	model_loader._loaded_models["TestModel"] = model_data
	
	# Change LOD
	var success = model_loader.change_model_lod("TestModel", ModelLoader.LODLevel.HIGH)
	
	assert_true(success)
	assert_true(lod_changed_emitted)
	assert_eq(new_lod_level, ModelLoader.LODLevel.HIGH)
	
	# Clean up
	for instance in model_data.instances.values():
		instance.queue_free()

func test_unload_model():
	# Create a test model
	var model_data = ModelLoader.ModelData.new()
	model_data.name = "TestModel"
	
	var test_instance = Node3D.new()
	test_scene.add_child(test_instance)
	model_data.instances[ModelLoader.LODLevel.MEDIUM] = test_instance
	
	model_loader._loaded_models["TestModel"] = model_data
	
	# Verify it's loaded
	assert_true("TestModel" in model_loader.get_model_list())
	
	# Unload it
	model_loader.unload_model("TestModel")
	
	# Verify it's unloaded
	assert_false("TestModel" in model_loader.get_model_list())

func test_scan_for_models():
	var models = model_loader._scan_for_models()
	
	# Should find Internal-Structures if it exists
	if DirAccess.dir_exists_absolute("res://assets/3d_models/raw/"):
		print("[Test] Found models: ", models)
		
		# Check if Internal-Structures is in the list
		var found_internal_structures = false
		for model in models:
			if "Internal-Structures" in model or "Internal_Structures" in model:
				found_internal_structures = true
				break
		
		if ResourceLoader.exists("res://assets/3d_models/raw/Internal-Structures.glb"):
			assert_true(found_internal_structures)

func test_performance_monitor_integration():
	# Test that ModelLoader responds to quality changes
	var quality_handled = false
	
	# Mock quality change
	if PerformanceMonitor:
		model_loader._on_quality_level_changed(PerformanceMonitor.QualityLevel.LOW)
		assert_eq(model_loader._current_quality_level, PerformanceMonitor.QualityLevel.LOW)
		
		model_loader._on_quality_level_changed(PerformanceMonitor.QualityLevel.HIGH)
		assert_eq(model_loader._current_quality_level, PerformanceMonitor.QualityLevel.HIGH)

func test_all_models_loaded_signal():
	var signal_emitted = false
	
	model_loader.all_models_loaded.connect(func(): signal_emitted = true)
	
	model_loader.use_threading = false
	
	# Load with empty queue should emit immediately
	model_loader._loading_queue.clear()
	model_loader._active_loads = 0
	model_loader._finish_threaded_load({}, null, Thread.new())
	
	assert_true(signal_emitted)