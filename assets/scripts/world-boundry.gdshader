shader_type spatial;

render_mode unshaded, blend_mix, cull_disabled;

uniform sampler2D albedo : source_color;
uniform vec2 uv_scale = vec2(10.0);

uniform float sphere_size = 5.0;

global uniform vec3 player_pos;

varying vec3 world_vertex;

void vertex() {
	world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {

	float dist = length(player_pos - world_vertex);

	vec4 tex = texture(albedo, UV * uv_scale);

	float reveal = 1.0 - smoothstep(0.0, sphere_size, dist);

	ALBEDO = tex.rgb;

	ALPHA = tex.a * reveal;
}