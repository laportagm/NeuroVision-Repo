---
allowed-tools: Bash(godot:*), Bash(find:*), Bash(grep:*), Bash(rg:*), Bash(ls:*), Bash(cat:*), Bash(head:*), Bash(tail:*), Read(*), Write(*), Edit(*), MultiEdit(*), Glob(*), Grep(*), mcp__godot__launch_editor(*), mcp__godot__run_project(*), mcp__godot__get_debug_output(*), mcp__godot__stop_project(*), mcp__godot__get_godot_version(*), mcp__godot__list_projects(*), mcp__godot__get_project_info(*), mcp__godot__create_scene(*), mcp__godot__add_node(*), mcp__godot__save_scene(*), mcp__godot__get_uid(*), mcp__godot__update_project_uids(*), mcp__filesystem-assets__read_file(*), mcp__filesystem-assets__read_multiple_files(*), mcp__filesystem-assets__write_file(*), mcp__filesystem-assets__edit_file(*), mcp__filesystem-assets__directory_tree(*), mcp__filesystem-assets__search_files(*), mcp__sequential-thinking__sequentialthinking(*)
description: Comprehensive Godot project testing, debugging, and error resolution using MCP servers
---

# Godot Project Fix & Validation Command

Comprehensively test, debug, and resolve all Godot editor errors, warnings, and issues in the NeuroVision educational platform. Use all available MCP servers for maximum efficiency and lasting solutions.

## Target Area

**Focus Area**: $ARGUMENTS (or "all" for comprehensive check)

## Project Context Analysis

**Godot Version**: !`godot --version`  
**Project Path**: `/Users/gagelaporta/Desktop/NeuroVision-Repo`  
**Project Info**: !`mcp__godot__get_project_info`  
**Current Branch**: !`git branch --show-current`  
**Recent Changes**: !`git status --porcelain`  

## Project Configuration

**Main Configuration**: @project.godot  
**Scene Structure**: !`find scenes/ -name "*.tscn" | head -10`  
**Script Files**: !`find src/ -name "*.gd" | wc -l`  
**Autoload Count**: !`grep -c "=" project.godot | grep autoload -A 20`  

## Educational Platform Status

**Main Development Guide**: @docs/CLAUDE.md  
**Architecture Overview**: @docs/auto-generated/current-architecture.md  
**Debug Workflow**: @docs/workflows/debugging.md  

## Task Execution

Use sequential thinking to plan and execute a comprehensive Godot project validation and fix process:

### Phase 1: Project Health Assessment

**1.1 Godot Engine Validation**
- Verify Godot 4.4.1 installation and compatibility
- Check project configuration integrity
- Validate scene and script references
- Identify missing dependencies

**1.2 Educational Autoload System Validation**
- Test all 13 autoload services (UnifiedColorManager, CoreSystemManager, etc.)
- Verify educational platform initialization sequence
- Check autoload dependency chains
- Validate educational service health

**1.3 Scene and Script Validation**
- Check all scene files for missing scripts or resources
- Validate script syntax and compilation
- Check for broken node references
- Verify educational scene structure integrity

### Phase 2: Comprehensive Testing

**2.1 Project Launch Testing**
- Launch Godot editor using MCP server
- Check for editor console errors and warnings
- Validate project loads without critical errors
- Test main scene functionality

**2.2 Educational System Testing**
- Test MainMenu scene Material 3 integration
- Test EnhancedExplorationScene 3D brain interaction
- Validate educational UI component functionality
- Check theme system and color management

**2.3 Performance and Compatibility Testing**
- Validate Intel UHD 620 performance targets (30+ FPS)
- Test educational accessibility features (WCAG AAA)
- Check memory usage and optimization
- Verify educational analytics integration

### Phase 3: Error Resolution and Optimization

**3.1 Critical Error Resolution**
- Fix any compilation errors or script issues
- Resolve missing resource references
- Fix broken node paths and scene references
- Address autoload initialization failures

**3.2 Warning and Issue Resolution**
- Address all Godot editor warnings
- Fix deprecated API usage
- Resolve performance warnings
- Clean up unused resources and imports

**3.3 Educational Platform Optimization**
- Optimize brain model loading and rendering
- Enhance educational UI responsiveness
- Improve theme system performance
- Validate medical accuracy of educational content

### Phase 4: Long-term Stability

**4.1 Project Structure Validation**
- Ensure proper file organization following NeuroVision standards
- Validate educational component architecture
- Check scene hierarchy and node structure
- Verify asset organization and references

**4.2 Documentation and Workflow Updates**
- Update debugging workflow with new solutions found
- Document any architectural changes made
- Update auto-generated documentation if structure changed
- Add troubleshooting steps for future reference

**4.3 Preventive Measures**
- Implement additional error checking in critical systems
- Add validation functions for educational components
- Enhance debug console commands for system monitoring
- Create automated testing procedures for educational workflows

## MCP Server Utilization Strategy

### Godot MCP Server Usage
```bash
# Project validation and testing
mcp__godot__get_project_info → Project health assessment
mcp__godot__launch_editor → Editor validation
mcp__godot__run_project → Runtime testing
mcp__godot__get_debug_output → Error capture and analysis
mcp__godot__stop_project → Clean shutdown testing

# Scene and node management
mcp__godot__create_scene → Test scene creation capability
mcp__godot__add_node → Test node addition functionality
mcp__godot__save_scene → Test scene saving integrity
mcp__godot__get_uid → UID system validation
mcp__godot__update_project_uids → UID consistency check
```

### Filesystem MCP Server Usage
```bash
# Project structure analysis
mcp__filesystem-assets__directory_tree → Complete structure scan
mcp__filesystem-assets__search_files → Find problematic files
mcp__filesystem-assets__read_multiple_files → Batch file analysis
mcp__filesystem-assets__edit_file → Efficient bulk fixes

# File integrity checking
mcp__filesystem-assets__get_file_info → File metadata validation
mcp__filesystem-assets__read_file → Individual file inspection
```

### Sequential Thinking Usage
```bash
# Complex problem solving
mcp__sequential-thinking__sequentialthinking → 
- Break down complex issues into manageable steps
- Plan multi-phase resolution strategies
- Analyze dependencies and resolution order
- Verify solutions before implementation
```

## Specific Validation Targets

### Educational Autoload Systems (Priority 1)
- **UnifiedColorManager**: Theme and color system integrity
- **CoreSystemManager**: Core platform health and error recovery
- **UISystemManager**: Educational UI coordination and lifecycle
- **EducationalPlatformManager**: Learning workflow management
- **ResourceManager**: 3D brain model loading and optimization
- **AssessmentService**: Educational quiz and assessment functionality
- **HighlightMaterialManager**: 3D brain interaction feedback
- **ProgressTracker**: Learning analytics and progress monitoring
- **PerformanceMonitor**: Performance validation and optimization
- **AuthenticationManager**: Educational access control
- **NetworkManager**: Educational content synchronization
- **DebugSystem**: Development and diagnostic tools

### Educational Scene Validation (Priority 2)
- **MainMenu.tscn**: Material 3 integration and navigation
- **EnhancedExplorationScene.tscn**: 3D brain interaction and rendering
- **StructureInfoPanel.tscn**: Educational content display
- **QuizPanel.tscn**: Assessment interface functionality

### Performance and Accessibility (Priority 3)
- Intel UHD 620 compatibility (30+ FPS minimum)
- WCAG AAA accessibility compliance
- Medical-grade reliability and accuracy
- Educational effectiveness and engagement

## Success Criteria

✅ **Zero Critical Errors**: No compilation or runtime errors  
✅ **Zero Warnings**: All Godot editor warnings resolved  
✅ **Educational Systems Functional**: All 13 autoloads operational  
✅ **Scenes Load Correctly**: All educational scenes functional  
✅ **Performance Targets Met**: 60+ FPS achieved, 30+ FPS minimum validated  
✅ **Accessibility Compliance**: WCAG AAA standards maintained  
✅ **Educational Features Working**: Brain interaction, assessment, analytics  
✅ **Documentation Updated**: Debugging workflow enhanced with solutions  

## Error Resolution Documentation

Document all fixes and solutions in the debugging workflow:

```markdown
## Recent Solutions (Claude Code Updates)
- 2025-06-21: [Specific error resolved and solution implemented]
- [Solution description with prevention measures]
```

## Long-term Stability Measures

1. **Automated Validation**: Implement project health checks
2. **Preventive Error Handling**: Add validation to critical systems
3. **Enhanced Debug Tools**: Improve diagnostic capabilities
4. **Documentation Updates**: Keep troubleshooting guides current
5. **Testing Procedures**: Create automated testing workflows

Focus on creating lasting solutions that prevent similar issues from recurring and enhance the overall stability and reliability of the NeuroVision educational platform.