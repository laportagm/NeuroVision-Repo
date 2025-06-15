extends Node

# === PRELOADS ===
const PerformanceMonitor = preload("res://src/autoload/PerformanceMonitor.gd")

## GPU Detection and Quality Auto-Configuration
##
## Detects GPU capabilities and sets appropriate quality defaults
## for optimal performance on various hardware configurations.

signal gpu_detected(gpu_info: Dictionary)
signal quality_preset_determined(preset: PerformanceMonitor.QualityLevel)

# === CONSTANTS ===

# Known low-end GPUs that need special handling
const LOW_END_GPUS: Array[String] = [
	"Intel UHD",
	"Intel HD",
	"Intel Iris",
	"AMD Radeon Vega",  # Integrated
	"GeForce MX",       # Low-end NVIDIA
	"GeForce GTX 1050", # Entry level
	"GeForce GT"        # Very old
]

# Known high-end GPUs
const HIGH_END_GPUS: Array[String] = [
	"RTX 40",   # RTX 4090, 4080, etc.
	"RTX 30",   # RTX 3090, 3080, etc.
	"RX 7900",  # AMD high-end
	"RX 6900",
	"Arc A7"    # Intel Arc high-end
]

# Memory thresholds (in MB)
const VRAM_THRESHOLD_LOW: int = 2048      # 2GB
const VRAM_THRESHOLD_MEDIUM: int = 4096   # 4GB
const VRAM_THRESHOLD_HIGH: int = 6144     # 6GB

# === PRIVATE VARIABLES ===
var _gpu_info: Dictionary = {}
var _detected_quality: PerformanceMonitor.QualityLevel = PerformanceMonitor.QualityLevel.MEDIUM

# === PUBLIC METHODS ===

func detect_gpu() -> Dictionary:
	"""Detect GPU and determine optimal quality settings"""
	_gpu_info = _get_gpu_info()
	_detected_quality = _determine_quality_preset(_gpu_info)
	
	print("[GPUDetector] GPU Detection Results:")
	print("  Renderer: " + _gpu_info.get("renderer_name", "Unknown"))
	print("  Vendor: " + _gpu_info.get("vendor", "Unknown"))
	print("  VRAM: %d MB" % _gpu_info.get("vram_mb", 0))
	print("  Detected Quality: " + _get_quality_name(_detected_quality))
	
	gpu_detected.emit(_gpu_info)
	quality_preset_determined.emit(_detected_quality)
	
	return _gpu_info

func get_recommended_quality() -> PerformanceMonitor.QualityLevel:
	"""Get the recommended quality level based on GPU detection"""
	if _gpu_info.is_empty():
		detect_gpu()
	return _detected_quality

func get_gpu_info() -> Dictionary:
	"""Get cached GPU information"""
	if _gpu_info.is_empty():
		detect_gpu()
	return _gpu_info

func is_low_end_gpu() -> bool:
	"""Check if current GPU is considered low-end"""
	return _detected_quality == PerformanceMonitor.QualityLevel.LOW

func get_recommended_settings() -> Dictionary:
	"""Get recommended settings based on GPU"""
	# Use numeric LOD levels to avoid circular dependency
	# 0 = HIGH, 1 = MEDIUM, 2 = LOW
	var settings = {
		"lod_level": 1,  # MEDIUM
		"shadow_quality": RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM,
		"msaa": Viewport.MSAA_2X,
		"screen_space_aa": Viewport.SCREEN_SPACE_AA_FXAA,
		"use_taa": false,
		"anisotropic_filtering": 4,
		"texture_quality": 1.0,
		"render_scale": 1.0
	}
	
	match _detected_quality:
		PerformanceMonitor.QualityLevel.LOW:
			settings.lod_level = 2  # LOW
			settings.shadow_quality = RenderingServer.SHADOW_QUALITY_HARD
			settings.msaa = Viewport.MSAA_DISABLED
			settings.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			settings.anisotropic_filtering = 2
			settings.texture_quality = 0.5
			settings.render_scale = 0.75
			
		PerformanceMonitor.QualityLevel.HIGH:
			settings.lod_level = 0  # HIGH
			settings.shadow_quality = RenderingServer.SHADOW_QUALITY_SOFT_HIGH
			settings.msaa = Viewport.MSAA_4X
			settings.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			settings.use_taa = true
			settings.anisotropic_filtering = 16
			settings.texture_quality = 1.0
			settings.render_scale = 1.0
			
		PerformanceMonitor.QualityLevel.ULTRA:
			settings.lod_level = 0  # HIGH
			settings.shadow_quality = RenderingServer.SHADOW_QUALITY_SOFT_ULTRA
			settings.msaa = Viewport.MSAA_8X
			settings.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED  # MSAA is enough
			settings.use_taa = true
			settings.anisotropic_filtering = 16
			settings.texture_quality = 1.0
			settings.render_scale = 1.25  # Super sampling
	
	return settings

# === PRIVATE METHODS ===

func _get_gpu_info() -> Dictionary:
	"""Gather GPU information from RenderingServer"""
	var info = {}
	
	# Get renderer information
	info["renderer_name"] = RenderingServer.get_video_adapter_name()
	info["vendor"] = RenderingServer.get_video_adapter_vendor()
	info["renderer_api"] = _get_renderer_api_name()
	
	# Estimate VRAM (Godot doesn't provide direct access)
	info["vram_mb"] = _estimate_vram(info["renderer_name"])
	
	# Get current capabilities
	# Note: Godot 4 doesn't expose max texture size directly
	info["max_texture_size"] = 16384  # Common default for modern GPUs
	
	# Check for specific features
	info["supports_s3tc"] = OS.has_feature("s3tc")
	info["supports_etc2"] = OS.has_feature("etc2")
	
	return info

func _get_renderer_api_name() -> String:
	"""Get the current rendering API name"""
	# This is a simplified version - in practice you might need more detection
	if OS.has_feature("vulkan"):
		return "Vulkan"
	elif OS.has_feature("opengl3"):
		return "OpenGL 3"
	elif OS.has_feature("metal"):
		return "Metal"
	else:
		return "Unknown"

func _estimate_vram(renderer_name: String) -> int:
	"""Estimate VRAM based on GPU model name"""
	var name_lower = renderer_name.to_lower()
	
	# Intel integrated graphics
	if "intel" in name_lower:
		if "uhd" in name_lower or "hd" in name_lower:
			return 1024  # 1GB typical for integrated
		elif "iris" in name_lower:
			if "xe" in name_lower:
				return 4096  # 4GB for Iris Xe
			return 2048  # 2GB for older Iris
	
	# NVIDIA GPUs
	elif "nvidia" in name_lower or "geforce" in name_lower:
		if "rtx 4090" in name_lower:
			return 24576  # 24GB
		elif "rtx 4080" in name_lower:
			return 16384  # 16GB
		elif "rtx 4070" in name_lower:
			return 12288  # 12GB
		elif "rtx 3090" in name_lower:
			return 24576  # 24GB
		elif "rtx 3080" in name_lower:
			return 10240  # 10GB
		elif "rtx 3070" in name_lower:
			return 8192   # 8GB
		elif "rtx 3060" in name_lower:
			return 12288  # 12GB
		elif "gtx 1660" in name_lower:
			return 6144   # 6GB
		elif "gtx 1650" in name_lower:
			return 4096   # 4GB
		elif "gtx 1050" in name_lower:
			return 2048   # 2GB
	
	# AMD GPUs
	elif "amd" in name_lower or "radeon" in name_lower:
		if "rx 7900" in name_lower:
			return 24576  # 24GB
		elif "rx 6900" in name_lower:
			return 16384  # 16GB
		elif "rx 6800" in name_lower:
			return 16384  # 16GB
		elif "rx 6700" in name_lower:
			return 12288  # 12GB
		elif "rx 6600" in name_lower:
			return 8192   # 8GB
		elif "vega" in name_lower:
			return 2048   # 2GB typical for integrated Vega
	
	# Apple Silicon
	elif "apple" in name_lower:
		if "m2" in name_lower or "m3" in name_lower:
			return 8192   # 8GB typical
		elif "m1" in name_lower:
			return 8192   # 8GB typical
	
	# Default fallback
	return 4096  # 4GB default

func _determine_quality_preset(gpu_info: Dictionary) -> PerformanceMonitor.QualityLevel:
	"""Determine quality preset based on GPU capabilities"""
	var renderer_name = gpu_info.get("renderer_name", "").to_lower()
	var vram_mb = gpu_info.get("vram_mb", 0)
	
	# Check for low-end GPUs first
	for gpu_pattern in LOW_END_GPUS:
		if gpu_pattern.to_lower() in renderer_name:
			return PerformanceMonitor.QualityLevel.LOW
	
	# Check for high-end GPUs
	for gpu_pattern in HIGH_END_GPUS:
		if gpu_pattern.to_lower() in renderer_name:
			if vram_mb >= VRAM_THRESHOLD_HIGH:
				return PerformanceMonitor.QualityLevel.ULTRA
			else:
				return PerformanceMonitor.QualityLevel.HIGH
	
	# Determine by VRAM
	if vram_mb < VRAM_THRESHOLD_LOW:
		return PerformanceMonitor.QualityLevel.LOW
	elif vram_mb < VRAM_THRESHOLD_MEDIUM:
		return PerformanceMonitor.QualityLevel.MEDIUM
	elif vram_mb < VRAM_THRESHOLD_HIGH:
		return PerformanceMonitor.QualityLevel.HIGH
	else:
		return PerformanceMonitor.QualityLevel.ULTRA

func _get_quality_name(quality: PerformanceMonitor.QualityLevel) -> String:
	"""Get human-readable quality level name"""
	match quality:
		PerformanceMonitor.QualityLevel.LOW:
			return "Low (Performance)"
		PerformanceMonitor.QualityLevel.MEDIUM:
			return "Medium (Balanced)"
		PerformanceMonitor.QualityLevel.HIGH:
			return "High (Quality)"
		PerformanceMonitor.QualityLevel.ULTRA:
			return "Ultra (Maximum)"
		_:
			return "Unknown"