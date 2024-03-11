shader_type canvas_item;

uniform float chaos : hint_range(0.0, 16.0) = .001;
uniform float radius : hint_range(0.0, .5) = 2.0;
uniform float attenuation : hint_range(1.0, 2.0) = .7;

// Add this line
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

varying vec2 amount_r;
varying vec2 amount_g;
varying vec2 amount_b;

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453) - 0.5; // Use 0.5 for consistency
}

void vertex() {
    // Use UV directly for correct UV mapping
    vec2 shifted_uv = (UV * 2.0) - 1.0;
    amount_r = normalize(vec2(rand(TIME * 1.3 * shifted_uv), rand(TIME * 1.64 * shifted_uv)));
    amount_g = normalize(vec2(rand(TIME * 1.5 * shifted_uv), rand(TIME * 1.7 * shifted_uv)));
    amount_b = normalize(vec2(rand(TIME * 1.17 * shifted_uv), rand(TIME * 1.23 * shifted_uv)));
}

void fragment() {
    vec2 chaos_v = vec2(chaos, -chaos); // Remove SCREEN_PIXEL_SIZE

    float dist = length((UV - vec2(0.5)) * 2.0);
    float att = clamp(dist / radius, 0.0, 1.0);

    chaos_v *= 1.0 - pow(att, attenuation);

    // Use texture2D for consistency (lowercase 'd')
    COLOR = vec4(
        texture(SCREEN_TEXTURE, SCREEN_UV + chaos_v * amount_r).r,
        texture(SCREEN_TEXTURE, SCREEN_UV + chaos_v * amount_g).g,
        texture(SCREEN_TEXTURE, SCREEN_UV + chaos_v * amount_b).b,
        1.0
    );
}
