extends Node

## Manages accessibility features and screen reader support

signal accessibility_mode_changed(enabled: bool)
signal screen_reader_announcement(text: String)

# === CONSTANTS ===
const MIN_FONT_SIZE: int = 14
const MAX_FONT_SIZE: int = 24

# === PRIVATE VARIABLES ===
var _accessibility_enabled: bool = false
var _font_size_multiplier: float = 1.0
var _high_contrast_enabled: bool = false
var _reduce_motion: bool = false

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[Accessibility] Manager initialized")
	_load_accessibility_settings()

func enable_accessibility() -> void:
	"""Enable accessibility features"""
	_accessibility_enabled = true
	_high_contrast_enabled = true
	_reduce_motion = true
	accessibility_mode_changed.emit(true)
	announce("Accessibility features enabled")

func disable_accessibility() -> void:
	"""Disable accessibility features"""
	_accessibility_enabled = false
	_high_contrast_enabled = false
	_reduce_motion = false
	accessibility_mode_changed.emit(false)

func announce(text: String) -> void:
	"""Announce text for screen readers"""
	if _accessibility_enabled:
		screen_reader_announcement.emit(text)
		print("[Accessibility] Announced: " + text)

func set_font_size_multiplier(multiplier: float) -> void:
	"""Set the font size multiplier"""
	_font_size_multiplier = clamp(multiplier, 0.8, 2.0)
	_apply_font_size_changes()

func is_high_contrast_enabled() -> bool:
	"""Check if high contrast mode is enabled"""
	return _high_contrast_enabled

func is_reduce_motion_enabled() -> bool:
	"""Check if reduce motion is enabled"""
	return _reduce_motion

func is_screen_reader_enabled() -> bool:
	"""Check if screen reader support is enabled"""
	return _accessibility_enabled

func is_accessibility_enabled() -> bool:
	"""Check if any accessibility features are enabled"""
	return _accessibility_enabled

# === PRIVATE METHODS ===

func _load_accessibility_settings() -> void:
	"""Load accessibility settings from user preferences"""
	# TODO: Load from SettingsManager when available
	pass

func _apply_font_size_changes() -> void:
	"""Apply font size changes to UI"""
	# TODO: Implement when UI system is ready
	pass
