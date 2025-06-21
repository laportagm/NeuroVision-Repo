extends Node

## Manages graphics optimization settings and presets for different GPU capabilities
## Works with IntelOptimizer to provide appropriate quality settings

signal quality_preset_changed(preset_name: String)
signal optimization_applied(settings: Dictionary)

# === ENUMS ===
enum QualityPreset {
	INTEGRATED_LOW,      # Intel UHD 620 and similar
	INTEGRATED_MEDIUM,   # Intel Iris and better integrated
	DEDICATED_LOW,       # Older dedicated GPUs
	DEDICATED_MEDIUM,    # Mid-range dedicated GPUs
	DEDICATED_HIGH,      # High-end dedicated GPUs
	MEDICAL_GRADE       # Maximum quality for medical accuracy
}

# === CONSTANTS ===
const PRESET_SETTINGS = {
	QualityPreset.INTEGRATED_LOW: {
		"name": "Integrated Graphics (Low)",
		"target_fps": 30,
		"ssao_enabled": false,
		"glow_enabled": false,
		"shadows_enabled": false,
		"blur_shader_amount": 2.0,
		"blur_enabled": false,
		"anti_aliasing": "none",
		"texture_quality": "low",
		"model_lod_bias": 2.0,
		"volumetric_fog": false,
		"reflection_probes": false,
		"description": "Optimized for Intel UHD 620 and similar"
	},
	QualityPreset.INTEGRATED_MEDIUM: {
		"name": "Integrated Graphics (Medium)",
		"target_fps": 45,
		"ssao_enabled": false,
		"glow_enabled": true,
		"shadows_enabled": false,
		"blur_shader_amount": 4.0,
		"blur_enabled": true,
		"anti_aliasing": "fxaa",
		"texture_quality": "medium",
		"model_lod_bias": 1.0,
		"volumetric_fog": false,
		"reflection_probes": false,
		"description": "Balanced for Intel Iris and better integrated GPUs"
	},
	QualityPreset.DEDICATED_LOW: {
		"name": "Dedicated Graphics (Low)",
		"target_fps": 60,
		"ssao_enabled": true,
		"glow_enabled": true,
		"shadows_enabled": true,
		"blur_shader_amount": 6.0,
		"blur_enabled": true,
		"anti_aliasing": "fxaa",
		"texture_quality": "medium",
		"model_lod_bias": 1.0,
		"volumetric_fog": false,
		"reflection_probes": true,
		"description": "For older dedicated graphics cards"
	},
	QualityPreset.DEDICATED_MEDIUM: {
		"name": "Dedicated Graphics (Medium)",
		"target_fps": 60,
		"ssao_enabled": true,
		"glow_enabled": true,
		"shadows_enabled": true,
		"blur_shader_amount": 8.0,
		"blur_enabled": true,
		"anti_aliasing": "msaa_2x",
		"texture_quality": "high",
		"model_lod_bias": 0.5,
		"volumetric_fog": true,
		"reflection_probes": true,
		"description": "Standard quality for modern GPUs"
	},
	QualityPreset.DEDICATED_HIGH: {
		"name": "Dedicated Graphics (High)",
		"target_fps": 120,
		"ssao_enabled": true,
		"glow_enabled": true,
		"shadows_enabled": true,
		"blur_shader_amount": 12.0,
		"blur_enabled": true,
		"anti_aliasing": "msaa_4x",
		"texture_quality": "ultra",
		"model_lod_bias": 0.0,
		"volumetric_fog": true,
		"reflection_probes": true,
		"description": "Maximum visual quality"
	},
	QualityPreset.MEDICAL_GRADE: {
		"name": "Medical Grade",
		"target_fps": 60,
		"ssao_enabled": true,
		"glow_enabled": true,
		"shadows_enabled": true,
		"blur_shader_amount": 8.0,
		"blur_enabled": true,
		"anti_aliasing": "msaa_4x",
		"texture_quality": "ultra",
		"model_lod_bias": 0.0,
		"volumetric_fog": false,  # Can interfere with medical accuracy
		"reflection_probes": true,
		"description": "Optimized for medical accuracy over performance"
	}
}

# === VARIABLES ===
var current_preset: QualityPreset = QualityPreset.DEDICATED_MEDIUM
var custom_settings: Dictionary = {}
var auto_detect_enabled: bool = true

# === LIFECYCLE ===
func _ready() -> void:
	print("[GraphicsOptimizationManager] Initializing graphics optimization system")
	
	# Auto-detect best preset on startup
	if auto_detect_enabled:
		auto_detect_quality_preset()

# === PUBLIC METHODS ===
func auto_detect_quality_preset() -> void:
	"""Automatically detect and apply the best quality preset based on GPU"""
	var intel_opt = get_node_or_null("/root/IntelOptimizer")
	if not intel_opt:
		push_warning("[GraphicsOptimizationManager] IntelOptimizer not available")
		return
	
	# Simple detection based on Intel GPU presence
	var detected_preset = QualityPreset.INTEGRATED_MEDIUM
	if intel_opt.is_intel_gpu_detected():
		detected_preset = QualityPreset.INTEGRATED_LOW
	
	print("[GraphicsOptimizationManager] Auto-detected preset: " + PRESET_SETTINGS[detected_preset].name)
	apply_quality_preset(detected_preset)

func apply_quality_preset(preset: QualityPreset) -> void:
	"""Apply a specific quality preset"""
	current_preset = preset
	var settings = PRESET_SETTINGS[preset].duplicate()
	
	# Merge with any custom settings
	for key in custom_settings:
		settings[key] = custom_settings[key]
	
	_apply_settings(settings)
	
	quality_preset_changed.emit(settings.name)
	optimization_applied.emit(settings)

func set_custom_setting(setting_name: String, value) -> void:
	"""Override a specific setting while keeping the current preset"""
	custom_settings[setting_name] = value
	apply_quality_preset(current_preset)

func clear_custom_settings() -> void:
	"""Remove all custom setting overrides"""
	custom_settings.clear()
	apply_quality_preset(current_preset)

func get_current_settings() -> Dictionary:
	"""Get the currently active settings"""
	var settings = PRESET_SETTINGS[current_preset].duplicate()
	for key in custom_settings:
		settings[key] = custom_settings[key]
	return settings

func get_preset_names() -> Array:
	"""Get list of available preset names for UI"""
	var names = []
	for preset in QualityPreset.values():
		names.append(PRESET_SETTINGS[preset].name)
	return names

func apply_to_scene(scene: Node) -> void:
	"""Apply current optimization settings to a specific scene"""
	var settings = get_current_settings()
	
	# Find and optimize environment
	var environments = scene.find_children("*", "WorldEnvironment", true)
	for env_node in environments:
		if env_node.environment:
			_optimize_environment(env_node.environment, settings)
	
	# Find and optimize lights
	var lights = scene.find_children("*", "Light3D", true)
	for light in lights:
		_optimize_light(light, settings)
	
	# Find and optimize materials
	var mesh_instances = scene.find_children("*", "MeshInstance3D", true)
	for mesh in mesh_instances:
		_optimize_mesh_instance(mesh, settings)

# === PRIVATE METHODS ===
func _determine_preset_from_gpu(gpu_info: Dictionary) -> QualityPreset:
	"""Determine the best quality preset based on GPU information"""
	var gpu_name = gpu_info.get("name", "").to_lower()
	var is_integrated = IntelOptimizer.is_integrated_graphics()
	
	if is_integrated:
		# Check for specific integrated GPU models
		if gpu_name.contains("uhd 620") or gpu_name.contains("uhd 630"):
			return QualityPreset.INTEGRATED_LOW
		elif gpu_name.contains("iris"):
			return QualityPreset.INTEGRATED_MEDIUM
		else:
			return QualityPreset.INTEGRATED_LOW
	else:
		# Dedicated GPU detection
		if gpu_name.contains("rtx 40") or gpu_name.contains("rx 7"):
			return QualityPreset.DEDICATED_HIGH
		elif gpu_name.contains("rtx 30") or gpu_name.contains("rx 6"):
			return QualityPreset.DEDICATED_MEDIUM
		else:
			return QualityPreset.DEDICATED_LOW

func _apply_settings(settings: Dictionary) -> void:
	"""Apply optimization settings globally"""
	# Update performance monitor target
	var perf_monitor = get_node_or_null("/root/PerformanceMonitor")
	if perf_monitor and perf_monitor.has_method("set_target_fps"):
		perf_monitor.set_target_fps(settings.get("target_fps", 60))
	
	# Update rendering settings
	var viewport = get_viewport()
	if viewport:
		# Anti-aliasing
		match settings.get("anti_aliasing", "none"):
			"none":
				viewport.msaa_3d = Viewport.MSAA_DISABLED
			"fxaa":
				viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			"msaa_2x":
				viewport.msaa_3d = Viewport.MSAA_2X
			"msaa_4x":
				viewport.msaa_3d = Viewport.MSAA_4X

func _optimize_environment(env: Environment, settings: Dictionary) -> void:
	"""Optimize environment settings"""
	env.ssao_enabled = settings.get("ssao_enabled", false)
	env.glow_enabled = settings.get("glow_enabled", false)
	env.volumetric_fog_enabled = settings.get("volumetric_fog", false)
	
	# Adjust quality settings
	if env.ssao_enabled:
		env.ssao_quality = RenderingServer.ENV_SSAO_QUALITY_LOW if settings.name.contains("Low") else RenderingServer.ENV_SSAO_QUALITY_MEDIUM

func _optimize_light(light: Light3D, settings: Dictionary) -> void:
	"""Optimize light settings"""
	if light is DirectionalLight3D:
		light.shadow_enabled = settings.get("shadows_enabled", false)
		if light.shadow_enabled:
			light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL

func _optimize_mesh_instance(mesh: MeshInstance3D, settings: Dictionary) -> void:
	"""Optimize mesh instance settings"""
	mesh.lod_bias = settings.get("model_lod_bias", 0.0)
	
	# Optimize materials if using blur shaders
	if mesh.material_override and mesh.material_override is ShaderMaterial:
		var mat = mesh.material_override as ShaderMaterial
		if mat.shader and mat.shader.resource_path.contains("glass"):
			mat.set_shader_parameter("blur_amount", settings.get("blur_shader_amount", 4.0))
			mat.set_shader_parameter("enable_blur", settings.get("blur_enabled", true))

# === DEBUG ===
func debug_print_current_settings() -> void:
	"""Print current settings for debugging"""
	var settings = get_current_settings()
	print("[GraphicsOptimizationManager] Current Settings:")
	for key in settings:
		print("  " + key + ": " + str(settings[key]))
