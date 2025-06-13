shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque;

// Rim light parameters
uniform float rim_power : hint_range(0.0, 10.0) = 2.0;
uniform float rim_intensity : hint_range(0.0, 2.0) = 1.0;
uniform vec4 rim_color : source_color = vec4(0.3, 0.6, 1.0, 1.0);
uniform float rim_blend : hint_range(0.0, 1.0) = 0.8;

// Animation parameters
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.0;
uniform float pulse_amplitude : hint_range(0.0, 1.0) = 0.2;

// Base material blending
uniform sampler2D base_texture : source_color;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float base_blend : hint_range(0.0, 1.0) = 0.5;

varying vec3 world_normal;
varying vec3 world_position;

void vertex() {
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    // Calculate view direction
    vec3 view_dir = normalize(CAMERA_POSITION_WORLD - world_position);
    
    // Calculate fresnel effect
    float fresnel = pow(1.0 - dot(view_dir, world_normal), rim_power);
    
    // Add pulse animation
    float pulse = sin(TIME * pulse_speed) * pulse_amplitude + 1.0;
    fresnel *= pulse;
    
    // Sample base texture if available
    vec4 base_sample = texture(base_texture, UV);
    vec4 base = base_sample * base_color;
    
    // Blend rim light with base
    vec3 final_color = mix(base.rgb, rim_color.rgb, fresnel * rim_blend);
    float final_alpha = max(base.a, fresnel * rim_color.a);
    
    // Apply rim intensity
    final_color *= rim_intensity;
    
    ALBEDO = final_color;
    ALPHA = final_alpha;
    
    // Add subtle emission for glow effect
    EMISSION = rim_color.rgb * fresnel * rim_intensity * 0.5;
}