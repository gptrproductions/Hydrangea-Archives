shader_type canvas_item;

uniform float fade_distance : hint_range(0.0, 0.5) = 0.1;
uniform float fade_strength : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);

    // Calculate fades for top and bottom
    float top_fade = smoothstep(0.0, fade_distance, UV.y);
    float bottom_fade = smoothstep(1.0, 1.0 - fade_distance, UV.y);

    // Combine the fades
    float fade_factor = min(top_fade, bottom_fade);

    // Apply fade to alpha only
    color.a *= fade_factor;

    // Output the final color
    COLOR = color;
}
