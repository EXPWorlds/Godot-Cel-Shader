shader_type spatial;

uniform bool use_shade = true;
uniform bool use_specular = false;
uniform bool use_rim = false;
uniform bool base_use_light_color = false;
uniform bool specular_use_light_color = false;
uniform bool rim_use_light_color = false;

uniform vec4 base_color : hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 shade_color : hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 specular_tint : hint_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform vec4 rim_tint : hint_color = vec4(0.5, 0.5, 0.5, 1.0);

uniform float shade_threshold : hint_range(-1.0, 1.0, 0.001) = 0.0;
uniform float shade_softness : hint_range(0.0, 1.0, 0.001) = 0.0;
uniform float specular_threshold : hint_range(0.0, 1.0, 0.001) = 0.005;
uniform float specular_softness : hint_range(0.0, 1.0, 0.001) = 0.0;
uniform float rim_threshold : hint_range(0.0, 1.0, 0.001) = 0.00;
uniform float rim_spread : hint_range(0.0, 1.0, 0.001) = 0.00;
uniform float rim_softness : hint_range(0.0, 1.0, 0.001) = 0.0;


void fragment()
{
	ALBEDO = base_color.rgb;
}


void light()
{
	vec3 diffuse = ALBEDO;
	float NdotL = dot(NORMAL, LIGHT);
	
	if (use_shade)
	{
		vec3 base = mix(ALBEDO, ALBEDO * LIGHT_COLOR, float(base_use_light_color));
		vec3 shade = shade_color.rgb;
		float is_shaded = smoothstep(shade_threshold - shade_softness ,shade_threshold + shade_softness, NdotL);
		diffuse = mix(shade, base, is_shaded);
	}
	
	if (use_specular && NdotL > shade_threshold)
	{
		vec3 specular = mix(specular_tint.rgb, specular_tint.rgb * LIGHT_COLOR, float(specular_use_light_color));
		vec3 half_angle = normalize(LIGHT + VIEW);
    	float specular_angle = max(dot(half_angle, NORMAL), 0.0);
		float flipped_specular_threshold = 1.0 - specular_threshold; //Converts uniform slider value into a value required for calculation
		float is_specular = smoothstep(flipped_specular_threshold - specular_softness, flipped_specular_threshold + specular_softness, specular_angle);
		diffuse = mix(diffuse, diffuse + specular.rgb, is_specular);
		diffuse = clamp(diffuse, vec3(0.0), vec3(1.0));
	}
	
	if (use_rim && NdotL > shade_threshold)
	{
		vec3 rim = mix(rim_tint.rgb, rim_tint.rgb * LIGHT_COLOR, float(rim_use_light_color));
		float rim_angle = 1.0 - dot(NORMAL, VIEW);
		float flipped_rim_spread = 1.0 - rim_spread; //Converts uniform slider value into a value required for calculation
		rim_angle *= pow(NdotL, flipped_rim_spread);
		float flipped_rim_threshold = 1.0 - rim_threshold; //Converts uniform slider value into a value required for calculation
		float is_rim = smoothstep(flipped_rim_threshold - rim_softness, flipped_rim_threshold + rim_softness, rim_angle);
		diffuse = mix(diffuse, diffuse + rim.rgb, is_rim);
		diffuse = clamp(diffuse, vec3(0.0), vec3(1.0));
	}
	
	DIFFUSE_LIGHT = diffuse.rgb;
}