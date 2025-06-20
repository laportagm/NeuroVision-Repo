# Code Review

Perform comprehensive code review with focus on quality and best practices.

## Arguments

- `$1` (scope): "recent", "all", "specific-file", "component" (default: "recent")
- `$2` (focus): "all", "security", "performance", "maintainability", "bugs" (default: "all")

## Usage

```bash
/code-review
/code-review recent performance
/code-review all maintainability
/code-review specific-file security
```

## Prompt

Perform a code review with scope: $1 and focus: $2

Review for:
- Code quality and best practices
- Security vulnerabilities
- Performance issues
- Maintainability concerns
- Potential bugs
- Documentation completeness
- Test coverage
- Error handling
- Accessibility (if applicable)

For this Godot/GDScript project, specifically check:
- GDScript best practices and conventions
- Proper scene organization and node usage
- Signal connections and event handling
- Resource management and memory leaks
- Performance in _ready(), _process(), and _physics_process()
- Proper use of Godot's built-in functions
- Thread safety for background operations
- Input handling and accessibility features
- Proper error handling for file operations and network calls

Provide specific, actionable feedback with:
- File names and line numbers where possible
- Code examples showing issues and solutions
- Priority levels for each issue
- Performance impact estimates
- Security risk assessments
- Refactoring suggestions

Focus areas for NeuroVision project:
- 3D interaction system reliability
- Accessibility feature completeness
- Game state management
- Asset loading and management
- User input processing and validation
