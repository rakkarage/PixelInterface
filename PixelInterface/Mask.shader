shader_type canvas_item;

uniform vec4 color: hint_color;
uniform sampler2D mask: hint_albedo;
uniform float scale = 2.0;
uniform vec2 pivot = vec2(0.5, 0.5);

void fragment() {
	COLOR.rgb = color.rgb;
	COLOR.a = 1.0 - texture(mask, (UV - pivot) * vec2(scale, scale) + pivot).a;
}