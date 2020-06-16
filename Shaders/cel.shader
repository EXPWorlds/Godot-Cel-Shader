//By David Lipps aka DaveTheDev @ EXPWorlds
//v2.0.0 for Godot 3.2

shader_type spatial;
render_mode ambient_light_disabled;

uniform bool use_shade = true;
uniform bool use_specular = false;
uniform bool use_rim = false;
uniform bool use_light = false;
uniform bool use_shadow = false;

uniform vec4 base_color : hint_color = vec4(1.0);
uniform vec4 shade_color : hint_color = vec4(1.0);
uniform vec4 specular_tint : hint_color = vec4(0.75);
uniform vec4 rim_tint : hint_color = vec4(0.75);

uniform float shade_threshold : hint_range(-1.0, 1.0, 0.001) = 0.0;
uniform float shade_softness : hint_range(0.0, 1.0, 0.001) = 0.01;

uniform float specular_glossiness : hint_range(1.0, 100.0, 0.1) = 15.0;
uniform float specular_threshold : hint_range(0.01, 1.0, 0.001) = 0.5;
uniform float specular_softness : hint_range(0.0, 1.0, 0.001) = 0.1;

uniform float rim_threshold : hint_range(0.00, 1.0, 0.001) = 0.25;
uniform float rim_softness : hint_range(0.0, 1.0, 0.001) = 0.05;
uniform float rim_spread : hint_range(0.0, 1.0, 0.001) = 0.5;

uniform float shadow_threshold : hint_range(0.00, 1.0, 0.001) = 0.7;
uniform float shadow_softness : hint_range(0.0, 1.0, 0.001) = 0.1;

uniform sampler2D base_texture: hint_albedo;
uniform sampler2D shade_texture: hint_albedo;

void light()
{
	float NdotL = dot(NORMAL, LIGHT);
	float is_lit = step(shade_threshold, NdotL);
	vec4 base = texture(base_texture, UV).rgba * base_color.rgba;
	vec4 shade = texture(shade_texture, UV).rgba * shade_color.rgba;
	vec4 diffuse = base;
	

	if (use_shade)
	{
		float shade_value = smoothstep(shade_threshold - shade_softness ,shade_threshold + shade_softness, NdotL);
		diffuse = mix(shade, base, shade_value);
		
		if (use_shadow)
		{
			float shadow_value = smoothstep(shadow_threshold - shadow_softness ,shadow_threshold + shadow_softness, ATTENUATION.r);
			shade_value = min(shade_value, shadow_value);
			diffuse = mix(shade, base, shade_value);
			is_lit = step(shadow_threshold, shade_value);
		}
	}
	
	if (use_specular)
	{
		vec3 half = normalize(VIEW + LIGHT);
		float NdotH = dot(NORMAL, half);
		
		float specular_value = pow(NdotH * is_lit, specular_glossiness * specular_glossiness);
		specular_value = smoothstep(specular_threshold - specular_softness, specular_threshold + specular_softness, specular_value);
		diffuse += specular_tint.rgba * specular_value;
	}
	
	if (use_rim)
	{
		float iVdotN = 1.0 - dot(VIEW, NORMAL);
		float inverted_rim_threshold = 1.0 - rim_threshold;
		float inverted_rim_spread = 1.0 - rim_spread;
		
		float rim_value = iVdotN * pow(NdotL, inverted_rim_spread);
		rim_value = smoothstep(inverted_rim_threshold - rim_softness, inverted_rim_threshold + rim_softness, rim_value);
		diffuse += rim_tint.rgba * rim_value * is_lit;
	}
	
	if (use_light)
	{
		diffuse *= vec4(LIGHT_COLOR, 1.0);
	}
	
	DIFFUSE_LIGHT = diffuse.rgb;
	ALPHA = diffuse.a;
}