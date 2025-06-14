## Test script for NeuroVision theme generation
extends Node

func _ready() -> void:
	print("=== Testing NeuroVision Theme Generation ===")
	
	# Load the theme generator
	var generator_class = load("res://src/ui/themes/GenerateThemeResources.gd")
	if not generator_class:
		print("❌ Failed to load theme generator")
		return
	
	# Generate all themes
	var success = generator_class.generate_all_themes()
	
	if success:
		print("✅ All NeuroVision themes generated successfully!")
		print("📁 Themes saved to: res://src/ui/themes/themes/")
		
		# Test theme loading
		_test_theme_loading()
	else:
		print("❌ Theme generation failed")

func _test_theme_loading() -> void:
	print("\n=== Testing Theme Loading ===")
	
	var theme_paths = [
		"res://src/ui/themes/themes/DarkTheme.tres",
		"res://src/ui/themes/themes/HighContrastTheme.tres", 
		"res://src/ui/themes/themes/ColorblindTheme.tres"
	]
	
	for theme_path in theme_paths:
		var theme = load(theme_path) as Theme
		if theme:
			var theme_name = theme.get_meta("theme_name", "Unknown")
			print("✅ Loaded: %s" % theme_name)
			
			# Test a few key properties
			if theme.has_color("font_color", "Button"):
				print("  - Button font color: %s" % theme.get_color("font_color", "Button"))
			if theme.has_stylebox("normal", "Button"):
				print("  - Button style: Available")
		else:
			print("❌ Failed to load: %s" % theme_path)
	
	print("\n🎨 NeuroVision theme system ready!")
	
	# Clean up - remove this test node
	queue_free()