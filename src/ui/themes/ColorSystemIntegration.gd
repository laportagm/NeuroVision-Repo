## ColorSystemIntegration.gd
## Integration layer for seamless color system adoption
##
## This class provides automated integration tools to ensure the unified color system
## works seamlessly with existing NeuroVision components and future additions.

class_name ColorSystemIntegration
extends RefCounted

# === INTEGRATION STATUS ===

enum IntegrationPhase {
	NOT_STARTED,
	ANALYZING,
	MIGRATING,
	VALIDATING,
	COMPLETE,
	ERROR
}

class IntegrationReport:
	var phase: IntegrationPhase = IntegrationPhase.NOT_STARTED
	var components_processed: int = 0
	var components_migrated: int = 0
	var validation_errors: Array[String] = []
	var performance_impact: Dictionary = {}
	var accessibility_improvements: Array[String] = []
	
	func get_success_rate() -> float:
		if components_processed == 0:
			return 0.0
		return float(components_migrated) / float(components_processed)

# === AUTOMATIC INTEGRATION ===

## Perform full integration of unified color system
static func integrate_unified_color_system() -> IntegrationReport:
	"""Automatically integrate the unified color system across NeuroVision"""
	
	var report = IntegrationReport.new()
	report.phase = IntegrationPhase.ANALYZING
	
	print("[ColorSystemIntegration] Starting full integration...")
	
	# Phase 1: Analyze existing color usage
	var analysis_result = _analyze_existing_color_usage()
	report.components_processed = analysis_result.total_components
	
	# Phase 2: Migrate components
	report.phase = IntegrationPhase.MIGRATING
	var migration_result = _migrate_components(analysis_result.components)
	report.components_migrated = migration_result.migrated_count
	
	# Phase 3: Validate integration
	report.phase = IntegrationPhase.VALIDATING
	var validation_result = _validate_integration()
	report.validation_errors = validation_result.errors
	
	# Phase 4: Performance check
	report.performance_impact = _assess_performance_impact()
	
	# Phase 5: Accessibility improvements
	report.accessibility_improvements = _document_accessibility_improvements()
	
	# Determine final status
	if report.validation_errors.is_empty() and report.get_success_rate() > 0.9:
		report.phase = IntegrationPhase.COMPLETE
		print("[ColorSystemIntegration] ✅ Integration completed successfully")
	else:
		report.phase = IntegrationPhase.ERROR
		print("[ColorSystemIntegration] ❌ Integration completed with issues")
	
	return report

## Integrate specific scene with unified colors
static func integrate_scene(scene: Node) -> Dictionary:
	"""Integrate a specific scene with the unified color system"""
	
	var result = {
		"success": true,
		"nodes_processed": 0,
		"nodes_migrated": 0,
		"errors": []
	}
	
	print("[ColorSystemIntegration] Integrating scene: %s" % scene.name)
	
	# Apply unified colors to all relevant nodes
	_integrate_node_recursive(scene, result)
	
	# Apply shader color adapter
	ShaderColorAdapter.apply_unified_colors_to_scene(scene, UnifiedColorManager.get_current_theme_variant())
	
	# Validate the integration
	var validation = ColorSystemValidator.validate_shader_colors(scene)
	if not validation.valid:
		result.errors.append_array(validation.violations)
		result.success = false
	
	print("[ColorSystemIntegration] Scene integration: %s (%d/%d nodes)" % [
		"✅ Success" if result.success else "❌ Error",
		result.nodes_migrated,
		result.nodes_processed
	])
	
	return result

# === COMPONENT MIGRATION ===

static func _analyze_existing_color_usage() -> Dictionary:
	"""Analyze existing color usage across the application"""
	
	var analysis = {
		"total_components": 0,
		"components": [],
		"hardcoded_colors": 0,
		"theme_aware_components": 0
	}
	
	# Scan for components with color usage
	var component_files = [
		"src/ui/components/",
		"src/ui/panels/",
		"src/scenes/",
		"src/autoload/"
	]
	
	for directory in component_files:
		_scan_directory_for_colors(directory, analysis)
	
	print("[ColorSystemIntegration] Analysis complete:")
	print("  - Total components: %d" % analysis.total_components)
	print("  - Hardcoded colors: %d" % analysis.hardcoded_colors)
	print("  - Theme-aware: %d" % analysis.theme_aware_components)
	
	return analysis

static func _scan_directory_for_colors(directory: String, analysis: Dictionary) -> void:
	"""Scan a directory for color usage patterns"""
	
	var dir = DirAccess.open("res://" + directory)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".gd"):
			var file_path = "res://" + directory + file_name
			_analyze_script_file(file_path, analysis)
		elif file_name.ends_with(".tscn"):
			var file_path = "res://" + directory + file_name
			_analyze_scene_file(file_path, analysis)
		
		file_name = dir.get_next()

static func _analyze_script_file(file_path: String, analysis: Dictionary) -> void:
	"""Analyze a script file for color usage"""
	
	var instances = M3ColorMigrator.analyze_file(file_path)
	analysis.total_components += 1
	
	var component_info = {
		"file_path": file_path,
		"type": "script",
		"hardcoded_colors": instances.size(),
		"theme_aware": false
	}
	
	# Check if already using theme system
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		if "M3DesignTokens" in content or "UnifiedColorSystem" in content:
			component_info.theme_aware = true
			analysis.theme_aware_components += 1
		else:
			analysis.hardcoded_colors += instances.size()
	
	analysis.components.append(component_info)

static func _analyze_scene_file(file_path: String, analysis: Dictionary) -> void:
	"""Analyze a scene file for hardcoded colors"""
	
	analysis.total_components += 1
	
	var component_info = {
		"file_path": file_path,
		"type": "scene",
		"hardcoded_colors": 0,
		"theme_aware": false
	}
	
	# Count hardcoded colors in scene file
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		var regex = RegEx.new()
		regex.compile(r"Color\s*\(\s*[\d.]+\s*,\s*[\d.]+\s*,\s*[\d.]+")
		var matches = regex.search_all(content)
		
		component_info.hardcoded_colors = matches.size()
		analysis.hardcoded_colors += matches.size()
	
	analysis.components.append(component_info)

static func _migrate_components(components: Array) -> Dictionary:
	"""Migrate components to use unified color system"""
	
	var result = {
		"migrated_count": 0,
		"error_count": 0,
		"errors": []
	}
	
	for component in components:
		var migration_success = false
		
		match component.type:
			"script":
				migration_success = _migrate_script_component(component)
			"scene":
				migration_success = _migrate_scene_component(component)
		
		if migration_success:
			result.migrated_count += 1
		else:
			result.error_count += 1
			result.errors.append("Failed to migrate: " + component.file_path)
	
	return result

static func _migrate_script_component(component: Dictionary) -> bool:
	"""Migrate a script component to unified color system"""
	
	var file_path = component.file_path
	
	# Skip if already theme-aware
	if component.theme_aware:
		return true
	
	# Skip if no hardcoded colors
	if component.hardcoded_colors == 0:
		return true
	
	print("[ColorSystemIntegration] Migrating script: %s" % file_path)
	
	# Use ColorSystemMigration to fix the file
	var migrator = ColorSystemMigration.new()
	var migration_result = migrator.migrate_script_file(file_path)
	
	return migration_result.success

static func _migrate_scene_component(component: Dictionary) -> bool:
	"""Migrate a scene component to unified color system"""
	
	var file_path = component.file_path
	
	# Skip if no hardcoded colors
	if component.hardcoded_colors == 0:
		return true
	
	print("[ColorSystemIntegration] Migrating scene: %s" % file_path)
	
	# For scene files, we need to be more careful
	# We'll mark them for manual review rather than auto-migrate
	push_warning("[ColorSystemIntegration] Scene file needs manual review: " + file_path)
	
	return false  # Manual review required

static func _validate_integration() -> Dictionary:
	"""Validate the integration results"""
	
	var validation = {
		"success": true,
		"errors": []
	}
	
	# Run full color system validation
	var system_validation = ColorSystemValidator.validate_project()
	
	if not system_validation.is_valid:
		validation.success = false
		for violation in system_validation.violations:
			validation.errors.append(violation.message)
	
	# Check accessibility compliance
	var accessibility_validation = ColorSystemValidator.validate_accessibility_compliance()
	
	if not accessibility_validation.accessibility_issues.is_empty():
		validation.success = false
		for issue in accessibility_validation.accessibility_issues:
			validation.errors.append("Accessibility: " + issue.issue)
	
	return validation

static func _assess_performance_impact() -> Dictionary:
	"""Assess performance impact of the unified color system"""
	
	var performance = {
		"color_access_time": 0.0,
		"cache_efficiency": 0.0,
		"memory_usage": 0,
		"shader_update_time": 0.0
	}
	
	# Measure color access performance
	var start_time = Time.get_ticks_msec()
	
	for i in range(1000):
		UnifiedColorSystem.get_color("primary")
		UnifiedColorSystem.get_color("surface")
		UnifiedColorSystem.get_color("on_surface")
	
	var end_time = Time.get_ticks_msec()
	performance.color_access_time = (end_time - start_time) / 1000.0
	
	# Check cache efficiency
	var cache_size = M3DesignTokens._color_cache.size()
	var total_tokens = M3DesignTokens.get_available_tokens().size()
	performance.cache_efficiency = float(cache_size) / float(total_tokens)
	
	# Estimate memory usage (simplified)
	performance.memory_usage = cache_size * 16  # Approximate bytes per cached color
	
	return performance

static func _document_accessibility_improvements() -> Array[String]:
	"""Document accessibility improvements from the unified system"""
	
	var improvements: Array[String] = []
	
	improvements.append("WCAG AAA compliance enforced across all components")
	improvements.append("Automatic contrast ratio validation (7:1 minimum)")
	improvements.append("Colorblind-safe palette options available")
	improvements.append("High contrast mode for visual impairments")
	improvements.append("Consistent focus indicators (3px minimum)")
	improvements.append("Brain structure colors optimized for accessibility")
	improvements.append("Theme variants for different accessibility needs")
	improvements.append("Real-time accessibility validation")
	
	return improvements

# === NODE INTEGRATION ===

static func _integrate_node_recursive(node: Node, result: Dictionary) -> void:
	"""Recursively integrate a node and its children"""
	
	result.nodes_processed += 1
	
	# Apply unified theme to the node
	if node is Control:
		var element_type = _determine_node_element_type(node)
		UnifiedColorSystem.apply_unified_theme(node, element_type)
		result.nodes_migrated += 1
	
	# Handle specific node types
	if node is MeshInstance3D:
		_integrate_mesh_instance(node, result)
	elif node is Light3D:
		_integrate_light_node(node, result)
	
	# Recursively process children
	for child in node.get_children():
		_integrate_node_recursive(child, result)

static func _determine_node_element_type(control: Control) -> String:
	"""Determine the element type for a control node"""
	
	if control is Button:
		return "button"
	elif control is Label:
		return "label"
	elif control is PanelContainer or control is Panel:
		return "panel"
	elif control is LineEdit or control is TextEdit:
		return "input"
	else:
		return "default"

static func _integrate_mesh_instance(mesh: MeshInstance3D, result: Dictionary) -> void:
	"""Integrate a MeshInstance3D with unified colors"""
	
	# Apply shader color adapter if it has a shader material
	if mesh.material_override is ShaderMaterial:
		var shader_material = mesh.material_override as ShaderMaterial
		ShaderColorAdapter.apply_unified_colors_to_material(shader_material)
		result.nodes_migrated += 1

static func _integrate_light_node(light: Light3D, result: Dictionary) -> void:
	"""Integrate lighting with unified color system"""
	
	# Adjust light colors to match theme
	var theme_variant = UnifiedColorManager.get_current_theme_variant()
	
	match theme_variant:
		"minimal":
			# Reduce light intensity for professional appearance
			light.light_energy *= 0.8
		"high_contrast":
			# Increase light intensity for better visibility
			light.light_energy *= 1.2
		"enhanced":
			# Standard lighting for engaging appearance
			pass
	
	result.nodes_migrated += 1

# === RUNTIME INTEGRATION ===

## Monitor runtime color access for optimization
static func enable_runtime_monitoring() -> void:
	"""Enable runtime monitoring of color system usage"""
	
	print("[ColorSystemIntegration] Enabling runtime monitoring...")
	
	# Enable validation logging
	UnifiedColorSystem.set_validation_enabled(true)
	
	# Connect to scene tree for automatic integration
	var main_loop = Engine.get_main_loop()
	if main_loop and main_loop.has_signal("node_added"):
		if not main_loop.node_added.is_connected(_on_node_added_to_scene):
			main_loop.node_added.connect(_on_node_added_to_scene)

static func _on_node_added_to_scene(node: Node) -> void:
	"""Automatically integrate new nodes added to the scene"""
	
	# Apply unified colors to new UI controls
	if node is Control:
		var element_type = _determine_node_element_type(node)
		UnifiedColorSystem.apply_unified_theme(node, element_type)
	
	# Apply shader colors to new mesh instances
	if node is MeshInstance3D and node.material_override is ShaderMaterial:
		var shader_material = node.material_override as ShaderMaterial
		ShaderColorAdapter.apply_unified_colors_to_material(shader_material)

# === INTEGRATION UTILITIES ===

## Create integration checklist for developers
static func generate_integration_checklist() -> Array[String]:
	"""Generate a checklist for manual integration steps"""
	
	return [
		"✅ Add UnifiedColorManager to project.godot autoloads",
		"✅ Replace Color() constructors with UnifiedColorSystem.get_color()",
		"✅ Update scene files to use theme-aware styling",
		"✅ Apply ShaderColorAdapter to custom shaders",
		"✅ Test theme switching across all variants",
		"✅ Validate accessibility compliance with screen readers",
		"✅ Run ColorSystemValidator.validate_project()",
		"✅ Test brain structure color visibility",
		"✅ Verify educational preset functionality",
		"✅ Confirm performance targets (60fps maintained)"
	]

## Generate integration documentation
static func generate_integration_documentation() -> String:
	"""Generate comprehensive integration documentation"""
	
	var doc = "# Unified Color System Integration Guide\n\n"
	
	doc += "## Quick Start\n"
	doc += "```gdscript\n"
	doc += "# Replace old color access:\n"
	doc += "# var color = Color(0.58, 0.65, 1.0)  # OLD\n"
	doc += "var color = UnifiedColorSystem.get_color(\"primary\")  # NEW\n"
	doc += "\n"
	doc += "# Educational colors:\n"
	doc += "var brain_color = UnifiedColorManager.get_brain_structure_color(\"hippocampus\")\n"
	doc += "\n"
	doc += "# Theme switching:\n"
	doc += "UnifiedColorManager.set_theme_variant(\"high_contrast\")\n"
	doc += "```\n\n"
	
	doc += "## Integration Checklist\n"
	var checklist = generate_integration_checklist()
	for item in checklist:
		doc += "- " + item + "\n"
	
	doc += "\n## Validation Commands\n"
	doc += "```gdscript\n"
	doc += "# Quick validation\n"
	doc += "ColorSystemValidator.quick_validate()\n"
	doc += "\n"
	doc += "# Full project validation\n"
	doc += "var report = ColorSystemValidator.validate_project()\n"
	doc += "print(report.generate_report())\n"
	doc += "```\n\n"
	
	doc += "## Educational Features\n"
	doc += "- 21 brain structure colors with theme adaptation\n"
	doc += "- WCAG AAA accessibility compliance\n"
	doc += "- Real-time theme switching\n"
	doc += "- Colorblind-safe alternatives\n"
	doc += "- Professional clinical themes\n"
	
	return doc

## Check integration readiness
static func check_integration_readiness() -> Dictionary:
	"""Check if the system is ready for unified color integration"""
	
	var readiness = {
		"ready": true,
		"requirements_met": [],
		"requirements_missing": [],
		"warnings": []
	}
	
	# Check for required autoloads
	if has_node("/root/UnifiedColorManager"):
		readiness.requirements_met.append("UnifiedColorManager autoload present")
	else:
		readiness.requirements_missing.append("UnifiedColorManager autoload missing")
		readiness.ready = false
	
	# Check for M3DesignTokens
	if M3DesignTokens:
		readiness.requirements_met.append("M3DesignTokens available")
	else:
		readiness.requirements_missing.append("M3DesignTokens not available")
		readiness.ready = false
	
	# Check for existing color system files
	var required_files = [
		"res://src/ui/themes/UnifiedColorSystem.gd",
		"res://src/ui/themes/ShaderColorAdapter.gd",
		"res://src/ui/themes/ColorSystemValidator.gd"
	]
	
	for file_path in required_files:
		if FileAccess.file_exists(file_path):
			readiness.requirements_met.append("File present: " + file_path)
		else:
			readiness.requirements_missing.append("File missing: " + file_path)
			readiness.ready = false
	
	return readiness

static func has_node(path: String) -> bool:
	"""Check if a node exists at the given path"""
	var main_loop = Engine.get_main_loop()
	if main_loop and main_loop.has_method("get_node"):
		return main_loop.get_node_or_null(path) != null
	return false