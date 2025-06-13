extends SceneTree

## Command-line test for highlight system
##
## Run with: godot --headless --script src/debug/test_highlight_system.gd

func _initialize() -> void:
	print("==================================================")
	print("[HighlightTest] Testing Highlight System Components")
	print("==================================================")
	
	# Test 1: Check if HighlightMaterialManager is loaded
	print("\n[Test 1] Checking HighlightMaterialManager autoload...")
	var highlight_manager = root.get_node_or_null("HighlightMaterialManager")
	if highlight_manager:
		print("  ✓ HighlightMaterialManager found and loaded")
		print("  - Pool size: %d" % highlight_manager.get_pool_size())
		print("  - Active highlights: %d" % highlight_manager.get_active_highlight_count())
	else:
		print("  ✗ HighlightMaterialManager NOT FOUND")
		print("  - Check if it's added to project.godot autoloads")
	
	# Test 2: Check shader loading
	print("\n[Test 2] Checking shader resource...")
	var shader_path = "res://assets/shaders/structure_highlight/fresnel_rim.gdshader"
	if ResourceLoader.exists(shader_path):
		var shader = load(shader_path)
		if shader:
			print("  ✓ Shader loaded successfully")
		else:
			print("  ✗ Shader exists but failed to load")
	else:
		print("  ✗ Shader file not found at: %s" % shader_path)
	
	# Test 3: Test material creation
	print("\n[Test 3] Testing material creation...")
	if highlight_manager:
		# Create a test mesh
		var test_mesh = MeshInstance3D.new()
		test_mesh.mesh = SphereMesh.new()
		root.add_child(test_mesh)
		
		# Try to set highlight state
		highlight_manager.set_highlight_state(test_mesh, highlight_manager.HighlightState.HOVERING)
		await create_timer(0.5).timeout
		
		var state = highlight_manager.get_current_state(test_mesh)
		if state == highlight_manager.HighlightState.HOVERING:
			print("  ✓ Material state change successful")
		else:
			print("  ✗ Material state change failed - Current state: %d" % state)
		
		# Cleanup
		highlight_manager.remove_highlight(test_mesh)
		test_mesh.queue_free()
	else:
		print("  ✗ Cannot test materials - HighlightManager not available")
	
	# Test 4: Test state machine
	print("\n[Test 4] Testing state machine...")
	var StateMachine = load("res://src/systems/3d_interaction/HighlightStateMachine.gd")
	if StateMachine:
		var sm = StateMachine.new()
		var transitions_ok = true
		
		# Test valid transition
		if not sm.can_transition_to(1):  # IDLE -> HOVERING
			transitions_ok = false
			print("  ✗ Valid transition IDLE->HOVERING failed")
		
		# Test invalid transition
		if sm.can_transition_to(5):  # IDLE -> DISABLED should be valid
			print("  ✓ State transitions working correctly")
		else:
			transitions_ok = false
			print("  ✗ Valid transition IDLE->DISABLED failed")
		
		if transitions_ok:
			print("  ✓ State machine validation working")
	else:
		print("  ✗ State machine script not found")
	
	# Test 5: Test integration layer
	print("\n[Test 5] Testing integration layer...")
	var IntegrationScript = load("res://src/systems/3d_interaction/HighlightSystemIntegration.gd")
	if IntegrationScript:
		print("  ✓ Integration script loaded")
		# Can't fully test without a scene, but script loads
	else:
		print("  ✗ Integration script not found")
	
	print("\n==================================================")
	print("[HighlightTest] Test Complete")
	print("==================================================")
	
	# Exit
	quit()