extends GutTest

## Test to verify model loading is working correctly

var model_loader = null

func before_each():
	var ModelLoader = preload("res://src/systems/3d_interaction/ModelLoader.gd")
	model_loader = ModelLoader.new()
	add_child(model_loader)

func after_each():
	if model_loader:
		model_loader.queue_free()

func test_model_path_finding():
	# Test the internal path finding
	var path = model_loader._find_model_path("Internal-Structures", 1)
	print("Found path: " + path)
	assert_true(path != "", "Should find Internal-Structures model path")
	assert_true(path.ends_with(".glb"), "Path should be a GLB file")

func test_model_file_exists():
	var path = "res://assets/3d_models/raw/Internal-Structures.glb"
	assert_true(FileAccess.file_exists(path), "Internal-Structures.glb should exist")

func test_model_can_load():
	var path = "res://assets/3d_models/raw/Internal-Structures.glb"
	var resource = load(path)
	assert_not_null(resource, "Should be able to load the GLB file")

func test_model_loader_async():
	var loaded = false
	var loaded_instance = null
	
	model_loader.load_model_async("Internal-Structures", func(instance):
		loaded = true
		loaded_instance = instance
	)
	
	# Wait for loading
	await wait_seconds(1.0)
	
	assert_true(loaded, "Model should have loaded")
	assert_not_null(loaded_instance, "Should have a valid instance")
	
	if loaded_instance:
		# Check it has children (the brain structures)
		var child_count = loaded_instance.get_child_count()
		print("Model has %d children" % child_count)
		assert_gt(child_count, 0, "Model should have brain structure children")
		
		# List the structures
		for child in loaded_instance.get_children():
			if child is MeshInstance3D:
				print("  - Structure: %s" % child.name)
		
		loaded_instance.queue_free()