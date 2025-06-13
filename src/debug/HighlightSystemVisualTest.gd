extends Node3D

## Visual test for highlight system
##
## This scene allows manual testing of the highlight system with visual feedback.

@onready var camera: Camera3D = $Camera3D
@onready var interaction_controller = $BrainInteractionController
@onready var highlight_integration = $HighlightSystemIntegration
@onready var test_structures = $TestStructures

var debug_label: Label

func _ready() -> void:
	print("==================================================")
	print("[VisualTest] Highlight System Visual Test Started")
	print("==================================================")
	
	# Initialize interaction controller
	interaction_controller.initialize(camera)
	
	# Create debug label
	_create_debug_ui()
	
	# Give time for systems to initialize
	await get_tree().create_timer(0.5).timeout
	
	print("[VisualTest] Ready for testing")
	print("  - Right-click to select")
	print("  - Hover to highlight")
	print("  - Press D for debug info")

func _create_debug_ui() -> void:
	"""Create debug information display"""
	debug_label = Label.new()
	debug_label.position = Vector2(10, 250)
	debug_label.size = Vector2(400, 200)
	debug_label.add_theme_color_override("font_color", Color.WHITE)
	debug_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	debug_label.add_theme_constant_override("shadow_offset_x", 2)
	debug_label.add_theme_constant_override("shadow_offset_y", 2)
	$UI.add_child(debug_label)

func _input(event: InputEvent) -> void:
	# Handle mouse input for interaction
	if event is InputEventMouseButton:
		interaction_controller.handle_mouse_click(event)
	elif event is InputEventMouseMotion:
		interaction_controller.handle_mouse_motion(event)
	
	# Handle keyboard shortcuts
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_C:
				print("[VisualTest] Clearing all selections")
				interaction_controller.clear_all_selections()
			
			KEY_D:
				_show_debug_info()
			
			KEY_1:
				# Test hover on first structure
				var hippocampus = test_structures.get_node("Hippocampus")
				interaction_controller.structure_highlighted.emit("Hippocampus", hippocampus)
				print("[VisualTest] Simulated hover on Hippocampus")
			
			KEY_2:
				# Test selection on second structure
				var amygdala = test_structures.get_node("Amygdala")
				interaction_controller.structure_selected.emit("Amygdala", amygdala)
				print("[VisualTest] Simulated selection on Amygdala")

func _show_debug_info() -> void:
	"""Display debug information"""
	var highlight_manager = get_node_or_null("/root/HighlightMaterialManager")
	if not highlight_manager:
		debug_label.text = "HighlightMaterialManager not found!"
		return
	
	var debug_text = "=== Highlight System Debug ===\n"
	debug_text += "Active highlights: %d\n" % highlight_manager.get_active_highlight_count()
	debug_text += "Material pool size: %d\n" % highlight_manager.get_pool_size()
	
	# Check each test structure
	debug_text += "\nStructure States:\n"
	for child in test_structures.get_children():
		if child is MeshInstance3D:
			var state = highlight_manager.get_current_state(child)
			var state_name = _get_state_name(state)
			debug_text += "  %s: %s (%d)\n" % [child.name, state_name, state]
			
			# Check if material is applied
			var mat = child.get_surface_override_material(0)
			if mat and mat is ShaderMaterial:
				debug_text += "    - Has shader material: %s\n" % (mat.shader != null)
	
	# Integration info
	if highlight_integration.has_method("get_debug_info"):
		var integration_info = highlight_integration.get_debug_info()
		debug_text += "\nIntegration Info:\n"
		for key in integration_info:
			debug_text += "  %s: %s\n" % [key, integration_info[key]]
	
	debug_label.text = debug_text
	print("\n" + debug_text)

func _get_state_name(state: int) -> String:
	"""Convert state enum to name"""
	var names = ["IDLE", "HOVERING", "SELECTED", "MULTI_SELECTED", "FOCUSED", "DISABLED"]
	if state >= 0 and state < names.size():
		return names[state]
	return "UNKNOWN"

func _process(_delta: float) -> void:
	# Update debug info continuously if visible
	if debug_label and debug_label.visible and debug_label.text != "":
		_show_debug_info()