shader_type canvas_item;

uniform float margin_x = 0.2; 
uniform float margin_y = 0.2;
uniform float intensity_x = 2.0;
uniform float intensity_y = 2.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // distanza dal bordo orizzontale
    float fade_x = smoothstep(0.0, margin_x, min(UV.x, 1.0 - UV.x));
    fade_x = pow(fade_x, intensity_x);

    // distanza dal bordo verticale
    float fade_y = smoothstep(0.0, margin_y, min(UV.y, 1.0 - UV.y));
    fade_y = pow(fade_y, intensity_y);

    float alpha_fade = fade_x * fade_y;

    COLOR = vec4(tex.rgb, tex.a * alpha_fade);
}
