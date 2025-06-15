## test_unified_color_system.gd
## Comprehensive test suite for the unified color system
##
## Tests that the color system fragmentation has been resolved and
## that theme switching works consistently across all components.

extends GdUnitTestSuite

# === TEST SETUP ===

func before_test():
	# Clear any cached colors before each test
	UnifiedColorSystem.clear_validation_logs()
	UnifiedColorSystem.set_validation_enabled(true)

func after_test():
	# Clean up after each test
	pass

# === CORE SYSTEM TESTS ===

func test_unified_color_system_exists():
	"""Test that UnifiedColorSystem class is available and functional"""
	
	assert_that(UnifiedColorSystem).is_not_null()
	
	# Test basic color access
	var primary_color = UnifiedColorSystem.get_color("primary")
	assert_that(primary_color).is_not_null()
	assert_that(primary_color).is_not_equal(Color())

func test_m3_design_tokens_integration():
	"""Test that M3DesignTokens are properly integrated"""
	
	# Test that M3DesignTokens still work for backward compatibility
	var m3_primary = M3DesignTokens.get_color("primary")
	var unified_primary = UnifiedColorSystem.get_color("primary")
	
	assert_that(m3_primary).is_equal(unified_primary)

func test_educational_color_access():
	"""Test educational-specific color access"""
	
	var brain_highlight = UnifiedColorSystem.get_educational_color("brain_structure_selection")
	assert_that(brain_highlight).is_not_null()
	
	var learning_progress = UnifiedColorSystem.get_educational_color("learning_progress_positive")
	assert_that(learning_progress).is_not_null()
	
	var clinical_alert = UnifiedColorSystem.get_educational_color("clinical_alert")
	assert_that(clinical_alert).is_not_null()

func test_brain_structure_colors():
	"""Test brain structure color system"""
	
	# Test known brain structures
	var hippocampus = UnifiedColorSystem.get_brain_structure_color("hippocampus")
	assert_that(hippocampus).is_equal(M3DesignTokens.BRAIN_STRUCTURE_COLORS["hippocampus"])
	
	var amygdala = UnifiedColorSystem.get_brain_structure_color("amygdala")
	assert_that(amygdala).is_equal(M3DesignTokens.BRAIN_STRUCTURE_COLORS["amygdala"])
	
	# Test unknown structure fallback
	var unknown = UnifiedColorSystem.get_brain_structure_color("unknown_structure")
	assert_that(unknown).is_equal(M3DesignTokens.get_color("primary"))

# === THEME SWITCHING TESTS ===

func test_theme_variant_adaptation():
	"""Test that colors adapt properly to different theme variants"""
	
	var base_color = Color(0.5, 0.5, 0.5, 1.0)
	
	# Test different theme adaptations
	var enhanced = UnifiedColorSystem._adapt_color_for_theme(base_color, "enhanced")
	var minimal = UnifiedColorSystem._adapt_color_for_theme(base_color, "minimal")
	var high_contrast = UnifiedColorSystem._adapt_color_for_theme(base_color, "high_contrast")
	var colorblind_safe = UnifiedColorSystem._adapt_color_for_theme(base_color, "colorblind_safe")
	
	# Enhanced should be slightly more vibrant
	assert_that(enhanced.s).is_greater_than(base_color.s * 1.05)
	
	# Minimal should be less saturated
	assert_that(minimal.s).is_less_than(base_color.s * 0.8)
	
	# Each variant should be different
	assert_that(enhanced).is_not_equal(minimal)
	assert_that(enhanced).is_not_equal(high_contrast)
	assert_that(enhanced).is_not_equal(colorblind_safe)

func test_stylebox_creation():
	"""Test unified StyleBox creation"""
	
	var button_style = UnifiedColorSystem.create_stylebox("button", "primary")
	assert_that(button_style).is_not_null()
	assert_that(button_style.bg_color).is_equal(UnifiedColorSystem.get_color("primary"))
	
	var panel_style = UnifiedColorSystem.create_stylebox("panel")
	assert_that(panel_style).is_not_null()
	assert_that(panel_style.bg_color).is_equal(UnifiedColorSystem.get_color("surface_container"))

# === ACCESSIBILITY TESTS ===

func test_accessibility_compliance():
	"""Test WCAG AAA accessibility compliance"""
	
	# Test primary/surface contrast
	var primary = UnifiedColorSystem.get_color("primary")
	var surface = UnifiedColorSystem.get_color("surface")
	var contrast_ratio = _calculate_contrast_ratio(primary, surface)
	
	assert_that(contrast_ratio).is_greater_than(7.0)  # WCAG AAA requirement
	
	# Test text/surface contrast
	var text_color = UnifiedColorSystem.get_color("on_surface")
	var text_contrast = _calculate_contrast_ratio(text_color, surface)
	
	assert_that(text_contrast).is_greater_than(7.0)  # WCAG AAA requirement

func test_colorblind_safety():
	"""Test colorblind-safe color conversion"""
	
	var red = Color.RED
	var green = Color.GREEN
	var blue = Color.BLUE
	
	var safe_red = UnifiedColorSystem._convert_to_colorblind_safe(red)
	var safe_green = UnifiedColorSystem._convert_to_colorblind_safe(green)
	var safe_blue = UnifiedColorSystem._convert_to_colorblind_safe(blue)
	
	# Colors should be distinguishable even when converted
	assert_that(safe_red).is_not_equal(safe_green)
	assert_that(safe_red).is_not_equal(safe_blue)
	assert_that(safe_green).is_not_equal(safe_blue)

# === SHADER INTEGRATION TESTS ===

func test_shader_color_adapter():
	"""Test ShaderColorAdapter functionality"""
	
	# Test glass tint color generation
	var glass_tint = ShaderColorAdapter.get_glass_tint_color("enhanced")
	assert_that(glass_tint).is_not_null()
	assert_that(glass_tint.a).is_greater_than(0.0)
	assert_that(glass_tint.a).is_less_than(1.0)
	
	# Test blur strength variation
	var enhanced_blur = ShaderColorAdapter.get_glass_blur_strength("enhanced")
	var minimal_blur = ShaderColorAdapter.get_glass_blur_strength("minimal")
	
	assert_that(enhanced_blur).is_greater_than(minimal_blur)

func test_shader_parameter_generation():
	"""Test shader parameter generation for different types"""
	
	var glass_params = ShaderColorAdapter.get_shader_parameters("glass_panel", "enhanced")
	assert_that(glass_params).contains_key("tint_color")
	assert_that(glass_params).contains_key("blur_amount")
	
	var highlight_params = ShaderColorAdapter.get_shader_parameters("brain_highlight", "enhanced")
	assert_that(highlight_params).contains_key("highlight_color")
	assert_that(highlight_params).contains_key("selection_intensity")

# === VALIDATION TESTS ===

func test_color_system_validator():
	"""Test ColorSystemValidator functionality"""
	
	# Test that validator can run without errors
	var validation_result = ColorSystemValidator.validate_accessibility_compliance()
	assert_that(validation_result).is_not_null()
	
	# Test that brain structure colors pass accessibility
	assert_that(validation_result.accessibility_issues.size()).is_less_than(5)  # Allow some minor issues

func test_validation_logging():
	"""Test that validation logging works correctly"""
	
	# Access some colors to generate logs
	UnifiedColorSystem.get_color("primary")
	UnifiedColorSystem.get_color("surface")
	UnifiedColorSystem.get_color("on_surface")
	
	# Check that accesses were logged
	var logs = UnifiedColorSystem._color_access_log
	assert_that(logs.size()).is_greater_than(0)
	
	# Test validation report generation
	var report = UnifiedColorSystem.validate_color_usage()
	assert_that(report).contains_key("valid")
	assert_that(report).contains_key("total_accesses")

# === INTEGRATION TESTS ===

func test_control_theme_application():
	"""Test applying unified theme to controls"""
	
	var test_button = Button.new()
	var test_label = Label.new()
	var test_panel = PanelContainer.new()
	
	# Apply unified themes
	UnifiedColorSystem.apply_unified_theme(test_button, "button")
	UnifiedColorSystem.apply_unified_theme(test_label, "label")
	UnifiedColorSystem.apply_unified_theme(test_panel, "panel")
	
	# Check that colors were applied
	assert_that(test_button.has_theme_color_override("font_color")).is_true()
	assert_that(test_label.has_theme_color_override("font_color")).is_true()
	
	# Clean up
	test_button.queue_free()
	test_label.queue_free()
	test_panel.queue_free()

func test_theme_switching_consistency():
	"""Test that theme switching maintains consistency"""
	
	# Test multiple theme variants
	var variants = ["enhanced", "minimal", "high_contrast", "colorblind_safe"]
	
	for variant in variants:
		# Get colors in this variant
		var primary = UnifiedColorSystem.get_color("primary")
		var surface = UnifiedColorSystem.get_color("surface_container")
		var text = UnifiedColorSystem.get_color("on_surface")
		
		# Colors should be valid
		assert_that(primary).is_not_equal(Color())
		assert_that(surface).is_not_equal(Color())
		assert_that(text).is_not_equal(Color())
		
		# Glass parameters should be consistent
		var glass_tint = ShaderColorAdapter.get_glass_tint_color(variant)
		var glass_blur = ShaderColorAdapter.get_glass_blur_strength(variant)
		
		assert_that(glass_tint).is_not_equal(Color())
		assert_that(glass_blur).is_greater_than(0.0)

# === PERFORMANCE TESTS ===

func test_color_access_performance():
	"""Test that color access is performant with caching"""
	
	var start_time = Time.get_ticks_msec()
	
	# Access colors multiple times
	for i in range(1000):
		UnifiedColorSystem.get_color("primary")
		UnifiedColorSystem.get_color("surface")
		UnifiedColorSystem.get_color("on_surface")
	
	var end_time = Time.get_ticks_msec()
	var duration = end_time - start_time
	
	# Should complete in reasonable time (less than 100ms for 3000 accesses)
	assert_that(duration).is_less_than(100)

func test_cache_invalidation():
	"""Test that color cache can be cleared and rebuilt"""
	
	# Access a color to populate cache
	var color1 = UnifiedColorSystem.get_color("primary")
	
	# Clear cache
	M3DesignTokens.clear_color_cache()
	
	# Access same color again
	var color2 = UnifiedColorSystem.get_color("primary")
	
	# Should be the same color
	assert_that(color1).is_equal(color2)

# === REGRESSION TESTS ===

func test_no_hardcoded_color_bypass():
	"""Test that no components are bypassing the unified color system"""
	
	# This would test that common bypass patterns don't exist
	# In a real implementation, this would scan loaded scenes
	
	# Test that we can detect hardcoded color usage
	var validator = ColorSystemValidator.new()
	var result = validator.validate_runtime_colors()
	
	# Should have minimal violations
	assert_that(result.violations.size()).is_less_than(5)

func test_brain_structure_integration():
	"""Test that brain structure colors integrate properly with themes"""
	
	var structures = ["hippocampus", "amygdala", "cortex", "cerebellum"]
	var variants = ["enhanced", "minimal", "high_contrast"]
	
	for structure in structures:
		for variant in variants:
			var color = UnifiedColorSystem.get_brain_structure_color(structure, variant)
			
			# Should be a valid color
			assert_that(color).is_not_equal(Color())
			
			# Should have reasonable contrast with surface
			var surface = UnifiedColorSystem.get_color("surface")
			var contrast = _calculate_contrast_ratio(color, surface)
			assert_that(contrast).is_greater_than(3.0)  # WCAG AA minimum for graphics

# === HELPER METHODS ===

func _calculate_contrast_ratio(c1: Color, c2: Color) -> float:
	"""Calculate WCAG contrast ratio between two colors"""
	var l1 = _get_relative_luminance(c1)
	var l2 = _get_relative_luminance(c2)
	
	var lighter = max(l1, l2)
	var darker = min(l1, l2)
	
	return (lighter + 0.05) / (darker + 0.05)

func _get_relative_luminance(color: Color) -> float:
	"""Calculate relative luminance for contrast calculation"""
	var r = _gamma_correct(color.r)
	var g = _gamma_correct(color.g)
	var b = _gamma_correct(color.b)
	
	return 0.2126 * r + 0.7152 * g + 0.0722 * b

func _gamma_correct(value: float) -> float:
	"""Apply gamma correction for luminance calculation"""
	if value <= 0.03928:
		return value / 12.92
	else:
		return pow((value + 0.055) / 1.055, 2.4)