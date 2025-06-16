## IThemeable.gd
## Interface for themeable components in NeuroVision
##
## This class defines the contract that all themeable UI components must follow.
## It ensures consistent theme application across the entire UI system.
## Components that implement this interface can be dynamically themed.

class_name IThemeable
extends RefCounted

# === INTERFACE METHODS ===
# These methods must be implemented by classes that use this interface

func apply_theme(theme: Theme) -> void:
	"""
	Apply a theme to this component.
	
	This method should:
	- Apply the theme to the component itself
	- Recursively apply to all child components
	- Update any custom styling based on theme
	- Trigger any necessary redraws or updates
	
	Args:
		theme: The Theme resource to apply
	"""
	push_error("apply_theme() must be implemented by %s" % get_class())

func get_theme_properties() -> Dictionary:
	"""
	Get the themeable properties of this component.
	
	Returns a dictionary describing what aspects can be themed:
	- colors: Dictionary of color properties
	- fonts: Dictionary of font properties
	- styles: Dictionary of style properties
	- constants: Dictionary of constant properties
	
	Example return:
	{
		"colors": {
			"font_color": "The main text color",
			"background_color": "The background color"
		},
		"fonts": {
			"font": "The main font",
			"bold_font": "The bold variant"
		},
		"styles": {
			"panel": "The panel background style",
			"button_normal": "The normal button style"
		},
		"constants": {
			"margin": "The margin size",
			"padding": "The padding size"
		}
	}
	"""
	push_error("get_theme_properties() must be implemented by %s" % get_class())
	return {}

func get_theme_type_name() -> String:
	"""
	Get the theme type name for this component.
	
	This is used to look up theme items in the Theme resource.
	For example: "Button", "Panel", "Label", etc.
	
	Returns:
		The theme type name as a string
	"""
	push_error("get_theme_type_name() must be implemented by %s" % get_class())
	return ""

func supports_theme_variants() -> bool:
	"""
	Check if this component supports theme variants.
	
	Theme variants allow components to have different styles based on context
	(e.g., "primary", "secondary", "danger" for buttons).
	
	Returns:
		true if variants are supported, false otherwise
	"""
	return false

func get_supported_variants() -> Array[String]:
	"""
	Get the list of supported theme variants.
	
	Only called if supports_theme_variants() returns true.
	
	Returns:
		Array of variant names (e.g., ["primary", "secondary", "danger"])
	"""
	return []

func set_theme_variant(variant: String) -> void:
	"""
	Set the active theme variant for this component.
	
	Only called if supports_theme_variants() returns true.
	
	Args:
		variant: The variant name to apply
	"""
	pass

func get_current_variant() -> String:
	"""
	Get the currently active theme variant.
	
	Only called if supports_theme_variants() returns true.
	
	Returns:
		The current variant name
	"""
	return "default"

# === HELPER METHODS ===
# These are utility methods that implementations can use

static func apply_theme_to_node(node: Node, theme: Theme) -> void:
	"""
	Helper method to apply theme to a node if it implements IThemeable.
	
	Args:
		node: The node to apply theme to
		theme: The theme to apply
	"""
	if node.has_method("apply_theme"):
		node.apply_theme(theme)

static func apply_theme_recursive(node: Node, theme: Theme) -> void:
	"""
	Recursively apply theme to a node and all its children.
	
	Args:
		node: The root node to start from
		theme: The theme to apply
	"""
	apply_theme_to_node(node, theme)
	
	for child in node.get_children():
		apply_theme_recursive(child, theme)

static func collect_theme_properties_recursive(node: Node) -> Dictionary:
	"""
	Collect all theme properties from a node tree.
	
	Args:
		node: The root node to start from
		
	Returns:
		Dictionary with node paths as keys and theme properties as values
	"""
	var properties = {}
	
	if node.has_method("get_theme_properties"):
		properties[node.get_path()] = node.get_theme_properties()
	
	for child in node.get_children():
		properties.merge(collect_theme_properties_recursive(child))
	
	return properties

static func validate_theme_implementation(node: Node) -> Array[String]:
	"""
	Validate that a node properly implements the IThemeable interface.
	
	Args:
		node: The node to validate
		
	Returns:
		Array of error messages (empty if valid)
	"""
	var errors: Array[String] = []
	
	var required_methods = [
		"apply_theme",
		"get_theme_properties",
		"get_theme_type_name"
	]
	
	for method in required_methods:
		if not node.has_method(method):
			errors.append("Missing required method: %s" % method)
	
	# If it supports variants, check variant methods
	if node.has_method("supports_theme_variants") and node.supports_theme_variants():
		var variant_methods = [
			"get_supported_variants",
			"set_theme_variant",
			"get_current_variant"
		]
		
		for method in variant_methods:
			if not node.has_method(method):
				errors.append("Missing variant method: %s" % method)
	
	return errors

# === THEME VARIANT DEFINITIONS ===
# Common theme variants that components can support

const BUTTON_VARIANTS = ["default", "primary", "secondary", "success", "warning", "danger", "ghost", "link"]
const PANEL_VARIANTS = ["default", "elevated", "outlined", "filled", "glass"]
const TEXT_VARIANTS = ["default", "heading", "subheading", "body", "caption", "overline"]
const INPUT_VARIANTS = ["default", "filled", "outlined", "underlined", "error", "success"]

# === THEME PROPERTY HELPERS ===

static func create_color_property(name: String, description: String, default_color: Color = Color.WHITE) -> Dictionary:
	"""Create a color property definition."""
	return {
		"type": "color",
		"name": name,
		"description": description,
		"default": default_color
	}

static func create_font_property(name: String, description: String, default_size: int = 16) -> Dictionary:
	"""Create a font property definition."""
	return {
		"type": "font",
		"name": name,
		"description": description,
		"default_size": default_size
	}

static func create_style_property(name: String, description: String, style_class: String = "StyleBox") -> Dictionary:
	"""Create a style property definition."""
	return {
		"type": "style",
		"name": name,
		"description": description,
		"style_class": style_class
	}

static func create_constant_property(name: String, description: String, default_value: int = 0) -> Dictionary:
	"""Create a constant property definition."""
	return {
		"type": "constant",
		"name": name,
		"description": description,
		"default": default_value
	}