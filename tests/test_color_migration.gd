extends Node

## Test suite for color migration to M3DesignTokens
## Validates that all colors are properly centralized and no hardcoded values remain

var test_results = {
	"color_resolution": "PENDING",
	"semantic_colors": "PENDING",
	"ui_colors": "PENDING",
	"migration_detection": "PENDING",
	"theme_generation": "PENDING",
	"performance": "PENDING",
	"errors": []
}

func _ready() -> void:
	print("\n========== Color Migration Test ==========")
	print("Testing M3DesignTokens color centralization...")
	
	# Create test container
	var container = VBoxContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.add_theme_constant_override("separation", 20)
	add_child(container)
	
	# Title
	var title = Label.new()
	title.text = "Color Migration Test Suite"
	title.add_theme_font_size_override("font_size", 24)
	container.add_child(title)
	
	# Run tests
	await _test_color_resolution(container)
	await _test_semantic_colors(container)
	await _test_ui_colors(container)
	await _test_migration_detection(container)
	await _test_theme_generation(container)
	await _test_performance(container)
	
	# Report results
	_generate_report()

func _test_color_resolution(container: Control) -> void:
	"""Test basic color resolution from tokens"""
	print("\n[Test] Testing color resolution...")
	
	var section_label = Label.new()
	section_label.text = "Color Resolution Test"
	section_label.add_theme_font_size_override("font_size", 18)
	container.add_child(section_label)
	
	var test_tokens = ["primary", "surface", "error", "brain_hippocampus"]
	var resolved_count = 0
	
	for token in test_tokens:
		var color = M3DesignTokens.get_color(token)
		if color != null:
			resolved_count += 1
			print("  ✓ Resolved '%s' -> %s" % [token, color])
		else:
			test_results.errors.append("Failed to resolve token: " + token)
			print("  ✗ Failed to resolve token: %s" % token)
	
	test_results.color_resolution = "PASS" if resolved_count == test_tokens.size() else "FAIL"
	
	# Visual display
	var color_grid = GridContainer.new()
	color_grid.columns = 5
	container.add_child(color_grid)
	
	for token in test_tokens:
		var color_rect = ColorRect.new()
		color_rect.custom_minimum_size = Vector2(60, 40)
		color_rect.color = M3DesignTokens.get_color(token)
		color_grid.add_child(color_rect)
		
		var label = Label.new()
		label.text = token
		label.add_theme_font_size_override("font_size", 10)
		color_grid.add_child(label)

func _test_semantic_colors(container: Control) -> void:
	"""Test semantic color roles"""
	print("\n[Test] Testing semantic colors...")
	
	var section_label = Label.new()
	section_label.text = "Semantic Colors Test"
	section_label.add_theme_font_size_override("font_size", 18)
	container.add_child(section_label)
	
	var semantic_roles = [
		"button_primary",
		"button_disabled",
		"text_primary",
		"text_disabled",
		"background_primary",
		"border_focus"
	]
	
	var all_valid = true
	for role in semantic_roles:
		var color = M3DesignTokens.get_semantic_color(role)
		if color == null or not color is Color:
			all_valid = false
			test_results.errors.append("Invalid semantic color: " + role)
			print("  ✗ Invalid semantic color: %s" % role)
		else:
			print("  ✓ Semantic color '%s' -> %s" % [role, color])
	
	test_results.semantic_colors = "PASS" if all_valid else "FAIL"

func _test_ui_colors(container: Control) -> void:
	"""Test UI element colors with states"""
	print("\n[Test] Testing UI element colors...")
	
	var section_label = Label.new()
	section_label.text = "UI Element Colors Test"
	section_label.add_theme_font_size_override("font_size", 18)
	container.add_child(section_label)
	
	var elements = ["panel", "button", "input", "label"]
	var states = ["default", "hover", "pressed", "disabled", "focus"]
	
	var test_panel = HBoxContainer.new()
	container.add_child(test_panel)
	
	var all_valid = true
	for element in elements:
		var element_box = VBoxContainer.new()
		test_panel.add_child(element_box)
		
		var element_label = Label.new()
		element_label.text = element.capitalize()
		element_label.add_theme_font_size_override("font_size", 12)
		element_box.add_child(element_label)
		
		for state in states:
			var color = M3DesignTokens.get_ui_color(element, state)
			if color == null or not color is Color:
				all_valid = false
				test_results.errors.append("Invalid UI color: %s/%s" % [element, state])
			else:
				var color_rect = ColorRect.new()
				color_rect.custom_minimum_size = Vector2(50, 20)
				color_rect.color = color
				color_rect.tooltip_text = "%s: %s" % [state, color]
				element_box.add_child(color_rect)
	
	test_results.ui_colors = "PASS" if all_valid else "FAIL"

func _test_migration_detection(container: Control) -> void:
	"""Test color migration detection"""
	print("\n[Test] Testing migration detection...")
	
	var section_label = Label.new()
	section_label.text = "Migration Detection Test"
	section_label.add_theme_font_size_override("font_size", 18)
	container.add_child(section_label)
	
	# Test color matching
	var test_colors = [
		{"color": Color(0.129, 0.871, 0.922), "expected": "primary"},
		{"color": Color.WHITE, "expected": "on_primary"},
		{"color": Color.BLACK, "expected": "shadow"},  # Black maps to shadow
		{"color": Color(0.941, 0.196, 0.274), "expected": "error"}
	]
	
	var correct_matches = 0
	for test in test_colors:
		var mapping = M3ColorMigrator.find_closest_token(test.color)
		if mapping.token_path == test.expected and mapping.confidence >= 0.7:
			correct_matches += 1
			print("  ✓ Correctly matched %s -> %s (%.1f%% confidence)" % [
				test.color, mapping.token_path, mapping.confidence * 100
			])
		else:
			print("  ✗ Failed to match %s (expected %s, got %s)" % [
				test.color, test.expected, mapping.token_path
			])
	
	test_results.migration_detection = "PASS" if correct_matches == test_colors.size() else "FAIL"

func _test_theme_generation(container: Control) -> void:
	"""Test theme generation from tokens"""
	print("\n[Test] Testing theme generation...")
	
	var section_label = Label.new()
	section_label.text = "Theme Generation Test"
	section_label.add_theme_font_size_override("font_size", 18)
	container.add_child(section_label)
	
	# Test custom theme generation
	var custom_primary = Color(0.5, 0.2, 0.8)  # Purple
	var custom_theme = ThemeResourceGenerator.generate_custom_theme(
		"Test Purple Theme",
		custom_primary,
		"dark"
	)
	
	if custom_theme != null:
		test_results.theme_generation = "PASS"
		print("  ✓ Successfully generated custom theme")
		
		# Apply theme to test button
		var test_button = Button.new()
		test_button.text = "Custom Theme Button"
		test_button.theme = custom_theme
		container.add_child(test_button)
	else:
		test_results.theme_generation = "FAIL"
		test_results.errors.append("Failed to generate custom theme")

func _test_performance(container: Control) -> void:
	"""Test color resolution performance"""
	print("\n[Test] Testing color resolution performance...")
	
	var section_label = Label.new()
	section_label.text = "Performance Test"
	section_label.add_theme_font_size_override("font_size", 18)
	container.add_child(section_label)
	
	# Clear cache for accurate testing
	M3DesignTokens.clear_color_cache()
	
	# Test uncached performance
	var start_time = Time.get_ticks_usec()
	var iterations = 1000
	
	for i in range(iterations):
		var _color1 = M3DesignTokens.get_color("primary")
		var _color2 = M3DesignTokens.get_semantic_color("button_primary")
		var _color3 = M3DesignTokens.get_ui_color("panel", "hover")
	
	var uncached_time = Time.get_ticks_usec() - start_time
	
	# Test cached performance
	start_time = Time.get_ticks_usec()
	
	for i in range(iterations):
		var _color1 = M3DesignTokens.get_color("primary")
		var _color2 = M3DesignTokens.get_semantic_color("button_primary")
		var _color3 = M3DesignTokens.get_ui_color("panel", "hover")
	
	var cached_time = Time.get_ticks_usec() - start_time
	
	var speedup = float(uncached_time) / float(cached_time)
	
	print("  Uncached: %d µs for %d iterations (%.2f µs/call)" % [
		uncached_time, iterations * 3, uncached_time / float(iterations * 3)
	])
	print("  Cached: %d µs for %d iterations (%.2f µs/call)" % [
		cached_time, iterations * 3, cached_time / float(iterations * 3)
	])
	print("  Cache speedup: %.1fx" % speedup)
	
	var perf_label = Label.new()
	perf_label.text = "Performance: %.1fx speedup with caching" % speedup
	container.add_child(perf_label)
	
	# Pass if cached is faster
	test_results.performance = "PASS" if speedup > 1.5 else "FAIL"

func _generate_report() -> void:
	"""Generate final test report"""
	await get_tree().create_timer(1.0).timeout
	
	print("\n========== Color Migration Test Results ==========")
	
	print("\nTest Results:")
	print("  Color Resolution: %s" % test_results.color_resolution)
	print("  Semantic Colors: %s" % test_results.semantic_colors)
	print("  UI Colors: %s" % test_results.ui_colors)
	print("  Migration Detection: %s" % test_results.migration_detection)
	print("  Theme Generation: %s" % test_results.theme_generation)
	print("  Performance: %s" % test_results.performance)
	
	if test_results.errors.size() > 0:
		print("\nErrors encountered:")
		for error in test_results.errors:
			print("  - %s" % error)
	
	# Summary
	var passed = 0
	var total = 0
	for key in test_results:
		if key != "errors" and test_results[key] == "PASS":
			passed += 1
		if key != "errors":
			total += 1
	
	print("\nSummary: %d/%d tests passed" % [passed, total])
	
	# Visual result
	var result_label = Label.new()
	result_label.text = "Color Migration Test Complete: %d/%d passed" % [passed, total]
	result_label.add_theme_font_size_override("font_size", 20)
	if passed == total:
		result_label.add_theme_color_override("font_color", M3DesignTokens.get_color("success"))
	elif passed > total / 2:
		result_label.add_theme_color_override("font_color", M3DesignTokens.get_color("warning"))
	else:
		result_label.add_theme_color_override("font_color", M3DesignTokens.get_color("error"))
	get_child(0).add_child(result_label)
	
	# Check for remaining hardcoded colors
	print("\n[Bonus Check] Scanning for remaining hardcoded colors...")
	var files_to_check = [
		"res://src/ui/components/StructureInfoPanel.gd",
		"res://src/ui/components/QuizPanel.gd"
	]
	
	for file_path in files_to_check:
		var instances = M3ColorMigrator.analyze_file(file_path)
		if instances.size() > 0:
			print("  ⚠️ Found %d hardcoded colors in %s" % [instances.size(), file_path])
		else:
			print("  ✓ No hardcoded colors in %s" % file_path)