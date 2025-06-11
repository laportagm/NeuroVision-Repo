extends GutTest

## Tests for Level 2: Core Systems Verification

var main_menu = null
var exploration_scene = null

func before_each():
	# Clean slate for each test
	main_menu = null
	exploration_scene = null

func after_each():
	if main_menu and is_instance_valid(main_menu):
		main_menu.queue_free()
	if exploration_scene and is_instance_valid(exploration_scene):
		exploration_scene.queue_free()

# === MAIN MENU TESTS ===

func test_main_menu_loads_correctly():
	# Load the main menu scene
	var menu_scene = load("res://src/ui/screens/MainMenu.tscn")
	assert_not_null(menu_scene)
	
	main_menu = menu_scene.instantiate()
	assert_not_null(main_menu)
	
	# Add to tree to trigger _ready
	add_child(main_menu)
	
	# Verify UI elements exist
	var start_button = main_menu.get_node("VBoxContainer/StartButton")
	var quit_button = main_menu.get_node("VBoxContainer/QuitButton")
	var title_label = main_menu.get_node("VBoxContainer/TitleLabel")
	
	assert_not_null(start_button)
	assert_not_null(quit_button)
	assert_not_null(title_label)
	
	# Verify text content
	assert_eq(title_label.text, "NeuroVis")
	assert_eq(start_button.text, "Start Exploration")

func test_main_menu_start_button_signal():
	var menu_scene = load("res://src/ui/screens/MainMenu.tscn")
	main_menu = menu_scene.instantiate()
	add_child(main_menu)
	
	var signal_emitted = false
	main_menu.start_exploration.connect(func(): signal_emitted = true)
	
	# Simulate button press
	var start_button = main_menu.get_node("VBoxContainer/StartButton")
	start_button.pressed.emit()
	
	assert_true(signal_emitted)

# === EXPLORATION SCENE TESTS ===

func test_exploration_scene_loads():
	# Load the exploration scene
	var scene = load("res://src/scenes/ExplorationScene.tscn")
	assert_not_null(scene)
	
	exploration_scene = scene.instantiate()
	assert_not_null(exploration_scene)
	
	# Verify it has required nodes
	add_child(exploration_scene)
	
	var camera = exploration_scene.get_node("Camera3D")
	var brain_container = exploration_scene.get_node("BrainModelContainer")
	var ui_layer = exploration_scene.get_node("UI")
	
	assert_not_null(camera)
	assert_not_null(brain_container)
	assert_not_null(ui_layer)

func test_exploration_scene_info_panel():
	var scene = load("res://src/scenes/ExplorationScene.tscn")
	exploration_scene = scene.instantiate()
	add_child(exploration_scene)
	
	# Get info panel
	var info_panel = exploration_scene.get_node("UI/InfoPanel")
	assert_not_null(info_panel)
	
	# Initially should be hidden
	assert_false(info_panel.visible)
	
	# Display structure info
	exploration_scene.display_structure_info("Test Structure", {
		"description": "Test description"
	})
	
	# Should now be visible
	await wait_frames(5)
	assert_true(info_panel.visible)

# === SCENE TRANSITION TESTS ===

func test_scene_manager_exists():
	# For now, we're handling transitions in MainMenu.gd
	# This test verifies the transition mechanism works
	
	var menu_scene = load("res://src/ui/screens/MainMenu.tscn")
	main_menu = menu_scene.instantiate()
	get_tree().root.add_child(main_menu)
	
	# The menu should be able to load exploration scene
	main_menu._on_start_button_pressed()
	
	# Wait for scene change
	await wait_seconds(0.5)
	
	# Menu should be freed and exploration scene should exist
	assert_false(is_instance_valid(main_menu) and not main_menu.is_queued_for_deletion())

# === AUTOLOAD INTEGRATION TESTS ===

func test_performance_monitor_integration():
	# Performance monitor should be running
	assert_not_null(PerformanceMonitor)
	assert_true(PerformanceMonitor._is_monitoring)
	
	# Should have metrics
	var metrics = PerformanceMonitor.get_current_metrics()
	assert_has(metrics, "fps")
	assert_has(metrics, "memory")
	assert_has(metrics, "quality_level")
	assert_gt(metrics.fps, 0)

func test_all_autoloads_accessible():
	# Verify all autoloads are available globally
	assert_not_null(ErrorRecoveryManager)
	assert_not_null(PerformanceMonitor)
	assert_not_null(AccessibilityManager)
	assert_not_null(ContentManager)
	assert_not_null(ProgressTracker)
	assert_not_null(AuthenticationManager)
	assert_not_null(NetworkManager)
	assert_not_null(SettingsManager)

func test_autoload_interaction():
	# Test that autoloads can interact properly
	
	# ErrorRecoveryManager should handle errors
	var error_count_before = ErrorRecoveryManager.get_error_history().size()
	ErrorRecoveryManager.handle_error("TEST", "Test error")
	var error_count_after = ErrorRecoveryManager.get_error_history().size()
	assert_eq(error_count_after, error_count_before + 1)
	
	# AccessibilityManager should toggle
	AccessibilityManager.enable_accessibility()
	assert_true(AccessibilityManager._accessibility_enabled)
	AccessibilityManager.disable_accessibility()
	assert_false(AccessibilityManager._accessibility_enabled)

# === PERFORMANCE TESTS ===

func test_startup_performance():
	# Measure scene loading time
	var start_time = Time.get_ticks_msec()
	
	var scene = load("res://src/scenes/ExplorationScene.tscn")
	exploration_scene = scene.instantiate()
	add_child(exploration_scene)
	
	var load_time = Time.get_ticks_msec() - start_time
	
	# Should load in under 1 second
	assert_lt(load_time, 1000)
	
	# FPS should be good
	var metrics = PerformanceMonitor.get_current_metrics()
	assert_gt(metrics.fps, 30)  # Minimum 30 FPS requirement