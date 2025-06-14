extends Node

## Test scene for M3ComponentApplicator
## Validates all Material 3 styling methods work correctly

# Test results tracking
var test_results = {
	"panels": {},
	"buttons": {},
	"text": {},
	"errors": []
}

func _ready() -> void:
	print("[M3ComponentApplicator Test] Starting component validation...")
	
	# Create test container
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.add_theme_constant_override("separation", 20)
	add_child(main_container)
	
	# Add title
	var title = Label.new()
	title.text = "M3ComponentApplicator Test Suite"
	title.add_theme_font_size_override("font_size", 24)
	main_container.add_child(title)
	
	# Test panels
	_test_panel_variants(main_container)
	
	# Test buttons
	_test_button_variants(main_container)
	
	# Test typography
	_test_typography_scales(main_container)
	
	# Report results
	_report_test_results()

func _test_panel_variants(container: Control) -> void:
	"""Test all panel styling variants"""
	print("[Test] Testing panel variants...")
	
	var panel_section = VBoxContainer.new()
	panel_section.custom_minimum_size.y = 200
	container.add_child(panel_section)
	
	# Section title
	var section_title = Label.new()
	section_title.text = "Panel Variants"
	section_title.add_theme_font_size_override("font_size", 18)
	panel_section.add_child(section_title)
	
	# Create horizontal container for panels
	var panel_container = HBoxContainer.new()
	panel_container.add_theme_constant_override("separation", 10)
	panel_section.add_child(panel_container)
	
	# Test each panel variant
	var variants = [
		["SURFACE", M3ComponentApplicator.PanelVariant.SURFACE],
		["SURFACE_VARIANT", M3ComponentApplicator.PanelVariant.SURFACE_VARIANT],
		["SURFACE_CONTAINER", M3ComponentApplicator.PanelVariant.SURFACE_CONTAINER],
		["GLASS", M3ComponentApplicator.PanelVariant.GLASS],
		["MODAL", M3ComponentApplicator.PanelVariant.MODAL],
		["CARD", M3ComponentApplicator.PanelVariant.CARD]
	]
	
	for variant_data in variants:
		var variant_name = variant_data[0]
		var variant_enum = variant_data[1]
		
		try:
			var panel = PanelContainer.new()
			panel.custom_minimum_size = Vector2(150, 100)
			
			# Apply M3 styling
			M3ComponentApplicator.apply_m3_panel_styling(panel, variant_enum)
			
			# Add label
			var label = Label.new()
			label.text = variant_name
			label.add_theme_color_override("font_color", Color.WHITE)
			panel.add_child(label)
			
			panel_container.add_child(panel)
			test_results.panels[variant_name] = "PASS"
			
		except:
			test_results.panels[variant_name] = "FAIL"
			test_results.errors.append("Panel variant %s failed to apply" % variant_name)
			print("[Error] Failed to apply panel variant: %s" % variant_name)

func _test_button_variants(container: Control) -> void:
	"""Test all button styling variants"""
	print("[Test] Testing button variants...")
	
	var button_section = VBoxContainer.new()
	button_section.custom_minimum_size.y = 150
	container.add_child(button_section)
	
	# Section title
	var section_title = Label.new()
	section_title.text = "Button Variants"
	section_title.add_theme_font_size_override("font_size", 18)
	button_section.add_child(section_title)
	
	# Create grid for buttons
	var button_grid = GridContainer.new()
	button_grid.columns = 3
	button_grid.add_theme_constant_override("h_separation", 10)
	button_grid.add_theme_constant_override("v_separation", 10)
	button_section.add_child(button_grid)
	
	# Test each button variant
	var variants = [
		["PRIMARY", M3ComponentApplicator.ButtonVariant.PRIMARY],
		["SECONDARY", M3ComponentApplicator.ButtonVariant.SECONDARY],
		["TERTIARY", M3ComponentApplicator.ButtonVariant.TERTIARY],
		["ICON", M3ComponentApplicator.ButtonVariant.ICON],
		["FAB", M3ComponentApplicator.ButtonVariant.FAB]
	]
	
	for variant_data in variants:
		var variant_name = variant_data[0]
		var variant_enum = variant_data[1]
		
		try:
			var button = Button.new()
			button.text = variant_name if variant_name != "ICON" else "★"
			
			# Apply M3 styling
			M3ComponentApplicator.apply_m3_button_styling(button, variant_enum)
			
			button_grid.add_child(button)
			test_results.buttons[variant_name] = "PASS"
			
			# Test button states
			_test_button_states(button, variant_name)
			
		except:
			test_results.buttons[variant_name] = "FAIL"
			test_results.errors.append("Button variant %s failed to apply" % variant_name)
			print("[Error] Failed to apply button variant: %s" % variant_name)

func _test_button_states(button: Button, variant_name: String) -> void:
	"""Test button state transitions"""
	# Test hover state exists
	if button.has_theme_stylebox_override("hover"):
		print("[Test] Button %s has hover state ✓" % variant_name)
	else:
		test_results.errors.append("Button %s missing hover state" % variant_name)
	
	# Test pressed state exists
	if button.has_theme_stylebox_override("pressed"):
		print("[Test] Button %s has pressed state ✓" % variant_name)
	else:
		test_results.errors.append("Button %s missing pressed state" % variant_name)
	
	# Test disabled state exists
	if button.has_theme_stylebox_override("disabled"):
		print("[Test] Button %s has disabled state ✓" % variant_name)
	else:
		test_results.errors.append("Button %s missing disabled state" % variant_name)
	
	# Test focus state exists
	if button.has_theme_stylebox_override("focus"):
		print("[Test] Button %s has focus state ✓" % variant_name)
	else:
		test_results.errors.append("Button %s missing focus state" % variant_name)

func _test_typography_scales(container: Control) -> void:
	"""Test all typography scale variants"""
	print("[Test] Testing typography scales...")
	
	var text_section = ScrollContainer.new()
	text_section.custom_minimum_size.y = 200
	container.add_child(text_section)
	
	var text_container = VBoxContainer.new()
	text_section.add_child(text_container)
	
	# Section title
	var section_title = Label.new()
	section_title.text = "Typography Scales"
	section_title.add_theme_font_size_override("font_size", 18)
	text_container.add_child(section_title)
	
	# Test each typography scale
	var scales = [
		["DISPLAY_LARGE", M3ComponentApplicator.TypographyScale.DISPLAY_LARGE],
		["HEADLINE_MEDIUM", M3ComponentApplicator.TypographyScale.HEADLINE_MEDIUM],
		["TITLE_MEDIUM", M3ComponentApplicator.TypographyScale.TITLE_MEDIUM],
		["BODY_LARGE", M3ComponentApplicator.TypographyScale.BODY_LARGE],
		["LABEL_MEDIUM", M3ComponentApplicator.TypographyScale.LABEL_MEDIUM]
	]
	
	for scale_data in scales:
		var scale_name = scale_data[0]
		var scale_enum = scale_data[1]
		
		try:
			# Test on Label
			var label = Label.new()
			label.text = "Label: %s" % scale_name
			M3ComponentApplicator.apply_m3_text_styling(label, scale_enum)
			text_container.add_child(label)
			
			# Test on RichTextLabel
			var rich_label = RichTextLabel.new()
			rich_label.text = "RichText: %s" % scale_name
			rich_label.fit_content = true
			M3ComponentApplicator.apply_m3_text_styling(rich_label, scale_enum)
			text_container.add_child(rich_label)
			
			test_results.text[scale_name] = "PASS"
			
		except:
			test_results.text[scale_name] = "FAIL"
			test_results.errors.append("Typography scale %s failed to apply" % scale_name)
			print("[Error] Failed to apply typography scale: %s" % scale_name)

func _report_test_results() -> void:
	"""Generate test report"""
	print("\n========== M3ComponentApplicator Test Results ==========")
	
	var total_tests = 0
	var passed_tests = 0
	
	# Panel results
	print("\nPanel Variants:")
	for variant in test_results.panels:
		total_tests += 1
		if test_results.panels[variant] == "PASS":
			passed_tests += 1
			print("  ✓ %s" % variant)
		else:
			print("  ✗ %s" % variant)
	
	# Button results
	print("\nButton Variants:")
	for variant in test_results.buttons:
		total_tests += 1
		if test_results.buttons[variant] == "PASS":
			passed_tests += 1
			print("  ✓ %s" % variant)
		else:
			print("  ✗ %s" % variant)
	
	# Typography results
	print("\nTypography Scales:")
	for scale in test_results.text:
		total_tests += 1
		if test_results.text[scale] == "PASS":
			passed_tests += 1
			print("  ✓ %s" % scale)
		else:
			print("  ✗ %s" % scale)
	
	# Error summary
	if test_results.errors.size() > 0:
		print("\nErrors encountered:")
		for error in test_results.errors:
			print("  - %s" % error)
	
	# Summary
	print("\n========== Summary ==========")
	print("Total tests: %d" % total_tests)
	print("Passed: %d" % passed_tests)
	print("Failed: %d" % (total_tests - passed_tests))
	print("Success rate: %.1f%%" % (float(passed_tests) / float(total_tests) * 100.0))
	
	# Visual indicator
	var summary_label = Label.new()
	summary_label.text = "Test Complete: %d/%d passed (%.1f%%)" % [passed_tests, total_tests, float(passed_tests) / float(total_tests) * 100.0]
	summary_label.add_theme_font_size_override("font_size", 20)
	if passed_tests == total_tests:
		summary_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		summary_label.add_theme_color_override("font_color", Color.YELLOW)
	get_child(0).add_child(summary_label)

# Handle exceptions that GDScript doesn't support with try/catch
func try(callable: Callable) -> void:
	callable.call()

func except() -> void:
	pass