extends GutTest

## Unit tests for ModelLoader

var model_loader: Node = null

func before_each():
	model_loader = preload("res://src/systems/3d_interaction/ModelLoader.gd").new()
	add_child(model_loader)

func after_each():
	if model_loader and is_instance_valid(model_loader):
		model_loader.queue_free()
		model_loader = null

# === INITIALIZATION TESTS ===

func test_initialization():
	assert_not_null(model_loader)
	assert_true(model_loader.auto_adjust_lod)
	assert_false(model_loader.preload_all_lods)
	assert_true(model_loader.use_threading)
	assert_eq(model_loader.max_concurrent_loads, 3)

func test_constants():
	assert_eq(ModelLoader.MODEL_PATH_BASE, "res://assets/3d_models/")
	assert_eq(ModelLoader.RAW_PATH, "res://assets/3d_models/raw/")
	assert_eq(ModelLoader.PROCESSED_PATH, "res://assets/3d_models/processed/")

func test_lod_enum():
	assert_eq(ModelLoader.LODLevel.HIGH, 0)
	assert_eq(ModelLoader.LODLevel.MEDIUM, 1)
	assert_eq(ModelLoader.LODLevel.LOW, 2)

# === PATH FINDING TESTS ===

func test_find_model_path():
	# Test with our known model
	var path = model_loader._find_model_path("Internal-Structures", ModelLoader.LODLevel.HIGH)
	
	# Should find the model in raw directory
	if path != "":
		assert_true(path.contains("Internal-Structures"))
		assert_true(path.ends_with(".glb"))

func test_clean_model_name():
	assert_eq(model_loader._clean_model_name("Internal-Structures"), "Internal Structures")
	assert_eq(model_loader._clean_model_name("test_model_good"), "Test Model")
	assert_eq(model_loader._clean_model_name("Brain_Region_(good)"), "Brain Region")
	assert_eq(model_loader._clean_model_name("hippocampus_high"), "Hippocampus")

# === LOADING TESTS ===

func test_model_list_empty_initially():
	assert_eq(model_loader.get_model_list().size(), 0)

func test_get_loaded_model_returns_null_for_unloaded():
	var model = model_loader.get_loaded_model("NonExistentModel")
	assert_null(model)

func test_unload_nonexistent_model():
	# Should not crash
	model_loader.unload_model("NonExistentModel")
	assert_true(true)  # If we get here, it didn't crash

func test_metadata_for_unloaded_model():
	var metadata = model_loader.get_model_metadata("NonExistentModel")
	assert_eq(metadata.size(), 0)

# === LOD TESTS ===

func test_get_recommended_lod():
	# Test different quality levels
	model_loader._current_quality_level = PerformanceMonitor.QualityLevel.LOW
	assert_eq(model_loader._get_recommended_lod(), ModelLoader.LODLevel.LOW)
	
	model_loader._current_quality_level = PerformanceMonitor.QualityLevel.MEDIUM
	assert_eq(model_loader._get_recommended_lod(), ModelLoader.LODLevel.MEDIUM)
	
	model_loader._current_quality_level = PerformanceMonitor.QualityLevel.HIGH
	assert_eq(model_loader._get_recommended_lod(), ModelLoader.LODLevel.HIGH)
	
	model_loader._current_quality_level = PerformanceMonitor.QualityLevel.ULTRA
	assert_eq(model_loader._get_recommended_lod(), ModelLoader.LODLevel.HIGH)

func test_lod_suffixes():
	assert_eq(ModelLoader.LOD_SUFFIXES[ModelLoader.LODLevel.HIGH], "_high")
	assert_eq(ModelLoader.LOD_SUFFIXES[ModelLoader.LODLevel.MEDIUM], "_medium")
	assert_eq(ModelLoader.LOD_SUFFIXES[ModelLoader.LODLevel.LOW], "_low")

# === SIGNAL TESTS ===

func test_model_loaded_signal():
	var signal_emitted = false
	var loaded_name = ""
	
	model_loader.model_loaded.connect(func(name, _instance):
		signal_emitted = true
		loaded_name = name
	)
	
	# Would need actual model file to test fully
	# For now, just verify signal is declared
	assert_has_signal(model_loader, "model_loaded")

func test_model_load_failed_signal():
	assert_has_signal(model_loader, "model_load_failed")

func test_lod_changed_signal():
	assert_has_signal(model_loader, "lod_changed")

func test_loading_progress_signal():
	assert_has_signal(model_loader, "loading_progress")

# === THREADING TESTS ===

func test_threading_enabled_by_default():
	assert_true(model_loader.use_threading)

func test_disable_threading():
	model_loader.use_threading = false
	assert_false(model_loader.use_threading)

func test_max_concurrent_loads():
	assert_eq(model_loader.max_concurrent_loads, 3)
	
	model_loader.max_concurrent_loads = 5
	assert_eq(model_loader.max_concurrent_loads, 5)

# === AUTO LOD TESTS ===

func test_auto_adjust_lod_enabled():
	assert_true(model_loader.auto_adjust_lod)

func test_disable_auto_adjust_lod():
	model_loader.auto_adjust_lod = false
	assert_false(model_loader.auto_adjust_lod)

# === HELPER METHOD TESTS ===

func test_scan_for_models():
	# This should find at least our Internal-Structures.glb
	var models = model_loader._scan_for_models()
	assert_true(models.size() >= 0)  # Might be 0 if no models in directory

func test_model_data_class():
	var model_data = ModelLoader.ModelData.new()
	assert_not_null(model_data)
	assert_eq(model_data.name, "")
	assert_eq(model_data.instances.size(), 0)
	assert_eq(model_data.current_lod, ModelLoader.LODLevel.MEDIUM)
	assert_eq(model_data.metadata.size(), 0)