shader_type spatial;

render_mode blend_mix, depth_draw_always, cull_back;

uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); //Change when texture is made (from design students)
uniform float opacity = 1.0; //Default opaque

//UNUSED SCRIPT BUT JUST IN CASE

void fragment() {
	
	ALBEDO = base_color.rgb;
	ALPHA = opacity;	
	
}

