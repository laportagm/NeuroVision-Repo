extends Node

## Console test for Material 3
## Run this with: godot --path . --script test_m3_console.gd

func _ready() -> void:
	print("\n=== TESTING MATERIAL 3 INTEGRATION ===\n")
	
	# Test 1: Check available themes
	print("Available themes:")
	var themes = UIThemeManager.get_available_themes()
	for theme in themes:
		print("  - %s: %s" % [theme, UIThemeManager.get_theme_display_name(theme)])
	
	# Test 2: Try to generate M3 theme
	print("\nGenerating Material 3 theme...")
	var m3_gen = preload("res://src/ui/themes/Material3ThemeGenerator.gd").new()
	m3_gen.setup_dependencies()
	var m3_theme = m3_gen.generate_material3_theme("default")
	
	if m3_theme:
		print("✓ Material 3 theme generated successfully")
		print("  - Has %d colors defined" % m3_theme.get_color_list("Label").size())
		print("  - Has %d styleboxes defined" % m3_theme.get_stylebox_list("Button").size())
		
		# Check accessibility
		var is_wcag = m3_theme.get_meta("wcag_aaa_validated", false)
		print("  - WCAG AAA validated: %s" % is_wcag)
	else:
		print("✗ Failed to generate Material 3 theme")
	
	# Test 3: Performance detection
	print("\nTesting performance detection...")
	var M3Perf = preload("res://src/ui/themes/M3PerformanceIntegration.gd")
	var perf_level = M3Perf.detect_optimal_performance_level()
	print("  - Detected level: %s" % M3Perf.get_performance_level_description(perf_level))
	
	# Test 4: Accessibility validation
	print("\nTesting accessibility validation...")
	var Validator = preload("res://src/ui/themes/M3AccessibilityValidator.gd")
	var base_validation = Validator.validate_m3_colors()
	print("  - Base M3 colors compliant: %s" % base_validation.is_compliant)
	if base_validation.issues.size() > 0:
		print("  - Issues: %d" % base_validation.issues.size())
		for issue in base_validation.issues:
			print("    • %s" % issue.description)
	
	print("\n=== TEST COMPLETE ===\n")
	
	# Exit after test
	get_tree().quit()