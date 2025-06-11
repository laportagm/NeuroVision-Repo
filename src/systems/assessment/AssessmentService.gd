extends Node

## Service for managing educational assessments and quizzes

signal assessment_loaded(assessment_id: String)
signal question_answered(question_id: String, is_correct: bool)
signal assessment_completed(assessment_id: String, score: Dictionary)

# === CONSTANTS ===
const ASSESSMENT_FILE_PATH = "res://content/assessments/brain_structures_quiz.json"
const SAVE_FILE_PATH = "user://assessment_progress.save"

# === ASSESSMENT CLASSES ===
class Question extends RefCounted:
	var id: String = ""
	var type: String = ""  # multiple_choice, true_false, fill_blank, matching
	var question: String = ""
	var options: Array = []
	var correct_answer: Variant = null
	var explanation: String = ""
	var learning_objective: String = ""
	var user_answer: Variant = null
	var is_answered: bool = false
	var is_correct: bool = false

class Assessment extends RefCounted:
	var id: String = ""
	var structure_id: String = ""
	var title: String = ""
	var difficulty: String = ""
	var questions: Array[Question] = []
	var current_question_index: int = 0
	var start_time: float = 0.0
	var completion_time: float = 0.0
	var score: int = 0
	var total_score: int = 0

# === PRIVATE VARIABLES ===
var _assessments: Dictionary = {}  # id -> Assessment
var _current_assessment: Assessment = null
var _user_progress: Dictionary = {}  # structure_id -> progress data
var _is_loaded: bool = false

# === PUBLIC METHODS ===

func _ready() -> void:
	"""Initialize the assessment service"""
	_load_assessments()
	_load_user_progress()

func get_assessments_for_structure(structure_id: String) -> Array:
	"""Get all assessments available for a brain structure"""
	var results = []
	
	for assessment_id in _assessments:
		var assessment = _assessments[assessment_id]
		if assessment.structure_id == structure_id:
			results.append({
				"id": assessment.id,
				"title": assessment.title,
				"difficulty": assessment.difficulty,
				"question_count": assessment.questions.size(),
				"best_score": _get_best_score(assessment.id)
			})
	
	return results

func start_assessment(assessment_id: String) -> bool:
	"""Start a new assessment session"""
	if not _assessments.has(assessment_id):
		push_error("[Assessment] Unknown assessment: " + assessment_id)
		return false
	
	_current_assessment = _assessments[assessment_id]
	_current_assessment.current_question_index = 0
	_current_assessment.start_time = Time.get_ticks_msec() / 1000.0
	_current_assessment.score = 0
	_current_assessment.total_score = _current_assessment.questions.size()
	
	# Reset all questions
	for question in _current_assessment.questions:
		question.user_answer = null
		question.is_answered = false
		question.is_correct = false
	
	assessment_loaded.emit(assessment_id)
	return true

func get_current_question() -> Dictionary:
	"""Get the current question in the active assessment"""
	if not _current_assessment:
		return {}
	
	if _current_assessment.current_question_index >= _current_assessment.questions.size():
		return {}
	
	var question = _current_assessment.questions[_current_assessment.current_question_index]
	
	return {
		"id": question.id,
		"type": question.type,
		"question": question.question,
		"options": question.options,
		"learning_objective": question.learning_objective,
		"question_number": _current_assessment.current_question_index + 1,
		"total_questions": _current_assessment.questions.size()
	}

func submit_answer(answer: Variant) -> Dictionary:
	"""Submit an answer for the current question"""
	if not _current_assessment:
		return {}
	
	var question = _current_assessment.questions[_current_assessment.current_question_index]
	question.user_answer = answer
	question.is_answered = true
	
	# Check if correct
	question.is_correct = _check_answer(question, answer)
	if question.is_correct:
		_current_assessment.score += 1
	
	question_answered.emit(question.id, question.is_correct)
	
	return {
		"is_correct": question.is_correct,
		"correct_answer": question.correct_answer,
		"explanation": question.explanation
	}

func next_question() -> bool:
	"""Move to the next question"""
	if not _current_assessment:
		return false
	
	_current_assessment.current_question_index += 1
	
	# Check if assessment complete
	if _current_assessment.current_question_index >= _current_assessment.questions.size():
		_complete_assessment()
		return false
	
	return true

func previous_question() -> bool:
	"""Move to the previous question"""
	if not _current_assessment:
		return false
	
	if _current_assessment.current_question_index > 0:
		_current_assessment.current_question_index -= 1
		return true
	
	return false

func skip_question() -> bool:
	"""Skip the current question"""
	if not _current_assessment:
		return false
	
	var question = _current_assessment.questions[_current_assessment.current_question_index]
	question.is_answered = true
	question.is_correct = false
	
	return next_question()

func get_progress() -> Dictionary:
	"""Get progress for the current assessment"""
	if not _current_assessment:
		return {}
	
	var answered = 0
	var correct = 0
	
	for question in _current_assessment.questions:
		if question.is_answered:
			answered += 1
		if question.is_correct:
			correct += 1
	
	return {
		"current_question": _current_assessment.current_question_index + 1,
		"total_questions": _current_assessment.questions.size(),
		"answered": answered,
		"correct": correct,
		"score": _current_assessment.score,
		"percentage": float(correct) / float(_current_assessment.questions.size()) * 100.0
	}

func get_structure_progress(structure_id: String) -> Dictionary:
	"""Get overall progress for a brain structure"""
	if not _user_progress.has(structure_id):
		return {
			"assessments_completed": 0,
			"total_questions_answered": 0,
			"average_score": 0.0,
			"mastery_level": "beginner"
		}
	
	return _user_progress[structure_id]

# === PRIVATE METHODS ===

func _load_assessments() -> void:
	"""Load assessment data from JSON file"""
	var file = FileAccess.open(ASSESSMENT_FILE_PATH, FileAccess.READ)
	if not file:
		push_error("[Assessment] Failed to open assessment file")
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		push_error("[Assessment] Failed to parse assessment JSON")
		return
	
	var data = json.data
	if not data.has("assessments"):
		push_error("[Assessment] Invalid assessment data format")
		return
	
	# Parse assessments
	for assessment_data in data.assessments:
		var assessment = Assessment.new()
		assessment.id = assessment_data.id
		assessment.structure_id = assessment_data.structure_id
		assessment.title = assessment_data.title
		assessment.difficulty = assessment_data.difficulty
		
		# Parse questions
		for question_data in assessment_data.questions:
			var question = Question.new()
			question.id = question_data.id
			question.type = question_data.type
			question.question = question_data.question
			question.options = question_data.get("options", [])
			question.correct_answer = question_data.correct_answer
			question.explanation = question_data.explanation
			question.learning_objective = question_data.learning_objective
			
			assessment.questions.append(question)
		
		_assessments[assessment.id] = assessment
	
	_is_loaded = true
	print("[Assessment] Loaded %d assessments" % _assessments.size())

func _check_answer(question: Question, answer: Variant) -> bool:
	"""Check if an answer is correct"""
	match question.type:
		"multiple_choice":
			return answer == question.correct_answer
		"true_false":
			return answer == question.correct_answer
		"fill_blank":
			# Case-insensitive comparison for fill-in-the-blank
			if answer is String and question.correct_answer is String:
				return answer.to_lower() == question.correct_answer.to_lower()
			return false
		_:
			return false

func _complete_assessment() -> void:
	"""Complete the current assessment"""
	if not _current_assessment:
		return
	
	_current_assessment.completion_time = Time.get_ticks_msec() / 1000.0 - _current_assessment.start_time
	
	var score_data = {
		"score": _current_assessment.score,
		"total": _current_assessment.total_score,
		"percentage": float(_current_assessment.score) / float(_current_assessment.total_score) * 100.0,
		"time_seconds": _current_assessment.completion_time,
		"difficulty": _current_assessment.difficulty
	}
	
	# Update user progress
	_update_user_progress(_current_assessment.structure_id, score_data)
	
	# Save progress
	_save_user_progress()
	
	assessment_completed.emit(_current_assessment.id, score_data)

func _update_user_progress(structure_id: String, score_data: Dictionary) -> void:
	"""Update user progress for a structure"""
	if not _user_progress.has(structure_id):
		_user_progress[structure_id] = {
			"assessments_completed": 0,
			"total_questions_answered": 0,
			"total_correct": 0,
			"average_score": 0.0,
			"best_scores": {},
			"mastery_level": "beginner"
		}
	
	var progress = _user_progress[structure_id]
	progress.assessments_completed += 1
	progress.total_questions_answered += score_data.total
	progress.total_correct += score_data.score
	
	# Update best score
	if not progress.best_scores.has(_current_assessment.id):
		progress.best_scores[_current_assessment.id] = 0.0
	
	progress.best_scores[_current_assessment.id] = max(
		progress.best_scores[_current_assessment.id],
		score_data.percentage
	)
	
	# Calculate average
	progress.average_score = float(progress.total_correct) / float(progress.total_questions_answered) * 100.0
	
	# Update mastery level
	if progress.average_score >= 90.0:
		progress.mastery_level = "expert"
	elif progress.average_score >= 70.0:
		progress.mastery_level = "intermediate"
	else:
		progress.mastery_level = "beginner"

func _get_best_score(assessment_id: String) -> float:
	"""Get the best score for an assessment"""
	for structure_id in _user_progress:
		var progress = _user_progress[structure_id]
		if progress.best_scores.has(assessment_id):
			return progress.best_scores[assessment_id]
	return 0.0

func _load_user_progress() -> void:
	"""Load user progress from save file"""
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		return
	
	_user_progress = file.get_var()
	file.close()
	
	print("[Assessment] Loaded user progress")

func _save_user_progress() -> void:
	"""Save user progress to file"""
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if not file:
		push_error("[Assessment] Failed to save progress")
		return
	
	file.store_var(_user_progress)
	file.close()