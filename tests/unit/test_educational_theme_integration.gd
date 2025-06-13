extends GutTest

## Unit tests for educational theme integration system
## Tests the integration between UIAdaptationManager and EducationalThemeGenerator

class_name TestEducationalThemeIntegration

# === TEST SETUP ===

var ui_manager: Node
var theme_generator: EducationalThemeGenerator

func before_each():
	"""Setup test environment"""
	# Create UIAdaptationManager instance for testing
	ui_manager = UIAdaptationManager.new()
	ui_manager.name = "TestUIAdaptationManager"
	add_child(ui_manager)
	
	# Create EducationalThemeGenerator instance
	theme_generator = EducationalThemeGenerator.new()

func after_each():
	"""Clean up test environment"""
	if ui_manager:
		ui_manager.queue_free()
	theme_generator = null

# === EDUCATIONAL COLOR SYSTEM TESTS ===

func test_educational_color_system_wcag_compliance():
	"""Test that educational color system meets WCAG AAA standards"""
	var validation_results = EducationalColorSystem.validate_color_accessibility()
	
	# Should have AAA compliant colors for each theme
	assert_gt(validation_results.light_theme_aaa, 0, "Light theme should have AAA compliant colors")
	assert_gt(validation_results.dark_theme_aaa, 0, "Dark theme should have AAA compliant colors")
	
	# Should have minimal or no failed combinations
	var failed_count = validation_results.failed_combinations.size()
	assert_le(failed_count, 2, "Should have minimal failed color combinations")

func test_educational_color_retrieval():
	"""Test educational color retrieval for different content types"""
	# Test critical concept colors
	var critical_light = EducationalColorSystem.get_content_type_color("light", "structure_name")
	var critical_dark = EducationalColorSystem.get_content_type_color("dark", "structure_name")
	
	assert_ne(critical_light, Color.MAGENTA, "Should return valid color for light theme critical content")
	assert_ne(critical_dark, Color.MAGENTA, "Should return valid color for dark theme critical content")
	assert_ne(critical_light, critical_dark, "Light and dark critical colors should be different")
	
	# Test function category colors
	var function_light = EducationalColorSystem.get_content_type_color("light", "function")
	var function_dark = EducationalColorSystem.get_content_type_color("dark", "function")
	
	assert_ne(function_light, Color.MAGENTA, "Should return valid color for light theme function content")
	assert_ne(function_dark, Color.MAGENTA, "Should return valid color for dark theme function content")

func test_learning_level_color_configuration():
	"""Test learning level specific color configurations"""
	var beginner_config = EducationalColorSystem.get_learning_level_style(UIAdaptationManager.LearningLevel.BEGINNER)
	var intermediate_config = EducationalColorSystem.get_learning_level_style(UIAdaptationManager.LearningLevel.INTERMEDIATE)
	var advanced_config = EducationalColorSystem.get_learning_level_style(UIAdaptationManager.LearningLevel.ADVANCED)
	
	# Each level should have different accent colors
	assert_ne(beginner_config.primary_accent, intermediate_config.primary_accent, "Beginner and intermediate should have different accent colors")
	assert_ne(intermediate_config.primary_accent, advanced_config.primary_accent, "Intermediate and advanced should have different accent colors")
	
	# Visual complexity should increase with level
	assert_eq(beginner_config.visual_complexity, "minimal", "Beginner should have minimal visual complexity")
	assert_eq(intermediate_config.visual_complexity, "standard", "Intermediate should have standard visual complexity")
	assert_eq(advanced_config.visual_complexity, "detailed", "Advanced should have detailed visual complexity")

# === THEME GENERATOR TESTS ===

func test_educational_theme_generation():
	"""Test educational theme generation for different variants"""
	# Test light theme generation
	var light_theme = EducationalThemeGenerator.generate_educational_theme(
		EducationalThemeGenerator.ThemeVariant.LIGHT, 
		UIAdaptationManager.LearningLevel.INTERMEDIATE
	)
	
	assert_not_null(light_theme, "Should generate light educational theme")
	assert_true(light_theme is Theme, "Should return Theme object")
	
	# Test dark theme generation
	var dark_theme = EducationalThemeGenerator.generate_educational_theme(
		EducationalThemeGenerator.ThemeVariant.DARK,
		UIAdaptationManager.LearningLevel.INTERMEDIATE
	)
	
	assert_not_null(dark_theme, "Should generate dark educational theme")
	assert_true(dark_theme is Theme, "Should return Theme object")
	
	# Test high contrast theme generation
	var high_contrast_theme = EducationalThemeGenerator.generate_educational_theme(
		EducationalThemeGenerator.ThemeVariant.HIGH_CONTRAST,
		UIAdaptationManager.LearningLevel.INTERMEDIATE
	)
	
	assert_not_null(high_contrast_theme, "Should generate high contrast educational theme")
	assert_true(high_contrast_theme is Theme, "Should return Theme object")

func test_component_category_theme_generation():
	"""Test theme generation for specific educational component categories"""
	# Test structure info optimization
	var structure_theme = EducationalThemeGenerator.generate_component_theme(
		EducationalThemeGenerator.ComponentCategory.STRUCTURE_INFO,
		EducationalThemeGenerator.ThemeVariant.LIGHT,
		UIAdaptationManager.LearningLevel.INTERMEDIATE
	)
	
	assert_not_null(structure_theme, "Should generate structure info theme")
	
	# Test clinical content optimization
	var clinical_theme = EducationalThemeGenerator.generate_component_theme(
		EducationalThemeGenerator.ComponentCategory.CLINICAL_CONTENT,
		EducationalThemeGenerator.ThemeVariant.LIGHT,
		UIAdaptationManager.LearningLevel.ADVANCED
	)
	
	assert_not_null(clinical_theme, "Should generate clinical content theme")

func test_learning_level_theme_adaptations():
	"""Test that themes adapt properly to different learning levels"""
	var beginner_theme = EducationalThemeGenerator.generate_educational_theme(
		EducationalThemeGenerator.ThemeVariant.LIGHT,
		UIAdaptationManager.LearningLevel.BEGINNER
	)
	
	var advanced_theme = EducationalThemeGenerator.generate_educational_theme(
		EducationalThemeGenerator.ThemeVariant.LIGHT,
		UIAdaptationManager.LearningLevel.ADVANCED
	)
	
	assert_not_null(beginner_theme, "Should generate beginner theme")
	assert_not_null(advanced_theme, "Should generate advanced theme")
	
	# Themes should be different objects
	assert_ne(beginner_theme, advanced_theme, "Beginner and advanced themes should be different")

# === UI ADAPTATION MANAGER INTEGRATION TESTS ===

func test_ui_adaptation_manager_theme_variant_setting():
	"""Test UIAdaptationManager theme variant management"""
	# Test initial theme variant
	assert_eq(ui_manager.get_theme_variant(), UIAdaptationManager.ThemeVariant.AUTO, "Should start with AUTO theme variant")
	
	# Test setting theme variant
	ui_manager.set_theme_variant(UIAdaptationManager.ThemeVariant.DARK)
	assert_eq(ui_manager.get_theme_variant(), UIAdaptationManager.ThemeVariant.DARK, "Should update to DARK theme variant")
	
	# Test setting same variant (should not emit duplicate signals)
	var signal_count = 0
	ui_manager.educational_theme_changed.connect(func(_theme, _variant): signal_count += 1)
	ui_manager.set_theme_variant(UIAdaptationManager.ThemeVariant.DARK)
	assert_eq(signal_count, 0, "Should not emit signal when setting same variant")

func test_ui_adaptation_manager_learning_level_theme_integration():
	"""Test that changing learning level updates educational theme"""
	var theme_change_count = 0
	var last_theme = null
	
	ui_manager.educational_theme_changed.connect(func(theme, _variant): 
		theme_change_count += 1
		last_theme = theme
	)
	
	# Change learning level should trigger theme update
	ui_manager.set_learning_level(UIAdaptationManager.LearningLevel.BEGINNER)
	assert_eq(theme_change_count, 1, "Should emit theme changed signal when learning level changes")
	assert_not_null(last_theme, "Should provide theme in signal")

func test_theme_variant_auto_resolution():
	"""Test automatic theme variant resolution based on accessibility"""
	# Test AUTO variant resolution with accessibility disabled
	ui_manager.set_theme_variant(UIAdaptationManager.ThemeVariant.AUTO)
	var resolved = ui_manager._resolve_theme_variant()
	
	# Should resolve to a specific variant (not AUTO)
	assert_ne(resolved, UIAdaptationManager.ThemeVariant.AUTO, "AUTO should resolve to specific variant")
	assert_true(resolved in [UIAdaptationManager.ThemeVariant.LIGHT, UIAdaptationManager.ThemeVariant.DARK, UIAdaptationManager.ThemeVariant.HIGH_CONTRAST], 
		"Should resolve to valid theme variant")

func test_adaptation_status_includes_theme_info():
	"""Test that adaptation status includes theme information"""
	var status = ui_manager.get_adaptation_status()
	
	assert_true(status.has("theme_variant"), "Status should include theme variant")
	assert_true(status.has("has_educational_theme"), "Status should include educational theme status")
	assert_eq(status.theme_variant, ui_manager.get_theme_variant(), "Status should show current theme variant")

# === THEME DISPLAY NAME TESTS ===

func test_theme_variant_display_names():
	"""Test theme variant display name functions"""
	assert_eq(ui_manager.get_theme_variant_display_name(UIAdaptationManager.ThemeVariant.AUTO), "Auto", "Should return correct AUTO display name")
	assert_eq(ui_manager.get_theme_variant_display_name(UIAdaptationManager.ThemeVariant.LIGHT), "Light", "Should return correct LIGHT display name")
	assert_eq(ui_manager.get_theme_variant_display_name(UIAdaptationManager.ThemeVariant.DARK), "Dark", "Should return correct DARK display name")
	assert_eq(ui_manager.get_theme_variant_display_name(UIAdaptationManager.ThemeVariant.HIGH_CONTRAST), "High Contrast", "Should return correct HIGH_CONTRAST display name")

func test_theme_variant_descriptions():
	"""Test theme variant description functions"""
	var auto_desc = ui_manager.get_theme_variant_description(UIAdaptationManager.ThemeVariant.AUTO)
	var light_desc = ui_manager.get_theme_variant_description(UIAdaptationManager.ThemeVariant.LIGHT)
	var dark_desc = ui_manager.get_theme_variant_description(UIAdaptationManager.ThemeVariant.DARK)
	var hc_desc = ui_manager.get_theme_variant_description(UIAdaptationManager.ThemeVariant.HIGH_CONTRAST)
	
	assert_gt(auto_desc.length(), 10, "AUTO description should be meaningful")
	assert_gt(light_desc.length(), 10, "LIGHT description should be meaningful")
	assert_gt(dark_desc.length(), 10, "DARK description should be meaningful")
	assert_gt(hc_desc.length(), 10, "HIGH_CONTRAST description should be meaningful")
	
	# Each description should be unique
	assert_ne(auto_desc, light_desc, "AUTO and LIGHT descriptions should be different")
	assert_ne(light_desc, dark_desc, "LIGHT and DARK descriptions should be different")
	assert_ne(dark_desc, hc_desc, "DARK and HIGH_CONTRAST descriptions should be different")

# === ACCESSIBILITY INTEGRATION TESTS ===

func test_accessibility_triggers_theme_update():
	"""Test that accessibility changes trigger appropriate theme updates"""
	var theme_change_count = 0
	ui_manager.educational_theme_changed.connect(func(_theme, _variant): theme_change_count += 1)
	
	# Set to AUTO mode
	ui_manager.set_theme_variant(UIAdaptationManager.ThemeVariant.AUTO)
	
	# Simulate accessibility mode enabling
	ui_manager._on_accessibility_changed(true)
	assert_eq(theme_change_count, 1, "Should update theme when accessibility is enabled")

# === UTILITY TESTS ===

func test_theme_info_metadata():
	"""Test theme information and metadata functions"""
	var theme_info = EducationalThemeGenerator.get_theme_info(
		EducationalThemeGenerator.ThemeVariant.LIGHT,
		UIAdaptationManager.LearningLevel.INTERMEDIATE
	)
	
	assert_true(theme_info.has("variant"), "Theme info should include variant")
	assert_true(theme_info.has("learning_level"), "Theme info should include learning level")
	assert_true(theme_info.has("wcag_compliance"), "Theme info should include WCAG compliance")
	assert_true(theme_info.has("educational_categories"), "Theme info should include educational categories")
	assert_eq(theme_info.wcag_compliance, "AAA (7:1 contrast ratio)", "Should specify WCAG AAA compliance")

func test_color_scheme_information():
	"""Test educational color scheme information"""
	var color_info = EducationalColorSystem.get_color_scheme_info()
	
	assert_true(color_info.has("total_light_colors"), "Should include light color count")
	assert_true(color_info.has("total_dark_colors"), "Should include dark color count")
	assert_true(color_info.has("educational_categories"), "Should include educational categories")
	assert_eq(color_info.wcag_compliance, "AAA (7:1 contrast ratio)", "Should specify WCAG AAA compliance")
	
	# Should have reasonable number of colors
	assert_gt(color_info.total_light_colors, 10, "Should have substantial number of light colors")
	assert_gt(color_info.total_dark_colors, 10, "Should have substantial number of dark colors")

# === CONTRAST RATIO TESTS ===

func test_wcag_contrast_ratio_calculations():
	"""Test WCAG contrast ratio calculation functions"""
	# Test high contrast combinations
	var white = Color.WHITE
	var black = Color.BLACK
	var contrast_ratio = EducationalColorSystem.calculate_contrast_ratio(black, white)
	
	assert_gt(contrast_ratio, 20.0, "Black on white should have very high contrast ratio")
	assert_true(EducationalColorSystem.meets_wcag_aaa(black, white), "Black on white should meet WCAG AAA")
	assert_true(EducationalColorSystem.meets_wcag_aa(black, white), "Black on white should meet WCAG AA")
	
	# Test low contrast combinations
	var light_gray = Color(0.8, 0.8, 0.8)
	var white_gray = Color(0.9, 0.9, 0.9)
	var low_contrast = EducationalColorSystem.calculate_contrast_ratio(light_gray, white_gray)
	
	assert_lt(low_contrast, 3.0, "Similar grays should have low contrast ratio")
	assert_false(EducationalColorSystem.meets_wcag_aaa(light_gray, white_gray), "Similar grays should not meet WCAG AAA")

func test_accessible_text_color_selection():
	"""Test automatic accessible text color selection"""
	# Test light background
	var light_bg = Color.WHITE
	var text_color_light = EducationalColorSystem.get_accessible_text_color(light_bg, "light")
	var contrast_light = EducationalColorSystem.calculate_contrast_ratio(text_color_light, light_bg)
	
	assert_gt(contrast_light, 7.0, "Text on light background should meet WCAG AAA")
	
	# Test dark background
	var dark_bg = Color.BLACK
	var text_color_dark = EducationalColorSystem.get_accessible_text_color(dark_bg, "dark")
	var contrast_dark = EducationalColorSystem.calculate_contrast_ratio(text_color_dark, dark_bg)
	
	assert_gt(contrast_dark, 7.0, "Text on dark background should meet WCAG AAA")

# === PERFORMANCE TESTS ===

func test_theme_generation_performance():
	"""Test that theme generation completes in reasonable time"""
	var start_time = Time.get_ticks_msec()
	
	# Generate multiple themes
	for i in range(3):
		var theme = EducationalThemeGenerator.generate_educational_theme(
			EducationalThemeGenerator.ThemeVariant.LIGHT,
			UIAdaptationManager.LearningLevel.INTERMEDIATE
		)
		assert_not_null(theme, "Should generate theme " + str(i))
	
	var end_time = Time.get_ticks_msec()
	var duration = end_time - start_time
	
	assert_lt(duration, 1000, "Theme generation should complete within 1 second")

func test_color_system_lookup_performance():
	"""Test that color system lookups are efficient"""
	var start_time = Time.get_ticks_msec()
	
	# Perform many color lookups
	for i in range(100):
		var color = EducationalColorSystem.get_educational_color("light", "critical_concept")
		assert_not_null(color, "Should return color for lookup " + str(i))
	
	var end_time = Time.get_ticks_msec()
	var duration = end_time - start_time
	
	assert_lt(duration, 100, "Color lookups should be very fast")