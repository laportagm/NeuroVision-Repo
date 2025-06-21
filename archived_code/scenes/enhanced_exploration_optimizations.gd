## Enhanced Exploration Scene Optimizations
##
## This script extends the EnhancedExplorationScene with performance optimizations
## and connects the real-time monitoring systems.

extends Node

# This would be added to the EnhancedExplorationScene.gd file

# === PERFORMANCE OPTIMIZATION METHODS ===

func _setup_performance_integration() -> void:
	"""Initialize performance monitoring and optimization systems"""
	print("[EnhancedExploration] Setting up performance integration")
	
	# Create real-time performance monitor
	var perf_monitor = RealTimePerformanceMonitor.new()
	perf_monitor.name = "PerformanceMonitor"
	add_child(perf_monitor)
	
	# Connect UI elements to performance monitor
	var ui_elements = {
		"fps_indicator": fps_indicator,
		"frame_time_indicator": frame_time_indicator,
		"quality_indicator": quality_indicator,
		"memory_usage": memory_usage,
		"cpu_usage": cpu_usage,
		"gpu_usage": gpu_usage,
		"brain_model_complexity": brain_model_complexity,
		"texture_memory": texture_memory,
		"performance_label": performance_label,
		"learning_analytics": learning_analytics
	}
	
	perf_monitor.connect_ui_elements(ui_elements)
	
	# Connect performance signals
	perf_monitor.performance_warning.connect(_on_performance_warning)
	perf_monitor.quality_adjustment_needed.connect(_on_quality_adjustment)
	
	# Show performance panel toggle
	if performance_toggle:
		performance_toggle.pressed.connect(_toggle_performance_panel)

func _setup_brain_interaction_system() -> void:
	"""Initialize the brain interaction controller"""
	print("[EnhancedExploration] Setting up brain interaction system")
	
	# Find or create interaction controller
	var interaction_system = $EducationalSystemsContainer/BrainInteractionSystem
	if not interaction_system:
		push_error("BrainInteractionSystem not found!")
		return
	
	# Add interaction controller if not present
	var controller = interaction_system.get_node_or_null("InteractionController")
	if not controller:
		controller = BrainInteractionController.new()
		controller.name = "InteractionController"
		interaction_system.add_child(controller)
	
	# Initialize with camera and structures
	controller.initialize(camera, _brain_structures)
	
	# Connect interaction signals
	controller.structure_selected.connect(_on_brain_structure_selected)
	controller.structure_highlighted.connect(_on_brain_structure_highlighted)
	
	# Store reference
	_brain_interaction = controller

func _optimize_lighting_for_medical_visualization() -> void:
	"""Optimize lighting setup for medical visualization"""
	print("[EnhancedExploration] Optimizing medical lighting")
	
	# Enable key light if disabled
	if key_light and not key_light.visible:
		key_light.visible = true
		key_light.light_energy = 0.8
		key_light.light_color = Color(0.95, 0.95, 1.0)
		key_light.shadow_enabled = GraphicsOptimizationManager.can_use_shadows()
		print("  ✓ KeyLight enabled for medical visualization")
	
	# Enable rim light for depth
	if rim_light and not rim_light.visible:
		rim_light.visible = true
		rim_light.light_energy = 0.3
		rim_light.light_color = Color(0.7, 0.8, 0.9)
		rim_light.shadow_enabled = false  # No shadows on rim light
		print("  ✓ RimLight enabled for anatomical depth")
	
	# Apply lighting preset
	_apply_lighting_preset("default")

func _apply_lighting_preset(preset_name: String) -> void:
	"""Apply a lighting preset for different viewing modes"""
	if not _lighting_presets.has(preset_name):
		return
		
	var preset = _lighting_presets[preset_name]
	
	if key_light:
		key_light.light_energy = preset.key_intensity
	if fill_light:
		fill_light.light_energy = preset.fill_intensity
	if rim_light:
		rim_light.light_energy = preset.rim_intensity
	
	if environment and environment.environment:
		environment.environment.ambient_light_energy = preset.ambient_intensity

func _toggle_performance_panel() -> void:
	"""Toggle the detailed performance monitoring panel"""
	if performance_panel:
		performance_panel.visible = !performance_panel.visible
		
		# Update button text
		if performance_toggle:
			performance_toggle.text = "Hide" if performance_panel.visible else "Metrics"

func _on_performance_warning(metric: String, value: float, threshold: float) -> void:
	"""Handle performance warnings"""
	match metric:
		"fps":
			push_warning("Low FPS: %.1f (target: %.1f)" % [value, threshold])
			if status_label:
				status_label.text = "Performance: Low FPS"
				status_label.modulate = Color(1.0, 0.8, 0.4)
		
		"memory":
			push_warning("High memory usage: %.0fMB" % value)
			if status_label:
				status_label.text = "Warning: High Memory"
				status_label.modulate = Color(1.0, 0.6, 0.4)
		
		"frame_time":
			push_warning("High frame time: %.1fms" % value)

func _on_quality_adjustment(new_quality: String) -> void:
	"""Handle automatic quality adjustments"""
	print("[Performance] Auto-adjusting quality to: " + new_quality)
	
	# Update UI to reflect change
	if quality_indicator:
		quality_indicator.text = "Quality: " + new_quality.to_upper()
	
	# Apply quality-specific optimizations
	match new_quality:
		"low":
			_apply_low_quality_settings()
		"medium":
			_apply_medium_quality_settings()
		"high":
			_apply_high_quality_settings()

func _apply_low_quality_settings() -> void:
	"""Apply settings for low-end hardware"""
	# Disable expensive effects
	if environment and environment.environment:
		environment.environment.ssao_enabled = false
		environment.environment.glow_enabled = false
		environment.environment.volumetric_fog_enabled = false
	
	# Reduce shadow quality
	if key_light:
		key_light.shadow_enabled = false
	
	# Simplify materials
	_optimize_materials_for_integrated()

func _apply_medium_quality_settings() -> void:
	"""Apply balanced quality settings"""
	if environment and environment.environment:
		environment.environment.ssao_enabled = false
		environment.environment.glow_enabled = true
		environment.environment.glow_intensity = 0.2
	
	if key_light:
		key_light.shadow_enabled = true
		key_light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL

func _apply_high_quality_settings() -> void:
	"""Apply high quality settings for capable hardware"""
	if environment and environment.environment:
		environment.environment.ssao_enabled = true
		environment.environment.ssao_radius = 0.5
		environment.environment.glow_enabled = true
		environment.environment.glow_intensity = 0.3
	
	if key_light:
		key_light.shadow_enabled = true
		key_light.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS

func _on_brain_structure_selected(structure_id: String, world_position: Vector3) -> void:
	"""Handle brain structure selection from interaction system"""
	_current_structure_id = structure_id
	
	# Update info panel
	if info_panel:
		info_panel.show_structure_info(structure_id)
	
	# Update selection indicator
	if selection_sphere:
		selection_sphere.visible = true
		selection_sphere.global_position = world_position
	
	# Emit signal for other systems
	structure_selected.emit(structure_id)
	
	# Update status
	if status_label:
		status_label.text = "Selected: " + structure_id.replace("_", " ").capitalize()
		status_label.modulate = Color(0.4, 0.8, 1.0)

func _on_brain_structure_highlighted(structure_id: String) -> void:
	"""Handle brain structure hover highlighting"""
	# Update status for hover
	if status_label and _current_structure_id == "":
		status_label.text = "Hovering: " + structure_id.replace("_", " ").capitalize()
		status_label.modulate = Color(0.7, 0.8, 0.9)