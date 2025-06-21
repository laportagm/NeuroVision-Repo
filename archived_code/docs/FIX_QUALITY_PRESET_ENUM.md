# Quality Preset Enum Fix

## Issue
Parser Error: Cannot find member "MEDIUM" in base "GraphicsOptimizationManager.gd.QualityPreset"

## Root Cause
The QualityPreset enum in GraphicsOptimizationManager.gd uses different naming convention:
- Instead of `LOW`, `MEDIUM`, `HIGH`
- It uses: `INTEGRATED_LOW`, `INTEGRATED_MEDIUM`, `DEDICATED_LOW`, etc.

## Fix Applied

### 1. GraphicsOptimizationManager.gd (line 135-137)
```gdscript
# Before:
var detected_preset = QualityPreset.MEDIUM
if intel_opt.is_intel_gpu_detected():
    detected_preset = QualityPreset.LOW

# After:
var detected_preset = QualityPreset.INTEGRATED_MEDIUM
if intel_opt.is_intel_gpu_detected():
    detected_preset = QualityPreset.INTEGRATED_LOW
```

### 2. BrainInteractionController.gd (line 68-69)
Updated comment to reflect correct enum values:
```gdscript
# Check if using integrated graphics quality preset (0 = INTEGRATED_LOW, 1 = INTEGRATED_MEDIUM)
if settings.has("quality_preset") and settings.quality_preset <= 1:
```

## QualityPreset Enum Values
```gdscript
enum QualityPreset {
    INTEGRATED_LOW,      # 0 - Intel UHD 620 and similar
    INTEGRATED_MEDIUM,   # 1 - Intel Iris and better integrated
    DEDICATED_LOW,       # 2 - Older dedicated GPUs
    DEDICATED_MEDIUM,    # 3 - Mid-range dedicated GPUs
    DEDICATED_HIGH,      # 4 - High-end dedicated GPUs
    MEDICAL_GRADE       # 5 - Maximum quality for medical accuracy
}
```

## Verification
The parser error has been resolved. The scene now loads without compilation errors related to the QualityPreset enum.