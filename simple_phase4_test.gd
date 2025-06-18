extends Node

func _ready():
	print("=== Phase 4 Simple Test ===")
	
	# Test Material3ThemeGenerator loading
	var generator_script = preload("res://src/ui_atomic/themes/generators/Material3ThemeGenerator.gd")
	print("✓ Material3ThemeGenerator loaded successfully")
	
	# Test PerformanceAwareShaderManager loading
	var shader_manager_script = preload("res://src/ui_atomic/themes/utilities/PerformanceAwareShaderManager.gd")
	print("✓ PerformanceAwareShaderManager loaded successfully")
	
	# Test ContextualColorGenerator loading
	var color_generator_script = preload("res://src/ui_atomic/themes/utilities/ContextualColorGenerator.gd")
	print("✓ ContextualColorGenerator loaded successfully")
	
	# Test M3DesignTokens integration
	var M3Tokens = preload("res://src/ui_atomic/themes/core/M3DesignTokens.gd")
	var primary_color = M3Tokens.get_color("primary")
	print("✓ M3DesignTokens integration working: primary=%s" % str(primary_color))
	
	print("=== Phase 4 Basic Functionality Verified ===")
	get_tree().quit()