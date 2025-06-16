## test_runner.gd
## Simple test runner for UI components
extends Node

func _ready() -> void:
	print("\n=== UI Component Test Runner ===\n")
	
	# Test BaseButton
	print("Testing BaseButton...")
	var base_button = load("res://src/ui_new/components/atoms/buttons/BaseButton.gd").new()
	base_button.name = "TestBaseButton"
	add_child(base_button)
	print("✓ BaseButton created successfully")
	
	# Test TextButton
	print("\nTesting TextButton...")
	var text_button = load("res://src/ui_new/components/atoms/buttons/TextButton.gd").new()
	text_button.name = "TestTextButton"
	text_button.text = "Test Button"
	add_child(text_button)
	print("✓ TextButton created successfully")
	print("  - Text: ", text_button.text)
	
	# Test BaseLabel
	print("\nTesting BaseLabel...")
	var base_label = load("res://src/ui_new/components/atoms/labels/BaseLabel.gd").new()
	base_label.name = "TestBaseLabel"
	base_label.text = "Test Label"
	add_child(base_label)
	print("✓ BaseLabel created successfully")
	print("  - Text: ", base_label.text)
	
	# Test ResponsiveLabel
	print("\nTesting ResponsiveLabel...")
	var responsive_label = load("res://src/ui_new/components/atoms/labels/ResponsiveLabel.gd").new()
	responsive_label.name = "TestResponsiveLabel"
	responsive_label.text = "Responsive Test"
	add_child(responsive_label)
	print("✓ ResponsiveLabel created successfully")
	print("  - Text: ", responsive_label.text)
	print("  - Responsive Mode: ", responsive_label.responsive_mode)
	
	# Test BaseInput
	print("\nTesting BaseInput...")
	var base_input = load("res://src/ui_new/components/atoms/inputs/BaseInput.gd").new()
	base_input.name = "TestBaseInput"
	add_child(base_input)
	print("✓ BaseInput created successfully")
	
	# Test TextInput
	print("\nTesting TextInput...")
	var text_input = load("res://src/ui_new/components/atoms/inputs/TextInput.gd").new()
	text_input.name = "TestTextInput"
	text_input.placeholder = "Enter text..."
	add_child(text_input)
	print("✓ TextInput created successfully")
	print("  - Placeholder: ", text_input.placeholder)
	
	# Test component hierarchy
	print("\n=== Component Hierarchy ===")
	print("BaseComponent → BaseButton → TextButton")
	print("BaseComponent → BaseLabel → ResponsiveLabel")
	print("BaseComponent → BaseInput → TextInput")
	
	# Test signals
	print("\n=== Testing Signals ===")
	text_button.pressed.connect(func(): print("Button pressed signal received"))
	text_input.text_changed.connect(func(text): print("Text changed: ", text))
	responsive_label.breakpoint_changed.connect(func(bp): print("Breakpoint changed: ", bp))
	
	print("\n✅ All components loaded successfully!")
	print("\n=== Test Complete ===\n")
	
	# Clean up
	await get_tree().create_timer(1.0).timeout
	queue_free()