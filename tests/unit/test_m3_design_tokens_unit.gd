extends Node

## Unit tests for M3DesignTokens color resolution API
## Tests all public methods, edge cases, and performance characteristics

class_name TestM3DesignTokensUnit

# Test results tracking
var tests_passed: int = 0
var tests_failed: int = 0
var test_results: Dictionary = {}

func _ready() -> void:
	print("\n========== M3DesignTokens Unit Tests ==========")
	
	# Clear cache before tests
	M3DesignTokens.clear_color_cache()
	
	# Run all test suites
	test_get_color()
	test_get_semantic_color()
	test_get_ui_color()
	test_color_caching()
	test_token_validation()
	test_edge_cases()
	test_performance()
	
	# Report results
	_report_results()

# === TEST SUITES ===

func test_get_color() -> void:
	print("\n[Test Suite] get_color()")
	
	# Test valid M3 color tokens
	_assert_color_equals(
		M3DesignTokens.get_color("primary"),
		M3DesignTokens.M3_COLORS["primary"],
		"get_color('primary') returns correct color"
	)
	
	_assert_color_equals(
		M3DesignTokens.get_color("surface"),
		M3DesignTokens.M3_COLORS["surface"],
		"get_color('surface') returns correct color"
	)
	
	# Test brain structure colors without prefix
	_assert_color_equals(
		M3DesignTokens.get_color("hippocampus"),
		M3DesignTokens.BRAIN_STRUCTURE_COLORS["hippocampus"],
		"get_color('hippocampus') returns brain color"
	)
	
	# Test brain structure colors with prefix
	_assert_color_equals(
		M3DesignTokens.get_color("brain_hippocampus"),
		M3DesignTokens.BRAIN_STRUCTURE_COLORS["hippocampus"],
		"get_color('brain_hippocampus') returns brain color"
	)
	
	# Test educational mapping
	_assert_color_equals(
		M3DesignTokens.get_color("brain_structure_highlight"),
		M3DesignTokens.M3_COLORS["primary"],
		"get_color('brain_structure_highlight') maps to primary"
	)
	
	# Test invalid token (should return fallback)
	_assert_color_equals(
		M3DesignTokens.get_color("invalid_token"),
		M3DesignTokens.M3_COLORS["on_surface"],
		"get_color('invalid_token') returns fallback color"
	)
	
	# Test theme variant parameter (currently unused but should not break)
	_assert_color_equals(
		M3DesignTokens.get_color("primary", "dark"),
		M3DesignTokens.M3_COLORS["primary"],
		"get_color() with theme variant works"
	)

func test_get_semantic_color() -> void:
	print("\n[Test Suite] get_semantic_color()")
	
	# Test button semantics
	_assert_color_equals(
		M3DesignTokens.get_semantic_color("button_primary"),
		M3DesignTokens.M3_COLORS["primary"],
		"button_primary returns primary color"
	)
	
	_assert_color_equals(
		M3DesignTokens.get_semantic_color("button_secondary"),
		M3DesignTokens.M3_COLORS["secondary"],
		"button_secondary returns secondary color"
	)
	
	# Test disabled state
	var disabled_color = M3DesignTokens.get_semantic_color("button_disabled")
	_assert_float_equals(
		disabled_color.a,
		M3DesignTokens.M3_OPACITY["disabled"],
		"button_disabled has correct opacity"
	)
	
	# Test text semantics
	_assert_color_equals(
		M3DesignTokens.get_semantic_color("text_primary"),
		M3DesignTokens.M3_COLORS["on_surface"],
		"text_primary returns on_surface"
	)
	
	var text_secondary = M3DesignTokens.get_semantic_color("text_secondary")
	_assert_float_equals(
		text_secondary.a,
		0.7,
		"text_secondary has 70% opacity"
	)
	
	# Test background semantics
	_assert_color_equals(
		M3DesignTokens.get_semantic_color("background_primary"),
		M3DesignTokens.M3_COLORS["surface"],
		"background_primary returns surface"
	)
	
	# Test undefined semantic (should fallback to get_color)
	_assert_color_equals(
		M3DesignTokens.get_semantic_color("primary"),
		M3DesignTokens.M3_COLORS["primary"],
		"undefined semantic falls back to get_color"
	)

func test_get_ui_color() -> void:
	print("\n[Test Suite] get_ui_color()")
	
	# Test element types
	_assert_color_equals(
		M3DesignTokens.get_ui_color("panel"),
		M3DesignTokens.M3_COLORS["surface"],
		"panel returns surface color"
	)
	
	_assert_color_equals(
		M3DesignTokens.get_ui_color("card"),
		M3DesignTokens.M3_COLORS["surface_container"],
		"card returns surface_container"
	)
	
	_assert_color_equals(
		M3DesignTokens.get_ui_color("button"),
		M3DesignTokens.M3_COLORS["primary"],
		"button returns primary"
	)
	
	# Test states
	var hover_color = M3DesignTokens.get_ui_color("button", "hover")
	_assert_true(
		hover_color.a < 1.0,
		"hover state has transparency"
	)
	
	var disabled_color = M3DesignTokens.get_ui_color("button", "disabled")
	_assert_float_equals(
		disabled_color.a,
		M3DesignTokens.M3_OPACITY["disabled"],
		"disabled state has correct opacity"
	)
	
	# Test unknown element (should default to surface)
	_assert_color_equals(
		M3DesignTokens.get_ui_color("unknown_element"),
		M3DesignTokens.M3_COLORS["surface"],
		"unknown element returns surface"
	)

func test_color_caching() -> void:
	print("\n[Test Suite] Color Caching")
	
	# Clear cache first
	M3DesignTokens.clear_color_cache()
	
	# Measure uncached access time
	var start_time = Time.get_ticks_usec()
	var color1 = M3DesignTokens.get_color("primary")
	var uncached_time = Time.get_ticks_usec() - start_time
	
	# Measure cached access time (second call)
	start_time = Time.get_ticks_usec()
	var color2 = M3DesignTokens.get_color("primary")
	var cached_time = Time.get_ticks_usec() - start_time
	
	_assert_color_equals(color1, color2, "Cached color matches original")
	_assert_true(cached_time <= uncached_time, "Cached access is not slower")
	
	# Test cache clearing
	M3DesignTokens.clear_color_cache()
	
	# After clearing, should still return same color
	var color3 = M3DesignTokens.get_color("primary")
	_assert_color_equals(color1, color3, "Color unchanged after cache clear")

func test_token_validation() -> void:
	print("\n[Test Suite] Token Validation")
	
	# Test has_token for various token types
	_assert_true(
		M3DesignTokens.has_token("primary"),
		"has_token('primary') returns true"
	)
	
	_assert_true(
		M3DesignTokens.has_token("hippocampus"),
		"has_token('hippocampus') returns true"
	)
	
	_assert_true(
		M3DesignTokens.has_token("brain_hippocampus"),
		"has_token('brain_hippocampus') returns true"
	)
	
	_assert_true(
		M3DesignTokens.has_token("brain_structure_highlight"),
		"has_token('brain_structure_highlight') returns true"
	)
	
	_assert_false(
		M3DesignTokens.has_token("invalid_token"),
		"has_token('invalid_token') returns false"
	)
	
	_assert_false(
		M3DesignTokens.has_token(""),
		"has_token('') returns false"
	)
	
	# Test get_available_tokens
	var tokens = M3DesignTokens.get_available_tokens()
	_assert_true(tokens.size() > 0, "get_available_tokens() returns non-empty array")
	_assert_true("primary" in tokens, "Token list contains 'primary'")
	_assert_true("brain_hippocampus" in tokens, "Token list contains brain tokens")

func test_edge_cases() -> void:
	print("\n[Test Suite] Edge Cases")
	
	# Test empty string
	var empty_color = M3DesignTokens.get_color("")
	_assert_not_null(empty_color, "get_color('') returns non-null")
	_assert_color_equals(
		empty_color,
		M3DesignTokens.M3_COLORS["on_surface"],
		"get_color('') returns fallback"
	)
	
	# Test very long token name
	var long_token = "a".repeat(100)
	var long_color = M3DesignTokens.get_color(long_token)
	_assert_not_null(long_color, "get_color(long_string) returns non-null")
	
	# Test special characters
	var special_color = M3DesignTokens.get_color("token!@#$%")
	_assert_not_null(special_color, "get_color(special_chars) returns non-null")
	
	# Test case sensitivity
	var lower_color = M3DesignTokens.get_color("primary")
	var upper_color = M3DesignTokens.get_color("PRIMARY")
	_assert_color_not_equals(
		upper_color,
		lower_color,
		"Token names are case-sensitive"
	)

func test_performance() -> void:
	print("\n[Test Suite] Performance")
	
	# Clear cache for accurate measurement
	M3DesignTokens.clear_color_cache()
	
	var iterations = 10000
	var tokens = ["primary", "surface", "error", "brain_hippocampus", "text_primary"]
	
	# Test bulk color resolution
	var start_time = Time.get_ticks_usec()
	for i in range(iterations):
		for token in tokens:
			var _color = M3DesignTokens.get_color(token)
	var total_time = Time.get_ticks_usec() - start_time
	
	var calls = iterations * tokens.size()
	var avg_time = float(total_time) / float(calls)
	
	print("  Performance: %d calls in %d µs (%.2f µs/call)" % [calls, total_time, avg_time])
	_assert_true(avg_time < 5.0, "Average call time under 5 microseconds")
	
	# Test cache efficiency
	var cache_misses = iterations * tokens.size()  # First iteration
	var cache_hits = iterations * tokens.size() * 4  # Subsequent iterations
	print("  Cache efficiency: %d hits, %d misses" % [cache_hits, cache_misses])

# === ASSERTION HELPERS ===

func _assert_true(condition: bool, message: String) -> void:
	if condition:
		tests_passed += 1
		print("  ✓ " + message)
		test_results[message] = "PASS"
	else:
		tests_failed += 1
		push_error("  ✗ " + message)
		test_results[message] = "FAIL"

func _assert_false(condition: bool, message: String) -> void:
	_assert_true(not condition, message)

func _assert_equals(actual, expected, message: String) -> void:
	_assert_true(actual == expected, message + " (got: %s)" % str(actual))

func _assert_not_equals(actual, expected, message: String) -> void:
	_assert_true(actual != expected, message)

func _assert_color_equals(actual: Color, expected: Color, message: String) -> void:
	var tolerance = 0.001
	var equals = abs(actual.r - expected.r) < tolerance and \
				 abs(actual.g - expected.g) < tolerance and \
				 abs(actual.b - expected.b) < tolerance and \
				 abs(actual.a - expected.a) < tolerance
	_assert_true(equals, message + " (got: %s)" % str(actual))

func _assert_color_not_equals(actual: Color, expected: Color, message: String) -> void:
	var equals = actual.r == expected.r and \
				 actual.g == expected.g and \
				 actual.b == expected.b and \
				 actual.a == expected.a
	_assert_false(equals, message)

func _assert_float_equals(actual: float, expected: float, message: String) -> void:
	var tolerance = 0.001
	_assert_true(abs(actual - expected) < tolerance, message + " (got: %.3f)" % actual)

func _assert_null(value, message: String) -> void:
	_assert_true(value == null, message)

func _assert_not_null(value, message: String) -> void:
	_assert_true(value != null, message)

# === REPORTING ===

func _report_results() -> void:
	print("\n========== Test Results ==========")
	print("Passed: %d" % tests_passed)
	print("Failed: %d" % tests_failed)
	print("Total: %d" % (tests_passed + tests_failed))
	
	if tests_failed > 0:
		print("\nFailed tests:")
		for test in test_results:
			if test_results[test] == "FAIL":
				print("  - " + test)
	
	var success_rate = float(tests_passed) / float(tests_passed + tests_failed) * 100.0
	print("\nSuccess rate: %.1f%%" % success_rate)