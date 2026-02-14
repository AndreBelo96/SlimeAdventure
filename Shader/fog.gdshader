shader_type canvas_item;

uniform float speed = 0.2;
uniform float scale = 3.0;
uniform float intensity = 0.15;
uniform vec4 fog_color : source_color = vec4(0.7, 0.9, 1.0, 1.0);

uniform float time;

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898,78.233))) * 43758.5453);
}

float noise(vec2 uv) {
	vec2 i = floor(uv);
	vec2 f = fract(uv);

	float a = random(i);
	float b = random(i + vec2(1.0, 0.0));
	float c = random(i + vec2(0.0, 1.0));
	float d = random(i + vec2(1.0, 1.0));

	vec2 u = f * f * (3.0 - 2.0 * f);

	return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b)* u.x * u.y;
}

void fragment() {
	vec2 uv = SCREEN_UV * scale;
	
	// movimento reale nel tempo
	uv.x += TIME * speed;
	uv.y += TIME * speed * 0.4;

	float n = noise(uv);

	float alpha = smoothstep(0.4, 0.7, n) * intensity;

	COLOR = vec4(fog_color.rgb, alpha);
}