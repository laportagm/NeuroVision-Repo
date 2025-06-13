extends SceneTree

## Test structure name mapping

func _initialize() -> void:
	print("==================================================")
	print("[MappingTest] Testing Structure Name Mapping")
	print("==================================================")
	
	# Test StructureContentService
	var content_service = root.get_node_or_null("StructureContentService")
	if not content_service:
		print("ERROR: StructureContentService not found!")
		quit(1)
		return
	
	# Wait for content to load
	print("Waiting for content to load...")
	await create_timer(1.0).timeout
	
	print("\n[Test 1] Testing direct mappings...")
	
	# Test problematic names
	var test_cases = [
		"Hipp And Others (good)",
		"Hipp and Others (good)",
		"hipp and others (good)",
		"HIPP AND OTHERS (GOOD)",
		"Hipp and Others",
		"hippocampus",
		"Hippocampus"
	]
	
	for test_name in test_cases:
		var content = content_service.get_structure_content(test_name)
		if content.is_empty():
			print("  ✗ Failed to find content for: '%s'" % test_name)
		else:
			print("  ✓ Found content for: '%s' -> %s" % [test_name, content.get("id", "???")])
	
	print("\n[Test 2] Testing normalization...")
	
	# Test the normalization function directly if possible
	if content_service.has_method("_normalize_model_name"):
		print("  Note: _normalize_model_name is private, cannot test directly")
	
	# Test through public API
	var variations = [
		"Striatum (good)",
		"striatum (good)",
		"Striatum",
		"STRIATUM",
		"Thalami (good)",
		"Thalami",
		"thalamus"
	]
	
	print("\n[Test 3] Testing other structure variations...")
	for variation in variations:
		var content = content_service.get_structure_content(variation)
		if not content.is_empty():
			print("  ✓ '%s' -> %s" % [variation, content.get("id", "???")])
		else:
			print("  ✗ '%s' -> NOT FOUND" % variation)
	
	print("\n[Test 4] Checking all loaded structures...")
	var all_ids = content_service.get_all_structure_ids()
	print("  Total structures loaded: %d" % all_ids.size())
	print("  Structure IDs: %s" % str(all_ids))
	
	print("\n==================================================")
	print("[MappingTest] Test Complete")
	print("==================================================")
	
	quit()