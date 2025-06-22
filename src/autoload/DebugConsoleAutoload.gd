extends Node

## Autoload wrapper for DebugConsole
## Ensures debug console is available in all scenes

var debug_console = null

func _ready() -> void:
	# Create debug console instance
	var DebugConsoleScript = preload("res://src/debug/DebugConsole.gd")
	debug_console = DebugConsoleScript.new()
	debug_console.name = "DebugConsoleLayer"
	add_child.call_deferred(debug_console)
	
	print("[Debug] Debug console initialized - Press ` to toggle")