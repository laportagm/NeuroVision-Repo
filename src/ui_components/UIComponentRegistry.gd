class_name UIComponentRegistry
extends Node

## Central registry for all UI components - makes them easily discoverable by Claude Code

# Component paths
const COMPONENTS = {
	# Base components
	"BasePanel": "res://src/ui_components/base/BasePanel.gd",
	"BaseButton": "res://src/ui_components/base/BaseButton.gd",
	"BaseCard": "res://src/ui_components/base/BaseCard.gd",
	"BaseModal": "res://src/ui_components/base/BaseModal.gd",
	
	# Composite components
	"InfoPanel": "res://src/ui_components/composite/InfoPanel/InfoPanel.gd",
	"QuizPanel": "res://src/ui_components/composite/QuizPanel/QuizPanel.gd",
	"SettingsPanel": "res://src/ui_components/composite/SettingsPanel/SettingsPanel.gd",
	
	# Atoms
	"IconButton": "res://src/ui_components/atoms/IconButton.gd",
	"ThemedLabel": "res://src/ui_components/atoms/ThemedLabel.gd",
	"GlassCard": "res://src/ui_components/atoms/GlassCard.gd",
	
	# Molecules
	"SearchBar": "res://src/ui_components/molecules/SearchBar.gd",
	"TabBar": "res://src/ui_components/molecules/TabBar.gd",
	"NavigationItem": "res://src/ui_components/molecules/NavigationItem.gd",
}

# Scene templates
const TEMPLATES = {
	"info_panel": "res://src/ui_components/templates/info_panel_template.tscn",
	"quiz_panel": "res://src/ui_components/templates/quiz_panel_template.tscn",
	"settings_panel": "res://src/ui_components/templates/settings_panel_template.tscn",
}

# Cached components
var _component_cache: Dictionary = {}

## Create a UI component by name
func create_component(component_name: String, parent: Node = null) -> Control:
	if not COMPONENTS.has(component_name):
		push_error("UIComponentRegistry: Unknown component '%s'" % component_name)
		return null
	
	# Check cache first
	var component_path = COMPONENTS[component_name]
	if not _component_cache.has(component_path):
		_component_cache[component_path] = load(component_path)
	
	var component_script = _component_cache[component_path]
	if not component_script:
		push_error("UIComponentRegistry: Failed to load component '%s'" % component_name)
		return null
	
	var instance = Control.new()
	instance.set_script(component_script)
	
	if parent:
		parent.add_child(instance)
	
	return instance

## Create a component from a template scene
func create_from_template(template_name: String, parent: Node = null) -> Control:
	if not TEMPLATES.has(template_name):
		push_error("UIComponentRegistry: Unknown template '%s'" % template_name)
		return null
	
	var template_scene = load(TEMPLATES[template_name])
	if not template_scene:
		push_error("UIComponentRegistry: Failed to load template '%s'" % template_name)
		return null
	
	var instance = template_scene.instantiate()
	
	if parent:
		parent.add_child(instance)
	
	return instance

## Get all available component names
func get_available_components() -> Array:
	return COMPONENTS.keys()

## Get all available templates
func get_available_templates() -> Array:
	return TEMPLATES.keys()

## Register a custom component
func register_component(name: String, path: String) -> void:
	COMPONENTS[name] = path
	print("UIComponentRegistry: Registered component '%s' at '%s'" % [name, path])

## Register a custom template
func register_template(name: String, path: String) -> void:
	TEMPLATES[name] = path
	print("UIComponentRegistry: Registered template '%s' at '%s'" % [name, path])