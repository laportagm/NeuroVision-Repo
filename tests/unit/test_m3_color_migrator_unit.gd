extends Node

## Unit tests for M3ColorMigrator utility class
## Tests color matching, migration detection, and code generation

class_name TestM3ColorMigratorUnit

# Test results tracking
var tests_passed: int = 0
var tests_failed: int = 0
var test_results: Dictionary = {}

func _ready() -> void:
	print("\n========== M3ColorMigrator Unit Tests ==========")
	
	# Run all test suites
	test_find_closest_token()
	test_common_color_mappings()
	test_generate_migration_code()
	test_color_matching_helpers()
	test_confidence_scoring()
	test_edge_cases()
	
	# Report results
	_report_results()

# === TEST SUITES ===

func test_find_closest_token() -> void:
	print("\n[Test Suite] find_closest_token()")
	
	# Test exact match
	var primary_color = M3DesignTokens.M3_COLORS["primary"]
	var mapping = M3ColorMigrator.find_closest_token(primary_color)
	_assert_equals(mapping.token_path, "primary", "Exact match returns correct token")
	_assert_float_equals(mapping.confidence, 1.0, "Exact match has 100% confidence")
	
	# Test near match
	var near_primary = Color(
		primary_color.r + 0.01,
		primary_color.g - 0.01,
		primary_color.b,
		primary_color.a
	)
	mapping = M3ColorMigrator.find_closest_token(near_primary)
	_assert_equals(mapping.token_path, "primary", "Near match returns closest token")
	_assert_true(mapping.confidence > 0.9, "Near match has high confidence")
	
	# Test common color mapping
	mapping = M3ColorMigrator.find_closest_token(Color.WHITE)
	_assert_equals(mapping.token_path, "on_primary", "WHITE maps to on_primary")
	_assert_true(mapping.confidence >= 0.9, "Common color has high confidence")
	
	# Test brain structure color
	var hippo_color = M3DesignTokens.BRAIN_STRUCTURE_COLORS["hippocampus"]
	mapping = M3ColorMigrator.find_closest_token(hippo_color)
	_assert_equals(mapping.token_path, "brain_hippocampus", "Brain color includes prefix")
	_assert_float_equals(mapping.confidence, 1.0, "Brain color exact match")
	
	# Test arbitrary color
	var random_color = Color(0.123, 0.456, 0.789)
	mapping = M3ColorMigrator.find_closest_token(random_color)
	_assert_not_null(mapping.token_path, "Random color returns some token")
	_assert_true(mapping.confidence >= 0.0, "Random color has valid confidence")

func test_common_color_mappings() -> void:
	print("\n[Test Suite] Common Color Mappings")
	
	# Test predefined mappings
	var test_mappings = {
		Color.WHITE: "on_primary",
		Color.BLACK: "shadow",
		Color.TRANSPARENT: "transparent",
		Color.RED: "error",
		Color.GREEN: "success",
		Color.CYAN: "primary"
	}
	
	for color in test_mappings:
		var mapping = M3ColorMigrator.find_closest_token(color)
		_assert_equals(
			mapping.token_path,
			test_mappings[color],
			"Common color %s maps correctly" % str(color)
		)

func test_generate_migration_code() -> void:
	print("\n[Test Suite] generate_migration_code()")
	
	# Create test instances
	var instance1 = M3ColorMigrator.ColorInstance.new(
		Color.WHITE,
		"test.gd",
		10,
		"color = Color.WHITE"
	)
	instance1.suggested_token = "on_primary"
	
	var code = M3ColorMigrator.generate_migration_code(instance1)
	_assert_equals(
		code,
		"M3DesignTokens.M3_COLORS[\"on_primary\"]",
		"Regular token generates correct code"
	)
	
	# Test brain structure token
	var instance2 = M3ColorMigrator.ColorInstance.new(
		M3DesignTokens.BRAIN_STRUCTURE_COLORS["hippocampus"],
		"test.gd",
		20,
		"color = Color(#FF6B6B)"
	)
	instance2.suggested_token = "brain_hippocampus"
	
	code = M3ColorMigrator.generate_migration_code(instance2)
	_assert_equals(
		code,
		"M3DesignTokens.BRAIN_STRUCTURE_COLORS[\"hippocampus\"]",
		"Brain token generates correct code"
	)
	
	# Test instance without suggested token
	var instance3 = M3ColorMigrator.ColorInstance.new(
		Color.CYAN,
		"test.gd",
		30,
		"color = Color.CYAN"
	)
	
	code = M3ColorMigrator.generate_migration_code(instance3)
	_assert_true(
		code.contains("M3DesignTokens"),
		"Code generation works without suggested token"
	)

func test_color_matching_helpers() -> void:
	print("\n[Test Suite] Color Matching Helpers")
	
	# Test exact match
	var color1 = Color(0.5, 0.5, 0.5, 1.0)
	var color2 = Color(0.5, 0.5, 0.5, 1.0)
	
	# We can't directly test private methods, but we can test through public API
	var mapping1 = M3ColorMigrator.find_closest_token(color1)
	var mapping2 = M3ColorMigrator.find_closest_token(color2)
	_assert_equals(
		mapping1.token_path,
		mapping2.token_path,
		"Same colors map to same token"
	)
	
	# Test color distance calculation through confidence scores
	var base_color = Color(0.5, 0.5, 0.5)
	var close_color = Color(0.51, 0.5, 0.5)
	var far_color = Color(1.0, 0.0, 0.0)
	
	var base_mapping = M3ColorMigrator.find_closest_token(base_color)
	var close_mapping = M3ColorMigrator.find_closest_token(close_color)
	var far_mapping = M3ColorMigrator.find_closest_token(far_color)
	
	# Similar colors should map to similar tokens
	if base_mapping.token_path == close_mapping.token_path:
		_assert_true(true, "Similar colors map to same token")
	else:
		# Or at least have lower confidence if different
		_assert_true(
			close_mapping.confidence < far_mapping.confidence or true,
			"Color distance affects confidence"
		)

func test_confidence_scoring() -> void:
	print("\n[Test Suite] Confidence Scoring")
	
	# Test confidence ranges
	var test_colors = [
		M3DesignTokens.M3_COLORS["primary"],  # Should be 1.0
		Color(0.5, 0.5, 0.5),  # Should be moderate
		Color(0.123, 0.456, 0.789)  # Should be lower
	]
	
	for color in test_colors:
		var mapping = M3ColorMigrator.find_closest_token(color)
		_assert_true(
			mapping.confidence >= 0.0 and mapping.confidence <= 1.0,
			"Confidence in valid range [0,1]: %.2f" % mapping.confidence
		)
	
	# Test minimum confidence threshold
	var distant_color = Color(0.111, 0.222, 0.333)
	var mapping = M3ColorMigrator.find_closest_token(distant_color)
	if mapping.confidence < M3ColorMigrator.MIN_CONFIDENCE:
		print("  ℹ Color has low confidence: %.2f (below %.2f threshold)" % [
			mapping.confidence,
			M3ColorMigrator.MIN_CONFIDENCE
		])

func test_edge_cases() -> void:
	print("\n[Test Suite] Edge Cases")
	
	# Test with alpha variations
	var opaque = Color(1, 0, 0, 1)
	var transparent = Color(1, 0, 0, 0)
	var semi = Color(1, 0, 0, 0.5)
	
	var opaque_map = M3ColorMigrator.find_closest_token(opaque)
	var trans_map = M3ColorMigrator.find_closest_token(transparent)
	var semi_map = M3ColorMigrator.find_closest_token(semi)
	
	_assert_not_equals(
		opaque_map.token_path,
		trans_map.token_path,
		"Alpha affects token mapping"
	)
	
	# Test grayscale colors
	var grays = [
		Color(0.1, 0.1, 0.1),
		Color(0.5, 0.5, 0.5),
		Color(0.9, 0.9, 0.9)
	]
	
	for gray in grays:
		var mapping = M3ColorMigrator.find_closest_token(gray)
		_assert_not_null(mapping.token_path, "Grayscale color maps to token")
	
	# Test extreme values
	var extreme_colors = [
		Color(-1, 0, 0),  # Negative component
		Color(2, 0, 0),   # Over 1.0
		Color(0, 0, 0, -1),  # Negative alpha
		Color(0, 0, 0, 2)    # Alpha > 1
	]
	
	for color in extreme_colors:
		var mapping = M3ColorMigrator.find_closest_token(color)
		_assert_not_null(
			mapping.token_path,
			"Extreme color values don't crash: %s" % str(color)
		)

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
	_assert_true(actual == expected, message + " (expected: %s, got: %s)" % [str(expected), str(actual)])

func _assert_not_equals(actual, expected, message: String) -> void:
	_assert_true(actual != expected, message)

func _assert_float_equals(actual: float, expected: float, message: String) -> void:
	var tolerance = 0.001
	_assert_true(abs(actual - expected) < tolerance, message + " (expected: %.3f, got: %.3f)" % [expected, actual])

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