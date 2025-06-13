extends Node

## Handles loading and management of 3D brain models with LOD support

signal model_loaded(model_name: String, model_instance: Node3D)
signal model_load_failed(model_name: String, error: String)
signal lod_changed(model_name: String, lod_level: int)
signal all_models_loaded()
# signal loading_progress(progress: float)

# === ENUMS ===
enum LODLevel {
	HIGH = 0,
	MEDIUM = 1,
	LOW = 2
}

# === CONSTANTS ===
const MODEL_PATH_BASE: String = "res://assets/3d_models/"
const PROCESSED_PATH: String = "res://assets/3d_models/processed/"
const RAW_PATH: String = "res://assets/3d_models/raw/"
const TEXTURE_PATH: String = "res://assets/3d_models/textures/"

# LOD suffixes for model files
const LOD_SUFFIXES: Dictionary = {
	LODLevel.HIGH: "_high",
	LODLevel.MEDIUM: "_medium",
	LODLevel.LOW: "_low"
}

# Fallback if no LOD variants exist
const LOD_FALLBACKS: Dictionary = {
	LODLevel.HIGH: ["", "_med", "_low"],
	LODLevel.MEDIUM: ["_med", "", "_low", "_high"],
	LODLevel.LOW: ["_low", "_med", "", "_high"]
}

# === EXPORTS ===
@export var auto_adjust_lod: bool = true
@export var preload_all_lods: bool = false
@export var use_threading: bool = true
@export var max_concurrent_loads: int = 3

# === PRIVATE VARIABLES ===
var _loaded_models: Dictionary = {}  # model_name -> ModelData
var _loading_queue: Array = []
var _active_loads: int = 0
var _current_quality_level: int = PerformanceMonitor.QualityLevel.LOW  # Start with LOW by default
var _model_cache: Dictionary = {}  # path -> Resource
var _gpu_detector = null  # Will be initialized in _ready

# Model data structure
class ModelData:
	var name: String
	var instances: Dictionary = {}  # LODLevel -> Node3D
	var current_lod: int = LODLevel.MEDIUM
	var bounding_box: AABB
	var metadata: Dictionary = {}

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[ModelLoader] System initialized")
	
	# Initialize GPU detector
	var GPUDetectorScript = preload("res://src/systems/3d_interaction/GPUDetector.gd")
	_gpu_detector = GPUDetectorScript.new()
	add_child(_gpu_detector)
	
	# Detect GPU and set initial quality
	var _gpu_info = _gpu_detector.detect_gpu()  # Prefixed with _ to indicate intentionally unused
	_current_quality_level = _gpu_detector.get_recommended_quality()
	
	var quality_names = ["LOW", "MEDIUM", "HIGH", "ULTRA"]
	if _current_quality_level < quality_names.size():
		print("[ModelLoader] Initial quality level: " + quality_names[_current_quality_level])
	else:
		print("[ModelLoader] Initial quality level: %d" % _current_quality_level)
	
	# Connect to performance monitor if available
	# Use call_deferred to ensure the node tree is ready
	call_deferred("_connect_to_performance_monitor")

func load_model(model_name: String, lod_level: int = -1) -> Dictionary:
	"""Load a brain model with specified LOD level"""
	if lod_level == -1:
		lod_level = _get_recommended_lod()
	
	# Check if already loaded
	if model_name in _loaded_models:
		var model_data = _loaded_models[model_name]
		if lod_level in model_data.instances:
			return {
				"mesh_instance": model_data.instances[lod_level].duplicate(),
				"error": ""
			}
	
	# Try to load synchronously
	var model_path = _find_model_path(model_name, lod_level)
	if model_path == "":
		return {
			"mesh_instance": null,
			"error": "Model file not found: %s LOD %d" % [model_name, lod_level]
		}
	
	var model_resource = _load_resource(model_path)
	if not model_resource:
		return {
			"mesh_instance": null,
			"error": "Failed to load model resource: %s" % model_path
		}
	
	var instance = _create_model_instance(model_resource, model_name)
	if instance:
		_register_loaded_model(model_name, instance, lod_level)
		return {
			"mesh_instance": instance,
			"error": ""
		}
	else:
		return {
			"mesh_instance": null,
			"error": "Failed to create model instance"
		}

func load_model_async(model_name: String, callback: Callable, lod_level: int = -1) -> void:
	"""Load a model asynchronously with callback"""
	if lod_level == -1:
		lod_level = _get_recommended_lod()
	
	# Check if already loaded
	if model_name in _loaded_models:
		var model_data = _loaded_models[model_name]
		if lod_level in model_data.instances:
			callback.call(model_data.instances[lod_level].duplicate())
			return
	
	# Add to loading queue with callback
	_loading_queue.append({
		"name": model_name,
		"lod": lod_level,
		"callback": callback
	})
	
	_process_loading_queue()

func load_all_brain_models() -> void:
	"""Load all available brain models"""
	var models_to_load = _scan_for_models()
	
	for model_name in models_to_load:
		_loading_queue.append({
			"name": model_name,
			"lod": _get_recommended_lod(),
			"callback": null
		})
	
	_process_loading_queue()

func get_loaded_model(model_name: String, lod_level: int = -1) -> Node3D:
	"""Get an already loaded model instance"""
	if not model_name in _loaded_models:
		return null
	
	var model_data = _loaded_models[model_name]
	
	if lod_level == -1:
		lod_level = model_data.current_lod
	
	if lod_level in model_data.instances:
		return model_data.instances[lod_level]
	
	# Try fallback LODs
	for fallback in LOD_FALLBACKS[lod_level]:
		for check_lod in LODLevel.values():
			if check_lod in model_data.instances:
				return model_data.instances[check_lod]
	
	return null

func change_model_lod(model_name: String, new_lod: int) -> bool:
	"""Change LOD level for a loaded model"""
	if not model_name in _loaded_models:
		return false
	
	var model_data = _loaded_models[model_name]
	
	# Check if LOD exists
	if new_lod in model_data.instances:
		model_data.current_lod = new_lod
		lod_changed.emit(model_name, new_lod)
		return true
	
	# Try to load the LOD
	load_model_async(model_name, func(_model): 
		model_data.current_lod = new_lod
		lod_changed.emit(model_name, new_lod)
	, new_lod)
	
	return false

func unload_model(model_name: String, keep_cached: bool = true) -> void:
	"""Unload a model from memory"""
	if not model_name in _loaded_models:
		return
	
	var model_data = _loaded_models[model_name]
	
	# Free all LOD instances
	for lod in model_data.instances:
		var instance = model_data.instances[lod]
		if instance and is_instance_valid(instance):
			instance.queue_free()
	
	# Remove from loaded models
	_loaded_models.erase(model_name)
	
	# Optionally clear from cache
	if not keep_cached:
		_clear_model_from_cache(model_name)

func get_model_list() -> Array:
	"""Get list of all loaded models"""
	return _loaded_models.keys()

func get_model_metadata(model_name: String) -> Dictionary:
	"""Get metadata for a loaded model"""
	if model_name in _loaded_models:
		return _loaded_models[model_name].metadata
	return {}

# === PRIVATE METHODS ===

func _process_loading_queue() -> void:
	"""Process the model loading queue"""
	while _loading_queue.size() > 0 and _active_loads < max_concurrent_loads:
		var load_request = _loading_queue.pop_front()
		
		if use_threading:
			_load_model_threaded(load_request)
		else:
			_load_model_immediate(load_request)

func _load_model_immediate(load_request: Dictionary) -> void:
	"""Load a model immediately (blocking)"""
	var model_name = load_request.name
	var lod_level = load_request.lod
	var callback = load_request.callback
	
	var model_path = _find_model_path(model_name, lod_level)
	
	if model_path == "":
		model_load_failed.emit(model_name, "Model file not found")
		if callback:
			callback.call(null)
		return
	
	# Load the model
	var model_resource = _load_resource(model_path)
	
	if not model_resource:
		model_load_failed.emit(model_name, "Failed to load model resource")
		if callback:
			callback.call(null)
		return
	
	# Create instance
	var instance = _create_model_instance(model_resource, model_name)
	
	if instance:
		_register_loaded_model(model_name, instance, lod_level)
		model_loaded.emit(model_name, instance)
		
		if callback:
			callback.call(instance)
	else:
		model_load_failed.emit(model_name, "Failed to create model instance")
		if callback:
			callback.call(null)

func _load_model_threaded(load_request: Dictionary) -> void:
	"""Load a model using threading"""
	_active_loads += 1
	
	# Create thread for loading
	var thread = Thread.new()
	thread.start(_thread_load_model.bind(load_request, thread))

func _thread_load_model(load_request: Dictionary, thread: Thread) -> void:
	"""Thread function for loading models"""
	var model_name = load_request.name
	var lod_level = load_request.lod
	
	var model_path = _find_model_path(model_name, lod_level)
	
	if model_path != "":
		# Load in thread
		var model_resource = ResourceLoader.load(model_path)
		
		# Return to main thread for instance creation
		call_deferred("_finish_threaded_load", load_request, model_resource, thread)
	else:
		call_deferred("_finish_threaded_load", load_request, null, thread)

func _finish_threaded_load(load_request: Dictionary, model_resource: Resource, thread: Thread) -> void:
	"""Finish threaded load on main thread"""
	thread.wait_to_finish()
	
	_active_loads -= 1
	
	if model_resource:
		var instance = _create_model_instance(model_resource, load_request.name)
		
		if instance:
			_register_loaded_model(load_request.name, instance, load_request.lod)
			model_loaded.emit(load_request.name, instance)
			
			if load_request.callback:
				load_request.callback.call(instance)
		else:
			model_load_failed.emit(load_request.name, "Failed to create instance")
			if load_request.callback:
				load_request.callback.call(null)
	else:
		model_load_failed.emit(load_request.name, "Failed to load resource")
		if load_request.callback:
			load_request.callback.call(null)
	
	# Continue processing queue
	_process_loading_queue()
	
	# Check if all done
	if _loading_queue.size() == 0 and _active_loads == 0:
		all_models_loaded.emit()

func _create_model_instance(model_resource: Resource, model_name: String) -> Node3D:
	"""Create an instance from a model resource"""
	if not model_resource:
		return null
	
	var instance: Node3D = null
	
	if model_resource is PackedScene:
		instance = model_resource.instantiate()
	elif model_resource is ArrayMesh:
		instance = MeshInstance3D.new()
		instance.mesh = model_resource
	else:
		push_error("[ModelLoader] Unknown resource type for model: " + model_name)
		return null
	
	# Set metadata
	instance.set_meta("model_name", model_name)
	instance.set_meta("structure_name", _clean_model_name(model_name))
	
	# Setup collision if needed
	_setup_model_collision(instance)
	
	return instance

func _setup_model_collision(model_instance: Node3D) -> void:
	"""Setup collision for model selection"""
	# Find all MeshInstance3D nodes
	var meshes = _find_all_meshes(model_instance)
	
	for mesh in meshes:
		# Skip if already has collision
		if mesh.get_child_count() > 0:
			for child in mesh.get_children():
				if child is StaticBody3D:
					continue
		
		# Add collision
		var static_body = StaticBody3D.new()
		mesh.add_child(static_body)
		
		# Create trimesh collision from mesh
		if mesh.mesh:
			mesh.create_trimesh_collision()
			
			# Move collision shape to static body
			for child in mesh.get_children():
				if child is StaticBody3D and child != static_body:
					for shape_child in child.get_children():
						if shape_child is CollisionShape3D:
							# Clear owner before moving to avoid warnings
							shape_child.owner = null
							child.remove_child(shape_child)
							static_body.add_child(shape_child)
							# Set new owner after adding
							shape_child.owner = model_instance
					child.queue_free()

func _find_all_meshes(node: Node3D) -> Array:
	"""Recursively find all MeshInstance3D nodes"""
	var meshes = []
	
	if node is MeshInstance3D:
		meshes.append(node)
	
	for child in node.get_children():
		if child is Node3D:
			meshes.append_array(_find_all_meshes(child))
	
	return meshes

func _register_loaded_model(model_name: String, instance: Node3D, lod_level: int) -> void:
	"""Register a loaded model in the system"""
	if not model_name in _loaded_models:
		_loaded_models[model_name] = ModelData.new()
		_loaded_models[model_name].name = model_name
	
	var model_data = _loaded_models[model_name]
	model_data.instances[lod_level] = instance
	model_data.current_lod = lod_level
	
	# Calculate bounding box
	model_data.bounding_box = _calculate_bounding_box(instance)
	
	# Store metadata
	model_data.metadata = {
		"lod_level": lod_level,
		"vertex_count": _count_vertices(instance),
		"material_count": _count_materials(instance),
		"has_collision": true
	}

func _calculate_bounding_box(node: Node3D) -> AABB:
	"""Calculate the bounding box of a model"""
	var aabb = AABB()
	var first = true
	
	var meshes = _find_all_meshes(node)
	
	for mesh in meshes:
		if mesh.mesh:
			var mesh_aabb = mesh.mesh.get_aabb()
			mesh_aabb = mesh.transform * mesh_aabb
			
			if first:
				aabb = mesh_aabb
				first = false
			else:
				aabb = aabb.merge(mesh_aabb)
	
	return aabb

func _count_vertices(node: Node3D) -> int:
	"""Count total vertices in a model"""
	var count = 0
	var meshes = _find_all_meshes(node)
	
	for mesh in meshes:
		if mesh.mesh:
			for i in range(mesh.mesh.get_surface_count()):
				var arrays = mesh.mesh.surface_get_arrays(i)
				if arrays.size() > Mesh.ARRAY_VERTEX:
					count += arrays[Mesh.ARRAY_VERTEX].size()
	
	return count

func _count_materials(node: Node3D) -> int:
	"""Count unique materials in a model"""
	var materials = {}
	var meshes = _find_all_meshes(node)
	
	for mesh in meshes:
		if mesh.mesh:
			for i in range(mesh.mesh.get_surface_count()):
				var mat = mesh.get_surface_override_material(i)
				if not mat:
					mat = mesh.mesh.surface_get_material(i)
				if mat:
					materials[mat] = true
	
	return materials.size()

func _find_model_path(model_name: String, lod_level: int) -> String:
	"""Find the path to a model file"""
	print("[ModelLoader] Looking for model: %s at LOD level: %d" % [model_name, lod_level])
	
	var lod_suffix = LOD_SUFFIXES.get(lod_level, "")
	
	# === NEW: Check model-specific subdirectory first ===
	# Try different folder naming conventions
	var folder_variations = [
		model_name + "_LOD",  # e.g., Internal-Structures_LOD
		model_name.replace("-", "_") + "_LOD",  # e.g., Internal_Structures_LOD
		model_name.replace("_", "-") + "_LOD",
		model_name.replace(" ", "_") + "_LOD",
		model_name.replace(" ", "-") + "_LOD"
	]
	
	for folder_name in folder_variations:
		var subfolder_path = PROCESSED_PATH + folder_name + "/"
		
		# Check if subfolder exists by trying to load a file from it
		# Try with full model name + suffix
		var path = subfolder_path + model_name + lod_suffix + ".glb"
		if ResourceLoader.exists(path):
			print("[ModelLoader] Found in subdirectory: " + path)
			return path
		
		# Try with just LOD suffix name (e.g., "low.glb", "high.glb")
		if lod_suffix != "":
			path = subfolder_path + lod_suffix.substr(1) + ".glb"  # Remove the underscore
			if ResourceLoader.exists(path):
				print("[ModelLoader] Found simplified name in subdirectory: " + path)
				return path
		
		# Try LOD fallbacks in subdirectory
		for suffix in LOD_FALLBACKS[lod_level]:
			path = subfolder_path + model_name + suffix + ".glb"
			if ResourceLoader.exists(path):
				print("[ModelLoader] Found fallback in subdirectory: " + path)
				return path
	
	# === ORIGINAL: Check flat processed directory ===
	var processed_path = PROCESSED_PATH + model_name + lod_suffix + ".glb"
	if ResourceLoader.exists(processed_path):
		print("[ModelLoader] Found processed LOD variant: " + processed_path)
		return processed_path
	
	# Try LOD fallbacks in processed directory
	for suffix in LOD_FALLBACKS[lod_level]:
		var path = PROCESSED_PATH + model_name + suffix + ".glb"
		if ResourceLoader.exists(path):
			print("[ModelLoader] Found processed model with fallback: " + path)
			return path
		
		# Try without suffix
		if suffix == "":
			path = PROCESSED_PATH + model_name + ".glb"
			if ResourceLoader.exists(path):
				print("[ModelLoader] Found processed model: " + path)
				return path
	
	# === FALLBACK: Try raw models ===
	var raw_path = RAW_PATH + model_name + ".glb"
	if ResourceLoader.exists(raw_path):
		print("[ModelLoader] WARNING: No LOD variant found, using raw model: " + raw_path)
		return raw_path
	
	# Try with different naming conventions in raw
	var variations = [
		model_name.replace(" ", "_"),
		model_name.replace("_", " "),
		model_name.replace("-", "_"),
		model_name.replace("_", "-"),
		model_name.to_lower(),
		model_name.to_upper()
	]
	
	for variant in variations:
		raw_path = RAW_PATH + variant + ".glb"
		if ResourceLoader.exists(raw_path):
			return raw_path
	
	print("[ModelLoader] ERROR: Could not find model: " + model_name)
	return ""

func _load_resource(path: String) -> Resource:
	"""Load a resource with caching"""
	if path in _model_cache:
		return _model_cache[path]
	
	var resource = ResourceLoader.load(path)
	
	if resource:
		_model_cache[path] = resource
	
	return resource

func _scan_for_models() -> Array:
	"""Scan directories for available models"""
	var models = []
	
	# Scan processed directory
	var dir = DirAccess.open(PROCESSED_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".glb") or file_name.ends_with(".gltf"):
				var model_name = file_name.get_basename()
				# Remove LOD suffixes
				for suffix in LOD_SUFFIXES.values():
					model_name = model_name.replace(suffix, "")
				
				if not model_name in models:
					models.append(model_name)
			
			file_name = dir.get_next()
	
	# Scan raw directory
	dir = DirAccess.open(RAW_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".glb") or file_name.ends_with(".gltf"):
				var model_name = file_name.get_basename()
				
				if not model_name in models:
					models.append(model_name)
			
			file_name = dir.get_next()
	
	return models

func _connect_to_performance_monitor() -> void:
	"""Connect to PerformanceMonitor after scene tree is ready"""
	# Check if we're in the scene tree
	if not is_inside_tree():
		return
		
	# Try to get PerformanceMonitor from autoloads
	var perf_monitor = get_node_or_null("/root/PerformanceMonitor")
	if perf_monitor and perf_monitor.has_signal("quality_level_changed"):
		perf_monitor.quality_level_changed.connect(_on_quality_level_changed)
		# Override with our detected quality
		if perf_monitor.has_method("set_quality_level"):
			perf_monitor.set_quality_level(_current_quality_level)
			print("[ModelLoader] Connected to PerformanceMonitor")

func _clean_model_name(model_name: String) -> String:
	"""Clean model name for display"""
	var clean_name = model_name
	
	# Remove common suffixes
	var suffixes_to_remove = ["_good", "_bad", "(good)", "(bad)", "_high", "_medium", "_low"]
	for suffix in suffixes_to_remove:
		clean_name = clean_name.replace(suffix, "")
	
	# Replace underscores with spaces
	clean_name = clean_name.replace("_", " ")
	
	# Capitalize properly
	clean_name = clean_name.capitalize()
	
	return clean_name.strip_edges()

func _get_recommended_lod() -> int:
	"""Get recommended LOD based on current quality settings"""
	match _current_quality_level:
		PerformanceMonitor.QualityLevel.LOW:
			return LODLevel.LOW
		PerformanceMonitor.QualityLevel.MEDIUM:
			return LODLevel.MEDIUM
		PerformanceMonitor.QualityLevel.HIGH, PerformanceMonitor.QualityLevel.ULTRA:
			return LODLevel.HIGH
		_:
			return LODLevel.MEDIUM

func _on_quality_level_changed(new_level: int) -> void:
	"""Handle quality level changes from PerformanceMonitor"""
	_current_quality_level = new_level
	
	if auto_adjust_lod:
		var new_lod = _get_recommended_lod()
		
		# Update all loaded models
		for model_name in _loaded_models:
			change_model_lod(model_name, new_lod)

func _clear_model_from_cache(model_name: String) -> void:
	"""Clear a model from the resource cache"""
	var keys_to_remove = []
	
	for path in _model_cache:
		if model_name in path:
			keys_to_remove.append(path)
	
	for key in keys_to_remove:
		_model_cache.erase(key)
