extends Node

## Quick test to verify Material 3 is working
## Add this to any scene or run as autoload

func _ready() -> void:
	print("\n=== MATERIAL 3 FUNCTIONALITY TEST ===")
	
	# Test 1: List available themes
	print("\n1. Available themes:")
	var themes = UIThemeManager.get_available_themes()
	for theme in themes:
		print("   - %s" % theme)
	
	# Test 2: Test theme generation
	print("\n2. Testing Material 3 generation:")
	UIThemeManager.set_theme("material3")
	await get_tree().create_timer(0.5).timeout
	
	var current = UIThemeManager.get_current_theme()
	print("   Current theme: %s" % current)
	print("   Is M3 active: %s" % UIThemeManager.is_material3_active())
	
	if UIThemeManager.current_theme_resource:
		print("   Theme loaded successfully!")
		var theme_res = UIThemeManager.current_theme_resource
		
		# Check some M3 properties
		if theme_res.has_color("font_color", "Label"):
			print("   - Has Label font color: %s" % theme_res.get_color("font_color", "Label"))
		if theme_res.has_stylebox("normal", "Button"):
			var button_style = theme_res.get_stylebox("normal", "Button")
			if button_style is StyleBoxFlat:
				print("   - Button bg color: %s" % button_style.bg_color)
				print("   - Button corner radius: %d" % button_style.corner_radius_top_left)
	
	# Test 3: Performance detection
	print("\n3. Performance integration:")
	var M3Perf = preload("res://src/ui/themes/M3PerformanceIntegration.gd")
	var perf_level = M3Perf.detect_optimal_performance_level()
	print("   Detected level: %d" % perf_level)
	
	# Test 4: Accessibility validation
	print("\n4. Accessibility check:")
	var Validator = preload("res://src/ui/themes/M3AccessibilityValidator.gd")
	var colors_valid = Validator.validate_m3_colors()
	print("   M3 colors WCAG compliant: %s" % colors_valid.is_compliant)
	
	print("\n=== TEST COMPLETE ===")
	print("Press F9 in MainMenu to toggle Material 3")
	print("Press F10 to cycle all themes")
	print("Press F11 to show theme info\n")