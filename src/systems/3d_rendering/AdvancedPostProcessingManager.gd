## Advanced Post-Processing Manager for NeuroVision
##
## Manages high-quality post-processing effects including SSAO, SSR, and
## other visual enhancements specifically tuned for medical brain visualization.

class_name AdvancedPostProcessingManager
extends Node

# === SIGNALS ===
signal post_processing_quality_changed(quality: String)
signal effect_toggled(effect_name: String, enabled: bool)
signal performance_adjusted(fps: float, quality: String)

# === CONSTANTS ===
const POST_PROCESSING_PRESETS = {
	"medical_maximum": {
		"description": "Maximum quality for medical accuracy",
		"ssao_enabled": true,
		"ssao_intensity": 1.2,
		"ssao_radius": 0.8,
		"ssao_quality": "ultra",
		"ssr_enabled": true,
		"ssr_max_steps": 64,
		"ssr_quality": "high",
		"sdfgi_enabled": true,
		"glow_enabled": false,
		"dof_enabled": false,
		"edge_enhancement": true,
		"color_correction": "medical"
	},
	"clinical_high": {
		"description": "High quality for clinical examination",
		"ssao_enabled": true,
		"ssao_intensity": 1.0,
		"ssao_radius": 0.6,
		"ssao_quality": "high",
		"ssr_enabled": true,
		"ssr_max_steps": 32,
		"ssr_quality": "medium",
		"sdfgi_enabled": false,
		"glow_enabled": false,
		"dof_enabled": false,
		"edge_enhancement": true,
		"color_correction": "clinical"
	},
	"educational_balanced": {
		"description": "Balanced quality for educational use",
		"ssao_enabled": true,
		"ssao_intensity": 0.8,
		"ssao_radius": 0.5,
		"ssao_quality": "medium",
		"ssr_enabled": true,
		"ssr_max_steps": 24,
		"ssr_quality": "medium",
		"sdfgi_enabled": false,
		"glow_enabled": true,
		"dof_enabled": false,
		"edge_enhancement": false,
		"color_correction": "enhanced"
	},
	"performance_optimized": {
		"description": "Optimized for performance",
		"ssao_enabled": true,
		"ssao_intensity": 0.6,
		"ssao_radius": 0.4,
		"ssao_quality": "low",
		"ssr_enabled": false,
		"ssr_max_steps": 16,
		"ssr_quality": "low",
		"sdfgi_enabled": false,
		"glow_enabled": false,
		"dof_enabled": false,
		"edge_enhancement": false,
		"color_correction": "standard"
	}
}

const QUALITY_LEVELS = ["low", "medium", "high", "ultra"]
const COLOR_CORRECTION_MODES = ["standard", "enhanced", "clinical", "medical"]

# === EXPORTS ===
@export_group("Post-Processing Settings")
@export var current_preset: String = "clinical_high"
@export var post_processing_quality: String = "high"
@export var adaptive_quality: bool = true
@export var medical_accuracy_mode: bool = true

@export_group("Effect Controls")
@export var ssao_enabled: bool = true
@export var ssr_enabled: bool = true
@export var sdfgi_enabled: bool = false
@export var glow_enabled: bool = false
@export var edge_enhancement_enabled: bool = true

@export_group("Performance Settings")
@export var target_fps: float = 60.0
@export var performance_monitoring_interval: float = 1.0
@export var quality_adjustment_threshold: float = 0.8

# === PRIVATE VARIABLES ===
var environment_resource: Environment
var camera_3d: Camera3D
var viewport: Viewport
var performance_monitor = null

# Effect-specific variables
var ssao_settings: Dictionary = {}
var ssr_settings: Dictionary = {}
var glow_settings: Dictionary = {}
var color_correction_settings: Dictionary = {}

# Performance tracking
var frame_time_samples: Array[float] = []
var quality_adjustment_timer: float = 0.0
var last_quality_adjustment: float = 0.0

# Custom post-processing materials
var edge_enhancement_material: ShaderMaterial
var medical_color_correction_material: ShaderMaterial

# Platform compatibility
var is_metal_backend: bool = false

# === INITIALIZATION ===

func _ready():
	_initialize_post_processing()
	_connect_to_systems()
	_apply_preset(current_preset)
	print("[PostProcessing] Advanced post-processing manager initialized")

func _initialize_post_processing():
	"""Initialize post-processing system"""
	viewport = get_viewport()
	camera_3d = viewport.get_camera_3d()
	
	if not camera_3d:
		push_error("[PostProcessing] No 3D camera found")
		return
	
	# Detect platform for compatibility
	is_metal_backend = _detect_metal_backend()
	if is_metal_backend:
		print("[PostProcessing] Metal backend detected - using compatibility mode")
	
	# Get or create environment
	var world_env = camera_3d.get_parent().get_node_or_null("WorldEnvironment")
	if world_env and world_env.environment:
		environment_resource = world_env.environment
	else:
		push_warning("[PostProcessing] No environment found, creating default")
		environment_resource = Environment.new()
	
	# Initialize custom post-processing effects
	_initialize_custom_effects()

func _initialize_custom_effects():
	"""Initialize custom post-processing effects"""
	# Edge enhancement shader with error handling
	edge_enhancement_material = _create_edge_enhancement_material()
	if not edge_enhancement_material or not edge_enhancement_material.shader:
		push_error("[PostProcessing] Failed to create edge enhancement material")
		_create_fallback_materials()
		return
	
	# Medical color correction shader with error handling
	medical_color_correction_material = _create_medical_color_correction_material()
	if not medical_color_correction_material or not medical_color_correction_material.shader:
		push_error("[PostProcessing] Failed to create medical color correction material")
		_create_fallback_materials()
		return
	
	print("[PostProcessing] Custom post-processing effects initialized successfully")

func _detect_metal_backend() -> bool:
	"""Detect if running on Metal rendering backend"""
	# Check operating system first
	if OS.get_name() != "macOS":
		return false
	
	# Try to get rendering device info
	var rendering_device = RenderingServer.get_rendering_device()
	if rendering_device:
		var device_name = rendering_device.get_device_name().to_lower()
		if "metal" in device_name or "apple" in device_name or "m1" in device_name or "m2" in device_name:
			return true
	
	# Fallback: assume Metal on macOS with Apple Silicon
	var processor = OS.get_processor_name().to_lower()
	if "apple" in processor or "m1" in processor or "m2" in processor:
		return true
	
	return false

func _create_fallback_materials():
	"""Create simple fallback materials when shader compilation fails"""
	print("[PostProcessing] Creating fallback materials for educational platform reliability")
	
	# Simple edge enhancement fallback
	edge_enhancement_material = ShaderMaterial.new()
	var simple_shader = Shader.new()
	simple_shader.code = """
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
}
"""
	edge_enhancement_material.shader = simple_shader
	
	# Simple color correction fallback
	medical_color_correction_material = ShaderMaterial.new()
	var color_shader = Shader.new()
	color_shader.code = """
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float brightness : hint_range(-0.5, 0.5) = 0.0;
uniform float contrast : hint_range(0.5, 2.0) = 1.0;

void fragment() {
	vec3 color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	color = (color - 0.5) * contrast + 0.5 + brightness;
	COLOR = vec4(clamp(color, 0.0, 1.0), 1.0);
}
"""
	medical_color_correction_material.shader = color_shader
	medical_color_correction_material.set_shader_parameter("brightness", 0.0)
	medical_color_correction_material.set_shader_parameter("contrast", 1.0)

func _create_edge_enhancement_material() -> ShaderMaterial:
	"""Create edge enhancement shader material"""
	var material = ShaderMaterial.new()
	var shader = Shader.new()
	
	shader.code = """
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float edge_threshold : hint_range(0.0, 1.0) = 0.1;
uniform float edge_intensity : hint_range(0.0, 3.0) = 1.0;
uniform vec3 edge_color : source_color = vec3(0.0, 0.0, 0.0);

vec3 sobel_edge_detection(sampler2D tex, vec2 uv, vec2 pixel_size) {
	vec3 horizontal = 
		texture(tex, uv + vec2(-pixel_size.x, -pixel_size.y)).rgb * -1.0 +
		texture(tex, uv + vec2(-pixel_size.x, 0.0)).rgb * -2.0 +
		texture(tex, uv + vec2(-pixel_size.x, pixel_size.y)).rgb * -1.0 +
		texture(tex, uv + vec2(pixel_size.x, -pixel_size.y)).rgb * 1.0 +
		texture(tex, uv + vec2(pixel_size.x, 0.0)).rgb * 2.0 +
		texture(tex, uv + vec2(pixel_size.x, pixel_size.y)).rgb * 1.0;
	
	vec3 vertical = 
		texture(tex, uv + vec2(-pixel_size.x, -pixel_size.y)).rgb * -1.0 +
		texture(tex, uv + vec2(0.0, -pixel_size.y)).rgb * -2.0 +
		texture(tex, uv + vec2(pixel_size.x, -pixel_size.y)).rgb * -1.0 +
		texture(tex, uv + vec2(-pixel_size.x, pixel_size.y)).rgb * 1.0 +
		texture(tex, uv + vec2(0.0, pixel_size.y)).rgb * 2.0 +
		texture(tex, uv + vec2(pixel_size.x, pixel_size.y)).rgb * 1.0;
	
	return sqrt(horizontal * horizontal + vertical * vertical);
}

void fragment() {
	vec2 pixel_size = 1.0 / SCREEN_PIXEL_SIZE;
	vec3 original_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	
	// Color-based edge detection for medical accuracy
	vec3 color_edge = sobel_edge_detection(SCREEN_TEXTURE, SCREEN_UV, pixel_size);
	float color_edge_magnitude = length(color_edge);
	
	// Enhanced edge detection using luminance difference
	float center_lum = dot(original_color, vec3(0.299, 0.587, 0.114));
	float left_lum = dot(texture(SCREEN_TEXTURE, SCREEN_UV - vec2(pixel_size.x, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
	float right_lum = dot(texture(SCREEN_TEXTURE, SCREEN_UV + vec2(pixel_size.x, 0.0)).rgb, vec3(0.299, 0.587, 0.114));
	float up_lum = dot(texture(SCREEN_TEXTURE, SCREEN_UV - vec2(0.0, pixel_size.y)).rgb, vec3(0.299, 0.587, 0.114));
	float down_lum = dot(texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, pixel_size.y)).rgb, vec3(0.299, 0.587, 0.114));
	
	float lum_edge = abs(center_lum - left_lum) + abs(center_lum - right_lum) + 
					 abs(center_lum - up_lum) + abs(center_lum - down_lum);
	
	// Combine color and luminance edge information for medical accuracy
	float edge_strength = max(lum_edge * 4.0, color_edge_magnitude);
	
	if (edge_strength > edge_threshold) {
		vec3 enhanced_color = mix(original_color, edge_color, edge_intensity * edge_strength);
		COLOR = vec4(enhanced_color, 1.0);
	} else {
		COLOR = vec4(original_color, 1.0);
	}
}
"""
	
	material.shader = shader
	material.set_shader_parameter("edge_threshold", 0.1)
	material.set_shader_parameter("edge_intensity", 1.0)
	material.set_shader_parameter("edge_color", Vector3(0.0, 0.0, 0.0))
	
	return material

func _create_medical_color_correction_material() -> ShaderMaterial:
	"""Create medical color correction shader material"""
	var material = ShaderMaterial.new()
	var shader = Shader.new()
	
	shader.code = """
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float contrast : hint_range(0.0, 3.0) = 1.0;
uniform float brightness : hint_range(-1.0, 1.0) = 0.0;
uniform float saturation : hint_range(0.0, 2.0) = 1.0;
uniform float gamma : hint_range(0.1, 3.0) = 1.0;
uniform vec3 white_balance : source_color = vec3(1.0, 1.0, 1.0);
uniform float medical_enhancement : hint_range(0.0, 1.0) = 0.0;

vec3 rgb_to_hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv_to_rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	vec3 original_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	
	// Apply white balance
	vec3 color = original_color * white_balance;
	
	// Brightness adjustment
	color += brightness;
	
	// Contrast adjustment
	color = (color - 0.5) * contrast + 0.5;
	
	// Gamma correction
	color = pow(max(color, vec3(0.0)), vec3(1.0 / gamma));
	
	// Saturation adjustment
	vec3 hsv = rgb_to_hsv(color);
	hsv.y *= saturation;
	color = hsv_to_rgb(hsv);
	
	// Medical enhancement - enhance tissue contrast
	if (medical_enhancement > 0.0) {
		// Enhance red channel for blood vessels
		color.r = mix(color.r, pow(color.r, 0.8), medical_enhancement * 0.3);
		
		// Enhance contrast in mid-tones for tissue detail
		float luminance = dot(color, vec3(0.299, 0.587, 0.114));
		float mid_tone_mask = 1.0 - abs(luminance - 0.5) * 2.0;
		color = mix(color, color * 1.2, medical_enhancement * mid_tone_mask * 0.2);
	}
	
	COLOR = vec4(clamp(color, 0.0, 1.0), 1.0);
}
"""
	
	material.shader = shader
	material.set_shader_parameter("contrast", 1.0)
	material.set_shader_parameter("brightness", 0.0)
	material.set_shader_parameter("saturation", 1.0)
	material.set_shader_parameter("gamma", 1.0)
	material.set_shader_parameter("white_balance", Vector3(1.0, 1.0, 1.0))
	material.set_shader_parameter("medical_enhancement", 0.0)
	
	return material

func _connect_to_systems():
	"""Connect to other rendering systems"""
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root.has_node("PerformanceMonitor"):
		performance_monitor = tree.root.get_node("PerformanceMonitor")
		print("[PostProcessing] Connected to performance monitoring")

# === PRESET MANAGEMENT ===

func apply_preset(preset_name: String):
	"""Apply a post-processing preset"""
	if not preset_name in POST_PROCESSING_PRESETS:
		push_error("[PostProcessing] Unknown preset: " + preset_name)
		return
	
	current_preset = preset_name
	_apply_preset(preset_name)

func _apply_preset(preset_name: String):
	"""Internal method to apply post-processing preset"""
	var preset = POST_PROCESSING_PRESETS[preset_name]
	
	print("[PostProcessing] Applying preset: %s - %s" % [preset_name, preset.description])
	
	# Apply SSAO settings
	if preset.ssao_enabled:
		_configure_ssao(preset.ssao_intensity, preset.ssao_radius, preset.ssao_quality)
	else:
		_disable_ssao()
	
	# Apply SSR settings
	if preset.ssr_enabled:
		_configure_ssr(preset.ssr_max_steps, preset.ssr_quality)
	else:
		_disable_ssr()
	
	# Apply SDFGI settings
	if preset.sdfgi_enabled:
		_configure_sdfgi()
	else:
		_disable_sdfgi()
	
	# Apply glow settings
	if preset.glow_enabled:
		_configure_glow()
	else:
		_disable_glow()
	
	# Apply edge enhancement
	edge_enhancement_enabled = preset.edge_enhancement
	
	# Apply color correction
	_configure_color_correction(preset.color_correction)

# === SSAO CONFIGURATION ===

func _configure_ssao(intensity: float, radius: float, quality: String):
	"""Configure Screen Space Ambient Occlusion"""
	if not environment_resource:
		return
	
	if is_metal_backend:
		_configure_ssao_metal_compatible(intensity, radius, quality)
	else:
		_configure_ssao_standard(intensity, radius, quality)
	
	ssao_enabled = true
	print("[PostProcessing] SSAO configured: intensity=%.2f, radius=%.2f, quality=%s (Metal: %s)" % [intensity, radius, quality, is_metal_backend])

func _configure_ssao_standard(intensity: float, radius: float, quality: String):
	"""Configure SSAO for standard rendering backends"""
	environment_resource.ssao_enabled = true
	environment_resource.ssao_radius = radius
	environment_resource.ssao_intensity = intensity
	environment_resource.ssao_power = 1.5
	environment_resource.ssao_detail = 0.5
	environment_resource.ssao_horizon = 0.06
	environment_resource.ssao_sharpness = 0.98
	
	# Configure SSAO quality using parameters instead of direct assignment
	# This provides better compatibility with Godot 4.4
	match quality:
		"ultra":
			environment_resource.ssao_detail = 0.7
			environment_resource.ssao_horizon = 0.04
			environment_resource.ssao_sharpness = 0.99
		"high":
			environment_resource.ssao_detail = 0.5
			environment_resource.ssao_horizon = 0.06
			environment_resource.ssao_sharpness = 0.98
		"medium":
			environment_resource.ssao_detail = 0.4
			environment_resource.ssao_horizon = 0.08
			environment_resource.ssao_sharpness = 0.95
		"low":
			environment_resource.ssao_detail = 0.3
			environment_resource.ssao_horizon = 0.1
			environment_resource.ssao_sharpness = 0.9

func _configure_ssao_metal_compatible(intensity: float, radius: float, quality: String):
	"""Configure SSAO with Metal backend compatibility"""
	environment_resource.ssao_enabled = true
	environment_resource.ssao_radius = radius * 0.8  # Slightly reduce radius for Metal compatibility
	environment_resource.ssao_intensity = intensity
	environment_resource.ssao_power = 1.3  # Adjusted for Metal
	environment_resource.ssao_detail = 0.4  # Reduced for Metal stability
	environment_resource.ssao_horizon = 0.08  # Adjusted for Metal
	environment_resource.ssao_sharpness = 0.95  # Slightly reduced for Metal
	
	# Note: In Godot 4.4, ssao_quality is set differently based on the rendering method
	# We'll use the rendering server to configure quality instead of direct assignment
	var quality_setting = RenderingServer.ENV_SSAO_QUALITY_MEDIUM
	match quality:
		"ultra":
			quality_setting = RenderingServer.ENV_SSAO_QUALITY_HIGH  # Downgrade ultra to high for Metal
		"high":
			quality_setting = RenderingServer.ENV_SSAO_QUALITY_HIGH
		"medium":
			quality_setting = RenderingServer.ENV_SSAO_QUALITY_MEDIUM
		"low":
			quality_setting = RenderingServer.ENV_SSAO_QUALITY_LOW
	
	# Use RenderingServer to set SSAO quality for better compatibility
	if environment_resource.has_method("set_ssao_quality"):
		environment_resource.set_ssao_quality(quality_setting)
	else:
		# Fallback: configure SSAO parameters manually for quality levels
		match quality:
			"ultra", "high":
				environment_resource.ssao_detail = 0.5
				environment_resource.ssao_horizon = 0.06
				environment_resource.ssao_sharpness = 0.98
			"medium":
				environment_resource.ssao_detail = 0.4
				environment_resource.ssao_horizon = 0.08
				environment_resource.ssao_sharpness = 0.95
			"low":
				environment_resource.ssao_detail = 0.3
				environment_resource.ssao_horizon = 0.1
				environment_resource.ssao_sharpness = 0.9

func _disable_ssao():
	"""Disable Screen Space Ambient Occlusion"""
	if environment_resource:
		environment_resource.ssao_enabled = false
	ssao_enabled = false
	print("[PostProcessing] SSAO disabled")

# === SSR CONFIGURATION ===

func _configure_ssr(max_steps: int, quality: String):
	"""Configure Screen Space Reflections"""
	if not environment_resource:
		return
	
	environment_resource.ssr_enabled = true
	environment_resource.ssr_max_steps = max_steps
	environment_resource.ssr_fade_in = 0.15
	environment_resource.ssr_fade_out = 2.0
	environment_resource.ssr_depth_tolerance = 0.2
	
	match quality:
		"high":
			environment_resource.ssr_fade_in = 0.1
			environment_resource.ssr_depth_tolerance = 0.1
		"medium":
			environment_resource.ssr_fade_in = 0.15
			environment_resource.ssr_depth_tolerance = 0.2
		"low":
			environment_resource.ssr_fade_in = 0.2
			environment_resource.ssr_depth_tolerance = 0.3
	
	ssr_enabled = true
	print("[PostProcessing] SSR configured: max_steps=%d, quality=%s" % [max_steps, quality])

func _disable_ssr():
	"""Disable Screen Space Reflections"""
	if environment_resource:
		environment_resource.ssr_enabled = false
	ssr_enabled = false
	print("[PostProcessing] SSR disabled")

# === SDFGI CONFIGURATION ===

func _configure_sdfgi():
	"""Configure Signed Distance Field Global Illumination"""
	if not environment_resource:
		return
	
	environment_resource.sdfgi_enabled = true
	environment_resource.sdfgi_use_occlusion = true
	environment_resource.sdfgi_read_sky_light = true
	environment_resource.sdfgi_bounce_feedback = 0.5
	environment_resource.sdfgi_normal_bias = 1.1
	environment_resource.sdfgi_probe_bias = 1.1
	environment_resource.sdfgi_y_scale = Environment.SDFGI_Y_SCALE_75_PERCENT
	
	sdfgi_enabled = true
	print("[PostProcessing] SDFGI configured")

func _disable_sdfgi():
	"""Disable Signed Distance Field Global Illumination"""
	if environment_resource:
		environment_resource.sdfgi_enabled = false
	sdfgi_enabled = false
	print("[PostProcessing] SDFGI disabled")

# === GLOW CONFIGURATION ===

func _configure_glow():
	"""Configure glow effect"""
	if not environment_resource:
		return
	
	environment_resource.glow_enabled = true
	# Note: glow_levels property was removed in Godot 4 - glow now uses automatic level calculation
	environment_resource.glow_intensity = 0.8
	environment_resource.glow_strength = 1.0
	environment_resource.glow_mix = 0.05
	environment_resource.glow_bloom = 0.0
	environment_resource.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
	
	# Note: Metal backend warning about LOD bias is expected and doesn't affect functionality
	# This is a known limitation of the Metal renderer with texture samplers
	glow_enabled = true
	print("[PostProcessing] Glow configured")

func _disable_glow():
	"""Disable glow effect"""
	if environment_resource:
		environment_resource.glow_enabled = false
	glow_enabled = false
	print("[PostProcessing] Glow disabled")

# === COLOR CORRECTION ===

func _configure_color_correction(mode: String):
	"""Configure color correction based on mode"""
	if not medical_color_correction_material:
		return
	
	match mode:
		"medical":
			medical_color_correction_material.set_shader_parameter("contrast", 1.3)
			medical_color_correction_material.set_shader_parameter("brightness", 0.05)
			medical_color_correction_material.set_shader_parameter("saturation", 0.9)
			medical_color_correction_material.set_shader_parameter("gamma", 0.9)
			medical_color_correction_material.set_shader_parameter("medical_enhancement", 0.8)
		"clinical":
			medical_color_correction_material.set_shader_parameter("contrast", 1.2)
			medical_color_correction_material.set_shader_parameter("brightness", 0.0)
			medical_color_correction_material.set_shader_parameter("saturation", 0.95)
			medical_color_correction_material.set_shader_parameter("gamma", 1.0)
			medical_color_correction_material.set_shader_parameter("medical_enhancement", 0.4)
		"enhanced":
			medical_color_correction_material.set_shader_parameter("contrast", 1.1)
			medical_color_correction_material.set_shader_parameter("brightness", 0.02)
			medical_color_correction_material.set_shader_parameter("saturation", 1.1)
			medical_color_correction_material.set_shader_parameter("gamma", 1.0)
			medical_color_correction_material.set_shader_parameter("medical_enhancement", 0.2)
		"standard":
			medical_color_correction_material.set_shader_parameter("contrast", 1.0)
			medical_color_correction_material.set_shader_parameter("brightness", 0.0)
			medical_color_correction_material.set_shader_parameter("saturation", 1.0)
			medical_color_correction_material.set_shader_parameter("gamma", 1.0)
			medical_color_correction_material.set_shader_parameter("medical_enhancement", 0.0)
	
	print("[PostProcessing] Color correction configured: " + mode)

# === PERFORMANCE MONITORING ===

func _process(delta):
	"""Monitor performance and adjust quality if needed"""
	if not adaptive_quality:
		return
	
	quality_adjustment_timer += delta
	if quality_adjustment_timer < performance_monitoring_interval:
		return
	
	quality_adjustment_timer = 0.0
	
	# Collect performance metrics
	var current_fps = Engine.get_frames_per_second()
	frame_time_samples.append(current_fps)
	
	if frame_time_samples.size() > 10:
		frame_time_samples.pop_front()
	
	# Calculate average FPS
	var avg_fps = 0.0
	for fps in frame_time_samples:
		avg_fps += fps
	avg_fps /= frame_time_samples.size()
	
	# Adjust quality based on performance
	_adjust_quality_for_performance(avg_fps)

func _adjust_quality_for_performance(avg_fps: float):
	"""Adjust post-processing quality based on performance"""
	var performance_ratio = avg_fps / target_fps
	var target_preset = current_preset
	
	# Prevent rapid quality changes
	if Time.get_time_dict_from_system()["second"] - last_quality_adjustment < 3.0:
		return
	
	if performance_ratio < quality_adjustment_threshold:
		# Performance is poor, reduce quality
		match current_preset:
			"medical_maximum":
				target_preset = "clinical_high"
			"clinical_high":
				target_preset = "educational_balanced"
			"educational_balanced":
				target_preset = "performance_optimized"
	elif performance_ratio > 1.1:
		# Performance is good, can increase quality
		match current_preset:
			"performance_optimized":
				target_preset = "educational_balanced"
			"educational_balanced":
				target_preset = "clinical_high"
			"clinical_high":
				if medical_accuracy_mode:
					target_preset = "medical_maximum"
	
	if target_preset != current_preset:
		apply_preset(target_preset)
		last_quality_adjustment = Time.get_time_dict_from_system()["second"]
		performance_adjusted.emit(avg_fps, target_preset)

# === PUBLIC API ===

func set_post_processing_quality(quality: String):
	"""Set overall post-processing quality"""
	if quality not in QUALITY_LEVELS:
		push_error("[PostProcessing] Invalid quality level: " + quality)
		return
	
	post_processing_quality = quality
	
	# Map quality to appropriate preset
	match quality:
		"ultra":
			apply_preset("medical_maximum")
		"high":
			apply_preset("clinical_high")
		"medium":
			apply_preset("educational_balanced")
		"low":
			apply_preset("performance_optimized")
	
	post_processing_quality_changed.emit(quality)

func toggle_effect(effect_name: String, enabled: bool):
	"""Toggle individual post-processing effect"""
	match effect_name:
		"ssao":
			if enabled:
				_configure_ssao(1.0, 0.6, "high")
			else:
				_disable_ssao()
		"ssr":
			if enabled:
				_configure_ssr(32, "medium")
			else:
				_disable_ssr()
		"sdfgi":
			if enabled:
				_configure_sdfgi()
			else:
				_disable_sdfgi()
		"glow":
			if enabled:
				_configure_glow()
			else:
				_disable_glow()
		"edge_enhancement":
			edge_enhancement_enabled = enabled
	
	effect_toggled.emit(effect_name, enabled)

func get_available_presets() -> Array:
	"""Get list of available post-processing presets"""
	return POST_PROCESSING_PRESETS.keys()

func get_preset_description(preset_name: String) -> String:
	"""Get description of a post-processing preset"""
	var preset = POST_PROCESSING_PRESETS.get(preset_name, {})
	return preset.get("description", "Unknown preset")

func get_diagnostics() -> Dictionary:
	"""Get diagnostic information about post-processing system"""
	return {
		"current_preset": current_preset,
		"post_processing_quality": post_processing_quality,
		"ssao_enabled": ssao_enabled,
		"ssr_enabled": ssr_enabled,
		"sdfgi_enabled": sdfgi_enabled,
		"glow_enabled": glow_enabled,
		"edge_enhancement_enabled": edge_enhancement_enabled,
		"adaptive_quality": adaptive_quality,
		"target_fps": target_fps,
		"current_fps": Engine.get_frames_per_second(),
		"medical_accuracy_mode": medical_accuracy_mode,
		"platform_compatibility": {
			"is_metal_backend": is_metal_backend,
			"os_name": OS.get_name(),
			"processor": OS.get_processor_name(),
			"shader_compilation_status": "fixed_godot_4_4_1",
			"educational_fallbacks_available": true
		},
		"shader_system": {
			"edge_enhancement_available": edge_enhancement_material != null,
			"color_correction_available": medical_color_correction_material != null,
			"screen_texture_migration": "completed",
			"metal_compatibility": "implemented"
		}
	}

func reset_to_defaults():
	"""Reset post-processing to default settings"""
	apply_preset("clinical_high")
	adaptive_quality = true
	medical_accuracy_mode = true
	print("[PostProcessing] Reset to defaults")
