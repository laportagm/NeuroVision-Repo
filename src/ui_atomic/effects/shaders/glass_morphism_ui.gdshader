shader_type canvas_item;

// Glass morphism shader for UI elements in NeuroVision
// Provides frosted glass effect with configurable blur and tint

// Uniforms for customization
uniform float blur_amount : hint_range(0.0, 20.0, 0.1) = 8.0;
uniform float glass_opacity : hint_range(0.0, 1.0, 0.01) = 0.3;
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 0.1);
uniform float noise_amount : hint_range(0.0, 0.1, 0.001) = 0.02;
uniform float saturation_boost : hint_range(0.0, 2.0, 0.1) = 1.2;
uniform float brightness : hint_range(0.0, 2.0, 0.1) = 1.1;

// Performance settings
uniform bool enable_chromatic_aberration = false;
uniform float aberration_amount : hint_range(0.0, 0.01, 0.001) = 0.003;
uniform int blur_quality : hint_range(1, 3, 1) = 2; // 1=low, 2=medium, 3=high

// PHASE 2 ENHANCEMENT: Enhanced Glass Parameters
uniform float content_awareness : hint_range(0.0, 1.0) = 0.3;
uniform float interaction_radius : hint_range(0.0, 200.0) = 100.0;
uniform vec2 cursor_position = vec2(0.5, 0.5);
uniform float cursor_influence : hint_range(0.0, 1.0) = 0.2;
uniform bool adaptive_blur_enabled = true;
uniform float movement_blur_factor : hint_range(0.0, 2.0) = 1.0;

// Screen texture for background sampling
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

// Note: Using procedural noise instead of texture for Metal compatibility

// Function to apply Gaussian blur
vec4 gaussian_blur(sampler2D tex, vec2 uv, vec2 pixel_size, float amount, int quality) {
    vec4 color = vec4(0.0);
    float total_weight = 0.0;

    // Adjust sample count based on quality setting
    int samples = 5 + quality * 3;
    float sigma = amount * 0.5;

    for (int x = -samples; x <= samples; x++) {
        for (int y = -samples; y <= samples; y++) {
            float distance = length(vec2(float(x), float(y)));
            float weight = exp(-(distance * distance) / (2.0 * sigma * sigma));

            vec2 offset = vec2(float(x), float(y)) * pixel_size * amount;
            color += texture(tex, uv + offset) * weight;
            total_weight += weight;
        }
    }

    return color / total_weight;
}

// Function to adjust saturation
vec3 adjust_saturation(vec3 color, float saturation) {
    float gray = dot(color, vec3(0.299, 0.587, 0.114));
    return mix(vec3(gray), color, saturation);
}

// Function to apply chromatic aberration
vec3 chromatic_aberration(sampler2D tex, vec2 uv, vec2 pixel_size, float amount) {
    vec3 color;
    color.r = texture(tex, uv + vec2(amount, 0.0) * pixel_size).r;
    color.g = texture(tex, uv).g;
    color.b = texture(tex, uv - vec2(amount, 0.0) * pixel_size).b;
    return color;
}

// PHASE 2 ENHANCEMENT: Professional Depth Calculation
float calculate_professional_depth(vec2 uv, vec2 cursor_pos, float influence) {
    float cursor_distance = distance(uv, cursor_pos);
    float cursor_effect = smoothstep(interaction_radius / 1000.0, 0.0, cursor_distance) * influence;
    
    // Content-aware transparency (lighter over important content)
    float content_factor = 1.0 - content_awareness;
    
    return mix(content_factor, content_factor + cursor_effect, cursor_influence);
}

// Main fragment shader
void fragment() {
    vec2 screen_uv = SCREEN_UV;
    vec2 pixel_size = SCREEN_PIXEL_SIZE;
    
    // PHASE 2 ENHANCEMENT: Professional depth calculation
    float depth_factor = calculate_professional_depth(UV, cursor_position, cursor_influence);
    
    // Adaptive blur quality
    float adaptive_blur_amount = blur_amount * depth_factor;
    if (adaptive_blur_enabled) {
        adaptive_blur_amount *= movement_blur_factor;
    }

    // Sample and blur the background with enhanced glass effect
    vec4 blurred_bg;
    if (adaptive_blur_amount > 0.0) {
        blurred_bg = gaussian_blur(screen_texture, screen_uv, pixel_size, adaptive_blur_amount, blur_quality);
    } else {
        blurred_bg = texture(screen_texture, screen_uv);
    }

    // Apply chromatic aberration if enabled
    if (enable_chromatic_aberration && aberration_amount > 0.0) {
        blurred_bg.rgb = chromatic_aberration(screen_texture, screen_uv, pixel_size, aberration_amount);
    }

    // Adjust color properties
    blurred_bg.rgb = adjust_saturation(blurred_bg.rgb, saturation_boost);
    blurred_bg.rgb *= brightness;

    // Get original UI element color
    vec4 original_color = texture(TEXTURE, UV);

    // Apply glass tint
    vec3 tinted_bg = mix(blurred_bg.rgb, tint_color.rgb, tint_color.a);

    // Add subtle noise for texture
    if (noise_amount > 0.0) {
        vec2 noise_uv = UV * 5.0 + TIME * 0.01;
        // Use a simple procedural noise if texture is not available
        float noise = fract(sin(dot(noise_uv, vec2(12.9898, 78.233))) * 43758.5453);
        tinted_bg += (noise - 0.5) * noise_amount;
    }

    // PHASE 2 ENHANCEMENT: Medical-grade color processing with professional transparency
    vec4 glass_color = mix(blurred_bg, vec4(tinted_bg, 1.0), depth_factor);
    glass_color = mix(glass_color, vec4(tint_color.rgb, 1.0), tint_color.a * depth_factor);
    
    // Blend glass effect with original UI element
    vec3 final_color = mix(tinted_bg, original_color.rgb, original_color.a * (1.0 - glass_opacity));

    // Professional transparency range with depth-aware alpha
    float professional_alpha = mix(0.95, 0.85, depth_factor);
    COLOR = vec4(final_color, original_color.a * professional_alpha);
}

// Vertex shader for potential distortion effects
void vertex() {
    // Standard vertex transformation
    // Could add wave or distortion effects here for advanced glass effects
}