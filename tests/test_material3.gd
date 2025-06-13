extends Node

## Test script for Material 3 theme integration
## Run this from the main scene to test M3 functionality

func _ready() -> void:
	print("\n=== MATERIAL 3 THEME TEST ===\n")
	
	# Wait for UI to be ready
	await get_tree().process_frame
	
	# Test 1: Switch to Material 3 theme
	print("Test 1: Switching to Material 3 theme...")
	UIThemeManager.set_theme("material3")
	await get_tree().create_timer(2.0).timeout
	
	# Test 2: Check if Material 3 is active
	print("Test 2: Material 3 active: ", UIThemeManager.is_material3_active())
	
	# Test 3: Generate M3 theme for brain region
	print("Test 3: Generating M3 theme for hippocampus...")
	UIThemeManager.generate_m3_brain_region_theme("hippocampus", 1)
	await get_tree().create_timer(2.0).timeout
	
	# Test 4: Test M3 adaptive colors
	print("Test 4: Getting adaptive colors for brain structures...")
	var structures = ["hippocampus", "thalamus", "striatum"]
	for structure in structures:
		var color = UIThemeManager.get_m3_adaptive_color(structure)
		print("  - %s: %s" % [structure, color])
	
	# Test 5: Test accessibility variants
	print("\nTest 5: Testing accessibility variants...")
	
	print("  - Switching to M3 High Contrast...")
	UIThemeManager.set_theme("material3_high_contrast")
	await get_tree().create_timer(2.0).timeout
	
	print("  - Switching to M3 Colorblind Safe...")
	UIThemeManager.set_theme("material3_colorblind")
	await get_tree().create_timer(2.0).timeout
	
	# Test 6: Validate accessibility
	print("\nTest 6: Validating accessibility...")
	var current_theme = UIThemeManager.current_theme_resource
	if current_theme:
		var Validator = preload("res://src/ui/themes/M3AccessibilityValidator.gd")
		var validation = Validator.validate_theme(current_theme)
		print("  - WCAG AAA Compliant: ", validation.is_compliant)
		if validation.issues.size() > 0:
			print("  - Issues found: ", validation.issues.size())
	
	# Test 7: Test performance integration
	print("\nTest 7: Testing performance optimization...")
	var M3Performance = preload("res://src/ui/themes/M3PerformanceIntegration.gd")
	var perf_level = M3Performance.detect_optimal_performance_level()
	print("  - Detected performance level: ", M3Performance.get_performance_level_description(perf_level))
	
	# Test 8: Apply glass morphism
	print("\nTest 8: Testing glass morphism effect...")
	var test_panel = PanelContainer.new()
	test_panel.custom_minimum_size = Vector2(200, 100)
	get_tree().root.add_child(test_panel)
	UIThemeManager.apply_m3_glass_morphism(test_panel, 0.85)
	print("  - Glass morphism applied to test panel")
	
	await get_tree().create_timer(2.0).timeout
	test_panel.queue_free()
	
	print("\n=== MATERIAL 3 TESTS COMPLETE ===\n")
	
	# Return to default theme
	print("Returning to default theme...")
	UIThemeManager.set_theme("dark")

func _input(event: InputEvent) -> void:
	# Press M to manually trigger Material 3 theme
	if event.is_action_pressed("ui_text_submit"):  # Enter key
		if Input.is_key_pressed(KEY_M):
			print("Manual M3 theme switch triggered")
			UIThemeManager.set_theme("material3")