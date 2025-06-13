@tool
extends EditorScript

## Quick LOD Performance Test
##
## Run this script to quickly test LOD performance without leaving the editor.
## It will report which LOD level achieves target FPS.

func _run() -> void:
	print("\n" + "=" * 60)
	print("   QUICK LOD PERFORMANCE TEST")
	print("=" * 60 + "\n")
	
	# Check if we have the processed LOD files
	var lod_files = {
		"LOW": "res://assets/3d_models/processed/Internal_Structures_LOD/Internal-Structures_low.glb",
		"HIGH": "res://assets/3d_models/processed/Internal_Structures_LOD/Internal-Structures_high.glb",
		"MEDIUM": "res://assets/3d_models/processed/Internal-Structures_medium.glb"  # Might be in flat structure
	}
	
	print("📁 Checking LOD files...")
	var found_files = {}
	
	for lod_name in lod_files:
		var path = lod_files[lod_name]
		if ResourceLoader.exists(path):
			found_files[lod_name] = path
			print("  ✅ %s: Found at %s" % [lod_name, path])
		else:
			# Try alternative paths
			var alt_paths = [
				"res://assets/3d_models/processed/Internal-Structures_%s.glb" % lod_name.to_lower(),
				"res://assets/3d_models/processed/Internal_Structures_LOD/%s.glb" % lod_name.to_lower(),
				"res://assets/3d_models/processed/Internal_Structures_LOD/Internal-Structures p.glb"  # Special case
			]
			
			var found = false
			for alt_path in alt_paths:
				if ResourceLoader.exists(alt_path):
					found_files[lod_name] = alt_path
					print("  ✅ %s: Found at %s" % [lod_name, alt_path])
					found = true
					break
			
			if not found:
				print("  ❌ %s: Not found" % lod_name)
	
	if found_files.is_empty():
		print("\n❌ ERROR: No LOD files found!")
		print("Please ensure LOD models are in:")
		print("  /assets/3d_models/processed/Internal_Structures_LOD/")
		return
	
	# Analyze file sizes
	print("\n📊 Analyzing LOD files...")
	for lod_name in found_files:
		var path = found_files[lod_name]
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var size_mb = file.get_length() / 1048576.0
			file.close()
			print("  %s: %.2f MB" % [lod_name, size_mb])
	
	# GPU Detection
	print("\n🖥️  GPU Detection...")
	var gpu_name = RenderingServer.get_video_adapter_name()
	var gpu_vendor = RenderingServer.get_video_adapter_vendor()
	print("  GPU: %s" % gpu_name)
	print("  Vendor: %s" % gpu_vendor)
	
	# Determine if it's a low-end GPU
	var is_low_end = false
	var gpu_lower = gpu_name.to_lower()
	if "intel" in gpu_lower and ("uhd" in gpu_lower or "hd" in gpu_lower):
		is_low_end = true
		print("  ⚠️  Low-end GPU detected - Intel integrated graphics")
	
	# Recommendations
	print("\n💡 Recommendations:")
	if is_low_end:
		print("  • Start with LOW quality LOD")
		print("  • Target: 30-60 FPS")
		print("  • Consider disabling shadows")
		print("  • Use 75% render scale")
	else:
		print("  • Start with MEDIUM quality LOD")
		print("  • Target: 60+ FPS")
		print("  • Can use full quality settings")
	
	# Testing instructions
	print("\n🧪 To test performance:")
	print("  1. Run the project")
	print("  2. Open debug console (F1)")
	print("  3. Type: lod_test")
	print("  4. Or manually load: res://src/debug/LODTestingScene.tscn")
	print("\n  Keyboard shortcuts in test scene:")
	print("    • 1/2/3: Force LOW/MEDIUM/HIGH LOD")
	print("    • Enter: Start automated benchmark")
	print("    • Space: Toggle model rotation")
	
	print("\n" + "=" * 60 + "\n")