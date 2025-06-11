extends GutTest

## Tests for Level 5: Content Management System

var content_service = null

func before_each():
	# Create instance of content service
	content_service = preload("res://src/systems/content_management/StructureContentService.gd").new()
	add_child(content_service)
	
	# Give it time to load
	await wait_frames(5)

func after_each():
	if content_service and is_instance_valid(content_service):
		content_service.queue_free()

# === CRITICAL: Content File Exists ===

func test_content_file_exists():
	var path = "res://content/brain_structures.json"
	assert_true(FileAccess.file_exists(path), "Brain structures content file must exist")

# === CRITICAL: Content Loads Successfully ===

func test_content_service_loads():
	assert_true(content_service.is_content_loaded(), "Content must load successfully")

func test_all_brain_structures_loaded():
	var structure_ids = content_service.get_all_structure_ids()
	
	# Should have 5 structures matching our model
	assert_eq(structure_ids.size(), 5, "Should load 5 brain structures")
	
	# Check expected structures
	assert_true("thalamus" in structure_ids, "Should have thalamus")
	assert_true("hippocampus" in structure_ids, "Should have hippocampus")
	assert_true("striatum" in structure_ids, "Should have striatum")
	assert_true("ventricles" in structure_ids, "Should have ventricles")
	assert_true("corpus_callosum" in structure_ids, "Should have corpus callosum")

# === CRITICAL: Content Retrieval ===

func test_get_structure_by_id():
	var thalamus = content_service.get_structure_content("thalamus")
	
	assert_not_null(thalamus)
	assert_eq(thalamus.displayName, "Thalamus")
	assert_has(thalamus, "description")
	assert_has(thalamus, "function")
	assert_has(thalamus, "clinicalRelevance")
	assert_has(thalamus, "connections")
	assert_has(thalamus, "learningObjectives")

func test_get_structure_by_model_name():
	# Test exact model name
	var content = content_service.get_structure_content("Thalami (good)")
	assert_eq(content.id, "thalamus", "Should find thalamus by model name")
	
	# Test hippocampus model name
	content = content_service.get_structure_content("Hipp and Others (good)")
	assert_eq(content.id, "hippocampus", "Should find hippocampus by model name")
	
	# Test normalized name
	content = content_service.get_structure_content("striatum")
	assert_eq(content.id, "striatum", "Should find striatum")

func test_model_name_normalization():
	# Various forms should all resolve to the same structure
	var variations = [
		"Corpus Callosum (good)",
		"Corpus Callosum",
		"corpus callosum",
		"CORPUS CALLOSUM"
	]
	
	for variation in variations:
		var content = content_service.get_structure_content(variation)
		assert_eq(content.id, "corpus_callosum", "Should normalize: " + variation)

# === Educational Content Quality ===

func test_educational_content_completeness():
	var structures = ["thalamus", "hippocampus", "striatum", "ventricles", "corpus_callosum"]
	
	for structure_id in structures:
		var content = content_service.get_structure_content(structure_id)
		
		# Check all educational fields are present and non-empty
		assert_true(content.description.length() > 50, structure_id + " must have substantial description")
		assert_true(content.function.length() > 50, structure_id + " must have detailed function")
		assert_true(content.clinicalRelevance.length() > 50, structure_id + " must have clinical relevance")
		assert_gt(content.connections.size(), 2, structure_id + " must have multiple connections")
		assert_gt(content.learningObjectives.size(), 2, structure_id + " must have learning objectives")
		assert_gt(content.keyFacts.size(), 2, structure_id + " must have key facts")

func test_category_organization():
	# Test getting structures by category
	var limbic = content_service.get_structures_by_category("Limbic System")
	assert_eq(limbic.size(), 1, "Should have 1 limbic structure")
	assert_eq(limbic[0].id, "hippocampus")
	
	var basal_ganglia = content_service.get_structures_by_category("Basal Ganglia")
	assert_eq(basal_ganglia.size(), 1, "Should have 1 basal ganglia structure")
	assert_eq(basal_ganglia[0].id, "striatum")

# === Search Functionality ===

func test_search_by_keyword():
	# Search for "memory"
	var results = content_service.search_structures("memory")
	
	assert_gt(results.size(), 0, "Should find structures related to memory")
	
	# Hippocampus should be top result
	var found_hippocampus = false
	for result in results:
		if result.id == "hippocampus":
			found_hippocampus = true
			break
	assert_true(found_hippocampus, "Hippocampus should be in memory search results")

func test_search_clinical_terms():
	# Search for clinical conditions
	var results = content_service.search_structures("Alzheimer")
	
	var found = false
	for result in results:
		if result.id == "hippocampus":
			found = true
			break
	assert_true(found, "Should find hippocampus when searching for Alzheimer's")

func test_fuzzy_search():
	# Misspellings and partial matches
	var content = content_service.get_structure_content("hippo")
	assert_eq(content.id, "hippocampus", "Should fuzzy match hippocampus")
	
	content = content_service.get_structure_content("corpus")
	assert_eq(content.id, "corpus_callosum", "Should fuzzy match corpus callosum")

# === Performance ===

func test_content_retrieval_speed():
	var start_time = Time.get_ticks_usec()
	
	# Retrieve all structures
	for i in range(100):
		content_service.get_structure_content("thalamus")
	
	var elapsed = Time.get_ticks_usec() - start_time
	var avg_time = elapsed / 100
	
	# Should be very fast (under 1ms per retrieval)
	assert_lt(avg_time, 1000, "Content retrieval must be fast")

# === Error Handling ===

func test_handles_missing_structure():
	var content = content_service.get_structure_content("nonexistent_structure")
	assert_eq(content, {}, "Should return empty dict for missing structure")

func test_handles_null_query():
	var content = content_service.get_structure_content("")
	assert_eq(content, {}, "Should handle empty query gracefully")