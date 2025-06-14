extends Node

## Comprehensive test suite for UI object pooling performance
## Tests both functionality and performance improvements

# === TEST CONFIGURATION ===
const TEST_ITERATIONS = 20
const QUIZ_OPTIONS_COUNT = 4
const STRUCTURE_COUNT = 60

var _test_results: Dictionary = {}
var _test_timer: Timer

# === PUBLIC METHODS ===

func _ready() -> void:
	print("=== UI POOLING PERFORMANCE TEST SUITE ===")
	print("Testing object pooling vs traditional object creation")
	
	# Setup test timer
	_setup_timer()
	
	# Run test suite
	await _run_complete_test_suite()
	
	print("=== TEST SUITE COMPLETED ===")

func _setup_timer() -> void:
	"""Setup timer for test execution"""
	_test_timer = Timer.new()
	_test_timer.wait_time = 0.1
	_test_timer.one_shot = true
	add_child(_test_timer)

# === MAIN TEST FUNCTIONS ===

func _run_complete_test_suite() -> void:
	"""Run all pooling tests"""
	await _test_pooling_system_initialization()
	await _test_quiz_button_pooling()
	await _test_structure_list_pooling()
	await _test_memory_efficiency()
	await _test_performance_comparison()
	_generate_final_report()

func _test_pooling_system_initialization() -> void:
	"""Test UIPoolManager initialization"""
	print("\n[TEST] UIPoolManager Initialization")
	
	if not UIPoolManager:
		print("❌ UIPoolManager not available")
		return
	
	# Check if essential pools exist
	var essential_pools = ["quiz_answer_button", "structure_list_item"]
	for pool_name in essential_pools:
		var stats = UIPoolManager.get_pool_stats(pool_name)
		if stats.is_empty():
			print("❌ Pool '%s' not initialized" % pool_name)
		else:
			print("✅ Pool '%s' ready - %d pre-warmed objects" % [pool_name, stats.available_count])

func _test_quiz_button_pooling() -> void:
	"""Test quiz button pooling performance"""
	print("\n[TEST] Quiz Button Pooling Performance")
	
	if not UIPoolManager:
		print("❌ UIPoolManager not available")
		return
	
	var pool_name = "quiz_answer_button"
	var start_stats = UIPoolManager.get_pool_stats(pool_name)
	
	# Test multiple get/return cycles
	var buttons: Array[Control] = []
	var start_time = Time.get_time_dict_from_system()
	
	# Get buttons from pool
	for i in range(TEST_ITERATIONS):
		for j in range(QUIZ_OPTIONS_COUNT):
			var btn = UIPoolManager.get_object(pool_name)
			if btn:
				buttons.append(btn)
	
	var get_time = Time.get_time_dict_from_system()
	
	# Return buttons to pool
	for btn in buttons:
		UIPoolManager.return_object(pool_name, btn)
	
	var return_time = Time.get_time_dict_from_system()
	
	# Calculate performance metrics
	var total_get_time = _calculate_time_diff(start_time, get_time)
	var total_return_time = _calculate_time_diff(get_time, return_time)
	var total_operations = TEST_ITERATIONS * QUIZ_OPTIONS_COUNT
	
	var end_stats = UIPoolManager.get_pool_stats(pool_name)
	
	print("✅ Quiz Button Pool Test Results:")
	print("  Operations: %d gets + %d returns" % [total_operations, total_operations])
	print("  Get Time: %.2fms (%.3fms per operation)" % [total_get_time, total_get_time / total_operations])
	print("  Return Time: %.2fms (%.3fms per operation)" % [total_return_time, total_return_time / total_operations])
	print("  Reuse Ratio: %.1f%%" % (end_stats.reuse_ratio * 100))
	
	_test_results["quiz_buttons"] = {
		"total_operations": total_operations,
		"get_time_ms": total_get_time,
		"return_time_ms": total_return_time,
		"reuse_ratio": end_stats.reuse_ratio,
		"efficiency_score": end_stats.efficiency_score
	}

func _test_structure_list_pooling() -> void:
	"""Test structure list item pooling"""
	print("\n[TEST] Structure List Pooling Performance")
	
	if not UIPoolManager:
		print("❌ UIPoolManager not available")
		return
	
	var pool_name = "structure_list_item"
	var start_stats = UIPoolManager.get_pool_stats(pool_name)
	
	# Simulate structure list rebuild (common operation)
	var start_time = Time.get_time_dict_from_system()
	var structure_buttons: Array[Control] = []
	
	# Get buttons for structure list
	for i in range(STRUCTURE_COUNT):
		var btn = UIPoolManager.get_object(pool_name)
		if btn:
			structure_buttons.append(btn)
			# Simulate structure setup
			btn.text = "Brain Structure %d" % i
	
	var build_time = Time.get_time_dict_from_system()
	
	# Clear structure list (return to pool)
	for btn in structure_buttons:
		UIPoolManager.return_object(pool_name, btn)
	
	var clear_time = Time.get_time_dict_from_system()
	
	var build_duration = _calculate_time_diff(start_time, build_time)
	var clear_duration = _calculate_time_diff(build_time, clear_time)
	var end_stats = UIPoolManager.get_pool_stats(pool_name)
	
	print("✅ Structure List Pool Test Results:")
	print("  Structures: %d items" % STRUCTURE_COUNT)
	print("  Build Time: %.2fms (%.3fms per item)" % [build_duration, build_duration / STRUCTURE_COUNT])
	print("  Clear Time: %.2fms (%.3fms per item)" % [clear_duration, clear_duration / STRUCTURE_COUNT])
	print("  Reuse Ratio: %.1f%%" % (end_stats.reuse_ratio * 100))
	
	_test_results["structure_list"] = {
		"structure_count": STRUCTURE_COUNT,
		"build_time_ms": build_duration,
		"clear_time_ms": clear_duration,
		"reuse_ratio": end_stats.reuse_ratio,
		"efficiency_score": end_stats.efficiency_score
	}

func _test_memory_efficiency() -> void:
	"""Test memory usage patterns"""
	print("\n[TEST] Memory Efficiency")
	
	if not UIPoolManager:
		print("❌ UIPoolManager not available")
		return
	
	var global_stats = UIPoolManager.get_global_stats()
	
	print("✅ Global Pool Statistics:")
	print("  Total Pools: %d" % global_stats.total_pools)
	print("  Objects Available: %d" % global_stats.total_available)
	print("  Objects In Use: %d" % global_stats.total_in_use)
	print("  Objects Created: %d" % global_stats.total_created)
	print("  Objects Reused: %d" % global_stats.total_reused)
	print("  Global Reuse Ratio: %.1f%%" % (global_stats.global_reuse_ratio * 100))
	print("  Estimated Memory Saved: %.1fMB" % global_stats.memory_saved_mb)
	
	_test_results["memory"] = global_stats

func _test_performance_comparison() -> void:
	"""Compare pooled vs non-pooled object creation"""
	print("\n[TEST] Performance Comparison: Pooled vs Non-Pooled")
	
	# Test traditional object creation
	var traditional_time = _benchmark_traditional_creation()
	
	# Test pooled object creation
	var pooled_time = _benchmark_pooled_creation()
	
	var improvement = 0.0
	if traditional_time > 0:
		improvement = ((traditional_time - pooled_time) / traditional_time) * 100.0
	
	print("✅ Performance Comparison Results:")
	print("  Traditional Creation: %.2fms" % traditional_time)
	print("  Pooled Creation: %.2fms" % pooled_time)
	print("  Performance Improvement: %.1f%%" % improvement)
	
	_test_results["performance_comparison"] = {
		"traditional_time_ms": traditional_time,
		"pooled_time_ms": pooled_time,
		"improvement_percent": improvement
	}

func _benchmark_traditional_creation() -> float:
	"""Benchmark traditional object creation"""
	var start_time = Time.get_time_dict_from_system()
	var buttons: Array[Button] = []
	
	# Create buttons traditionally
	for i in range(TEST_ITERATIONS):
		for j in range(QUIZ_OPTIONS_COUNT):
			var btn = Button.new()
			btn.text = "Option %d" % j
			btn.toggle_mode = true
			buttons.append(btn)
	
	var create_time = Time.get_time_dict_from_system()
	
	# Clean up
	for btn in buttons:
		btn.queue_free()
	
	return _calculate_time_diff(start_time, create_time)

func _benchmark_pooled_creation() -> float:
	"""Benchmark pooled object creation"""
	if not UIPoolManager:
		return 0.0
	
	var start_time = Time.get_time_dict_from_system()
	var buttons: Array[Control] = []
	
	# Get buttons from pool
	for i in range(TEST_ITERATIONS):
		for j in range(QUIZ_OPTIONS_COUNT):
			var btn = UIPoolManager.get_object("quiz_answer_button")
			if btn:
				btn.text = "Option %d" % j
				btn.toggle_mode = true
				buttons.append(btn)
	
	var get_time = Time.get_time_dict_from_system()
	
	# Return to pool
	for btn in buttons:
		UIPoolManager.return_object("quiz_answer_button", btn)
	
	return _calculate_time_diff(start_time, get_time)

func _generate_final_report() -> void:
	"""Generate comprehensive test report"""
	print("\n=== FINAL PERFORMANCE REPORT ===")
	
	if _test_results.has("performance_comparison"):
		var perf = _test_results.performance_comparison
		print("🚀 Overall Performance Improvement: %.1f%%" % perf.improvement_percent)
	
	if _test_results.has("memory"):
		var memory = _test_results.memory
		print("💾 Memory Efficiency: %.1fMB saved" % memory.memory_saved_mb)
		print("♻️  Global Reuse Ratio: %.1f%%" % (memory.global_reuse_ratio * 100))
	
	print("\n📊 Detailed Results by Component:")
	
	if _test_results.has("quiz_buttons"):
		var quiz = _test_results.quiz_buttons
		print("  Quiz Buttons:")
		print("    - Reuse Ratio: %.1f%%" % (quiz.reuse_ratio * 100))
		print("    - Efficiency Score: %.1f" % quiz.efficiency_score)
	
	if _test_results.has("structure_list"):
		var structure = _test_results.structure_list
		print("  Structure List:")
		print("    - Reuse Ratio: %.1f%%" % (structure.reuse_ratio * 100))
		print("    - Build Time per Item: %.3fms" % (structure.build_time_ms / structure.structure_count))
	
	print("\n🎯 Recommendations:")
	
	var overall_improvement = 0.0
	if _test_results.has("performance_comparison"):
		overall_improvement = _test_results.performance_comparison.improvement_percent
	
	if overall_improvement > 50:
		print("  ✅ Excellent pooling performance - system working optimally")
	elif overall_improvement > 25:
		print("  ⚠️  Good pooling performance - consider optimizing pool sizes")
	else:
		print("  ❌ Poor pooling performance - investigate pool configuration")
	
	# Educational impact assessment
	print("\n🎓 Educational Impact:")
	if overall_improvement > 30:
		print("  • Smoother quiz transitions enhance learning flow")
		print("  • Faster structure browsing improves exploration experience")
		print("  • Reduced frame drops maintain immersion")
	
	print("\n✨ UI Pooling Test Suite Complete!")

# === UTILITY METHODS ===

func _calculate_time_diff(start_time: Dictionary, end_time: Dictionary) -> float:
	"""Calculate time difference in milliseconds"""
	var start_ms = start_time.hour * 3600000 + start_time.minute * 60000 + start_time.second * 1000
	var end_ms = end_time.hour * 3600000 + end_time.minute * 60000 + end_time.second * 1000
	return abs(end_ms - start_ms)

# === DEBUG COMMANDS ===

func run_quick_test() -> void:
	"""Quick test for debug console"""
	print("Running quick pooling test...")
	await _test_quiz_button_pooling()

func check_pool_status() -> void:
	"""Check current pool status"""
	if UIPoolManager:
		var global_stats = UIPoolManager.get_global_stats()
		print("Pool Status: %d pools, %.1f%% reuse ratio" % [
			global_stats.total_pools, global_stats.global_reuse_ratio * 100
		])
	else:
		print("UIPoolManager not available")

func reset_pools() -> void:
	"""Reset all pools for testing"""
	if UIPoolManager:
		UIPoolManager.cleanup_pools()
		print("Pools reset")
	else:
		print("UIPoolManager not available")