extends Node

## Simple tests for UIAdaptationManager functionality (without GUT framework)

var adaptation_manager: Node
var test_passed = true

func _ready():
	print("Starting UIAdaptationManager tests...")
	run_all_tests()

func run_all_tests():
	test_manager_initialization()
	test_learning_level_changes()
	test_layout_mode_changes() 
	test_content_hierarchy()
	test_layout_configuration()
	
	if test_passed:
		print("✅ All UIAdaptationManager tests passed!")
	else:
		print("❌ Some UIAdaptationManager tests failed!")

func setup_manager():
	if adaptation_manager:
		adaptation_manager.queue_free()
	adaptation_manager = UIAdaptationManager
	return adaptation_manager != null

func test_manager_initialization():
	print("\n→ Testing manager initialization...")
	
	if not setup_manager():
		print("  ❌ Failed to access UIAdaptationManager")
		test_passed = false
		return
	
	# In headless mode, auto-adaptation may change the layout mode
	# So we test that the manager exists and has valid enum values
	var current_mode = adaptation_manager.get_layout_mode()
	if current_mode < 0 or current_mode > 3:
		print("  ❌ Layout mode should be a valid enum value")
		test_passed = false
		return
	
	if adaptation_manager.get_learning_level() != adaptation_manager.LearningLevel.INTERMEDIATE:
		print("  ❌ Default learning level should be INTERMEDIATE")
		test_passed = false
		return
	
	print("  ✓ Manager initialization test passed")

func test_layout_mode_changes():
	print("\n→ Testing layout mode changes...")
	
	if not setup_manager():
		print("  ❌ Failed to access UIAdaptationManager")
		test_passed = false
		return
	
	var signal_emitted = false
	var received_mode = -1
	
	# Connect signal before making changes
	var signal_connection = adaptation_manager.layout_mode_changed.connect(
		func(mode): 
			signal_emitted = true
			received_mode = mode
	)
	
	# Disable auto-adaptation for predictable testing
	adaptation_manager.enable_auto_adaptation(false)
	
	# Test changing to PRESENTATION mode (should work in headless)
	var current_mode = adaptation_manager.get_layout_mode()
	adaptation_manager.set_layout_mode(adaptation_manager.LayoutMode.PRESENTATION, true)
	await get_tree().process_frame
	
	if adaptation_manager.get_layout_mode() != adaptation_manager.LayoutMode.PRESENTATION:
		print("  ❌ Layout mode should be PRESENTATION after setting")
		test_passed = false
		return
	
	if not signal_emitted:
		print("  ❌ layout_mode_changed signal should have been emitted")
		test_passed = false
		return
	
	if received_mode != adaptation_manager.LayoutMode.PRESENTATION:
		print("  ❌ Signal should contain correct mode value")
		test_passed = false
		return
	
	# Test that setting same mode doesn't emit signal
	signal_emitted = false
	adaptation_manager.set_layout_mode(adaptation_manager.LayoutMode.PRESENTATION)
	
	if signal_emitted:
		print("  ❌ Signal should not emit when setting same layout mode")
		test_passed = false
		return
	
	adaptation_manager.layout_mode_changed.disconnect(signal_connection)
	print("  ✓ Layout mode changes test passed")

func test_learning_level_changes():
	print("\n→ Testing learning level changes...")
	
	if not setup_manager():
		print("  ❌ Failed to access UIAdaptationManager")
		test_passed = false
		return
	
	var signal_emitted = false
	var received_level = -1
	
	# Connect signal before making changes
	var signal_connection = adaptation_manager.learning_level_changed.connect(
		func(level): 
			signal_emitted = true
			received_level = level
	)
	
	# Test changing to BEGINNER level (different from current INTERMEDIATE)
	adaptation_manager.set_learning_level(adaptation_manager.LearningLevel.BEGINNER)
	await get_tree().process_frame
	
	if adaptation_manager.get_learning_level() != adaptation_manager.LearningLevel.BEGINNER:
		print("  ❌ Learning level should be BEGINNER after setting")
		test_passed = false
		return
	
	if not signal_emitted:
		print("  ❌ learning_level_changed signal should have been emitted")
		test_passed = false
		return
	
	if received_level != adaptation_manager.LearningLevel.BEGINNER:
		print("  ❌ Signal should contain correct level value")
		test_passed = false
		return
	
	adaptation_manager.learning_level_changed.disconnect(signal_connection)
	print("  ✓ Learning level changes test passed")

func test_content_hierarchy():
	print("\n→ Testing content hierarchy...")
	
	if not setup_manager():
		print("  ❌ Failed to access UIAdaptationManager")
		test_passed = false
		return
	
	# Test BEGINNER hierarchy
	adaptation_manager.set_learning_level(adaptation_manager.LearningLevel.BEGINNER)
	var hierarchy = adaptation_manager.get_content_hierarchy()
	
	if not hierarchy.has("primary"):
		print("  ❌ Hierarchy should have 'primary' key")
		test_passed = false
		return
	
	if not hierarchy.has("hidden"):
		print("  ❌ Hierarchy should have 'hidden' key")
		test_passed = false
		return
	
	if hierarchy.max_info_items != 5:
		print("  ❌ Beginner level should have max 5 info items")
		test_passed = false
		return
	
	# Test content visibility
	if not adaptation_manager.should_show_content("structure_name"):
		print("  ❌ 'structure_name' should be visible for beginner")
		test_passed = false
		return
	
	if adaptation_manager.should_show_content("technical_details"):
		print("  ❌ 'technical_details' should be hidden for beginner")
		test_passed = false
		return
	
	# Test ADVANCED hierarchy
	adaptation_manager.set_learning_level(adaptation_manager.LearningLevel.ADVANCED)
	hierarchy = adaptation_manager.get_content_hierarchy()
	
	if hierarchy.max_info_items != -1:
		print("  ❌ Advanced level should have unlimited info items")
		test_passed = false
		return
	
	if hierarchy.hidden.size() != 0:
		print("  ❌ Advanced level should not hide any content")
		test_passed = false
		return
	
	print("  ✓ Content hierarchy test passed")

func test_layout_configuration():
	print("\n→ Testing layout configuration...")
	
	if not setup_manager():
		print("  ❌ Failed to access UIAdaptationManager")
		test_passed = false
		return
	
	# Disable auto-adaptation for predictable testing
	adaptation_manager.enable_auto_adaptation(false)
	
	# Test PRESENTATION configuration (works in all environments)
	adaptation_manager.set_layout_mode(adaptation_manager.LayoutMode.PRESENTATION, true)
	var config = adaptation_manager.get_layout_configuration()
	
	if not config.has("sidebar_width"):
		print("  ❌ Configuration should have 'sidebar_width' key")
		test_passed = false
		return
	
	if config.sidebar_width != 0:
		print("  ❌ PRESENTATION mode sidebar_width should be 0")
		test_passed = false
		return
	
	if not config.has("info_panel_position"):
		print("  ❌ Configuration should have 'info_panel_position' key")
		test_passed = false
		return
	
	if config.info_panel_position != "overlay_center":
		print("  ❌ PRESENTATION mode should use overlay_center panels")
		test_passed = false
		return
	
	# Test COMPACT configuration
	adaptation_manager.set_layout_mode(adaptation_manager.LayoutMode.COMPACT, true)
	config = adaptation_manager.get_layout_configuration()
	
	if config.sidebar_width != 280:
		print("  ❌ COMPACT mode sidebar_width should be 280")
		test_passed = false
		return
	
	if config.info_panel_position != "overlay":
		print("  ❌ COMPACT mode should use overlay panels")
		test_passed = false
		return
	
	print("  ✓ Layout configuration test passed")