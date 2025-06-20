# Project Overview

Get comprehensive project context before starting work.

## Arguments

- `$1` (scope): "full", "structure", "dependencies", or "recent" (default: "full")

## Usage

```bash
/project-overview
/project-overview structure
/project-overview dependencies
/project-overview recent
```

## Prompt

Analyze this project and provide a comprehensive overview including:
- Project type, language(s), and framework(s)
- Main purpose and functionality
- Architecture and key components
- Entry points and main files
- Dependencies and external integrations
- Recent changes (if scope includes "recent")
- Current development status
- Areas that might need attention

Focus level: $1

For this NeuroVision project specifically, pay attention to:
- Godot engine integration
- 3D interaction systems
- Accessibility features
- Testing frameworks
- Asset organization
