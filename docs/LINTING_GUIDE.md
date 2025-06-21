# NeuroVision Linting & Code Quality Guide

This guide ensures consistent code quality across the NeuroVision medical education platform.

## Quick Start

### 1. Install Required Tools

```bash
# Install Python tools
pip install gdtoolkit pre-commit

# Install pre-commit hooks
pre-commit install

# Run all linters manually
pre-commit run --all-files
```

### 2. VS Code Setup

VS Code settings are already configured in `.vscode/settings.json`:
- Auto-format on save for GDScript
- Proper indentation (tabs, size 4)
- Line length limit (100 characters)
- Trailing whitespace removal

### 3. Essential Commands

```bash
# Format all GDScript files
gdformat **/*.gd

# Lint all GDScript files
gdlint **/*.gd

# Run specific linter
pre-commit run gdformat --all-files
pre-commit run gdlint --all-files

# Check before committing
pre-commit run
```

## GDScript Standards

### Naming Conventions

```gdscript
# Classes - PascalCase
class_name BrainStructureExplorer

# Functions - snake_case
func calculate_brain_volume() -> float:

# Variables - snake_case
var hippocampus_volume: float = 0.0

# Constants - UPPER_SNAKE_CASE
const MAX_BRAIN_STRUCTURES: int = 100

# Signals - snake_case
signal structure_selected(structure_name: String)

# Enums - PascalCase with UPPER_SNAKE_CASE values
enum MedicalAccuracy {
    STUDENT_LEVEL,
    PROFESSIONAL_LEVEL,
    RESEARCH_LEVEL
}
```

### Code Organization

```gdscript
# Standard class structure
class_name EducationalComponent
extends Node

# 1. Signals
signal learning_completed(score: float)

# 2. Enums
enum DifficultyLevel { BEGINNER, INTERMEDIATE, ADVANCED }

# 3. Constants
const MAX_QUIZ_TIME: float = 300.0

# 4. Export variables
@export_group("Educational Settings")
@export var difficulty: DifficultyLevel = DifficultyLevel.BEGINNER
@export var enable_hints: bool = true

# 5. Public variables
var current_score: float = 0.0

# 6. Private variables
var _internal_timer: float = 0.0

# 7. Onready variables
@onready var quiz_panel: Control = $QuizPanel

# 8. Built-in functions
func _ready() -> void:
    pass

func _process(delta: float) -> void:
    pass

# 9. Public functions
func start_quiz() -> void:
    pass

# 10. Private functions
func _calculate_score() -> float:
    return 0.0
```

### Common Issues & Fixes

#### 1. Line Too Long
```gdscript
# ❌ Bad
var very_long_medical_terminology_description: String = "The hippocampus is a complex brain structure embedded deep into temporal lobe with a major role in learning and memory"

# ✅ Good
var very_long_medical_terminology_description: String = \
    "The hippocampus is a complex brain structure embedded deep into " + \
    "temporal lobe with a major role in learning and memory"
```

#### 2. Indentation Errors
```gdscript
# ❌ Bad (spaces)
func process_brain_data():
    if brain_loaded:
        return

# ✅ Good (tabs)
func process_brain_data():
	if brain_loaded:
		return
```

#### 3. Trailing Whitespace
```gdscript
# ❌ Bad
var brain_model: Node3D   

# ✅ Good
var brain_model: Node3D
```

## File-Specific Rules

### GDScript Files (`.gd`)
- Use tabs for indentation
- 100 character line limit
- Trailing commas in multiline arrays/dictionaries
- Type hints for all functions and variables

### Scene Files (`.tscn`)
- Edited through Godot Editor only
- Use meaningful node names
- Group related nodes
- Add metadata for accessibility

### Resource Files (`.tres`)
- Created through Godot Editor
- Use descriptive resource names
- Store in appropriate directories

### JSON Files (`.json`)
- 2 spaces for indentation
- Valid JSON syntax
- Meaningful property names
- Comments not allowed (use separate docs)

## Pre-commit Hooks

Our pre-commit configuration runs:

1. **File Fixes**
   - Remove trailing whitespace
   - Fix end-of-file newlines
   - Ensure LF line endings
   - Check for merge conflicts

2. **GDScript**
   - Format with gdformat
   - Lint with gdlint

3. **Other Files**
   - YAML validation
   - JSON validation
   - Markdown linting
   - EditorConfig compliance

## Ignoring Linting

### Temporary Disable
```gdscript
# gdlint: disable=line-length
var extremely_long_line_that_cannot_be_broken_for_medical_accuracy_reasons: String = "..."
# gdlint: enable=line-length
```

### File-Level Ignore
Add to `.gdignore`:
```
path/to/generated/file.gd
**/temp_*.gd
```

### Project-Level Ignore
Configure in `.gdlintrc`:
```ini
exclude = [
    ".godot/**",
    "addons/**",
    "**/test_*.gd"
]
```

## VS Code Extensions

Recommended extensions for linting:
- **godot-tools** - Official Godot support
- **EditorConfig** - Consistent formatting
- **Error Lens** - Inline error display
- **TODO Highlight** - Highlight TODOs
- **Trailing Spaces** - Visualize trailing spaces

## Troubleshooting

### gdformat not found
```bash
# Ensure Python path is correct
pip show gdtoolkit

# Add to PATH if needed
export PATH="$PATH:~/.local/bin"
```

### Pre-commit fails
```bash
# Update hooks
pre-commit clean
pre-commit install --install-hooks

# Skip hooks temporarily
git commit --no-verify
```

### VS Code not formatting
1. Check Output > Godot Tools
2. Ensure Godot LSP is running
3. Restart VS Code
4. Check `.vscode/settings.json` exists

## Medical Code Standards

### Anatomical Naming
```gdscript
# Use medical terminology
var hippocampus: BrainStructure  # ✅
var memory_thing: Node3D          # ❌

# Be specific with medical terms
func calculate_hippocampal_volume()  # ✅
func calc_hippo_vol()               # ❌
```

### Educational Comments
```gdscript
# Document medical relevance
## Calculates hippocampal volume using segmentation data.
## Used for Alzheimer's disease progression tracking.
func calculate_hippocampal_volume() -> float:
    pass
```

### Accessibility Compliance
```gdscript
# Always include accessibility metadata
@export var accessibility_label: String = "Brain structure selection"
@export var accessibility_hint: String = "Right-click to select structures"
```

## Continuous Integration

GitHub Actions runs linting on:
- Every push to main branches
- All pull requests
- Scheduled weekly checks

Failed linting blocks merges to protect code quality.

---

For questions about linting, check the [VS Code setup guide](.vscode/README.md) or run:
```bash
gdformat --help
gdlint --help
```