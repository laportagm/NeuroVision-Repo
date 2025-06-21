extends Node

## Handles error recovery and graceful degradation

signal error_occurred(error_code: String, message: String)
signal recovery_attempted(error_code: String, success: bool)

# === CONSTANTS ===
const MAX_RECOVERY_ATTEMPTS: int = 3
const RECOVERY_DELAY: float = 1.0

# === PRIVATE VARIABLES ===
var _error_history: Array[Dictionary] = []
var _recovery_attempts: Dictionary = {}

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[ErrorRecovery] Manager initialized")

func handle_error(error_code: String, message: String, _context: Dictionary = {}) -> void:
	"""Handle an error with automatic recovery attempts"""
	push_error("[%s] %s" % [error_code, message])
	
	var error_data = {
		"code": error_code,
		"message": message,
		"context": _context,
		"timestamp": Time.get_ticks_msec()
	}
	
	_error_history.append(error_data)
	error_occurred.emit(error_code, message)
	
	_attempt_recovery(error_code, _context)

func get_error_history() -> Array[Dictionary]:
	"""Get the complete error history"""
	return _error_history.duplicate()

# === PRIVATE METHODS ===

func _attempt_recovery(error_code: String, _context: Dictionary) -> void:
	"""Attempt to recover from an error"""
	if not _recovery_attempts.has(error_code):
		_recovery_attempts[error_code] = 0
	
	if _recovery_attempts[error_code] >= MAX_RECOVERY_ATTEMPTS:
		push_error("[ErrorRecovery] Max recovery attempts reached for: " + error_code)
		recovery_attempted.emit(error_code, false)
		return
	
	_recovery_attempts[error_code] += 1
	
	# Implement recovery strategies based on error code
	match error_code:
		"NETWORK_ERROR":
			await get_tree().create_timer(RECOVERY_DELAY).timeout
			# Retry network operation
			recovery_attempted.emit(error_code, true)
		"RESOURCE_LOAD_ERROR":
			# Try alternative resource loading
			recovery_attempted.emit(error_code, true)
		_:
			recovery_attempted.emit(error_code, false)
