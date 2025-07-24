shader_type canvas_item;

uniform vec2 up_left = vec2(0.0);
uniform vec2 up_right = vec2(1.0, 0.0);
uniform vec2 down_right = vec2(1.0, 1.0);
uniform vec2 down_left = vec2(0.0, 1.0);

uniform vec2 plane_size;
uniform vec2 mouse_position;
uniform float hover_strength = 0.1;

varying mat3 trans_inv;
varying vec2 trans_scale;
varying vec2 trans_offset;

varying vec4 vertex_color;

mat3 perspective_transform(vec2[4] poly) {
    float dx1 = poly[1].x - poly[2].x;
    float dx2 = poly[3].x - poly[2].x;
    float dx3 = poly[0].x - poly[1].x + poly[2].x - poly[3].x;
    float dy1 = poly[1].y - poly[2].y;
    float dy2 = poly[3].y - poly[2].y;
    float dy3 = poly[0].y - poly[1].y + poly[2].y - poly[3].y;

    float a13 = (dx3 * dy2 - dy3 * dx2) / (dx1 * dy2 - dy1 * dx2);
    float a23 = (dx1 * dy3 - dy1 * dx3) / (dx1 * dy2 - dy1 * dx2);
    float a11 = poly[1].x - poly[0].x + a13 * poly[1].x;
    float a21 = poly[3].x - poly[0].x + a23 * poly[3].x;
    float a31 = poly[0].x;
    float a12 = poly[1].y - poly[0].y + a13 * poly[1].y;
    float a22 = poly[3].y - poly[0].y + a23 * poly[3].y;
    float a32 = poly[0].y;

    mat3 transform_mat = mat3(
        vec3(a11, a12, a13),
        vec3(a21, a22, a23),
        vec3(a31, a32, 1)
    );

    return inverse(transform_mat);
}

vec2 mult_mat_inv_point(mat3 mat_inv, vec2 point) {
    vec3 result = mat_inv * vec3(point, 1.0);
    return vec2(result.x / result.z, result.y / result.z);
}

void vertex() {
	vertex_color = COLOR;
    vec2[] poly = {up_left, up_right, down_right, down_left};

    // Calculate the center of the button
    vec2 center = vec2(0.5);

    // Calculate the offset based on mouse position
    vec2 offset = (mouse_position - center) * hover_strength;

    // Adjust the corners based on the offset to create a perspective effect
    poly[0] += vec2(-offset.x, -offset.y);
    poly[1] += vec2(offset.x, -offset.y);
    poly[2] += vec2(offset.x, offset.y);
    poly[3] += vec2(-offset.x, offset.y);

    // Precalculating transformation matrix
    trans_inv = perspective_transform(poly);

    // Scale and offset to transform vertex and later UV to support out of bounding box transformation
    trans_scale = vec2(
        max(max(up_right.x, down_right.x) - min(up_left.x, down_left.x), 1.0),
        max(max(down_left.y, down_right.y) - min(up_left.y, up_right.y), 1.0)
    );
    trans_offset = vec2(
        min(min(up_left.x, down_left.x), 0.0),
        min(min(up_left.y, up_right.y), 0.0)
    );
    VERTEX = VERTEX * trans_scale + plane_size * trans_offset;
}

void fragment() {

    // Apply the perspective transform
    vec2 pUV = mult_mat_inv_point(trans_inv, UV * trans_scale + trans_offset);

    // Prevent sampling outside the assigned region
    if (pUV.x > 1.0 || pUV.y > 1.0 || pUV.x < 0.0 || pUV.y < 0.0) {
        COLOR = vec4(0.0);
    } else {
		COLOR = texture(TEXTURE, pUV) * vertex_color;
    }
}
