shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
//uniform float glow_intensity = 0.001;
uniform float pulse_strength = 0.1;
uniform float pulse_speed = 2.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float pulse = pulse_strength * sin(TIME * pulse_speed);
    vec3 final_rgb = tex.rgb + glow_color.rgb * pulse;
    COLOR = vec4(final_rgb, tex.a);
}