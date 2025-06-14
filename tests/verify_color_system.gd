extends SceneTree

## Minimal script to verify color system is working

func _init():
	print("\n=== COLOR SYSTEM VERIFICATION ===")
	
	# Test 1: Can we access M3 colors?
	var primary = M3DesignTokens.M3_COLORS.get("primary")
	if primary:
		print("✓ M3_COLORS accessible - primary: %s" % str(primary))
	else:
		print("✗ M3_COLORS not accessible")
	
	# Test 2: Can we access brain colors?
	var hippo = M3DesignTokens.BRAIN_STRUCTURE_COLORS.get("hippocampus")
	if hippo:
		print("✓ BRAIN_STRUCTURE_COLORS accessible - hippocampus: %s" % str(hippo))
	else:
		print("✗ BRAIN_STRUCTURE_COLORS not accessible")
	
	# Test 3: Does get_color work?
	var color = M3DesignTokens.get_color("primary")
	if color and color == primary:
		print("✓ get_color() works correctly")
	else:
		print("✗ get_color() failed")
	
	# Test 4: Does color migration work?
	if M3ColorMigrator:
		var mapping = M3ColorMigrator.find_closest_token(Color.WHITE)
		if mapping and mapping.has("token_path"):
			print("✓ M3ColorMigrator works - WHITE -> %s" % mapping.token_path)
		else:
			print("✗ M3ColorMigrator failed")
	else:
		print("✗ M3ColorMigrator not found")
	
	# Test 5: Check if transparent color exists
	var transparent = M3DesignTokens.M3_COLORS.get("transparent")
	if transparent:
		print("✓ Transparent color exists: %s" % str(transparent))
	else:
		print("✗ Transparent color missing")
	
	print("\n=== VERIFICATION COMPLETE ===")
	
	quit(0)