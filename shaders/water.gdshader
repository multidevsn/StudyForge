shader_type spatial;
render_mode blend_mix, depth_draw_alpha_prepass, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform vec4 deep_color : source_color = vec4(0.015, 0.14, 0.22, 0.92);
uniform vec4 shallow_color : source_color = vec4(0.10, 0.42, 0.55, 0.78);
uniform float wave_speed = 0.32;
uniform float wave_scale = 0.12;
uniform float fresnel_power = 4.5;

void vertex() {
	float w1 = sin(VERTEX.x * 0.42 + TIME * wave_speed);
	float w2 = cos(VERTEX.z * 0.36 + TIME * wave_speed * 1.15);
	VERTEX.y += (w1 + w2) * wave_scale * 0.10;
}

void fragment() {
	float fresnel = pow(1.0 - max(dot(normalize(NORMAL), normalize(VIEW)), 0.0), fresnel_power);
	float bands = sin((WORLD_POSITION.x + WORLD_POSITION.z) * 0.35 + TIME * 0.6) * 0.05;
	vec3 color = mix(deep_color.rgb, shallow_color.rgb, clamp(fresnel + bands + 0.15, 0.0, 1.0));
	ALBEDO = color;
	ROUGHNESS = 0.08;
	SPECULAR = 0.72;
	ALPHA = mix(deep_color.a, shallow_color.a, fresnel);
}
