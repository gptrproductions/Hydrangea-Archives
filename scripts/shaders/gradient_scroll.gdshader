shader_type canvas_item;

uniform sampler2D gradient_texture;
uniform sampler2D bevel_texture;
uniform float speed = 1.0;
uniform float scale = 1.0;
uniform float progress = 1.0;
uniform vec4 fallback_color : source_color; // Custom color for unfilled area
uniform bool enable_fallback = true;

void fragment() {
    // Scroll the gradient horizontally
    float offset = mod(TIME * speed, 1.0);
    float shifted_u = mod(UV.x * scale + offset, 1.0);

    // Create a dynamic liquid wave effect
    float wave_x = sin(UV.y * 8.0 + TIME * speed * 3.0) * 0.08; // Horizontal displacement
    float wave_y = cos(UV.x * 6.0 + TIME * speed * 2.5) * 0.05; // Vertical wobble effect

    float wavy_u = mod(shifted_u + wave_x + wave_y, 1.0);

    // Sample gradient and base texture
    vec4 grad_color = texture(gradient_texture, vec2(wavy_u, 0.0));
    vec4 base_tex = texture(TEXTURE, UV);

    // Add bevel overlay (white) based on Y progress
    vec4 bevel_color = texture(bevel_texture, UV);

    if (UV.x > progress) {
        if (enable_fallback) {
            COLOR = fallback_color * base_tex.a;
        } else {
            discard;
        }
    } else {
        COLOR = (grad_color + bevel_color) * base_tex.a;
    }
}
