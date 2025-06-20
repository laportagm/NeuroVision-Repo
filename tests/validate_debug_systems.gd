#!/usr/bin/env -S godot -s
extends SceneTree

func _init():
	print("\n=== Validating Debug Systems ===\n")
	
	# Check DebugSystem
	if Engine.has_singleton("DebugSystem"):
		print("✓ DebugSystem autoload found")
	else:
		print("✗ DebugSystem autoload missing")
	
	# Check DebugConsoleAutoload  
	if Engine.has_singleton("DebugConsoleAutoload"):
		print("✓ DebugConsoleAutoload found")
	else:
		print("✗ DebugConsoleAutoload missing")
		
	# Check debug console input mapping
	if InputMap.has_action("toggle_debug_console"):
		print("✓ Debug console input mapping configured")
	else:
		print("✗ Debug console input mapping missing")
	
	print("\n=== Validation Complete ===\n")
	quit()