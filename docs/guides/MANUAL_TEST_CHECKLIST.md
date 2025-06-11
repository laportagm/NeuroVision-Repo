# NeuroVision Manual Test Checklist

## Interactive Features to Test

### 1. Camera Controls
- [ ] **Left Click + Drag**: Rotate camera around brain
- [ ] **Middle Click + Drag**: Pan camera position
- [ ] **Right Click**: Select brain structure
- [ ] **Scroll Wheel**: Zoom in/out
- [ ] **Two-finger swipe** (trackpad): Rotate camera
- [ ] **Pinch** (trackpad): Zoom in/out

### 2. Keyboard Shortcuts
- [ ] **R**: Reset camera view
- [ ] **F**: Focus on selected structure
- [ ] **G**: Toggle grid visibility
- [ ] **L**: Toggle labels
- [ ] **Q**: Open quiz panel
- [ ] **H**: Open/close help overlay
- [ ] **ESC**: Return to main menu

### 3. Structure Selection
- [ ] Click structure buttons in left panel:
  - [ ] Thalamus
  - [ ] Hippocampus
  - [ ] Striatum
  - [ ] Ventricles
  - [ ] Corpus Callosum
- [ ] Right-click on 3D structures to select
- [ ] Verify selection sphere appears
- [ ] Check info panel updates with structure information

### 4. UI Elements
- [ ] **View Presets Dropdown**: Test all camera presets
- [ ] **Labels Toggle**: Check labels appear/disappear
- [ ] **Quiz Button**: Opens quiz panel
- [ ] **Help Button**: Shows control instructions
- [ ] **Status Bar**: Shows current status and FPS

### 5. Info Panel
- [ ] Displays structure name
- [ ] Shows description
- [ ] Lists functions
- [ ] Shows clinical relevance
- [ ] Quiz button in panel works
- [ ] Close button works

### 6. Quiz System
- [ ] Quiz panel opens
- [ ] Shows available assessments
- [ ] Can select an assessment
- [ ] Questions display correctly
- [ ] Can submit answers
- [ ] Shows feedback
- [ ] Can navigate between questions
- [ ] Shows results at end

### 7. Performance
- [ ] FPS counter updates
- [ ] Quality level adjusts automatically
- [ ] No stuttering during rotation
- [ ] Smooth zoom animations

### 8. Help Overlay
- [ ] Shows mouse controls
- [ ] Shows trackpad controls
- [ ] Shows keyboard shortcuts
- [ ] Shows tips
- [ ] Can be closed with H or click

## Expected Behaviors

### Selection Feedback
- Selected structure should be highlighted
- Selection sphere should appear at structure location
- Status bar should show selected structure name
- Left panel button should highlight in cyan

### Camera Behavior
- Smooth rotation without jumping
- Zoom has limits (can't go too close or far)
- Reset view returns to default angle
- Focus centers on selected structure

### Performance Indicators
- FPS should stay above 30
- Quality should adjust if FPS drops
- No memory leaks during extended use

## Bug Indicators
- [ ] Error messages in console
- [ ] Structures not selectable
- [ ] Info panel not updating
- [ ] Camera controls not responding
- [ ] UI elements not visible
- [ ] Quiz not loading questions
- [ ] Help text not displaying

## Test Completion
- [ ] All camera controls tested
- [ ] All keyboard shortcuts working
- [ ] All structures selectable
- [ ] All UI panels functional
- [ ] Quiz system operational
- [ ] Performance acceptable
- [ ] No critical errors

Sign off: _________________ Date: _________________