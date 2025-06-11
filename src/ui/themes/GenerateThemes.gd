@tool
extends EditorScript

## Tool script to generate theme files
## Run this in the editor to create all theme resources

func _run() -> void:
	print("Generating NeuroVis themes...")
	
	# Generate Dark theme
	var dark_theme = ThemeGenerator.generate_theme("dark")
	ResourceSaver.save(dark_theme, "res://src/ui/themes/themes/DarkTheme.tres")
	print("✓ Generated Dark theme")
	
	# Generate High Contrast theme
	var high_contrast_theme = ThemeGenerator.generate_theme("high_contrast")
	ResourceSaver.save(high_contrast_theme, "res://src/ui/themes/themes/HighContrastTheme.tres")
	print("✓ Generated High Contrast theme")
	
	# Generate Colorblind theme
	var colorblind_theme = ThemeGenerator.generate_theme("colorblind")
	ResourceSaver.save(colorblind_theme, "res://src/ui/themes/themes/ColorblindTheme.tres")
	print("✓ Generated Colorblind theme")
	
	print("Theme generation complete!")