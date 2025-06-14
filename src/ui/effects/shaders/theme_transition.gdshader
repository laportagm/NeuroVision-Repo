shader_type canvas_item;

// Theme transition shader for smooth visual transitions in NeuroVision
// Provides various transition effects between themes

// Transition parameters
uniform float transition_progress : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform int transition_type : hint_range(0, 5, 1) = 0; // 0=fade, 1=slide, 2=ripple, 3=morph, 4=pixelate, 5=spiral

// Colors for interpolation
uniform vec4 from_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 to_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Effect parameters
uniform vec2 transition_center = vec2(0.5, 0.5);
uniform float ripple_frequency : hint_range(1.0, 20.0, 0.5) = 10.0;
uniform float pixelate_size : hint_range(1.0, 50.0, 1.0) = 20.0;
uniform float spiral_rotations : hint_range(0.5, 5.0, 0.5) = 2.0;

// Performance options
uniform bool smooth_interpolation = true;
uniform bool enable_glow = true;
uniform float glow_intensity : hint_range(0.0, 2.0, 0.1) = 0.5;

// Texture samplers
uniform sampler2D from_texture : hint_default_white, repeat_disable, filter_linear;
uniform sampler2D to_texture : hint_default_white, repeat_disable, filter_linear;

// Easing functions
float ease_in_out_cubic(float t) {
    if (t < 0.5) {
        return 4.0 * t * t * t;
    } else {
        float p = 2.0 * t - 2.0;
        return 1.0 + p * p * p * 0.5;
    }
}

float ease_in_out_sine(float t) {
    return -0.5 * (cos(PI * t) - 1.0);
}

float ease_in_out_expo(float t) {
    if (t == 0.0) return 0.0;
    if (t == 1.0) return 1.0;
    if (t < 0.5) {
        return 0.5 * pow(2.0, 20.0 * t - 10.0);
    }
    return 1.0 - 0.5 * pow(2.0, -20.0 * t + 10.0);
}

// Transition effect functions
float fade_transition(vec2 uv, float progress) {
    return smooth_interpolation ? ease_in_out_cubic(progress) : progress;
}

float slide_transition(vec2 uv, float progress) {
    float eased = ease_in_out_cubic(progress);
    return step(uv.x, eased);
}

float ripple_transition(vec2 uv, float progress) {
    vec2 center_dist = uv - transition_center;
    float dist = length(center_dist);
    float ripple = sin(dist * ripple_frequency - progress * PI * 2.0) * 0.5 + 0.5;
    float mask = smoothstep(progress - 0.1, progress + 0.1, dist);
    return mix(ripple, 1.0, mask);
}

float morph_transition(vec2 uv, float progress) {
    vec2 center_dist = uv - transition_center;
    float angle = atan(center_dist.y, center_dist.x);
    float radius = length(center_dist);
    
    float morph = sin(angle * 8.0 + progress * PI * 4.0) * 0.1;
    float expand = progress * (1.0 + morph);
    
    return smoothstep(expand - 0.1, expand + 0.1, radius);
}

float pixelate_transition(vec2 uv, float progress) {
    float pixels = mix(pixelate_size, 1.0, ease_in_out_cubic(progress));
    vec2 pixelated = floor(uv * pixels) / pixels;
    float noise = fract(sin(dot(pixelated, vec2(12.9898, 78.233))) * 43758.5453);
    return step(noise, progress);
}

float spiral_transition(vec2 uv, float progress) {
    vec2 center_dist = uv - transition_center;
    float angle = atan(center_dist.y, center_dist.x);
    float radius = length(center_dist);
    
    float spiral_angle = angle + radius * spiral_rotations * TAU;
    float spiral_progress = fract(spiral_angle / TAU + progress);
    
    return smoothstep(0.0, 0.1, spiral_progress);
}

// Glow effect for transitions
vec3 add_glow(vec3 color, float intensity, float progress) {
    float glow = sin(progress * PI) * intensity;
    return color + vec3(glow);
}

// Main fragment shader
void fragment() {
    vec2 uv = UV;
    vec4 from_sample = texture(from_texture, uv);
    vec4 to_sample = texture(to_texture, uv);
    
    // Calculate transition mask based on selected type
    float mask = 0.0;
    
    switch(transition_type) {
        case 0: // Fade
            mask = fade_transition(uv, transition_progress);
            break;
        case 1: // Slide
            mask = slide_transition(uv, transition_progress);
            break;
        case 2: // Ripple
            mask = ripple_transition(uv, transition_progress);
            break;
        case 3: // Morph
            mask = morph_transition(uv, transition_progress);
            break;
        case 4: // Pixelate
            mask = pixelate_transition(uv, transition_progress);
            break;
        case 5: // Spiral
            mask = spiral_transition(uv, transition_progress);
            break;
    }
    
    // Interpolate between textures
    vec4 texture_mix = mix(from_sample, to_sample, mask);
    
    // Interpolate between colors
    vec4 color_mix = mix(from_color, to_color, mask);
    
    // Combine texture and color interpolation
    vec4 final_color = texture_mix * color_mix;
    
    // Add glow effect if enabled
    if (enable_glow && transition_progress > 0.0 && transition_progress < 1.0) {
        final_color.rgb = add_glow(final_color.rgb, glow_intensity, transition_progress);
    }
    
    // Apply final color
    COLOR = final_color;
    
    // Special handling for UI elements - preserve original alpha
    COLOR.a *= texture(TEXTURE, uv).a;
}

// Vertex shader for potential displacement effects
void vertex() {
    // Standard vertex transformation
    // Could add displacement for more dramatic transitions
    
    // Example: Wave displacement during transition
    if (transition_type == 2 && transition_progress > 0.0 && transition_progress < 1.0) {
        float wave = sin(VERTEX.x * 0.05 + transition_progress * PI * 2.0) * 5.0;
        VERTEX.y += wave * sin(transition_progress * PI);
    }
}