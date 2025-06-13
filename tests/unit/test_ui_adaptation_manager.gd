extends Node

## Tests for UIAdaptationManager functionality

var adaptation_manager: Node

func before_each():
	adaptation_manager = preload("res://src/autoload/UIAdaptationManager.gd").new()
	add_child(adaptation_manager)

func after_each():
	if adaptation_manager:
		adaptation_manager.queue_free()

# === INITIALIZATION TESTS ===

func test_manager_initializes_with_defaults():
	"""Test that UIAdaptationManager initializes with correct default values"""
	assert_not_null(adaptation_manager)
	assert_eq(adaptation_manager.get_layout_mode(), adaptation_manager.LayoutMode.STANDARD)
	assert_eq(adaptation_manager.get_learning_level(), adaptation_manager.LearningLevel.INTERMEDIATE)

func test_manager_has_required_signals():
	"""Test that all required signals are defined"""
	assert_true(adaptation_manager.has_signal("layout_mode_changed"))
	assert_true(adaptation_manager.has_signal("learning_level_changed"))
	assert_true(adaptation_manager.has_signal("content_hierarchy_updated"))
	assert_true(adaptation_manager.has_signal("ui_adaptation_applied"))

# === LAYOUT MODE TESTS ===

func test_set_layout_mode_compact():
	"""Test setting layout mode to COMPACT"""
	var signal_emitted = false
	var emitted_mode = -1
	
	adaptation_manager.layout_mode_changed.connect(func(mode):
		signal_emitted = true
		emitted_mode = mode
	)
	
	adaptation_manager.set_layout_mode(adaptation_manager.LayoutMode.COMPACT)
	
	assert_eq(adaptation_manager.get_layout_mode(), adaptation_manager.LayoutMode.COMPACT)
	assert_true(signal_emitted)
	assert_eq(emitted_mode, adaptation_manager.LayoutMode.COMPACT)

func test_set_layout_mode_standard():
	"""Test setting layout mode to STANDARD"""
	adaptation_manager.set_layout_mode(adaptation_manager.LayoutMode.STANDARD)
	assert_eq(adaptation_manager.get_layout_mode(), adaptation_manager.LayoutMode.STANDARD)

func test_set_layout_mode_presentation():
	"""Test setting layout mode to PRESENTATION"""
	adaptation_manager.set_layout_mode(adaptation_manager.LayoutMode.PRESENTATION)
	assert_eq(adaptation_manager.get_layout_mode(), adaptation_manager.LayoutMode.PRESENTATION)

func test_set_same_layout_mode_no_signal():
	"""Test that setting same layout mode doesn't emit signal"""
	var signal_count = 0
	
	adaptation_manager.layout_mode_changed.connect(func(mode):
		signal_count += 1
	)
	
	# Set to current mode (STANDARD by default)
	adaptation_manager.set_layout_mode(adaptation_manager.LayoutMode.STANDARD)
	assert_eq(signal_count, 0)
	
	# Set to different mode
	adaptation_manager.set_layout_mode(adaptation_manager.LayoutMode.COMPACT)
	assert_eq(signal_count, 1)
	
	# Set to same mode again
	adaptation_manager.set_layout_mode(adaptation_manager.LayoutMode.COMPACT)
	assert_eq(signal_count, 1)

# === LEARNING LEVEL TESTS ===

func test_set_learning_level_beginner():
	"""Test setting learning level to BEGINNER"""
	var signal_emitted = false
	var emitted_level = -1
	
	adaptation_manager.learning_level_changed.connect(func(level):
		signal_emitted = true
		emitted_level = level
	)
	
	adaptation_manager.set_learning_level(adaptation_manager.LearningLevel.BEGINNER)
	
	assert_eq(adaptation_manager.get_learning_level(), adaptation_manager.LearningLevel.BEGINNER)
	assert_true(signal_emitted)
	assert_eq(emitted_level, adaptation_manager.LearningLevel.BEGINNER)

func test_set_learning_level_advanced():
	"""Test setting learning level to ADVANCED"""
	adaptation_manager.set_learning_level(adaptation_manager.LearningLevel.ADVANCED)
	assert_eq(adaptation_manager.get_learning_level(), adaptation_manager.LearningLevel.ADVANCED)

func test_set_same_learning_level_no_signal():
	"""Test that setting same learning level doesn't emit signal"""
	var signal_count = 0
	
	adaptation_manager.learning_level_changed.connect(func(level):
		signal_count += 1
	)
	
	# Set to current level (INTERMEDIATE by default)
	adaptation_manager.set_learning_level(adaptation_manager.LearningLevel.INTERMEDIATE)
	assert_eq(signal_count, 0)
	
	# Set to different level
	adaptation_manager.set_learning_level(adaptation_manager.LearningLevel.BEGINNER)
	assert_eq(signal_count, 1)

# === CONTENT HIERARCHY TESTS ===

func test_content_hierarchy_beginner():
	"""Test content hierarchy for beginner level"""
	adaptation_manager.set_learning_level(adaptation_manager.LearningLevel.BEGINNER)
	var hierarchy = adaptation_manager.get_content_hierarchy()
	
	assert_true(hierarchy.has("primary"))
	assert_true(hierarchy.has("secondary"))
	assert_true(hierarchy.has("hidden"))
	assert_true(hierarchy.has("max_info_items"))
	
	# Beginner should have limited items
	assert_eq(hierarchy.max_info_items, 5)
	
	# Should hide technical details
	assert_true("technical_details" in hierarchy.hidden)

func test_content_hierarchy_advanced():
	"""Test content hierarchy for advanced level"""
	adaptation_manager.set_learning_level(adaptation_manager.LearningLevel.ADVANCED)
	var hierarchy = adaptation_manager.get_content_hierarchy()
	
	# Advanced should have unlimited items
	assert_eq(hierarchy.max_info_items, -1)
	
	# Should not hide anything
	assert_eq(hierarchy.hidden.size(), 0)

func test_should_show_content():
	"""Test content visibility logic"""
	adaptation_manager.set_learning_level(adaptation_manager.LearningLevel.BEGINNER)
	
	# Primary content should be shown
	assert_true(adaptation_manager.should_show_content("structure_name"))
	
	# Hidden content should not be shown
	assert_false(adaptation_manager.should_show_content("technical_details"))

func test_content_priority():
	"""Test content priority logic"""
	adaptation_manager.set_learning_level(adaptation_manager.LearningLevel.INTERMEDIATE)
	
	# Primary content should have priority 1
	assert_eq(adaptation_manager.get_content_priority("structure_name"), 1)
	
	# Secondary content should have priority 2
	assert_eq(adaptation_manager.get_content_priority("detailed_description"), 2)
	
	# Unknown content should have priority 4
	assert_eq(adaptation_manager.get_content_priority("unknown_content"), 4)

# === LAYOUT CONFIGURATION TESTS ===

func test_get_layout_configuration():
	"""Test getting layout configuration"""
	adaptation_manager.set_layout_mode(adaptation_manager.LayoutMode.COMPACT)
	var config = adaptation_manager.get_layout_configuration()
	
	assert_true(config.has("sidebar_width"))
	assert_true(config.has("info_panel_width"))
	assert_true(config.has("info_panel_position"))
	assert_eq(config.sidebar_width, 280)  # Compact mode value

func test_recommended_layout_mode():
	"""Test recommended layout mode logic"""
	# Test small screen
	adaptation_manager.adapt_to_screen_size(Vector2(500, 400))
	var recommended = adaptation_manager.get_recommended_layout_mode()
	assert_eq(recommended, adaptation_manager.LayoutMode.COMPACT)
	
	# Test large screen
	adaptation_manager.adapt_to_screen_size(Vector2(1600, 1200))
	recommended = adaptation_manager.get_recommended_layout_mode()
	assert_eq(recommended, adaptation_manager.LayoutMode.STANDARD)

# === UTILITY METHODS TESTS ===

func test_display_names():
	"""Test display name methods"""
	var layout_name = adaptation_manager.get_layout_mode_display_name(adaptation_manager.LayoutMode.COMPACT)
	assert_eq(layout_name, "Compact")
	
	var level_name = adaptation_manager.get_learning_level_display_name(adaptation_manager.LearningLevel.BEGINNER)
	assert_eq(level_name, "Beginner")

func test_descriptions():
	"""Test description methods"""
	var layout_desc = adaptation_manager.get_layout_mode_description(adaptation_manager.LayoutMode.PRESENTATION)
	assert_true(layout_desc.contains("presentation"))
	
	var level_desc = adaptation_manager.get_learning_level_description(adaptation_manager.LearningLevel.ADVANCED)
	assert_true(level_desc.contains("comprehensive"))

func test_adaptation_status():
	"""Test adaptation status reporting"""
	var status = adaptation_manager.get_adaptation_status()
	
	assert_true(status.has("layout_mode"))
	assert_true(status.has("learning_level"))
	assert_true(status.has("screen_size"))
	assert_true(status.has("auto_adapt_enabled"))

# === INTEGRATION TESTS ===

func test_content_hierarchy_signal_emission():
	"""Test that content hierarchy signal is emitted"""
	var signal_emitted = false
	var emitted_hierarchy = {}
	
	adaptation_manager.content_hierarchy_updated.connect(func(hierarchy):
		signal_emitted = true
		emitted_hierarchy = hierarchy
	)
	
	adaptation_manager.set_learning_level(adaptation_manager.LearningLevel.ADVANCED)
	
	assert_true(signal_emitted)
	assert_true(emitted_hierarchy.has("primary"))

func test_ui_adaptation_signal_emission():
	"""Test that UI adaptation signal is emitted"""
	var signal_emitted = false
	var adaptation_data = {}
	
	adaptation_manager.ui_adaptation_applied.connect(func(data):
		signal_emitted = true
		adaptation_data = data
	)
	
	adaptation_manager.set_layout_mode(adaptation_manager.LayoutMode.PRESENTATION)
	
	assert_true(signal_emitted)
	assert_true(adaptation_data.has("layout_mode"))
	assert_true(adaptation_data.has("configuration"))

func test_auto_adaptation():
	"""Test automatic adaptation functionality"""
	adaptation_manager.enable_auto_adaptation(true)
	
	# Small screen should trigger compact mode
	adaptation_manager.adapt_to_screen_size(Vector2(600, 400))
	assert_eq(adaptation_manager.get_layout_mode(), adaptation_manager.LayoutMode.COMPACT)

# === ERROR HANDLING TESTS ===

func test_invalid_enum_values():
	"""Test handling of invalid enum values"""
	# This should not crash the system
	var current_mode = adaptation_manager.get_layout_mode()
	adaptation_manager.set_layout_mode(999)  # Invalid enum value
	
	# Should maintain current mode
	assert_eq(adaptation_manager.get_layout_mode(), current_mode)

# === COMPREHENSIVE TEST ===

func test_full_workflow():
	"""Test complete workflow of UI adaptation"""
	var layout_changed = false
	var level_changed = false
	var hierarchy_updated = false
	
	# Connect to all signals
	adaptation_manager.layout_mode_changed.connect(func(mode): layout_changed = true)
	adaptation_manager.learning_level_changed.connect(func(level): level_changed = true)
	adaptation_manager.content_hierarchy_updated.connect(func(hierarchy): hierarchy_updated = true)
	
	# Change layout mode
	adaptation_manager.set_layout_mode(adaptation_manager.LayoutMode.COMPACT)
	assert_true(layout_changed)
	
	# Change learning level
	adaptation_manager.set_learning_level(adaptation_manager.LearningLevel.BEGINNER)
	assert_true(level_changed)
	assert_true(hierarchy_updated)
	
	# Verify final state
	assert_eq(adaptation_manager.get_layout_mode(), adaptation_manager.LayoutMode.COMPACT)
	assert_eq(adaptation_manager.get_learning_level(), adaptation_manager.LearningLevel.BEGINNER)
	
	# Verify content is properly filtered
	assert_false(adaptation_manager.should_show_content("technical_details"))
	assert_true(adaptation_manager.should_show_content("structure_name"))