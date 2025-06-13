# Performance Audit

Analyze performance issues and optimization opportunities.

## Arguments

- `$1` (focus): "all", "frontend", "backend", "rendering", "gameplay" (default: "all")
- `$2` (environment): "debug", "release", "both" (default: "both")

## Usage

```bash
/performance-audit
/performance-audit rendering release
/performance-audit gameplay debug
/performance-audit all both
```

## Prompt

Perform performance audit focusing on: $1 for environment: $2

Analyze:
- Code efficiency and optimization opportunities
- Rendering performance and GPU usage
- Memory usage patterns and potential leaks
- CPU-intensive operations and bottlenecks
- Asset loading and caching strategies
- Scene loading and instantiation performance
- Physics simulation performance
- Audio processing efficiency

For this Godot project, specifically examine:

**Rendering Performance:**
- 3D scene complexity and polygon counts
- Texture sizes and compression settings
- Shader performance and optimization
- Lighting and shadow quality vs performance
- Viewport and camera optimization
- LOD (Level of Detail) implementation

**Gameplay Performance:**
- _process() and _physics_process() efficiency
- Signal/callback performance
- Input handling responsiveness
- AI and game logic optimization
- Animation and tween performance
- UI update frequency and efficiency

**Memory Management:**
- Asset preloading vs on-demand loading
- Scene instantiation and cleanup
- Memory pools and object reuse
- Texture streaming and management
- Audio sample management
- GC pressure and allocation patterns

**System Performance:**
- File I/O operations and caching
- Network operations (if applicable)
- Threading and background operations
- Platform-specific optimizations
- Battery usage on mobile platforms

Provide specific optimization recommendations with:
- Expected performance impact
- Implementation complexity
- Compatibility considerations
- Profiling data interpretation
- Before/after measurement strategies
- Platform-specific optimizations
- Trade-offs between quality and performance

Focus on optimizations that will improve:
- Frame rate stability and consistency
- Loading times and responsiveness
- Memory usage and efficiency
- Battery life (mobile platforms)
- User experience and interaction quality
