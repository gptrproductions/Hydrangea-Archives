shader_type canvas_item;
render_mode blend_add;

uniform vec2 rect_size = vec2(0.1, 0.1);
uniform float bness = 1.0;
uniform float fall_off_scale = 3.0;
uniform float b_offset = 0.0;
uniform float alpha_threshold = 0.1; // Minimum brightness to render
uniform float smooth_fade = 0.05;    // Smooth fade range

void fragment() {
    vec2 uv = UV - vec2(0.5);
    vec2 closest_rect_point = uv;

    closest_rect_point.x = clamp(uv.x, -rect_size.x, rect_size.x);
    closest_rect_point.y = clamp(uv.y, -rect_size.y, rect_size.y);

    vec2 cuv = uv - closest_rect_point;
    float d2c = length(cuv);

    // Calculate alpha with brightness
    float alpha = -log(d2c * fall_off_scale + b_offset) * bness;

    // Smoothly fade out dark areas
    alpha = smoothstep(alpha_threshold, alpha_threshold + smooth_fade, alpha);

    COLOR.a = alpha;
}
