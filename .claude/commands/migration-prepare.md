# Migration Prepare

Prepare for technology migrations, version updates, or platform changes.

## Arguments

- `$1` (target): Target version, platform, or technology (e.g., "godot-4.3", "mobile", "web")
- `$2` (strategy): "gradual", "complete", "hybrid" (default: "gradual")

## Usage

```bash
/migration-prepare godot-4.3 gradual
/migration-prepare mobile complete
/migration-prepare web hybrid
/migration-prepare godot-5.0 gradual
```

## Prompt

Prepare migration plan to: $1 using strategy: $2

Analyze:
- Current technology stack compatibility
- Migration complexity and risks
- Required code changes and updates
- Breaking changes to address
- Dependency updates needed
- Asset format changes required
- Testing requirements and validation
- Timeline and milestone planning
- Rollback strategies and contingencies

For this Godot project migration, specifically address:

**Version Migration (Godot Updates):**
- API changes and deprecated functions
- Scene format updates and compatibility
- GDScript syntax changes
- Rendering pipeline changes
- Physics system updates
- Audio system modifications
- Input handling changes
- Export template updates

**Platform Migration:**
- Platform-specific code requirements
- Performance optimization needs
- UI/UX adaptation requirements
- Input method changes
- Asset optimization for target platform
- Platform-specific features integration
- Testing on target platform
- Distribution and deployment changes

**Technology Stack Changes:**
- Framework or engine migration paths
- Code conversion requirements
- Asset pipeline changes
- Build system modifications
- Development workflow updates
- Team training requirements

Create a detailed migration roadmap including:

**Phase 1: Preparation**
- Compatibility assessment
- Risk analysis and mitigation
- Tool and environment setup
- Team preparation and training
- Backup and rollback planning

**Phase 2: Core Migration**
- Critical system updates
- Core functionality migration
- Essential feature updates
- Basic testing and validation

**Phase 3: Feature Migration**
- Advanced feature updates
- Performance optimizations
- Platform-specific enhancements
- Comprehensive testing

**Phase 4: Finalization**
- Final testing and validation
- Documentation updates
- Deployment preparation
- Team knowledge transfer

Include for each phase:
- Specific tasks and deliverables
- Time estimates and dependencies
- Risk assessments and mitigation
- Testing and validation criteria
- Success metrics and milestones
- Rollback triggers and procedures
