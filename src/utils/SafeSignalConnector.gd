extends Node
class_name SafeSignalConnector

## Utility class for safe signal connections with error handling
##
## This class provides static methods to safely connect signals with proper validation
## and error handling to prevent runtime errors from invalid connections.

# === STATIC METHODS ===

static func safe_connect(source: Object, signal_name: String, target: Object, method_name: String, binds: Array = []) -> Error:
	## Safely connect a signal with validation
	if not is_instance_valid(source):
		push_error("[SafeSignalConnector] Invalid source object for signal: " + signal_name)
		return ERR_INVALID_PARAMETER
	
	if not is_instance_valid(target):
		push_error("[SafeSignalConnector] Invalid target object for method: " + method_name)
		return ERR_INVALID_PARAMETER
	
	if not source.has_signal(signal_name):
		push_error("[SafeSignalConnector] Signal not found: " + signal_name + " on " + source.get_class())
		return ERR_DOES_NOT_EXIST
	
	if not target.has_method(method_name):
		push_error("[SafeSignalConnector] Method not found: " + method_name + " on " + target.get_class())
		return ERR_DOES_NOT_EXIST
	
	# Check if already connected
	if source.is_connected(signal_name, Callable(target, method_name)):
		push_warning("[SafeSignalConnector] Signal already connected: " + signal_name + " -> " + method_name)
		return OK
	
	# Connect with error handling
	var callable = Callable(target, method_name)
	if binds.size() > 0:
		callable = callable.bind(binds)
	
	var err = source.connect(signal_name, callable)
	if err != OK:
		push_error("[SafeSignalConnector] Failed to connect signal: " + signal_name + " -> " + method_name + " (Error: " + str(err) + ")")
		return err
	
	return OK

static func safe_disconnect(source: Object, signal_name: String, target: Object, method_name: String) -> Error:
	## Safely disconnect a signal with validation
	if not is_instance_valid(source):
		return ERR_INVALID_PARAMETER
	
	if not is_instance_valid(target):
		return ERR_INVALID_PARAMETER
	
	if not source.has_signal(signal_name):
		return ERR_DOES_NOT_EXIST
	
	var callable = Callable(target, method_name)
	if not source.is_connected(signal_name, callable):
		return ERR_DOES_NOT_EXIST
	
	source.disconnect(signal_name, callable)
	return OK

static func safe_connect_lambda(source: Object, signal_name: String, lambda: Callable) -> Error:
	## Safely connect a signal to a lambda/callable
	if not is_instance_valid(source):
		push_error("[SafeSignalConnector] Invalid source object for signal: " + signal_name)
		return ERR_INVALID_PARAMETER
	
	if not source.has_signal(signal_name):
		push_error("[SafeSignalConnector] Signal not found: " + signal_name + " on " + source.get_class())
		return ERR_DOES_NOT_EXIST
	
	# Check if valid callable
	if not lambda.is_valid():
		push_error("[SafeSignalConnector] Invalid callable provided")
		return ERR_INVALID_PARAMETER
	
	var err = source.connect(signal_name, lambda)
	if err != OK:
		push_error("[SafeSignalConnector] Failed to connect signal: " + signal_name + " (Error: " + str(err) + ")")
		return err
	
	return OK

static func safe_connect_oneshot(source: Object, signal_name: String, target: Object, method_name: String, binds: Array = []) -> Error:
	## Connect a signal that will automatically disconnect after first emission
	var err = safe_connect(source, signal_name, target, method_name, binds)
	if err != OK:
		return err
	
	# Get the callable
	var callable = Callable(target, method_name)
	if binds.size() > 0:
		callable = callable.bind(binds)
	
	# Make it one-shot
	source.connect(signal_name, callable, CONNECT_ONE_SHOT)
	return OK

static func disconnect_all_from(source: Object, signal_name: String = "") -> void:
	## Disconnect all connections from a specific signal or all signals
	if not is_instance_valid(source):
		return
	
	if signal_name.is_empty():
		# Disconnect all signals
		for sig in source.get_signal_list():
			for connection in source.get_signal_connection_list(sig.name):
				source.disconnect(sig.name, connection.callable)
	else:
		# Disconnect specific signal
		if source.has_signal(signal_name):
			for connection in source.get_signal_connection_list(signal_name):
				source.disconnect(signal_name, connection.callable)