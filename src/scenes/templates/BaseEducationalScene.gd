class_name BaseEducationalScene
extends Node3D

## Base class for all educational scenes in NeuroVision
## Provides standard lighting, camera, and UI framework with accessibility support

# === SIGNALS ===
signal scene_ready()
signal model_loaded(model_name: String)
signal structure_selected(structure_name: String)
signal ui_interaction(interaction_type: String, data: Dictionary)

# === CONSTANTS ===
const DEFAULT_CAMERA_DISTANCE: float = 10.0
const DEFAULT_FOV: float = 65.0
const LIGHTING_PRESETS = {
	"standard": {
		"main_energy": 1.2,
		"fill_energy": 0.3,
		"rim_energy": 0.8
	},
	"high_contrast": {
		"main_energy": 1.5,
		"fill_energy": 0.1,
		"rim_energy": 1.0
	},
	"low_light": {
		"main_energy": 0.8,
		"fill_energy": 0.2,
		"rim_energy": 0.5
	}
}

# === NODES ===
@onready var camera: Camera3D = $CameraSystem/CameraPivot/Camera3D
@onready var camera_pivot: Node3D = $CameraSystem/CameraPivot
@onready var brain_container: Node3D = $BrainModelContainer
@onready var model_holder: Node3D = $BrainModelContainer/ModelHolder
@onready var selection_sphere: MeshInstance3D = $BrainModelContainer/SelectionSphere
@onready var main_ui: Control = $UI/MainUI
@onready var debug_overlay: Control = $UI/DebugOverlay
@onready var accessibility_layer: Control = $UI/AccessibilityLayer

# Lighting
@onready var main_light: DirectionalLight3D = $Environment/Lighting/DirectionalLight3D
@onready var fill_light: DirectionalLight3D = $Environment/Lighting/FillLight
@onready var rim_light: DirectionalLight3D = $Environment/Lighting/RimLight

# === PRIVATE VARIABLES ===
var _current_model: Node3D = null
var _camera_controller = null
var _selection_manager = null
var _is_initialized: bool = false

# === VIRTUAL METHODS (Override in derived classes) ===

func _educational_setup() -> void:
	"""Override this method to implement scene-specific educational setup"""
	pass

func _create_ui() -> void:
	"""Override this method to create scene-specific UI"""
	pass

func _configure_accessibility() -> void:
	"""Override this method to configure scene-specific accessibility features"""
	pass

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[BaseEducationalScene] Initializing educational scene")
	
	# Wait for managers to be ready
	await get_tree().process_frame
	
	_initialize_base_systems()
	_educational_setup()
	_create_ui()
	_configure_accessibility()
	
	_is_initialized = true
	scene_ready.emit()

func load_brain_model(model_path: String) -> bool:
	"""Load a brain model into the scene"""
	if not ResourceLoader.exists(model_path):
		push_error("[BaseEducationalScene] Model not found: " + model_path)
		return false
	
	var model_scene = load(model_path)
	if model_scene == null:
		push_error("[BaseEducationalScene] Failed to load model: " + model_path)
		return false
	
	# Remove existing model
	if _current_model:
		model_holder.remove_child(_current_model)
		_current_model.queue_free()
	
	# Instantiate new model
	_current_model = model_scene.instantiate()
	model_holder.add_child(_current_model)
	
	# Configure model for educational use
	_configure_model_for_education(_current_model)
	
	model_loaded.emit(model_path.get_file().get_basename())
	return true

func set_lighting_preset(preset_name: String) -> void:
	"""Set lighting preset for different educational contexts"""
	if not LIGHTING_PRESETS.has(preset_name):
		push_warning("[BaseEducationalScene] Unknown lighting preset: " + preset_name)
		return
	
	var preset = LIGHTING_PRESETS[preset_name]
	main_light.light_energy = preset.main_energy
	fill_light.light_energy = preset.fill_energy
	rim_light.light_energy = preset.rim_energy

func focus_camera_on_model() -> void:
	"""Focus camera on the loaded model"""
	if not _current_model:
		return
	
	var aabb = _get_model_bounds(_current_model)
	var size = aabb.size.length()
	var distance = size * 1.5
	
	if _camera_controller:
		_camera_controller.focus_on_bounds(aabb)
	else:
		# Simple camera positioning
		camera_pivot.position = aabb.get_center()
		camera.position.z = distance

func enable_debug_overlay(enabled: bool) -> void:
	"""Enable or disable debug overlay"""
	debug_overlay.visible = enabled

func get_educational_context() -> Dictionary:
	"""Get educational context information"""
	return {
		"scene_type": get_script().get_global_name(),
		"model_loaded": _current_model != null,
		"camera_position": camera.global_position,
		"learning_level": EducationalPlatformManager.get_learning_level() if EducationalPlatformManager else 1
	}

# === PRIVATE METHODS ===

func _initialize_base_systems() -> void:
	"""Initialize base educational systems"""
	# Initialize camera controller if available
	var camera_controller_class = preload("res://src/core/interaction/CameraBehaviorController.gd")
	if camera_controller_class:
		_camera_controller = camera_controller_class.new()
		_camera_controller.initialize(camera, camera_pivot)
		add_child(_camera_controller)
	
	# Initialize selection manager if available
	var selection_manager_class = preload("res://src/core/interaction/BrainStructureSelectionManager.gd")
	if selection_manager_class:
		_selection_manager = selection_manager_class.new()
		_selection_manager.selection_sphere = selection_sphere
		_selection_manager.structure_selected.connect(_on_structure_selected)
		add_child(_selection_manager)
	
	# Apply Intel GPU optimizations if detected
	if CoreSystemManager and CoreSystemManager.is_intel_gpu_detected():
		_apply_intel_optimizations()

func _configure_model_for_education(model: Node3D) -> void:
	"""Configure a loaded model for educational use"""
	# Enable collision for selection
	_add_collision_to_model(model)
	
	# Set up material highlighting
	_setup_material_highlighting(model)
	
	# Configure for accessibility
	_configure_model_accessibility(model)

func _add_collision_to_model(model: Node3D) -> void:
	"""Add collision shapes to model for selection"""
	var mesh_instances = _find_mesh_instances(model)
	for mesh_instance in mesh_instances:
		if mesh_instance.get_child_count() == 0 or not mesh_instance.get_child(0) is StaticBody3D:
			var static_body = StaticBody3D.new()
			var collision_shape = CollisionShape3D.new()
			
			if mesh_instance.mesh:
				collision_shape.shape = mesh_instance.mesh.create_trimesh_shape()
			
			static_body.add_child(collision_shape)
			mesh_instance.add_child(static_body)

func _find_mesh_instances(node: Node) -> Array[MeshInstance3D]:
	"""Recursively find all MeshInstance3D nodes"""
	var mesh_instances: Array[MeshInstance3D] = []
	
	if node is MeshInstance3D:
		mesh_instances.append(node)
	
	for child in node.get_children():
		mesh_instances.append_array(_find_mesh_instances(child))
	
	return mesh_instances

func _setup_material_highlighting(model: Node3D) -> void:
	"""Setup material highlighting for educational interaction"""
	if not HighlightMaterialManager:
		return
	
	var mesh_instances = _find_mesh_instances(model)
	for mesh_instance in mesh_instances:
		HighlightMaterialManager.register_mesh_for_highlighting(mesh_instance)

func _configure_model_accessibility(model: Node3D) -> void:
	"""Configure model for accessibility features"""
	# Add accessibility labels
	var mesh_instances = _find_mesh_instances(model)
	for mesh_instance in mesh_instances:
		if mesh_instance.name and not mesh_instance.name.is_empty():
			# Add accessibility metadata
			mesh_instance.set_meta("accessibility_label", mesh_instance.name)
			mesh_instance.set_meta("educational_content", true)

func _get_model_bounds(model: Node3D) -> AABB:
	"""Get bounding box of the model"""
	var aabb = AABB()
	var mesh_instances = _find_mesh_instances(model)
	
	for mesh_instance in mesh_instances:
		if mesh_instance.mesh:
			var local_aabb = mesh_instance.mesh.get_aabb()
			local_aabb = mesh_instance.transform * local_aabb
			
			if aabb.size == Vector3.ZERO:
				aabb = local_aabb
			else:
				aabb = aabb.merge(local_aabb)
	
	return aabb

func _apply_intel_optimizations() -> void:
	"""Apply Intel GPU optimizations to the scene"""
	# Reduce shadow quality
	main_light.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	
	# Disable unnecessary lights for performance
	if CoreSystemManager.get_performance_level() == 3:  # PerformanceLevel.POOR
		fill_light.visible = false
		rim_light.visible = false

func _on_structure_selected(structure_name: String, _mesh: MeshInstance3D) -> void:
	"""Handle structure selection"""
	structure_selected.emit(structure_name)
	
	# Update educational progress
	if EducationalPlatformManager:
		EducationalPlatformManager.update_progress(structure_name, "view", {"_duration": 0.0})

# === INPUT HANDLING ===

func _unhandled_input(event: InputEvent) -> void:
	"""Handle base input events"""
	if event.is_action_pressed("ui_cancel"):
		# Handle escape key for accessibility
		ui_interaction.emit("escape_pressed", {})
	elif event.is_action_pressed("ui_accept"):
		# Handle enter key for accessibility
		ui_interaction.emit("accept_pressed", {})