shader_type canvas_item;

uniform sampler2D pattern_texture : source_color;
uniform sampler2D glow_gradient : source_color; // Gradient texture
uniform float progress : hint_range(0.0, 1.0) = 0.5;
uniform float pattern_scale_x : hint_range(0.01, 10.0) = 1.0;
uniform float pattern_scale_y : hint_range(0.01, 10.0) = 1.0;
uniform float scroll_speed : hint_range(-5.0, 5.0) = 1.0;
uniform float time_offset = 0.0;

void fragment() {
    // Animate the pattern scrolling
    float offset = TIME * scroll_speed + time_offset;

    // Scale and repeat the pattern
    vec2 scaled_uv = vec2(UV.x * pattern_scale_x + offset, UV.y * pattern_scale_y);
    vec2 repeat_uv = fract(scaled_uv); // Wrap UV coordinates to repeat

    // Get the noise texture color
    vec4 pattern_color = texture(pattern_texture, repeat_uv);

    // Get color from gradient based on UV.x (horizontal progress)
    vec4 glow_color = texture(glow_gradient, vec2(UV.x, 0.5));

    // Clip to progress
    if (UV.x > progress) {
        discard;
    }

    // Overlay blend mode
    vec3 base_color = glow_color.rgb;
    vec3 blend_color = pattern_color.rgb;

    vec3 overlay = mix(
        2.0 * base_color * blend_color,
        1.0 - 2.0 * (1.0 - base_color) * (1.0 - blend_color),
        step(0.5, blend_color)
    );

    // Apply color with overlay and use noise texture alpha
    COLOR.rgb = overlay;
    COLOR.a = pattern_color.a * glow_color.a;
}
