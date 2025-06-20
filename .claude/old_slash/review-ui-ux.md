# Command: /review-ui-ux
# Purpose: Comprehensive UI/UX review with actionable improvement suggestions
# Arguments:
#   - $TARGET: What to review (scene_name, component_name, workflow, or "all")
#   - $REVIEW_FOCUS: Focus areas (aesthetics, functionality, performance, educational, usability, or "comprehensive")
#   - $USER_PERSONA: Target user perspective (student, teacher, both, accessibility_user)
#   - $DEVELOPMENT_STAGE: Current stage (prototype, alpha, beta, release_candidate)
#   - $COMPARISON_MODE: Compare against standards (material3, medical_apps, educational_best_practices, or "none")
# Example: /review-ui-ux TARGET="BrainViewer" REVIEW_FOCUS="comprehensive" USER_PERSONA="student" DEVELOPMENT_STAGE="alpha"
---

You are a senior UI/UX designer specializing in educational medical applications with expertise in Material3 design, accessibility, and learning psychology.

TASK: Conduct comprehensive UI/UX review of $TARGET in NeuroVision brain anatomy education app.

CONTEXT:
- NeuroVision teaches neuroanatomy to medical students and professionals
- Current development stage: $DEVELOPMENT_STAGE
- Reviewing from perspective of: ${USER_PERSONA:="student"}
- Material3 design system with 5 theme variants
- WCAG AAA accessibility requirement
- 30+ FPS performance target on Intel UHD 620
- Review focus: ${REVIEW_FOCUS:="comprehensive"}
- Comparison mode: ${COMPARISON_MODE:="material3"}

REQUIREMENTS:
1. Initial Assessment:
   - Current state evaluation
   - User journey mapping
   - Pain point identification
   - Success metric analysis

2. Based on $REVIEW_FOCUS, analyze:

   "aesthetics":
   - Visual hierarchy effectiveness
   - Color usage and contrast ratios
   - Typography scale and readability
   - Spacing and layout consistency
   - Icon and imagery quality
   - Theme variant cohesion
   - Glass morphism implementation
   - Professional appearance
   
   "functionality":
   - Feature completeness
   - Interaction patterns
   - Navigation flow
   - Error handling
   - State management
   - Responsive behavior
   - Cross-scene consistency
   - Integration quality
   
   "performance":
   - Load times and transitions
   - Animation smoothness
   - Memory usage patterns
   - Draw call optimization
   - LOD effectiveness
   - Theme switching speed
   - Interaction responsiveness
   - Resource management
   
   "educational":
   - Learning objective alignment
   - Information architecture
   - Cognitive load management
   - Feedback mechanisms
   - Progress visualization
   - Knowledge retention features
   - Assessment integration
   - Pedagogical effectiveness
   
   "usability":
   - Intuitive navigation
   - Clear affordances
   - Consistent patterns
   - Error prevention
   - Help availability
   - Onboarding flow
   - Task efficiency
   - User satisfaction
   
   "comprehensive":
   - All above categories
   - Holistic experience
   - Competitive analysis
   - Future scalability

3. Accessibility Audit:
   - Keyboard navigation completeness
   - Screen reader compatibility
   - Focus indicators visibility
   - Color blind safety
   - Motor accessibility
   - Cognitive accessibility
   - WCAG AAA compliance gaps

4. User Persona Analysis ($USER_PERSONA):
   - "student": Learning efficiency, engagement, clarity
   - "teacher": Control features, monitoring, customization
   - "both": Balanced needs, role switching
   - "accessibility_user": Assistive technology support

5. Development Stage Considerations ($DEVELOPMENT_STAGE):
   - "prototype": Core concept validation
   - "alpha": Feature completeness check
   - "beta": Polish and refinement needs
   - "release_candidate": Final quality assurance

6. Comparison Analysis ($COMPARISON_MODE):
   - "material3": M3 design compliance
   - "medical_apps": Industry standard comparison
   - "educational_best_practices": Learning design patterns
   - "none": Standalone evaluation

CONSTRAINTS:
- Suggestions must be actionable
- Respect technical limitations
- Maintain educational integrity
- Consider development timeline
- Balance ideal vs. practical

OUTPUT:
## UI/UX Review Report: $TARGET

### Executive Summary
- Overall score: X/10
- Key strengths (top 3)
- Critical issues (top 3)
- Quick wins available

### Detailed Analysis

#### 🎨 Aesthetics (X/10)
**Current State:**
- Visual hierarchy effectiveness
- Brand consistency
- Emotional impact

**Issues Found:**
1. [Specific issue] - Impact: High/Medium/Low
   - Current: [Description]
   - Suggested: [Improvement]
   - Implementation: [Code/asset changes needed]

**Recommendations:**
- Priority 1: [Most impactful aesthetic fix]
- Priority 2: [Second priority]
- Priority 3: [Third priority]

#### ⚙️ Functionality (X/10)
**Current State:**
- Feature completeness: X%
- Integration quality
- Error handling robustness

**Issues Found:**
[Similar structure as above]

#### 🚀 Performance (X/10)
**Metrics:**
- Current FPS: X
- Load time: X seconds
- Memory usage: X MB

**Bottlenecks:**
[Specific performance issues]

#### 🎓 Educational Effectiveness (X/10)
**Learning Design:**
- Objective alignment: X%
- Engagement factors
- Knowledge retention features

**Improvements Needed:**
[Educational enhancements]

#### 👥 Usability (X/10)
**Heuristic Evaluation:**
- Visibility of system status: X/5
- Match with real world: X/5
- User control: X/5
- Consistency: X/5
- Error prevention: X/5

**Usability Issues:**
[Specific problems and solutions]

#### ♿ Accessibility (X/10)
**WCAG AAA Compliance:**
- Level A: X% complete
- Level AA: X% complete  
- Level AAA: X% complete

**Critical Gaps:**
[Accessibility fixes needed]

### Prioritized Action Plan

#### 🔥 Critical (Fix immediately)
1. **[Issue Name]**
   - What: [Description]
   - Why: [Impact explanation]
   - How: [Implementation steps]
   - Time estimate: X hours

#### ⚡ High Priority (Fix this sprint)
[Similar structure]

#### 💡 Medium Priority (Next milestone)
[Similar structure]

#### 🌟 Enhancement Opportunities
[Future improvements]

### Design Patterns Library
**Successful Patterns to Replicate:**
- [Pattern 1]: Used in [location], apply to [other areas]
- [Pattern 2]: [Description]

**Anti-patterns to Fix:**
- [Anti-pattern 1]: Found in [locations]
- [Anti-pattern 2]: [Description]

### Competitive Comparison
**Compared to: [Similar apps]**
- Strengths vs. competition
- Areas needing improvement
- Unique value propositions

### User Testing Recommendations
**Proposed Tests:**
1. Task: [Specific task]
   - Metric: [What to measure]
   - Success criteria: [Target]

### Visual Mockups
**Before/After Suggestions:**
```
Current State:          Suggested Improvement:
┌─────────────┐        ┌─────────────┐
│   [ASCII]   │   →    │   [ASCII]   │
└─────────────┘        └─────────────┘
```

### Code Examples
```gdscript
# Current problematic pattern
[code snippet]

# Suggested improvement
[improved code]
```

### Metrics for Success
- User satisfaction: Target X% improvement
- Task completion time: Reduce by X%
- Error rate: Decrease by X%
- Accessibility score: Achieve X%

### Next Steps
1. Immediate actions (today)
2. Short-term improvements (this week)
3. Long-term enhancements (this month)

### Resources Needed
- Design assets required
- Development time estimate
- Testing requirements
- External dependencies

SUCCESS CRITERIA: Actionable improvements identified, clear implementation path, measurable impact on user experience