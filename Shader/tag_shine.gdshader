shader_type canvas_item;

uniform vec2 tag_size = vec2(64.0, 14.0);
uniform float period = 2.5;
uniform float width = 0.25;
uniform float strength = 1.0;
uniform vec3 shine_color : source_color = vec3(1.0, 0.97, 0.85);

varying vec2 local_uv;

void vertex() {
	local_uv = VERTEX / tag_size;
}

void fragment() {
	float t = fract(TIME / period) * 2.4 - 0.7;
	float band = smoothstep(width, 0.0, abs(local_uv.x - t));
	COLOR.rgb = mix(COLOR.rgb, shine_color, band * strength);
}