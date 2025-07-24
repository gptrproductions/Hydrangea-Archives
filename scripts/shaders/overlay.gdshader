shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV); // Get what's behind
    vec4 object_color = texture(TEXTURE, UV); // Get the object's color

    // Overlay blend mode
    vec3 overlay = mix(
        2.0 * screen_color.rgb * object_color.rgb,
        1.0 - 2.0 * (1.0 - screen_color.rgb) * (1.0 - object_color.rgb),
        step(0.5, screen_color.rgb)
    );

    COLOR.rgb = overlay;
    COLOR.a = object_color.a; // Preserve object's alpha
}
