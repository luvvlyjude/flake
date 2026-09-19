precision highp float;

varying vec2 f_src_pos;

uniform sampler2D u_texture;

const float threshold = 0.01;
const vec3 blue = vec3(0.333, 0.984, 0.984); // #55FBFB
const vec3 yellow = vec3(0.988, 0.988, 0.329); // #FCFC54
const vec3 black = vec3(0., 0., 0.); // #000000


void main() {
    vec4 color = texture2D(u_texture, f_src_pos);


    bool is_rta = all(lessThan(abs(color.rgb - blue), vec3(threshold)));
    bool is_igt = all(lessThan(abs(color.rgb - yellow), vec3(threshold)));
    bool is_border = all(lessThan(abs(color.rgb - black), vec3(threshold)));

    if (is_rta || is_igt || is_border) {
        gl_FragColor = color;
    } else {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
    }
}
