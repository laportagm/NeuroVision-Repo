# Generate Documentation

Generate missing documentation for the project.

## Arguments

- `$1` (target): "missing", "api", "readme", "setup", "contributing" (default: "missing")
- `$2` (format): "markdown", "gdscript-doc", "html", "wiki" (default: "markdown")

## Usage

```bash
/generate-docs
/generate-docs api markdown
/generate-docs setup markdown
/generate-docs contributing markdown
/generate-docs missing gdscript-doc
```

## Prompt

Generate documentation for: $1 in format: $2

Create comprehensive documentation including:
- Clear descriptions and explanations
- Usage examples and code samples
- Parameter/return value documentation
- Installation/setup instructions
- Configuration options and settings
- Troubleshooting guides and FAQ
- Contributing guidelines (if applicable)
- API reference documentation

For this NeuroVision Godot project, generate:

**API Documentation:**
- GDScript class and method documentation
- Signal documentation and usage
- Scene structure and node explanations
- Autoload script documentation
- Custom resource type documentation

**Setup Documentation:**
- Development environment setup
- Godot version requirements
- Dependency installation
- Build and export instructions
- Testing setup and execution

**Feature Documentation:**
- 3D interaction system usage
- Accessibility features and implementation
- Game mechanics and controls
- Configuration options and customization
- Asset organization and usage guidelines

**Technical Documentation:**
- Architecture overview and design patterns
- Code organization and conventions
- Performance considerations and optimization
- Security measures and best practices
- Integration guides for new features

Ensure documentation is:
- Up-to-date with current codebase
- Consistent with project style and tone
- Accessible and easy to understand
- Properly formatted and organized
- Includes relevant examples and screenshots
- Covers edge cases and troubleshooting

Generate content that follows:
- Godot documentation conventions
- Clear and concise writing style
- Proper markdown formatting
- Consistent terminology and naming
- Comprehensive but not overwhelming detail levels
