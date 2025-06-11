# How to Use NEUROVIS_PROMPT_ENGINEERING.json

## Quick Start

The `NEUROVIS_PROMPT_ENGINEERING.json` file is your comprehensive guide for creating effective prompts for AI-assisted development of NeuroVis.

### Access the Guidelines

1. **In your editor**: Open `NEUROVIS_PROMPT_ENGINEERING.json`
2. **Quick reference**: Check `docs/QUICK_PROMPT_REFERENCE.md` for copy-paste templates
3. **Example prompts**: See the `completeExamples` section in the JSON

### Using the Prompt Formula

The NeuroVis prompt formula from the JSON:
```
[Godot Context] + [Educational Purpose] + [File Location] + 
[Requirements] + [Autoload Integration] + [Accessibility] = Effective Prompt
```

### Example Usage

1. **Find the right template** in `domainPatterns`:
   - 3D Interaction System
   - Assessment System  
   - UI Components
   - Teacher Tools

2. **Fill in the template** with your specific component details

3. **Check the quality criteria** in `qualityEvaluation.criteria`

4. **Use a complete example** from `completeExamples` as reference

### Quick Example

For implementing a new UI component:
```json
{
  "role": "You are creating educational UI for NeuroVis in Godot",
  "task": "Build ProgressRing in src/ui/components/",
  "visualDesign": "Clean, educational, age-appropriate for high school+",
  "responsiveness": "Support 720p to 4K displays",
  "accessibility": "Full keyboard nav, screen reader, high contrast mode",
  "integration": "Connect to ProgressTracker autoload",
  "output": ".gd and .tscn files with proper scene structure"
}
```

### Workflow Integration

1. Check `PROJECT_PROGRESS.md` for next task
2. Find appropriate pattern in the JSON
3. Create your prompt using the template
4. After implementation: `./scripts/update_progress.sh "task" "done"`

The JSON file contains everything you need to create consistent, effective prompts for NeuroVis development!
