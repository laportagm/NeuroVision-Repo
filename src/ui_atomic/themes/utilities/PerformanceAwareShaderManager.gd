## Performance-Aware Shader Management System for NeuroVision
## Phase 4: Advanced Material 3 Theme Integration
##
## This system dynamically manages shader quality and effects based on real-time
## performance metrics and hardware capabilities for optimal educational experience.

class_name PerformanceAwareShaderManager
extends RefCounted

# === SIGNALS ===
signal shader_quality_changed(new_quality: String)
signal hardware_profile_detected(profile: Dictionary)
signal performance_adaptation_triggered(reason: String)

# === CONSTANTS ===
const QUALITY_LEVELS = ["low", "medium", "high", "maximum"]
const SHADER_VARIANTS = {
	"glass_morphism": {
		"low": "res://src/ui_atomic/themes/shaders/glass_morphism_lite.gdshader",
		"medium": "res://src/ui_atomic/themes/shaders/glass_morphism_medium.gdshader", 
		"high": "res://src/ui_atomic/themes/shaders/glass_morphism_full.gdshader",
		"maximum": "res://src/ui_atomic/themes/shaders/glass_morphism_ultra.gdshader"
	},
	"ui_blur": {
		"low": "res://src/ui_atomic/themes/shaders/ui_blur_basic.gdshader",
		"medium": "res://src/ui_atomic/themes/shaders/ui_blur_medium.gdshader",
		"high": "res://src/ui_atomic/themes/shaders/ui_blur_advanced.gdshader",
		"maximum": "res://src/ui_atomic/themes/shaders/ui_blur_ultra.gdshader"
	},
	"brain_highlight": {
		"low": "res://src/ui_atomic/themes/shaders/brain_highlight_simple.gdshader",
		"medium": "res://src/ui_atomic/themes/shaders/brain_highlight_standard.gdshader",
		"high": "res://src/ui_atomic/themes/shaders/brain_highlight_enhanced.gdshader",
		"maximum": "res://src/ui_atomic/themes/shaders/brain_highlight_premium.gdshader"
	}
}

# === PROPERTIES ===
var current_quality_level: String = "medium"
var hardware_profile: Dictionary = {}
var performance_monitor = null
var loaded_shaders: Dictionary = {}
var shader_materials_cache: Dictionary = {}
var quality_adaptation_enabled: bool = true
var manual_quality_override: String = ""

# Performance thresholds
var performance_thresholds = {
	"fps_excellent": 75.0,
	"fps_good": 60.0,
	"fps_acceptable": 45.0,
	"fps_poor": 30.0,
	"memory_warning_mb": 400.0,
	"memory_critical_mb": 600.0,
	"frame_time_warning_ms": 22.0,
	"frame_time_critical_ms": 33.0
}

# === INITIALIZATION ===

func _init():
	_detect_hardware_profile()
	_initialize_performance_monitoring()
	_preload_essential_shaders()

func _detect_hardware_profile() -> void:
	"""Detect hardware capabilities for shader optimization"""
	hardware_profile = {
		"cpu_cores": OS.get_processor_count(),
		"platform": OS.get_name(),
		"renderer": RenderingServer.get_rendering_device().get_device_name() if RenderingServer.get_rendering_device() else "Software",
		"supports_compute": RenderingServer.get_rendering_device() != null,
		"mobile_device": OS.get_name() in ["Android", "iOS"],
		"detected_at": Time.get_unix_time_from_system()
	}
	
	# Determine GPU tier
	var renderer = hardware_profile.renderer.to_lower()
	if "nvidia" in renderer or "amd" in renderer or "radeon" in renderer:
		hardware_profile["gpu_tier"] = "dedicated"
		hardware_profile["max_quality"] = "maximum"
	elif "intel" in renderer and ("iris" in renderer or "xe" in renderer):
		hardware_profile["gpu_tier"] = "integrated_modern"
		hardware_profile["max_quality"] = "high"
	elif "intel" in renderer:
		hardware_profile["gpu_tier"] = "integrated_basic"
		hardware_profile["max_quality"] = "medium"
	else:
		hardware_profile["gpu_tier"] = "unknown"
		hardware_profile["max_quality"] = "medium"
	
	# Mobile optimizations
	if hardware_profile.mobile_device:
		hardware_profile["max_quality"] = "medium"
	
	print("[ShaderManager] Hardware profile detected: %s GPU, Max quality: %s" % [
		hardware_profile.gpu_tier, hardware_profile.max_quality
	])
	
	hardware_profile_detected.emit(hardware_profile)

func _initialize_performance_monitoring() -> void:
	"""Initialize connection to performance monitoring systems"""
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root.has_node("UIThemeManager"):
		performance_monitor = tree.root.get_node("UIThemeManager")
		print("[ShaderManager] Connected to UIThemeManager performance monitoring")
	
	# Set initial quality based on hardware
	current_quality_level = _determine_initial_quality()
	print("[ShaderManager] Initial quality level: %s" % current_quality_level)

func _determine_initial_quality() -> String:
	"""Determine initial quality level based on hardware"""
	var max_quality = hardware_profile.get("max_quality", "medium")
	var quality_index = QUALITY_LEVELS.find(max_quality)
	
	# Conservative approach - start one level below max
	if quality_index > 0:
		return QUALITY_LEVELS[quality_index - 1]
	else:
		return max_quality

# === SHADER MANAGEMENT ===

func _preload_essential_shaders() -> void:
	"""Preload essential shaders for common quality levels"""
	var essential_types = ["glass_morphism", "ui_blur"]
	var essential_qualities = ["low", "medium", "high"]
	
	for shader_type in essential_types:
		for quality in essential_qualities:
			_load_shader(shader_type, quality)

func _load_shader(shader_type: String, quality: String) -> Shader:
	"""Load and cache a shader variant"""
	var cache_key = shader_type + "_" + quality
	
	if loaded_shaders.has(cache_key):
		return loaded_shaders[cache_key]
	
	if not SHADER_VARIANTS.has(shader_type):
		push_error("[ShaderManager] Unknown shader type: %s" % shader_type)
		return null
	
	var variant_paths = SHADER_VARIANTS[shader_type]
	if not variant_paths.has(quality):
		push_error("[ShaderManager] Unknown quality level for %s: %s" % [shader_type, quality])
		return null
	
	var shader_path = variant_paths[quality]
	if not ResourceLoader.exists(shader_path):
		push_warning("[ShaderManager] Shader not found, using fallback: %s" % shader_path)
		# Try to find next lower quality
		var quality_index = QUALITY_LEVELS.find(quality)
		if quality_index > 0:
			return _load_shader(shader_type, QUALITY_LEVELS[quality_index - 1])
		return null
	
	var shader = load(shader_path) as Shader
	if shader:
		loaded_shaders[cache_key] = shader
		print("[ShaderManager] Loaded shader: %s (%s quality)" % [shader_type, quality])
	else:
		push_error("[ShaderManager] Failed to load shader: %s" % shader_path)
	
	return shader

func get_optimal_shader(shader_type: String, override_quality: String = "") -> Shader:
	"""Get optimal shader for current performance level"""
	var target_quality = override_quality if override_quality != "" else current_quality_level
	
	# Ensure quality is within hardware limits
	var max_quality = hardware_profile.get("max_quality", "medium")
	var max_index = QUALITY_LEVELS.find(max_quality)
	var target_index = QUALITY_LEVELS.find(target_quality)
	
	if target_index > max_index:
		target_quality = max_quality
		print("[ShaderManager] Quality clamped to hardware limit: %s" % target_quality)
	
	return _load_shader(shader_type, target_quality)

func create_optimized_material(shader_type: String, base_parameters: Dictionary = {}) -> ShaderMaterial:
	"""Create shader material optimized for current performance level"""
	var cache_key = shader_type + "_" + current_quality_level + "_" + str(base_parameters.hash())
	
	if shader_materials_cache.has(cache_key):
		return shader_materials_cache[cache_key].duplicate()
	
	var shader = get_optimal_shader(shader_type)
	if not shader:
		return null
	
	var material = ShaderMaterial.new()
	material.shader = shader
	
	# Apply performance-appropriate parameters
	var optimized_params = _optimize_shader_parameters(shader_type, base_parameters)
	for param_name in optimized_params:
		_set_shader_parameter_safely(material, param_name, optimized_params[param_name])
	
	# Cache the material template
	shader_materials_cache[cache_key] = material
	
	return material.duplicate()

func _optimize_shader_parameters(shader_type: String, base_params: Dictionary) -> Dictionary:
	"""Optimize shader parameters based on current quality level"""
	var optimized = base_params.duplicate()
	
	# Get performance tokens from M3DesignTokens
	var M3Tokens = preload("res://src/ui_atomic/themes/core/M3DesignTokens.gd")
	var performance_data = M3Tokens.M3_PERFORMANCE_TOKENS.get(current_quality_level, {})
	
	match shader_type:
		"glass_morphism":
			optimized["blur_radius"] = performance_data.get("blur_radius", 6.0)
			optimized["glass_opacity"] = 0.85
			optimized["noise_amount"] = performance_data.get("blur_radius", 6.0) / 50.0
			optimized["enable_chromatic_aberration"] = current_quality_level == "maximum"
			
		"ui_blur":
			optimized["blur_amount"] = performance_data.get("blur_radius", 4.0)
			optimized["blur_quality"] = 1 if current_quality_level in ["low", "medium"] else 2
			
		"brain_highlight":
			optimized["glow_intensity"] = 1.0 if current_quality_level in ["high", "maximum"] else 0.7
			optimized["edge_detection"] = current_quality_level in ["high", "maximum"]
			optimized["animation_speed"] = performance_data.get("animation_duration_multiplier", 1.0)
	
	return optimized

func _set_shader_parameter_safely(material: ShaderMaterial, param_name: String, value: Variant) -> void:
	"""Safely set shader parameter with existence check"""
	if not material or not material.shader:
		return
	
	var shader_params = material.shader.get_shader_uniform_list()
	for param_info in shader_params:
		if param_info.name == param_name:
			material.set_shader_parameter(param_name, value)
			return
	
	# Parameter doesn't exist in this shader variant - that's okay
	print("[ShaderManager] Parameter '%s' not found in shader variant" % param_name)

# === PERFORMANCE ADAPTATION ===

func update_for_performance_change(metrics: Dictionary) -> void:
	"""Update shader quality based on performance metrics"""
	if not quality_adaptation_enabled or manual_quality_override != "":
		return
	
	var new_quality = _evaluate_required_quality(metrics)
	if new_quality != current_quality_level:
		set_quality_level(new_quality, "performance_adaptation")

func _evaluate_required_quality(metrics: Dictionary) -> String:
	"""Evaluate required quality level from performance metrics"""
	var fps = metrics.get("fps", 30.0)
	var memory_mb = metrics.get("memory_mb", 300.0)
	var frame_time_ms = metrics.get("frame_time_ms", 33.0)
	var stability = metrics.get("performance_stability", 0.5)
	
	# Score each aspect
	var performance_score = 0.0
	
	# FPS scoring (40% weight)
	if fps >= performance_thresholds.fps_excellent:
		performance_score += 0.4
	elif fps >= performance_thresholds.fps_good:
		performance_score += 0.3
	elif fps >= performance_thresholds.fps_acceptable:
		performance_score += 0.2
	else:
		performance_score += 0.1
	
	# Memory efficiency (30% weight)
	if memory_mb < performance_thresholds.memory_warning_mb:
		performance_score += 0.3
	elif memory_mb < performance_thresholds.memory_critical_mb:
		performance_score += 0.2
	else:
		performance_score += 0.1
	
	# Frame time consistency (20% weight)
	if frame_time_ms < performance_thresholds.frame_time_warning_ms:
		performance_score += 0.2
	elif frame_time_ms < performance_thresholds.frame_time_critical_ms:
		performance_score += 0.1
	
	# Stability (10% weight)
	performance_score += stability * 0.1
	
	# Map to quality level
	if performance_score >= 0.85:
		return "maximum"
	elif performance_score >= 0.65:
		return "high"
	elif performance_score >= 0.45:
		return "medium"
	else:
		return "low"

func set_quality_level(new_quality: String, reason: String = "manual") -> void:
	"""Set shader quality level with optional reason"""
	if new_quality not in QUALITY_LEVELS:
		push_error("[ShaderManager] Invalid quality level: %s" % new_quality)
		return
	
	# Check hardware constraints
	var max_quality = hardware_profile.get("max_quality", "medium")
	var max_index = QUALITY_LEVELS.find(max_quality)
	var new_index = QUALITY_LEVELS.find(new_quality)
	
	if new_index > max_index:
		print("[ShaderManager] Quality clamped from %s to %s (hardware limit)" % [new_quality, max_quality])
		new_quality = max_quality
	
	if new_quality == current_quality_level:
		return
	
	var old_quality = current_quality_level
	current_quality_level = new_quality
	
	# Clear material cache to force regeneration
	shader_materials_cache.clear()
	
	print("[ShaderManager] Quality changed: %s -> %s (reason: %s)" % [old_quality, new_quality, reason])
	shader_quality_changed.emit(new_quality)
	
	if reason == "performance_adaptation":
		performance_adaptation_triggered.emit("Quality reduced due to performance")

func enable_quality_adaptation(enabled: bool) -> void:
	"""Enable or disable automatic quality adaptation"""
	quality_adaptation_enabled = enabled
	print("[ShaderManager] Quality adaptation %s" % ("enabled" if enabled else "disabled"))

func set_manual_quality_override(quality: String) -> void:
	"""Set manual quality override (empty string to disable)"""
	manual_quality_override = quality
	if quality != "":
		set_quality_level(quality, "manual_override")
		print("[ShaderManager] Manual quality override: %s" % quality)
	else:
		print("[ShaderManager] Manual quality override removed")

# === UTILITY METHODS ===

func get_current_quality() -> String:
	"""Get current quality level"""
	return current_quality_level

func get_hardware_profile() -> Dictionary:
	"""Get detected hardware profile"""
	return hardware_profile.duplicate()

func get_available_shaders() -> Dictionary:
	"""Get list of available shader types and variants"""
	var available = {}
	for shader_type in SHADER_VARIANTS:
		available[shader_type] = []
		var variants = SHADER_VARIANTS[shader_type]
		for quality in QUALITY_LEVELS:
			if variants.has(quality) and ResourceLoader.exists(variants[quality]):
				available[shader_type].append(quality)
	return available

func get_performance_impact_estimate(shader_type: String, quality: String) -> Dictionary:
	"""Estimate performance impact of a shader configuration"""
	var impact = {
		"gpu_load": 0.0,
		"memory_usage_mb": 0.0,
		"complexity_score": 0.0
	}
	
	var quality_multiplier = float(QUALITY_LEVELS.find(quality) + 1) / float(QUALITY_LEVELS.size())
	
	match shader_type:
		"glass_morphism":
			impact.gpu_load = 0.3 * quality_multiplier
			impact.memory_usage_mb = 20.0 * quality_multiplier
			impact.complexity_score = 0.7 * quality_multiplier
		"ui_blur":
			impact.gpu_load = 0.2 * quality_multiplier
			impact.memory_usage_mb = 15.0 * quality_multiplier
			impact.complexity_score = 0.5 * quality_multiplier
		"brain_highlight":
			impact.gpu_load = 0.4 * quality_multiplier
			impact.memory_usage_mb = 25.0 * quality_multiplier
			impact.complexity_score = 0.8 * quality_multiplier
	
	return impact

func clear_shader_cache() -> void:
	"""Clear all cached shaders and materials"""
	loaded_shaders.clear()
	shader_materials_cache.clear()
	print("[ShaderManager] Shader cache cleared")

func get_diagnostics() -> Dictionary:
	"""Get diagnostic information about shader system"""
	return {
		"current_quality": current_quality_level,
		"hardware_profile": hardware_profile,
		"cached_shaders": loaded_shaders.size(),
		"cached_materials": shader_materials_cache.size(),
		"quality_adaptation_enabled": quality_adaptation_enabled,
		"manual_override": manual_quality_override,
		"available_shaders": get_available_shaders()
	}