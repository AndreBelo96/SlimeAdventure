shader_type canvas_item;

uniform float white_value : hint_range(0.0, 1.0) = 1.0;
uniform float alpha_value : hint_range(0.0, 1.0) = 1.0;
uniform float smoothness : hint_range(0.0, 0.1) = 0.02;
uniform vec3 color : source_color = vec3(1.0);

void fragment() {
	vec4 pixelColor = texture(TEXTURE, UV);

	pixelColor.rgb *= color;

	// Se player è overlappato (si possono rpednere colori della sprite e dello screen
	// Fare un outline bianca con z index = 100 (easy)

    if (pixelColor.a == 1.0) {
        // factor = 0 sotto la linea → bianco, 1 sopra → colore originale
        float factor = smoothstep(white_value - smoothness, white_value, UV.y);
        pixelColor.rgb = mix(pixelColor.rgb, vec3(1.0), factor);
    }

	 if (pixelColor.a > 0.0) {
		float factor = smoothstep(alpha_value - smoothness, alpha_value, UV.y);
		pixelColor.a = mix(pixelColor.a * alpha_value, 0.0, factor);
	}


    COLOR = pixelColor;
}
