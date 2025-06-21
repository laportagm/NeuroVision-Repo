---
allowed-tools: Read(*), Write(*), Edit(*), MultiEdit(*), Bash(find:*), Bash(wc:*), Bash(grep:*), mcp__filesystem-assets__read_file(*), mcp__filesystem-assets__read_multiple_files(*), mcp__filesystem-assets__write_file(*), mcp__filesystem-assets__edit_file(*), mcp__filesystem-assets__directory_tree(*)
description: Update relevant documentation when project code, structure, or functionality changes
---

# Auto-Update Documentation Command

You need to update the relevant documentation based on changes to the project. Analyze what has changed and update the appropriate documentation files to keep them current and accurate.

## Context Analysis

**Target File/Area**: $ARGUMENTS  
**Project Structure**: !`find src/ -name "*.gd" | head -20`  
**Recent Git Changes**: !`git status --porcelain`  
**Current Autoloads**: !`grep -A 20 "^\[autoload\]" project.godot`  

## File Content Context

**Project Configuration**: @project.godot  
**Current Architecture Doc**: @docs/auto-generated/current-architecture.md  
**File Index**: @docs/auto-generated/file-index.md  

## Your Task

Based on the provided context and target file/area ($ARGUMENTS), update the relevant documentation files:

### 1. **Auto-Generated Documentation Updates**

**If project structure changed:**
- Update `docs/auto-generated/current-architecture.md` with new autoloads, systems, or structural changes
- Update `docs/auto-generated/file-index.md` with new file locations and patterns
- Add timestamp and change description to "Recent Changes" sections

**If autoloads changed:**
- Scan project.godot for autoload changes
- Update architecture overview with new service descriptions
- Update file index with new autoload locations
- Verify all 13+ autoload systems are documented correctly

### 2. **Template Updates**

**If new patterns discovered:**
- Update `docs/templates/ui-component-template.md` with new UI patterns
- Update `docs/templates/autoload-template.md` with new service patterns
- Update `docs/templates/scene-template.md` with new scene patterns
- Add discoveries to "Recent Improvements" sections with date

### 3. **Workflow Updates**

**If new procedures discovered:**
- Update `docs/workflows/ui-development.md` with new UI development steps
- Update `docs/workflows/performance-optimization.md` with new optimization techniques
- Update `docs/workflows/debugging.md` with new debugging solutions
- Document new troubleshooting steps in appropriate workflow files

### 4. **Reference Documentation Updates**

**If standards or requirements changed:**
- Update `docs/reference/standards.md` with new coding standards
- Update performance targets if new optimizations were implemented
- Update accessibility requirements if new compliance features added

## Update Guidelines

### Auto-Generated Files Update Pattern:
```markdown
<!-- CLAUDE CODE: Add your improvements here with date -->
- 2025-06-21: [Description of change/discovery]
- [Previous entries...]
```

### Template Enhancement Pattern:
```markdown
## Recent Improvements (Claude Code Updates)
- 2025-06-21: [New pattern or improvement discovered]
- [Previous improvements...]
```

### File Index Update Pattern:
```markdown
### Recent File Changes (Claude Code Updates)
- 2025-06-21: [File changes, new components, structure modifications]
- [Previous changes...]
```

## Specific Update Actions

**For UI Changes:**
1. Update file index if new UI components created
2. Update UI development workflow if new patterns discovered
3. Update UI component template if better patterns found

**For Autoload Changes:**
1. Regenerate current architecture overview
2. Update autoload template if new patterns discovered
3. Update file index with new autoload locations

**For Scene Changes:**
1. Update architecture overview with scene modifications
2. Update scene template if new patterns discovered
3. Update file index with new scene locations

**For Performance Changes:**
1. Update performance optimization workflow
2. Update architecture overview with performance improvements
3. Update standards if new performance requirements

**For Educational Feature Changes:**
1. Update educational integration patterns in templates
2. Update workflow documentation with new educational procedures
3. Update architecture overview with new educational systems

## Critical Requirements

- **Preserve History**: Always add to "Recent Changes/Improvements" sections, never replace
- **Date Stamp**: Include current date (2025-06-21) with all updates
- **Claude Code Attribution**: Mark updates as "by Claude Code" for self-updating tracking
- **Maintain Structure**: Keep existing documentation structure and formatting
- **Update Multiple Files**: Update all relevant documentation files, not just one
- **Validate References**: Ensure file paths and references remain accurate

## Success Criteria

✅ **Auto-generated documentation reflects current project state**  
✅ **Templates include any new patterns discovered**  
✅ **Workflows document any new procedures**  
✅ **File index accurately maps current project structure**  
✅ **All updates include timestamps and change descriptions**  
✅ **Documentation maintains self-updating format for future Claude Code sessions**

Focus on making the documentation more valuable and accurate for future autonomous development sessions.