shader_type canvas_item;

void fragment() {
	COLOR.rgb = vec3(texture(TEXTURE, UV).r, 0, 0);
}
