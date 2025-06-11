# NeuroVis Testing Framework Setup

## Current Status

The project uses the GUT (Godot Unit Test) framework for testing, but it's not currently installed. A temporary `GutTest.gd` base class has been created to allow tests to run without errors.

## Temporary Solution (Currently Active)

**File:** `/tests/GutTest.gd`
- Provides basic assertion methods (assert_true, assert_eq, etc.)
- Implements test lifecycle hooks (before_each, after_each)
- Allows existing tests to parse without errors
- Limited functionality compared to full GUT framework

## Permanent Solution: Install GUT

### Option 1: Automated Setup (Recommended)
```bash
./scripts/setup_gut.sh
```

This script will:
1. Download GUT v9.2.1
2. Extract to `addons/gut/`
3. Remove temporary `GutTest.gd`
4. Provide instructions for enabling in Godot

### Option 2: Manual Installation
1. Download GUT from: https://github.com/bitwes/Gut/releases
2. Extract to `res://addons/gut/`
3. Open project in Godot Editor
4. Go to Project > Project Settings > Plugins
5. Enable the "Gut" plugin
6. Delete `/tests/GutTest.gd`

## Running Tests

### With Temporary Framework
```bash
godot --headless --script scripts/run_tests.gd
```

### With Full GUT (After Installation)
```bash
# Command line
godot --headless -s addons/gut/gut_cmdln.gd

# Or use the GUT panel in Godot Editor (bottom dock)
```

## Test Structure

All tests follow this pattern:
```gdscript
extends GutTest

func before_each():
    # Setup code

func test_feature_name():
    # Test implementation
    assert_eq(actual, expected)

func after_each():
    # Cleanup code
```

## Test Locations

- **Unit Tests:** `/tests/unit/`
- **Integration Tests:** `/tests/integration/`
- **Performance Tests:** `/tests/performance/`
- **Accessibility Tests:** `/tests/accessibility/`

## Benefits of Full GUT Installation

1. **Rich Assertions:** More assertion types and better error messages
2. **Mocking/Stubbing:** Test doubles for complex dependencies
3. **GUI Test Runner:** Visual test execution in editor
4. **Test Filtering:** Run specific tests or test suites
5. **Code Coverage:** Track which code is tested
6. **Parameterized Tests:** Run same test with different inputs
7. **Better Async Support:** Testing signals and coroutines

## Educational Testing Requirements

Per NeuroVis standards, all tests should verify:
- ✅ Offline functionality
- ✅ Accessibility compliance
- ✅ Performance on minimum hardware (30+ FPS)
- ✅ Error handling
- ✅ Educational accuracy

## Next Steps

1. Run `./scripts/setup_gut.sh` to install full framework
2. Enable GUT plugin in Project Settings
3. Run existing tests to verify setup
4. Write new tests using full GUT features