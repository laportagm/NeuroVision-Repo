class_name TestRunner
extends Control

## Test runner UI for the unified test framework

# === NODES ===
@onready var test_framework: TestFramework = $TestFramework
@onready var run_all_button: Button = $UI/Controls/RunAllTests
@onready var run_critical_button: Button = $UI/Controls/RunCriticalTests
@onready var run_ui_button: Button = $UI/Controls/RunUITests
@onready var run_performance_button: Button = $UI/Controls/RunPerformanceTests
@onready var clear_button: Button = $UI/Controls/ClearResults
@onready var status_label: Label = $UI/Status/StatusLabel
@onready var progress_bar: ProgressBar = $UI/Status/ProgressBar
@onready var test_items: VBoxContainer = $UI/Results/TestList/TestScrollContainer/TestItems
@onready var details_text: RichTextLabel = $UI/Results/Details/DetailsScrollContainer/DetailsText

# === PRIVATE VARIABLES ===
var _test_buttons: Array[Button] = []
var _current_tests: int = 0
var _completed_tests: int = 0

# === PUBLIC METHODS ===

func _ready() -> void:
	_connect_signals()
	_setup_ui()

# === PRIVATE METHODS ===

func _connect_signals() -> void:
	"""Connect UI signals and test framework signals"""
	# Button signals
	run_all_button.pressed.connect(_on_run_all_tests)
	run_critical_button.pressed.connect(_on_run_critical_tests)
	run_ui_button.pressed.connect(_on_run_ui_tests)
	run_performance_button.pressed.connect(_on_run_performance_tests)
	clear_button.pressed.connect(_on_clear_results)
	
	# Test framework signals
	test_framework.test_started.connect(_on_test_started)
	test_framework.test_completed.connect(_on_test_completed)
	test_framework.test_suite_completed.connect(_on_test_suite_completed)

func _setup_ui() -> void:
	"""Setup initial UI state"""
	progress_bar.value = 0
	progress_bar.visible = false
	status_label.text = "Ready - %d tests registered" % test_framework._test_registry.size()

func _on_run_all_tests() -> void:
	"""Run all registered tests"""
	_start_test_run("Running all tests...")
	test_framework.run_all_tests()

func _on_run_critical_tests() -> void:
	"""Run only critical tests"""
	_start_test_run("Running critical tests...")
	test_framework.run_critical_tests()

func _on_run_ui_tests() -> void:
	"""Run UI component tests"""
	_start_test_run("Running UI tests...")
	test_framework.run_tests_by_category(TestFramework.TestCategory.UI_COMPONENTS)

func _on_run_performance_tests() -> void:
	"""Run performance tests"""
	_start_test_run("Running performance tests...")
	test_framework.run_tests_by_category(TestFramework.TestCategory.PERFORMANCE)

func _on_clear_results() -> void:
	"""Clear test results"""
	for button in _test_buttons:
		button.queue_free()
	_test_buttons.clear()
	
	details_text.text = "Select a test to view details"
	status_label.text = "Results cleared"
	progress_bar.visible = false

func _start_test_run(message: String) -> void:
	"""Start a test run"""
	status_label.text = message
	progress_bar.visible = true
	progress_bar.value = 0
	_current_tests = 0
	_completed_tests = 0
	
	# Disable test buttons during run
	_set_buttons_enabled(false)

func _on_test_started(test_name: String) -> void:
	"""Handle test started"""
	_current_tests += 1
	status_label.text = "Running: " + test_name
	
	# Add test item to list
	var test_button = Button.new()
	test_button.text = test_name + " - Running..."
	test_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	test_button.pressed.connect(_on_test_selected.bind(test_name))
	test_items.add_child(test_button)
	_test_buttons.append(test_button)

func _on_test_completed(test_name: String, result: bool) -> void:
	"""Handle test completed"""
	_completed_tests += 1
	
	# Update progress
	if _current_tests > 0:
		progress_bar.value = (_completed_tests * 100.0) / _current_tests
	
	# Update test button
	for button in _test_buttons:
		if button.text.begins_with(test_name):
			var status = "PASSED" if result else "FAILED"
			var color = Color.GREEN if result else Color.RED
			button.text = test_name + " - " + status
			button.modulate = color
			break

func _on_test_suite_completed(total_tests: int, passed: int, failed: int) -> void:
	"""Handle test suite completion"""
	var success_rate = (passed * 100.0) / total_tests if total_tests > 0 else 0
	status_label.text = "Completed: %d/%d passed (%.1f%%)" % [passed, total_tests, success_rate]
	
	progress_bar.value = 100
	
	# Re-enable test buttons
	_set_buttons_enabled(true)
	
	# Update details with summary
	var summary = "[b]Test Suite Summary[/b]\n\n"
	summary += "Total Tests: %d\n" % total_tests
	summary += "Passed: [color=green]%d[/color]\n" % passed
	summary += "Failed: [color=red]%d[/color]\n" % failed
	summary += "Success Rate: %.1f%%\n\n" % success_rate
	
	if failed > 0:
		summary += "[color=red]Some tests failed. Check individual results for details.[/color]"
	else:
		summary += "[color=green]All tests passed![/color]"
	
	details_text.text = summary

func _on_test_selected(test_name: String) -> void:
	"""Handle test selection for details view"""
	var test_data = test_framework._test_results.get(test_name, {})
	var registry_data = test_framework._test_registry.get(test_name, {})
	
	var details = "[b]Test: %s[/b]\n\n" % test_name
	
	if registry_data:
		var category = _get_category_name(registry_data.get("category", 0))
		var priority = _get_priority_name(registry_data.get("priority", 0))
		details += "Category: %s\n" % category
		details += "Priority: %s\n\n" % priority
	
	if test_data:
		var result = test_data.get("result", false)
		var status = "PASSED" if result else "FAILED"
		var color = "green" if result else "red"
		details += "Result: [color=%s]%s[/color]\n" % [color, status]
		
		if test_data.has("completed_at"):
			var time = test_data.completed_at
			details += "Completed: %d ms\n" % time
		
		if test_data.has("error"):
			details += "\n[color=red]Error: %s[/color]\n" % test_data.error
	else:
		details += "No results available"
	
	details_text.text = details

func _set_buttons_enabled(enabled: bool) -> void:
	"""Enable or disable test control buttons"""
	run_all_button.disabled = not enabled
	run_critical_button.disabled = not enabled
	run_ui_button.disabled = not enabled
	run_performance_button.disabled = not enabled

func _get_category_name(category: int) -> String:
	"""Get category name from enum value"""
	match category:
		TestFramework.TestCategory.UI_COMPONENTS:
			return "UI Components"
		TestFramework.TestCategory.CONTENT_MANAGEMENT:
			return "Content Management"
		TestFramework.TestCategory.PERFORMANCE:
			return "Performance"
		TestFramework.TestCategory.ACCESSIBILITY:
			return "Accessibility"
		TestFramework.TestCategory.INTEGRATION:
			return "Integration"
		TestFramework.TestCategory.VISUAL_REGRESSION:
			return "Visual Regression"
		_:
			return "Unknown"

func _get_priority_name(priority: int) -> String:
	"""Get priority name from enum value"""
	match priority:
		TestFramework.TestPriority.CRITICAL:
			return "Critical"
		TestFramework.TestPriority.HIGH:
			return "High"
		TestFramework.TestPriority.MEDIUM:
			return "Medium"
		TestFramework.TestPriority.LOW:
			return "Low"
		_:
			return "Unknown"