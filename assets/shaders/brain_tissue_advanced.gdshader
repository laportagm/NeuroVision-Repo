// Advanced Brain Tissue Shader for NeuroVision
// Medical-grade brain tissue rendering with subsurface scattering,
// anatomical accuracy, and educational context adaptation.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

// === EDUCATIONAL CONTEXT UNIFORMS ===
uniform float medical_accuracy : hint_range(0.0, 1.0) = 1.0;
uniform float learning_level : hint_range(0.0, 1.0) = 0.5;  // 0=beginner, 0.5=intermediate, 1=advanced
uniform bool clinical_mode = false;
uniform bool pathology_mode = false;

// === TISSUE TYPE SELECTION ===
uniform int tissue_type : hint_range(0, 5) = 0;  
// 0=Gray Matter, 1=White Matter, 2=Blood Vessels, 3=CSF, 4=Dura Mater, 5=Pia Mater

// === BASE MATERIAL PROPERTIES ===
uniform vec4 base_color : source_color = vec4(0.85, 0.75, 0.70, 1.0);
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.7;
uniform float specular : hint_range(0.0, 1.0) = 0.5;

// === SUBSURFACE SCATTERING ===
uniform bool subsurface_enabled = true;
uniform float subsurface_strength : hint_range(0.0, 1.0) = 0.8;
uniform vec3 subsurface_color : source_color = vec3(0.9, 0.8, 0.75);
uniform float subsurface_radius : hint_range(0.0, 2.0) = 0.5;
uniform float subsurface_anisotropy : hint_range(-1.0, 1.0) = 0.0;

// === TISSUE-SPECIFIC PROPERTIES ===
uniform float tissue_density : hint_range(0.0, 1.0) = 0.8;
uniform float vascular_visibility : hint_range(0.0, 1.0) = 0.2;
uniform float myelin_sheen : hint_range(0.0, 1.0) = 0.3;
uniform float cortical_folding : hint_range(0.0, 1.0) = 0.5;

// === EDUCATIONAL ENHANCEMENTS ===
uniform float structure_highlight : hint_range(0.0, 1.0) = 0.0;
uniform vec3 highlight_color : source_color = vec3(0.2, 0.8, 1.0);
uniform float educational_contrast : hint_range(0.0, 2.0) = 1.0;
uniform float beginner_saturation_boost : hint_range(0.0, 1.0) = 0.0;

// === LIGHTING ENHANCEMENT ===
uniform float rim_lighting : hint_range(0.0, 2.0) = 0.8;
uniform vec3 rim_color : source_color = vec3(1.0, 0.9, 0.8);
uniform float ambient_enhancement : hint_range(0.0, 1.0) = 0.3;

// === PATHOLOGY SIMULATION ===
uniform float inflammation_level : hint_range(0.0, 1.0) = 0.0;
uniform float ischemia_level : hint_range(0.0, 1.0) = 0.0;
uniform float edema_level : hint_range(0.0, 1.0) = 0.0;
uniform float atrophy_level : hint_range(0.0, 1.0) = 0.0;

// === TEXTURES ===
uniform sampler2D tissue_normal_map : hint_normal;
uniform sampler2D tissue_detail_map;
uniform sampler2D vascular_map;
uniform sampler2D pathology_mask;

// === NOISE AND VARIATION ===
uniform float surface_variation : hint_range(0.0, 1.0) = 0.1;
uniform float micro_detail_scale : hint_range(0.1, 10.0) = 2.0;
uniform sampler2D noise_texture;

// === MEDICAL ACCURACY CONSTANTS ===
const vec3 GRAY_MATTER_BASE = vec3(0.85, 0.75, 0.70);
const vec3 WHITE_MATTER_BASE = vec3(0.95, 0.92, 0.88);
const vec3 BLOOD_VESSEL_BASE = vec3(0.8, 0.25, 0.25);
const vec3 CSF_BASE = vec3(0.9, 0.95, 0.98);
const vec3 DURA_MATER_BASE = vec3(0.7, 0.65, 0.60);
const vec3 PIA_MATER_BASE = vec3(0.9, 0.85, 0.8);

// Subsurface scattering parameters for different tissue types
const float GRAY_MATTER_SSS = 0.8;
const float WHITE_MATTER_SSS = 0.6;
const float BLOOD_VESSEL_SSS = 0.4;
const float CSF_SSS = 0.1;
const float DURA_MATER_SSS = 0.3;
const float PIA_MATER_SSS = 0.5;

// === UTILITY FUNCTIONS ===

vec3 get_tissue_base_color(int type) {
    switch (type) {
        case 0: return GRAY_MATTER_BASE;   // Gray Matter
        case 1: return WHITE_MATTER_BASE;  // White Matter
        case 2: return BLOOD_VESSEL_BASE;  // Blood Vessels
        case 3: return CSF_BASE;           // CSF
        case 4: return DURA_MATER_BASE;    // Dura Mater
        case 5: return PIA_MATER_BASE;     // Pia Mater
        default: return GRAY_MATTER_BASE;
    }
}

float get_tissue_subsurface_strength(int type) {
    switch (type) {
        case 0: return GRAY_MATTER_SSS;
        case 1: return WHITE_MATTER_SSS;
        case 2: return BLOOD_VESSEL_SSS;
        case 3: return CSF_SSS;
        case 4: return DURA_MATER_SSS;
        case 5: return PIA_MATER_SSS;
        default: return GRAY_MATTER_SSS;
    }
}

vec3 apply_educational_adjustments(vec3 color, float level) {
    // Beginner mode: Enhance contrast and saturation
    if (level <= 0.33) {
        color = mix(color, normalize(color) * length(color), beginner_saturation_boost);
        color = (color - 0.5) * educational_contrast + 0.5;
    }
    // Advanced mode: More realistic, subdued colors
    else if (level >= 0.67) {
        color = mix(color, color * 0.9, 0.3);
    }
    
    return color;
}

vec3 apply_pathology_effects(vec3 base_color, vec2 uv) {
    vec3 pathology_color = base_color;
    
    // Sample pathology mask if available
    vec4 pathology_data = texture(pathology_mask, uv);
    
    // Inflammation: Reddish tint
    if (inflammation_level > 0.0) {
        vec3 inflamed = mix(pathology_color, vec3(1.2, 0.8, 0.8) * pathology_color, inflammation_level * pathology_data.r);
        pathology_color = inflamed;
    }
    
    // Ischemia: Bluish/gray tint
    if (ischemia_level > 0.0) {
        vec3 ischemic = mix(pathology_color, vec3(0.8, 0.8, 1.1) * pathology_color, ischemia_level * pathology_data.g);
        pathology_color = ischemic;
    }
    
    // Edema: Increased translucency
    if (edema_level > 0.0) {
        pathology_color = mix(pathology_color, pathology_color * 1.1, edema_level * pathology_data.b);
    }
    
    // Atrophy: Darker, more muted
    if (atrophy_level > 0.0) {
        pathology_color = mix(pathology_color, pathology_color * 0.7, atrophy_level * pathology_data.a);
    }
    
    return pathology_color;
}

float calculate_subsurface_scattering(vec3 light_dir, vec3 view_dir, vec3 normal, float thickness) {
    // Approximate subsurface scattering using translucency
    vec3 light_through = light_dir + normal * subsurface_anisotropy;
    float translucency = pow(max(0.0, dot(-view_dir, light_through)), subsurface_radius * 10.0);
    
    // Tissue density affects light penetration
    float penetration = 1.0 - tissue_density;
    
    return translucency * penetration * thickness;
}

vec3 calculate_rim_lighting(vec3 normal, vec3 view_dir, vec3 base_color) {
    float rim_factor = 1.0 - max(0.0, dot(normal, view_dir));
    rim_factor = pow(rim_factor, 2.0);
    
    // Clinical mode gets enhanced rim lighting for better structure definition
    float rim_strength = clinical_mode ? rim_lighting * 1.5 : rim_lighting;
    
    return base_color + rim_color * rim_factor * rim_strength;
}

vec3 add_vascular_details(vec3 base_color, vec2 uv) {
    if (vascular_visibility <= 0.0) return base_color;
    
    vec4 vascular_data = texture(vascular_map, uv);
    
    // Add subtle blood vessel coloration
    vec3 vessel_color = mix(base_color, BLOOD_VESSEL_BASE, vascular_data.r * vascular_visibility);
    
    // Add slight specular enhancement for wet blood vessels
    // This would need to be handled in the lighting calculation
    
    return vessel_color;
}

vec3 enhance_for_medical_accuracy(vec3 color) {
    if (!clinical_mode) return color;
    
    // Medical mode: Enhance contrast for diagnostic accuracy
    color = (color - 0.5) * 1.2 + 0.5;
    
    // Slightly cool color temperature for clinical appearance
    color.r *= 0.98;
    color.b *= 1.02;
    
    return color;
}

// === NOISE AND SURFACE VARIATION ===

vec3 add_surface_micro_detail(vec3 base_color, vec2 uv, vec3 normal) {
    vec2 detail_uv = uv * micro_detail_scale;
    
    // Sample noise for surface variation
    float noise = texture(noise_texture, detail_uv).r;
    
    // Apply surface variation
    vec3 varied_color = base_color + (noise - 0.5) * surface_variation * 0.1;
    
    // Cortical folding simulation for gray matter
    if (tissue_type == 0 && cortical_folding > 0.0) {
        float folding_noise = texture(noise_texture, detail_uv * 0.5).g;
        varied_color = mix(varied_color, varied_color * 0.9, folding_noise * cortical_folding);
    }
    
    return varied_color;
}

// === MAIN SHADER FUNCTIONS ===

void vertex() {
    // Standard vertex transformation
    VERTEX = VERTEX;
    NORMAL = NORMAL;
    UV = UV;
}

void fragment() {
    vec2 uv = UV;
    
    // Get base tissue color
    vec3 tissue_base = get_tissue_base_color(tissue_type);
    
    // Apply base color override if set
    vec3 final_color = mix(tissue_base, base_color.rgb, 0.5);
    
    // Add surface micro-details
    final_color = add_surface_micro_detail(final_color, uv, NORMAL);
    
    // Add vascular details
    final_color = add_vascular_details(final_color, uv);
    
    // Apply pathology effects if enabled
    if (pathology_mode) {
        final_color = apply_pathology_effects(final_color, uv);
    }
    
    // Apply educational context adjustments
    final_color = apply_educational_adjustments(final_color, learning_level);
    
    // Add structure highlighting for educational purposes
    if (structure_highlight > 0.0) {
        final_color = mix(final_color, highlight_color, structure_highlight * 0.3);
    }
    
    // Enhance for medical accuracy
    final_color = enhance_for_medical_accuracy(final_color);
    
    // Apply rim lighting (this is a simplified approach)
    vec3 view_dir = normalize(CAMERA_POSITION_WORLD - VERTEX);
    final_color = calculate_rim_lighting(NORMAL, view_dir, final_color);
    
    // Set material properties
    ALBEDO = final_color;
    METALLIC = metallic;
    ROUGHNESS = roughness;
    SPECULAR = specular;
    
    // Subsurface scattering (handled in light() function)
    // Godot's built-in subsurface scattering is configured via material properties
    // We'll approximate additional SSS effects in the light() function
    
    // Handle transparency for CSF and delicate tissues
    if (tissue_type == 3 || tissue_type == 5) {  // CSF or Pia Mater
        ALPHA = base_color.a;
    }
    
    // Apply normal mapping
    vec3 normal_map = texture(tissue_normal_map, uv).rgb;
    if (length(normal_map) > 0.1) {
        NORMAL_MAP = normal_map;
    }
    
    // Educational enhancement: Add slight emission for better visibility in beginner mode
    if (learning_level <= 0.33 && beginner_saturation_boost > 0.0) {
        EMISSION = final_color * 0.05 * beginner_saturation_boost;
    }
}

void light() {
    // Custom lighting calculation for medical accuracy
    
    // Enhanced subsurface scattering calculation
    if (subsurface_enabled) {
        float sss = calculate_subsurface_scattering(LIGHT, VIEW, NORMAL, 1.0 - tissue_density);
        float sss_strength = get_tissue_subsurface_strength(tissue_type) * subsurface_strength;
        
        // Add subsurface contribution
        DIFFUSE_LIGHT += LIGHT_COLOR * ALBEDO * sss * sss_strength;
    }
    
    // Standard lighting
    float NdotL = max(0.0, dot(NORMAL, LIGHT));
    DIFFUSE_LIGHT += LIGHT_COLOR * ALBEDO * NdotL;
    
    // Enhanced specular for wet tissues (blood vessels, CSF)
    if (tissue_type == 2 || tissue_type == 3) {
        vec3 H = normalize(LIGHT + VIEW);
        float NdotH = max(0.0, dot(NORMAL, H));
        float spec = pow(NdotH, (1.0 - ROUGHNESS) * 128.0);
        SPECULAR_LIGHT += LIGHT_COLOR * spec * SPECULAR * 1.5;
    }
    
    // Medical accuracy: Enhance contrast in lighting
    if (clinical_mode) {
        DIFFUSE_LIGHT *= 1.1;
    }
}