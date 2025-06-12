extends Node

## Test script for verifying quiz panel keyboard accessibility

var quiz_panel: Panel

func _ready() -> void:
	print("\n=== QUIZ ACCESSIBILITY TEST ===\n")
	
	# Enable accessibility
	AccessibilityManager.enable_accessibility()
	print("✓ Accessibility enabled")
	
	# Create a quiz panel
	quiz_panel = preload("res://src/ui/components/QuizPanel.tscn").instantiate()
	add_child(quiz_panel)
	
	# Center the panel
	quiz_panel.position = Vector2(390, 60)
	
	# Wait a moment then show assessment list
	await get_tree().create_timer(0.5).timeout
	
	# Create mock assessments
	var assessments = [
		{
			"id": "test_1",
			"title": "Basic Brain Structures",
			"difficulty": "Easy",
			"best_score": 85.0
		},
		{
			"id": "test_2", 
			"title": "Advanced Neuroanatomy",
			"difficulty": "Hard",
			"best_score": 0.0
		},
		{
			"id": "test_3",
			"title": "Functional Areas",
			"difficulty": "Medium", 
			"best_score": 92.5
		}
	]
	
	print("\nShowing assessment list...")
	quiz_panel.show_assessment_list(assessments)
	
	print("\nKEYBOARD NAVIGATION TEST:")
	print("- Press TAB to navigate between assessments")
	print("- Press 1, 2, or 3 to quick-select an assessment")
	print("- Press ENTER to select focused assessment")
	print("- Press ESCAPE to close the panel")
	
	# Connect to assessment selection
	quiz_panel.assessment_selected.connect(_on_assessment_selected)
	quiz_panel.answer_submitted.connect(_on_answer_submitted)
	quiz_panel.quiz_closed.connect(_on_quiz_closed)

func _on_assessment_selected(assessment_id: String) -> void:
	print("\n✓ Assessment selected: " + assessment_id)
	
	# Show a sample question
	await get_tree().create_timer(0.5).timeout
	
	var question = {
		"id": "q1",
		"type": "multiple_choice",
		"question": "Which structure is responsible for memory formation?",
		"options": ["Hippocampus", "Cerebellum", "Medulla", "Thalamus"],
		"question_number": 1,
		"total_questions": 3,
		"learning_objective": "Identify key brain structures"
	}
	
	print("\nShowing question...")
	quiz_panel.display_question(question)
	
	print("\nQUESTION NAVIGATION TEST:")
	print("- Press TAB to navigate between options")
	print("- Press 1-4 to quick-select an answer")
	print("- Press ENTER or SPACE to submit")
	print("- Press ESCAPE to close")

func _on_answer_submitted(answer: Variant) -> void:
	print("\n✓ Answer submitted: " + str(answer))
	
	# Show feedback
	var result = {
		"is_correct": answer == 0,  # Hippocampus is correct
		"correct_answer": 0,
		"explanation": "The hippocampus is crucial for forming new memories and is part of the limbic system."
	}
	
	quiz_panel.show_feedback(result)

func _on_quiz_closed() -> void:
	print("\n✓ Quiz panel closed")
	print("\nTest complete! Accessibility features working.")
	
	# Exit after a moment
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()