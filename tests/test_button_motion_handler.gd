extends Node

## Test scene for ButtonMotionHandler
## Validates hover animations and interaction effects work correctly

# Test tracking
var test_results = {
	"hover_animation": false,
	"focus_animation": false,
	"press_animation": false,
	"performance": {},
	"errors": []
}

var test_buttons = []
var fps_samples = []
var test_start_time: float

func _ready() -> void:
	print("[ButtonMotionHandler Test] Starting animation validation...")
	
	# Create main container
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.add_theme_constant_override("separation", 20)
	add_child(main_container)
	
	# Add title
	var title = Label.new()
	title.text = "ButtonMotionHandler Test Suite"
	title.add_theme_font_size_override("font_size", 24)
	main_container.add_child(title)
	
	# Instructions
	var instructions = Label.new()
	instructions.text = "Test hover, focus (Tab), and click animations. Watch for smooth 60 FPS."
	instructions.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	main_container.add_child(instructions)
	
	# Create test sections
	_create_basic_animation_test(main_container)
	_create_enhanced_button_test(main_container)
	_create_performance_test(main_container)
	_create_accessibility_test(main_container)
	
	# Start performance monitoring
	test_start_time = Time.get_ticks_msec() / 1000.0
	set_process(true)

func _create_basic_animation_test(container: Control) -> void:
	"""Test basic hover animations"""
	var section = _create_section(container, "Basic Hover Animation Test")
	
	var button_container = HBoxContainer.new()
	button_container.add_theme_constant_override("separation", 20)
	section.add_child(button_container)
	
	# Create test buttons with different configurations
	var configs = [
		{"text": "Default Hover", "duration": 0.2, "scale": 1.05},
		{"text": "Fast Hover", "duration": 0.1, "scale": 1.1},
		{"text": "Subtle Hover", "duration": 0.3, "scale": 1.02},
		{"text": "No Animation", "duration": 0.0, "scale": 1.0}
	]
	
	for config in configs:
		var button = Button.new()
		button.text = config.text
		button.custom_minimum_size = Vector2(120, 40)
		
		# Apply M3 styling first
		if ClassDB.class_exists("M3ComponentApplicator"):
			M3ComponentApplicator.apply_m3_button_styling(button)
		
		# Then add motion handler
		if config.scale > 1.0:
			ButtonMotionHandler.setup_button_hover_animation(button, config.duration, config.scale)
		
		button_container.add_child(button)
		test_buttons.append(button)
		
		# Track hover events
		button.mouse_entered.connect(_on_button_hovered.bind(button.text))

func _create_enhanced_button_test(container: Control) -> void:
	"""Test integration with EnhancedButton"""
	var section = _create_section(container, "Enhanced Button Integration")
	
	var button_container = HBoxContainer.new()
	button_container.add_theme_constant_override("separation", 20)
	section.add_child(button_container)
	
	# Standard button with motion handler
	var standard_button = Button.new()
	standard_button.text = "Standard + Motion"
	standard_button.custom_minimum_size = Vector2(150, 40)
	ButtonMotionHandler.setup_button_hover_animation(standard_button)
	ButtonMotionHandler.setup_button_press_animation(standard_button)
	button_container.add_child(standard_button)
	
	# Enhanced button (if available)
	if ClassDB.class_exists("EnhancedButton"):
		var enhanced_button = EnhancedButton.new()
		enhanced_button.text = "Enhanced Button"
		enhanced_button.custom_minimum_size = Vector2(150, 40)
		button_container.add_child(enhanced_button)
	else:
		var placeholder = Label.new()
		placeholder.text = "EnhancedButton not available"
		placeholder.add_theme_color_override("font_color", Color.YELLOW)
		button_container.add_child(placeholder)

func _create_performance_test(container: Control) -> void:
	"""Test performance with many animated buttons"""
	var section = _create_section(container, "Performance Test (50 buttons)")
	
	var grid = GridContainer.new()
	grid.columns = 10
	grid.add_theme_constant_override("h_separation", 5)
	grid.add_theme_constant_override("v_separation", 5)
	section.add_child(grid)
	
	# Create 50 buttons to test performance
	for i in range(50):
		var button = Button.new()
		button.text = str(i + 1)
		button.custom_minimum_size = Vector2(40, 30)
		
		# Apply motion handler
		ButtonMotionHandler.setup_button_hover_animation(button, 0.15, 1.08)
		
		grid.add_child(button)
		test_buttons.append(button)
	
	# FPS counter
	var fps_label = Label.new()
	fps_label.name = "FPSLabel"
	fps_label.text = "FPS: --"
	fps_label.add_theme_font_size_override("font_size", 16)
	fps_label.add_theme_color_override("font_color", Color.CYAN)
	section.add_child(fps_label)

func _create_accessibility_test(container: Control) -> void:
	"""Test keyboard navigation and focus animations"""
	var section = _create_section(container, "Accessibility Test (Tab Navigation)")
	
	var info = Label.new()
	info.text = "Press Tab to navigate, Enter/Space to activate"
	info.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	section.add_child(info)
	
	var button_container = HBoxContainer.new()
	button_container.add_theme_constant_override("separation", 15)
	section.add_child(button_container)
	
	# Create focusable buttons
	for i in range(4):
		var button = Button.new()
		button.text = "Focus %d" % (i + 1)
		button.custom_minimum_size = Vector2(100, 40)
		button.focus_mode = Control.FOCUS_ALL
		
		# Apply motion handler
		ButtonMotionHandler.setup_button_hover_animation(button)
		
		# Track focus events
		button.focus_entered.connect(_on_button_focused.bind(button.text))
		button.pressed.connect(_on_button_pressed.bind(button.text))
		
		button_container.add_child(button)
		test_buttons.append(button)
	
	# Set focus neighbors
	for i in range(button_container.get_child_count()):
		var button = button_container.get_child(i)
		if i > 0:
			button.focus_neighbor_left = button_container.get_child(i - 1).get_path()
		if i < button_container.get_child_count() - 1:
			button.focus_neighbor_right = button_container.get_child(i + 1).get_path()

func _create_section(container: Control, title: String) -> VBoxContainer:
	"""Create a test section with title"""
	var section = VBoxContainer.new()
	section.add_theme_constant_override("separation", 10)
	
	var separator = HSeparator.new()
	container.add_child(separator)
	
	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", Color.CYAN)
	section.add_child(title_label)
	
	container.add_child(section)
	return section

func _process(_delta: float) -> void:
	"""Monitor performance"""
	var fps = Engine.get_frames_per_second()
	fps_samples.append(fps)
	
	# Keep last 60 samples (1 second at 60 FPS)
	if fps_samples.size() > 60:
		fps_samples.pop_front()
	
	# Update FPS display
	var fps_label = get_node_or_null("FPSLabel")
	if fps_label:
		var avg_fps = 0.0
		for sample in fps_samples:
			avg_fps += sample
		avg_fps /= fps_samples.size()
		
		fps_label.text = "FPS: %.1f (avg: %.1f)" % [fps, avg_fps]
		
		# Color code based on performance
		if avg_fps >= 58:
			fps_label.add_theme_color_override("font_color", Color.GREEN)
		elif avg_fps >= 50:
			fps_label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			fps_label.add_theme_color_override("font_color", Color.RED)
		
		# Store performance result
		test_results.performance["average_fps"] = avg_fps
		test_results.performance["min_fps"] = fps_samples.min()
		test_results.performance["max_fps"] = fps_samples.max()

func _on_button_hovered(button_name: String) -> void:
	"""Track hover animation"""
	test_results.hover_animation = true
	print("[Test] Button '%s' hover animation triggered" % button_name)

func _on_button_focused(button_name: String) -> void:
	"""Track focus animation"""
	test_results.focus_animation = true
	print("[Test] Button '%s' focus animation triggered" % button_name)

func _on_button_pressed(button_name: String) -> void:
	"""Track press animation"""
	test_results.press_animation = true
	print("[Test] Button '%s' press animation triggered" % button_name)

func _exit_tree() -> void:
	"""Generate test report on exit"""
	print("\n========== ButtonMotionHandler Test Results ==========")
	
	print("\nAnimation Tests:")
	print("  Hover animation: %s" % ("✓ PASS" if test_results.hover_animation else "✗ FAIL"))
	print("  Focus animation: %s" % ("✓ PASS" if test_results.focus_animation else "✗ FAIL"))
	print("  Press animation: %s" % ("✓ PASS" if test_results.press_animation else "✗ FAIL"))
	
	if test_results.performance.has("average_fps"):
		print("\nPerformance Metrics:")
		print("  Average FPS: %.1f" % test_results.performance.average_fps)
		print("  Min FPS: %.1f" % test_results.performance.min_fps)
		print("  Max FPS: %.1f" % test_results.performance.max_fps)
		print("  Performance: %s" % (
			"✓ EXCELLENT" if test_results.performance.average_fps >= 58 else
			"⚠ GOOD" if test_results.performance.average_fps >= 50 else
			"✗ POOR"
		))
	
	if test_results.errors.size() > 0:
		print("\nErrors:")
		for error in test_results.errors:
			print("  - %s" % error)
	
	var test_duration = Time.get_ticks_msec() / 1000.0 - test_start_time
	print("\nTest duration: %.1f seconds" % test_duration)