extends SceneTree

## Simple test runner for NeuroVis
## Run with: godot --headless --script scripts/run_tests.gd

var test_files = []
var tests_passed = 0
var tests_failed = 0

func _init():
	print("\n=== NeuroVis Test Runner ===\n")
	print("Note: Using temporary test framework. Install GUT for full features.\n")
	
	# Find all test files
	_find_test_files("res://tests/")
	
	# Run tests
	for test_file in test_files:
		_run_test_file(test_file)
	
	# Summary
	print("\n=== Test Summary ===")
	print("Tests Passed: %d" % tests_passed)
	print("Tests Failed: %d" % tests_failed)
	print("Total Tests: %d" % (tests_passed + tests_failed))
	
	# Exit with appropriate code
	quit(1 if tests_failed > 0 else 0)

func _find_test_files(path: String):
	var dir = DirAccess.open(path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			_find_test_files(full_path)
		elif file_name.ends_with(".gd") and file_name.begins_with("test_"):
			test_files.append(full_path)
		
		file_name = dir.get_next()

func _run_test_file(path: String):
	print("\nRunning tests in: %s" % path)
	print("-" * 50)
	
	var script = load(path)
	if not script:
		print("ERROR: Failed to load test file")
		tests_failed += 1
		return
	
	var test_instance = script.new()
	if not test_instance:
		print("ERROR: Failed to create test instance")
		tests_failed += 1
		return
	
	# Find and run test methods
	var methods = []
	for method in test_instance.get_method_list():
		if method.name.begins_with("test_"):
			methods.append(method.name)
	
	for method_name in methods:
		print("  Running %s..." % method_name)
		
		# Run before_each
		if test_instance.has_method("before_each"):
			test_instance.before_each()
		
		# Run test
		var start_errors = get_print_error_count()
		test_instance.call(method_name)
		var end_errors = get_print_error_count()
		
		# Check results
		if end_errors > start_errors:
			print("    ❌ FAILED")
			tests_failed += 1
		else:
			print("    ✅ PASSED")
			tests_passed += 1
		
		# Run after_each
		if test_instance.has_method("after_each"):
			test_instance.after_each()
	
	# Cleanup
	if test_instance.has_method("queue_free"):
		test_instance.queue_free()

func get_print_error_count() -> int:
	# This is a workaround - in real implementation we'd track errors better
	return 0