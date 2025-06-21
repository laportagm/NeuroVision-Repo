extends Node
class_name SafeModelLoader

## Safe model loading with error handling for the NeuroVision educational platform
##
## This class provides robust model loading with fallback options and clear
## error reporting to ensure the educational experience is not interrupted
## by missing or corrupted model files.

signal model_loaded(model_instance: Node3D)
signal model_load_failed(error_message: String)
signal loading_progress(progress: float)

# Model loading options
enum LoadMode {
	BLOCKING,     # Load immediately, blocking the thread
	ASYNC,        # Load asynchronously with callbacks
	BACKGROUND    # Load in background thread
}

# === PRIVATE VARIABLES ===
var _model_cache: Dictionary = {}
var _loading_thread: Thread = null
var _is_loading: bool = false

# === PUBLIC METHODS ===

func load_brain_model(model_name: String = "Internal-Structures", lod: String = "low", mode: LoadMode = LoadMode.BLOCKING) -> Node3D:
	"""Load a brain model with error handling and fallback options"""
	
	# Check cache first
	var cache_key = "%s_%s" % [model_name, lod]
	if cache_key in _model_cache:
		var cached_model = _model_cache[cache_key]
		if is_instance_valid(cached_model):
			model_loaded.emit(cached_model.duplicate())
			return cached_model.duplicate()
	
	# Get model path
	var model_path = ModelPaths.get_model_path(model_name, lod)
	
	match mode:
		LoadMode.BLOCKING:
			return _load_model_blocking(model_path, cache_key)
		LoadMode.ASYNC:
			_load_model_async(model_path, cache_key)
			return null
		LoadMode.BACKGROUND:
			_load_model_background(model_path, cache_key)
			return null
	
	return null

func _load_model_blocking(path: String, cache_key: String) -> Node3D:
	"""Load a model synchronously with error handling"""
	
	if not ResourceLoader.exists(path):
		var error_msg = "Model file not found: %s" % path
		push_error("[SafeModelLoader] " + error_msg)
		model_load_failed.emit(error_msg)
		
		# Try fallback paths
		var fallback = _try_fallback_paths(path)
		if fallback:
			path = fallback
		else:
			return _create_error_placeholder("Model not found")
	
	loading_progress.emit(0.0)
	
	# Load the resource
	var resource = ResourceLoader.load(path)
	loading_progress.emit(0.5)
	
	if not resource:
		var error_msg = "Failed to load model resource: %s" % path
		push_error("[SafeModelLoader] " + error_msg)
		model_load_failed.emit(error_msg)
		return _create_error_placeholder("Failed to load")
	
	# Create instance
	var instance = _create_instance_from_resource(resource)
	loading_progress.emit(0.9)
	
	if not instance:
		var error_msg = "Failed to instantiate model: %s" % path
		push_error("[SafeModelLoader] " + error_msg)
		model_load_failed.emit(error_msg)
		return _create_error_placeholder("Instantiation failed")
	
	# Cache the model
	_model_cache[cache_key] = instance
	
	loading_progress.emit(1.0)
	model_loaded.emit(instance)
	
	print("[SafeModelLoader] Successfully loaded model: %s" % path)
	return instance

func _load_model_background(path: String, cache_key: String) -> void:
	"""Load a model in background thread"""
	# For now, use async loading as background
	_load_model_async(path, cache_key)

func _load_model_async(path: String, cache_key: String) -> void:
	"""Load a model asynchronously"""
	
	if _is_loading:
		push_warning("[SafeModelLoader] Already loading a model, please wait")
		return
	
	_is_loading = true
	
	# Use Godot's threaded loading
	if not ResourceLoader.exists(path):
		_is_loading = false
		model_load_failed.emit("Model file not found: %s" % path)
		return
	
	ResourceLoader.load_threaded_request(path)
	_monitor_async_load(path, cache_key)

func _monitor_async_load(path: String, cache_key: String) -> void:
	"""Monitor asynchronous loading progress"""
	
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(path, progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if progress.size() > 0:
				loading_progress.emit(progress[0])
			# Check again next frame
			await get_tree().process_frame
			_monitor_async_load(path, cache_key)
			
		ResourceLoader.THREAD_LOAD_LOADED:
			var resource = ResourceLoader.load_threaded_get(path)
			var instance = _create_instance_from_resource(resource)
			if instance:
				_model_cache[cache_key] = instance
				model_loaded.emit(instance)
			else:
				model_load_failed.emit("Failed to instantiate model")
			_is_loading = false
			
		ResourceLoader.THREAD_LOAD_FAILED:
			model_load_failed.emit("Threaded loading failed for: %s" % path)
			_is_loading = false
			
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			model_load_failed.emit("Invalid resource: %s" % path)
			_is_loading = false

func _create_instance_from_resource(resource: Resource) -> Node3D:
	"""Create a Node3D instance from a loaded resource"""
	
	if resource is PackedScene:
		var scene = resource as PackedScene
		return scene.instantiate()
	
	elif resource is ArrayMesh:
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = resource
		return mesh_instance
	
	else:
		push_error("[SafeModelLoader] Unknown resource type: %s" % resource.get_class())
		return null

func _create_error_placeholder(error_text: String) -> Node3D:
	"""Create a placeholder model when loading fails"""
	
	var placeholder = Node3D.new()
	placeholder.name = "ErrorPlaceholder"
	
	# Create a simple box mesh as placeholder
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(2, 2, 2)
	mesh_instance.mesh = box_mesh
	
	# Add error material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.2, 0.2, 0.5)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.material_override = material
	
	# Add error label
	var label_3d = Label3D.new()
	label_3d.text = error_text
	label_3d.position = Vector3(0, 1.5, 0)
	label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	placeholder.add_child(mesh_instance)
	placeholder.add_child(label_3d)
	
	return placeholder

func _try_fallback_paths(original_path: String) -> String:
	"""Try alternative paths when the original fails"""
	
	# Try different file extensions
	var base_path = original_path.get_basename()
	var alternatives = [
		base_path + ".gltf",
		base_path + ".glb",
		base_path + ".tscn",
		base_path + ".res"
	]
	
	for alt_path in alternatives:
		if ResourceLoader.exists(alt_path):
			print("[SafeModelLoader] Using fallback path: %s" % alt_path)
			return alt_path
	
	# Try the default brain model
	var default_path = ModelPaths.get_default_brain_model()
	if ResourceLoader.exists(default_path) and default_path != original_path:
		print("[SafeModelLoader] Using default brain model as fallback")
		return default_path
	
	return ""

func clear_cache() -> void:
	"""Clear the model cache to free memory"""
	
	for key in _model_cache:
		var model = _model_cache[key]
		if is_instance_valid(model):
			model.queue_free()
	
	_model_cache.clear()
	print("[SafeModelLoader] Model cache cleared")

func _exit_tree() -> void:
	"""Clean up when exiting the tree"""
	clear_cache()
	
	if _loading_thread and _loading_thread.is_started():
		_loading_thread.wait_to_finish()