# NeuroVision Config Update 2.3.0

## Date: 2025-06-19

### Summary
Updated `.claude/config.json` to version 2.3.0 with comprehensive debug system documentation and recent project improvements.

### Changes Made

#### 1. Version Update
- Updated `config_version` from 2.2.0 to 2.3.0
- Updated `last_updated` to 2025-06-19

#### 2. Added Debug Systems
- Added `DEBUG_GUIDE.md` to context files
- Added `src/debug/DebugSystem.gd` and `src/debug/DebugConsole.gd` to key_systems
- Added debug services section to autoload architecture

#### 3. Completed Systems
- Added `comprehensive_debug_system`
- Added `in_game_debug_console`
- Added `error_detection_scripts`

#### 4. Development Workflow
- Added `debug_script`: debug_neurovision_enhanced.sh
- Added `error_check`: tools/scripts/comprehensive_error_check.sh

#### 5. Quality Assurance
- Added `debug_system` and `debug_console` references

#### 6. Error Management
- Added `debug_logging` path pattern
- Added `error_detection` script reference

#### 7. Debug Shortcuts
- Added `toggle_debug_console`: ` (backtick)
- Added `error_summary`: errors
- Added `autoload_status`: autoloads
- Added `fps_check`: fps
- Added `run_tests`: test all

#### 8. Recent Improvements
- Added new `debug_enhancements` section documenting:
  - Comprehensive debug system with real-time monitoring
  - In-game console with 40+ commands
  - Error detection scripts
  - Debug overlay
  - Profiling tools
  - Log management

#### 9. New Debug Tools Section
Added comprehensive `debug_tools` section with:
- External scripts configuration
- In-game systems documentation
- Debug commands reference
- Error detection patterns
- Debug configuration settings

### Backup
Previous config backed up to `.claude/config.backup.json`

### Validation
JSON syntax validated successfully

---

The configuration now fully documents the new debugging capabilities added to NeuroVision, making it easier for future development and troubleshooting.