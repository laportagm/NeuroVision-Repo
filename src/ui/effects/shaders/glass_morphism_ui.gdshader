shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 10.0) = 3.0;
uniform float transparency : hint_range(0.0, 1.0) = 0.8;
uniform vec4 glass_color : source_color = vec4(1.0, 1.0, 1.0, 0.1);
uniform float edge_brightness : hint_range(0.0, 2.0) = 1.2;
uniform float depth_fade : hint_range(0.0, 1.0) = 0.1;

// Educational glass morphism for NeuroVision UI elements
// Optimized for medical interface clarity and accessibility

vec4 blur_sample(sampler2D tex, vec2 uv, float blur_size) {
    vec4 color = vec4(0.0);
    float total_weight = 0.0;
    
    // Calculate pixel size for Godot 4
    vec2 pixel_size = 1.0 / vec2(textureSize(tex, 0));
    
    // Gaussian blur kernel for glass effect
    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            vec2 offset = vec2(float(x), float(y)) * blur_size * pixel_size;
            float weight = exp(-float(x*x + y*y) / 2.0);
            color += texture(tex, uv + offset) * weight;
            total_weight += weight;
        }
    }
    
    return color / total_weight;
}

void fragment() {
    vec2 screen_uv = SCREEN_UV;
    
    // Sample blurred background
    vec4 blurred_bg = blur_sample(SCREEN_TEXTURE, screen_uv, blur_amount);
    
    // Add glass tint
    vec4 glass_effect = mix(blurred_bg, glass_color, glass_color.a);
    
    // Edge enhancement for medical UI clarity
    vec2 edge_uv = UV - 0.5;
    float edge_dist = length(edge_uv);
    float edge_factor = smoothstep(0.3, 0.5, edge_dist) * edge_brightness;
    
    // Combine effects
    vec4 final_color = glass_effect;
    final_color.rgb += edge_factor * glass_color.rgb;
    final_color.a = transparency;
    
    COLOR = final_color;
}