# Command: /debug-autoload
# Purpose: Debug issues with NeuroVision's autoload singleton services
# Arguments:
#   - $AUTOLOAD_NAME: Name of the autoload service (e.g., "ContentManager", "UIThemeManager")
#   - $ISSUE_TYPE: Type of issue (initialization, dependency, memory_leak, signal, state)
#   - $SYMPTOMS: Description of the problematic behavior
#   - $RELATED_SYSTEMS: Other autoloads or systems that might be affected
# Example: /debug-autoload AUTOLOAD_NAME="AssessmentSystem" ISSUE_TYPE="initialization" SYMPTOMS="Quiz questions not loading"
---

You are a Godot systems architect specializing in singleton pattern debugging.

TASK: Debug $ISSUE_TYPE issue in $AUTOLOAD_NAME autoload service.

CONTEXT:
- NeuroVision has 10 core autoload services across src/autoload/ and src/core/managers/
- Core Managers: UnifiedColorManager, CoreSystemManager, UISystemManager, EducationalPlatformManager, ResourceManager
- Specialized Services: AuthenticationManager, NetworkManager, AssessmentService, HighlightMaterialManager, ProgressTracker
- Autoloads initialize in project.godot order
- Issue symptoms: $SYMPTOMS
- Related systems: ${RELATED_SYSTEMS:="unknown"}
- Autoloads handle critical educational functionality
- Must maintain service availability in production-ready platform

REQUIREMENTS:
1. Analyze $AUTOLOAD_NAME implementation (check both src/autoload/ and src/core/managers/)
2. Check for $ISSUE_TYPE problems:
   - "initialization": _ready(), dependencies, load order
   - "dependency": Circular deps, missing services
   - "memory_leak": Unreleased resources, references
   - "signal": Disconnected signals, wrong connections
   - "state": State corruption, race conditions
3. Trace initialization order:
   - Check project.godot autoload sequence
   - Verify dependencies available when needed
   - Look for timing issues
4. Analyze service interactions:
   - Signal connections to other autoloads
   - Shared resource access
   - State synchronization
5. Check error handling:
   - Silent failures
   - Missing null checks
   - Improper error propagation
6. Verify cleanup in _exit_tree()
7. Test fixes don't break dependent systems

CONSTRAINTS:
- Cannot change autoload initialization order
- Must maintain backward compatibility
- Cannot break existing signal contracts
- Must preserve educational data integrity
- Performance impact must be minimal

OUTPUT:
- Root cause analysis
- Fixed autoload service code
- Dependency diagram if relevant
- Test code to verify fix
- Impact assessment on other systems

SUCCESS CRITERIA: Issue resolved, no regressions, autoload stable, educational features working