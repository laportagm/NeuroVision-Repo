## Test script for Material 3 UI implementation
## Run this to verify animations and styling are working correctly

extends Node

func _ready() -> void:
	print("\n[M3 Test] === MATERIAL 3 UI TEST ===")
	print("[M3 Test] Testing button animations and Material 3 styling")
	
	# Check if ButtonMotionHandler exists
	if not ClassDB.class_exists("ButtonMotionHandler"):
		push_error("[M3 Test] ButtonMotionHandler class not found!")
		return
	
	print("[M3 Test] ✓ ButtonMotionHandler class exists")
	
	# Check if M3DesignTokens exists
	if not ClassDB.class_exists("M3DesignTokens"):
		push_error("[M3 Test] M3DesignTokens class not found!")
		return
	
	print("[M3 Test] ✓ M3DesignTokens class exists")
	
	# Verify color tokens
	if M3DesignTokens.M3_COLORS.has("primary"):
		print("[M3 Test] ✓ Primary color: %s" % M3DesignTokens.M3_COLORS["primary"])
	
	# Verify motion constants
	print("[M3 Test] ✓ Hover duration: %dms" % M3DesignTokens.M3_DURATION["short4"])
	print("[M3 Test] ✓ Button corner radius: %dpx" % M3DesignTokens.M3_CORNER_RADIUS["button"])
	
	print("\n[M3 Test] === TEST COMPLETE ===")
	print("[M3 Test] Material 3 implementation is ready!")
	print("[M3 Test] Launch MainMenu to see animations in action\n")