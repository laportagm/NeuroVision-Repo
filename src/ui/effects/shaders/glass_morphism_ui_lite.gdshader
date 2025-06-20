shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float transparency : hint_range(0.0, 1.0) = 0.7;
uniform vec4 glass_color : source_color = vec4(1.0, 1.0, 1.0, 0.08);

// Lite version of glass morphism for lower-end educational hardware
// Optimized for Intel UHD 620 and educational institution requirements

void fragment() {
    vec2 screen_uv = SCREEN_UV;
    
    // Simple background sampling without expensive blur
    vec4 background = texture(SCREEN_TEXTURE, screen_uv);
    
    // Basic glass tint with minimal processing
    vec4 final_color = mix(background, glass_color, glass_color.a);
    final_color.a = transparency;
    
    COLOR = final_color;
}