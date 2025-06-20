## Standalone Scene Optimization Script
## This version can run without the editor

extends SceneTree

const SCENE_PATH = "res://scenes/3d/EnhancedExplorationScene.tscn"

func _init() -> void:
	print("\n=== APPLYING SCENE OPTIMIZATIONS ===")
	print("Target scene: " + SCENE_PATH)
	
	# Load and optimize the scene
	var success = optimize_scene()
	
	# Exit with appropriate code
	quit(0 if success else 1)

func optimize_scene() -> bool:
	# Load the scene
	var scene = load(SCENE_PATH) as PackedScene
	if not scene:
		push_error("Failed to load scene: " + SCENE_PATH)
		return false
	
	var root = scene.instantiate()
	if not root:
		push_error("Failed to instantiate scene")
		return false
	
	print("\nStarting optimizations...")
	var changes_made = 0
	
	# 1. Enable medical lighting
	changes_made += _enable_medical_lighting(root)
	
	# 2. Remove redundant nodes
	changes_made += _remove_redundant_nodes(root)
	
	# 3. Add missing critical nodes
	changes_made += _add_missing_nodes(root)
	
	# 4. Optimize environment settings
	changes_made += _optimize_environment(root)
	
	print("\n[Summary] Total changes made: " + str(changes_made))
	
	if changes_made > 0:
		# Save the modified scene
		var packed = PackedScene.new()
		packed.pack(root)
		
		# First save as optimized version
		var optimized_path = SCENE_PATH.replace(".tscn", "_optimized.tscn")
		var error = ResourceSaver.save(packed, optimized_path)
		
		if error == OK:
			print("\n✅ Optimized scene saved to: " + optimized_path)
			
			# Now overwrite the original
			error = ResourceSaver.save(packed, SCENE_PATH)
			if error == OK:
				print("✅ Original scene updated!")
				return true
			else:
				push_error("Failed to update original scene: " + str(error))
		else:
			push_error("Failed to save optimized scene: " + str(error))
	else:
		print("\n⚠️  No changes were needed.")
	
	return false

func _enable_medical_lighting(root: Node) -> int:
	print("\n[1] Enabling Medical Lighting...")
	var changes = 0
	
	# Find and enable KeyLight
	var key_light = root.find_child("KeyLight", true, false) as DirectionalLight3D
	if key_light:
		if not key_light.visible:
			key_light.visible = true
			key_light.light_energy = 0.8
			key_light.light_color = Color(0.95, 0.95, 1.0)
			print("  ✓ KeyLight enabled with medical settings")
			changes += 1
		else:
			print("  - KeyLight already enabled")
	
	# Find and enable RimLight
	var rim_light = root.find_child("RimLight", true, false) as DirectionalLight3D
	if rim_light:
		if not rim_light.visible:
			rim_light.visible = true
			rim_light.light_energy = 0.3
			rim_light.light_color = Color(0.7, 0.8, 0.9)
			print("  ✓ RimLight enabled for depth")
			changes += 1
		else:
			print("  - RimLight already enabled")
	
	return changes

func _remove_redundant_nodes(root: Node) -> int:
	print("\n[2] Removing Redundant Nodes...")
	var changes = 0
	
	var nodes_to_remove = {
		"MedicalCameraEffects": "Empty placeholder node",
		"ProximityWarning": "Unused collision system",
		"CameraConstraints": "Over-engineered collision",
		"AnnotationDebug": "Development artifact"
	}
	
	for node_name in nodes_to_remove:
		var node = root.find_child(node_name, true, false)
		if node:
			var parent = node.get_parent()
			if parent:
				parent.remove_child(node)
				node.queue_free()
				print("  ✓ Removed: " + node_name + " (" + nodes_to_remove[node_name] + ")")
				changes += 1
		else:
			print("  - " + node_name + " not found")
	
	return changes

func _add_missing_nodes(root: Node) -> int:
	print("\n[3] Adding Missing Critical Nodes...")
	var changes = 0
	
	# Add BrainModelLoader
	var model_holder = root.find_child("BrainModelHolder", true, false)
	if model_holder:
		if not model_holder.has_node("BrainModelLoader"):
			var loader = Node.new()
			loader.name = "BrainModelLoader"
			loader.set_meta("description", "Async brain model loading system")
			model_holder.add_child(loader)
			loader.owner = root
			print("  ✓ Added BrainModelLoader")
			changes += 1
	
	# Add InteractionController
	var interaction_system = root.find_child("BrainInteractionSystem", true, false)
	if interaction_system:
		if not interaction_system.has_node("InteractionController"):
			var controller = Node3D.new()
			controller.name = "InteractionController"
			controller.set_meta("description", "Manages brain structure selection and highlighting")
			
			# Try to load and attach the script
			var script_path = "res://src/systems/3d_interaction/BrainInteractionController.gd"
			if ResourceLoader.exists(script_path):
				controller.set_script(load(script_path))
				print("  ✓ Added InteractionController with script")
			else:
				print("  ✓ Added InteractionController (script not found)")
			
			interaction_system.add_child(controller)
			controller.owner = root
			changes += 1
	
	# Add AccessibilityManager
	var systems_container = root.find_child("EducationalSystemsContainer", true, false)
	if systems_container:
		if not systems_container.has_node("AccessibilityManager"):
			var accessibility = Node.new()
			accessibility.name = "AccessibilityManager"
			accessibility.set_meta("description", "WCAG AAA compliance coordination")
			systems_container.add_child(accessibility)
			accessibility.owner = root
			print("  ✓ Added AccessibilityManager")
			changes += 1
	
	# Add EducationalAudioSystem
	if not root.has_node("EducationalAudioSystem"):
		var audio_system = AudioStreamPlayer.new()
		audio_system.name = "EducationalAudioSystem"
		audio_system.bus = "Master"
		audio_system.set_meta("description", "Medical terminology pronunciation and audio feedback")
		root.add_child(audio_system)
		audio_system.owner = root
		print("  ✓ Added EducationalAudioSystem")
		changes += 1
	
	return changes

func _optimize_environment(root: Node) -> int:
	print("\n[4] Optimizing Environment Settings...")
	var changes = 0
	
	var world_env = root.find_child("MedicalVisualizationEnvironment", true, false) as WorldEnvironment
	if world_env and world_env.environment:
		var env = world_env.environment
		
		# Optimize for Intel UHD 620
		if env.ssao_enabled:
			env.ssao_enabled = false
			print("  ✓ Disabled SSAO for performance")
			changes += 1
		
		if env.glow_intensity > 0.2:
			env.glow_intensity = 0.2
			env.glow_bloom = 0.2
			print("  ✓ Reduced glow intensity")
			changes += 1
		
		# Disable other expensive effects
		if env.has_method("set_volumetric_fog_enabled") and env.volumetric_fog_enabled:
			env.volumetric_fog_enabled = false
			print("  ✓ Disabled volumetric fog")
			changes += 1
	
	# Optimize shader blur values
	var panels = [
		root.find_child("EducationalTopBar", true, false),
		root.find_child("AnatomicalInfoPanel", true, false)
	]
	
	for panel in panels:
		if panel and panel.material:
			var mat = panel.material as ShaderMaterial
			if mat and mat.get_shader_parameter("blur_amount") != null:
				var current_blur = mat.get_shader_parameter("blur_amount")
				if current_blur > 6.0:
					mat.set_shader_parameter("blur_amount", 4.0)
					print("  ✓ Reduced blur on " + panel.name)
					changes += 1
	
	return changes