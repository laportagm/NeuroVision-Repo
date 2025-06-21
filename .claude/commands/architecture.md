---
allowed-tools: filesystem, sequential-thinking, codecmcp, memory
description: Comprehensive architecture review for NeuroVision educational platform components
---

# Architecture Review for NeuroVision

## Current Project Context

- **Project Structure**: !`find . -type d -name "core" -o -name "educational" -o -name "assessment" | grep -v ".godot" | head -20`
- **Autoload Services**: !`grep -A 20 "\[autoload\]" project.godot | grep -v "^$"`
- **Scene Files**: !`find . -name "*.tscn" -type f | grep -E "(Main|UI|Educational)" | head -10`
- **Total Code Files**: !`find . -name "*.gd" -type f | wc -l`
- **Performance Critical Files**: !`find . -name "*Performance*.gd" -o -name "*Optimizer*.gd" | head -10`

## Component to Analyze

Analyzing architecture for: **$ARGUMENTS**

## Architecture Analysis Request

You are a senior software architect specializing in educational 3D applications built with Godot 4.x. Perform a comprehensive architecture review of the NeuroVision project, specifically focusing on: **$ARGUMENTS**

### Project Requirements
- **Platform**: Educational neuroscience visualization for medical students
- **Tech Stack**: Godot 4.4.1, GDScript, modular architecture
- **Performance**: 30+ FPS on Intel UHD 620 graphics
- **Accessibility**: WCAG AAA compliance required
- **Features**: Offline-first, 3D brain visualization, assessment integration
- **Constraints**: Must work on low-end educational hardware

### Analysis Scope

1. **Current Architecture Mapping**
   - Analyze the project structure shown above
   - Review autoload/service dependencies
   - Map module boundaries and communication patterns
   - Identify resource management strategies
   - Document architectural patterns in use

2. **Quality Assessment**
   - **Modularity**: How well can new educational content be added?
   - **Performance**: Are there architectural bottlenecks limiting FPS?
   - **Accessibility**: How well integrated are accessibility features?
   - **Maintainability**: How easy is it to modify and extend?
   - **Testability**: Can components be tested in isolation?
   - **Scalability**: Will it handle more content and users?

3. **Problem Identification**
   - Tight coupling between components
   - Performance bottlenecks in architecture
   - Missing abstraction layers
   - Technical debt accumulation
   - Violation of SOLID principles
   - Resource loading inefficiencies

4. **Recommendations**
   - Specific refactoring steps with file impacts
   - New architectural patterns to adopt
   - Module restructuring approach
   - Performance optimization strategies
   - Accessibility integration improvements
   - Testing framework additions

### Output Format

Provide a structured report with:

1. **Executive Summary** (2-3 paragraphs)
   - Current state assessment
   - Critical issues found
   - Top 3 recommendations

2. **Architecture Diagram** (ASCII or description)
   - Current system structure
   - Component relationships
   - Data flow patterns

3. **Detailed Findings**
   - Issues ranked by severity (Critical/High/Medium/Low)
   - Impact on educational effectiveness
   - Technical debt assessment

4. **Action Plan**
   - Immediate fixes (this week)
   - Short-term improvements (this month)
   - Long-term refactoring (this quarter)
   - Each with specific file changes

5. **Code Examples**
   - Before/after snippets for key refactorings
   - New patterns to implement
   - Interface definitions

### Special Considerations

Based on the component "$ARGUMENTS", also analyze:

- If related to **UI/UX**: Panel architecture, accessibility patterns, responsive design
- If related to **Performance**: Rendering pipeline, resource loading, scene optimization
- If related to **Educational**: Module system, assessment integration, progress tracking
- If related to **3D/Graphics**: Model management, LOD systems, interaction patterns
- If related to **Data**: Persistence layer, offline storage, state management

### Reference Files

Key files to examine based on common architectural concerns:
- Main scene structure: @Main.tscn
- Project configuration: @project.godot
- Core systems: @core/
- Educational modules: @educational/
- UI components: @ui/

Generate a comprehensive architecture review that provides actionable insights for improving the NeuroVision platform's architecture while maintaining its educational effectiveness and performance targets.