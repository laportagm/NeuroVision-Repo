## Realistic Brain Material Manager for NeuroVision
## Enhanced 3D rendering with medical-grade brain tissue materials
##
## This system creates and manages realistic materials for .glb brain models
## with advanced subsurface scattering, structure-specific properties, and
## educational context adaptation.

class_name RealisticBrainMaterialManager
extends Node

# === SIGNALS ===
signal material_created(material_name: String, material: Material)
signal material_applied(node: Node3D, material_name: String)
signal quality_level_changed(new_level: String)

# === CONSTANTS ===
const MATERIAL_QUALITY_LEVELS = ["low", "medium", "high", "maximum"]
const BRAIN_REGIONS = {
	"gray_matter": {
		"albedo": Color(0.85, 0.75, 0.70, 1.0),
		"roughness": 0.9,
		"subsurface": 0.8,
		"description": "Cerebral cortex and neural cell bodies"
	},
	"white_matter": {
		"albedo": Color(0.95, 0.92, 0.88, 1.0),
		"roughness": 0.7,
		"subsurface": 0.6,
		"description": "Myelinated axons and nerve fibers"
	},
	"blood_vessels": {
		"albedo": Color(0.8, 0.25, 0.25, 1.0),
		"roughness": 0.3,
		"subsurface": 0.4,
		"description": "Vascular network and blood supply"
	},
	"cerebrospinal_fluid": {
		"albedo": Color(0.9, 0.95, 0.98, 0.8),
		"roughness": 0.1,
		"subsurface": 0.1,
		"description": "CSF spaces and ventricular system"
	},
	"dura_mater": {
		"albedo": Color(0.7, 0.65, 0.60, 1.0),
		"roughness": 0.8,
		"subsurface": 0.3,
		"description": "Tough outer meningeal layer"
	},
	"pia_mater": {
		"albedo": Color(0.9, 0.85, 0.8, 0.9),
		"roughness": 0.6,
		"subsurface": 0.5,
		"description": "Delicate inner meningeal layer"
	}
}

# === PROPERTIES ===
var current_quality_level: String = "high"
var material_cache: Dictionary = {}
var educational_context: Dictionary = {}
var performance_monitor = null
var lighting_manager = null

# Material enhancement settings
var enhancement_settings = {
	"subsurface_enabled": true,
	"clearcoat_enabled": true,
	"rim_lighting_enabled": true,
	"normal_mapping_enabled": true,
	"detail_textures_enabled": true,
	"wetness_simulation": 0.3,
	"vascular_visibility": 0.2,
	"tissue_transparency": 0.0
}

# === INITIALIZATION ===

func _init():
	_initialize_performance_monitoring()
	_create_base_materials()
	print("[BrainMaterials] Realistic brain material manager initialized")

func _initialize_performance_monitoring():
	"""Initialize connection to performance monitoring for quality adaptation"""
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root.has_node("PerformanceMonitor"):
		performance_monitor = tree.root.get_node("PerformanceMonitor")
		print("[BrainMaterials] Connected to performance monitoring")

func _create_base_materials():
	"""Create base materials for all brain regions"""
	for region_name in BRAIN_REGIONS:
		var region_data = BRAIN_REGIONS[region_name]
		var material = _create_brain_tissue_material(region_name, region_data)
		material_cache[region_name] = material
		material_created.emit(region_name, material)  # Emit signal for educational tracking
		print("[BrainMaterials] Created material for: %s" % region_name)

# === ENHANCED BRAIN TISSUE MATERIALS ===

func _create_brain_tissue_material(region_name: String, region_data: Dictionary) -> StandardMaterial3D:
	"""Create enhanced brain tissue material with subsurface scattering"""
	var material = StandardMaterial3D.new()
	material.resource_name = "BrainTissue_" + region_name
	
	# Base material properties
	material.albedo_color = region_data.albedo
	material.metallic = 0.0  # Biological tissue is non-metallic
	material.roughness = region_data.roughness
	
	# === SUBSURFACE SCATTERING FOR REALISTIC TISSUE ===
	if enhancement_settings.subsurface_enabled:
		material.subsurf_scatter_strength = region_data.subsurface
		# Removed deprecated Godot 3 flags
		
		# Enable skin mode for better subsurface scattering
		if region_name in ["gray_matter", "white_matter"]:
			material.subsurf_scatter_skin_mode = true
		
		# Subsurface scattering color (slightly warmer for tissue)
		var subsurface_color = region_data.albedo.lightened(0.1)
		subsurface_color.r = min(subsurface_color.r + 0.05, 1.0)  # Slight red shift
		# Note: subsurface_color property doesn't exist in StandardMaterial3D
		# We'll handle this through shader parameters if using custom shaders
	
	# === CLEARCOAT FOR WET TISSUE APPEARANCE ===
	if enhancement_settings.clearcoat_enabled:
		material.clearcoat = enhancement_settings.wetness_simulation
		material.clearcoat_roughness = 0.9  # Biological tissue isn't glossy
	
	# === RIM LIGHTING FOR DEPTH PERCEPTION ===
	if enhancement_settings.rim_lighting_enabled:
		material.rim = 0.8
		material.rim_tint = 0.3
	
	# === TRANSPARENCY FOR CSF AND DELICATE TISSUES ===
	if region_name in ["cerebrospinal_fluid", "pia_mater"]:
		material.flags_transparent = true
		material.albedo_color.a = region_data.albedo.a
	
	# === REGION-SPECIFIC ENHANCEMENTS ===
	match region_name:
		"blood_vessels":
			# Blood vessels have slight wetness and different scattering
			material.clearcoat = 0.5
			material.subsurf_scatter_strength = 0.4
			material.roughness = 0.3
		
		"cerebrospinal_fluid":
			# CSF should be clear and refractive
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.albedo_color.a = 0.3
			material.refraction_enabled = true
			material.refraction_scale = 0.1
			material.roughness = 0.05
		
		"white_matter":
			# White matter has more organized structure
			material.anisotropy_enabled = true
			material.anisotropy = 0.3
		
		"dura_mater":
			# Dura is tougher and less translucent
			material.subsurf_scatter_strength = 0.2
			material.roughness = 0.9
	
	# === PERFORMANCE-BASED QUALITY ADJUSTMENT ===
	_adjust_material_for_performance(material, current_quality_level)
	
	return material

func _adjust_material_for_performance(material: StandardMaterial3D, quality_level: String):
	"""Adjust material complexity based on performance level"""
	match quality_level:
		"maximum":
			# Full quality - all features enabled
			pass  # Already configured above
		
		"high":
			# Slight reduction in quality for better performance
			if material.subsurf_scatter_strength > 0.5:
				material.subsurf_scatter_strength *= 0.9
		
		"medium":
			# Moderate quality reduction
			material.subsurf_scatter_strength *= 0.7
			material.clearcoat *= 0.8
			material.rim *= 0.9
		
		"low":
			# Minimal quality for maximum performance
			material.subsurf_scatter_strength *= 0.5
			material.clearcoat = 0.0
			material.rim = 0.0
			material.anisotropy_enabled = false
			material.refraction_enabled = false

# === EDUCATIONAL CONTEXT ADAPTATION ===

func apply_educational_context(context: Dictionary):
	"""Adapt materials based on educational context"""
	educational_context = context
	
	# Adjust material properties based on context
	for region_name in material_cache:
		var material = material_cache[region_name] as StandardMaterial3D
		_adapt_material_for_context(material, region_name, context)

func _adapt_material_for_context(material: StandardMaterial3D, region_name: String, context: Dictionary):
	"""Adapt individual material for educational context"""
	var learning_level = context.get("learning_level", "intermediate")
	var clinical_focus = context.get("clinical_focus", false)
	var _pathology_mode = context.get("pathology_mode", false)
	
	# Store original properties for restoration
	if not material.has_meta("original_albedo"):
		material.set_meta("original_albedo", material.albedo_color)
		material.set_meta("original_roughness", material.roughness)
		material.set_meta("original_subsurface", material.subsurf_scatter_strength)
	
	# Learning level adaptations
	match learning_level:
		"beginner":
			# Enhance contrast and saturation for better visibility
			var enhanced_color = material.get_meta("original_albedo")
			enhanced_color.s = min(enhanced_color.s + 0.1, 1.0)
			enhanced_color.v = min(enhanced_color.v + 0.05, 1.0)
			material.albedo_color = enhanced_color
		
		"advanced":
			# More realistic, subdued appearance
			var realistic_color = material.get_meta("original_albedo")
			realistic_color.s *= 0.9
			material.albedo_color = realistic_color
		
		"expert":
			# Clinical accuracy over visual appeal
			material.albedo_color = material.get_meta("original_albedo")
	
	# Clinical focus adaptations
	if clinical_focus:
		# Increase contrast for medical examination
		material.roughness = material.get_meta("original_roughness") * 0.8
		material.rim = 1.0  # Enhanced edge definition
	
	# Pathology mode adaptations
	if _pathology_mode and region_name in ["gray_matter", "white_matter"]:
		# Slight color shift to indicate pathological conditions
		var pathology_tint = Color(1.1, 0.9, 0.9, 1.0)  # Slight reddish tint
		material.albedo_color = material.albedo_color * pathology_tint

# === STRUCTURE-SPECIFIC MATERIAL APPLICATION ===

func apply_material_to_structure(structure_node: Node3D, structure_name: String, region_type: String = "gray_matter"):
	"""Apply appropriate material to a brain structure"""
	if not structure_node:
		push_error("[BrainMaterials] Invalid structure node")
		return
	
	var material = get_material_for_region(region_type)
	if not material:
		push_error("[BrainMaterials] Material not found for region: %s" % region_type)
		return
	
	# Apply material to all mesh instances in the structure
	_apply_material_recursive(structure_node, material)
	
	material_applied.emit(structure_node, region_type)
	print("[BrainMaterials] Applied %s material to %s" % [region_type, structure_name])

func _apply_material_recursive(node: Node, material: Material):
	"""Recursively apply material to all MeshInstance3D nodes"""
	if node is MeshInstance3D:
		var mesh_instance = node as MeshInstance3D
		mesh_instance.material_override = material
	
	for child in node.get_children():
		_apply_material_recursive(child, material)

# === MATERIAL VARIANTS FOR INTERACTION STATES ===

func create_highlight_material(base_region: String, highlight_color: Color = Color.CYAN) -> StandardMaterial3D:
	"""Create highlighted version of material for selection feedback"""
	var base_material = get_material_for_region(base_region)
	if not base_material:
		return null
	
	var highlight_material = base_material.duplicate() as StandardMaterial3D
	highlight_material.resource_name = base_material.resource_name + "_Highlight"
	
	# Enhanced rim lighting for highlight
	highlight_material.rim = 1.5
	highlight_material.rim_tint = 0.0  # Use rim color directly
	
	# Slight emission for glow effect
	highlight_material.emission_enabled = true
	highlight_material.emission = highlight_color * 0.2
	highlight_material.emission_energy = 0.5
	
	# Enhance clearcoat for selection emphasis
	highlight_material.clearcoat = min(highlight_material.clearcoat + 0.3, 1.0)
	
	return highlight_material

func create_pathology_material(base_region: String, pathology_type: String = "inflammation") -> StandardMaterial3D:
	"""Create pathological variant of material"""
	var base_material = get_material_for_region(base_region)
	if not base_material:
		return null
	
	var pathology_material = base_material.duplicate() as StandardMaterial3D
	pathology_material.resource_name = base_material.resource_name + "_" + pathology_type
	
	match pathology_type:
		"inflammation":
			# Reddish tint for inflammation
			pathology_material.albedo_color = pathology_material.albedo_color * Color(1.2, 0.8, 0.8, 1.0)
			pathology_material.emission_enabled = true
			pathology_material.emission = Color(0.3, 0.0, 0.0, 1.0)
			pathology_material.emission_energy = 0.1
		
		"ischemia":
			# Bluish/gray tint for reduced blood flow
			pathology_material.albedo_color = pathology_material.albedo_color * Color(0.8, 0.8, 1.1, 1.0)
			pathology_material.subsurf_scatter_strength *= 0.6
		
		"degeneration":
			# Darker, more muted appearance
			pathology_material.albedo_color = pathology_material.albedo_color.darkened(0.2)
			pathology_material.roughness = min(pathology_material.roughness + 0.2, 1.0)
		
		"edema":
			# Increased translucency and slight swelling effect
			if not pathology_material.flags_transparent:
				pathology_material.flags_transparent = true
				pathology_material.albedo_color.a = 0.9
			pathology_material.clearcoat = min(pathology_material.clearcoat + 0.2, 1.0)
	
	return pathology_material

# === QUALITY AND PERFORMANCE MANAGEMENT ===

func set_quality_level(quality_level: String):
	"""Set material quality level and update all cached materials"""
	if quality_level not in MATERIAL_QUALITY_LEVELS:
		push_error("[BrainMaterials] Invalid quality level: %s" % quality_level)
		return
	
	if quality_level == current_quality_level:
		return
	
	var old_level = current_quality_level
	current_quality_level = quality_level
	
	# Update all cached materials
	for region_name in material_cache:
		var material = material_cache[region_name] as StandardMaterial3D
		_adjust_material_for_performance(material, quality_level)
	
	quality_level_changed.emit(quality_level)
	print("[BrainMaterials] Quality level changed: %s -> %s" % [old_level, quality_level])

func update_for_performance_metrics(metrics: Dictionary):
	"""Update material quality based on performance metrics"""
	if not performance_monitor:
		return
	
	var fps = metrics.get("fps", 60.0)
	var memory_mb = metrics.get("memory_mb", 300.0)
	
	var target_quality = current_quality_level
	
	# Determine if quality adjustment is needed
	if fps < 30.0 or memory_mb > 600.0:
		# Poor performance - reduce quality
		var current_index = MATERIAL_QUALITY_LEVELS.find(current_quality_level)
		if current_index > 0:
			target_quality = MATERIAL_QUALITY_LEVELS[current_index - 1]
	elif fps > 60.0 and memory_mb < 400.0:
		# Good performance - can increase quality
		var current_index = MATERIAL_QUALITY_LEVELS.find(current_quality_level)
		if current_index < MATERIAL_QUALITY_LEVELS.size() - 1:
			target_quality = MATERIAL_QUALITY_LEVELS[current_index + 1]
	
	if target_quality != current_quality_level:
		set_quality_level(target_quality)

# === PUBLIC API ===

func get_material_for_region(region_name: String) -> StandardMaterial3D:
	"""Get material for specific brain region"""
	return material_cache.get(region_name, material_cache.get("gray_matter"))

func get_available_regions() -> Array:
	"""Get list of available brain regions"""
	return BRAIN_REGIONS.keys()

func get_region_description(region_name: String) -> String:
	"""Get description of brain region"""
	var region_data = BRAIN_REGIONS.get(region_name, {})
	return region_data.get("description", "Unknown brain region")

func enable_enhancement(enhancement_name: String, enabled: bool):
	"""Enable or disable specific material enhancement"""
	if enhancement_name in enhancement_settings:
		enhancement_settings[enhancement_name] = enabled
		_refresh_all_materials()
		print("[BrainMaterials] Enhancement '%s' %s" % [enhancement_name, "enabled" if enabled else "disabled"])

func _refresh_all_materials():
	"""Refresh all materials with current enhancement settings"""
	material_cache.clear()
	_create_base_materials()
	
	# Reapply educational context if set
	if not educational_context.is_empty():
		apply_educational_context(educational_context)

func get_diagnostics() -> Dictionary:
	"""Get diagnostic information about material system"""
	return {
		"cached_materials": material_cache.size(),
		"current_quality": current_quality_level,
		"enhancement_settings": enhancement_settings,
		"educational_context": educational_context,
		"available_regions": get_available_regions()
	}

func clear_material_cache():
	"""Clear all cached materials"""
	material_cache.clear()
	_create_base_materials()
	print("[BrainMaterials] Material cache cleared and refreshed")
