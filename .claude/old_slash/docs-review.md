# Documentation Review

Review and update project documentation for accuracy and completeness.

## Arguments

- `$1` (type): "all", "readme", "api", "code-comments", "setup" (default: "all")
- `$2` (update): "false", "true" (default: "false")

## Usage

```bash
/docs-review
/docs-review readme true
/docs-review api false
/docs-review code-comments true
/docs-review setup true
```

## Prompt

Review documentation of type: $1
Auto-update if possible: $2

Check for:
- Accuracy and completeness
- Outdated information
- Missing documentation
- Code-comment quality
- Setup/installation instructions
- API documentation completeness
- Examples and usage patterns
- Troubleshooting sections

For this NeuroVision Godot project, specifically review:
- README.md for project setup and overview
- Code comments in GDScript files
- Scene documentation and node explanations
- Accessibility feature documentation
- 3D interaction system documentation
- Build and deployment instructions
- Testing documentation and procedures
- Asset usage and organization docs
- Configuration and settings documentation

Focus areas:
- Installation and setup instructions
- Development environment setup
- Game mechanics and interaction explanations
- Accessibility features and their usage
- Testing procedures and coverage
- Deployment and build processes
- Troubleshooting common issues
- Contributing guidelines for developers

Identify gaps and provide updated content for:
- Missing API documentation
- Unclear setup instructions
- Outdated screenshots or examples
- Missing code comments in complex functions
- Incomplete feature explanations
- Missing troubleshooting information
- Inadequate accessibility documentation
- Missing development workflow documentation

Provide specific recommendations with:
- Priority levels for each documentation update
- Suggested content improvements
- Template structures for missing docs
- Code comment enhancement suggestions
