shader_type canvas_item;

void fragment() {
	COLOR.rgb = vec3(0, texture(TEXTURE, UV).g, 0);
}
