shader_type canvas_item;

uniform vec4 shine_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float speed = 0.5;
uniform float width = 0.2;
uniform float intensity = 1.5; 

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    float raw_pos = TIME * speed;
    float pos = raw_pos; // lascio andare oltre 1.0

    // calcolo distanza dal centro banda
    float dist = abs(UV.x - pos);
    float shine = smoothstep(width, 0.0, dist);

    // fade-out quando pos > 1.0
    float fade = 1.0 - smoothstep(1.0, 1.0 + width, raw_pos);
    shine *= fade;

    vec3 final_rgb = tex.rgb + shine_color.rgb * shine * intensity;
    COLOR = vec4(final_rgb, tex.a);
}
