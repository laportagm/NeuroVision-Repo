extends GutTest

## Tests for Level 7: Assessment System Foundation

var assessment_service = null
var quiz_panel_scene = null
var quiz_panel = null

func before_each():
	# Get assessment service (it's an autoload)
	assessment_service = AssessmentService
	
	# Load quiz panel scene
	quiz_panel_scene = preload("res://src/ui/components/QuizPanel.tscn")
	quiz_panel = quiz_panel_scene.instantiate()
	add_child(quiz_panel)
	
	# Give time for initialization
	await wait_frames(5)

func after_each():
	if quiz_panel and is_instance_valid(quiz_panel):
		quiz_panel.queue_free()

# === CRITICAL: Assessment Data Loads ===

func test_assessment_file_exists():
	var path = "res://content/assessments/brain_structures_quiz.json"
	assert_true(FileAccess.file_exists(path), "Assessment data file must exist")

func test_assessments_load_successfully():
	# Service should be loaded as autoload
	assert_not_null(assessment_service, "Assessment service must be loaded")
	
	# Should have assessments loaded
	var thalamus_assessments = assessment_service.get_assessments_for_structure("thalamus")
	assert_gt(thalamus_assessments.size(), 0, "Should have thalamus assessments")

func test_all_structures_have_assessments():
	var structures = ["thalamus", "hippocampus", "striatum", "ventricles", "corpus_callosum"]
	
	for structure_id in structures:
		var assessments = assessment_service.get_assessments_for_structure(structure_id)
		assert_gt(assessments.size(), 0, "Structure '%s' should have assessments" % structure_id)

# === CRITICAL: Assessment Flow ===

func test_start_assessment():
	var result = assessment_service.start_assessment("thalamus_basics")
	assert_true(result, "Should successfully start assessment")
	
	var question = assessment_service.get_current_question()
	assert_not_null(question)
	assert_has(question, "question")
	assert_has(question, "options")
	assert_has(question, "type")
	assert_has(question, "question_number")
	assert_has(question, "total_questions")

func test_submit_answer():
	assessment_service.start_assessment("thalamus_basics")
	
	# Submit correct answer (1 = "Sensory relay station")
	var result = assessment_service.submit_answer(1)
	
	assert_has(result, "is_correct")
	assert_has(result, "correct_answer")
	assert_has(result, "explanation")
	assert_true(result.is_correct, "Answer should be correct")

func test_next_question():
	assessment_service.start_assessment("hippocampus_basics")
	
	# Answer first question
	assessment_service.submit_answer(2)
	
	# Move to next
	var has_next = assessment_service.next_question()
	assert_true(has_next, "Should have next question")
	
	var question = assessment_service.get_current_question()
	assert_eq(question.question_number, 2, "Should be on question 2")

func test_assessment_completion():
	var completed = false
	var final_score = {}
	
	# Connect to completion signal
	assessment_service.assessment_completed.connect(func(id, score):
		completed = true
		final_score = score
	)
	
	# Start small assessment
	assessment_service.start_assessment("ventricles_basics")
	
	# Answer all questions
	for i in range(3):
		assessment_service.submit_answer(0)  # Just answer something
		assessment_service.next_question()
	
	await wait_frames(2)
	
	assert_true(completed, "Assessment should complete")
	assert_has(final_score, "score")
	assert_has(final_score, "total")
	assert_has(final_score, "percentage")
	assert_has(final_score, "time_seconds")

# === Quiz Panel UI Tests ===

func test_quiz_panel_shows_assessment_list():
	var test_assessments = [
		{
			"id": "test1",
			"title": "Test Assessment 1",
			"difficulty": "beginner",
			"question_count": 5,
			"best_score": 80.0
		},
		{
			"id": "test2",
			"title": "Test Assessment 2",
			"difficulty": "intermediate",
			"question_count": 10,
			"best_score": 0.0
		}
	]
	
	quiz_panel.show_assessment_list(test_assessments)
	
	assert_true(quiz_panel.visible, "Quiz panel should be visible")
	assert_eq(quiz_panel._title_label.text, "Select an Assessment")

func test_quiz_panel_displays_question():
	var test_question = {
		"id": "q1",
		"type": "multiple_choice",
		"question": "What is the primary function of the thalamus?",
		"options": ["Motor control", "Sensory relay", "Memory", "Hormones"],
		"learning_objective": "Understand thalamic function",
		"question_number": 1,
		"total_questions": 3
	}
	
	quiz_panel.display_question(test_question)
	
	assert_true(quiz_panel.visible, "Panel should be visible")
	assert_true(quiz_panel._question_label.text.contains("What is the primary function"))
	assert_eq(quiz_panel._option_buttons.size(), 4, "Should have 4 option buttons")

func test_quiz_panel_shows_feedback():
	var correct_result = {
		"is_correct": true,
		"correct_answer": 1,
		"explanation": "The thalamus is the sensory relay station."
	}
	
	# First display a question
	quiz_panel.display_question({
		"type": "multiple_choice",
		"question": "Test",
		"options": ["A", "B", "C", "D"],
		"question_number": 1,
		"total_questions": 1
	})
	
	quiz_panel.show_feedback(correct_result)
	
	assert_true(quiz_panel._feedback_panel.visible, "Feedback should be visible")
	assert_true(quiz_panel._feedback_label.text.contains("Correct"))

func test_quiz_panel_shows_results():
	var score_data = {
		"score": 8,
		"total": 10,
		"percentage": 80.0,
		"time_seconds": 120.5,
		"difficulty": "intermediate"
	}
	
	quiz_panel.show_results(score_data)
	
	assert_eq(quiz_panel._title_label.text, "Quiz Complete!")
	assert_false(quiz_panel._button_container.visible, "Buttons should be hidden")

# === Progress Tracking ===

func test_get_assessment_progress():
	assessment_service.start_assessment("striatum_basics")
	
	var progress = assessment_service.get_progress()
	assert_has(progress, "current_question")
	assert_has(progress, "total_questions")
	assert_has(progress, "answered")
	assert_has(progress, "correct")
	assert_has(progress, "percentage")
	
	assert_eq(progress.current_question, 1)
	assert_eq(progress.answered, 0)

func test_structure_progress_tracking():
	# Get initial progress
	var progress = assessment_service.get_structure_progress("corpus_callosum")
	
	assert_has(progress, "assessments_completed")
	assert_has(progress, "total_questions_answered")
	assert_has(progress, "average_score")
	assert_has(progress, "mastery_level")

# === Question Types ===

func test_multiple_choice_questions():
	assessment_service.start_assessment("thalamus_basics")
	var question = assessment_service.get_current_question()
	
	assert_eq(question.type, "multiple_choice")
	assert_eq(question.options.size(), 4, "Should have 4 options")

func test_true_false_questions():
	assessment_service.start_assessment("thalamus_basics")
	
	# Skip to true/false question
	assessment_service.skip_question()
	assessment_service.skip_question()
	
	var question = assessment_service.get_current_question()
	assert_eq(question.type, "true_false")

# === Error Handling ===

func test_invalid_assessment_id():
	var result = assessment_service.start_assessment("nonexistent_assessment")
	assert_false(result, "Should fail to start invalid assessment")

func test_skip_question():
	assessment_service.start_assessment("hippocampus_basics")
	
	var skipped = assessment_service.skip_question()
	assert_true(skipped, "Should successfully skip")
	
	var progress = assessment_service.get_progress()
	assert_eq(progress.current_question, 2, "Should move to next question")
	assert_eq(progress.correct, 0, "Skipped questions count as incorrect")

# === Integration Tests ===

func test_full_quiz_flow():
	var assessment_id = "ventricles_basics"
	var completed = false
	
	# Connect completion signal
	assessment_service.assessment_completed.connect(func(id, score):
		if id == assessment_id:
			completed = true
	)
	
	# Start assessment
	assert_true(assessment_service.start_assessment(assessment_id))
	
	# Answer all questions
	for i in range(3):
		var question = assessment_service.get_current_question()
		assert_not_null(question)
		
		# Answer correctly based on our test data
		var answer = 2 if i == 0 else true if i == 2 else 2
		var result = assessment_service.submit_answer(answer)
		assert_has(result, "is_correct")
		
		if i < 2:
			assert_true(assessment_service.next_question())
		else:
			assessment_service.next_question()  # Triggers completion
	
	await wait_frames(2)
	
	assert_true(completed, "Assessment should complete")

func test_quiz_panel_integration():
	var selected_assessment = ""
	
	# Connect assessment selection signal
	quiz_panel.assessment_selected.connect(func(id):
		selected_assessment = id
	)
	
	# Show assessments for thalamus
	var assessments = assessment_service.get_assessments_for_structure("thalamus")
	quiz_panel.show_assessment_list(assessments)
	
	# Simulate clicking first assessment button
	if quiz_panel._options_container.get_child_count() > 0:
		var first_button = quiz_panel._options_container.get_child(0)
		first_button.pressed.emit()
		
		await wait_frames(2)
		
		assert_eq(selected_assessment, "thalamus_basics", "Should select assessment")

# === Performance ===

func test_assessment_loading_performance():
	var start_time = Time.get_ticks_usec()
	
	# Load assessments for all structures
	for structure in ["thalamus", "hippocampus", "striatum", "ventricles", "corpus_callosum"]:
		assessment_service.get_assessments_for_structure(structure)
	
	var elapsed = Time.get_ticks_usec() - start_time
	
	# Should be very fast (under 10ms total)
	assert_lt(elapsed, 10000, "Assessment loading should be fast")

func test_question_navigation_performance():
	assessment_service.start_assessment("hippocampus_basics")
	
	var start_time = Time.get_ticks_usec()
	
	# Navigate through questions quickly
	for i in range(3):
		assessment_service.get_current_question()
		assessment_service.submit_answer(0)
		assessment_service.next_question()
	
	var elapsed = Time.get_ticks_usec() - start_time
	
	# Should handle rapid navigation (under 5ms)
	assert_lt(elapsed, 5000, "Question navigation should be fast")