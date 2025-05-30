shader_type canvas_item;

void fragment() {
    vec4 screen_tex = texture(TEXTURE, SCREEN_UV);
    if (screen_tex.a < 0.1) {
        discard;
    }
    COLOR = screen_tex;
}
