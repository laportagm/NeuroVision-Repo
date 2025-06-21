extends Node

## Autoload wrapper for DebugConsole
## Ensures debug console is available in all scenes

var debug_console = null

func _ready() -> void:
	# Create debug console UI layer
	debug_console = CanvasLayer.new()
	debug_console.name = "DebugConsoleLayer"
	debug_console.layer = 100  # High layer to be on top
	add_child(debug_console)
	
	# Initialize console UI
	_setup_console_ui()
	
	print("[Debug] Debug console initialized - Press F1 to toggle")

func _setup_console_ui() -> void:
	# Create a simple debug console UI
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.visible = false
	debug_console.add_child(panel)
	
	# Store reference for toggling
	debug_console.set_meta("panel", panel)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug_console"):
		toggle_console()

func toggle_console() -> void:
	if debug_console and debug_console.has_meta("panel"):
		var panel = debug_console.get_meta("panel")
		panel.visible = not panel.visible
