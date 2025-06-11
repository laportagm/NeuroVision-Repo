# Example: Your Next Task Using the Prompt Guide

Based on your PROJECT_PROGRESS.md, you need to complete the PerformanceMonitor. Here's how to use the prompt guide:

## Step 1: Check Progress
Current status shows:
- ✅ Environment setup complete
- ⬜ PerformanceMonitor needs completion

## Step 2: Use This Prompt

Copy and paste this into Claude or your AI assistant:

---

You are implementing the PerformanceMonitor autoload for the NeuroVis educational neuroanatomy application using Godot 4.x and GDScript.

**File:** src/autoload/PerformanceMonitor.gd

**Context:** 
- Phase 1 core system (Week 1-2)
- Must maintain 30+ FPS on Intel UHD 620 graphics
- Students need smooth 3D brain exploration without stuttering
- No internet connection required

**Current Code Status:**
The file exists with a basic skeleton. Complete the implementation.

**Requirements:**
1. Track FPS with 60-sample rolling average using a circular buffer
2. Monitor memory usage via OS.get_static_memory_usage()
3. Implement three quality presets:
   - 'low': Disable shadows, reduce texture quality, LOD bias +2
   - 'medium': Simple shadows, normal textures, LOD bias +1  
   - 'high': Full quality, all effects enabled
4. Auto-adjust quality when average FPS < 30 for 3 consecutive seconds
5. Provide manual override via set_quality_preset(preset: String)

**Signals to Implement:**
- `signal performance_warning(metric: String, value: float)`
- `signal quality_changed(new_quality: String)`

**Integration Points:**
- ErrorRecoveryManager: Log when quality auto-adjusts
- SettingsManager: Save/load user's quality preference
- Future: LODManager will subscribe to quality_changed signal

**Accessibility Consideration:**
When quality changes automatically, queue a notification for AccessibilityManager to announce after 2 seconds (avoid interrupting current speech).

**Error Handling:**
- Validate quality preset strings
- Handle OS calls that might fail on some platforms
- Graceful fallback if performance monitoring fails

**Testing:**
Include a `simulate_low_performance()` method for testing auto-adjustment.

Please implement the complete PerformanceMonitor with all features described above. Follow NeuroVis coding standards with proper type hints and docstrings.

---

## Step 3: After Implementation

1. Test the implementation in Godot
2. Verify 30+ FPS is maintained
3. Run: `./scripts/update_progress.sh "PerformanceMonitor" "done"`
4. Commit: `git commit -m "feat: Complete PerformanceMonitor with auto quality adjustment"`

## Why This Prompt Works

✅ **Role**: "You are implementing..." - Clear context
✅ **File Location**: Exact path specified
✅ **Educational Context**: "Students need smooth 3D brain exploration"
✅ **Technical Requirements**: Numbered list with specifics
✅ **Integration**: Shows how it connects to other systems
✅ **Accessibility**: Included from the start
✅ **Error Handling**: Explicitly requested
✅ **Testing**: Includes testability features

This follows the NeuroVis prompt formula perfectly!
