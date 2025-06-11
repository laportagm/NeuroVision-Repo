# NeuroVision Test Suite

## Overview
This directory contains all tests for the NeuroVision educational neuroanatomy application.

## Test Framework
Currently using a temporary `GutTest` base class located at `addons/gut/gut_test_base.gd`. This provides basic testing functionality until the full GUT framework is installed.

## Running Tests

### Option 1: Run All Tests
```bash
# From project root
godot --headless -s tests/run_tests.gd
```

### Option 2: Run Individual Test File
```bash
# Example for a specific test
godot --headless -s tests/unit/test_level7_assessment_system.gd
```

### Option 3: From Godot Editor
1. Open the test file in the Script Editor
2. Click "Run" or press F6
3. Check the Output panel for results

## Test Structure

```
tests/
├── README.md                    # This file
├── run_tests.gd                # Test runner script
├── test_gut_setup.gd           # Verify test framework works
├── unit/                       # Unit tests
│   ├── test_autoload_fixes.gd
│   ├── test_brain_interaction_controller.gd
│   ├── test_level3_brain_model.gd
│   ├── test_level5_content_management.gd
│   ├── test_level6_enhanced_interaction.gd
│   ├── test_level7_assessment_system.gd
│   ├── test_model_loader.gd
│   └── test_performance_monitor.gd
└── integration/                # Integration tests
    ├── test_brain_interaction_integration.gd
    ├── test_brain_model_loading.gd
    ├── test_core_systems.gd
    └── test_level4_interaction.gd
```

## Writing Tests

All test files should extend `GutTest`:

```gdscript
extends GutTest

func before_each():
    # Setup before each test
    pass

func after_each():
    # Cleanup after each test
    pass

func test_example():
    assert_true(true, "This should pass")
    assert_eq(1 + 1, 2, "Math should work")
```

## Available Assertions

- `assert_true(condition, msg)`
- `assert_false(condition, msg)`
- `assert_eq(actual, expected, msg)`
- `assert_ne(actual, expected, msg)`
- `assert_null(value, msg)`
- `assert_not_null(value, msg)`
- `assert_gt(actual, expected, msg)`
- `assert_lt(actual, expected, msg)`
- `assert_has(dict, key, msg)`
- `assert_file_exists(path, msg)`
- `assert_has_signal(obj, signal_name, msg)`
- `assert_has_method(obj, method_name, msg)`

## Utility Functions

- `wait_frames(count)` - Wait for specified number of frames
- `wait_seconds(time)` - Wait for specified time in seconds
- `wait_for_signal(obj, signal_name, timeout)` - Wait for signal emission

## Known Issues

1. **GutTest base class errors**: If you see "Could not find base class GutTest", close and reopen the Godot editor to refresh the class cache.

2. **Autoload dependencies**: Some tests require autoload singletons to be properly configured in project.godot.

3. **3D model tests**: Tests involving 3D models require the GLB files to be present in `assets/3d_models/`.

## Installing Full GUT Framework

To upgrade to the full GUT testing framework:

1. Download GUT from: https://github.com/bitwes/Gut/releases
2. Extract to `res://addons/gut/`
3. Enable in Project Settings > Plugins
4. Update test files to use full GUT API

## Test Coverage Goals

- **Unit Tests**: Cover all individual classes and functions
- **Integration Tests**: Test system interactions
- **Performance Tests**: Ensure 60fps maintained
- **UI Tests**: Verify all panels and interactions
- **Content Tests**: Validate educational content loading