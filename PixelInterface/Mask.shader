shader_type canvas_item;

uniform vec4 color: hint_color;
uniform sampler2D mask: hint_albedo;
uniform float scale = 2.0;
const float pivot = 0.5;

void fragment() {
	vec2 ps = SCREEN_PIXEL_SIZE;
	vec2 ratio = (ps.x > ps.y) ? vec2(ps.y / ps.x, 1) : vec2(1, ps.x / ps.y);
	float a = 1.0 - texture(mask, (UV - pivot) * scale * ratio + pivot).a;
	COLOR.a = (a < 0.5) ? 0.0 : color.a;
	COLOR.rgb = color.rgb;
}
