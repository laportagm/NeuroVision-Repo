extends Node

## Simple test for educational theme system without autoload dependencies
## Tests basic functionality of the theme classes directly

func _ready():
	print("=== Simple Educational Theme Test ===")
	
	test_color_system_directly()
	test_theme_generation_directly()
	
	print("=== Simple Educational Theme Tests Completed ===")
	get_tree().quit()

func test_color_system_directly():
	print("\n--- Testing EducationalColorSystem Direct Access ---")
	
	# Load the color system resource directly
	var color_system_script = load("res://src/ui/themes/EducationalColorSystem.gd")
	
	# Test basic color retrieval
	var light_critical = color_system_script.get_educational_color("light", "critical_concept")
	var dark_critical = color_system_script.get_educational_color("dark", "critical_concept")
	
	print("Light critical concept color: ", light_critical)
	print("Dark critical concept color: ", dark_critical)
	
	assert_test(light_critical != Color.MAGENTA, "Light theme should return valid color")
	assert_test(dark_critical != Color.MAGENTA, "Dark theme should return valid color")
	assert_test(light_critical != dark_critical, "Light and dark colors should be different")
	
	# Test content type mapping
	var structure_color = color_system_script.get_content_type_color("light", "structure_name")
	var function_color = color_system_script.get_content_type_color("light", "function")
	
	print("Structure name color: ", structure_color)
	print("Function color: ", function_color)
	
	assert_test(structure_color != Color.MAGENTA, "Structure color should be valid")
	assert_test(function_color != Color.MAGENTA, "Function color should be valid")
	
	# Test contrast ratio calculations
	var white = Color.WHITE
	var black = Color.BLACK
	var contrast_ratio = color_system_script.calculate_contrast_ratio(black, white)
	
	print("Black on white contrast ratio: ", contrast_ratio)
	assert_test(contrast_ratio > 20.0, "Black on white should have very high contrast")
	assert_test(color_system_script.meets_wcag_aaa(black, white), "Black on white should meet WCAG AAA")
	
	# Test accessible text color selection
	var text_color_light = color_system_script.get_accessible_text_color(white, "light")
	var text_color_dark = color_system_script.get_accessible_text_color(black, "dark")
	
	print("Accessible text on white: ", text_color_light)
	print("Accessible text on black: ", text_color_dark)
	
	assert_test(text_color_light != white, "Text color should be different from background")
	assert_test(text_color_dark != black, "Text color should be different from background")
	
	print("✓ EducationalColorSystem direct access tests passed")

func test_theme_generation_directly():
	print("\n--- Testing EducationalThemeGenerator Direct Access ---")
	
	# Load the theme generator script directly
	var theme_generator_script = load("res://src/ui/themes/EducationalThemeGenerator.gd")
	
	# Create instance to access enums
	var generator_instance = theme_generator_script.new()
	
	# Test theme generation with enum access
	var LIGHT = generator_instance.ThemeVariant.LIGHT
	var DARK = generator_instance.ThemeVariant.DARK
	var HIGH_CONTRAST = generator_instance.ThemeVariant.HIGH_CONTRAST
	
	var BEGINNER = 0     # LearningLevel.BEGINNER  
	var INTERMEDIATE = 1 # LearningLevel.INTERMEDIATE
	var ADVANCED = 2     # LearningLevel.ADVANCED
	
	# Test light theme generation
	var light_theme = theme_generator_script.generate_educational_theme(LIGHT, INTERMEDIATE)
	
	assert_test(light_theme != null, "Light theme should generate successfully")
	assert_test(light_theme is Theme, "Should return Theme object")
	print("✓ Light theme generated successfully")
	
	# Test dark theme generation
	var dark_theme = theme_generator_script.generate_educational_theme(DARK, INTERMEDIATE)
	
	assert_test(dark_theme != null, "Dark theme should generate successfully")
	assert_test(dark_theme is Theme, "Should return Theme object")
	print("✓ Dark theme generated successfully")
	
	# Test high contrast theme generation
	var hc_theme = theme_generator_script.generate_educational_theme(HIGH_CONTRAST, INTERMEDIATE)
	
	assert_test(hc_theme != null, "High contrast theme should generate successfully")
	assert_test(hc_theme is Theme, "Should return Theme object")
	print("✓ High contrast theme generated successfully")
	
	# Test different learning levels
	var beginner_theme = theme_generator_script.generate_educational_theme(LIGHT, BEGINNER)
	var advanced_theme = theme_generator_script.generate_educational_theme(LIGHT, ADVANCED)
	
	assert_test(beginner_theme != null, "Beginner theme should generate successfully")
	assert_test(advanced_theme != null, "Advanced theme should generate successfully")
	assert_test(beginner_theme != advanced_theme, "Different learning level themes should be different objects")
	print("✓ Learning level theme variations generated successfully")
	
	# Test theme info metadata
	var theme_info = theme_generator_script.get_theme_info(LIGHT, INTERMEDIATE)
	
	assert_test(theme_info.has("variant"), "Theme info should include variant")
	assert_test(theme_info.has("learning_level"), "Theme info should include learning level")
	assert_test(theme_info.has("wcag_compliance"), "Theme info should include WCAG compliance")
	assert_test(theme_info.wcag_compliance == "AAA (7:1 contrast ratio)", "Should specify WCAG AAA compliance")
	print("✓ Theme info metadata working correctly")
	
	print("✓ EducationalThemeGenerator direct access tests passed")

func assert_test(condition: bool, message: String):
	if not condition:
		push_error("ASSERTION FAILED: " + message)
		get_tree().quit(1)
	else:
		print("  ✓ " + message)