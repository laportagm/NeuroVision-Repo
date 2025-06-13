extends SceneTree

## Simple test to verify highlight system works

func _initialize() -> void:
	print("Testing highlight system...")
	
	# Get highlight manager
	var highlight_manager = root.get_node_or_null("HighlightMaterialManager")
	if not highlight_manager:
		print("ERROR: HighlightMaterialManager not found!")
		quit(1)
		return
	
	print("✓ HighlightMaterialManager found")
	
	# Create test mesh
	var test_mesh = MeshInstance3D.new()
	test_mesh.mesh = SphereMesh.new()
	root.add_child(test_mesh)
	
	# Test state changes
	print("\nTesting state transitions:")
	
	# Test hover
	highlight_manager.set_highlight_state(test_mesh, highlight_manager.HighlightState.HOVERING)
	await create_timer(0.3).timeout
	var state = highlight_manager.get_current_state(test_mesh)
	print("  Hover state: %d (expected %d)" % [state, highlight_manager.HighlightState.HOVERING])
	
	# Test selection
	highlight_manager.set_highlight_state(test_mesh, highlight_manager.HighlightState.SELECTED)
	await create_timer(0.3).timeout
	state = highlight_manager.get_current_state(test_mesh)
	print("  Selected state: %d (expected %d)" % [state, highlight_manager.HighlightState.SELECTED])
	
	# Test material application
	var material = test_mesh.get_surface_override_material(0)
	if material:
		print("\n✓ Material applied to mesh")
		print("  Material type: %s" % material.get_class())
		
		var is_headless = OS.has_feature("headless") or DisplayServer.get_name() == "headless"
		
		if material is ShaderMaterial:
			if material.shader:
				print("  ✓ Shader: %s" % material.shader.resource_path)
			else:
				print("  ✗ ShaderMaterial has no shader assigned")
		elif material is StandardMaterial3D and is_headless:
			print("  ✓ Using StandardMaterial3D fallback (headless mode)")
		else:
			print("  ✗ Unexpected material type")
	else:
		print("\n✗ No material applied to mesh")
		# Check material count
		print("  Surface count: %d" % test_mesh.mesh.get_surface_count())
		print("  Material count: %d" % test_mesh.get_surface_override_material_count())
		
	# Also check active materials in manager
	print("\nManager state:")
	print("  Active highlights: %d" % highlight_manager.get_active_highlight_count())
	print("  Pool size: %d" % highlight_manager.get_pool_size())
	
	# Cleanup
	highlight_manager.remove_highlight(test_mesh)
	test_mesh.queue_free()
	
	print("\nTest complete!")
	quit()