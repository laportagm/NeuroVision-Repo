extends Node
class_name MemoryManager

## Utility class for memory management and cleanup
##
## This class provides static methods to help prevent memory leaks by properly
## managing object lifecycles and providing cleanup utilities.

# === STATIC METHODS ===

static func safe_free(object: Object) -> void:
	## Safely free an object with validation
	if is_instance_valid(object):
		if object is Node and object.is_inside_tree():
			object.queue_free()
		else:
			object.free()

static func safe_free_children(node: Node) -> void:
	## Safely free all children of a node
	if not is_instance_valid(node):
		return
		
	for child in node.get_children():
		safe_free_children(child)  # Recursive cleanup
		safe_free(child)

static func disconnect_all_signals(object: Object) -> void:
	## Disconnect all signals from an object to prevent leaked connections
	if not is_instance_valid(object):
		return
		
	for sig in object.get_signal_list():
		for connection in object.get_signal_connection_list(sig.name):
			object.disconnect(sig.name, connection.callable)

static func cleanup_node(node: Node) -> void:
	## Comprehensive cleanup for a node and its children
	if not is_instance_valid(node):
		return
		
	# Stop all processing
	node.set_process(false)
	node.set_physics_process(false)
	node.set_process_input(false)
	node.set_process_unhandled_input(false)
	
	# Clear all timers
	for child in node.get_children():
		if child is Timer:
			child.stop()
			child.queue_free()
	
	# Disconnect all signals
	disconnect_all_signals(node)
	
	# Cleanup children recursively
	safe_free_children(node)

static func cleanup_material(material: Material) -> void:
	## Cleanup material resources
	if not is_instance_valid(material):
		return
		
	# Clear shader parameters that might hold references
	if material is ShaderMaterial:
		var shader_material = material as ShaderMaterial
		# Clear texture references
		for param in shader_material.get_property_list():
			if param.type == TYPE_OBJECT:
				shader_material.set_shader_parameter(param.name, null)

static func cleanup_mesh_instance(mesh_instance: MeshInstance3D) -> void:
	## Cleanup mesh instance and its materials
	if not is_instance_valid(mesh_instance):
		return
		
	# Clear material overrides
	for i in range(mesh_instance.get_surface_override_material_count()):
		mesh_instance.set_surface_override_material(i, null)
	
	# Clear mesh reference
	mesh_instance.mesh = null

static func create_auto_freed_timer(duration: float, callback: Callable) -> Timer:
	## Create a timer that automatically frees itself after timeout
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(callback)
	timer.timeout.connect(timer.queue_free)
	return timer

static func track_object_creation(object: Object, owner_name: String = "") -> void:
	## Debug helper to track object creation
	if OS.is_debug_build():
		var type_name = object.get_class()
		var owner_info = " (owned by " + owner_name + ")" if owner_name else ""
		print("[MemoryManager] Created: " + type_name + owner_info + " at " + str(Time.get_ticks_msec()))

static func track_object_deletion(object: Object, owner_name: String = "") -> void:
	## Debug helper to track object deletion
	if OS.is_debug_build():
		var type_name = object.get_class() if is_instance_valid(object) else "InvalidObject"
		var owner_info = " (owned by " + owner_name + ")" if owner_name else ""
		print("[MemoryManager] Freed: " + type_name + owner_info + " at " + str(Time.get_ticks_msec()))

static func get_memory_usage_mb() -> float:
	## Get current memory usage in megabytes
	return OS.get_static_memory_usage() / 1048576.0