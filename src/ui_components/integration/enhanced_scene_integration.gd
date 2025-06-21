extends Node

## Integration helper for using new UI components in EnhancedExplorationScene
## This can be added as a child node or used as a reference

class_name EnhancedSceneUIIntegration

# The new info panel instance
var simple_info_panel: SimpleInfoPanel

# Reference to the UI layer where panels should be added
var ui_layer: Control

func setup_new_ui_components(parent_ui_layer: Control) -> void:
	ui_layer = parent_ui_layer
	
	# Create the new simplified info panel
	simple_info_panel = SimpleInfoPanel.new()
	simple_info_panel.name = "SimpleInfoPanel"
	simple_info_panel.auto_hide = true
	simple_info_panel.auto_hide_delay = 30.0
	ui_layer.add_child(simple_info_panel)
	
	print("[UI Integration] New info panel created and added to scene")

func show_structure_info(structure_data: Dictionary) -> void:
	if simple_info_panel:
		simple_info_panel.display_structure_info(structure_data)
	else:
		push_error("[UI Integration] Info panel not initialized")

func hide_all_panels() -> void:
	if simple_info_panel and simple_info_panel._is_visible:
		simple_info_panel.hide_panel()

func get_info_panel() -> SimpleInfoPanel:
	return simple_info_panel