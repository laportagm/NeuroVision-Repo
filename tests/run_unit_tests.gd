extends SceneTree

## Simple test runner that executes unit tests and exits

func _init():
	print("\n========== COLOR SYSTEM UNIT TESTS ==========")
	print("Running unit tests for color migration system...")
	
	# Create test instances
	var m3_test = preload("res://tests/unit/test_m3_design_tokens_unit.gd").new()
	var migrator_test = preload("res://tests/unit/test_m3_color_migrator_unit.gd").new()
	
	# Add to tree
	root.add_child(m3_test)
	root.add_child(migrator_test)
	
	# Wait for tests to complete
	await create_timer(2.0).timeout
	
	# Report final results
	var total_passed = 0
	var total_failed = 0
	
	if m3_test.has_method("tests_passed"):
		total_passed += m3_test.tests_passed
		total_failed += m3_test.tests_failed
	
	if migrator_test.has_method("tests_passed"):
		total_passed += migrator_test.tests_passed
		total_failed += migrator_test.tests_failed
	
	print("\n========== FINAL RESULTS ==========")
	print("Total Passed: %d" % total_passed)
	print("Total Failed: %d" % total_failed)
	print("Success Rate: %.1f%%" % (float(total_passed) / float(total_passed + total_failed) * 100.0))
	
	# Exit
	quit(total_failed)