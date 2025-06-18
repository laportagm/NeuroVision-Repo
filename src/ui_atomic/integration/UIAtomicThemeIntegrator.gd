extends Node
class_name UIAtomicThemeIntegrator

## Integration bridge for unified theme system with atomic design
## 
## This class ensures all ui_atomic components properly integrate with
## the existing UnifiedColorManager and Material 3 theme system

signal theme_applied_to_atomic_components()
signal atomic_component_registered(component_path: String)

# === CONSTANTS ===
const ATOMIC_COMPONENT_PATHS = [
	"res://src/ui_atomic/pages/",
	"res://src/ui_atomic/organisms/", 
	"res://src/ui_atomic/molecules/",
	"res://src/ui_atomic/atoms/"
]

# === PRIVATE VARIABLES ===
var _registered_components: Array[Node] = []
var _theme_integration_active: bool = false

# === PUBLIC METHODS ===

func _ready() -> void:
	"""Initialize atomic theme integration"""
	print("[UIAtomicThemeIntegrator] Initializing atomic design theme integration")
	
	# Connect to existing unified color manager
	if UnifiedColorManager:
		UnifiedColorManager.theme_changed.connect(_on_unified_theme_changed)
		_theme_integration_active = true
		print("[UIAtomicThemeIntegrator] ✅ Connected to UnifiedColorManager")
	else:
		push_warning("[UIAtomicThemeIntegrator] UnifiedColorManager not found")

func apply_theme_to_atomic_component(component: Node) -> void:
	"""Apply current theme to an atomic component"""
	if not _theme_integration_active:
		return
		
	# Apply theme based on component type
	if component.has_method("apply_educational_theme"):
		component.apply_educational_theme()
	elif component.has_method("apply_material3_theme"):  
		component.apply_material3_theme()
	elif component is Control:
		_apply_fallback_theme(component)

func register_atomic_component(component: Node, component_path: String = "") -> void:
	"""Register an atomic component for theme management"""
	if component in _registered_components:
		return
		
	_registered_components.append(component)
	
	# Apply current theme immediately
	apply_theme_to_atomic_component(component)
	
	# Emit registration signal
	atomic_component_registered.emit(component_path)

func get_educational_color_for_atomic(role: String, context: String = "") -> Color:
	"""Get educational color optimized for atomic components"""
	if UnifiedColorManager:
		return UnifiedColorManager.get_educational_color(role, context)
	else:
		# Fallback colors for atomic components
		match role:
			"primary": return Color.CYAN
			"secondary": return Color.BLUE  
			"surface": return Color(0.1, 0.1, 0.15, 0.9)
			_: return Color.WHITE

# === PRIVATE METHODS ===

func _apply_fallback_theme(control: Control) -> void:
	"""Apply fallback theme for components without theme methods"""
	# Apply basic Material 3 styling
	if control is Button:
		_style_atomic_button(control as Button)
	elif control is Panel or control is PanelContainer:
		_style_atomic_panel(control)

func _style_atomic_button(button: Button) -> void:
	"""Apply atomic button styling"""
	var style = StyleBoxFlat.new()
	style.bg_color = get_educational_color_for_atomic("primary")
	style.set_corner_radius_all(8)
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	style.content_margin_left = 24
	style.content_margin_right = 24
	
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_color_override("font_color", get_educational_color_for_atomic("on_primary"))

func _style_atomic_panel(panel: Control) -> void:
	"""Apply atomic panel styling"""
	var style = StyleBoxFlat.new()
	style.bg_color = get_educational_color_for_atomic("surface")
	style.set_corner_radius_all(12)
	style.shadow_size = 4
	style.shadow_color = Color(0, 0, 0, 0.3)
	
	if panel.has_method("add_theme_stylebox_override"):
		panel.add_theme_stylebox_override("panel", style)

func _on_unified_theme_changed(new_variant: String) -> void:
	"""Handle theme changes from UnifiedColorManager"""
	print("[UIAtomicThemeIntegrator] Theme changed to: " + new_variant)
	
	# Reapply theme to all registered atomic components
	for component in _registered_components:
		if is_instance_valid(component):
			apply_theme_to_atomic_component(component)
	
	theme_applied_to_atomic_components.emit()