extends Node

## Simple test to verify color system functionality

func _ready():
	print("\n========== SIMPLE COLOR SYSTEM TEST ==========")
	
	# Test 1: Basic color resolution
	print("\n[Test 1] Basic Color Resolution:")
	var primary = M3DesignTokens.get_color("primary")
	print("  Primary color: %s" % str(primary))
	print("  Expected: %s" % str(M3DesignTokens.M3_COLORS["primary"]))
	print("  Match: %s" % str(primary == M3DesignTokens.M3_COLORS["primary"]))
	
	# Test 2: Brain structure colors
	print("\n[Test 2] Brain Structure Colors:")
	var hippo = M3DesignTokens.get_color("hippocampus")
	print("  Hippocampus color: %s" % str(hippo))
	print("  Expected: %s" % str(M3DesignTokens.BRAIN_STRUCTURE_COLORS["hippocampus"]))
	print("  Match: %s" % str(hippo == M3DesignTokens.BRAIN_STRUCTURE_COLORS["hippocampus"]))
	
	# Test 3: Color migration
	print("\n[Test 3] Color Migration:")
	var mapping = M3ColorMigrator.find_closest_token(Color.WHITE)
	print("  WHITE maps to: %s (confidence: %.2f)" % [mapping.token_path, mapping.confidence])
	
	# Test 4: Semantic colors
	print("\n[Test 4] Semantic Colors:")
	var button_primary = M3DesignTokens.get_semantic_color("button_primary")
	print("  Button primary: %s" % str(button_primary))
	
	# Test 5: UI colors
	print("\n[Test 5] UI Colors:")
	var panel_color = M3DesignTokens.get_ui_color("panel")
	print("  Panel color: %s" % str(panel_color))
	
	# Test 6: Token validation
	print("\n[Test 6] Token Validation:")
	print("  Has 'primary': %s" % str(M3DesignTokens.has_token("primary")))
	print("  Has 'invalid': %s" % str(M3DesignTokens.has_token("invalid")))
	
	# Test 7: Available tokens
	print("\n[Test 7] Available Tokens:")
	var tokens = M3DesignTokens.get_available_tokens()
	print("  Total tokens: %d" % tokens.size())
	print("  Sample tokens: %s" % str(tokens.slice(0, 5)))
	
	print("\n========== TEST COMPLETE ==========")
	
	# Exit after a short delay
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()