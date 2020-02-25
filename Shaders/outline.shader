shader_type spatial;
render_mode cull_front, unshaded, ambient_light_disabled;

uniform float outline_thickness : hint_range(0.0, 1.0, 0.001) = 0.005;
uniform vec4 outline_color : hint_color = vec4(0.0, 0.0, 0.0, 1.0);

void vertex()
{
	VERTEX = (NORMAL * outline_thickness) + VERTEX;
}

void fragment()
{
	ALBEDO = outline_color.rgb;
}