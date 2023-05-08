shader_type canvas_item;

uniform sampler2D noise: filter_linear;

void fragment() {
	COLOR.rgb = texture(noise, UV).rgb;
}
