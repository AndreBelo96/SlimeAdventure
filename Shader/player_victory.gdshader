shader_type canvas_item;

uniform sampler2D dissolve_texture;
uniform float dissolve_value : hint_range(0.0, 1.0);

void fragment(){
	vec4 main_texture = texture(TEXTURE, UV);
	vec4 noise_texture = texture(dissolve_texture, UV);
	main_texture.a *= step(1.0, dissolve_value + noise_texture.r);
	COLOR = main_texture;
}
