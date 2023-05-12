shader_type canvas_item;

void fragment() {
	COLOR.rgb = vec3(0, 0, texture(TEXTURE, UV).b);
}
