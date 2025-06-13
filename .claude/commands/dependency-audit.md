# Dependency Audit

Review and manage project dependencies, plugins, and external resources.

## Arguments

- `$1` (action): "analyze", "update", "remove-unused", "security-check" (default: "analyze")
- `$2` (include_dev): "true", "false" (default: "true")

## Usage

```bash
/dependency-audit
/dependency-audit analyze true
/dependency-audit update false
/dependency-audit remove-unused true
/dependency-audit security-check true
```

## Prompt

Perform dependency audit with action: $1
Include dev dependencies: $2

For this Godot project, analyze:
- Godot addons and plugins in the addons/ folder
- External assets and their sources
- Third-party scripts and libraries
- Git submodules or external repositories
- Build tools and development dependencies
- Asset pipeline dependencies

Check for:
- Unused addons or plugins
- Outdated plugins that need updates
- Security vulnerabilities in third-party code
- License compatibility issues
- Performance impact of heavy dependencies
- Alternative plugins or solutions
- Dependency conflicts between addons
- Missing dependencies for proper functionality

Specific to Godot projects:
- Plugin compatibility with current Godot version
- Asset dependencies and their update status
- External tool integrations (build scripts, etc.)
- Development tool dependencies

Provide recommendations for:
- Updates to newer, more secure versions
- Removal of unused or redundant dependencies
- Alternative solutions that might be better
- Security patches or workarounds
- Performance optimizations
- License compliance requirements

Include impact assessment for each recommendation:
- Compatibility risks
- Performance implications
- Development workflow changes
- Breaking changes to consider
