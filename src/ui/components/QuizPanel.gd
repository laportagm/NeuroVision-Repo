extends Panel

## Educational quiz interface panel

signal answer_submitted(answer: Variant)
signal next_question_requested()
signal quiz_closed()
signal assessment_selected(assessment_id: String)

# === CONSTANTS ===
const PANEL_WIDTH = 500
const PANEL_HEIGHT = 600
const FEEDBACK_DISPLAY_TIME = 2.0

# === NODES ===
@onready var title_label: Label = $VBox/Header/TitleLabel
@onready var progress_bar: ProgressBar = $VBox/Header/ProgressBar
@onready var progress_label: Label = $VBox/Header/ProgressLabel
@onready var question_container: VBoxContainer = $VBox/QuestionContainer
@onready var question_label: RichTextLabel = $VBox/QuestionContainer/QuestionLabel
@onready var options_container: VBoxContainer = $VBox/QuestionContainer/OptionsContainer
@onready var feedback_panel: Panel = $VBox/FeedbackPanel
@onready var feedback_label: RichTextLabel = $VBox/FeedbackPanel/FeedbackLabel
@onready var button_container: HBoxContainer = $VBox/ButtonContainer
@onready var submit_button: Button = $VBox/ButtonContainer/SubmitButton
@onready var next_button: Button = $VBox/ButtonContainer/NextButton
@onready var skip_button: Button = $VBox/ButtonContainer/SkipButton
@onready var close_button: Button = $VBox/Header/CloseButton

# === PRIVATE VARIABLES ===
var _current_question: Dictionary = {}
var _selected_answer: Variant = null
var _option_buttons: Array[Button] = []
var _is_answered: bool = false

# === PUBLIC METHODS ===

func _ready() -> void:
	"""Initialize the quiz panel"""
	_setup_ui()
	_connect_signals()
	
	# Enable keyboard input processing
	set_process_unhandled_key_input(true)
	focus_mode = Control.FOCUS_ALL
	
	hide()

func show_assessment_list(assessments: Array) -> void:
	"""Show list of available assessments"""
	clear_quiz()
	title_label.text = "Select an Assessment"
	progress_bar.hide()
	progress_label.hide()
	feedback_panel.hide()
	button_container.hide()
	
	# Create assessment buttons
	var first_button = null
	var prev_button = null
	
	for i in range(assessments.size()):
		var assessment = assessments[i]
		var btn = Button.new()
		btn.text = "%s (%s)" % [assessment.title, assessment.difficulty]
		btn.add_theme_font_size_override("font_size", 16)
		
		# Show best score if available
		if assessment.best_score > 0:
			btn.text += " - Best: %.0f%%" % assessment.best_score
		
		# Enable keyboard navigation
		btn.focus_mode = Control.FOCUS_ALL
		btn.add_theme_stylebox_override("focus", _create_focus_style())
		
		# Add number shortcuts for first 9 assessments
		if i < 9:
			var shortcut = Shortcut.new()
			var key = InputEventKey.new()
			key.keycode = KEY_1 + i
			shortcut.events = [key]
			btn.shortcut = shortcut
		
		# Set focus neighbors
		if prev_button:
			btn.focus_neighbor_top = prev_button.get_path()
			prev_button.focus_neighbor_bottom = btn.get_path()
		
		btn.pressed.connect(func(): _on_assessment_selected(assessment.id))
		options_container.add_child(btn)
		
		if not first_button:
			first_button = btn
		prev_button = btn
	
	# Focus first assessment
	if first_button:
		first_button.call_deferred("grab_focus")
	
	show()

func display_question(question_data: Dictionary) -> void:
	"""Display a quiz question"""
	_current_question = question_data
	_selected_answer = null
	_is_answered = false
	
	# Update UI
	title_label.text = "Brain Structure Quiz"
	question_label.text = "[b]Question %d of %d[/b]\n\n%s" % [
		question_data.question_number,
		question_data.total_questions,
		question_data.question
	]
	
	# Update progress
	var progress = float(question_data.question_number - 1) / float(question_data.total_questions)
	progress_bar.value = progress * 100
	progress_label.text = "%d / %d" % [question_data.question_number, question_data.total_questions]
	progress_bar.show()
	progress_label.show()
	
	# Clear previous options
	_clear_options()
	
	# Create option buttons based on question type
	match question_data.type:
		"multiple_choice":
			_create_multiple_choice_options(question_data.options)
		"true_false":
			_create_true_false_options()
	
	# Show/hide buttons
	submit_button.disabled = true
	submit_button.show()
	next_button.hide()
	skip_button.show()
	button_container.show()
	feedback_panel.hide()
	
	show()

func show_feedback(result: Dictionary) -> void:
	"""Show feedback for the submitted answer"""
	_is_answered = true
	
	# Update button states
	submit_button.hide()
	next_button.show()
	skip_button.hide()
	
	# Disable option buttons
	for btn in _option_buttons:
		btn.disabled = true
	
	# Show feedback
	var feedback_text = ""
	if result.is_correct:
		feedback_text = "[color=green][b]Correct![/b][/color]\n\n"
		feedback_panel.modulate = Color(0.3, 0.8, 0.3, 0.9)
	else:
		feedback_text = "[color=red][b]Incorrect[/b][/color]\n\n"
		feedback_panel.modulate = Color(0.8, 0.3, 0.3, 0.9)
		
		# Show correct answer
		if _current_question.type == "multiple_choice":
			var correct_option = _current_question.options[result.correct_answer]
			feedback_text += "Correct answer: [b]%s[/b]\n\n" % correct_option
		elif _current_question.type == "true_false":
			feedback_text += "Correct answer: [b]%s[/b]\n\n" % str(result.correct_answer)
	
	feedback_text += result.explanation
	feedback_label.text = feedback_text
	feedback_panel.show()

func show_results(score_data: Dictionary) -> void:
	"""Show final quiz results"""
	clear_quiz()
	title_label.text = "Quiz Complete!"
	
	# Create results display
	var results_label = RichTextLabel.new()
	results_label.bbcode_enabled = true
	results_label.fit_content = true
	
	var grade = _calculate_grade(score_data.percentage)
	var grade_color = _get_grade_color(grade)
	
	results_label.text = "[center][b]Your Results[/b][/center]\n\n"
	results_label.text += "Score: [b]%d / %d[/b]\n" % [score_data.score, score_data.total]
	results_label.text += "Percentage: [color=%s][b]%.1f%%[/b][/color]\n" % [grade_color, score_data.percentage]
	results_label.text += "Grade: [color=%s][b]%s[/b][/color]\n" % [grade_color, grade]
	results_label.text += "Time: %.1f seconds\n\n" % score_data.time_seconds
	
	# Add encouraging message
	if score_data.percentage >= 90:
		results_label.text += "[color=green]Excellent work! You've mastered this material.[/color]"
	elif score_data.percentage >= 70:
		results_label.text += "[color=yellow]Good job! Keep practicing to improve further.[/color]"
	else:
		results_label.text += "[color=orange]Keep studying! Review the material and try again.[/color]"
	
	question_container.add_child(results_label)
	
	# Show close button only
	button_container.hide()
	feedback_panel.hide()
	progress_bar.hide()
	progress_label.hide()

func clear_quiz() -> void:
	"""Clear all quiz content"""
	_clear_options()
	for child in question_container.get_children():
		if child != question_label:
			child.queue_free()
	question_label.text = ""
	feedback_panel.hide()

# === PRIVATE METHODS ===

func _setup_ui() -> void:
	"""Setup the UI components"""
	custom_minimum_size = Vector2(PANEL_WIDTH, PANEL_HEIGHT)
	
	# Style the panel
	add_theme_stylebox_override("panel", _create_panel_style())
	
	# Style buttons
	submit_button.text = "Submit Answer"
	submit_button.add_theme_color_override("font_color", Color.WHITE)
	submit_button.focus_mode = Control.FOCUS_ALL
	submit_button.add_theme_stylebox_override("focus", _create_focus_style())
	
	next_button.text = "Next Question"
	next_button.add_theme_color_override("font_color", Color.WHITE)
	next_button.focus_mode = Control.FOCUS_ALL
	next_button.add_theme_stylebox_override("focus", _create_focus_style())
	
	skip_button.text = "Skip"
	skip_button.focus_mode = Control.FOCUS_ALL
	skip_button.add_theme_stylebox_override("focus", _create_focus_style())
	
	# Close button
	close_button.focus_mode = Control.FOCUS_ALL
	close_button.add_theme_stylebox_override("focus", _create_focus_style())
	
	# Progress bar styling
	progress_bar.add_theme_stylebox_override("fill", _create_progress_style())

func _create_panel_style() -> StyleBox:
	"""Create panel style"""
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	style.border_color = Color.CYAN
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(20)
	return style

func _create_progress_style() -> StyleBox:
	"""Create progress bar style"""
	var style = StyleBoxFlat.new()
	style.bg_color = Color.CYAN
	style.set_corner_radius_all(3)
	return style

func _create_focus_style() -> StyleBox:
	"""Create focus indicator style for accessibility"""
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.3, 0.3)
	style.border_color = Color.CYAN
	style.set_border_width_all(3)
	style.set_corner_radius_all(5)
	style.set_content_margin_all(8)
	return style

func _connect_signals() -> void:
	"""Connect UI signals"""
	submit_button.pressed.connect(_on_submit_pressed)
	next_button.pressed.connect(_on_next_pressed)
	skip_button.pressed.connect(_on_skip_pressed)
	close_button.pressed.connect(_on_close_pressed)

func _create_multiple_choice_options(options: Array) -> void:
	"""Create multiple choice option buttons"""
	var button_group = ButtonGroup.new()
	
	for i in range(options.size()):
		var btn = Button.new()
		btn.text = "%s. %s" % [char(65 + i), options[i]]  # A, B, C, D...
		btn.add_theme_font_size_override("font_size", 14)
		btn.toggle_mode = true
		btn.button_group = button_group
		
		# Enable keyboard navigation
		btn.focus_mode = Control.FOCUS_ALL
		btn.add_theme_stylebox_override("focus", _create_focus_style())
		
		# Add number key shortcuts (1-4 for typical quiz)
		if i < 9:  # Support keys 1-9
			var shortcut = Shortcut.new()
			var key = InputEventKey.new()
			key.keycode = KEY_1 + i
			shortcut.events = [key]
			btn.shortcut = shortcut
		
		# Store button first
		options_container.add_child(btn)
		_option_buttons.append(btn)
		
		# Set focus neighbors for Tab navigation after adding to tree
		if i > 0 and _option_buttons.size() > 1:
			var prev_btn = _option_buttons[i-1]
			btn.focus_neighbor_top = prev_btn.get_path()
			prev_btn.focus_neighbor_bottom = btn.get_path()
		
		btn.toggled.connect(func(pressed): 
			if pressed: 
				_on_option_selected(i)
				# Announce selection for accessibility
				if has_node("/root/AccessibilityManager") and AccessibilityManager.is_screen_reader_enabled():
					AccessibilityManager.announce("Selected option %s" % btn.text)
		)
	
	# Connect last option to submit button
	if _option_buttons.size() > 0:
		var last_btn = _option_buttons[-1]
		last_btn.focus_neighbor_bottom = submit_button.get_path()
		submit_button.focus_neighbor_top = last_btn.get_path()
		
		# Set focus to first option when question is displayed
		_option_buttons[0].call_deferred("grab_focus")

func _create_true_false_options() -> void:
	"""Create true/false option buttons"""
	var options = ["True", "False"]
	var button_group = ButtonGroup.new()
	
	for i in range(options.size()):
		var btn = Button.new()
		btn.text = options[i]
		btn.add_theme_font_size_override("font_size", 16)
		btn.toggle_mode = true
		btn.button_group = button_group
		
		# Enable keyboard navigation
		btn.focus_mode = Control.FOCUS_ALL
		btn.add_theme_stylebox_override("focus", _create_focus_style())
		
		# Add T/F keyboard shortcuts
		var shortcut = Shortcut.new()
		var key = InputEventKey.new()
		key.keycode = KEY_T if i == 0 else KEY_F
		shortcut.events = [key]
		btn.shortcut = shortcut
		
		# Also add number keys 1/2
		var num_shortcut = Shortcut.new()
		var num_key = InputEventKey.new()
		num_key.keycode = KEY_1 + i
		num_shortcut.events = [num_key]
		# Combine shortcuts
		btn.shortcut = shortcut
		
		# Add to scene first
		options_container.add_child(btn)
		_option_buttons.append(btn)
		
		# Set focus neighbors after adding to tree
		if i == 1 and _option_buttons.size() > 1:
			var prev_btn = _option_buttons[0]
			btn.focus_neighbor_top = prev_btn.get_path()
			prev_btn.focus_neighbor_bottom = btn.get_path()
		
		btn.toggled.connect(func(pressed): 
			if pressed: 
				_on_option_selected(i == 0)  # True = true, False = false
				# Announce selection
				if has_node("/root/AccessibilityManager") and AccessibilityManager.is_screen_reader_enabled():
					AccessibilityManager.announce("Selected %s" % options[i])
		)
	
	# Connect last option to submit button and set initial focus
	if _option_buttons.size() > 0:
		var last_btn = _option_buttons[-1]
		last_btn.focus_neighbor_bottom = submit_button.get_path()
		submit_button.focus_neighbor_top = last_btn.get_path()
		
		# Set focus to first option
		_option_buttons[0].call_deferred("grab_focus")

func _clear_options() -> void:
	"""Clear all option buttons"""
	for btn in _option_buttons:
		btn.queue_free()
	_option_buttons.clear()

func _on_option_selected(value: Variant) -> void:
	"""Handle option selection"""
	_selected_answer = value
	submit_button.disabled = false

func _on_submit_pressed() -> void:
	"""Handle submit button press"""
	if _selected_answer != null:
		answer_submitted.emit(_selected_answer)

func _on_next_pressed() -> void:
	"""Handle next button press"""
	next_question_requested.emit()

func _on_skip_pressed() -> void:
	"""Handle skip button press"""
	answer_submitted.emit(null)
	next_question_requested.emit()

func _on_close_pressed() -> void:
	"""Handle close button press"""
	hide()
	quiz_closed.emit()

func _on_assessment_selected(assessment_id: String) -> void:
	"""Handle assessment selection"""
	clear_quiz()
	assessment_selected.emit(assessment_id)

func _calculate_grade(percentage: float) -> String:
	"""Calculate letter grade from percentage"""
	if percentage >= 90:
		return "A"
	elif percentage >= 80:
		return "B"
	elif percentage >= 70:
		return "C"
	elif percentage >= 60:
		return "D"
	else:
		return "F"

func _get_grade_color(grade: String) -> String:
	"""Get color for grade display"""
	match grade:
		"A":
			return "#00ff00"
		"B":
			return "#88ff00"
		"C":
			return "#ffff00"
		"D":
			return "#ff8800"
		"F":
			return "#ff0000"
		_:
			return "#ffffff"

func _unhandled_key_input(event: InputEvent) -> void:
	"""Handle keyboard input for accessibility"""
	if not visible:
		return
		
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				# Close the panel
				_on_close_pressed()
				get_viewport().set_input_as_handled()
			KEY_ENTER, KEY_KP_ENTER:
				# Submit answer if button is visible and enabled
				if submit_button.visible and not submit_button.disabled:
					_on_submit_pressed()
					get_viewport().set_input_as_handled()
				elif next_button.visible:
					_on_next_pressed()
					get_viewport().set_input_as_handled()
			KEY_SPACE:
				# Alternative submit key
				if submit_button.visible and not submit_button.disabled and _selected_answer != null:
					_on_submit_pressed()
					get_viewport().set_input_as_handled()