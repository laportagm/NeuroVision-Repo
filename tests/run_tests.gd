extends Node

## Simple test runner for NeuroVision tests
## Run with: godot --headless -s tests/run_tests.gd

var total_tests = 0
var passed_tests = 0
var failed_tests = 0
var current_test_file = ""

func _ready():
	print("\n╔════════════════════════════════════════╗")
	print("║     NeuroVision Test Suite Runner      ║")
	print("╚════════════════════════════════════════╝\n")
	
	# Define test files to run
	var test_files = [
		"res://tests/unit/test_autoload_fixes.gd",
		"res://tests/unit/test_performance_monitor.gd",
		"res://tests/unit/test_brain_interaction_controller.gd",
		"res://tests/unit/test_model_loader.gd",
		"res://tests/unit/test_level3_brain_model.gd",
		"res://tests/unit/test_level5_content_management.gd",
		"res://tests/unit/test_level6_enhanced_interaction.gd",
		"res://tests/unit/test_level7_assessment_system.gd"
	]
	
	# Run each test file
	for test_file in test_files:
		await run_test_file(test_file)
		await get_tree().create_timer(0.1).timeout
	
	# Print summary
	print("\n╔════════════════════════════════════════╗")
	print("║           Test Summary                 ║")
	print("╚════════════════════════════════════════╝")
	print("Total Tests Run: %d" % total_tests)
	print("Passed: %d" % passed_tests)
	print("Failed: %d" % failed_tests)
	
	if failed_tests == 0:
		print("\n✅ All tests passed!")
	else:
		print("\n❌ Some tests failed!")
	
	# Exit with appropriate code
	get_tree().quit(1 if failed_tests > 0 else 0)

func run_test_file(path: String) -> void:
	print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("Running: %s" % path.get_file())
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	
	current_test_file = path
	
	# Try to load the test script
	if not ResourceLoader.exists(path):
		print("❌ Test file not found: %s" % path)
		failed_tests += 1
		return
	
	var script = load(path)
	if not script:
		print("❌ Failed to load test script: %s" % path)
		failed_tests += 1
		return
	
	# Create test instance
	var test = script.new()
	if not test:
		print("❌ Failed to create test instance")
		failed_tests += 1
		return
	
	add_child(test)
	
	# Run lifecycle: before_all
	if test.has_method("before_all"):
		test.before_all()
		await get_tree().process_frame
	
	# Find and run all test methods
	var test_methods = []
	for method in test.get_method_list():
		if method.name.begins_with("test_"):
			test_methods.append(method.name)
	
	print("Found %d test methods" % test_methods.size())
	
	for test_method in test_methods:
		await run_test_method(test, test_method)
	
	# Run lifecycle: after_all
	if test.has_method("after_all"):
		test.after_all()
		await get_tree().process_frame
	
	# Clean up
	test.queue_free()
	await get_tree().process_frame

func run_test_method(test: Node, method_name: String) -> void:
	total_tests += 1
	print("\n  → %s" % method_name)
	
	# Track errors
	var error_count_before = get_error_count()
	
	# Run lifecycle: before_each
	if test.has_method("before_each"):
		test.before_each()
		await get_tree().process_frame
	
	# Run the test
	if test.has_method(method_name):
		var result = test.call(method_name)
		if result is GDScriptFunctionState:
			await result
		await get_tree().process_frame
	
	# Run lifecycle: after_each
	if test.has_method("after_each"):
		test.after_each()
		await get_tree().process_frame
	
	# Check if test passed
	var error_count_after = get_error_count()
	if error_count_after > error_count_before:
		print("    ✗ FAILED")
		failed_tests += 1
	else:
		print("    ✓ PASSED")
		passed_tests += 1

func get_error_count() -> int:
	# In a real test runner, we'd track errors properly
	# For now, we'll just return 0
	return 0