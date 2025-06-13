extends Node

## Test script to verify enhanced theme styling is working

func _ready() -> void:
	print("=== Testing Enhanced Theme System ===")
	
	# Check if UIThemeManager exists
	if not UIThemeManager:
		print("ERROR: UIThemeManager not found as autoload!")
		return
	
	print("✓ UIThemeManager found")
	
	# Check if the method exists
	if not UIThemeManager.has_method("apply_enhanced_styling_immediately"):
		print("ERROR: apply_enhanced_styling_immediately method not found!")
		return
	
	print("✓ apply_enhanced_styling_immediately method exists")
	
	# Apply enhanced styling
	print("Applying enhanced styling...")
	UIThemeManager.apply_enhanced_styling_immediately()
	
	# Create test UI to verify styling
	_create_test_ui()
	
	print("=== Enhanced Theme Test Complete ===")

func _create_test_ui() -> void:
	"""Create test UI elements to verify styling"""
	
	# Create a container
	var container = VBoxContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	container.custom_minimum_size = Vector2(400, 300)
	add_child(container)
	
	# Create a panel to test panel styling
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(350, 100)
	container.add_child(panel)
	
	var panel_label = Label.new()
	panel_label.text = "Enhanced Panel with Shadow"
	panel.add_child(panel_label)
	
	# Add some space
	container.add_child(HSeparator.new())
	
	# Create buttons to test button styling
	var button1 = Button.new()
	button1.text = "Enhanced Button 1"
	container.add_child(button1)
	
	var button2 = Button.new()
	button2.text = "Enhanced Button 2"
	container.add_child(button2)
	
	# Check if ThemeEffectsManager is available
	var effects_manager = get_node_or_null("/root/ThemeEffectsManager")
	if effects_manager:
		print("✓ ThemeEffectsManager is available")
		# Try to apply glass morphism to the panel
		if effects_manager.has_method("apply_glass_morphism"):
			effects_manager.apply_glass_morphism(panel, 0.5)
			print("✓ Glass morphism applied to test panel")
	else:
		print("! ThemeEffectsManager not found - glass effects won't be applied")
	
	# Verify styling was applied
	await get_tree().process_frame
	
	# Check panel styling
	var panel_style = panel.get_theme_stylebox("panel")
	if panel_style and panel_style is StyleBoxFlat:
		print("✓ Panel has StyleBoxFlat applied")
		print("  - Background color: ", panel_style.bg_color)
		print("  - Corner radius: ", panel_style.corner_radius_top_left)
		print("  - Shadow size: ", panel_style.shadow_size)
	else:
		print("✗ Panel styling not applied correctly")
	
	# Check button styling
	var button_style = button1.get_theme_stylebox("normal")
	if button_style and button_style is StyleBoxFlat:
		print("✓ Button has StyleBoxFlat applied")
		print("  - Background color: ", button_style.bg_color)
		print("  - Corner radius: ", button_style.corner_radius_top_left)
		print("  - Shadow size: ", button_style.shadow_size)
	else:
		print("✗ Button styling not applied correctly")