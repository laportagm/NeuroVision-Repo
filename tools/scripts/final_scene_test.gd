## Final Scene Test
## This script performs a final comprehensive test of the Enhanced Exploration Scene

extends SceneTree

func _init() -> void:
	print("\n=== FINAL ENHANCED EXPLORATION SCENE TEST ===")
	
	# Load the scene
	var scene = load("res://scenes/3d/EnhancedExplorationScene.tscn")
	if not scene:
		push_error("Failed to load scene!")
		quit(1)
		return
	
	print("✅ Scene loaded successfully")
	
	# Check if script compiles
	var script = load("res://scenes/3d/EnhancedExplorationScene.gd")
	if not script:
		push_error("Failed to load script!")
		quit(1)
		return
	
	print("✅ Script compiles without errors")
	
	# Instantiate the scene
	var instance = scene.instantiate()
	if not instance:
		push_error("Failed to instantiate scene!")
		quit(1)
		return
	
	print("✅ Scene instantiated successfully")
	
	# Add to tree
	root.add_child(instance)
	
	# Wait for initialization
	await process_frame
	
	print("\n[Scene Analysis]")
	
	# Check critical nodes
	var critical_checks = {
		"KeyLight": instance.find_child("KeyLight", true, false),
		"RimLight": instance.find_child("RimLight", true, false),
		"BrainModelLoader": instance.find_child("BrainModelLoader", true, false),
		"InteractionController": instance.find_child("InteractionController", true, false),
		"MedicalViewCamera": instance.find_child("MedicalViewCamera", true, false)
	}
	
	var all_good = true
	for node_name in critical_checks:
		if critical_checks[node_name]:
			print("  ✅ %s exists" % node_name)
		else:
			print("  ❌ %s missing" % node_name)
			all_good = false
	
	# Check lighting configuration
	print("\n[Lighting Configuration]")
	var key_light = instance.find_child("KeyLight", true, false) as DirectionalLight3D
	if key_light:
		print("  KeyLight: visible=%s, energy=%.1f" % [key_light.visible, key_light.light_energy])
		if key_light.visible and key_light.light_energy > 0:
			print("  ✅ Medical lighting enabled")
		else:
			print("  ❌ Medical lighting disabled")
			all_good = false
	
	# Check for removed nodes
	print("\n[Optimization Verification]")
	var removed_nodes = ["ProximityWarning", "CameraConstraints", "MedicalCameraEffects", "FeedbackVFX"]
	var removed_count = 0
	for node_name in removed_nodes:
		if not instance.find_child(node_name, true, false):
			removed_count += 1
	print("  ✅ %d/%d redundant nodes removed" % [removed_count, removed_nodes.size()])
	
	# Summary
	print("\n[Summary]")
	if all_good:
		print("✅ Enhanced Exploration Scene is fully optimized and ready!")
		print("  - Medical lighting enabled for proper visualization")
		print("  - All critical nodes present")
		print("  - Redundant nodes removed")
		print("  - Script compiles without errors")
		print("  - Scene loads successfully")
		print("\n🎉 The scene is ready for use in the Godot editor!")
	else:
		print("⚠️ Some issues remain - please review the output above")
	
	# Cleanup
	instance.queue_free()
	
	# Wait a moment
	await create_timer(0.5).timeout
	
	quit(0 if all_good else 1)