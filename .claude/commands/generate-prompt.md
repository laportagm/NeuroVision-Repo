# Command: /generate-prompt
# Purpose: Generate well-structured NeuroVision development prompts
# Arguments:
#   - $TASK_TYPE: Type of task (component, feature, fix, refactor, test)
#   - $COMPONENT_NAME: Name of component/feature
#   - $EDUCATIONAL_GOAL: Specific learning objective
#   - $PHASE: Development phase (1, 2, or 3)
#   - $COMPLEXITY: Task complexity (simple, medium, complex)
# Example: /generate-prompt TASK_TYPE="component" COMPONENT_NAME="HippocampusQuiz" EDUCATIONAL_GOAL="spatial memory understanding" PHASE="1"
---

You are creating a comprehensive development prompt for NeuroVision educational neuroanatomy app.

TASK: Generate a structured prompt for $TASK_TYPE: $COMPONENT_NAME supporting "$EDUCATIONAL_GOAL".

CONTEXT:
- NeuroVision Phase ${PHASE:="1"} development
- Educational brain anatomy app for students/teachers
- Godot 4.x with 30+ FPS on Intel UHD 620
- 14 autoload managers for core functionality
- Material3 design with WCAG AAA compliance
- Task complexity: ${COMPLEXITY:="medium"}

REQUIREMENTS:
1. Analyze task requirements:
   - Component type and purpose
   - Educational objectives served
   - Target users (students/teachers)
   - Integration requirements
   - Performance constraints

2. Generate prompt structure based on $TASK_TYPE:

   FOR "component":
   ```
   You are implementing $COMPONENT_NAME for the NeuroVision educational neuroanatomy application using Godot 4.x.

   **File Location:** src/[appropriate_path]/$COMPONENT_NAME.gd
   **Educational Purpose:** $EDUCATIONAL_GOAL
   **Development Phase:** Phase $PHASE - [Phase description]
   **Target Users:** [Students/Teachers/Both] at [education level]

   **Educational Context:**
   [How this component supports neuroanatomy learning, specific brain structures involved, learning outcomes expected]

   **Core Requirements:**
   1. [Functional requirement with educational context]
   2. Performance: Maintain 30+ FPS on Intel UHD 620
   3. Accessibility: Full WCAG AAA compliance
   4. Integration: [Specific autoload managers needed]
   5. Error handling: Graceful degradation

   **Technical Implementation:**
   - Architecture: [Pattern to follow]
   - Dependencies: [Required systems]
   - State management: [How state is handled]
   - Data flow: [Input/output patterns]

   **Accessibility Requirements (WCAG AAA):**
   - Keyboard: [Specific navigation patterns]
   - Screen reader: [Announcements needed]
   - Visual: [Contrast, sizing, indicators]
   - Motor: [Timing, target sizes]

   **Integration Points:**
   - ContentManager: [Content loading needs]
   - ProgressTracker: [Analytics to track]
   - AccessibilityManager: [Features to register]
   - UIThemeManager: [Theme integration]
   - [Other autoloads]: [Specific integrations]

   **Educational Effectiveness:**
   - Clear learning objective alignment
   - Immediate feedback mechanisms
   - Progress tracking integration
   - Adaptive difficulty support

   **Testing Requirements:**
   - Unit tests for core logic
   - Integration tests with autoloads
   - Accessibility compliance tests
   - Performance benchmarks
   - Educational effectiveness validation
   ```

   FOR "feature":
   ```
   [Feature-specific template focusing on user stories and workflows]
   ```

   FOR "fix":
   ```
   [Bug fix template with root cause analysis requirements]
   ```

   FOR "refactor":
   ```
   [Refactoring template with preservation requirements]
   ```

   FOR "test":
   ```
   [Test creation template with coverage goals]
   ```

3. Include phase-specific requirements:
   - Phase 1: Offline-first, core functionality
   - Phase 2: Teacher tools, cloud features
   - Phase 3: Deployment, optimization

4. Add component-specific details:
   - UI: Material3 integration, responsive design
   - 3D: Performance constraints, LOD usage
   - Assessment: Question types, feedback
   - Autoload: Global responsibilities

5. Specify deliverables:
   - Code files to create/modify
   - Scene files if applicable
   - Test files required
   - Documentation updates

CONSTRAINTS:
- Maintain educational focus
- Ensure accessibility throughout
- Follow NeuroVision patterns
- Consider performance impact
- Support offline functionality

OUTPUT:
Complete, ready-to-use prompt including:
- Full context and requirements
- Technical specifications
- Educational objectives
- Integration details
- Testing requirements
- Success criteria

Remember to include:
- Specific file paths
- Exact autoload integrations
- Measurable success metrics
- Progress tracking reminder

SUCCESS CRITERIA: Generated prompt enables effective implementation supporting educational goals with proper integration