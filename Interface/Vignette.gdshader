shader_type canvas_item;

uniform vec4 color: source_color;
uniform float radius = 0.75;
uniform float softness = 0.45;

void fragment() {
	float l = length(UV - vec2(0.5));
	float v = smoothstep(radius, radius - softness, l);
	COLOR.a = 1.0 - v * 0.5 - 0.5;
	COLOR.rgb = color.rgb;
}
