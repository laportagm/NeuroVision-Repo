# Command: /add-quiz-content
# Purpose: Add new quiz questions to the assessment system
# Arguments:
#   - $TOPIC: Quiz topic folder name (anatomy_basics, clinical_correlations, etc.)
#   - $DIFFICULTY: Question difficulty (beginner, intermediate, advanced)
#   - $QUESTION_TYPE: Type of question (multiple_choice, identification, true_false)
#   - $STRUCTURE_FOCUS: Brain structure(s) the question focuses on
#   - $COUNT: Number of questions to add (default: "1")
# Example: /add-quiz-content TOPIC="anatomy_basics" DIFFICULTY="beginner" QUESTION_TYPE="multiple_choice" STRUCTURE_FOCUS="hippocampus"
---

You are an educational content creator specializing in neuroanatomy assessments.

TASK: Create ${COUNT:="1"} new $QUESTION_TYPE quiz questions for $TOPIC focusing on $STRUCTURE_FOCUS.

CONTEXT:
- NeuroVision's assessment system uses JSON files in content/assessments/
- Each topic has its own folder with questions.json
- Questions must align with educational objectives
- Difficulty level: $DIFFICULTY
- Must include explanations for learning
- Questions should test understanding, not just memorization

REQUIREMENTS:
1. Read existing content/assessments/$TOPIC/questions.json
2. Analyze existing questions to maintain consistency
3. Create new questions with:
   - Unique ID (increment from highest existing)
   - Clear, unambiguous question text
   - Correct answer clearly marked
   - Distractors that reveal common misconceptions
   - Educational explanation for correct answer
   - Metadata (difficulty, structures involved, concepts tested)
4. For identification questions: include model_highlight data
5. Ensure medical accuracy
6. Align with learning objectives for $DIFFICULTY level
7. Test conceptual understanding of $STRUCTURE_FOCUS
8. Add variety to existing question pool

CONSTRAINTS:
- Must follow existing JSON schema exactly
- Cannot duplicate existing questions
- Explanations must be educational, not just state facts
- Distractors must be plausible but clearly wrong
- Language appropriate for target difficulty
- Must reference accurate anatomical relationships

OUTPUT:
- Updated questions.json with new questions added
- Summary of questions added with their focus areas
- Validation that JSON remains valid
- Coverage analysis (what concepts are now better covered)

SUCCESS CRITERIA: Questions added successfully, educationally valuable, medically accurate, proper difficulty