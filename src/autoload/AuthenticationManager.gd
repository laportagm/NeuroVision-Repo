extends Node

## Handles user authentication and session management

signal login_successful(user_id: String)
signal login_failed(error: String)
signal logout_successful()

# === CONSTANTS ===
const SESSION_TIMEOUT: float = 3600.0  # 1 hour

# === PRIVATE VARIABLES ===
var _current_user: Dictionary = {}
var _session_timer: Timer

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[Auth] Manager initialized")
	_setup_session_timer()

func login(username: String, _password: String) -> void:
	"""Attempt to log in a user"""
	# TODO: Implement actual authentication
	if username.is_empty():
		login_failed.emit("Username cannot be empty")
		return
		
	# For now, demo mode accepts any non-empty username
	print("[Auth] Login attempt for: " + username)
	_current_user = {"id": "demo_user", "username": username}
	login_successful.emit("demo_user")
	_session_timer.start()

func logout() -> void:
	"""Log out the current user"""
	_current_user.clear()
	logout_successful.emit()
	print("[Auth] User logged out")

func get_current_user() -> Dictionary:
	"""Get the current user information"""
	return _current_user

func is_authenticated() -> bool:
	"""Check if a user is currently authenticated"""
	return not _current_user.is_empty()

# === PRIVATE METHODS ===

func _setup_session_timer() -> void:
	"""Setup the session timeout timer"""
	_session_timer = Timer.new()
	_session_timer.wait_time = SESSION_TIMEOUT
	_session_timer.timeout.connect(_on_session_timeout)
	_session_timer.one_shot = true
	add_child(_session_timer)

func _on_session_timeout() -> void:
	"""Handle session timeout"""
	if is_authenticated():
		logout()
		print("[Auth] Session timed out")
