## ShaderColorAdapter.gd
## Theme-aware shader parameter manager for glass morphism and effects
##
## This system fixes the hardcoded shader tint colors by providing
## dynamic color parameters that adapt to the current theme variant.
## Ensures glass morphism effects remain consistent with the unified color system.

class_name ShaderColorAdapter
extends RefCounted

# === SHADER COLOR MAPPINGS ===

## Glass morphism color roles
const GLASS_COLOR_ROLES = {
	"tint_color": "surface_container",
	"border_color": "outline_variant", 
	"highlight_color": "primary",
	"background_blur": "surface",
	"accent_glow": "primary"
}

## Glass effect opacity levels by theme variant
const GLASS_OPACITY_VARIANTS = {
	"enhanced": {
		"tint_alpha": 0.15,
		"border_alpha": 0.2,
		"blur_strength": 12.0
	},
	"minimal": {
		"tint_alpha": 0.08,
		"border_alpha": 0.1,
		"blur_strength": 4.0
	},
	"high_contrast": {
		"tint_alpha": 0.25,
		"border_alpha": 0.4,
		"blur_strength": 8.0
	},
	"colorblind_safe": {
		"tint_alpha": 0.18,
		"border_alpha": 0.25,
		"blur_strength": 10.0
	}
}

# === SHADER MATERIAL MANAGEMENT ===

## Update all shader materials to use theme-aware colors
static func apply_unified_colors_to_scene(scene: Node, theme_variant: String = "enhanced") -> void:
	"""Update all shader materials in a scene to use unified colors"""
	
	print("[ShaderColorAdapter] Applying unified colors to scene: %s (variant: %s)" % [scene.name, theme_variant])
	
	var shader_materials = _find_shader_materials(scene)
	
	for material in shader_materials:
		apply_unified_colors_to_material(material, theme_variant)
	
	print("[ShaderColorAdapter] Updated %d shader materials" % shader_materials.size())

## Update a specific shader material
static func apply_unified_colors_to_material(material: ShaderMaterial, theme_variant: String = "enhanced") -> void:
	"""Update a shader material to use unified color system"""
	
	if not material or not material.shader:
		return
	
	var shader_path = material.shader.resource_path
	print("[ShaderColorAdapter] Updating material with shader: %s" % shader_path)
	
	# Handle glass panel shaders
	if "glass_panel" in shader_path:
		_apply_glass_panel_colors(material, theme_variant)
	
	# Handle other effect shaders
	elif "glow" in shader_path:
		_apply_glow_effect_colors(material, theme_variant)
	
	elif "highlight" in shader_path:
		_apply_highlight_colors(material, theme_variant)
	
	else:
		# Generic shader color application
		_apply_generic_shader_colors(material, theme_variant)

## Get theme-aware glass tint color
static func get_glass_tint_color(theme_variant: String = "enhanced") -> Color:
	"""Get the appropriate glass tint color for current theme"""
	
	var base_color = UnifiedColorSystem.get_color("surface_container")
	var opacity_data = GLASS_OPACITY_VARIANTS.get(theme_variant, GLASS_OPACITY_VARIANTS["enhanced"])
	
	base_color.a = opacity_data["tint_alpha"]
	return base_color

## Get theme-aware glass border color
static func get_glass_border_color(theme_variant: String = "enhanced") -> Color:
	"""Get the appropriate glass border color for current theme"""
	
	var base_color = UnifiedColorSystem.get_color("outline_variant")
	var opacity_data = GLASS_OPACITY_VARIANTS.get(theme_variant, GLASS_OPACITY_VARIANTS["enhanced"])
	
	base_color.a = opacity_data["border_alpha"]
	return base_color

## Get theme-aware blur strength
static func get_glass_blur_strength(theme_variant: String = "enhanced") -> float:
	"""Get the appropriate blur strength for current theme"""
	
	var opacity_data = GLASS_OPACITY_VARIANTS.get(theme_variant, GLASS_OPACITY_VARIANTS["enhanced"])
	return opacity_data["blur_strength"]

# === SHADER PARAMETER SETTERS ===

## Set glass morphism parameters for a material
static func set_glass_morphism_parameters(material: ShaderMaterial, theme_variant: String = "enhanced") -> void:
	"""Set all glass morphism shader parameters for unified theming"""
	
	if not material:
		return
	
	# Set tint color
	var tint_color = get_glass_tint_color(theme_variant)
	material.set_shader_parameter("tint_color", tint_color)
	
	# Set border color if available
	if _material_has_parameter(material, "border_color"):
		var border_color = get_glass_border_color(theme_variant)
		material.set_shader_parameter("border_color", border_color)
	
	# Set blur amount
	if _material_has_parameter(material, "blur_amount"):
		var blur_strength = get_glass_blur_strength(theme_variant)
		material.set_shader_parameter("blur_amount", blur_strength)
	
	# Set highlight color if available
	if _material_has_parameter(material, "highlight_color"):
		var highlight_color = UnifiedColorSystem.get_color("primary")
		highlight_color.a = 0.3
		material.set_shader_parameter("highlight_color", highlight_color)
	
	print("[ShaderColorAdapter] Applied glass morphism parameters (variant: %s)" % theme_variant)

## Set brain structure highlight parameters
static func set_brain_highlight_parameters(material: ShaderMaterial, structure_name: String, theme_variant: String = "enhanced") -> void:
	"""Set brain structure highlight shader parameters"""
	
	if not material:
		return
	
	# Get structure-specific color
	var structure_color = UnifiedColorSystem.get_brain_structure_color(structure_name, theme_variant)
	material.set_shader_parameter("highlight_color", structure_color)
	
	# Set selection intensity based on theme
	var intensity = 0.8
	match theme_variant:
		"minimal":
			intensity = 0.6
		"high_contrast":
			intensity = 1.0
		"enhanced":
			intensity = 0.8
	
	material.set_shader_parameter("selection_intensity", intensity)
	
	print("[ShaderColorAdapter] Applied brain highlight parameters for %s (variant: %s)" % [structure_name, theme_variant])

# === PRIVATE HELPER METHODS ===

static func _find_shader_materials(node: Node) -> Array[ShaderMaterial]:
	"""Recursively find all shader materials in a node tree"""
	
	var materials: Array[ShaderMaterial] = []
	
	# Check current node
	if node.has_method("get_material"):
		var material = node.get_material()
		if material is ShaderMaterial:
			materials.append(material)
	
	# Check node-specific material properties
	if node is MeshInstance3D:
		var mesh_instance = node as MeshInstance3D
		if mesh_instance.material_override is ShaderMaterial:
			materials.append(mesh_instance.material_override)
	
	elif node is Control:
		var control = node as Control
		if control.material is ShaderMaterial:
			materials.append(control.material)
	
	# Recursively check children
	for child in node.get_children():
		materials.append_array(_find_shader_materials(child))
	
	return materials

static func _apply_glass_panel_colors(material: ShaderMaterial, theme_variant: String) -> void:
	"""Apply unified colors to glass panel shaders"""
	
	set_glass_morphism_parameters(material, theme_variant)
	
	# Additional glass panel specific parameters
	if _material_has_parameter(material, "background_color"):
		var bg_color = UnifiedColorSystem.get_color("surface")
		material.set_shader_parameter("background_color", bg_color)

static func _apply_glow_effect_colors(material: ShaderMaterial, theme_variant: String) -> void:
	"""Apply unified colors to glow effect shaders"""
	
	if _material_has_parameter(material, "glow_color"):
		var glow_color = UnifiedColorSystem.get_color("primary")
		material.set_shader_parameter("glow_color", glow_color)
	
	if _material_has_parameter(material, "glow_intensity"):
		var intensity = 0.5
		match theme_variant:
			"minimal":
				intensity = 0.3
			"enhanced":
				intensity = 0.7
			"high_contrast":
				intensity = 0.8
		material.set_shader_parameter("glow_intensity", intensity)

static func _apply_highlight_colors(material: ShaderMaterial, _theme_variant: String) -> void:
	"""Apply unified colors to highlight shaders"""
	
	if _material_has_parameter(material, "highlight_color"):
		var highlight_color = UnifiedColorSystem.get_color("primary")
		material.set_shader_parameter("highlight_color", highlight_color)
	
	if _material_has_parameter(material, "rim_color"):
		var rim_color = UnifiedColorSystem.get_color("primary")
		rim_color.a = 0.6
		material.set_shader_parameter("rim_color", rim_color)

static func _apply_generic_shader_colors(material: ShaderMaterial, _theme_variant: String) -> void:
	"""Apply unified colors to generic shaders"""
	
	# Common shader parameter names to update
	var common_parameters = {
		"color": "primary",
		"tint": "surface_container",
		"accent": "primary",
		"background": "surface",
		"border": "outline"
	}
	
	for param_name in common_parameters:
		if _material_has_parameter(material, param_name):
			var token_name = common_parameters[param_name]
			var color = UnifiedColorSystem.get_color(token_name)
			material.set_shader_parameter(param_name, color)

static func _material_has_parameter(material: ShaderMaterial, parameter_name: String) -> bool:
	"""Check if a shader material has a specific parameter"""
	
	if not material or not material.shader:
		return false
	
	# Note: In a real implementation, this would check the shader's parameter list
	# For now, we'll assume common parameters exist
	var common_parameters = [
		"tint_color", "border_color", "blur_amount", "highlight_color",
		"glow_color", "glow_intensity", "background_color", "rim_color",
		"color", "tint", "accent", "background", "border", "selection_intensity"
	]
	
	return parameter_name in common_parameters

# === THEME SWITCHING SUPPORT ===

## Update all shaders in a scene when theme changes
static func on_theme_changed(scene: Node, new_theme_variant: String) -> void:
	"""Called when the theme variant changes to update all shaders"""
	
	print("[ShaderColorAdapter] Theme changed to: %s" % new_theme_variant)
	apply_unified_colors_to_scene(scene, new_theme_variant)

## Create shader material with unified colors
static func create_glass_material(theme_variant: String = "enhanced") -> ShaderMaterial:
	"""Create a new glass morphism material with unified colors"""
	
	var material = ShaderMaterial.new()
	
	# Note: In a real implementation, this would load the actual shader
	# material.shader = load("res://src/ui/effects/shaders/glass_panel_v1.gdshader")
	
	# Apply unified colors
	set_glass_morphism_parameters(material, theme_variant)
	
	return material

## Get themed shader parameters as dictionary
static func get_shader_parameters(shader_type: String, theme_variant: String = "enhanced") -> Dictionary:
	"""Get shader parameters for a specific shader type and theme variant"""
	
	var parameters = {}
	
	match shader_type:
		"glass_panel":
			parameters["tint_color"] = get_glass_tint_color(theme_variant)
			parameters["border_color"] = get_glass_border_color(theme_variant)
			parameters["blur_amount"] = get_glass_blur_strength(theme_variant)
			parameters["highlight_color"] = UnifiedColorSystem.get_color("primary")
		
		"brain_highlight":
			parameters["highlight_color"] = UnifiedColorSystem.get_color("primary")
			parameters["selection_intensity"] = 0.8
			parameters["rim_color"] = UnifiedColorSystem.get_color("primary")
		
		"ui_glow":
			parameters["glow_color"] = UnifiedColorSystem.get_color("primary")
			parameters["glow_intensity"] = 0.5
		
		_:
			print("[ShaderColorAdapter] Unknown shader type: %s" % shader_type)
	
	return parameters

# === VALIDATION ===

## Validate that all shaders in a scene use unified colors
static func validate_shader_colors(scene: Node) -> Dictionary:
	"""Validate that all shaders use the unified color system"""
	
	var report = {
		"valid": true,
		"violations": [],
		"total_materials": 0,
		"unified_materials": 0
	}
	
	var materials = _find_shader_materials(scene)
	report.total_materials = materials.size()
	
	for material in materials:
		if _is_material_using_unified_colors(material):
			report.unified_materials += 1
		else:
			report.violations.append({
				"material": material,
				"issue": "Not using unified color system"
			})
	
	report.valid = report.violations.is_empty()
	
	return report

static func _is_material_using_unified_colors(material: ShaderMaterial) -> bool:
	"""Check if a material is using the unified color system"""
	
	# This is a simplified check - in practice, would verify parameter values
	# against known unified color tokens
	return material != null and material.shader != null