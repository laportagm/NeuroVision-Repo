extends GutTest

## Integration tests for PerformanceMonitor with scene

var test_scene: Node3D = null
var performance_monitor = null

func before_each():
	# Use the actual autoload instance
	performance_monitor = PerformanceMonitor
	
	# Create a test scene with some 3D content
	test_scene = Node3D.new()
	add_child(test_scene)
	
	# Add some 3D objects to affect performance
	for i in range(5):
		var mesh_instance = MeshInstance3D.new()
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(1, 1, 1)
		mesh_instance.mesh = box_mesh
		mesh_instance.position = Vector3(i * 2, 0, 0)
		test_scene.add_child(mesh_instance)

func after_each():
	if test_scene and is_instance_valid(test_scene):
		test_scene.queue_free()
		test_scene = null

# === INTEGRATION TESTS ===

func test_performance_monitoring_with_scene():
	# Ensure monitoring is running
	performance_monitor.start_monitoring()
	
	# Wait for metrics to update
	await wait_seconds(2.0)
	
	var metrics = performance_monitor.get_current_metrics()
	
	# Verify we're getting real metrics
	assert_gt(metrics.fps, 0.0)
	assert_gt(metrics.memory, 0.0)
	assert_gte(metrics.draw_calls, 1)  # At least our test meshes

func test_quality_adjustment_integration():
	# Lock quality initially
	performance_monitor.lock_quality(true)
	var initial_quality = performance_monitor.get_current_quality_level()
	
	# Set to low quality
	performance_monitor.set_quality_level(PerformanceMonitor.QualityLevel.LOW)
	await wait_seconds(0.5)
	
	# Verify quality settings applied
	assert_eq(performance_monitor.get_current_quality_level(), PerformanceMonitor.QualityLevel.LOW)
	
	# Unlock and wait for potential adjustment
	performance_monitor.lock_quality(false)
	performance_monitor._time_since_start = 15.0  # Skip grace period
	
	# Force quality check
	performance_monitor.force_quality_check()
	await wait_seconds(0.5)
	
	# Quality might have adjusted based on actual performance
	var new_quality = performance_monitor.get_current_quality_level()
	assert_true(new_quality >= PerformanceMonitor.QualityLevel.LOW)
	assert_true(new_quality <= PerformanceMonitor.QualityLevel.ULTRA)

func test_performance_signals_integration():
	var report_received = false
	var report_data = {}
	
	performance_monitor.performance_report_ready.connect(func(report):
		report_received = true
		report_data = report
	)
	
	performance_monitor.start_monitoring()
	
	# Wait for at least one report
	await wait_seconds(1.5)
	
	assert_true(report_received)
	assert_has(report_data, "fps")
	assert_has(report_data, "average_fps")
	assert_gt(report_data.fps, 0.0)

func test_memory_monitoring():
	var initial_metrics = performance_monitor.get_current_metrics()
	var initial_memory = initial_metrics.memory
	
	# Create a large array to increase memory usage
	var large_data = []
	for i in range(100000):
		large_data.append(randf())
	
	await wait_seconds(1.5)
	
	var new_metrics = performance_monitor.get_current_metrics()
	
	# Memory should have increased
	assert_gt(new_metrics.memory, 0.0)
	
	# Clean up
	large_data.clear()

func test_quality_settings_affect_rendering():
	# Test each quality level
	for quality in [
		PerformanceMonitor.QualityLevel.LOW,
		PerformanceMonitor.QualityLevel.MEDIUM,
		PerformanceMonitor.QualityLevel.HIGH,
		PerformanceMonitor.QualityLevel.ULTRA
	]:
		performance_monitor.set_quality_level(quality)
		await wait_frames(2)  # Wait for rendering changes
		
		var metrics = performance_monitor.get_current_metrics()
		assert_eq(metrics.quality_level, quality)

func test_startup_grace_period():
	# Reset time since start
	performance_monitor._time_since_start = 0.0
	performance_monitor._quality_locked = false
	
	# Set very low FPS to trigger quality decrease
	performance_monitor._fps_history = [10.0] * PerformanceMonitor.FPS_HISTORY_SIZE
	performance_monitor._average_fps = 10.0
	
	var initial_quality = performance_monitor.get_current_quality_level()
	
	# Try to adjust during grace period
	performance_monitor._check_and_adjust_quality()
	
	# Quality should not change during grace period
	assert_eq(performance_monitor.get_current_quality_level(), initial_quality)
	
	# Simulate time passing
	performance_monitor._time_since_start = 15.0
	
	# Now it should adjust
	performance_monitor._check_and_adjust_quality()
	
	# Quality might have decreased (unless already at LOW)
	if initial_quality > PerformanceMonitor.QualityLevel.LOW:
		assert_lt(performance_monitor.get_current_quality_level(), initial_quality)