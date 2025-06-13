extends Node

## Quick test for educational theme integration
## Simple validation of core theme functionality

func _ready():
	print("=== Educational Theme Integration Quick Test ===")
	
	test_educational_color_system()
	test_theme_generation()
	test_ui_adaptation_integration()
	
	print("=== All Educational Theme Tests Completed ===")
	get_tree().quit()

func test_educational_color_system():
	print("\n--- Testing Educational Color System ---")
	
	# Test color retrieval
	var light_critical = EducationalColorSystem.get_educational_color("light", "critical_concept")
	var dark_critical = EducationalColorSystem.get_educational_color("dark", "critical_concept")
	
	print("Light critical concept color: ", light_critical)
	print("Dark critical concept color: ", dark_critical)
	
	assert_test(light_critical != Color.MAGENTA, "Light theme should return valid color")
	assert_test(dark_critical != Color.MAGENTA, "Dark theme should return valid color")
	assert_test(light_critical != dark_critical, "Light and dark colors should be different")
	
	# Test content type mapping
	var structure_color = EducationalColorSystem.get_content_type_color("light", "structure_name")
	var function_color = EducationalColorSystem.get_content_type_color("light", "function")
	
	print("Structure name color: ", structure_color)
	print("Function color: ", function_color)
	
	assert_test(structure_color != Color.MAGENTA, "Structure color should be valid")
	assert_test(function_color != Color.MAGENTA, "Function color should be valid")
	
	# Test learning level configurations
	var beginner_config = EducationalColorSystem.get_learning_level_style(UIAdaptationManager.LearningLevel.BEGINNER)
	var advanced_config = EducationalColorSystem.get_learning_level_style(UIAdaptationManager.LearningLevel.ADVANCED)
	
	print("Beginner accent: ", beginner_config.primary_accent)
	print("Advanced accent: ", advanced_config.primary_accent)
	print("Beginner complexity: ", beginner_config.visual_complexity)
	print("Advanced complexity: ", advanced_config.visual_complexity)
	
	assert_test(beginner_config.primary_accent != advanced_config.primary_accent, "Learning levels should have different accents")
	assert_test(beginner_config.visual_complexity == "minimal", "Beginner should be minimal complexity")
	assert_test(advanced_config.visual_complexity == "detailed", "Advanced should be detailed complexity")
	
	print("✓ Educational Color System tests passed")

func test_theme_generation():
	print("\n--- Testing Theme Generation ---")
	
	# Test basic theme generation
	var light_theme = EducationalThemeGenerator.generate_educational_theme(
		EducationalThemeGenerator.ThemeVariant.LIGHT, 
		UIAdaptationManager.LearningLevel.INTERMEDIATE
	)
	
	assert_test(light_theme != null, "Light theme should generate successfully")
	assert_test(light_theme is Theme, "Should return Theme object")
	print("✓ Light theme generated successfully")
	
	# Test dark theme generation
	var dark_theme = EducationalThemeGenerator.generate_educational_theme(
		EducationalThemeGenerator.ThemeVariant.DARK,
		UIAdaptationManager.LearningLevel.INTERMEDIATE
	)
	
	assert_test(dark_theme != null, "Dark theme should generate successfully")
	assert_test(dark_theme is Theme, "Should return Theme object")
	print("✓ Dark theme generated successfully")
	
	# Test high contrast theme generation
	var hc_theme = EducationalThemeGenerator.generate_educational_theme(
		EducationalThemeGenerator.ThemeVariant.HIGH_CONTRAST,
		UIAdaptationManager.LearningLevel.INTERMEDIATE
	)
	
	assert_test(hc_theme != null, "High contrast theme should generate successfully")
	assert_test(hc_theme is Theme, "Should return Theme object")
	print("✓ High contrast theme generated successfully")
	
	# Test different learning levels
	var beginner_theme = EducationalThemeGenerator.generate_educational_theme(
		EducationalThemeGenerator.ThemeVariant.LIGHT,
		UIAdaptationManager.LearningLevel.BEGINNER
	)
	
	var advanced_theme = EducationalThemeGenerator.generate_educational_theme(
		EducationalThemeGenerator.ThemeVariant.LIGHT,
		UIAdaptationManager.LearningLevel.ADVANCED
	)
	
	assert_test(beginner_theme != null, "Beginner theme should generate successfully")
	assert_test(advanced_theme != null, "Advanced theme should generate successfully")
	assert_test(beginner_theme != advanced_theme, "Different learning level themes should be different objects")
	print("✓ Learning level theme variations generated successfully")
	
	print("✓ Theme Generation tests passed")

func test_ui_adaptation_integration():
	print("\n--- Testing UI Adaptation Integration ---")
	
	# Test theme variant enums exist
	assert_test(UIAdaptationManager.ThemeVariant.AUTO == 0, "AUTO variant should exist")
	assert_test(UIAdaptationManager.ThemeVariant.LIGHT == 1, "LIGHT variant should exist")
	assert_test(UIAdaptationManager.ThemeVariant.DARK == 2, "DARK variant should exist")
	assert_test(UIAdaptationManager.ThemeVariant.HIGH_CONTRAST == 3, "HIGH_CONTRAST variant should exist")
	print("✓ Theme variant enums defined correctly")
	
	# Test display name functions
	var auto_name = UIAdaptationManager.get_theme_variant_display_name(UIAdaptationManager.ThemeVariant.AUTO)
	var light_name = UIAdaptationManager.get_theme_variant_display_name(UIAdaptationManager.ThemeVariant.LIGHT)
	var dark_name = UIAdaptationManager.get_theme_variant_display_name(UIAdaptationManager.ThemeVariant.DARK)
	var hc_name = UIAdaptationManager.get_theme_variant_display_name(UIAdaptationManager.ThemeVariant.HIGH_CONTRAST)
	
	print("Theme variant names: ", auto_name, ", ", light_name, ", ", dark_name, ", ", hc_name)
	
	assert_test(auto_name == "Auto", "AUTO should display as 'Auto'")
	assert_test(light_name == "Light", "LIGHT should display as 'Light'")
	assert_test(dark_name == "Dark", "DARK should display as 'Dark'")
	assert_test(hc_name == "High Contrast", "HIGH_CONTRAST should display as 'High Contrast'")
	print("✓ Theme variant display names correct")
	
	# Test description functions
	var auto_desc = UIAdaptationManager.get_theme_variant_description(UIAdaptationManager.ThemeVariant.AUTO)
	var light_desc = UIAdaptationManager.get_theme_variant_description(UIAdaptationManager.ThemeVariant.LIGHT)
	
	assert_test(auto_desc.length() > 10, "AUTO description should be meaningful")
	assert_test(light_desc.length() > 10, "LIGHT description should be meaningful")
	assert_test(auto_desc != light_desc, "Descriptions should be different")
	print("✓ Theme variant descriptions provided")
	
	print("✓ UI Adaptation Integration tests passed")

func assert_test(condition: bool, message: String):
	if not condition:
		push_error("ASSERTION FAILED: " + message)
		get_tree().quit(1)
	else:
		print("  ✓ " + message)