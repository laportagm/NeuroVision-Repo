## Integration Code for EnhancedExplorationScene
##
## Add these functions to EnhancedExplorationScene.gd to properly connect
## the optimized systems and enable full functionality.

extends Node

# Add this code to your existing EnhancedExplorationScene.gd file

# === NEW INTEGRATION FUNCTIONS ===

func _integrate_optimized_systems() -> void:
	"""Main integration function - call this from _ready()"""
	print("[Integration] Connecting optimized systems...")
	
	# Setup real-time performance monitoring
	_setup_real_time_performance_monitor()
	
	# Initialize brain interaction with the new controller
	_initialize_brain_interaction_controller()
	
	# Connect performance UI elements
	_connect_performance_ui()
	
	# Apply lighting optimizations
	_apply_optimized_lighting()
	
	# Setup accessibility manager
	_initialize_accessibility_manager()

func _setup_real_time_performance_monitor() -> void:
	"""Create and configure the real-time performance monitor"""
	# Check if we already have a performance monitor child
	var existing_monitor = get_node_or_null("PerformanceMonitor")
	if existing_monitor:
		print("[Integration] Performance monitor already exists")
		return
	
	# Create new performance monitor
	var perf_monitor_script = load("res://src/systems/performance/RealTimePerformanceMonitor.gd")
	if not perf_monitor_script:
		push_error("[Integration] RealTimePerformanceMonitor.gd not found!")
		return
		
	var perf_monitor = Node.new()
	perf_monitor.set_script(perf_monitor_script)
	perf_monitor.name = "PerformanceMonitor"
	add_child(perf_monitor)
	
	# Connect UI elements if they exist
	var ui_elements = {}
	
	# Safely get UI elements
	if fps_indicator:
		ui_elements["fps_indicator"] = fps_indicator
	if frame_time_indicator:
		ui_elements["frame_time_indicator"] = frame_time_indicator
	if quality_indicator:
		ui_elements["quality_indicator"] = quality_indicator
	if memory_usage:
		ui_elements["memory_usage"] = memory_usage
	if cpu_usage:
		ui_elements["cpu_usage"] = cpu_usage
	if gpu_usage:
		ui_elements["gpu_usage"] = gpu_usage
	if brain_model_complexity:
		ui_elements["brain_model_complexity"] = brain_model_complexity
	if texture_memory:
		ui_elements["texture_memory"] = texture_memory
	if performance_label:
		ui_elements["performance_label"] = performance_label
	if learning_analytics:
		ui_elements["learning_analytics"] = learning_analytics
	
	if ui_elements.size() > 0:
		perf_monitor.connect_ui_elements(ui_elements)
		print("[Integration] Connected %d UI elements to performance monitor" % ui_elements.size())
	
	# Connect signals
	if perf_monitor.has_signal("performance_warning"):
		perf_monitor.performance_warning.connect(_on_performance_warning)
	if perf_monitor.has_signal("quality_adjustment_needed"):
		perf_monitor.quality_adjustment_needed.connect(_on_quality_adjustment)

func _initialize_brain_interaction_controller() -> void:
	"""Setup the brain interaction controller if it exists"""
	# Find the InteractionController we added
	var controller_path = "EducationalSystemsContainer/BrainInteractionSystem/InteractionController"
	var controller = get_node_or_null(controller_path)
	
	if not controller:
		push_warning("[Integration] InteractionController not found at: " + controller_path)
		return
	
	# Initialize with camera and brain structures
	if camera and _brain_structures.size() > 0:
		controller.initialize(camera, _brain_structures)
		print("[Integration] Brain interaction controller initialized with %d structures" % _brain_structures.size())
	else:
		# Initialize with just camera, structures will be added later
		controller.initialize(camera, {})
		print("[Integration] Brain interaction controller initialized (awaiting brain structures)")
	
	# Connect interaction signals
	if controller.has_signal("structure_selected"):
		controller.structure_selected.connect(_on_brain_structure_selected_integrated)
	if controller.has_signal("structure_highlighted"):
		controller.structure_highlighted.connect(_on_brain_structure_highlighted_integrated)
	
	# Store reference
	_brain_interaction = controller

func _connect_performance_ui() -> void:
	"""Connect the performance toggle button"""
	if performance_toggle and not performance_toggle.pressed.is_connected(_toggle_performance_panel):
		performance_toggle.pressed.connect(_toggle_performance_panel)
		print("[Integration] Performance toggle button connected")

func _apply_optimized_lighting() -> void:
	"""Ensure lighting is properly configured"""
	# Verify lights are enabled
	if key_light and not key_light.visible:
		key_light.visible = true
		key_light.light_energy = 0.8
		print("[Integration] KeyLight enabled")
	
	if rim_light and not rim_light.visible:
		rim_light.visible = true
		rim_light.light_energy = 0.3
		print("[Integration] RimLight enabled")
	
	# Apply lighting preset
	if _lighting_presets.has("default"):
		_apply_lighting_preset("default")

func _initialize_accessibility_manager() -> void:
	"""Setup accessibility manager if present"""
	var accessibility_path = "EducationalSystemsContainer/AccessibilityManager"
	var accessibility_manager = get_node_or_null(accessibility_path)
	
	if accessibility_manager:
		print("[Integration] Accessibility manager found and ready")
		# Future: Add accessibility initialization here
	else:
		push_warning("[Integration] AccessibilityManager not found")

# === SIGNAL HANDLERS ===

func _on_brain_structure_selected_integrated(structure_id: String, world_position: Vector3) -> void:
	"""Handle structure selection from the new interaction controller"""
	_current_structure_id = structure_id
	
	# Update info panel
	if info_panel and info_panel.has_method("show_structure_info"):
		info_panel.show_structure_info(structure_id)
	
	# Update selection indicator
	if selection_sphere:
		selection_sphere.visible = true
		selection_sphere.global_position = world_position
	
	# Update status
	if status_label:
		var display_name = structure_id.replace("_", " ").capitalize()
		status_label.text = "Selected: " + display_name
		status_label.modulate = Color(0.4, 0.8, 1.0)
	
	# Emit signal for other systems
	structure_selected.emit(structure_id)

func _on_brain_structure_highlighted_integrated(structure_id: String) -> void:
	"""Handle structure hover from the new interaction controller"""
	if status_label and _current_structure_id == "":
		var display_name = structure_id.replace("_", " ").capitalize()
		status_label.text = "Hovering: " + display_name
		status_label.modulate = Color(0.7, 0.8, 0.9)

func _on_performance_warning(metric: String, value: float, threshold: float) -> void:
	"""Handle performance warnings from monitor"""
	match metric:
		"fps":
			if status_label:
				status_label.text = "Performance: Low FPS (%.1f)" % value
				status_label.modulate = Color(1.0, 0.8, 0.4)
		"memory":
			if status_label:
				status_label.text = "Warning: High Memory Usage"
				status_label.modulate = Color(1.0, 0.6, 0.4)

func _on_quality_adjustment(new_quality: String) -> void:
	"""Handle automatic quality adjustments"""
	print("[Performance] Quality auto-adjusted to: " + new_quality)
	
	if quality_indicator:
		quality_indicator.text = "Quality: " + new_quality.to_upper()
	
	# Apply quality-specific settings
	match new_quality:
		"low":
			_apply_low_quality_settings()
		"medium":
			_apply_medium_quality_settings()
		"high":
			_apply_high_quality_settings()

# === INTEGRATION CALL ===
# Add this to your existing _ready() function:
#
# func _ready() -> void:
#     # ... existing code ...
#     
#     # Integrate optimized systems
#     _integrate_optimized_systems()
#     
#     # ... rest of existing code ...

# === MOUSE INPUT HANDLING ===
# Update your _handle_mouse_button function to use the new interaction controller:

func _handle_mouse_button_integrated(event: InputEventMouseButton) -> void:
	"""Updated mouse handling for brain interaction"""
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_is_rotating = true
		else:
			_is_rotating = false
			
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		# Use the new interaction controller for selection
		if _brain_interaction and _brain_interaction.has_method("handle_selection_input"):
			var handled = _brain_interaction.handle_selection_input(event.position)
			if not handled:
				# Clicked on empty space - deselect
				_deselect_current_structure()
		else:
			# Fallback to old selection method
			_handle_structure_selection_at_mouse(event.position)
			
	elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
		_zoom_velocity -= ZOOM_SPEED * 10
		_zoom_velocity = clamp(_zoom_velocity, -50, 50)
		
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_zoom_velocity += ZOOM_SPEED * 10
		_zoom_velocity = clamp(_zoom_velocity, -50, 50)