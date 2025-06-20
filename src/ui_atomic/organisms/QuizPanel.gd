class_name QuizPanel
extends Control

const ButtonMotionHandlerScript = preload("res://src/ui_atomic/atoms/buttons/ButtonMotionHandler.gd") # Validated path

## Enhanced educational quiz interface panel with gamification features

signal answer_submitted(answer: Variant)
signal next_question_requested()
signal quiz_closed()
signal assessment_selected(assessment_id: String)

# === CONSTANTS ===
const PANEL_WIDTH = 600
const PANEL_HEIGHT = 700

# Get timing values from M3 design tokens
static func _get_feedback_display_time() -> float:
	return M3DesignTokens.M3_DURATION["long2"] / 1000.0

static func _get_transition_duration() -> float:
	return M3DesignTokens.M3_DURATION["medium1"] / 1000.0

# === NODES ===
@onready var progress_bar: ProgressBar = $QuizMainContainer/QuizProgressHeader/QuizProgressBar
@onready var score_display: Label = $QuizMainContainer/QuizProgressHeader/QuizScoreDisplay
@onready var streak_number: Label = $QuizMainContainer/QuizProgressHeader/CorrectStreakCounter/StreakNumberLabel
@onready var streak_icon: TextureRect = $QuizMainContainer/QuizProgressHeader/CorrectStreakCounter/StreakIconDisplay
@onready var question_text: RichTextLabel = $QuizMainContainer/AssessmentQuestionArea/QuizQuestionText
@onready var question_image: TextureRect = $QuizMainContainer/AssessmentQuestionArea/AnatomicalQuestionImage
@onready var answer_container: VBoxContainer = $QuizMainContainer/AssessmentQuestionArea/MultipleChoiceAnswerContainer
@onready var correct_feedback: PanelContainer = $QuizMainContainer/EducationalFeedbackArea/CorrectAnswerFeedback
@onready var incorrect_feedback: PanelContainer = $QuizMainContainer/EducationalFeedbackArea/IncorrectAnswerFeedback
@onready var confidence_slider: HSlider = $QuizMainContainer/LearnerConfidenceArea/ConfidenceRatingSlider
@onready var submit_button: Button = $QuizMainContainer/QuizActionArea/SubmitAnswerButton
@onready var skip_button: Button = $QuizMainContainer/QuizActionArea/SkipQuestionButton
@onready var explanation_button: Button = $QuizMainContainer/QuizActionArea/ShowExplanationButton
@onready var close_button: Button = $QuizMainContainer/QuizActionArea/CloseQuizButton

# === PRIVATE VARIABLES ===
var _current_question: Dictionary = {}
var _selected_answer: Variant = null
var _option_buttons: Array[Button] = []
var _is_answered: bool = false

# Enhanced Gamification System
var _current_score: int = 0
var _streak_count: int = 0
var _total_questions: int = 0
var _question_number: int = 0
var _confidence_level: int = 3

# Performance metrics for pooling
var _pooling_metrics: Dictionary = {
	"buttons_created": 0,
	"buttons_reused": 0,
	"total_transitions": 0,
	"avg_transition_time": 0.0,
	"transition_times": []
}

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
	question_text.text = "[b]Select an Assessment[/b]"
	progress_bar.hide()
	correct_feedback.hide()
	incorrect_feedback.hide()
	
	# Create assessment buttons
	var first_button = null
	var prev_button = null
	
	for i in range(assessments.size()):
		var assessment = assessments[i]
		var btn = Button.new()
		btn.text = "%s (%s)" % [assessment.title, assessment.difficulty]
		
		# Apply M3 secondary button styling
		M3ComponentApplicator.apply_m3_button_styling(btn, M3ComponentApplicator.ButtonVariant.SECONDARY)
		
		# Show best score if available
		if assessment.best_score > 0:
			btn.text += " - Best: %.0f%%" % assessment.best_score
		
		# Enable keyboard navigation
		btn.focus_mode = Control.FOCUS_ALL
		btn.add_theme_stylebox_override("focus", _create_m3_focus_style())
		
		# Add motion effect
		if ClassDB.class_exists("ButtonMotionHandler"):
			ButtonMotionHandlerScript.setup_button_hover_animation(btn)
		
		# Add number shortcuts for first 9 assessments
		if i < 9:
			var shortcut = Shortcut.new()
			var key = InputEventKey.new()
			key.keycode = KEY_1 + i
			shortcut.events = [key]
			btn.shortcut = shortcut
		
		btn.pressed.connect(func(): _on_assessment_selected(assessment.id))
		answer_container.add_child(btn)
		
		# Set focus neighbors after adding to tree
		if prev_button:
			btn.focus_neighbor_top = prev_button.get_path()
			prev_button.focus_neighbor_bottom = btn.get_path()
		
		if not first_button:
			first_button = btn
		prev_button = btn
	
	# Focus first assessment
	if first_button:
		first_button.call_deferred("grab_focus")
	
	show()

func display_question(question_data: Dictionary) -> void:
	"""Display a quiz question with enhanced gamification"""
	_current_question = question_data
	_selected_answer = null
	_is_answered = false
	_question_number = question_data.get("question_number", 1)
	_total_questions = question_data.get("total_questions", 1)
	
	# Update enhanced question display
	question_text.text = "[b]Question %d of %d[/b]\n\n%s" % [
		_question_number,
		_total_questions,
		question_data.question
	]
	
	# Update gamification elements
	_update_progress_display()
	_update_score_display()
	_update_streak_display()
	
	# Handle question image if available
	if question_data.has("image_path"):
		question_image.visible = true
		# TODO: Load actual image
		question_image.modulate = M3DesignTokens.M3_COLORS["primary"]
	else:
		question_image.visible = false
	
	# Clear previous options
	_clear_options()
	
	# Create option buttons based on question type
	match question_data.type:
		"multiple_choice":
			_create_multiple_choice_options(question_data.options)
		"true_false":
			_create_true_false_options()
	
	# Reset UI state
	submit_button.disabled = true
	_hide_all_feedback()
	confidence_slider.value = 3
	_confidence_level = 3
	
	show()

func show_feedback(result: Dictionary) -> void:
	"""Show enhanced feedback with gamification elements"""
	_is_answered = true
	
	# Update score and streak
	if result.is_correct:
		_current_score += 1
		_streak_count += 1
		_show_correct_feedback(result)
	else:
		_streak_count = 0
		_show_incorrect_feedback(result)
	
	# Update displays
	_update_score_display()
	_update_streak_display()
	
	# Disable option buttons
	for btn in _option_buttons:
		btn.disabled = true

func _show_correct_feedback(result: Dictionary) -> void:
	"""Show correct answer feedback with positive reinforcement"""
	_hide_all_feedback()
	correct_feedback.visible = true
	
	var feedback_content = correct_feedback.get_node("CorrectContainer/FeedbackText")
	var feedback_text = "[color=green][b]Correct![/b][/color]\n\n"
	
	# Add confidence bonus message
	if _confidence_level >= 4:
		feedback_text += "[color=blue]Confidence Bonus! +5 points[/color]\n"
		_current_score += 5
	
	feedback_text += result.get("explanation", "Great job!")
	feedback_content.text = feedback_text
	
	# Style the feedback panel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.8, 0.2, 0.3)  # Green tint
	style.set_corner_radius_all(12)
	style.set_content_margin_all(16)
	correct_feedback.add_theme_stylebox_override("panel", style)

func _show_incorrect_feedback(result: Dictionary) -> void:
	"""Show incorrect answer feedback with educational support"""
	_hide_all_feedback()
	incorrect_feedback.visible = true
	
	var feedback_content = incorrect_feedback.get_node("IncorrectContainer/FeedbackText")
	var feedback_text = "[color=red][b]Incorrect[/b][/color]\n\n"
	
	# Show correct answer
	if _current_question.type == "multiple_choice":
		var correct_option = _current_question.options[result.correct_answer]
		feedback_text += "Correct answer: [b]%s[/b]\n\n" % correct_option
	elif _current_question.type == "true_false":
		feedback_text += "Correct answer: [b]%s[/b]\n\n" % str(result.correct_answer)
	
	feedback_text += result.get("explanation", "Keep studying!")
	feedback_content.text = feedback_text
	
	# Style the feedback panel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.8, 0.2, 0.2, 0.3)  # Red tint
	style.set_corner_radius_all(12)
	style.set_content_margin_all(16)
	incorrect_feedback.add_theme_stylebox_override("panel", style)

func _hide_all_feedback() -> void:
	"""Hide all feedback panels"""
	correct_feedback.visible = false
	incorrect_feedback.visible = false

func _update_progress_display() -> void:
	"""Update the progress bar and related displays"""
	var progress = float(_question_number - 1) / float(_total_questions)
	progress_bar.value = progress * 100

func _update_score_display() -> void:
	"""Update the score display"""
	score_display.text = "Score: %d" % _current_score

func _update_streak_display() -> void:
	"""Update the streak counter with visual effects"""
	streak_number.text = "Streak: %d" % _streak_count
	
	# Add visual flair for streaks
	if _streak_count >= 5:
		streak_number.add_theme_color_override("font_color", Color.GOLD)
		# TODO: Add streak icon when available
	elif _streak_count >= 3:
		streak_number.add_theme_color_override("font_color", Color.ORANGE)
	else:
		streak_number.add_theme_color_override("font_color", M3DesignTokens.M3_COLORS["on_surface"])

func show_results(score_data: Dictionary) -> void:
	"""Show final quiz results"""
	clear_quiz()
	question_text.text = "[center][b]Quiz Complete![/b][/center]"
	
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
	
	answer_container.add_child(results_label)
	
	# Hide unnecessary elements
	correct_feedback.hide()
	incorrect_feedback.hide()
	progress_bar.hide()

func clear_quiz() -> void:
	"""Clear all quiz content"""
	_clear_options()
	for child in answer_container.get_children():
		child.queue_free()
	question_text.text = ""
	correct_feedback.hide()
	incorrect_feedback.hide()

# === PRIVATE METHODS ===

func _setup_ui() -> void:
	"""Setup the UI components with Material 3 styling"""
	custom_minimum_size = Vector2(PANEL_WIDTH, PANEL_HEIGHT)
	
	# Apply M3 modal sheet styling
	M3ComponentApplicator.apply_m3_panel_styling(self, M3ComponentApplicator.PanelVariant.MODAL)
	
	# Style question text with M3 typography
	if question_text:
		question_text.add_theme_color_override("default_color", M3DesignTokens.get_color("on_surface"))
		question_text.add_theme_font_size_override("normal_font_size", M3DesignTokens.M3_TYPE_SCALE["body_large"]["size"])
	
	# Style buttons with M3
	submit_button.text = "Submit Answer"
	M3ComponentApplicator.apply_m3_button_styling(submit_button, M3ComponentApplicator.ButtonVariant.PRIMARY)
	submit_button.focus_mode = Control.FOCUS_ALL
	
	explanation_button.text = "Explanation"
	M3ComponentApplicator.apply_m3_button_styling(explanation_button, M3ComponentApplicator.ButtonVariant.SECONDARY)
	explanation_button.focus_mode = Control.FOCUS_ALL
	
	skip_button.text = "Skip"
	M3ComponentApplicator.apply_m3_button_styling(skip_button, M3ComponentApplicator.ButtonVariant.TERTIARY)
	skip_button.focus_mode = Control.FOCUS_ALL
	
	# Close button as icon button
	M3ComponentApplicator.apply_m3_button_styling(close_button, M3ComponentApplicator.ButtonVariant.ICON)
	close_button.focus_mode = Control.FOCUS_ALL
	
	# Add motion to buttons
	if ClassDB.class_exists("ButtonMotionHandler"):
		ButtonMotionHandlerScript.setup_button_hover_animation(submit_button)
		ButtonMotionHandlerScript.setup_button_hover_animation(explanation_button)
		ButtonMotionHandlerScript.setup_button_hover_animation(skip_button)
		ButtonMotionHandlerScript.setup_button_hover_animation(close_button)
	
	# Progress bar styling with M3
	_apply_m3_progress_styling()

func _apply_m3_progress_styling() -> void:
	"""Apply Material 3 styling to progress bar"""
	if not progress_bar:
		return
	
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = M3DesignTokens.get_color("surface_variant")
	bg_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["full"])
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = M3DesignTokens.get_color("primary")
	fill_style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["full"])
	
	progress_bar.add_theme_stylebox_override("background", bg_style)
	progress_bar.add_theme_stylebox_override("fill", fill_style)
	
	# Progress styling complete

func _create_m3_feedback_style(is_correct: bool) -> StyleBox:
	"""Create M3 feedback panel style"""
	var style = StyleBoxFlat.new()
	if is_correct:
		style.bg_color = M3DesignTokens.get_color("success_container")
	else:
		style.bg_color = M3DesignTokens.get_color("error_container")
	style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["medium"])
	style.set_content_margin_all(M3DesignTokens.M3_SPACING["medium"])
	return style

func _create_m3_focus_style() -> StyleBox:
	"""Create M3 focus indicator style for accessibility"""
	var style = StyleBoxFlat.new()
	style.bg_color = M3DesignTokens.get_color("transparent")
	style.border_color = M3DesignTokens.get_color("primary")
	style.set_border_width_all(M3DesignTokens.M3_ACCESSIBILITY["focus_indicator_width"])
	style.set_corner_radius_all(M3DesignTokens.M3_CORNER_RADIUS["small"])
	style.set_content_margin_all(M3DesignTokens.M3_SPACING["small"])
	return style

func _connect_signals() -> void:
	"""Connect UI signals"""
	submit_button.pressed.connect(_on_submit_pressed)
	skip_button.pressed.connect(_on_skip_pressed)
	explanation_button.pressed.connect(_on_explanation_pressed)
	close_button.pressed.connect(_on_close_pressed)
	confidence_slider.value_changed.connect(_on_confidence_changed)

func _create_multiple_choice_options(options: Array) -> void:
	"""Create multiple choice option buttons using object pooling for performance"""
	var start_time = Time.get_time_dict_from_system()
	var button_group = ButtonGroup.new()
	
	for i in range(options.size()):
		# Get button from pool instead of creating new one
		var btn: Button = null
		# Use has_singleton to check if autoload exists before accessing
		if Engine.has_singleton("UIPoolManager"):
			var pool_manager = Engine.get_singleton("UIPoolManager")
			if pool_manager and pool_manager._is_initialized:
				btn = pool_manager.get_object("quiz_answer_button")
				if btn:
					_pooling_metrics.buttons_reused += 1
				else:
					# Fallback to creating new button if pool fails
					btn = Button.new()
					_pooling_metrics.buttons_created += 1
					print("[QuizPanel] Pool failed, created new button")
			else:
				# Fallback if UIPoolManager not initialized
				btn = Button.new()
		else:
			# Fallback if UIPoolManager not available
			btn = Button.new()
			_pooling_metrics.buttons_created += 1
		
		if not btn:
			push_error("[QuizPanel] Failed to get button from pool or create new one")
			continue
		
		# Configure the button
		btn.text = "%s. %s" % [char(65 + i), options[i]]  # A, B, C, D...
		btn.toggle_mode = true
		btn.button_group = button_group
		
		# Apply M3 tertiary button styling for options
		M3ComponentApplicator.apply_m3_button_styling(btn, M3ComponentApplicator.ButtonVariant.TERTIARY)
		
		# Enable keyboard navigation
		btn.focus_mode = Control.FOCUS_ALL
		btn.add_theme_stylebox_override("focus", _create_m3_focus_style())
		
		# Add motion effect
		if ClassDB.class_exists("ButtonMotionHandler"):
			ButtonMotionHandlerScript.setup_button_hover_animation(btn)
		
		# Add number key shortcuts (1-4 for typical quiz)
		if i < 9:  # Support keys 1-9
			var shortcut = Shortcut.new()
			var key = InputEventKey.new()
			key.keycode = KEY_1 + i
			shortcut.events = [key]
			btn.shortcut = shortcut
		
		# Store button first
		answer_container.add_child(btn)
		_option_buttons.append(btn)
		
		# Set focus neighbors for Tab navigation after adding to tree
		if i > 0 and _option_buttons.size() > 1:
			var prev_btn = _option_buttons[i-1]
			btn.focus_neighbor_top = prev_btn.get_path()
			prev_btn.focus_neighbor_bottom = btn.get_path()
		
		# Connect signal for option selection
		btn.toggled.connect(func(pressed): 
			if pressed: 
				_on_option_selected(i)
				# Announce selection for accessibility
				# TODO: Re-enable when AccessibilityManager is available
				# if has_node("/root/AccessibilityManager") and AccessibilityManager.is_screen_reader_enabled():
				#	AccessibilityManager.announce("Selected option %s" % btn.text)
		)
	
	# Record performance metrics
	var end_time = Time.get_time_dict_from_system()
	var transition_time = _calculate_time_diff(start_time, end_time)
	_pooling_metrics.transition_times.append(transition_time)
	_pooling_metrics.total_transitions += 1
	
	# Calculate rolling average
	if _pooling_metrics.transition_times.size() > 10:
		_pooling_metrics.transition_times = _pooling_metrics.transition_times.slice(-10)
	
	var total_time = 0.0
	for time in _pooling_metrics.transition_times:
		total_time += time
	_pooling_metrics.avg_transition_time = total_time / _pooling_metrics.transition_times.size()
	
	print("[QuizPanel] Created %d options in %.2fms (avg: %.2fms)" % [
		options.size(), transition_time, _pooling_metrics.avg_transition_time
	])
	
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
		btn.add_theme_font_size_override("font_size", M3DesignTokens.M3_TYPE_SCALE["body_large"]["size"])
		btn.toggle_mode = true
		btn.button_group = button_group
		
		# Enable keyboard navigation
		btn.focus_mode = Control.FOCUS_ALL
		btn.add_theme_stylebox_override("focus", _create_m3_focus_style())
		
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
		answer_container.add_child(btn)
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
				# TODO: Re-enable when AccessibilityManager is available
				# if has_node("/root/AccessibilityManager") and AccessibilityManager.is_screen_reader_enabled():
				#	AccessibilityManager.announce("Selected %s" % options[i])
		)
	
	# Connect last option to submit button and set initial focus
	if _option_buttons.size() > 0:
		var last_btn = _option_buttons[-1]
		last_btn.focus_neighbor_bottom = submit_button.get_path()
		submit_button.focus_neighbor_top = last_btn.get_path()
		
		# Set focus to first option
		_option_buttons[0].call_deferred("grab_focus")

func _clear_options() -> void:
	"""Clear all option buttons using pool management for performance"""
	var start_time = Time.get_time_dict_from_system()
	
	for btn in _option_buttons:
		# Remove from container first
		if btn.get_parent():
			btn.get_parent().remove_child(btn)
		
		# Return to pool if possible, otherwise free
		if Engine.has_singleton("UIPoolManager") and btn.has_meta("pooled_object"):
			var pool_manager = Engine.get_singleton("UIPoolManager")
			if pool_manager and pool_manager._is_initialized:
				var pool_name = btn.get_meta("pool_name", "quiz_answer_button")
				if not pool_manager.return_object(pool_name, btn):
					# Return failed, free the object
					btn.queue_free()
					print("[QuizPanel] Failed to return button to pool, freeing")
			else:
				# Pool manager not initialized, free normally
				btn.queue_free()
		else:
			# Not a pooled object or no pool manager, free normally
			btn.queue_free()
	
	_option_buttons.clear()
	
	var end_time = Time.get_time_dict_from_system()
	var clear_time = _calculate_time_diff(start_time, end_time)
	print("[QuizPanel] Cleared options in %.2fms" % clear_time)

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

func _on_explanation_pressed() -> void:
	"""Handle explanation button press"""
	print("[QuizPanel] Explanation requested for current question")
	# TODO: Show detailed explanation

func _on_confidence_changed(value: float) -> void:
	"""Handle confidence slider value change"""
	_confidence_level = int(value)
	print("[QuizPanel] Confidence level set to: ", _confidence_level)

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
	# Use M3 semantic colors for grades
	match grade:
		"A":
			return M3DesignTokens.get_color("success").to_html()
		"B":
			return M3DesignTokens.get_color("tertiary").to_html()
		"C":
			return M3DesignTokens.get_color("warning").to_html()
		"D":
			return M3DesignTokens.get_color("warning_variant").to_html()
		"F":
			return M3DesignTokens.get_color("error").to_html()
		_:
			return M3DesignTokens.get_color("on_surface").to_html()

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
				elif explanation_button.visible:
					_on_explanation_pressed()
					get_viewport().set_input_as_handled()
			KEY_SPACE:
				# Alternative submit key
				if submit_button.visible and not submit_button.disabled and _selected_answer != null:
					_on_submit_pressed()
					get_viewport().set_input_as_handled()

# === PERFORMANCE METRICS ===

func get_pooling_metrics() -> Dictionary:
	"""Get detailed performance metrics for pooling system"""
	var reuse_ratio = 0.0
	var total_buttons = _pooling_metrics.buttons_created + _pooling_metrics.buttons_reused
	if total_buttons > 0:
		reuse_ratio = float(_pooling_metrics.buttons_reused) / float(total_buttons)
	
	return {
		"buttons_created": _pooling_metrics.buttons_created,
		"buttons_reused": _pooling_metrics.buttons_reused,
		"total_transitions": _pooling_metrics.total_transitions,
		"avg_transition_time_ms": _pooling_metrics.avg_transition_time,
		"reuse_ratio": reuse_ratio,
		"performance_improvement": reuse_ratio * 100.0,
		"memory_saved_estimate_kb": _pooling_metrics.buttons_reused * 10  # Rough estimate
	}

func log_performance_metrics() -> void:
	"""Log current performance metrics to console"""
	var metrics = get_pooling_metrics()
	print("[QuizPanel Performance Metrics]")
	print("  Buttons Created: %d" % metrics.buttons_created)
	print("  Buttons Reused: %d" % metrics.buttons_reused)
	print("  Reuse Ratio: %.1f%%" % (metrics.reuse_ratio * 100))
	print("  Avg Transition Time: %.2fms" % metrics.avg_transition_time_ms)
	print("  Total Transitions: %d" % metrics.total_transitions)
	print("  Estimated Memory Saved: %.1fKB" % metrics.memory_saved_estimate_kb)

func reset_performance_metrics() -> void:
	"""Reset performance tracking metrics"""
	_pooling_metrics = {
		"buttons_created": 0,
		"buttons_reused": 0,
		"total_transitions": 0,
		"avg_transition_time": 0.0,
		"transition_times": []
	}
	print("[QuizPanel] Performance metrics reset")

func _calculate_time_diff(start_time: Dictionary, end_time: Dictionary) -> float:
	## Calculate time difference in milliseconds
	var start_ms = start_time.hour * 3600000 + start_time.minute * 60000 + start_time.second * 1000
	var end_ms = end_time.hour * 3600000 + end_time.minute * 60000 + end_time.second * 1000
	return abs(end_ms - start_ms)

func _exit_tree() -> void:
	## Clean up resources to prevent memory leaks
	# Clean up option buttons
	for button in _option_buttons:
		if is_instance_valid(button):
			# Clear style overrides
			button.remove_theme_stylebox_override("normal")
			button.remove_theme_stylebox_override("hover")
			button.remove_theme_stylebox_override("pressed")
			button.remove_theme_stylebox_override("focus")
			button.queue_free()
	_option_buttons.clear()
	
	# Clean up assessment selection buttons
	for button in answer_container.get_children():
		if button is Button and button.pressed.is_connected(_on_assessment_selected):
			button.pressed.disconnect(_on_assessment_selected)
	
	# Disconnect main UI signals
	if submit_button and submit_button.pressed.is_connected(_on_submit_pressed):
		submit_button.pressed.disconnect(_on_submit_pressed)
	if skip_button and skip_button.pressed.is_connected(_on_skip_pressed):
		skip_button.pressed.disconnect(_on_skip_pressed)
	if explanation_button and explanation_button.pressed.is_connected(_on_explanation_pressed):
		explanation_button.pressed.disconnect(_on_explanation_pressed)
	if close_button and close_button.pressed.is_connected(_on_close_pressed):
		close_button.pressed.disconnect(_on_close_pressed)
	if confidence_slider and confidence_slider.value_changed.is_connected(_on_confidence_changed):
		confidence_slider.value_changed.disconnect(_on_confidence_changed)
	
	# Clear cached references
	_current_question = {}
	_selected_answer = null
