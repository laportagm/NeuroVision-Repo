extends RefCounted

## Highlight State Machine
##
## Manages state transitions and validation for the highlighting system.
## Ensures smooth and valid transitions between highlight states.

# === IMPORTS ===
const HighlightState = preload("res://src/systems/3d_interaction/HighlightMaterialManager.gd").HighlightState

# === SIGNALS ===
signal state_changed(old_state: HighlightState, new_state: HighlightState)
signal transition_denied(from_state: HighlightState, to_state: HighlightState)

# === PRIVATE VARIABLES ===
var _current_state: HighlightState = HighlightState.IDLE
var _previous_state: HighlightState = HighlightState.IDLE
var _locked: bool = false

# Valid state transitions
var _valid_transitions: Dictionary = {
	HighlightState.IDLE: [
		HighlightState.HOVERING,
		HighlightState.SELECTED,
		HighlightState.DISABLED
	],
	HighlightState.HOVERING: [
		HighlightState.IDLE,
		HighlightState.SELECTED,
		HighlightState.FOCUSED,
		HighlightState.DISABLED
	],
	HighlightState.SELECTED: [
		HighlightState.IDLE,
		HighlightState.HOVERING,
		HighlightState.FOCUSED,
		HighlightState.MULTI_SELECTED,
		HighlightState.DISABLED
	],
	HighlightState.MULTI_SELECTED: [
		HighlightState.SELECTED,
		HighlightState.IDLE,
		HighlightState.DISABLED
	],
	HighlightState.FOCUSED: [
		HighlightState.SELECTED,
		HighlightState.HOVERING,
		HighlightState.IDLE,
		HighlightState.DISABLED
	],
	HighlightState.DISABLED: [
		HighlightState.IDLE
	]
}

# === PUBLIC METHODS ===

func get_current_state() -> HighlightState:
	"""Get the current state"""
	return _current_state

func get_previous_state() -> HighlightState:
	"""Get the previous state"""
	return _previous_state

func can_transition_to(new_state: HighlightState) -> bool:
	"""Check if transition to new state is valid"""
	if _locked:
		return false
	
	if _current_state == new_state:
		return false
	
	if _current_state in _valid_transitions:
		return new_state in _valid_transitions[_current_state]
	
	return false

func transition_to(new_state: HighlightState) -> bool:
	"""Attempt to transition to a new state"""
	if not can_transition_to(new_state):
		transition_denied.emit(_current_state, new_state)
		return false
	
	_previous_state = _current_state
	_current_state = new_state
	state_changed.emit(_previous_state, _current_state)
	return true

func force_state(new_state: HighlightState) -> void:
	"""Force a state change (bypasses validation)"""
	if _current_state != new_state:
		_previous_state = _current_state
		_current_state = new_state
		state_changed.emit(_previous_state, _current_state)

func lock() -> void:
	"""Lock the state machine (prevents transitions)"""
	_locked = true

func unlock() -> void:
	"""Unlock the state machine"""
	_locked = false

func is_locked() -> bool:
	"""Check if state machine is locked"""
	return _locked

func reset() -> void:
	"""Reset to idle state"""
	force_state(HighlightState.IDLE)
	_locked = false

# === STATE QUERIES ===

func is_interactive() -> bool:
	"""Check if current state allows interaction"""
	return _current_state != HighlightState.DISABLED

func is_highlighted() -> bool:
	"""Check if currently in any highlighted state"""
	return _current_state != HighlightState.IDLE and _current_state != HighlightState.DISABLED

func is_selected() -> bool:
	"""Check if in any selected state"""
	return _current_state in [HighlightState.SELECTED, HighlightState.MULTI_SELECTED, HighlightState.FOCUSED]

func get_state_name() -> String:
	"""Get human-readable state name"""
	match _current_state:
		HighlightState.IDLE: return "Idle"
		HighlightState.HOVERING: return "Hovering"
		HighlightState.SELECTED: return "Selected"
		HighlightState.MULTI_SELECTED: return "Multi-Selected"
		HighlightState.FOCUSED: return "Focused"
		HighlightState.DISABLED: return "Disabled"
		_: return "Unknown"