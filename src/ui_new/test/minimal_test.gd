extends Node

func _ready() -> void:
	print("=== Minimal UI Component Test ===")
	
	# Test if BaseComponent exists
	var base_comp_script = load("res://src/ui_new/core/base/BaseComponent.gd")
	if base_comp_script:
		print("✓ BaseComponent loaded")
	else:
		print("✗ BaseComponent not found")
	
	# Test if button components load
	var base_button_script = load("res://src/ui_new/components/atoms/buttons/BaseButton.gd")
	if base_button_script:
		print("✓ BaseButton (NVBaseButton) loaded")
	else:
		print("✗ BaseButton not found")
	
	# Try to instantiate a basic control
	var control = Control.new()
	control.name = "TestControl"
	add_child(control)
	print("✓ Basic Control created")
	
	print("=== Test Complete ===")
	
	get_tree().quit()