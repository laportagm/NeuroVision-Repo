extends Node
class_name SafeResourceLoader

## Utility class for safe resource loading with validation
##
## This class provides methods to safely load resources with proper error handling
## and validation to prevent runtime errors from missing resources.

# === STATIC METHODS ===

static func safe_preload(path: String, fallback: Resource = null) -> Resource:
	## Safely preload a resource with error handling
	if not ResourceLoader.exists(path):
		push_error("[SafeResourceLoader] Resource not found: " + path)
		return fallback
	
	var resource = load(path)
	if resource == null:
		push_error("[SafeResourceLoader] Failed to load resource: " + path)
		return fallback
	
	return resource

static func safe_load_script(path: String) -> GDScript:
	## Safely load a GDScript file
	if not ResourceLoader.exists(path):
		push_error("[SafeResourceLoader] Script not found: " + path)
		return null
	
	var script = load(path) as GDScript
	if script == null:
		push_error("[SafeResourceLoader] Failed to load script or not a GDScript: " + path)
		return null
	
	return script

static func safe_load_scene(path: String) -> PackedScene:
	## Safely load a PackedScene
	if not ResourceLoader.exists(path):
		push_error("[SafeResourceLoader] Scene not found: " + path)
		return null
	
	var scene = load(path) as PackedScene
	if scene == null:
		push_error("[SafeResourceLoader] Failed to load scene or not a PackedScene: " + path)
		return null
	
	return scene

static func safe_load_shader(path: String) -> Shader:
	## Safely load a shader resource
	if not ResourceLoader.exists(path):
		push_error("[SafeResourceLoader] Shader not found: " + path)
		return null
	
	var shader = load(path) as Shader
	if shader == null:
		push_error("[SafeResourceLoader] Failed to load shader: " + path)
		return null
	
	return shader

static func validate_resource_paths(paths: Array) -> Dictionary:
	## Validate multiple resource paths and return status
	var result = {
		"valid": [],
		"missing": [],
		"total": paths.size()
	}
	
	for path in paths:
		if ResourceLoader.exists(path):
			result.valid.append(path)
		else:
			result.missing.append(path)
	
	return result

static func try_load_first_available(paths: Array) -> Resource:
	## Try to load the first available resource from a list of paths
	for path in paths:
		if ResourceLoader.exists(path):
			var resource = load(path)
			if resource != null:
				return resource
	
	push_error("[SafeResourceLoader] No valid resource found in paths: " + str(paths))
	return null