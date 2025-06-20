## Medical-Grade Area Lighting System for NeuroVision
##
## Advanced lighting system designed specifically for medical visualization
## of brain anatomy with professional examination lighting standards.

class_name MedicalGradeLightingManager
extends Node3D

# === SIGNALS ===
signal lighting_preset_changed(preset_name: String)
signal quality_level_changed(quality: String)
signal lighting_intensity_adjusted(intensity: float)

# === CONSTANTS ===
const MEDICAL_LIGHTING_PRESETS = {
	"examination": {
		"description": "Medical examination lighting - bright, even, clinical",
		"main_intensity": 1.5,
		"fill_intensity": 0.8,
		"rim_intensity": 0.6,
		"color_temperature": 6500,  # Daylight white
		"shadows_enabled": true,
		"shadow_softness": 0.4
	},
	"surgical": {
		"description": "Surgical lighting - intense, focused, minimal shadows",
		"main_intensity": 2.2,
		"fill_intensity": 1.2,
		"rim_intensity": 0.3,
		"color_temperature": 6000,  # Slightly warm white
		"shadows_enabled": false,
		"shadow_softness": 0.0
	},
	"anatomical": {
		"description": "Anatomical study - balanced, detailed, educational",
		"main_intensity": 1.2,
		"fill_intensity": 0.6,
		"rim_intensity": 0.8,
		"color_temperature": 5500,  # Neutral white
		"shadows_enabled": true,
		"shadow_softness": 0.6
	},
	"pathology": {
		"description": "Pathology examination - enhanced contrast, clinical accuracy",
		"main_intensity": 1.8,
		"fill_intensity": 0.4,
		"rim_intensity": 1.0,
		"color_temperature": 6200,  # Cool white
		"shadows_enabled": true,
		"shadow_softness": 0.2
	},
	"research": {
		"description": "Research visualization - balanced, accurate color reproduction",
		"main_intensity": 1.0,
		"fill_intensity": 0.7,
		"rim_intensity": 0.5,
		"color_temperature": 5800,  # Standard white
		"shadows_enabled": true,
		"shadow_softness": 0.5
	}
}

const QUALITY_LEVELS = ["low", "medium", "high", "maximum"]
const LIGHT_TYPES = ["main", "fill", "rim", "ambient"]

# === EXPORTS ===
@export_group("Medical Lighting Configuration")
@export var current_preset: String = "examination"
@export var lighting_quality: String = "high"
@export var adaptive_quality: bool = true
@export var medical_accuracy_mode: bool = true

@export_group("Performance Settings")
@export var max_shadow_distance: float = 50.0
@export var shadow_cascade_count: int = 4
@export var use_area_lights: bool = true
@export var area_light_size: float = 2.0

@export_group("Educational Context")
@export var learning_mode: String = "intermediate"  # beginner, intermediate, advanced
@export var clinical_focus: bool = false
@export var enhance_contrast: bool = false

# === LIGHTING NODES ===
@onready var main_light: DirectionalLight3D
@onready var fill_light_left: DirectionalLight3D
@onready var fill_light_right: DirectionalLight3D
@onready var rim_light: DirectionalLight3D
@onready var ambient_light: Node3D
@onready var area_lights_container: Node3D
@onready var environment: Environment

# === PRIVATE VARIABLES ===
var current_lighting_data: Dictionary = {}
var performance_monitor = null
var brain_material_manager: RealisticBrainMaterialManager
var lighting_transition_tween: Tween
var area_lights: Array[Light3D] = []

# Performance tracking
var frame_time_samples: Array[float] = []
var target_fps: float = 60.0
var quality_adjustment_timer: float = 0.0

# === INITIALIZATION ===

func _ready():
	_initialize_lighting_setup()
	_connect_performance_monitoring()
	_apply_lighting_preset(current_preset)
	print("[MedicalLighting] Medical-grade lighting system initialized")

func _initialize_lighting_setup():
	"""Initialize the lighting node structure"""
	# Create main directional light
	main_light = DirectionalLight3D.new()
	main_light.name = "MainLight"
	main_light.position = Vector3(0, 10, 5)
	main_light.rotation_degrees = Vector3(-45, 0, 0)
	add_child(main_light)
	
	# Create fill lights for even illumination
	fill_light_left = DirectionalLight3D.new()
	fill_light_left.name = "FillLightLeft"
	fill_light_left.position = Vector3(-5, 5, 0)
	fill_light_left.rotation_degrees = Vector3(-30, 45, 0)
	add_child(fill_light_left)
	
	fill_light_right = DirectionalLight3D.new()
	fill_light_right.name = "FillLightRight"
	fill_light_right.position = Vector3(5, 5, 0)
	fill_light_right.rotation_degrees = Vector3(-30, -45, 0)
	add_child(fill_light_right)
	
	# Create rim light for depth perception
	rim_light = DirectionalLight3D.new()
	rim_light.name = "RimLight"
	rim_light.position = Vector3(0, 0, -10)
	rim_light.rotation_degrees = Vector3(0, 180, 0)
	add_child(rim_light)
	
	# Create container for area lights
	area_lights_container = Node3D.new()
	area_lights_container.name = "AreaLights"
	add_child(area_lights_container)
	
	if use_area_lights:
		_create_area_lights()

func _create_area_lights():
	"""Create area lights for soft, medical-grade illumination"""
	# Create multiple area lights positioned around the brain model
	var area_light_positions = [
		Vector3(0, 8, 3),    # Top front
		Vector3(-4, 6, 2),   # Left side
		Vector3(4, 6, 2),    # Right side
		Vector3(0, 4, -3)    # Back
	]
	
	for i in range(area_light_positions.size()):
		var area_light = _create_single_area_light(i, area_light_positions[i])
		area_lights_container.add_child(area_light)
		area_lights.append(area_light)

func _create_single_area_light(index: int, light_position: Vector3) -> Light3D:
	"""Create a single area light with medical-grade properties"""
	# Note: Godot doesn't have true area lights, so we'll use OmniLight3D
	# with specific settings to approximate area light behavior
	var light = OmniLight3D.new()
	light.name = "AreaLight_" + str(index)
	light.position = light_position
	
	# Configure for medical lighting
	light.light_energy = 0.8
	light.light_indirect_energy = 0.3
	light.light_size = area_light_size
	light.omni_range = 15.0
	light.omni_attenuation = 0.8
	
	# Enable shadows for main area lights
	if index < 2:  # Only first two area lights cast shadows for performance
		light.shadow_enabled = true
		light.shadow_bias = 0.1
		light.shadow_normal_bias = 1.0
		light.shadow_blur = 2.0
	
	return light

func _connect_performance_monitoring():
	"""Connect to performance monitoring for adaptive quality"""
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root.has_node("PerformanceMonitor"):
		performance_monitor = tree.root.get_node("PerformanceMonitor")
		print("[MedicalLighting] Connected to performance monitoring")

# === LIGHTING PRESET MANAGEMENT ===

func apply_lighting_preset(preset_name: String):
	"""Apply a medical lighting preset"""
	if not preset_name in MEDICAL_LIGHTING_PRESETS:
		push_error("[MedicalLighting] Unknown preset: " + preset_name)
		return
	
	current_preset = preset_name
	_apply_lighting_preset(preset_name)

func _apply_lighting_preset(preset_name: String):
	"""Internal method to apply lighting preset"""
	var preset = MEDICAL_LIGHTING_PRESETS[preset_name]
	current_lighting_data = preset.duplicate()
	
	print("[MedicalLighting] Applying preset: %s - %s" % [preset_name, preset.description])
	
	# Calculate color temperature
	var light_color = _color_temperature_to_rgb(preset.color_temperature)
	
	# Configure main light
	if main_light:
		main_light.light_energy = preset.main_intensity
		main_light.light_color = light_color
		main_light.shadow_enabled = preset.shadows_enabled
		if preset.shadows_enabled:
			_configure_shadows(main_light, preset.shadow_softness)
	
	# Configure fill lights
	if fill_light_left:
		fill_light_left.light_energy = preset.fill_intensity * 0.7
		fill_light_left.light_color = light_color.lightened(0.1)
		fill_light_left.shadow_enabled = false
	
	if fill_light_right:
		fill_light_right.light_energy = preset.fill_intensity * 0.7
		fill_light_right.light_color = light_color.lightened(0.1)
		fill_light_right.shadow_enabled = false
	
	# Configure rim light
	if rim_light:
		rim_light.light_energy = preset.rim_intensity
		rim_light.light_color = light_color.lightened(0.2)
		rim_light.shadow_enabled = false
	
	# Configure area lights
	_configure_area_lights(preset, light_color)
	
	# Apply educational context adjustments
	_apply_educational_context_lighting()
	
	lighting_preset_changed.emit(preset_name)

func _configure_shadows(light: DirectionalLight3D, softness: float):
	"""Configure shadow settings for medical accuracy"""
	light.shadow_enabled = true
	light.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	light.directional_shadow_max_distance = max_shadow_distance
	
	# Adjust shadow quality based on lighting quality
	match lighting_quality:
		"maximum":
			light.directional_shadow_split_1 = 0.1
			light.directional_shadow_split_2 = 0.3
			light.directional_shadow_split_3 = 0.6
			light.shadow_bias = 0.05
			light.shadow_normal_bias = 0.5
		"high":
			light.directional_shadow_split_1 = 0.15
			light.directional_shadow_split_2 = 0.35
			light.directional_shadow_split_3 = 0.65
			light.shadow_bias = 0.1
			light.shadow_normal_bias = 1.0
		"medium":
			light.directional_shadow_split_1 = 0.2
			light.directional_shadow_split_2 = 0.4
			light.directional_shadow_split_3 = 0.7
			light.shadow_bias = 0.15
			light.shadow_normal_bias = 1.5
		"low":
			light.directional_shadow_split_1 = 0.3
			light.directional_shadow_split_2 = 0.6
			light.directional_shadow_split_3 = 0.8
			light.shadow_bias = 0.2
			light.shadow_normal_bias = 2.0
	
	# Apply softness
	light.shadow_blur = softness * 3.0

func _configure_area_lights(preset: Dictionary, base_color: Color):
	"""Configure area lights based on preset"""
	var area_intensity = preset.fill_intensity * 0.5
	
	for light in area_lights:
		if light is OmniLight3D:
			light.light_energy = area_intensity
			light.light_color = base_color
			light.light_indirect_energy = area_intensity * 0.4
			
			# Adjust shadow settings for performance
			if light.shadow_enabled:
				match lighting_quality:
					"maximum", "high":
						light.shadow_bias = 0.1
						light.shadow_blur = preset.shadow_softness * 2.0
					"medium":
						light.shadow_bias = 0.15
						light.shadow_blur = preset.shadow_softness * 1.5
					"low":
						light.shadow_enabled = false

func _apply_educational_context_lighting():
	"""Apply lighting adjustments based on educational context"""
	var intensity_modifier = 1.0
	var contrast_modifier = 1.0
	
	# Adjust based on learning mode
	match learning_mode:
		"beginner":
			# Brighter, more dramatic lighting for better visibility
			intensity_modifier = 1.2
			contrast_modifier = 1.3
		"intermediate":
			# Balanced lighting
			intensity_modifier = 1.0
			contrast_modifier = 1.0
		"advanced":
			# More realistic, subdued lighting
			intensity_modifier = 0.9
			contrast_modifier = 0.9
	
	# Clinical focus adjustments
	if clinical_focus:
		intensity_modifier *= 1.3
		contrast_modifier *= 1.4
		# Reduce warm tones for clinical accuracy
		_adjust_color_temperature(200)  # Cooler
	
	# Enhanced contrast for accessibility
	if enhance_contrast:
		contrast_modifier *= 1.5
		_increase_rim_lighting(0.3)
	
	# Apply modifiers to all lights
	_apply_lighting_modifiers(intensity_modifier, contrast_modifier)

func _apply_lighting_modifiers(intensity_mod: float, contrast_mod: float):
	"""Apply intensity and contrast modifiers to all lights"""
	if main_light:
		main_light.light_energy *= intensity_mod
	
	if fill_light_left:
		fill_light_left.light_energy *= intensity_mod * (2.0 - contrast_mod)
	
	if fill_light_right:
		fill_light_right.light_energy *= intensity_mod * (2.0 - contrast_mod)
	
	if rim_light:
		rim_light.light_energy *= intensity_mod * contrast_mod
	
	for light in area_lights:
		if light is OmniLight3D:
			light.light_energy *= intensity_mod

# === COLOR TEMPERATURE AND LIGHTING UTILITIES ===

func _color_temperature_to_rgb(kelvin: float) -> Color:
	"""Convert color temperature in Kelvin to RGB color"""
	# Simplified color temperature to RGB conversion
	# Based on Tanner Helland's algorithm
	var temp = kelvin / 100.0
	var red: float
	var green: float
	var blue: float
	
	# Calculate red component
	if temp <= 66:
		red = 255
	else:
		red = temp - 60
		red = 329.698727446 * pow(red, -0.1332047592)
		red = clamp(red, 0, 255)
	
	# Calculate green component
	if temp <= 66:
		green = temp
		green = 99.4708025861 * log(green) - 161.1195681661
		green = clamp(green, 0, 255)
	else:
		green = temp - 60
		green = 288.1221695283 * pow(green, -0.0755148492)
		green = clamp(green, 0, 255)
	
	# Calculate blue component
	if temp >= 66:
		blue = 255
	elif temp <= 19:
		blue = 0
	else:
		blue = temp - 10
		blue = 138.5177312231 * log(blue) - 305.0447927307
		blue = clamp(blue, 0, 255)
	
	return Color(red / 255.0, green / 255.0, blue / 255.0, 1.0)

func _adjust_color_temperature(kelvin_offset: float):
	"""Adjust color temperature of all lights"""
	var new_temp = current_lighting_data.color_temperature + kelvin_offset
	var new_color = _color_temperature_to_rgb(new_temp)
	
	if main_light:
		main_light.light_color = new_color
	if fill_light_left:
		fill_light_left.light_color = new_color.lightened(0.1)
	if fill_light_right:
		fill_light_right.light_color = new_color.lightened(0.1)
	if rim_light:
		rim_light.light_color = new_color.lightened(0.2)

func _increase_rim_lighting(amount: float):
	"""Increase rim lighting for better contrast"""
	if rim_light:
		rim_light.light_energy += amount

# === PERFORMANCE AND QUALITY MANAGEMENT ===

func _process(delta):
	"""Monitor performance and adjust quality if needed"""
	if not adaptive_quality:
		return
	
	quality_adjustment_timer += delta
	if quality_adjustment_timer < 1.0:  # Check every second
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
	"""Adjust lighting quality based on performance"""
	var target_quality = lighting_quality
	var current_index = QUALITY_LEVELS.find(lighting_quality)
	
	if avg_fps < target_fps * 0.8:  # Below 80% of target
		# Reduce quality
		if current_index > 0:
			target_quality = QUALITY_LEVELS[current_index - 1]
	elif avg_fps > target_fps * 0.95:  # Above 95% of target
		# Increase quality
		if current_index < QUALITY_LEVELS.size() - 1:
			target_quality = QUALITY_LEVELS[current_index + 1]
	
	if target_quality != lighting_quality:
		set_lighting_quality(target_quality)

func set_lighting_quality(quality: String):
	"""Set lighting quality level"""
	if quality not in QUALITY_LEVELS:
		push_error("[MedicalLighting] Invalid quality level: " + quality)
		return
	
	if quality == lighting_quality:
		return
	
	var old_quality = lighting_quality
	lighting_quality = quality
	
	# Reapply current preset with new quality
	_apply_lighting_preset(current_preset)
	
	quality_level_changed.emit(quality)
	print("[MedicalLighting] Quality changed: %s -> %s" % [old_quality, quality])

# === PUBLIC API ===

func get_available_presets() -> Array:
	"""Get list of available lighting presets"""
	return MEDICAL_LIGHTING_PRESETS.keys()

func get_preset_description(preset_name: String) -> String:
	"""Get description of a lighting preset"""
	var preset = MEDICAL_LIGHTING_PRESETS.get(preset_name, {})
	return preset.get("description", "Unknown preset")

func set_learning_mode(mode: String):
	"""Set educational learning mode"""
	if mode in ["beginner", "intermediate", "advanced"]:
		learning_mode = mode
		_apply_educational_context_lighting()
		print("[MedicalLighting] Learning mode set to: " + mode)

func set_clinical_focus(enabled: bool):
	"""Enable or disable clinical focus mode"""
	clinical_focus = enabled
	_apply_educational_context_lighting()
	print("[MedicalLighting] Clinical focus: " + str(enabled))

func adjust_overall_intensity(intensity: float):
	"""Adjust overall lighting intensity"""
	intensity = clamp(intensity, 0.1, 3.0)
	
	if main_light:
		main_light.light_energy = current_lighting_data.main_intensity * intensity
	if fill_light_left:
		fill_light_left.light_energy = current_lighting_data.fill_intensity * 0.7 * intensity
	if fill_light_right:
		fill_light_right.light_energy = current_lighting_data.fill_intensity * 0.7 * intensity
	if rim_light:
		rim_light.light_energy = current_lighting_data.rim_intensity * intensity
	
	for light in area_lights:
		if light is OmniLight3D:
			light.light_energy = current_lighting_data.fill_intensity * 0.5 * intensity
	
	lighting_intensity_adjusted.emit(intensity)

func get_diagnostics() -> Dictionary:
	"""Get diagnostic information about lighting system"""
	return {
		"current_preset": current_preset,
		"lighting_quality": lighting_quality,
		"adaptive_quality": adaptive_quality,
		"learning_mode": learning_mode,
		"clinical_focus": clinical_focus,
		"area_lights_count": area_lights.size(),
		"current_fps": Engine.get_frames_per_second(),
		"target_fps": target_fps,
		"lighting_data": current_lighting_data
	}

func reset_to_defaults():
	"""Reset lighting to default medical examination preset"""
	apply_lighting_preset("examination")
	set_lighting_quality("high")
	learning_mode = "intermediate"
	clinical_focus = false
	enhance_contrast = false
	print("[MedicalLighting] Reset to defaults")