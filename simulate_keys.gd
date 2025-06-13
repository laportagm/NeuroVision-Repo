extends Node

## Simulate key presses for testing Material 3
## Add this script to the scene

func _ready() -> void:
	print("\n[KeyTest] Simulating key presses in 2 seconds...")
	await get_tree().create_timer(2.0).timeout
	
	# Simulate F11 to show theme info
	print("[KeyTest] Simulating F11...")
	var event = InputEventKey.new()
	event.keycode = KEY_F11
	event.pressed = true
	Input.parse_input_event(event)
	
	await get_tree().create_timer(1.0).timeout
	
	# Simulate F10 to cycle themes
	print("[KeyTest] Simulating F10...")
	event = InputEventKey.new()
	event.keycode = KEY_F10
	event.pressed = true
	Input.parse_input_event(event)
	
	print("[KeyTest] Done!")