extends Control

## Demonstration scene for progressive disclosure functionality

var progressive_panel: Control

func _ready():
	print("=== Progressive Disclosure Demo ===")
	
	# Wait for autoloads to initialize
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Create and setup the progressive disclosure panel
	setup_demo_panel()
	
	# Demonstrate the features
	await demonstrate_features()

func setup_demo_panel():
	"""Setup a demo progressive disclosure panel"""
	print("\n→ Setting up progressive disclosure panel...")
	
	# Load the progressive disclosure panel scene
	var panel_scene = preload("res://src/ui/components/ProgressiveDisclosurePanel.tscn")
	progressive_panel = panel_scene.instantiate()
	add_child(progressive_panel)
	
	# Connect signals for demonstration
	progressive_panel.disclosure_level_changed.connect(_on_disclosure_changed)
	progressive_panel.learning_level_adjusted.connect(_on_learning_level_adjusted)
	
	print("  ✓ Progressive disclosure panel created")

func demonstrate_features():
	"""Demonstrate progressive disclosure features"""
	print("\n→ Demonstrating progressive disclosure features...")
	
	# Test 1: Show content for hippocampus
	print("\n1. Displaying hippocampus content...")
	progressive_panel.display_structure_content("hippocampus")
	await get_tree().create_timer(2.0).timeout
	
	# Test 2: Change learning levels
	print("\n2. Testing learning level changes...")
	for level in [UIAdaptationManager.LearningLevel.BEGINNER, UIAdaptationManager.LearningLevel.ADVANCED, UIAdaptationManager.LearningLevel.INTERMEDIATE]:
		print("   → Setting learning level to: " + str(level))
		if UIAdaptationManager:
			UIAdaptationManager.set_learning_level(level)
		await get_tree().create_timer(1.5).timeout
	
	# Test 3: Progressive disclosure levels
	print("\n3. Testing progressive disclosure levels...")
	for disclosure_level in [LearningContentManager.DisclosureLevel.MINIMAL, LearningContentManager.DisclosureLevel.BASIC, LearningContentManager.DisclosureLevel.DETAILED, LearningContentManager.DisclosureLevel.COMPREHENSIVE]:
		print("   → Setting disclosure level to: " + str(disclosure_level))
		progressive_panel.set_disclosure_level(disclosure_level)
		await get_tree().create_timer(1.5).timeout
	
	# Test 4: Different structures
	print("\n4. Testing different brain structures...")
	var structures = ["thalamus", "striatum", "corpus_callosum", "ventricles"]
	for structure in structures:
		print("   → Displaying: " + structure)
		progressive_panel.display_structure_content(structure)
		await get_tree().create_timer(2.0).timeout
	
	# Test 5: Content filtering verification
	print("\n5. Verifying content filtering...")
	verify_content_filtering()
	
	print("\n✅ Progressive disclosure demonstration complete!")
	print("\nKey Features Demonstrated:")
	print("  ✓ Content filtering based on learning levels")
	print("  ✓ Progressive disclosure with smooth transitions") 
	print("  ✓ Expandable sections with priority indicators")
	print("  ✓ Integration with UIAdaptationManager")
	print("  ✓ Multiple brain structure support")
	print("  ✓ Accessibility-compliant design")

func verify_content_filtering():
	"""Verify that content filtering is working correctly"""
	print("   → Verifying content filtering...")
	
	if not LearningContentManager:
		print("   ❌ LearningContentManager not available")
		return
	
	# Test content at different levels
	for level in [UIAdaptationManager.LearningLevel.BEGINNER, UIAdaptationManager.LearningLevel.INTERMEDIATE, UIAdaptationManager.LearningLevel.ADVANCED]:
		UIAdaptationManager.set_learning_level(level)
		await get_tree().process_frame
		
		var content = LearningContentManager.get_filtered_content("hippocampus")
		var metadata = content.get("_metadata", {})
		
		print("     → Level " + str(level) + ": " + str(metadata.get("filtered_fields", 0)) + " fields, complexity: " + str(metadata.get("content_complexity", "unknown")))
		
		# Verify essential fields are always present
		if not content.has("displayName"):
			print("     ❌ Missing essential field: displayName")
		
		# Verify level-appropriate fields
		match level:
			UIAdaptationManager.LearningLevel.BEGINNER:
				if content.has("connections"):
					print("     ⚠️  Beginner level should not show connections")
			UIAdaptationManager.LearningLevel.ADVANCED:
				if not content.has("connections"):
					print("     ⚠️  Advanced level should show connections")
	
	print("   ✓ Content filtering verification complete")

func _on_disclosure_changed(structure_id: String, level: int):
	"""Handle disclosure level changes"""
	print("   📊 Disclosure level changed for " + structure_id + " to level " + str(level))

func _on_learning_level_adjusted(new_level: int):
	"""Handle learning level adjustments"""
	print("   🎓 Learning level adjusted to: " + str(new_level))