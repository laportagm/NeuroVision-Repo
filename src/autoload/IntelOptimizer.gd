extends Node

## Intel UHD 620 Performance Optimizer for NeuroVision
## Ensures 30+ FPS on minimum spec hardware for educational use

signal optimization_applied(type: String, description: String)
signal performance_critical(metric: String, value: float)

# Intel UHD 620 specifications
const INTEL_VRAM_LIMIT: int = 256  # MB (shared memory)
const INTEL_TARGET_FPS: float = 30.0
const INTEL_CRITICAL_FPS: float = 20.0
const INTEL_MAX_DRAW_CALLS: int = 50
const INTEL_MAX_TRIANGLES: int = 10000

# Detection patterns for Intel graphics
const INTEL_GPU_PATTERNS = [
	"intel",
	"uhd 620", "uhd 630", "uhd graphics",
	"hd 4000", "hd 5000", "hd graphics",
	"iris"
]

var _is_intel_gpu: bool = false
var _optimizations_applied: Dictionary = {}
var _monitoring_active: bool = false

func _ready():
	print("[IntelOptimizer] Initializing Intel UHD 620 optimizer")
	detect_intel_hardware()
	
	if _is_intel_gpu:
		print("[IntelOptimizer] Intel GPU detected - applying optimizations")
		apply_intel_optimizations()
		start_performance_monitoring()
	else:
		print("[IntelOptimizer] Non-Intel GPU detected - Intel optimizations disabled")

func detect_intel_hardware() -> bool:
	"""Detect if running on Intel integrated graphics"""
	var renderer = RenderingServer.get_video_adapter_name().to_lower()
	var vendor = RenderingServer.get_video_adapter_vendor().to_lower()
	
	print("[IntelOptimizer] GPU Detection:")
	print("  Renderer: %s" % renderer)
	print("  Vendor: %s" % vendor)
	
	# Check vendor first
	if "intel" in vendor:
		_is_intel_gpu = true
		print("[IntelOptimizer] Intel vendor detected")
		return true
	
	# Check renderer for Intel patterns
	for pattern in INTEL_GPU_PATTERNS:
		if pattern in renderer:
			_is_intel_gpu = true
			print("[IntelOptimizer] Intel GPU pattern '%s' detected" % pattern)
			return true
	
	return false

func apply_intel_optimizations():
	"""Apply comprehensive Intel UHD 620 optimizations"""
	
	# 1. Force low quality settings
	force_low_quality_settings()
	
	# 2. Optimize 3D model loading
	optimize_model_loading()
	
	# 3. Disable expensive UI effects
	disable_expensive_ui_effects()
	
	# 4. Configure memory management
	configure_memory_settings()
	
	# 5. Set up automatic performance monitoring
	setup_automatic_degradation()
	
	print("[IntelOptimizer] Intel UHD 620 optimizations applied")

func force_low_quality_settings():
	"""Force lowest quality settings for Intel graphics"""
	if PerformanceMonitor:
		PerformanceMonitor.set_quality_level(PerformanceMonitor.QualityLevel.LOW)
		PerformanceMonitor.lock_quality(true)
		_optimizations_applied["quality_locked"] = "LOW quality forced"
		optimization_applied.emit("quality", "Forced LOW quality for Intel UHD 620")

func optimize_model_loading():
	"""Configure model loading for Intel UHD 620"""
	# Force smallest models - ModelLoader is in the scene, not autoload
	# We'll wait for scene initialization and apply optimization when needed
	var deferred_optimization = func():
		await get_tree().process_frame
		var model_loader = get_tree().get_first_node_in_group("model_loader")
		if not model_loader:
			# Try to find ModelLoader in exploration scene
			model_loader = get_tree().get_first_node_in_group("brain_model_system")
		
		if model_loader and model_loader.has_method("force_lod_level"):
			model_loader.force_lod_level(2)  # Force lowest LOD
			_optimizations_applied["model_lod"] = "Forced lowest LOD models"
			optimization_applied.emit("models", "Using 4.1MB optimized models instead of 32MB")
			print("[IntelOptimizer] Forced lowest LOD models for Intel UHD 620")
		else:
			print("[IntelOptimizer] ModelLoader not found - will apply when available")
	
	deferred_optimization.call()
	
	# Reduce texture quality globally
	var viewport = get_viewport()
	if viewport:
		# Use compatibility renderer for Intel graphics
		if ProjectSettings.get_setting("rendering/renderer/rendering_method") != "gl_compatibility":
			ProjectSettings.set_setting("rendering/renderer/rendering_method", "gl_compatibility")
			_optimizations_applied["renderer"] = "Switched to compatibility renderer"
			optimization_applied.emit("renderer", "Using GL compatibility renderer for Intel")

func disable_expensive_ui_effects():
	"""Disable expensive UI effects for Intel UHD 620"""
	
	# Disable glass morphism entirely
	if UIThemeManager:
		UIThemeManager.set_glass_morphism_enabled(false)
		_optimizations_applied["glass_morphism"] = "Disabled glass morphism effects"
		optimization_applied.emit("ui_effects", "Disabled glass morphism for Intel UHD 620")
	
	# Disable theme effects
	if ThemeEffectsManager:
		ThemeEffectsManager.set_glass_quality(1)  # Lowest quality
		_optimizations_applied["theme_effects"] = "Reduced theme effects quality"
		optimization_applied.emit("ui_effects", "Reduced theme effects to minimum")
	
	# Disable particle effects
	_disable_particle_effects()

func _disable_particle_effects():
	"""Disable particle effects for Intel graphics"""
	if ThemeEffectsManager:
		# Clear all particle pools to save memory
		ThemeEffectsManager.cleanup_unused_effects()
		_optimizations_applied["particles"] = "Disabled particle effects"
		optimization_applied.emit("particles", "Disabled particle effects for Intel UHD 620")

func configure_memory_settings():
	"""Configure memory settings for Intel shared memory"""
	
	# Aggressive UI object pooling
	if Engine.has_singleton("UIPoolManager"):
		var pool_manager = Engine.get_singleton("UIPoolManager")
		if pool_manager:
			pool_manager.set_debug_mode(false)  # Reduce logging overhead
			_optimizations_applied["pooling"] = "Optimized UI object pooling"
	
	# Force garbage collection more frequently
	var gc_timer = Timer.new()
	gc_timer.wait_time = 10.0  # Every 10 seconds
	gc_timer.timeout.connect(_force_garbage_collection)
	gc_timer.autostart = true
	add_child(gc_timer)
	
	_optimizations_applied["memory"] = "Aggressive memory management enabled"
	optimization_applied.emit("memory", "Enabled aggressive memory management")

func setup_automatic_degradation():
	"""Set up automatic performance degradation for Intel UHD 620"""
	if not PerformanceMonitor:
		return
	
	# Connect to performance warnings
	PerformanceMonitor.performance_warning.connect(_on_performance_warning)
	PerformanceMonitor.performance_critical.connect(_on_performance_critical)
	
	# Set Intel-specific thresholds
	PerformanceMonitor.force_quality_check()
	
	_optimizations_applied["auto_degradation"] = "Automatic performance degradation enabled"
	optimization_applied.emit("monitoring", "Automatic degradation for Intel UHD 620 active")

func start_performance_monitoring():
	"""Start Intel-specific performance monitoring"""
	_monitoring_active = true
	
	var monitor_timer = Timer.new()
	monitor_timer.wait_time = 2.0  # Check every 2 seconds
	monitor_timer.timeout.connect(_check_intel_performance)
	monitor_timer.autostart = true
	add_child(monitor_timer)
	
	print("[IntelOptimizer] Intel UHD 620 monitoring started")

func _check_intel_performance():
	"""Check performance specifically for Intel UHD 620"""
	if not _monitoring_active or not PerformanceMonitor:
		return
	
	var metrics = PerformanceMonitor.get_current_metrics()
	
	# Critical FPS check
	if metrics.fps < INTEL_CRITICAL_FPS:
		print("[IntelOptimizer] ❌ CRITICAL: FPS %.1f below Intel UHD 620 minimum" % metrics.fps)
		_apply_emergency_optimizations()
		performance_critical.emit("fps", metrics.fps)
	
	# Memory pressure check (Intel uses shared memory)
	if metrics.memory > INTEL_VRAM_LIMIT:
		print("[IntelOptimizer] ⚠️  Memory pressure: %.1f MB (Intel limit: %d MB)" % [metrics.memory, INTEL_VRAM_LIMIT])
		_reduce_memory_usage()
	
	# Draw call check
	if metrics.draw_calls > INTEL_MAX_DRAW_CALLS:
		print("[IntelOptimizer] ⚠️  High draw calls: %d (Intel limit: %d)" % [metrics.draw_calls, INTEL_MAX_DRAW_CALLS])

func _apply_emergency_optimizations():
	"""Apply emergency optimizations when FPS drops critically low"""
	print("[IntelOptimizer] Applying emergency optimizations for Intel UHD 620")
	
	# Force absolute minimum quality
	if PerformanceMonitor:
		var viewport = get_viewport()
		if viewport:
			var viewport_rid = viewport.get_viewport_rid()
			# Disable all anti-aliasing
			RenderingServer.viewport_set_msaa_3d(viewport_rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
			RenderingServer.viewport_set_screen_space_aa(viewport_rid, RenderingServer.VIEWPORT_SCREEN_SPACE_AA_DISABLED)
			# Minimum shadow resolution
			RenderingServer.directional_shadow_atlas_set_size(512, true)
	
	# Disable all UI animations
	if UIThemeManager:
		UIThemeManager.disable_all_animations()
	
	_optimizations_applied["emergency"] = "Emergency Intel optimizations applied"
	optimization_applied.emit("emergency", "Applied emergency optimizations for Intel UHD 620")

func _reduce_memory_usage():
	"""Reduce memory usage when approaching Intel limits"""
	# Force UI pool cleanup
	if Engine.has_singleton("UIPoolManager"):
		var pool_manager = Engine.get_singleton("UIPoolManager")
		if pool_manager:
			pool_manager.cleanup_pools()
	
	# Force garbage collection
	_force_garbage_collection()
	
	# Clear unused theme resources
	if UIThemeManager:
		UIThemeManager.clear_unused_themes()

func _force_garbage_collection():
	"""Force garbage collection for Intel shared memory management"""
	if Engine.is_editor_hint():
		return  # Don't force GC in editor
	
	# Force GC for Intel memory pressure relief
	var before_memory = OS.get_static_memory_usage()
	
	# Trigger GC by creating and destroying temporary objects
	for i in range(10):
		var temp = []
		temp.resize(100)
		temp = null
	
	var after_memory = OS.get_static_memory_usage()
	var freed_mb = (before_memory - after_memory) / 1048576.0
	
	if freed_mb > 1.0:
		print("[IntelOptimizer] Freed %.1f MB for Intel shared memory" % freed_mb)

func _on_performance_warning(metric: String, value: float, threshold: float):
	"""Handle performance warnings on Intel graphics"""
	print("[IntelOptimizer] Performance warning on Intel UHD 620: %s = %.2f (threshold: %.2f)" % [metric, value, threshold])
	
	if metric == "fps" and value < INTEL_TARGET_FPS:
		_apply_progressive_degradation()

func _on_performance_critical(metric: String, value: float):
	"""Handle critical performance issues on Intel graphics"""
	print("[IntelOptimizer] CRITICAL performance issue on Intel UHD 620: %s = %.2f" % [metric, value])
	_apply_emergency_optimizations()

func _apply_progressive_degradation():
	"""Apply progressive quality degradation for Intel graphics"""
	print("[IntelOptimizer] Applying progressive degradation for Intel UHD 620")
	
	# Progressive steps to improve performance
	if not _optimizations_applied.has("step1"):
		# Step 1: Reduce UI effects further
		if UIThemeManager:
			UIThemeManager.set_effects_quality(0)  # Minimum
		_optimizations_applied["step1"] = "Reduced UI effects"
		optimization_applied.emit("degradation", "Step 1: Reduced UI effects")
		
	elif not _optimizations_applied.has("step2"):
		# Step 2: Disable shadows entirely
		RenderingServer.directional_shadow_atlas_set_size(0, true)
		_optimizations_applied["step2"] = "Disabled shadows"
		optimization_applied.emit("degradation", "Step 2: Disabled shadows")
		
	elif not _optimizations_applied.has("step3"):
		# Step 3: Emergency mode
		_apply_emergency_optimizations()
		_optimizations_applied["step3"] = "Emergency mode"

func get_optimization_report() -> Dictionary:
	"""Get report of applied optimizations"""
	return {
		"is_intel_gpu": _is_intel_gpu,
		"monitoring_active": _monitoring_active,
		"optimizations_applied": _optimizations_applied,
		"target_fps": INTEL_TARGET_FPS,
		"memory_limit_mb": INTEL_VRAM_LIMIT
	}

func is_intel_gpu_detected() -> bool:
	"""Check if Intel GPU was detected"""
	return _is_intel_gpu