extends GutTest

## Test to verify GutTest base class is working

func test_basic_assertions():
	assert_true(true, "True should be true")
	assert_false(false, "False should be false")
	assert_eq(1, 1, "1 should equal 1")
	assert_ne(1, 2, "1 should not equal 2")
	assert_null(null, "null should be null")
	assert_not_null(self, "self should not be null")
	assert_gt(2, 1, "2 should be greater than 1")
	assert_lt(1, 2, "1 should be less than 2")

func test_dictionary_assertions():
	var dict = {"key": "value", "number": 42}
	assert_has(dict, "key", "Dictionary should have 'key'")
	assert_has(dict, "number", "Dictionary should have 'number'")
	assert_eq(dict.key, "value", "Key should have correct value")

func test_wait_functions():
	# Test wait_frames
	var start_frame = Engine.get_frames_drawn()
	await wait_frames(2)
	var end_frame = Engine.get_frames_drawn()
	assert_gte(end_frame, start_frame + 1, "Should have waited at least 1 frame")
	
	# Test wait_seconds (very short time)
	var start_time = Time.get_ticks_msec()
	await wait_seconds(0.1)
	var end_time = Time.get_ticks_msec()
	assert_gte(end_time - start_time, 90, "Should have waited at least 90ms")

func test_lifecycle_methods():
	# These should exist and not crash
	before_all()
	after_all()
	before_each()
	after_each()
	
	assert_true(true, "Lifecycle methods should not crash")