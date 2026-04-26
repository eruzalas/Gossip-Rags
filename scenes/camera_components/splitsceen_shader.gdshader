shader_type canvas_item;
render_mode unshaded;

uniform vec2 viewport_size;          // size in pixels of the viewport
uniform sampler2D viewport1 : source_color;
uniform sampler2D viewport2 : source_color;
uniform bool split_active;           // true: split screen, false: use view1
uniform vec2 player1_position;       // position of player 1 un UV coordinates
uniform vec2 player2_position;       // position of player 2 un UV coordinates
uniform float split_line_thickness : hint_range(0, 10, 0.1);  // width of the split boder
uniform vec3 split_line_color : source_color;       // color of the split border
uniform bool is_multi_floor = false;         // true: Basic horizontal splitscreen, false: normal splitscreen
uniform bool is_p1_top = false;              //For multi-floor screen assignment
const vec2 split_origin = vec2(0.5, 0.5); // Middle of the screen where splitscreen rotates around

//NOTES FOR GDSHADER LANGUAGE:
// UV is a built in vector2 variable (x, y) that denotes the position of the current pixel
// COLOR denotes this current pixel's color
// GDShader language does not use return for its built in functions eg: fragment(), as such - MUST USE UGLY if else statements rather than having negative conditions
//
// i.e: CANNOT USE if(!split_active)
//                 .........
//                 return
//                 if(...)
//


//For checking distance of every pixel to the splitscreen line
float distance_to_line(vec2 p1, vec2 p2, vec2 point) {
	float a = p1.y - p2.y;
	float b = p2.x - p1.x;
	return abs(a * point.x + b * point.y + p1.x * p2.y - p2.x * p1.y) / sqrt(a * a + b * b);
}

void fragment() {
	vec3 view1 = texture(viewport1, UV).rgb;
	vec3 view2 = texture(viewport2, UV).rgb;

	float width = viewport_size.x;
	float height = viewport_size.y;
	
	
	if (is_multi_floor)
	{
	    vec2 top_uv = vec2(UV.x, UV.y * 2.0);
	    vec2 bottom_uv = vec2(UV.x, (UV.y - 0.5) * 2.0);

	    vec3 top_view;
	    vec3 bottom_view;

	    if (is_p1_top)
	    {
	        top_view = texture(viewport1, top_uv).rgb;
	        bottom_view = texture(viewport2, bottom_uv).rgb;
	    }
	    else
	    {
	        top_view = texture(viewport2, top_uv).rgb;
	        bottom_view = texture(viewport1, bottom_uv).rgb;
	    }

	    if (UV.y < 0.5)
	    {
	        COLOR = vec4(top_view, 1.0);
	    }
	    else
	    {
	        COLOR = vec4(bottom_view, 1.0);
	    }

	    float dist = abs(UV.y - 0.5) * viewport_size.y;
	    if (dist < split_line_thickness)
	    {
	        COLOR.rgb = mix(split_line_color, COLOR.rgb, dist / split_line_thickness);
	    }
	}
	
	if (split_active && !is_multi_floor) {
		
		vec2 dx = player2_position - player1_position;

		float split_slope;
		if (dx.y != 0.0)
		{
		split_slope = dx.x / dx.y;
		} else {
		split_slope = 100000.0; // High value (vertical split) if dx.y = 0
		}
		
		vec2 split_line_start = vec2(0.0, height * ((split_origin.x - 0.0) * split_slope + split_origin.y));
		vec2 split_line_end = vec2(width, height * ((split_origin.x - 1.0) * split_slope + split_origin.y));

		float split_current_y = (split_origin.x - UV.x) * split_slope + split_origin.y;
		float split_player1_position_y = (split_origin.x - player1_position.x) * split_slope + split_origin.y;

		// Check on which side of the split UV is and select the proper view.
		
		if (UV.y > split_current_y) {
			if (player1_position.y > split_player1_position_y) {
				COLOR = vec4(view1, 1.0);
			} else {
				COLOR = vec4(view2, 1.0);
			}
		} else {
			if (player1_position.y < split_player1_position_y) {
				COLOR = vec4(view1, 1.0);
			} else {
				COLOR = vec4(view2, 1.0);
			}
		}
		
		float distance_to_split_line = distance_to_line(split_line_start, split_line_end, vec2(UV.x * width, UV.y * height));
		if (distance_to_split_line < split_line_thickness) {
			// Draw antialiased split line.
			COLOR.rgb = mix(split_line_color, COLOR.rgb, distance_to_split_line / split_line_thickness);
		}
	} else if(!is_multi_floor) {
		COLOR = vec4(view1, 1.0);
	}
}
