extends Node

## Tests for LearningContentManager functionality

var learning_content_manager: Node
var test_passed = true

func _ready():
	print("Starting LearningContentManager tests...")
	# Wait for autoloads to initialize
	await get_tree().process_frame
	await get_tree().process_frame
	run_all_tests()

func run_all_tests():
	test_manager_initialization()
	await test_content_filtering()
	await test_learning_level_integration()
	await test_progressive_disclosure()
	test_content_metadata()
	test_field_availability()
	
	if test_passed:
		print("✅ All LearningContentManager tests passed!")
	else:
		print("❌ Some LearningContentManager tests failed!")

func setup_manager():
	learning_content_manager = LearningContentManager
	return learning_content_manager != null

func test_manager_initialization():
	print("\n→ Testing manager initialization...")
	
	if not setup_manager():
		print("  ❌ Failed to access LearningContentManager")
		test_passed = false
		return
	
	# Test that manager is initialized
	if not learning_content_manager.has_method("get_filtered_content"):
		print("  ❌ LearningContentManager missing required methods")
		test_passed = false
		return
	
	# Test learning level summary
	var summary = learning_content_manager.get_learning_level_summary()
	if not summary.has("learning_level"):
		print("  ❌ Learning level summary missing level information")
		test_passed = false
		return
	
	print("  ✓ Manager initialization test passed")

func test_content_filtering():
	print("\n→ Testing content filtering...")
	
	if not setup_manager():
		print("  ❌ Failed to access LearningContentManager")
		test_passed = false
		return
	
	# Wait for StructureContentService to be ready
	if not StructureContentService or not StructureContentService.is_content_loaded():
		print("  ⏳ Waiting for StructureContentService...")
		await get_tree().create_timer(1.0).timeout
	
	if not StructureContentService.is_content_loaded():
		print("  ❌ StructureContentService not ready")
		test_passed = false
		return
	
	# Test filtering for known structure
	var filtered_content = learning_content_manager.get_filtered_content("hippocampus")
	
	if filtered_content.is_empty():
		print("  ❌ No filtered content returned for hippocampus")
		test_passed = false
		return
	
	# Check that filtered content has metadata
	if not filtered_content.has("_metadata"):
		print("  ❌ Filtered content missing metadata")
		test_passed = false
		return
	
	var metadata = filtered_content._metadata
	if not metadata.has("learning_level"):
		print("  ❌ Metadata missing learning level")
		test_passed = false
		return
	
	# Check that essential fields are present
	if not filtered_content.has("displayName"):
		print("  ❌ Filtered content missing displayName")
		test_passed = false
		return
	
	print("  ✓ Content filtering test passed")

func test_learning_level_integration():
	print("\n→ Testing learning level integration...")
	
	if not setup_manager():
		print("  ❌ Failed to access LearningContentManager")
		test_passed = false
		return
	
	# Wait for services to be ready
	await get_tree().process_frame
	
	# Test different learning levels
	for level in [UIAdaptationManager.LearningLevel.BEGINNER, UIAdaptationManager.LearningLevel.INTERMEDIATE, UIAdaptationManager.LearningLevel.ADVANCED]:
		# Set learning level via UIAdaptationManager
		if UIAdaptationManager:
			UIAdaptationManager.set_learning_level(level)
			await get_tree().process_frame
		
		# Get content for current level
		var content = learning_content_manager.get_filtered_content("hippocampus")
		if content.is_empty():
			print("  ❌ No content for level " + str(level))
			test_passed = false
			return
		
		# Check metadata reflects current level
		var metadata = content.get("_metadata", {})
		if metadata.get("learning_level", -1) != level:
			print("  ❌ Content metadata doesn't match level " + str(level))
			test_passed = false
			return
	
	print("  ✓ Learning level integration test passed")

func test_progressive_disclosure():
	print("\n→ Testing progressive disclosure...")
	
	if not setup_manager():
		print("  ❌ Failed to access LearningContentManager")
		test_passed = false
		return
	
	# Test different disclosure levels
	for disclosure_level in [LearningContentManager.DisclosureLevel.MINIMAL, LearningContentManager.DisclosureLevel.BASIC, LearningContentManager.DisclosureLevel.DETAILED, LearningContentManager.DisclosureLevel.COMPREHENSIVE]:
		var content = learning_content_manager.get_progressive_content("hippocampus", disclosure_level)
		
		if content.is_empty():
			print("  ❌ No content for disclosure level " + str(disclosure_level))
			test_passed = false
			return
		
		# Check metadata
		var metadata = content.get("_metadata", {})
		if not metadata.has("disclosure_level"):
			print("  ❌ Progressive content missing disclosure level metadata")
			test_passed = false
			return
		
		if metadata.disclosure_level != disclosure_level:
			print("  ❌ Disclosure level mismatch: expected " + str(disclosure_level) + ", got " + str(metadata.disclosure_level))
			test_passed = false
			return
	
	# Test advancing disclosure level
	var advanced_content = learning_content_manager.advance_disclosure_level("hippocampus")
	if advanced_content.is_empty():
		print("  ❌ Failed to advance disclosure level")
		test_passed = false
		return
	
	print("  ✓ Progressive disclosure test passed")

func test_content_metadata():
	print("\n→ Testing content metadata...")
	
	if not setup_manager():
		print("  ❌ Failed to access LearningContentManager")
		test_passed = false
		return
	
	# Wait for services to be ready
	await get_tree().process_frame
	
	# Test content metadata generation
	var metadata = learning_content_manager.get_content_metadata("hippocampus")
	
	if metadata.is_empty():
		print("  ❌ No metadata generated for hippocampus")
		test_passed = false
		return
	
	# Check required metadata fields
	var required_fields = ["total_fields", "available_at_beginner", "available_at_intermediate", "available_at_advanced", "field_priorities"]
	for field in required_fields:
		if not metadata.has(field):
			print("  ❌ Metadata missing field: " + field)
			test_passed = false
			return
	
	# Check that counts make sense
	if metadata.available_at_beginner > metadata.available_at_intermediate:
		print("  ❌ Beginner should have fewer or equal fields than intermediate")
		test_passed = false
		return
	
	if metadata.available_at_intermediate > metadata.available_at_advanced:
		print("  ❌ Intermediate should have fewer or equal fields than advanced")
		test_passed = false
		return
	
	print("  ✓ Content metadata test passed")

func test_field_availability():
	print("\n→ Testing field availability...")
	
	if not setup_manager():
		print("  ❌ Failed to access LearningContentManager")
		test_passed = false
		return
	
	# Test field availability at different levels
	var essential_field = "displayName"
	var advanced_field = "connections"
	
	# Essential field should be available at all levels
	for level in [UIAdaptationManager.LearningLevel.BEGINNER, UIAdaptationManager.LearningLevel.INTERMEDIATE, UIAdaptationManager.LearningLevel.ADVANCED]:
		if not learning_content_manager.is_field_available_at_level(essential_field, level):
			print("  ❌ Essential field '" + essential_field + "' not available at level " + str(level))
			test_passed = false
			return
	
	# Advanced field should not be available at beginner level
	if learning_content_manager.is_field_available_at_level(advanced_field, UIAdaptationManager.LearningLevel.BEGINNER):
		print("  ❌ Advanced field '" + advanced_field + "' should not be available at beginner level")
		test_passed = false
		return
	
	# Test field priorities
	var essential_priority = learning_content_manager.get_field_priority(essential_field)
	var advanced_priority = learning_content_manager.get_field_priority(advanced_field)
	
	if essential_priority >= advanced_priority:
		print("  ❌ Essential field should have higher priority (lower number) than advanced field")
		test_passed = false
		return
	
	print("  ✓ Field availability test passed")

func test_content_complexity_description():
	print("\n→ Testing content complexity descriptions...")
	
	if not setup_manager():
		print("  ❌ Failed to access LearningContentManager")
		test_passed = false
		return
	
	# Test descriptions for all levels
	for level in [UIAdaptationManager.LearningLevel.BEGINNER, UIAdaptationManager.LearningLevel.INTERMEDIATE, UIAdaptationManager.LearningLevel.ADVANCED]:
		var description = learning_content_manager.get_content_complexity_description(level)
		
		if description == "" or description == "Unknown complexity level":
			print("  ❌ Invalid complexity description for level " + str(level))
			test_passed = false
			return
	
	print("  ✓ Content complexity description test passed")

func test_cache_functionality():
	print("\n→ Testing cache functionality...")
	
	if not setup_manager():
		print("  ❌ Failed to access LearningContentManager")
		test_passed = false
		return
	
	# Get content twice to test caching
	var content1 = learning_content_manager.get_filtered_content("hippocampus")
	var content2 = learning_content_manager.get_filtered_content("hippocampus")
	
	if content1.is_empty() or content2.is_empty():
		print("  ❌ Failed to get content for cache test")
		test_passed = false
		return
	
	# Content should be equivalent (cached)
	if content1.get("displayName", "") != content2.get("displayName", ""):
		print("  ❌ Cached content doesn't match original")
		test_passed = false
		return
	
	# Clear cache and test
	learning_content_manager.clear_content_cache()
	var content3 = learning_content_manager.get_filtered_content("hippocampus")
	
	if content3.is_empty():
		print("  ❌ Failed to get content after cache clear")
		test_passed = false
		return
	
	print("  ✓ Cache functionality test passed")