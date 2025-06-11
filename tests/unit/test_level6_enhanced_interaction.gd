extends GutTest

## Tests for Level 6: Enhanced 3D Interaction Features

var camera_presets = null
var annotation_system = null
var test_camera = null
var test_container = null

func before_each():
	# Create test environment
	test_container = Node3D.new()
	add_child(test_container)
	
	test_camera = Camera3D.new()
	test_camera.position = Vector3(0, 0, 5)
	add_child(test_camera)
	
	# Initialize systems
	var CameraPresetManager = preload("res://src/systems/3d_interaction/CameraPresetManager.gd")
	camera_presets = CameraPresetManager.new()
	add_child(camera_presets)
	
	var AnnotationSystem = preload("res://src/systems/3d_interaction/AnnotationSystem.gd")
	annotation_system = AnnotationSystem.new()
	add_child(annotation_system)

func after_each():
	if camera_presets and is_instance_valid(camera_presets):
		camera_presets.queue_free()
	if annotation_system and is_instance_valid(annotation_system):
		annotation_system.queue_free()
	if test_camera and is_instance_valid(test_camera):
		test_camera.queue_free()
	if test_container and is_instance_valid(test_container):
		test_container.queue_free()

# === CAMERA PRESET TESTS ===

func test_camera_preset_initialization():
	camera_presets.initialize(test_camera, test_container)
	
	# Should create camera pivot
	assert_not_null(test_camera.get_parent())
	assert_eq(test_camera.get_parent().name, "CameraPivot")

func test_all_camera_presets_exist():
	camera_presets.initialize(test_camera, test_container)
	
	# Test each preset
	var presets = [
		camera_presets.CameraPreset.ANTERIOR,
		camera_presets.CameraPreset.POSTERIOR,
		camera_presets.CameraPreset.LATERAL_RIGHT,
		camera_presets.CameraPreset.LATERAL_LEFT,
		camera_presets.CameraPreset.SUPERIOR,
		camera_presets.CameraPreset.INFERIOR,
		camera_presets.CameraPreset.OBLIQUE_1,
		camera_presets.CameraPreset.OBLIQUE_2
	]
	
	for preset in presets:
		var name = camera_presets.get_preset_name(preset)
		assert_true(name.length() > 0, "Preset should have name")
		
		var desc = camera_presets.get_preset_description(preset)
		assert_true(desc.length() > 0, "Preset should have description")

func test_camera_preset_application():
	camera_presets.initialize(test_camera, test_container)
	
	# Apply instant preset
	camera_presets.apply_preset(camera_presets.CameraPreset.ANTERIOR, true)
	assert_eq(camera_presets.get_current_preset(), camera_presets.CameraPreset.ANTERIOR)
	
	# Camera should be positioned
	assert_eq(test_camera.position.z, camera_presets.CAMERA_DISTANCE)

func test_camera_preset_cycling():
	camera_presets.initialize(test_camera, test_container)
	
	var initial_preset = camera_presets.get_current_preset()
	
	# Cycle forward
	camera_presets.cycle_presets(true)
	var next_preset = camera_presets.get_current_preset()
	assert_ne(initial_preset, next_preset, "Preset should change when cycling")
	
	# Cycle backward
	camera_presets.cycle_presets(false)
	assert_eq(camera_presets.get_current_preset(), initial_preset, "Should cycle back")

func test_camera_focus_on_structure():
	camera_presets.initialize(test_camera, test_container)
	
	# Create test structure
	var test_mesh = MeshInstance3D.new()
	test_mesh.mesh = BoxMesh.new()
	test_mesh.position = Vector3(2, 0, 0)
	test_container.add_child(test_mesh)
	
	# Focus on structure
	camera_presets.focus_on_structure(test_mesh, 5.0)
	
	# Camera pivot should move to structure position
	assert_eq(camera_presets._camera_pivot.position.x, 2.0)

# === ANNOTATION SYSTEM TESTS ===

func test_annotation_system_initialization():
	annotation_system.initialize(test_container, test_camera)
	
	# Should create annotation container
	var annotation_container = test_container.get_node_or_null("Annotations")
	assert_not_null(annotation_container)

func test_add_annotation():
	annotation_system.initialize(test_container, test_camera)
	
	# Create test structure
	var test_mesh = MeshInstance3D.new()
	test_mesh.mesh = BoxMesh.new()
	test_container.add_child(test_mesh)
	
	# Add annotation
	annotation_system.add_annotation(
		"test_ann",
		"Test Label",
		test_mesh,
		Vector3(0, 1, 0)
	)
	
	# Should exist
	assert_true(annotation_system._annotations.has("test_ann"))
	
	# Should have 3D label
	var annotation = annotation_system._annotations["test_ann"]
	assert_not_null(annotation.label_3d)
	assert_eq(annotation.label_3d.text, "Test Label")

func test_annotation_importance_levels():
	annotation_system.initialize(test_container, test_camera)
	
	var test_mesh = MeshInstance3D.new()
	test_container.add_child(test_mesh)
	
	# Add annotations with different importance
	annotation_system.add_annotation("low", "Low", test_mesh)
	annotation_system.add_annotation("med", "Medium", test_mesh)
	annotation_system.add_annotation("high", "High", test_mesh)
	
	annotation_system.set_annotation_importance("low", 0)
	annotation_system.set_annotation_importance("med", 1)
	annotation_system.set_annotation_importance("high", 2)
	
	# Test detail levels
	annotation_system.set_detail_level(0)  # Only high importance
	assert_false(annotation_system._annotations["low"].label_3d.visible)
	assert_false(annotation_system._annotations["med"].label_3d.visible)
	assert_true(annotation_system._annotations["high"].label_3d.visible)

func test_annotation_visibility_toggle():
	annotation_system.initialize(test_container, test_camera)
	
	var test_mesh = MeshInstance3D.new()
	test_container.add_child(test_mesh)
	
	annotation_system.add_annotation("test", "Test", test_mesh)
	
	# Initially visible
	assert_true(annotation_system._visibility_enabled)
	
	# Toggle off
	annotation_system.toggle_visibility()
	assert_false(annotation_system._visibility_enabled)
	assert_false(annotation_system._annotations["test"].label_3d.visible)

func test_annotation_highlighting():
	annotation_system.initialize(test_container, test_camera)
	
	var test_mesh = MeshInstance3D.new()
	test_container.add_child(test_mesh)
	
	annotation_system.add_annotation("test", "Test", test_mesh)
	
	# Highlight
	annotation_system.highlight_annotation("test", true)
	var label = annotation_system._annotations["test"].label_3d
	assert_eq(label.modulate, annotation_system.HIGHLIGHT_COLOR)
	
	# Unhighlight
	annotation_system.highlight_annotation("test", false)
	assert_eq(label.modulate, annotation_system.LABEL_COLOR)

func test_default_brain_annotations():
	annotation_system.initialize(test_container, test_camera)
	
	# Create mock brain structures
	var structures = {}
	var structure_names = [
		"Thalami (good)",
		"Hipp and Others (good)",
		"Striatum (good)",
		"Ventricles (good)",
		"Corpus Callosum (good)"
	]
	
	for name in structure_names:
		var mesh = MeshInstance3D.new()
		mesh.name = name
		test_container.add_child(mesh)
		structures[name] = mesh
	
	# Create default annotations
	annotation_system.create_default_annotations(structures)
	
	# Should have annotations for each structure
	assert_true(annotation_system._annotations.has("thalamus_relay"))
	assert_true(annotation_system._annotations.has("hippocampus_memory"))
	assert_true(annotation_system._annotations.has("striatum_motor"))
	assert_true(annotation_system._annotations.has("ventricles_csf"))
	assert_true(annotation_system._annotations.has("corpus_callosum_connect"))

# === INTEGRATION TESTS ===

func test_camera_and_annotation_integration():
	# Initialize both systems
	camera_presets.initialize(test_camera, test_container)
	annotation_system.initialize(test_container, test_camera)
	
	# Create test structure with annotation
	var test_mesh = MeshInstance3D.new()
	test_mesh.mesh = BoxMesh.new()
	test_container.add_child(test_mesh)
	
	annotation_system.add_annotation("test", "Test Structure", test_mesh)
	
	# Apply different camera presets
	camera_presets.apply_preset(camera_presets.CameraPreset.ANTERIOR, true)
	await wait_frames(2)
	
	# Annotation should still be visible
	assert_true(annotation_system._annotations["test"].label_3d.visible)
	
	# Apply another preset
	camera_presets.apply_preset(camera_presets.CameraPreset.SUPERIOR, true)
	await wait_frames(2)
	
	# Should maintain visibility
	assert_true(annotation_system._annotations["test"].label_3d.visible)