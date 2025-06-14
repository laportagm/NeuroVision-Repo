extends Node

## Test script for performance-based shader system
## Tests the quality-based shader switching functionality

func _ready() -> void:
	print("=== SHADER PERFORMANCE TEST ===")
	_test_shader_loading()
	_test_quality_switching()
	_test_performance_integration()
	print("=== TEST COMPLETED ===")

func _test_shader_loading() -> void:
	print("\n[TEST] Testing shader loading...")
	
	# Check if UIThemeManager exists
	if not UIThemeManager:
		print("❌ UIThemeManager not found")
		return
	
	# Test shader preloading
	var lite_shader_path = "res://src/ui/effects/shaders/glass_morphism_ui_lite.gdshader"
	var full_shader_path = "res://src/ui/effects/shaders/glass_morphism_ui.gdshader"
	
	if ResourceLoader.exists(lite_shader_path):
		print("✅ Lite shader exists: " + lite_shader_path)
	else:
		print("❌ Lite shader missing: " + lite_shader_path)
	
	if ResourceLoader.exists(full_shader_path):
		print("✅ Full shader exists: " + full_shader_path)
	else:
		print("❌ Full shader missing: " + full_shader_path)

func _test_quality_switching() -> void:
	print("\n[TEST] Testing quality-based switching...")
	
	if not UIThemeManager:
		print("❌ UIThemeManager not available")
		return
	
	# Test different quality levels
	var quality_levels = ["low", "medium", "high", "ultra"]
	
	for quality in quality_levels:
		print("Testing quality: " + quality)
		UIThemeManager.apply_quality_based_shaders(quality)
		
		var current_quality = UIThemeManager.get_current_shader_quality()
		if current_quality == quality:
			print("✅ Quality set correctly: " + quality)
		else:
			print("❌ Quality mismatch. Expected: " + quality + ", Got: " + current_quality)
		
		# Check if lite shader is active for low/medium
		var is_lite_active = UIThemeManager.is_lite_shader_active()
		var should_be_lite = quality in ["low", "medium"]
		
		if is_lite_active == should_be_lite:
			print("✅ Shader selection correct for " + quality)
		else:
			print("❌ Shader selection incorrect for " + quality)

func _test_performance_integration() -> void:
	print("\n[TEST] Testing PerformanceMonitor integration...")
	
	if not PerformanceMonitor:
		print("❌ PerformanceMonitor not available")
		return
	
	if not UIThemeManager:
		print("❌ UIThemeManager not available")
		return
	
	print("✅ Both PerformanceMonitor and UIThemeManager available")
	
	# Test signal connection
	if PerformanceMonitor.is_connected("quality_level_changed", UIThemeManager._on_quality_level_changed):
		print("✅ Signal connection established")
	else:
		print("❌ Signal connection missing")

func _test_ui_panels_group() -> void:
	print("\n[TEST] Testing UI panels group...")
	
	var ui_panels = get_tree().get_nodes_in_group("ui_panels")
	print("Found " + str(ui_panels.size()) + " panels in ui_panels group")
	
	for panel in ui_panels:
		if panel is Control:
			print("✅ Valid panel: " + panel.name + " (" + panel.get_class() + ")")
		else:
			print("❌ Invalid panel: " + str(panel))

# Test function that can be called from debug console
func test_shader_switch_performance() -> void:
	print("\n=== PERFORMANCE TEST ===")
	
	if not UIThemeManager:
		return
	
	var start_time = Time.get_time_dict_from_system()
	
	# Switch to lite shader
	UIThemeManager.apply_quality_based_shaders("low")
	var lite_time = Time.get_time_dict_from_system()
	
	# Switch to full shader  
	UIThemeManager.apply_quality_based_shaders("high")
	var full_time = Time.get_time_dict_from_system()
	
	print("Shader switching completed")
	print("Check console for performance impact")

# Utility function to force shader quality for testing
func force_quality(quality: String) -> void:
	if UIThemeManager:
		UIThemeManager.force_shader_quality(quality)
		print("Forced shader quality to: " + quality)
	else:
		print("UIThemeManager not available")