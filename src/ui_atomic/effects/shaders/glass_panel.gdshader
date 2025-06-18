shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 10.0) = 5.0;
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 0.08);
void fragment() {
vec4 screen_tex = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
COLOR = mix(screen_tex, tint_color, tint_color.a);
COLOR.a = 0.92;
}