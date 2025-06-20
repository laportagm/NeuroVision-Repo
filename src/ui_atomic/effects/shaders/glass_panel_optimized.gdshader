shader_type canvas_item;

// Optimized glass panel shader for integrated graphics
// Reduces blur samples and simplifies calculations

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 10.0) = 2.0; // Reduced default
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 0.08);
uniform bool enable_blur = true; // Allow disabling blur entirely

void fragment() {
    vec4 screen_tex;
    
    if (enable_blur) {
        // Simple blur using mipmaps (much faster than multi-sampling)
        screen_tex = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
    } else {
        // No blur for maximum performance
        screen_tex = texture(SCREEN_TEXTURE, SCREEN_UV);
    }
    
    // Simple mix operation
    COLOR = mix(screen_tex, tint_color, tint_color.a);
    COLOR.a = 0.92;
}