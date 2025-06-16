# NeuroVision Slash Commands

Comprehensive collection of custom Claude Code commands designed specifically for the NeuroVision brain anatomy education project. These commands streamline development, ensure consistency, and maintain high quality standards across the application.

## 📋 Table of Contents

- [Command Categories](#command-categories)
- [Available Commands](#available-commands)
- [Quick Usage Guide](#quick-usage-guide)
- [Common Workflows](#common-workflows)
- [Best Practices](#best-practices)
- [Project-Specific Notes](#project-specific-notes)

## Command Categories

### 🎨 UI/UX Development
Commands for creating, fixing, and reviewing user interface components with Material3 design and accessibility focus.

### 🧠 Content Management
Tools for managing educational content, brain structure data, and assessment materials.

### 🚀 Performance & Optimization
Utilities for analyzing and optimizing performance, 3D models, and visual effects.

### 🎬 Scene Management
Commands for composing scenes, integrating models, and managing reusable components.

### 🧪 Testing & Debugging
Tools for creating tests, debugging issues, and ensuring code quality.

### 🧹 Maintenance & Architecture
Commands for cleaning up code, reviewing architecture, and maintaining project structure.

## Available Commands

### 🎨 UI/UX Development

#### `/create-ui-component`
Create Material3-compliant UI components with built-in accessibility features.
```bash
/create-ui-component COMPONENT_NAME="BrainFactCard" COMPONENT_TYPE="card" FEATURES="responsive,accessible"
```

#### `/fix-theme-issue`
Fix theme-related visual issues and ensure color consistency across all theme variants.
```bash
/fix-theme-issue COMPONENT="QuizQuestionCard.gd" ISSUE_TYPE="contrast" THEME_VARIANT="ocean_depths" DESCRIPTION="Text hard to read on dark background"
```

#### `/add-accessibility`
Add WCAG-compliant accessibility features to existing components.
```bash
/add-accessibility COMPONENT="BrainStructureList" FEATURES="keyboard_nav,screen_reader" WCAG_LEVEL="AA"
```

#### `/review-ui-ux`
Conduct comprehensive UI/UX review with actionable improvement suggestions.
```bash
/review-ui-ux TARGET="BrainViewer" REVIEW_FOCUS="comprehensive" USER_PERSONA="student" DEVELOPMENT_STAGE="alpha"
```

### 🧠 Content Management

#### `/update-brain-structure`
Update anatomical data across all content files while maintaining medical accuracy.
```bash
/update-brain-structure STRUCTURE_ID="hippocampus" UPDATE_TYPE="clinical" NEW_DATA="Critical for memory formation and spatial navigation"
```

#### `/add-quiz-content`
Add educationally-sound quiz questions to the assessment system.
```bash
/add-quiz-content TOPIC="anatomy_basics" DIFFICULTY="beginner" QUESTION_TYPE="multiple_choice" STRUCTURE_FOCUS="amygdala" COUNT="5"
```

### 🚀 Performance & Optimization

#### `/analyze-performance`
Analyze performance impact of scenes, scripts, or shaders against target metrics.
```bash
/analyze-performance TARGET="src/ui/screens/BrainViewer.tscn" METRICS="fps,draw_calls,memory" CONTEXT="brain_view" DEVICE_PROFILE="low_end"
```


#### `/generate-shader`
Create custom visual effect shaders optimized for educational visualization.
```bash
/generate-shader SHADER_NAME="selection_pulse" SHADER_TYPE="material" EFFECT="pulse" PERFORMANCE_TARGET="balanced"
```

### 🎬 Scene Management

#### `/scene-compose`
Compose complex scenes from reusable components with future model expansion support.
```bash
/scene-compose SCENE_NAME="DetailedBrainExplorer" SCENE_TYPE="exploration" COMPONENTS="BrainViewer,StructureInfo,NavigationControls" LAYOUT="split" MODEL_SLOTS="3"
```

#### `/model-integrate`
Seamlessly integrate new 3D brain models into existing scenes.
```bash
/model-integrate MODEL_NAME="hippocampus_detailed" TARGET_SCENES="viewer,quiz" INTEGRATION_TYPE="add_option" LOD_CONFIG="auto" EDUCATIONAL_METADATA="hippocampus_data.json"
```

#### `/scene-variant`
Create optimized scene variants for different platforms and user types.
```bash
/scene-variant BASE_SCENE="BrainExplorer" VARIANT_TYPE="mobile" OPTIMIZATIONS="performance" FEATURE_SET="essential" INHERITANCE="true"
```

#### `/component-library`
Build and manage a library of reusable scene components.
```bash
/component-library ACTION="create" COMPONENT_TYPE="ui_panel" COMPONENT_NAME="ModelComparisonPanel" COMPATIBILITY="all_themes" EXPORT_PRESET="true"
```

### 🧪 Testing & Debugging

#### `/create-test`
Generate comprehensive tests for components with educational focus.
```bash
/create-test TEST_TARGET="StructureHighlightManager" TEST_TYPE="unit" TEST_FOCUS="highlight_persistence" COVERAGE_GOAL="80"
```

#### `/debug-autoload`
Debug issues with singleton autoload services and their dependencies.
```bash
/debug-autoload AUTOLOAD_NAME="ContentManager" ISSUE_TYPE="initialization" SYMPTOMS="Content not loading on startup" RELATED_SYSTEMS="UIThemeManager,ProgressTracker"
```

### 🧹 Maintenance & Architecture

#### `/cleanup-scan`
Scan project for cleanup opportunities without making changes.
```bash
/cleanup-scan TARGET="code" AGGRESSIVE="false" INCLUDE_PATTERNS="*.gd,*.tscn" EXCLUDE_DIRS=".godot,assets/3d_models"
```

#### `/execute-cleanup`
Execute cleanup operations based on scan results with safety controls.
```bash
/execute-cleanup CATEGORY="safe" BACKUP="true" TARGET_AREA="ui" DRY_RUN="false"
```

#### `/audit-scene-architecture`
Comprehensive review of scene organization, dependencies, and architectural issues.
```bash
/audit-scene-architecture AUDIT_SCOPE="all" ANALYSIS_DEPTH="thorough" INCLUDE_SUGGESTIONS="true" SAFETY_LEVEL="balanced"
```

#### `/context-summary`
Generate detailed documentation for components or systems.
```bash
/context-summary COMPONENT="src/systems/3d_interaction" DEPTH="deep" FOCUS="educational" OUTPUT_FORMAT="markdown"
```

#### `/generate-prompt`
Create well-structured development prompts for AI-assisted coding.
```bash
/generate-prompt TASK_TYPE="component" COMPONENT_NAME="HippocampusQuiz" EDUCATIONAL_GOAL="spatial memory understanding" PHASE="1" COMPLEXITY="medium"
```

## Quick Usage Guide

### Command Syntax
1. **Arguments use `$` prefix**: `$ARGUMENT_NAME`
2. **Multi-word values need quotes**: `DESCRIPTION="Complex description here"`
3. **Optional arguments have defaults**: `${OPTIONAL:="default_value"}`
4. **Commands are project-aware**: Tailored specifically to NeuroVision's architecture

### Argument Types
- **Required**: Must be provided for command to work
- **Optional**: Have sensible defaults if not specified
- **Conditional**: Required based on other argument values

## Common Workflows

### 🏗️ Building a New Educational Scene
```bash
# 1. Create reusable components
/component-library ACTION="create" COMPONENT_TYPE="ui_panel" COMPONENT_NAME="StructureDetailPanel"

# 2. Compose scene from components
/scene-compose SCENE_NAME="BrainLearningHub" SCENE_TYPE="hybrid" COMPONENTS="BrainViewer,StructureDetailPanel,QuizPanel" LAYOUT="adaptive" MODEL_SLOTS="5"

# 3. Create mobile variant
/scene-variant BASE_SCENE="BrainLearningHub" VARIANT_TYPE="mobile" OPTIMIZATIONS="performance" FEATURE_SET="essential"

# 4. Test performance
/analyze-performance TARGET="BrainLearningHub.tscn" METRICS="all" DEVICE_PROFILE="low_end"
```

### 🧠 Adding New Brain Models
```bash
# 1. Integrate models into scenes
/model-integrate MODEL_NAME="cerebellum_detailed" TARGET_SCENES="viewer,exploration" INTEGRATION_TYPE="add_option" LOD_CONFIG="auto"

# 2. Update component library
/component-library ACTION="update" COMPONENT_TYPE="3d_control" COMPONENT_NAME="ModelSelector" COMPATIBILITY="new_models"

# 3. Test performance impact
/analyze-performance TARGET="BrainViewer.tscn" METRICS="fps,memory" DEVICE_PROFILE="integrated_graphics"
```

### 🎨 UI/UX Improvement Cycle
```bash
# 1. Review current state
/review-ui-ux TARGET="AssessmentScene" REVIEW_FOCUS="comprehensive" USER_PERSONA="student"

# 2. Fix identified issues
/fix-theme-issue COMPONENT="QuizPanel" ISSUE_TYPE="contrast" THEME_VARIANT="all"

# 3. Add missing accessibility
/add-accessibility COMPONENT="QuizPanel" FEATURES="keyboard_nav,screen_reader" WCAG_LEVEL="AAA"

# 4. Verify improvements
/create-test TEST_TARGET="QuizPanel" TEST_TYPE="ui" TEST_FOCUS="accessibility"
```

### 🧹 Project Architecture Cleanup
```bash
# 1. Audit scene architecture
/audit-scene-architecture AUDIT_SCOPE="all" ANALYSIS_DEPTH="thorough" SAFETY_LEVEL="balanced"

# 2. Review UI/UX holistically
/review-ui-ux TARGET="all" REVIEW_FOCUS="comprehensive" DEVELOPMENT_STAGE="alpha"

# 3. Scan for cleanup opportunities
/cleanup-scan TARGET="scenes" AGGRESSIVE="false" EXCLUDE_DIRS="assets/3d_models"

# 4. Execute safe cleanup (with dry run first)
/execute-cleanup CATEGORY="safe" BACKUP="true" DRY_RUN="true"
```

### 📊 Performance Optimization Pipeline
```bash
# 1. Baseline performance analysis
/analyze-performance TARGET="BrainViewer.tscn" METRICS="all" DEVICE_PROFILE="integrated_graphics"

# 2. Generate optimized shaders
/generate-shader SHADER_NAME="mobile_highlight" EFFECT="highlight" PERFORMANCE_TARGET="performance"

# 3. Review code quality for performance
/review-code-quality COMPONENT="BrainViewer" REVIEW_FOCUS="performance" DEPTH="standard"

# 4. Re-test performance
/analyze-performance TARGET="BrainViewer.tscn" METRICS="fps,memory" DEVICE_PROFILE="integrated_graphics"
```

## Best Practices

### General Guidelines
1. **Always specify medical context** when updating educational content
2. **Test on multiple theme variants** (all 4 current themes) when fixing UI issues
3. **Leverage performance achievements** - optimize beyond 120+ FPS standard
4. **Include accessibility** in all UI components (WCAG AAA compliance achieved)
5. **Validate medical accuracy** for all content changes
6. **Create tests** for new functionality
7. **Check autoload dependencies** (current 10 core systems) when debugging
8. **Use unified color system** for all component development
9. **Plan for Phase 2** educational feature enhancement
10. **Maintain production-ready** standards for all changes

### Command-Specific Tips

#### Scene Management
- Always use scene inheritance for variants
- Plan for 5+ brain models in scene architecture
- Use component library for reusability
- Test performance impact of scene changes

#### UI Development
- Apply Material3 design tokens with unified color system
- Test all 4 theme variants (enhanced, minimal, high contrast, colorblind safe)
- Ensure keyboard navigation works (WCAG AAA standard)
- Validate 7:1+ contrast ratios achieved

#### Content Management
- Cross-reference medical sources
- Maintain consistent terminology
- Link quiz content to structures
- Update all related files

#### Architecture
- Run audits before major refactoring
- Always backup before cleanup
- Use dry-run mode first
- Validate educational features post-cleanup

## Project-Specific Notes

### Technical Stack
- **Engine**: Godot 4.4.1 (Production)
- **Design System**: Material3 with Unified Color Management
- **Autoloads**: 10 core singleton services managing platform functionality
- **Theme Variants**: 4 optimized schemes
  - enhanced_student (engaging for students)
  - minimal_clinical (professional medical)
  - high_contrast_accessibility (WCAG AAA)
  - colorblind_safe (universal accessibility)

### Requirements
- **Accessibility**: WCAG AAA compliance mandatory (achieved 7:1+ contrast)
- **Performance**: 120+ FPS achieved (4x exceeding 30 FPS target on Intel UHD 620)
- **Educational**: Medical textbook accuracy with 21+ brain structures
- **Platforms**: Desktop production-ready, mobile/tablet optimized

### Architecture Highlights
- **Model Expansion**: Designed for 5+ detailed brain models
- **Scene Variants**: Support for mobile, desktop, teacher modes
- **Component Reusability**: Extensive library system
- **Offline-First**: Full functionality without internet

## Troubleshooting

### Command Not Working?
1. Verify you're in the project root directory
2. Check argument names match exactly (case-sensitive)
3. Use quotes for multi-word values
4. Ensure the command file exists in `.claude/commands/`
5. Verify all required arguments are provided

### Common Issues
- **"File not found"**: Check paths are relative to project root
- **"Invalid argument"**: Verify argument names and values
- **"Command failed"**: Check prerequisites and dependencies
- **"No changes made"**: May indicate everything is already optimal

## Contributing New Commands

When creating new slash commands:
1. Place in `.claude/commands/` directory
2. Use descriptive names: `verb-noun.md`
3. Include comprehensive header documentation
4. Define all arguments clearly with examples
5. Specify sensible default values
6. Test thoroughly before committing
7. Update this README with usage examples
8. Consider impact on existing workflows

## Version History

- **v1.0**: Initial command set (UI, content, performance)
- **v1.1**: Added scene management commands
- **v1.2**: Added maintenance and architecture commands
- **v1.3**: Added UI/UX review and architecture audit
- **Current**: Optimized suite of 35 essential commands (removed 3 overly generic/specialized commands)

---

*These commands are continuously updated to match NeuroVision's evolving architecture and requirements. Check individual command files for the most current options and features.*