extends Resource
class_name ModelPaths

## Configuration for brain model paths in the NeuroVision project
##
## This centralizes all model path references to make it easy to update
## when model locations change.

# Model directories
const MODEL_BASE_PATH = "res://assets/3d_models/"
const PROCESSED_PATH = "res://assets/3d_models/processed/"
const RAW_PATH = "res://assets/3d_models/raw/"

# Available models and their locations
const BRAIN_MODELS = {
	"Internal-Structures": {
		"raw": RAW_PATH + "Internal-Structures.glb",
		"high": PROCESSED_PATH + "Internal_Structures_LOD/Internal-Structures_high.glb",
		"medium": PROCESSED_PATH + "Internal_Structures_LOD/Internal-Structures p.glb",
		"low": PROCESSED_PATH + "Internal_Structures_LOD/Internal-Structures_low.glb",
		"default": PROCESSED_PATH + "Internal_Structures_LOD/Internal-Structures_low.glb"  # For Intel UHD 620
	},
	"BrainModel": {
		# Alias for compatibility
		"default": PROCESSED_PATH + "Internal_Structures_LOD/Internal-Structures_low.glb"
	}
}

# Get the path for a specific model and LOD level
static func get_model_path(model_name: String, lod: String = "default") -> String:
	if model_name in BRAIN_MODELS:
		var model_data = BRAIN_MODELS[model_name]
		if lod in model_data:
			return model_data[lod]
		elif "default" in model_data:
			return model_data["default"]
	
	# Fallback to raw path
	return RAW_PATH + model_name + ".glb"

# Check if a model exists
static func model_exists(model_name: String) -> bool:
	return model_name in BRAIN_MODELS

# Get all available model names
static func get_available_models() -> Array:
	return BRAIN_MODELS.keys()

# Get the default brain model for the educational platform
static func get_default_brain_model() -> String:
	return get_model_path("Internal-Structures", "low")  # Optimized for Intel UHD 620