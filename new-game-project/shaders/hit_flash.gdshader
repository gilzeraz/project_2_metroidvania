shader_type canvas_item;

uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec3 mixed_rgb = mix(tex_color.rgb, vec3(1.0), flash_amount);
	COLOR = vec4(mixed_rgb, tex_color.a);
}

