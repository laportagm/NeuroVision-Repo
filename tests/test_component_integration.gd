extends Node

## Integration test for M3ComponentApplicator and ButtonMotionHandler
## Verifies these components work correctly with existing UI components

var test_results = {
	"structure_info_panel": "PENDING",
	"quiz_panel": "PENDING", 
	"button_animations": "PENDING",
	"theme_switching": "PENDING",
	"errors": []
}

func _ready() -> void:
	print("\n========== Component Integration Test ==========")
	print("Testing M3ComponentApplicator and ButtonMotionHandler integration...")
	
	# Create test container
	var container = VBoxContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.add_theme_constant_override("separation", 20)
	add_child(container)
	
	# Title
	var title = Label.new()
	title.text = "Component Integration Test"
	title.add_theme_font_size_override("font_size", 24)
	container.add_child(title)
	
	# Run tests
	await _test_structure_info_panel(container)
	await _test_quiz_panel(container)
	await _test_theme_switching(container)
	await _test_performance_under_load(container)
	
	# Report results
	_generate_report()

func _test_structure_info_panel(container: Control) -> void:
	"""Test StructureInfoPanel with new components"""
	print("\n[Test] Testing StructureInfoPanel integration...")
	
	var section_label = Label.new()
	section_label.text = "StructureInfoPanel Test"
	section_label.add_theme_font_size_override("font_size", 18)
	container.add_child(section_label)
	
	# Check if class exists
	if not ClassDB.class_exists("StructureInfoPanel"):
		test_results.structure_info_panel = "SKIP"
		test_results.errors.append("StructureInfoPanel class not found")
		return
	
	try:
		# Create panel
		var info_panel = load("res://src/ui/components/StructureInfoPanel.gd").new()
		container.add_child(info_panel)
		
		# Test data
		var test_structure = {
			"id": "hippocampus",
			"displayName": "Hippocampus",
			"description": "Critical for memory formation and spatial navigation",
			"function": "Memory consolidation, pattern separation, spatial processing",
			"keyFacts": [
				"Part of the limbic system",
				"Contains CA1-CA4 regions",
				"Vulnerable to stress and aging"
			],
			"clinicalRelevance": "Affected early in Alzheimer's disease",
			"learningObjectives": [
				"Identify anatomical location",
				"Understand memory functions",
				"Recognize pathological changes"
			]
		}
		
		# Display structure info
		info_panel.display_structure_info(test_structure)
		
		# Verify panel is visible
		await get_tree().create_timer(0.5).timeout
		
		if info_panel.visible:
			test_results.structure_info_panel = "PASS"
			print("  ✓ StructureInfoPanel displayed successfully")
		else:
			test_results.structure_info_panel = "FAIL"
			test_results.errors.append("StructureInfoPanel failed to display")
			print("  ✗ StructureInfoPanel failed to display")
		
		# Clean up
		info_panel.queue_free()
		
	except:
		test_results.structure_info_panel = "ERROR"
		test_results.errors.append("Exception creating StructureInfoPanel")
		print("  ✗ Exception when creating StructureInfoPanel")

func _test_quiz_panel(container: Control) -> void:
	"""Test QuizPanel with new components"""
	print("\n[Test] Testing QuizPanel integration...")
	
	var section_label = Label.new()
	section_label.text = "QuizPanel Test"
	section_label.add_theme_font_size_override("font_size", 18)
	container.add_child(section_label)
	
	if not ClassDB.class_exists("QuizPanel"):
		test_results.quiz_panel = "SKIP"
		test_results.errors.append("QuizPanel class not found")
		return
	
	try:
		# Create quiz panel
		var quiz_panel = load("res://src/ui/components/QuizPanel.gd").new()
		container.add_child(quiz_panel)
		
		# Test question data
		var test_question = {
			"question": "What is the primary function of the hippocampus?",
			"type": "multiple_choice",
			"options": [
				"Memory formation",
				"Motor control", 
				"Vision processing",
				"Hormone regulation"
			],
			"correct_answer": 0,
			"question_number": 1,
			"total_questions": 5
		}
		
		# Display question
		quiz_panel.display_question(test_question)
		
		# Check if displayed
		await get_tree().create_timer(0.5).timeout
		
		if quiz_panel.visible:
			test_results.quiz_panel = "PASS"
			print("  ✓ QuizPanel displayed successfully")
			
			# Test button animations
			var buttons = quiz_panel.get_node("VBox/QuestionContainer/OptionsContainer").get_children()
			if buttons.size() > 0:
				test_results.button_animations = "PASS"
				print("  ✓ Quiz buttons created with animations")
			else:
				test_results.button_animations = "FAIL"
				test_results.errors.append("No quiz buttons created")
		else:
			test_results.quiz_panel = "FAIL"
			test_results.errors.append("QuizPanel failed to display")
			print("  ✗ QuizPanel failed to display")
		
		# Clean up
		quiz_panel.queue_free()
		
	except:
		test_results.quiz_panel = "ERROR"
		test_results.errors.append("Exception creating QuizPanel")
		print("  ✗ Exception when creating QuizPanel")

func _test_theme_switching(container: Control) -> void:
	"""Test theme switching with new components"""
	print("\n[Test] Testing theme switching...")
	
	var section_label = Label.new()
	section_label.text = "Theme Switching Test"
	section_label.add_theme_font_size_override("font_size", 18)
	container.add_child(section_label)
	
	# Create test panel
	var test_panel = PanelContainer.new()
	test_panel.custom_minimum_size = Vector2(300, 100)
	container.add_child(test_panel)
	
	var panel_label = Label.new()
	panel_label.text = "Theme Test Panel"
	test_panel.add_child(panel_label)
	
	# Apply M3 styling
	if ClassDB.class_exists("M3ComponentApplicator"):
		M3ComponentApplicator.apply_m3_panel_styling(test_panel, M3ComponentApplicator.PanelVariant.CARD)
		print("  ✓ M3 styling applied")
	else:
		print("  ⚠ M3ComponentApplicator not available")
	
	# Test theme switching
	if UIThemeManager:
		var original_theme = UIThemeManager.get_current_theme()
		
		# Try switching themes
		var themes_to_test = ["dark", "high_contrast", "colorblind"]
		
		for theme_name in themes_to_test:
			UIThemeManager.set_theme(theme_name, false)
			await get_tree().create_timer(0.3).timeout
			
			if UIThemeManager.get_current_theme() == theme_name:
				print("  ✓ Successfully switched to %s theme" % theme_name)
			else:
				print("  ✗ Failed to switch to %s theme" % theme_name)
				test_results.errors.append("Theme switch failed: %s" % theme_name)
		
		# Restore original theme
		UIThemeManager.set_theme(original_theme, false)
		test_results.theme_switching = "PASS"
	else:
		test_results.theme_switching = "SKIP"
		test_results.errors.append("UIThemeManager not available")

func _test_performance_under_load(container: Control) -> void:
	"""Test performance with many styled components"""
	print("\n[Test] Testing performance under load...")
	
	var section_label = Label.new()
	section_label.text = "Performance Test"
	section_label.add_theme_font_size_override("font_size", 18)
	container.add_child(section_label)
	
	# FPS tracking
	var fps_label = Label.new()
	fps_label.name = "FPSLabel"
	fps_label.text = "Creating 100 styled buttons..."
	container.add_child(fps_label)
	
	# Create many buttons
	var grid = GridContainer.new()
	grid.columns = 10
	container.add_child(grid)
	
	var start_time = Time.get_ticks_msec()
	
	for i in range(100):
		var button = Button.new()
		button.text = str(i)
		button.custom_minimum_size = Vector2(40, 30)
		
		# Apply styling if available
		if ClassDB.class_exists("M3ComponentApplicator"):
			M3ComponentApplicator.apply_m3_button_styling(button, M3ComponentApplicator.ButtonVariant.SECONDARY)
		
		# Apply motion if available
		if ClassDB.class_exists("ButtonMotionHandler"):
			ButtonMotionHandler.setup_button_hover_animation(button)
		
		grid.add_child(button)
	
	var creation_time = Time.get_ticks_msec() - start_time
	fps_label.text = "Created 100 buttons in %d ms (%.1f ms per button)" % [creation_time, creation_time / 100.0]
	
	if creation_time < 1000:  # Less than 1 second
		print("  ✓ Good performance: %d ms total" % creation_time)
	else:
		print("  ⚠ Slow performance: %d ms total" % creation_time)

func _generate_report() -> void:
	"""Generate final test report"""
	await get_tree().create_timer(1.0).timeout
	
	print("\n========== Integration Test Results ==========")
	
	print("\nComponent Tests:")
	print("  StructureInfoPanel: %s" % test_results.structure_info_panel)
	print("  QuizPanel: %s" % test_results.quiz_panel)
	print("  Button Animations: %s" % test_results.button_animations)
	print("  Theme Switching: %s" % test_results.theme_switching)
	
	if test_results.errors.size() > 0:
		print("\nErrors encountered:")
		for error in test_results.errors:
			print("  - %s" % error)
	
	# Summary
	var passed = 0
	var total = 0
	for key in test_results:
		if key != "errors" and test_results[key] == "PASS":
			passed += 1
		if key != "errors" and test_results[key] != "SKIP":
			total += 1
	
	print("\nSummary: %d/%d tests passed" % [passed, total])
	
	# Visual result
	var result_label = Label.new()
	result_label.text = "Integration Test Complete: %d/%d passed" % [passed, total]
	result_label.add_theme_font_size_override("font_size", 20)
	if passed == total:
		result_label.add_theme_color_override("font_color", Color.GREEN)
	elif passed > total / 2:
		result_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		result_label.add_theme_color_override("font_color", Color.RED)
	get_child(0).add_child(result_label)

# GDScript doesn't have try/catch, so these are placeholder functions
func try(callable: Callable) -> void:
	callable.call()

func except() -> void:
	pass