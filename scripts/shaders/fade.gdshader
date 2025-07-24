shader_type canvas_item;

uniform bool reverse = false; // true for bottom, false for top

void fragment() {
    float y = reverse ? 1.0 - UV.y : UV.y;
    float fade = smoothstep(0.0, 1.0, y); // 0 (transparent) to 1 (opaque)
    COLOR = vec4(COLOR.rgb, COLOR.a * fade); // multiply alpha for transparency
}
