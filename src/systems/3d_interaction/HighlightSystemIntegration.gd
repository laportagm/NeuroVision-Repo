extends Node

## Highlight System Integration
##
## Bridges the existing BrainInteractionController with the new HighlightMaterialManager.
## This allows gradual migration to the new system without breaking existing functionality.

# === DEPENDENCIES ===
var _brain_interaction: Node3D
var _highlight_manager: Node
var _state_machines: Dictionary = {}  # MeshInstance3D -> HighlightStateMachine

# === PUBLIC METHODS ===

func _ready() -> void:
	print("[HighlightIntegration] Initializing integration layer")
	
	# Get highlight manager (should be autoloaded)
	if has_node("/root/HighlightMaterialManager"):
		_highlight_manager = get_node("/root/HighlightMaterialManager")
	else:
		# Create if not autoloaded
		_highlight_manager = preload("res://src/systems/3d_interaction/HighlightMaterialManager.gd").new()
		_highlight_manager.name = "HighlightMaterialManager"
		get_tree().root.add_child(_highlight_manager)
	
	# Wait for scene to be ready
	await get_tree().process_frame
	_connect_to_interaction_system()

func _connect_to_interaction_system() -> void:
	"""Connect to the brain interaction controller"""
	# Find the interaction controller in the scene
	var interaction_nodes = get_tree().get_nodes_in_group("brain_interaction")
	if interaction_nodes.is_empty():
		# Try to find by type
		for node in get_tree().get_nodes_in_group(""):
			if node.has_signal("structure_selected"):
				_brain_interaction = node
				break
	else:
		_brain_interaction = interaction_nodes[0]
	
	if _brain_interaction:
		print("[HighlightIntegration] Connected to interaction controller")
		_setup_signal_connections()
	else:
		push_warning("[HighlightIntegration] No brain interaction controller found")
		# Retry after a delay
		await get_tree().create_timer(1.0).timeout
		_connect_to_interaction_system()

func _setup_signal_connections() -> void:
	"""Connect to interaction controller signals"""
	if _brain_interaction.has_signal("structure_highlighted"):
		_brain_interaction.structure_highlighted.connect(_on_structure_highlighted)
	
	if _brain_interaction.has_signal("structure_selected"):
		_brain_interaction.structure_selected.connect(_on_structure_selected)
	
	if _brain_interaction.has_signal("selection_cleared"):
		_brain_interaction.selection_cleared.connect(_on_selection_cleared)
	
	print("[HighlightIntegration] Signal connections established")

# === SIGNAL HANDLERS ===

func _on_structure_highlighted(structure_name: String, mesh_instance: MeshInstance3D) -> void:
	"""Handle structure hover/highlight"""
	if not mesh_instance or not _highlight_manager:
		return
	
	# Get or create state machine for this mesh
	var state_machine = _get_or_create_state_machine(mesh_instance)
	
	# Transition to hovering state
	if state_machine.can_transition_to(_highlight_manager.HighlightState.HOVERING):
		_highlight_manager.set_highlight_state(mesh_instance, _highlight_manager.HighlightState.HOVERING)

func _on_structure_selected(structure_name: String, mesh_instance: MeshInstance3D) -> void:
	"""Handle structure selection"""
	if not mesh_instance or not _highlight_manager:
		return
	
	# Get or create state machine for this mesh
	var state_machine = _get_or_create_state_machine(mesh_instance)
	
	# Check if this is multi-selection
	var selected_count = 0
	if _brain_interaction.has_method("get_selected_structures"):
		selected_count = _brain_interaction.get_selected_structures().size()
	
	var target_state = _highlight_manager.HighlightState.SELECTED
	if selected_count > 1:
		target_state = _highlight_manager.HighlightState.MULTI_SELECTED
	
	# Transition to selected state
	if state_machine.can_transition_to(target_state):
		_highlight_manager.set_highlight_state(mesh_instance, target_state)

func _on_selection_cleared() -> void:
	"""Handle clearing all selections"""
	# Return all meshes to idle state
	for mesh in _state_machines:
		if is_instance_valid(mesh):
			_highlight_manager.set_highlight_state(mesh, _highlight_manager.HighlightState.IDLE)
	
	# Clear state machines for garbage collected meshes
	var to_remove = []
	for mesh in _state_machines:
		if not is_instance_valid(mesh):
			to_remove.append(mesh)
	
	for mesh in to_remove:
		_state_machines.erase(mesh)

# === HELPER METHODS ===

func _get_or_create_state_machine(mesh: MeshInstance3D) -> RefCounted:
	"""Get or create a state machine for a mesh"""
	if not mesh in _state_machines:
		var StateMachine = preload("res://src/systems/3d_interaction/HighlightStateMachine.gd")
		_state_machines[mesh] = StateMachine.new()
		
		# Connect state machine to material manager updates
		_state_machines[mesh].state_changed.connect(_on_state_changed.bind(mesh))
	
	return _state_machines[mesh]

func _on_state_changed(old_state: int, new_state: int, mesh: MeshInstance3D) -> void:
	"""Handle state machine state changes"""
	# State machine has validated the transition, now apply it
	_highlight_manager.set_highlight_state(mesh, new_state)

# === PUBLIC API ===

func focus_structure(mesh_instance: MeshInstance3D) -> void:
	"""Focus on a specific structure (enhanced highlight)"""
	if not mesh_instance or not _highlight_manager:
		return
	
	var state_machine = _get_or_create_state_machine(mesh_instance)
	if state_machine.can_transition_to(_highlight_manager.HighlightState.FOCUSED):
		_highlight_manager.set_highlight_state(mesh_instance, _highlight_manager.HighlightState.FOCUSED)

func disable_structure(mesh_instance: MeshInstance3D) -> void:
	"""Disable highlighting for a structure"""
	if not mesh_instance or not _highlight_manager:
		return
	
	var state_machine = _get_or_create_state_machine(mesh_instance)
	state_machine.force_state(_highlight_manager.HighlightState.DISABLED)
	_highlight_manager.set_highlight_state(mesh_instance, _highlight_manager.HighlightState.DISABLED)

func enable_structure(mesh_instance: MeshInstance3D) -> void:
	"""Re-enable highlighting for a structure"""
	if not mesh_instance or not _highlight_manager:
		return
	
	var state_machine = _get_or_create_state_machine(mesh_instance)
	state_machine.force_state(_highlight_manager.HighlightState.IDLE)
	_highlight_manager.set_highlight_state(mesh_instance, _highlight_manager.HighlightState.IDLE)

# === DEBUG ===

func get_debug_info() -> Dictionary:
	"""Get debug information about the highlight system"""
	return {
		"active_state_machines": _state_machines.size(),
		"highlight_manager_active": _highlight_manager != null,
		"brain_interaction_connected": _brain_interaction != null,
		"material_pool_size": _highlight_manager.get_pool_size() if _highlight_manager else 0,
		"active_highlights": _highlight_manager.get_active_highlight_count() if _highlight_manager else 0
	}