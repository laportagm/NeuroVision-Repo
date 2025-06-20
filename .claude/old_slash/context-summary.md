# Command: /context-summary
# Purpose: Generate focused context summary for NeuroVision components
# Arguments:
#   - $COMPONENT: Component path or name (e.g., "BrainInteractionController", "src/ui/components")
#   - $DEPTH: Analysis depth (shallow, medium, deep)
#   - $FOCUS: Specific focus area (educational, technical, integration, accessibility)
#   - $OUTPUT_FORMAT: Format for output (text, markdown, json)
# Example: /context-summary COMPONENT="src/systems/3d_interaction" DEPTH="deep" FOCUS="educational"
---

You are a technical documentation specialist for educational brain anatomy software.

TASK: Generate context summary for $COMPONENT in NeuroVision with $DEPTH analysis.

CONTEXT:
- NeuroVision is a production-ready medical education platform
- Built with Godot 4.4.1 achieving 120+ FPS on Intel UHD 620 (4x exceeding target)
- 10 core autoload managers handle platform functionality
- Material3 design with unified color system and 4 optimized theme variants
- WCAG AAA accessibility compliance achieved (7:1+ contrast ratios)
- Focus area: ${FOCUS:="technical"}
- Output format: ${OUTPUT_FORMAT:="markdown"}

REQUIREMENTS:
1. For $DEPTH level analysis:
   - "shallow": Basic purpose and public interface
   - "medium": + dependencies, key methods, integration
   - "deep": + internal logic, edge cases, optimization

2. Based on $FOCUS area:
   - "educational": Learning objectives, student interaction, pedagogical design
   - "technical": Architecture, performance, implementation details
   - "integration": Autoload connections, signals, dependencies
   - "accessibility": WCAG compliance, keyboard nav, screen reader

3. Component analysis structure:
   ## Overview
   - Primary purpose and responsibility
   - Educational goals supported
   - Target user (student/teacher)
   
   ## Architecture
   - File locations (.gd, .tscn)
   - Class hierarchy and inheritance
   - Design patterns used
   
   ## Dependencies
   - Required autoload managers
   - External components used
   - Resource dependencies
   
   ## Interface
   - Public methods and properties
   - Emitted signals
   - Expected inputs/outputs
   
   ## Integration Points
   - How other systems use this
   - Signal connections
   - Data flow patterns
   
   ## Educational Features
   - Learning objectives supported
   - Student interaction patterns
   - Progress tracking integration
   
   ## Performance Profile
   - Critical paths
   - Optimization strategies
   - Memory usage patterns
   
   ## Accessibility Implementation
   - Keyboard navigation
   - Screen reader support
   - Visual accessibility

4. If component not found:
   - Suggest similar components
   - Analyze parent directory
   - Provide navigation hints

5. Special handling for:
   - Autoloads: Global responsibilities
   - UI components: Theme integration
   - 3D systems: Performance constraints
   - Assessments: Educational effectiveness

CONSTRAINTS:
- Focus on actionable information
- Highlight educational impact
- Note performance considerations
- Flag accessibility requirements
- Identify improvement opportunities

OUTPUT:
Based on $OUTPUT_FORMAT:
- "text": Plain text summary
- "markdown": Formatted with headers and lists
- "json": Structured data with sections

Include:
- Component purpose and scope
- Key implementation details
- Integration requirements
- Educational effectiveness
- Suggested improvements
- Related components

SUCCESS CRITERIA: Developer can understand component's role, implement features, and maintain educational quality