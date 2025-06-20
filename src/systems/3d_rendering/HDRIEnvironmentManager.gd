## HDRI Environment Manager for NeuroVision
##
## Manages high dynamic range image (HDRI) environments for realistic
## reflections and ambient lighting in medical brain visualization.

class_name HDRIEnvironmentManager
extends Node

# === SIGNALS ===
signal environment_changed(environment_name: String)
signal hdri_loaded(environment_name: String, success: bool)
signal reflection_quality_changed(quality: String)

# === CONSTANTS ===
const HDRI_ENVIRONMENTS = {
	"medical_lab": {
		"path": "res://assets/hdri/medical_lab.hdr",
		"description": "Clinical laboratory environment with neutral lighting",
		"intensity": 0.8,
		"rotation": 0.0,
		"suitable_for": ["examination", "surgical", "pathology"]
	},
	"anatomy_room": {
		"path": "res://assets/hdri/anatomy_room.hdr", 
		"description": "Anatomy classroom with educational lighting",
		"intensity": 0.6,
		"rotation": 45.0,
		"suitable_for": ["anatomical", "research"]
	},
	"neutral_studio": {
		"path": "res://assets/hdri/neutral_studio.hdr",
		"description": "Neutral studio environment for accurate color reproduction",
		"intensity": 0.7,
		"rotation": 0.0,
		"suitable_for": ["research", "pathology"]
	},
	"soft_ambient": {
		"path": "res://assets/hdri/soft_ambient.hdr",
		"description": "Soft ambient lighting for comfortable viewing",
		"intensity": 0.5,
		"rotation": 0.0,
		"suitable_for": ["anatomical", "examination"]
	}
}

const REFLECTION_QUALITY_LEVELS = ["low", "medium", "high", "maximum"]
const FALLBACK_ENVIRONMENT_COLOR = Color(0.1, 0.1, 0.15, 1.0)

# === EXPORTS ===
@export_group("Environment Settings")
@export var current_environment: String = "medical_lab"
@export var reflection_quality: String = "high"
@export var auto_select_environment: bool = true
@export var enable_reflections: bool = true

@export_group("Performance Settings")
@export var adaptive_quality: bool = true
@export var max_reflection_bounces: int = 3
@export var ssr_enabled: bool = true
@export var sdfgi_enabled: bool = false

@export_group("Visual Settings")
@export var environment_intensity: float = 1.0
@export var reflection_intensity: float = 1.0
@export var background_mode: String = "color"  # "hdri", "color", "gradient"

# === PRIVATE VARIABLES ===
var environment_resource: Environment
var world_environment: WorldEnvironment
var hdri_cache: Dictionary = {}
var current_hdri_texture: Texture2D
var performance_monitor = null
var lighting_manager: MedicalGradeLightingManager

# Performance tracking
var reflection_performance_samples: Array[float] = []
var quality_adjustment_timer: float = 0.0

# === INITIALIZATION ===

func _ready():
	_initialize_environment_system()
	_connect_to_systems()
	_load_initial_environment()
	print("[HDRIEnvironment] HDRI environment manager initialized")

func _initialize_environment_system():
	"""Initialize the environment system"""
	# Create environment resource
	environment_resource = Environment.new()
	_configure_base_environment()
	
	# Create WorldEnvironment node if not present
	world_environment = get_viewport().get_camera_3d().get_parent().get_node_or_null("WorldEnvironment")
	if not world_environment:
		world_environment = WorldEnvironment.new()
		world_environment.name = "WorldEnvironment"
		get_viewport().get_camera_3d().get_parent().add_child(world_environment)
	
	world_environment.environment = environment_resource

func _configure_base_environment():
	"""Configure base environment settings"""
	# Background settings
	environment_resource.background_mode = Environment.BG_COLOR
	environment_resource.background_color = FALLBACK_ENVIRONMENT_COLOR
	
	# Ambient lighting
	environment_resource.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment_resource.ambient_light_color = Color(0.3, 0.3, 0.35, 1.0)
	environment_resource.ambient_light_energy = 0.2
	
	# Reflection settings
	if enable_reflections:
		_configure_reflections()
	
	# Screen-space reflections
	if ssr_enabled:
		_configure_ssr()
	
	# Global illumination
	if sdfgi_enabled:
		_configure_sdfgi()

func _configure_reflections():
	"""Configure reflection probe settings"""
	environment_resource.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	
	match reflection_quality:
		"maximum":
			environment_resource.ssr_enabled = true
			environment_resource.ssr_max_steps = 64
			environment_resource.ssr_fade_in = 0.15
			environment_resource.ssr_fade_out = 2.0
			environment_resource.ssr_depth_tolerance = 0.2
		"high":
			environment_resource.ssr_enabled = true
			environment_resource.ssr_max_steps = 32
			environment_resource.ssr_fade_in = 0.2
			environment_resource.ssr_fade_out = 1.5
			environment_resource.ssr_depth_tolerance = 0.3
		"medium":
			environment_resource.ssr_enabled = true
			environment_resource.ssr_max_steps = 16
			environment_resource.ssr_fade_in = 0.3
			environment_resource.ssr_fade_out = 1.0
			environment_resource.ssr_depth_tolerance = 0.5
		"low":
			environment_resource.ssr_enabled = false

func _configure_ssr():
	"""Configure screen-space reflections"""
	environment_resource.ssr_enabled = ssr_enabled
	if ssr_enabled:
		environment_resource.ssr_max_steps = 32
		environment_resource.ssr_fade_in = 0.15
		environment_resource.ssr_fade_out = 2.0
		environment_resource.ssr_depth_tolerance = 0.2

func _configure_sdfgi():
	"""Configure signed distance field global illumination"""
	environment_resource.sdfgi_enabled = sdfgi_enabled
	if sdfgi_enabled:
		environment_resource.sdfgi_use_occlusion = true
		environment_resource.sdfgi_read_sky_light = true
		environment_resource.sdfgi_bounce_feedback = 0.5
		environment_resource.sdfgi_normal_bias = 1.1
		environment_resource.sdfgi_probe_bias = 1.1

func _connect_to_systems():
	"""Connect to other rendering systems"""
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root.has_node("UIThemeManager"):
		performance_monitor = tree.root.get_node("UIThemeManager")
		print("[HDRIEnvironment] Connected to performance monitoring")
	
	# Try to find lighting manager
	lighting_manager = get_node_or_null("../MedicalGradeLightingManager")
	if lighting_manager:
		print("[HDRIEnvironment] Connected to lighting manager")

func _load_initial_environment():
	"""Load the initial HDRI environment"""
	if auto_select_environment:
		_auto_select_environment_for_preset("examination")
	else:
		load_hdri_environment(current_environment)

# === HDRI ENVIRONMENT MANAGEMENT ===

func load_hdri_environment(environment_name: String):
	"""Load an HDRI environment by name"""
	if not environment_name in HDRI_ENVIRONMENTS:
		push_error("[HDRIEnvironment] Unknown environment: " + environment_name)
		_load_fallback_environment()
		return
	
	current_environment = environment_name
	var env_data = HDRI_ENVIRONMENTS[environment_name]
	
	print("[HDRIEnvironment] Loading environment: %s - %s" % [environment_name, env_data.description])
	
	# Check cache first
	if environment_name in hdri_cache:
		_apply_cached_hdri(environment_name)
		return
	
	# Load HDRI texture asynchronously
	_load_hdri_texture_async(environment_name, env_data)

func _load_hdri_texture_async(environment_name: String, env_data: Dictionary):
	"""Load HDRI texture asynchronously"""
	var hdri_path = env_data.path
	
	# Check if file exists
	if not FileAccess.file_exists(hdri_path):
		# Use procedural environment as fallback when HDRI is missing
		print("[HDRIEnvironment] HDRI not found, using procedural fallback for: " + environment_name)
		_create_procedural_environment(environment_name, env_data)
		return
	
	# Load texture
	var texture = load(hdri_path) as Texture2D
	if texture:
		hdri_cache[environment_name] = {
			"texture": texture,
			"data": env_data
		}
		_apply_hdri_environment(environment_name, texture, env_data)
		hdri_loaded.emit(environment_name, true)
	else:
		push_error("[HDRIEnvironment] Failed to load HDRI: " + hdri_path)
		_create_procedural_environment(environment_name, env_data)
		hdri_loaded.emit(environment_name, false)

func _apply_cached_hdri(environment_name: String):
	"""Apply cached HDRI environment"""
	var cached = hdri_cache[environment_name]
	_apply_hdri_environment(environment_name, cached.texture, cached.data)

func _apply_hdri_environment(environment_name: String, texture: Texture2D, env_data: Dictionary):
	"""Apply HDRI environment to the scene"""
	current_hdri_texture = texture
	
	# Configure background
	match background_mode:
		"hdri":
			environment_resource.background_mode = Environment.BG_SKY
			environment_resource.sky = Sky.new()
			var sky_material = PanoramaSkyMaterial.new()
			sky_material.panorama = texture
			environment_resource.sky.sky_material = sky_material
		"color":
			environment_resource.background_mode = Environment.BG_COLOR
			environment_resource.background_color = FALLBACK_ENVIRONMENT_COLOR
		"gradient":
			environment_resource.background_mode = Environment.BG_COLOR
			environment_resource.background_color = FALLBACK_ENVIRONMENT_COLOR
	
	# Configure ambient lighting from HDRI
	environment_resource.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment_resource.ambient_light_energy = env_data.intensity * environment_intensity * 0.3
	
	# Configure reflections from HDRI
	if enable_reflections:
		environment_resource.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
		# Apply rotation
		if abs(env_data.rotation) > 0.1:
			# Note: Godot doesn't have direct sky rotation, so we'd need custom shader
			pass
	
	print("[HDRIEnvironment] Applied HDRI environment: " + environment_name)
	environment_changed.emit(environment_name)

func _create_procedural_environment(environment_name: String, env_data: Dictionary):
	"""Create procedural environment when HDRI is not available"""
	print("[HDRIEnvironment] Creating procedural environment for: " + environment_name)
	
	# Create procedural sky
	environment_resource.background_mode = Environment.BG_SKY
	environment_resource.sky = Sky.new()
	var sky_material = ProceduralSkyMaterial.new()
	
	# Configure sky based on environment type
	match environment_name:
		"medical_lab":
			sky_material.sky_top_color = Color(0.9, 0.95, 1.0)
			sky_material.sky_horizon_color = Color(0.8, 0.85, 0.9)
			sky_material.ground_bottom_color = Color(0.6, 0.65, 0.7)
			sky_material.sun_angle_max = 30.0
		"anatomy_room":
			sky_material.sky_top_color = Color(0.95, 0.9, 0.85)
			sky_material.sky_horizon_color = Color(0.85, 0.8, 0.75)
			sky_material.ground_bottom_color = Color(0.7, 0.65, 0.6)
			sky_material.sun_angle_max = 45.0
		_:
			# Default neutral sky
			sky_material.sky_top_color = Color(0.9, 0.9, 0.9)
			sky_material.sky_horizon_color = Color(0.8, 0.8, 0.8)
			sky_material.ground_bottom_color = Color(0.6, 0.6, 0.6)
	
	environment_resource.sky.sky_material = sky_material
	
	# Set ambient lighting
	environment_resource.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment_resource.ambient_light_energy = env_data.intensity * environment_intensity * 0.4
	
	environment_changed.emit(environment_name)

func _load_fallback_environment():
	"""Load fallback color environment"""
	print("[HDRIEnvironment] Loading fallback environment")
	environment_resource.background_mode = Environment.BG_COLOR
	environment_resource.background_color = FALLBACK_ENVIRONMENT_COLOR
	environment_resource.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment_resource.ambient_light_color = Color(0.3, 0.3, 0.35)
	environment_resource.ambient_light_energy = 0.2

# === AUTO-SELECTION AND INTEGRATION ===

func _auto_select_environment_for_preset(lighting_preset: String):
	"""Automatically select appropriate HDRI environment for lighting preset"""
	var best_environment = "medical_lab"  # Default
	
	# Find best matching environment
	for env_name in HDRI_ENVIRONMENTS:
		var env_data = HDRI_ENVIRONMENTS[env_name]
		if lighting_preset in env_data.suitable_for:
			best_environment = env_name
			break
	
	if best_environment != current_environment:
		load_hdri_environment(best_environment)

func sync_with_lighting_preset(preset_name: String):
	"""Sync HDRI environment with lighting manager preset"""
	if auto_select_environment:
		_auto_select_environment_for_preset(preset_name)

# === PERFORMANCE MONITORING ===

func _process(delta):
	"""Monitor reflection performance and adjust quality if needed"""
	if not adaptive_quality:
		return
	
	quality_adjustment_timer += delta
	if quality_adjustment_timer < 2.0:  # Check every 2 seconds
		return
	
	quality_adjustment_timer = 0.0
	
	# Simple performance check based on FPS
	var current_fps = Engine.get_frames_per_second()
	reflection_performance_samples.append(current_fps)
	
	if reflection_performance_samples.size() > 5:
		reflection_performance_samples.pop_front()
	
	# Calculate average FPS
	var avg_fps = 0.0
	for fps in reflection_performance_samples:
		avg_fps += fps
	avg_fps /= reflection_performance_samples.size()
	
	# Adjust reflection quality based on performance
	_adjust_reflection_quality_for_performance(avg_fps)

func _adjust_reflection_quality_for_performance(avg_fps: float):
	"""Adjust reflection quality based on performance"""
	var target_fps = 60.0
	var target_quality = reflection_quality
	var current_index = REFLECTION_QUALITY_LEVELS.find(reflection_quality)
	
	if avg_fps < target_fps * 0.7:  # Below 70% of target
		# Reduce quality
		if current_index > 0:
			target_quality = REFLECTION_QUALITY_LEVELS[current_index - 1]
	elif avg_fps > target_fps * 0.9:  # Above 90% of target
		# Increase quality
		if current_index < REFLECTION_QUALITY_LEVELS.size() - 1:
			target_quality = REFLECTION_QUALITY_LEVELS[current_index + 1]
	
	if target_quality != reflection_quality:
		set_reflection_quality(target_quality)

# === PUBLIC API ===

func set_reflection_quality(quality: String):
	"""Set reflection quality level"""
	if quality not in REFLECTION_QUALITY_LEVELS:
		push_error("[HDRIEnvironment] Invalid reflection quality: " + quality)
		return
	
	if quality == reflection_quality:
		return
	
	var old_quality = reflection_quality
	reflection_quality = quality
	
	_configure_reflections()
	
	reflection_quality_changed.emit(quality)
	print("[HDRIEnvironment] Reflection quality changed: %s -> %s" % [old_quality, quality])

func set_environment_intensity(intensity: float):
	"""Set environment lighting intensity"""
	environment_intensity = clamp(intensity, 0.0, 3.0)
	
	# Reapply current environment with new intensity
	if current_environment in HDRI_ENVIRONMENTS:
		var env_data = HDRI_ENVIRONMENTS[current_environment]
		environment_resource.ambient_light_energy = env_data.intensity * environment_intensity * 0.3

func set_reflection_intensity(intensity: float):
	"""Set reflection intensity"""
	reflection_intensity = clamp(intensity, 0.0, 2.0)
	
	# Apply reflection intensity (would need custom shader for full control)
	if environment_resource.sky and environment_resource.sky.sky_material:
		# This is a simplified approach - full implementation would require shader modifications
		pass

func set_background_mode(mode: String):
	"""Set background display mode"""
	if mode in ["hdri", "color", "gradient"]:
		background_mode = mode
		# Reapply current environment with new background mode
		if current_environment in HDRI_ENVIRONMENTS:
			load_hdri_environment(current_environment)

func get_available_environments() -> Array:
	"""Get list of available HDRI environments"""
	return HDRI_ENVIRONMENTS.keys()

func get_environment_description(environment_name: String) -> String:
	"""Get description of an HDRI environment"""
	var env_data = HDRI_ENVIRONMENTS.get(environment_name, {})
	return env_data.get("description", "Unknown environment")

func get_suitable_environments_for_preset(preset_name: String) -> Array:
	"""Get environments suitable for a lighting preset"""
	var suitable = []
	for env_name in HDRI_ENVIRONMENTS:
		var env_data = HDRI_ENVIRONMENTS[env_name]
		if preset_name in env_data.suitable_for:
			suitable.append(env_name)
	return suitable

func get_diagnostics() -> Dictionary:
	"""Get diagnostic information about environment system"""
	return {
		"current_environment": current_environment,
		"reflection_quality": reflection_quality,
		"environment_intensity": environment_intensity,
		"reflection_intensity": reflection_intensity,
		"background_mode": background_mode,
		"hdri_cache_size": hdri_cache.size(),
		"ssr_enabled": ssr_enabled,
		"sdfgi_enabled": sdfgi_enabled,
		"adaptive_quality": adaptive_quality,
		"current_fps": Engine.get_frames_per_second()
	}