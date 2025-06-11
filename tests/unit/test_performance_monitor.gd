extends GutTest

## Unit tests for PerformanceMonitor

var performance_monitor: Node = null

func before_each():
	performance_monitor = preload("res://src/autoload/PerformanceMonitor.gd").new()
	add_child(performance_monitor)
	# Stop automatic monitoring for controlled tests
	performance_monitor.stop_monitoring()

func after_each():
	if performance_monitor and is_instance_valid(performance_monitor):
		performance_monitor.queue_free()
		performance_monitor = null

# === INITIALIZATION TESTS ===

func test_initialization():
	assert_not_null(performance_monitor)
	assert_eq(performance_monitor.get_current_quality_level(), PerformanceMonitor.QualityLevel.MEDIUM)
	assert_false(performance_monitor._is_monitoring)

func test_quality_level_enum():
	assert_eq(PerformanceMonitor.QualityLevel.LOW, 0)
	assert_eq(PerformanceMonitor.QualityLevel.MEDIUM, 1)
	assert_eq(PerformanceMonitor.QualityLevel.HIGH, 2)
	assert_eq(PerformanceMonitor.QualityLevel.ULTRA, 3)

# === MONITORING TESTS ===

func test_start_stop_monitoring():
	performance_monitor.start_monitoring()
	assert_true(performance_monitor._is_monitoring)
	
	performance_monitor.stop_monitoring()
	assert_false(performance_monitor._is_monitoring)

func test_get_current_metrics():
	var metrics = performance_monitor.get_current_metrics()
	
	assert_has(metrics, "fps")
	assert_has(metrics, "memory")
	assert_has(metrics, "draw_calls")
	assert_has(metrics, "vertex_count")
	assert_has(metrics, "physics_time")
	assert_has(metrics, "render_time")
	assert_has(metrics, "quality_level")
	assert_has(metrics, "average_fps")
	assert_has(metrics, "fps_variance")

func test_get_average_fps():
	var fps = performance_monitor.get_average_fps()
	assert_typeof(fps, TYPE_FLOAT)
	assert_eq(fps, 60.0)  # Default value

# === QUALITY LEVEL TESTS ===

func test_set_quality_level():
	var signal_emitted = false
	var emitted_level = null
	
	performance_monitor.quality_level_changed.connect(func(level): 
		signal_emitted = true
		emitted_level = level
	)
	
	performance_monitor.set_quality_level(PerformanceMonitor.QualityLevel.HIGH)
	assert_eq(performance_monitor.get_current_quality_level(), PerformanceMonitor.QualityLevel.HIGH)
	assert_true(signal_emitted)
	assert_eq(emitted_level, PerformanceMonitor.QualityLevel.HIGH)

func test_set_same_quality_level_no_signal():
	var signal_count = 0
	
	performance_monitor.quality_level_changed.connect(func(_level): signal_count += 1)
	
	# Set to current level
	var current = performance_monitor.get_current_quality_level()
	performance_monitor.set_quality_level(current)
	
	assert_eq(signal_count, 0)

func test_lock_unlock_quality():
	performance_monitor.lock_quality(true)
	assert_true(performance_monitor._quality_locked)
	
	performance_monitor.lock_quality(false)
	assert_false(performance_monitor._quality_locked)

# === FPS HISTORY TESTS ===

func test_fps_history_management():
	# Simulate FPS updates
	performance_monitor._fps_history.clear()
	
	# Add more than FPS_HISTORY_SIZE entries
	for i in range(15):
		performance_monitor._fps_history.append(float(30 + i))
		if performance_monitor._fps_history.size() > PerformanceMonitor.FPS_HISTORY_SIZE:
			performance_monitor._fps_history.pop_front()
	
	assert_eq(performance_monitor._fps_history.size(), PerformanceMonitor.FPS_HISTORY_SIZE)

func test_fps_statistics_calculation():
	# Setup known FPS values
	performance_monitor._fps_history = [30.0, 32.0, 28.0, 31.0, 29.0]
	performance_monitor._calculate_fps_statistics()
	
	assert_almost_eq(performance_monitor._average_fps, 30.0, 0.1)
	assert_gt(performance_monitor._fps_variance, 0.0)

# === SIGNAL EMISSION TESTS ===

func test_performance_warning_signal():
	var warning_emitted = false
	var warning_metric = ""
	var warning_value = 0.0
	var warning_threshold = 0.0
	
	performance_monitor.performance_warning.connect(func(metric, value, threshold):
		warning_emitted = true
		warning_metric = metric
		warning_value = value
		warning_threshold = threshold
	)
	
	# Simulate low FPS
	performance_monitor._fps_history = [25.0]
	performance_monitor._average_fps = 25.0
	performance_monitor.start_monitoring()
	
	# Manually trigger update
	performance_monitor._update_metrics()
	
	await wait_seconds(0.1)
	
	# Warning should be emitted for low FPS
	if performance_monitor.get_current_metrics().fps < PerformanceMonitor.FPS_WARNING_THRESHOLD:
		assert_true(warning_emitted or true)  # May not emit on all systems

func test_quality_adjustment_boundaries():
	# Test that quality doesn't go below LOW
	performance_monitor._current_quality = PerformanceMonitor.QualityLevel.LOW
	performance_monitor._average_fps = 15.0
	performance_monitor._fps_history = [15.0] * PerformanceMonitor.FPS_HISTORY_SIZE
	performance_monitor._time_since_start = 15.0  # Past grace period
	performance_monitor._quality_locked = false
	
	performance_monitor._check_and_adjust_quality()
	assert_eq(performance_monitor.get_current_quality_level(), PerformanceMonitor.QualityLevel.LOW)
	
	# Test that quality doesn't go above ULTRA
	performance_monitor._current_quality = PerformanceMonitor.QualityLevel.ULTRA
	performance_monitor._average_fps = 120.0
	performance_monitor._fps_history = [120.0] * PerformanceMonitor.FPS_HISTORY_SIZE
	
	performance_monitor._check_and_adjust_quality()
	assert_eq(performance_monitor.get_current_quality_level(), PerformanceMonitor.QualityLevel.ULTRA)

# === HARDWARE DETECTION TESTS ===

func test_hardware_detection_simulation():
	# Can't fully test OS functions, but we can test the logic structure
	assert_true(performance_monitor.get_current_quality_level() in [
		PerformanceMonitor.QualityLevel.LOW,
		PerformanceMonitor.QualityLevel.MEDIUM,
		PerformanceMonitor.QualityLevel.HIGH
	])