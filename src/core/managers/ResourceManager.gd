extends Node

## Centralized resource management for NeuroVision educational platform
## Handles shared resources, caching, and memory optimization

signal resource_loaded(resource_path: String, resource: Resource)
signal resource_unloaded(resource_path: String)
signal cache_cleared(category: String)

# === ENUMS ===

enum ResourceCategory {
	TEXTURES,
	MATERIALS,
	SHADERS,
	STYLES,
	SCENES,
	MODELS,
	AUDIO,
	FONTS
}

enum CachePolicy {
	PERMANENT,    # Never unload
	TEMPORARY,    # Unload when not in use
	SESSION      # Unload when scene changes
}

# === CONSTANTS ===

const MAX_CACHE_SIZE_MB: int = 256
const CLEANUP_INTERVAL: float = 30.0
const PRELOAD_ESSENTIAL: bool = true

# Resource categories and their file extensions
const CATEGORY_EXTENSIONS = {
	ResourceCategory.TEXTURES: [".png", ".jpg", ".jpeg", ".svg", ".tga"],
	ResourceCategory.MATERIALS: [".tres", ".res"],
	ResourceCategory.SHADERS: [".gdshader"],
	ResourceCategory.STYLES: [".tres", ".res"],
	ResourceCategory.SCENES: [".tscn"],
	ResourceCategory.MODELS: [".glb", ".gltf", ".obj", ".dae"],
	ResourceCategory.AUDIO: [".ogg", ".wav", ".mp3"],
	ResourceCategory.FONTS: [".ttf", ".otf", ".woff", ".woff2"]
}

# Essential resources that should always be cached
const ESSENTIAL_RESOURCES = {
	"glass_panel_material": "res://src/ui/resources/materials/GlassPanelMaterial.tres",
	"glass_panel_style": "res://src/ui/resources/styles/GlassPanelStyle.tres",
	"sidebar_panel_style": "res://src/ui/resources/styles/SidebarPanelStyle.tres",
	"bottom_panel_style": "res://src/ui/resources/styles/BottomPanelStyle.tres",
	"base_educational_scene": "res://src/scenes/templates/BaseEducationalScene.tscn"
}

# === PRIVATE VARIABLES ===

var _resource_cache: Dictionary = {}
var _cache_metadata: Dictionary = {}
var _reference_counts: Dictionary = {}
var _cache_size_bytes: int = 0
var _cleanup_timer: Timer

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[ResourceManager] Initializing centralized resource management")
	_setup_cleanup_timer()
	
	if PRELOAD_ESSENTIAL:
		_preload_essential_resources()

## Resource Loading Methods

func load_resource(resource_path: String, cache_policy: CachePolicy = CachePolicy.TEMPORARY) -> Resource:
	"""Load a resource with caching support"""
	# Check cache first
	if _resource_cache.has(resource_path):
		_increment_reference(resource_path)
		return _resource_cache[resource_path]
	
	# Load resource
	if not ResourceLoader.exists(resource_path):
		push_error("[ResourceManager] Resource not found: " + resource_path)
		return null
	
	var resource = ResourceLoader.load(resource_path)
	if resource == null:
		push_error("[ResourceManager] Failed to load resource: " + resource_path)
		return null
	
	# Cache the resource
	_cache_resource(resource_path, resource, cache_policy)
	
	resource_loaded.emit(resource_path, resource)
	return resource

func load_shared_style(style_name: String) -> StyleBox:
	"""Load a shared UI style resource"""
	var style_path = "res://src/ui/resources/styles/" + style_name + ".tres"
	return load_resource(style_path, CachePolicy.PERMANENT)

func load_shared_material(material_name: String) -> Material:
	"""Load a shared material resource"""
	var material_path = "res://src/ui/resources/materials/" + material_name + ".tres"
	return load_resource(material_path, CachePolicy.PERMANENT)

func preload_resources(resource_paths: Array[String], cache_policy: CachePolicy = CachePolicy.TEMPORARY) -> void:
	"""Preload multiple resources"""
	for path in resource_paths:
		load_resource(path, cache_policy)

## Resource Management Methods

func unload_resource(resource_path: String) -> void:
	"""Unload a resource from cache"""
	if not _resource_cache.has(resource_path):
		return
	
	_decrement_reference(resource_path)
	
	# Only actually unload if no references remain and not permanent
	var metadata = _cache_metadata.get(resource_path, {})
	if _reference_counts.get(resource_path, 0) <= 0 and metadata.get("cache_policy") != CachePolicy.PERMANENT:
		_remove_from_cache(resource_path)

func clear_cache_category(category: ResourceCategory) -> void:
	"""Clear all cached resources in a category"""
	var to_remove = []
	
	for resource_path in _resource_cache:
		var detected_category = _detect_resource_category(resource_path)
		if detected_category == category:
			var metadata = _cache_metadata.get(resource_path, {})
			if metadata.get("cache_policy") != CachePolicy.PERMANENT:
				to_remove.append(resource_path)
	
	for path in to_remove:
		_remove_from_cache(path)
	
	cache_cleared.emit(_get_category_name(category))

func clear_temporary_cache() -> void:
	"""Clear all temporary cached resources"""
	var to_remove = []
	
	for resource_path in _resource_cache:
		var metadata = _cache_metadata.get(resource_path, {})
		if metadata.get("cache_policy") == CachePolicy.TEMPORARY and _reference_counts.get(resource_path, 0) <= 0:
			to_remove.append(resource_path)
	
	for path in to_remove:
		_remove_from_cache(path)

func get_cache_stats() -> Dictionary:
	"""Get cache statistics"""
	var stats = {
		"total_resources": _resource_cache.size(),
		"cache_size_mb": _cache_size_bytes / 1024.0 / 1024.0,
		"categories": {}
	}
	
	# Count by category
	for category in ResourceCategory.values():
		stats.categories[_get_category_name(category)] = 0
	
	for resource_path in _resource_cache:
		var category = _detect_resource_category(resource_path)
		var category_name = _get_category_name(category)
		stats.categories[category_name] += 1
	
	return stats

func optimize_cache() -> void:
	"""Optimize cache by removing unused resources"""
	if _cache_size_bytes < MAX_CACHE_SIZE_MB * 1024 * 1024:
		return
	
	print("[ResourceManager] Cache size exceeded, optimizing...")
	
	# Remove unused temporary resources first
	clear_temporary_cache()
	
	# If still over limit, remove least recently used session resources
	if _cache_size_bytes >= MAX_CACHE_SIZE_MB * 1024 * 1024:
		_remove_lru_resources()

# === PRIVATE METHODS ===

func _setup_cleanup_timer() -> void:
	"""Setup periodic cache cleanup"""
	_cleanup_timer = Timer.new()
	_cleanup_timer.wait_time = CLEANUP_INTERVAL
	_cleanup_timer.autostart = true
	_cleanup_timer.timeout.connect(_periodic_cleanup)
	add_child(_cleanup_timer)

func _preload_essential_resources() -> void:
	"""Preload essential resources for the educational platform"""
	print("[ResourceManager] Preloading essential resources...")
	
	for resource_name in ESSENTIAL_RESOURCES:
		var resource_path = ESSENTIAL_RESOURCES[resource_name]
		load_resource(resource_path, CachePolicy.PERMANENT)

func _cache_resource(resource_path: String, resource: Resource, cache_policy: CachePolicy) -> void:
	"""Cache a resource with metadata"""
	_resource_cache[resource_path] = resource
	_cache_metadata[resource_path] = {
		"cache_policy": cache_policy,
		"loaded_at": Time.get_ticks_msec(),
		"last_accessed": Time.get_ticks_msec(),
		"category": _detect_resource_category(resource_path),
		"estimated_size": _estimate_resource_size(resource)
	}
	
	_reference_counts[resource_path] = 1
	_cache_size_bytes += _cache_metadata[resource_path].estimated_size

func _remove_from_cache(resource_path: String) -> void:
	"""Remove a resource from cache"""
	if not _resource_cache.has(resource_path):
		return
	
	var metadata = _cache_metadata.get(resource_path, {})
	_cache_size_bytes -= metadata.get("estimated_size", 0)
	
	_resource_cache.erase(resource_path)
	_cache_metadata.erase(resource_path)
	_reference_counts.erase(resource_path)
	
	resource_unloaded.emit(resource_path)

func _increment_reference(resource_path: String) -> void:
	"""Increment reference count and update access time"""
	_reference_counts[resource_path] = _reference_counts.get(resource_path, 0) + 1
	
	if _cache_metadata.has(resource_path):
		_cache_metadata[resource_path].last_accessed = Time.get_ticks_msec()

func _decrement_reference(resource_path: String) -> void:
	"""Decrement reference count"""
	var current_count = _reference_counts.get(resource_path, 0)
	_reference_counts[resource_path] = max(0, current_count - 1)

func _detect_resource_category(resource_path: String) -> ResourceCategory:
	"""Detect resource category from file extension"""
	var extension = resource_path.get_extension().to_lower()
	
	for category in CATEGORY_EXTENSIONS:
		if extension in CATEGORY_EXTENSIONS[category]:
			return category
	
	return ResourceCategory.TEXTURES  # Default

func _estimate_resource_size(resource: Resource) -> int:
	"""Estimate resource memory size in bytes"""
	if resource is Texture2D:
		var texture = resource as Texture2D
		return texture.get_width() * texture.get_height() * 4  # RGBA
	elif resource is PackedScene:
		return 50000  # Estimate for scenes
	elif resource is Material:
		return 5000   # Estimate for materials
	elif resource is StyleBox:
		return 1000   # Estimate for styles
	else:
		return 10000  # Default estimate

func _get_category_name(category: ResourceCategory) -> String:
	"""Get category name as string"""
	match category:
		ResourceCategory.TEXTURES:
			return "Textures"
		ResourceCategory.MATERIALS:
			return "Materials"
		ResourceCategory.SHADERS:
			return "Shaders"
		ResourceCategory.STYLES:
			return "Styles"
		ResourceCategory.SCENES:
			return "Scenes"
		ResourceCategory.MODELS:
			return "Models"
		ResourceCategory.AUDIO:
			return "Audio"
		ResourceCategory.FONTS:
			return "Fonts"
		_:
			return "Unknown"

func _periodic_cleanup() -> void:
	"""Periodic cache cleanup"""
	clear_temporary_cache()
	
	# Optimize if cache is getting large
	if _cache_size_bytes > MAX_CACHE_SIZE_MB * 1024 * 1024 * 0.8:  # 80% of limit
		optimize_cache()

func _remove_lru_resources() -> void:
	"""Remove least recently used resources"""
	var lru_candidates = []
	
	# Collect session resources sorted by last access time
	for resource_path in _resource_cache:
		var metadata = _cache_metadata.get(resource_path, {})
		if metadata.get("cache_policy") == CachePolicy.SESSION and _reference_counts.get(resource_path, 0) <= 0:
			lru_candidates.append({
				"path": resource_path,
				"last_accessed": metadata.get("last_accessed", 0)
			})
	
	# Sort by access time (oldest first)
	lru_candidates.sort_custom(func(a, b): return a.last_accessed < b.last_accessed)
	
	# Remove oldest resources until under limit
	var target_size = MAX_CACHE_SIZE_MB * 1024 * 1024 * 0.7  # 70% of limit
	for candidate in lru_candidates:
		if _cache_size_bytes <= target_size:
			break
		_remove_from_cache(candidate.path)