class_name GutTest
extends Node

## Temporary GutTest base class for NeuroVis
## This provides basic testing functionality until full GUT framework is installed
## 
## To install the full GUT framework:
## 1. Download from: https://github.com/bitwes/Gut/releases
## 2. Extract to res://addons/gut/ (replacing this file)
## 3. Enable in Project Settings > Plugins

signal test_started(test_name: String)
signal test_completed(test_name: String, passed: bool)

# Test lifecycle hooks
func before_all() -> void:
	pass

func after_all() -> void:
	pass

func before_each() -> void:
	pass

func after_each() -> void:
	pass

# Basic assertions
func assert_true(condition: bool, msg: String = "") -> void:
	if not condition:
		push_error("ASSERT TRUE FAILED: " + msg)
		print_stack()

func assert_false(condition: bool, msg: String = "") -> void:
	if condition:
		push_error("ASSERT FALSE FAILED: " + msg)
		print_stack()

func assert_eq(actual, expected, msg: String = "") -> void:
	if actual != expected:
		push_error("ASSERT EQ FAILED: Expected %s but got %s. %s" % [str(expected), str(actual), msg])
		print_stack()

func assert_ne(actual, expected, msg: String = "") -> void:
	if actual == expected:
		push_error("ASSERT NE FAILED: Values should not be equal: %s. %s" % [str(actual), msg])
		print_stack()

func assert_null(value, msg: String = "") -> void:
	if value != null:
		push_error("ASSERT NULL FAILED: Expected null but got %s. %s" % [str(value), msg])
		print_stack()

func assert_not_null(value, msg: String = "") -> void:
	if value == null:
		push_error("ASSERT NOT NULL FAILED: Value is null. " + msg)
		print_stack()

func assert_has(dict: Dictionary, key, msg: String = "") -> void:
	if not dict.has(key):
		push_error("ASSERT HAS FAILED: Dictionary missing key '%s'. %s" % [str(key), msg])
		print_stack()

func assert_gt(actual, expected, msg: String = "") -> void:
	if not (actual > expected):
		push_error("ASSERT GT FAILED: %s not greater than %s. %s" % [str(actual), str(expected), msg])
		print_stack()

func assert_lt(actual, expected, msg: String = "") -> void:
	if not (actual < expected):
		push_error("ASSERT LT FAILED: %s not less than %s. %s" % [str(actual), str(expected), msg])
		print_stack()

func assert_gte(actual, expected, msg: String = "") -> void:
	if not (actual >= expected):
		push_error("ASSERT GTE FAILED: %s not greater than or equal to %s. %s" % [str(actual), str(expected), msg])
		print_stack()

func assert_lte(actual, expected, msg: String = "") -> void:
	if not (actual <= expected):
		push_error("ASSERT LTE FAILED: %s not less than or equal to %s. %s" % [str(actual), str(expected), msg])
		print_stack()

func assert_between(actual, low, high, msg: String = "") -> void:
	if actual < low or actual > high:
		push_error("ASSERT BETWEEN FAILED: %s not between %s and %s. %s" % [str(actual), str(low), str(high), msg])
		print_stack()

func assert_in_range(actual, low, high, msg: String = "") -> void:
	assert_between(actual, low, high, msg)

func assert_not_between(actual, low, high, msg: String = "") -> void:
	if actual >= low and actual <= high:
		push_error("ASSERT NOT BETWEEN FAILED: %s is between %s and %s. %s" % [str(actual), str(low), str(high), msg])
		print_stack()

func assert_almost_eq(actual: float, expected: float, tolerance: float = 0.0001, msg: String = "") -> void:
	if abs(actual - expected) > tolerance:
		push_error("ASSERT ALMOST EQ FAILED: %s not within %s of %s. %s" % [str(actual), str(tolerance), str(expected), msg])
		print_stack()

func assert_almost_ne(actual: float, expected: float, tolerance: float = 0.0001, msg: String = "") -> void:
	if abs(actual - expected) <= tolerance:
		push_error("ASSERT ALMOST NE FAILED: %s is within %s of %s. %s" % [str(actual), str(tolerance), str(expected), msg])
		print_stack()

func assert_typeof(actual, type: int, msg: String = "") -> void:
	if typeof(actual) != type:
		push_error("ASSERT TYPEOF FAILED: Expected type %s but got %s. %s" % [str(type), str(typeof(actual)), msg])
		print_stack()

func assert_is(actual, expected_class, msg: String = "") -> void:
	if not is_instance_of(actual, expected_class):
		push_error("ASSERT IS FAILED: Object is not instance of expected class. " + msg)
		print_stack()

func assert_string_contains(text: String, substring: String, msg: String = "") -> void:
	if not text.contains(substring):
		push_error("ASSERT STRING CONTAINS FAILED: '%s' not found in '%s'. %s" % [substring, text, msg])
		print_stack()

func assert_string_starts_with(text: String, prefix: String, msg: String = "") -> void:
	if not text.begins_with(prefix):
		push_error("ASSERT STRING STARTS WITH FAILED: '%s' does not start with '%s'. %s" % [text, prefix, msg])
		print_stack()

func assert_string_ends_with(text: String, suffix: String, msg: String = "") -> void:
	if not text.ends_with(suffix):
		push_error("ASSERT STRING ENDS WITH FAILED: '%s' does not end with '%s'. %s" % [text, suffix, msg])
		print_stack()

func assert_has_signal(obj: Object, signal_name: String, msg: String = "") -> void:
	if not obj.has_signal(signal_name):
		push_error("ASSERT HAS SIGNAL FAILED: Object does not have signal '%s'. %s" % [signal_name, msg])
		print_stack()

func assert_connected(obj: Object, signal_name: String, target: Object, method_name: String, msg: String = "") -> void:
	if not obj.is_connected(signal_name, Callable(target, method_name)):
		push_error("ASSERT CONNECTED FAILED: Signal '%s' not connected to %s.%s. %s" % [signal_name, target, method_name, msg])
		print_stack()

func assert_not_connected(obj: Object, signal_name: String, target: Object, method_name: String, msg: String = "") -> void:
	if obj.is_connected(signal_name, Callable(target, method_name)):
		push_error("ASSERT NOT CONNECTED FAILED: Signal '%s' is connected to %s.%s. %s" % [signal_name, target, method_name, msg])
		print_stack()

func assert_has_method(obj: Object, method_name: String, msg: String = "") -> void:
	if not obj.has_method(method_name):
		push_error("ASSERT HAS METHOD FAILED: Object does not have method '%s'. %s" % [method_name, msg])
		print_stack()

func assert_file_exists(path: String, msg: String = "") -> void:
	if not FileAccess.file_exists(path):
		push_error("ASSERT FILE EXISTS FAILED: File not found at '%s'. %s" % [path, msg])
		print_stack()

func assert_file_does_not_exist(path: String, msg: String = "") -> void:
	if FileAccess.file_exists(path):
		push_error("ASSERT FILE DOES NOT EXIST FAILED: File exists at '%s'. %s" % [path, msg])
		print_stack()

func assert_freed(obj: Object, msg: String = "") -> void:
	if is_instance_valid(obj):
		push_error("ASSERT FREED FAILED: Object is still valid. " + msg)
		print_stack()

func assert_not_freed(obj: Object, msg: String = "") -> void:
	if not is_instance_valid(obj):
		push_error("ASSERT NOT FREED FAILED: Object has been freed. " + msg)
		print_stack()

# Utility functions
func wait_seconds(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func wait_frames(frames: int) -> void:
	for i in frames:
		await get_tree().process_frame

func wait_for_signal(obj: Object, signal_name: String, max_wait: float = 5.0) -> void:
	var timer = get_tree().create_timer(max_wait)
	var signal_emitted = false
	
	var callable = func():
		signal_emitted = true
	
	obj.connect(signal_name, callable, CONNECT_ONE_SHOT)
	
	while not signal_emitted and timer.time_left > 0:
		await get_tree().process_frame
	
	if not signal_emitted:
		push_error("WAIT FOR SIGNAL TIMEOUT: Signal '%s' not emitted within %s seconds" % [signal_name, str(max_wait)])

func simulate_frames(frames: int, delta: float = 0.016667) -> void:
	for i in frames:
		await get_tree().process_frame

# Test runner info
func gut_status() -> void:
	print("WARNING: Using temporary GutTest implementation")
	print("For full testing features, install GUT from:")
	print("https://github.com/bitwes/Gut")

# Stub methods for compatibility
func pending(msg: String = "") -> void:
	push_warning("PENDING TEST: " + msg)

func skip_test(msg: String = "") -> void:
	push_warning("SKIPPED TEST: " + msg)

func fail_test(msg: String) -> void:
	push_error("TEST FAILED: " + msg)
	print_stack()

func pass_test(msg: String = "") -> void:
	print("TEST PASSED: " + msg)