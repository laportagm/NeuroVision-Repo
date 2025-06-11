# Generate NeuroVis Prompt

You are creating a well-structured development prompt for NeuroVis that follows the comprehensive prompt engineering guidelines.

**Task:** $ARGUMENTS
**Goal:** Generate a prompt that ensures effective AI-assisted development aligned with educational goals and technical requirements

## Prompt Engineering Framework

### 1. Context Analysis
**Determine the following before generating the prompt:**

**Component Type:**
- [ ] Autoload Manager (Global system)
- [ ] 3D Interaction System
- [ ] UI Component 
- [ ] Assessment/Quiz Component
- [ ] Teacher Tool
- [ ] Data Management System

**Development Phase:**
- [ ] Phase 1: Core Foundation (Offline-first, performance focus)
- [ ] Phase 2: Educational Features (Teacher tools, cloud integration)
- [ ] Phase 3: Deployment (Cross-platform, distribution)

**Educational Context:**
- What specific neuroanatomy learning objective does this support?
- Who is the target user (student/teacher/both)?
- What age group (high school/university)?
- How does this fit into the overall learning experience?

### 2. NeuroVis Prompt Template Structure

```
You are implementing [COMPONENT_NAME] for the NeuroVis educational neuroanatomy application using Godot 4.x.

**File Location:** [Exact src/ path]
**Educational Purpose:** [Specific learning objective this supports]
**Development Phase:** [1/2/3] - [Phase description]
**Target Users:** [Students/Teachers/Both] at [education level]

**Educational Context:**
[2-3 sentences explaining how this supports neuroanatomy learning]

**Core Requirements:**
1. [Functional requirement with educational context]
2. [Performance requirement: 30+ FPS on Intel UHD 620]
3. [Accessibility requirement: WCAG AAA compliance]
4. [Integration requirement: specific autoload managers]
5. [Error handling requirement: graceful degradation]

**Accessibility Requirements (WCAG AAA):**
- Keyboard navigation: [Specific key mappings]
- Screen reader support: [What to announce]
- Visual accessibility: [Contrast, scaling, focus indicators]
- Motor accessibility: [Touch targets, timing considerations]

**Performance Constraints:**
- Target FPS: 30+ on Intel UHD 620 graphics
- Memory usage: [Specific limit for component type]
- Loading time: [Specific threshold]
- Response time: <200ms for user interactions

**Integration Points:**
- ErrorRecoveryManager: [How errors are handled]
- PerformanceMonitor: [Performance tracking needs]
- AccessibilityManager: [Accessibility registration]
- ContentManager: [Content loading requirements]
- ProgressTracker: [Learning analytics to record]
- [Other relevant autoloads]: [Integration specifics]

**Signals to Emit:**
- signal_name(param: Type) - [When emitted and educational purpose]
- [Additional signals as needed]

**Educational Effectiveness:**
[Requirements for how this supports learning objectives]

**Testing Requirements:**
- Unit tests for core functionality
- Accessibility compliance testing
- Performance validation on minimum hardware
- Educational effectiveness validation
- Integration testing with autoload managers

**Error Handling:**
[Specific error scenarios and recovery strategies]

**Offline Requirements (Phase 1):**
[How component works without internet connection]

Remember: Update PROJECT_PROGRESS.md after implementation completion.
```

### 3. Template Specializations

**For Autoload Managers:**
```
**Autoload Responsibilities:**
- [Primary domain responsibility]
- [Educational support role]
- [System coordination tasks]

**Global Interface Requirements:**
- initialize() -> bool
- get_status() -> Dictionary
- handle_error(context: Dictionary) -> void
- [Manager-specific methods]

**Lifecycle Management:**
- _ready() setup with dependency validation
- Graceful degradation when dependencies missing
- Clean shutdown procedures
```

**For UI Components:**
```
**Educational UI Requirements:**
- Age-appropriate visual design
- Clear learning objective support
- Immediate feedback for interactions
- Progress indication and encouragement

**Responsive Design:**
- 720p to 4K display support
- Mobile/tablet compatibility
- Scalable interface elements

**Component Files:**
- src/ui/components/[ComponentName].gd
- src/ui/components/[ComponentName].tscn
```

**For 3D Interaction Systems:**
```
**3D Interaction Requirements:**
- Smooth camera controls (orbit, zoom, pan)
- Structure selection via raycast
- Visual feedback and highlighting
- Touch and mouse input support

**Educational 3D Features:**
- Structure identification support
- Spatial relationship learning
- Progressive exploration guidance
- Accessibility for 3D navigation
```

**For Assessment Components:**
```
**Assessment Design Requirements:**
- Multiple question types support
- Immediate educational feedback
- Progress tracking and analytics
- Adaptive difficulty options

**Educational Effectiveness:**
- Clear learning objective alignment
- Constructive feedback on errors
- Hint systems without giving away answers
- Misconception identification and correction
```

### 4. Quality Validation Checklist

**Before using any generated prompt, verify:**
- [ ] Specific Godot 4.x implementation context provided
- [ ] Educational purpose clearly defined
- [ ] Performance constraints explicitly stated (30+ FPS)
- [ ] Accessibility requirements detailed (WCAG AAA)
- [ ] Autoload integration points specified
- [ ] File locations exact and consistent with project structure
- [ ] Error handling approach defined
- [ ] Testing requirements comprehensive
- [ ] Offline functionality considered (for Phase 1)
- [ ] Progress tracking reminder included

### 5. Common Prompt Enhancement Patterns

**Educational Context Enhancement:**
```
Original: "Create a button component"
Enhanced: "Create an accessible brain structure selection button that helps students identify hippocampus location through visual and audio feedback, supporting the learning objective of spatial neuroanatomy recognition"
```

**Performance Specification Enhancement:**
```
Original: "Make it fast"
Enhanced: "Maintain 30+ FPS on Intel UHD 620 graphics during 3D model interaction, with automatic LOD switching and quality adaptation when frame rate drops below 30 FPS for more than 3 seconds"
```

**Accessibility Requirement Enhancement:**
```
Original: "Make it accessible"
Enhanced: "Full WCAG AAA compliance with Tab/Shift+Tab navigation, Enter/Space activation, Escape cancellation, screen reader announcements for all state changes, and high contrast mode support with 7:1 contrast ratios"
```

### 6. Context-Aware Prompt Generation

**For Current Development State:**
Check PROJECT_PROGRESS.md to understand:
- Which components are already implemented
- What dependencies are available
- Which systems need integration
- Current phase and priorities

**For Educational Curriculum:**
Reference content/ directory structure:
- Brain regions covered
- Assessment types needed
- Learning paths supported
- Age-appropriate content requirements

**For Technical Architecture:**
Consider existing src/ structure:
- Available autoload managers
- Established patterns and conventions
- Integration points already defined
- Performance baselines established

### 7. Example Generated Prompt

**Input:** "Create a quiz question component for hippocampus identification"

**Generated NeuroVis Prompt:**
```
You are implementing HippocampusIdentificationQuestion for the NeuroVis educational neuroanatomy application using Godot 4.x.

**File Location:** src/systems/assessment/QuestionTypes/HippocampusIdentificationQuestion.gd
**Educational Purpose:** Enable students to identify the hippocampus in 3D brain models and understand its role in memory formation
**Development Phase:** Phase 1 - Core Foundation
**Target Users:** High school and university students studying basic neuroanatomy

**Educational Context:**
This component supports the fundamental learning objective of hippocampus identification and spatial recognition within the limbic system. Students will develop visual-spatial understanding of hippocampal anatomy and begin connecting structure to function in memory processes.

**Core Requirements:**
1. 3D model-based identification with click interaction
2. Performance: Maintain 30+ FPS during 3D model manipulation
3. Accessibility: Full keyboard navigation with arrow keys for 3D exploration
4. Integration: ContentManager for model loading, ProgressTracker for learning analytics
5. Error handling: Graceful fallback when 3D models unavailable

**Accessibility Requirements (WCAG AAA):**
- Keyboard navigation: Arrow keys for 3D model rotation, Enter for selection
- Screen reader support: Announce structure names and spatial relationships
- Visual accessibility: High contrast highlighting, scalable text (12-24pt)
- Motor accessibility: Large click targets, adjustable timing for responses

**Performance Constraints:**
- Target FPS: 30+ on Intel UHD 620 during 3D interaction
- Memory usage: <50MB for 3D model and question data
- Loading time: <2 seconds for hippocampus model
- Response time: <100ms for selection feedback

**Integration Points:**
- ErrorRecoveryManager: Handle missing 3D models with 2D fallback
- PerformanceMonitor: Reduce model quality if FPS drops
- AccessibilityManager: Register for keyboard navigation and announcements
- ContentManager: Load hippocampus 3D model and educational metadata
- ProgressTracker: Record identification attempts and success rates

**Signals to Emit:**
- structure_identified(structure_id: String, correct: bool) - When student makes selection
- learning_milestone_reached(milestone: String) - When identification mastery achieved

**Educational Effectiveness:**
- Provide immediate feedback with anatomical context
- Include hints about hippocampal location without giving away answer
- Connect identification to functional significance in memory
- Track multiple identification attempts for mastery assessment

**Testing Requirements:**
- Unit tests for 3D interaction and answer validation
- Accessibility testing with keyboard-only navigation
- Performance testing with hippocampus model on Intel UHD 620
- Educational effectiveness testing with target age group

**Error Handling:**
- Missing 3D models: Fall back to 2D diagram with accessibility descriptions
- Performance issues: Reduce model quality automatically
- Input failures: Clear error messages with recovery guidance

**Offline Requirements (Phase 1):**
All hippocampus identification functionality works completely offline using local ContentManager database and 3D models.

Remember: Update PROJECT_PROGRESS.md after implementation completion.
```

This comprehensive prompt includes all NeuroVis-specific requirements while maintaining focus on educational effectiveness and accessibility.

### Final Output
Generate a complete, ready-to-use prompt following the above framework for: $ARGUMENTS
