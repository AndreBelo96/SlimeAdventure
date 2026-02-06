shader_type canvas_item;

uniform float white_value : hint_range(0.0, 1.0);
uniform float dissolve_value : hint_range(0.0, 1.0);

// chiamata per ogni pixel nell'immagine
void fragment(){
	vec4 pixelColor = texture(TEXTURE, UV);

	if (pixelColor.a == 1.0) {

		float mask = smoothstep(UV.y, UV.y, white_value);

		pixelColor.rgb = mix(pixelColor.rgb, vec3(1.0), mask);
	}

	COLOR = pixelColor;
}
