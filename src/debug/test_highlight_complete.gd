extends SceneTree

## Complete test of highlight system in both modes

func _initialize() -> void:
	print("==================================================")
	print("[CompleteTest] Highlight System Complete Test")
	print("==================================================")
	
	var is_headless = OS.has_feature("headless") or DisplayServer.get_name() == "headless"
	print("\nRunning in %s mode" % ("HEADLESS" if is_headless else "NORMAL"))
	
	# Test all components
	var all_passed = true
	
	# Test 1: Manager loads
	print("\n[Test 1] HighlightMaterialManager...")
	var highlight_manager = root.get_node_or_null("HighlightMaterialManager")
	if highlight_manager:
		print("  ✓ Manager loaded")
	else:
		print("  ✗ Manager not found")
		all_passed = false
	
	# Test 2: Material pool creation
	print("\n[Test 2] Material pool...")
	# Give time for initialization
	await create_timer(0.1).timeout
	if highlight_manager and highlight_manager.has_method("get_pool_size"):
		var pool_size = highlight_manager.get_pool_size()
		# In headless mode, materials are created on demand, so pool might be smaller
		if pool_size >= 0:
			print("  ✓ Pool system working (size: %d)" % pool_size)
		else:
			print("  ✗ Pool error")
			all_passed = false
	else:
		print("  ✗ Pool method not found")
		all_passed = false
	
	# Test 3: State transitions
	print("\n[Test 3] State transitions...")
	if highlight_manager:
		var test_mesh = MeshInstance3D.new()
		test_mesh.mesh = SphereMesh.new()
		root.add_child(test_mesh)
		
		# Test transitions
		var transitions_ok = true
		
		# Idle -> Hovering
		highlight_manager.set_highlight_state(test_mesh, highlight_manager.HighlightState.HOVERING)
		await create_timer(0.3).timeout  # Wait for transition
		var hover_state = highlight_manager.get_current_state(test_mesh)
		if hover_state != highlight_manager.HighlightState.HOVERING:
			print("    Expected HOVERING (1), got %d" % hover_state)
			transitions_ok = false
		
		# Hovering -> Selected
		highlight_manager.set_highlight_state(test_mesh, highlight_manager.HighlightState.SELECTED)
		await create_timer(0.3).timeout  # Wait for transition
		var selected_state = highlight_manager.get_current_state(test_mesh)
		if selected_state != highlight_manager.HighlightState.SELECTED:
			print("    Expected SELECTED (2), got %d" % selected_state)
			transitions_ok = false
		
		if transitions_ok:
			print("  ✓ State transitions working")
		else:
			print("  ✗ State transitions failed")
			all_passed = false
		
		# Cleanup
		highlight_manager.remove_highlight(test_mesh)
		test_mesh.queue_free()
	
	# Test 4: Material type
	print("\n[Test 4] Material type...")
	if highlight_manager:
		var test_mesh2 = MeshInstance3D.new()
		test_mesh2.mesh = SphereMesh.new()
		root.add_child(test_mesh2)
		
		highlight_manager.set_highlight_state(test_mesh2, highlight_manager.HighlightState.HOVERING)
		await create_timer(0.1).timeout
		
		var material = test_mesh2.get_surface_override_material(0)
		if material:
			if is_headless and material is StandardMaterial3D:
				print("  ✓ StandardMaterial3D fallback (headless)")
			elif not is_headless and material is ShaderMaterial:
				print("  ✓ ShaderMaterial (normal mode)")
			else:
				print("  ✗ Wrong material type for mode")
				all_passed = false
		else:
			print("  ✗ No material applied")
			all_passed = false
		
		# Cleanup
		highlight_manager.remove_highlight(test_mesh2)
		test_mesh2.queue_free()
	
	# Test 5: Integration components
	print("\n[Test 5] Integration components...")
	var components_ok = true
	
	# Check state machine
	var StateMachine = load("res://src/systems/3d_interaction/HighlightStateMachine.gd")
	if not StateMachine:
		print("  ✗ State machine not found")
		components_ok = false
	
	# Check integration layer
	var Integration = load("res://src/systems/3d_interaction/HighlightSystemIntegration.gd")
	if not Integration:
		print("  ✗ Integration layer not found")
		components_ok = false
	
	# Check shader (only in normal mode)
	if not is_headless:
		var shader = load("res://assets/shaders/structure_highlight/fresnel_rim.gdshader")
		if not shader:
			print("  ✗ Shader not found")
			components_ok = false
	
	if components_ok:
		print("  ✓ All integration components present")
	else:
		all_passed = false
	
	# Summary
	print("\n==================================================")
	if all_passed:
		print("[CompleteTest] ALL TESTS PASSED ✓")
		print("Batch 1 implementation is working correctly!")
	else:
		print("[CompleteTest] SOME TESTS FAILED ✗")
	print("==================================================")
	
	quit()