shader_type canvas_item;

uniform float flash_duration = 1.5;      // durata del flash in secondi
uniform vec3 flash_color : source_color = vec3(1.0, 1.0, 1.0);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // flash_factor = 1 all'inizio (completamente flash), 0 alla fine
    float flash_factor = 1.0 - clamp(TIME / flash_duration, 0.0, 1.0);

    // miscelo il flash con la texture normale
    vec3 final_color = mix(tex.rgb, flash_color, flash_factor);

    COLOR = vec4(final_color, tex.a);
}
