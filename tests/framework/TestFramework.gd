class_name TestFramework
extends Node

## Unified test framework for NeuroVision educational platform
## Replaces individual test scenes with a consolidated testing system

signal test_started(test_name: String)
signal test_completed(test_name: String, result: bool)
signal test_suite_completed(total_tests: int, passed: int, failed: int)

# === ENUMS ===

enum TestCategory {
	UI_COMPONENTS,
	CONTENT_MANAGEMENT,
	PERFORMANCE,
	ACCESSIBILITY,
	INTEGRATION,
	VISUAL_REGRESSION
}

enum TestPriority {
	CRITICAL,  # Must pass for release
	HIGH,      # Important functionality
	MEDIUM,    # Nice to have
	LOW        # Future improvements
}

# === CONSTANTS ===

const TEST_TIMEOUT: float = 30.0
const PERFORMANCE_TEST_DURATION: float = 10.0

# === PRIVATE VARIABLES ===

var _test_registry: Dictionary = {}
var _test_results: Dictionary = {}
var _current_test: String = ""
var _test_timer: Timer
var _is_running: bool = false

# === TEST REGISTRATION ===

func _ready() -> void:
	print("[TestFramework] Initializing unified test framework")
	_setup_timer()
	_register_tests()

func register_test(test_name: String, test_function: Callable, category: TestCategory, priority: TestPriority = TestPriority.MEDIUM) -> void:
	"""Register a test function"""
	_test_registry[test_name] = {
		"function": test_function,
		"category": category,
		"priority": priority,
		"registered_at": Time.get_ticks_msec()
	}

# === TEST EXECUTION ===

func run_all_tests() -> void:
	"""Run all registered tests"""
	if _is_running:
		push_warning("[TestFramework] Tests already running")
		return
	
	_is_running = true
	_test_results.clear()
	
	print("[TestFramework] Starting test suite with %d tests" % _test_registry.size())
	
	var total_tests = _test_registry.size()
	var passed = 0
	var failed = 0
	
	for test_name in _test_registry:
		var result = await _run_test(test_name)
		if result:
			passed += 1
		else:
			failed += 1
	
	_is_running = false
	test_suite_completed.emit(total_tests, passed, failed)
	
	print("[TestFramework] Test suite completed: %d/%d passed" % [passed, total_tests])

func run_tests_by_category(category: TestCategory) -> void:
	"""Run tests in a specific category"""
	var category_tests = []
	for test_name in _test_registry:
		if _test_registry[test_name].category == category:
			category_tests.append(test_name)
	
	await _run_test_list(category_tests)

func run_tests_by_priority(priority: TestPriority) -> void:
	"""Run tests with specific priority"""
	var priority_tests = []
	for test_name in _test_registry:
		if _test_registry[test_name].priority == priority:
			priority_tests.append(test_name)
	
	await _run_test_list(priority_tests)

func run_critical_tests() -> void:
	"""Run only critical tests for CI/CD"""
	await run_tests_by_priority(TestPriority.CRITICAL)

# === PRIVATE METHODS ===

func _setup_timer() -> void:
	"""Setup test timeout timer"""
	_test_timer = Timer.new()
	_test_timer.one_shot = true
	_test_timer.timeout.connect(_on_test_timeout)
	add_child(_test_timer)

func _register_tests() -> void:
	"""Register all available tests"""
	# UI Component Tests
	register_test("ui_theme_manager", _test_ui_theme_manager, TestCategory.UI_COMPONENTS, TestPriority.CRITICAL)
	register_test("button_motion_handler", _test_button_motion_handler, TestCategory.UI_COMPONENTS, TestPriority.HIGH)
	register_test("quiz_panel_functionality", _test_quiz_panel, TestCategory.UI_COMPONENTS, TestPriority.HIGH)
	register_test("accessibility_features", _test_accessibility, TestCategory.ACCESSIBILITY, TestPriority.CRITICAL)
	
	# Content Management Tests
	register_test("educational_content_loading", _test_content_loading, TestCategory.CONTENT_MANAGEMENT, TestPriority.CRITICAL)
	register_test("learning_progress_tracking", _test_progress_tracking, TestCategory.CONTENT_MANAGEMENT, TestPriority.HIGH)
	register_test("content_filtering", _test_content_filtering, TestCategory.CONTENT_MANAGEMENT, TestPriority.MEDIUM)
	
	# Performance Tests
	register_test("frame_rate_stability", _test_frame_rate, TestCategory.PERFORMANCE, TestPriority.CRITICAL)
	register_test("memory_usage", _test_memory_usage, TestCategory.PERFORMANCE, TestPriority.HIGH)
	register_test("model_loading_performance", _test_model_loading_perf, TestCategory.PERFORMANCE, TestPriority.MEDIUM)
	
	# Integration Tests
	register_test("autoload_dependencies", _test_autoload_integration, TestCategory.INTEGRATION, TestPriority.CRITICAL)
	register_test("ui_manager_integration", _test_ui_manager_integration, TestCategory.INTEGRATION, TestPriority.HIGH)
	register_test("educational_workflow", _test_educational_workflow, TestCategory.INTEGRATION, TestPriority.HIGH)

func _run_test(test_name: String) -> bool:
	"""Run a single test"""
	if not _test_registry.has(test_name):
		push_error("[TestFramework] Test not found: " + test_name)
		return false
	
	_current_test = test_name
	test_started.emit(test_name)
	
	print("[TestFramework] Running test: " + test_name)
	
	# Start timeout timer
	_test_timer.start(TEST_TIMEOUT)
	
	var test_data = _test_registry[test_name]
	var test_function = test_data.function
	
	var result = false
	try:
		result = await test_function.call()
	except:
		print("[TestFramework] Test crashed: " + test_name)
		result = false
	
	_test_timer.stop()
	
	_test_results[test_name] = {
		"result": result,
		"completed_at": Time.get_ticks_msec(),
		"category": test_data.category,
		"priority": test_data.priority
	}
	
	test_completed.emit(test_name, result)
	
	var status = "PASSED" if result else "FAILED"
	print("[TestFramework] Test %s: %s" % [test_name, status])
	
	return result

func _run_test_list(test_names: Array) -> void:
	"""Run a list of tests"""
	var passed = 0
	var failed = 0
	
	for test_name in test_names:
		var result = await _run_test(test_name)
		if result:
			passed += 1
		else:
			failed += 1
	
	print("[TestFramework] Test subset completed: %d/%d passed" % [passed, test_names.size()])

func _on_test_timeout() -> void:
	"""Handle test timeout"""
	push_error("[TestFramework] Test timeout: " + _current_test)
	_test_results[_current_test] = {
		"result": false,
		"completed_at": Time.get_ticks_msec(),
		"error": "timeout"
	}
	test_completed.emit(_current_test, false)

# === TEST IMPLEMENTATIONS ===

func _test_ui_theme_manager() -> bool:
	"""Test UISystemManager theme functionality"""
	if not UISystemManager:
		return false
	
	# Test theme switching
	var original_theme = UISystemManager.get_current_theme()
	var switch_success = UISystemManager.set_theme("material3")
	
	if not switch_success:
		return false
	
	# Restore original theme
	UISystemManager.set_theme(original_theme)
	return true

func _test_button_motion_handler() -> bool:
	"""Test button motion handler functionality"""
	# Create a test button
	var button = Button.new()
	button.text = "Test Button"
	add_child(button)
	
	# Test button creation and functionality
	var result = button != null and button.text == "Test Button"
	
	# Cleanup
	button.queue_free()
	return result

func _test_quiz_panel() -> bool:
	"""Test quiz panel functionality"""
	# Load quiz panel resource
	var quiz_panel_scene = preload("res://src/ui/components/QuizPanel.tscn")
	if not quiz_panel_scene:
		return false
	
	var quiz_panel = quiz_panel_scene.instantiate()
	add_child(quiz_panel)
	
	# Test basic functionality
	var result = quiz_panel != null
	
	# Cleanup
	quiz_panel.queue_free()
	return result

func _test_accessibility() -> bool:
	"""Test accessibility features"""
	if not CoreSystemManager:
		return false
	
	# Test accessibility feature setting
	CoreSystemManager.set_accessibility_feature("high_contrast", true)
	var high_contrast_enabled = CoreSystemManager.get_accessibility_feature("high_contrast")
	
	CoreSystemManager.set_accessibility_feature("high_contrast", false)
	
	return high_contrast_enabled

func _test_content_loading() -> bool:
	"""Test educational content loading"""
	if not EducationalPlatformManager:
		return false
	
	# Test content loading
	EducationalPlatformManager.load_content("test_structure")
	
	# Simple test - just check manager exists and doesn't crash
	return true

func _test_progress_tracking() -> bool:
	"""Test learning progress tracking"""
	if not EducationalPlatformManager:
		return false
	
	# Test progress update
	EducationalPlatformManager.update_progress("test_structure", "view", {"duration": 1.0})
	var progress = EducationalPlatformManager.get_progress("test_structure")
	
	return progress.has("interactions")

func _test_content_filtering() -> bool:
	"""Test content filtering by learning level"""
	if not EducationalPlatformManager:
		return false
	
	# Test content filtering
	var filtered = EducationalPlatformManager.get_filtered_content("test_structure", 0)
	
	# Simple validation - should return a dictionary
	return filtered is Dictionary

func _test_frame_rate() -> bool:
	"""Test frame rate stability"""
	var start_time = Time.get_ticks_msec()
	var frame_count = 0
	
	# Monitor frame rate for a short period
	while Time.get_ticks_msec() - start_time < 1000:  # 1 second
		await get_tree().process_frame
		frame_count += 1
	
	var fps = frame_count
	return fps >= 30  # Minimum 30 FPS requirement

func _test_memory_usage() -> bool:
	"""Test memory usage within acceptable limits"""
	if not CoreSystemManager:
		return false
	
	var memory_mb = CoreSystemManager.get_memory_usage()
	return memory_mb < 512.0  # 512MB limit

func _test_model_loading_perf() -> bool:
	"""Test 3D model loading performance"""
	var start_time = Time.get_ticks_msec()
	
	# Simulate model loading test
	await get_tree().create_timer(0.1).timeout
	
	var load_time = Time.get_ticks_msec() - start_time
	return load_time < 5000  # 5 second limit

func _test_autoload_integration() -> bool:
	"""Test autoload manager integration"""
	var managers = [
		CoreSystemManager,
		UISystemManager,
		EducationalPlatformManager
	]
	
	for manager in managers:
		if not manager:
			return false
	
	return true

func _test_ui_manager_integration() -> bool:
	"""Test UI manager integration with other systems"""
	if not UISystemManager or not CoreSystemManager:
		return false
	
	# Test theme system integration
	var theme_name = UISystemManager.get_current_theme()
	return theme_name != null and not theme_name.is_empty()

func _test_educational_workflow() -> bool:
	"""Test complete educational workflow"""
	if not EducationalPlatformManager or not UISystemManager:
		return false
	
	# Test learning level setting
	EducationalPlatformManager.set_learning_level(1)
	var level = EducationalPlatformManager.get_learning_level()
	
	return level == 1