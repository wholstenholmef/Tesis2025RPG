shader_type canvas_item;

uniform float radius;

void fragment() {
	//Calculate the distance from the center of viewport to current viewport
	vec2 center = vec2(0.5, 0.5);
	vec2 local_coords = (UV - center); //adjust aspect ratio
	float distance = length(local_coords);
	
	float circleRadius = radius / float(2);
	
	if(distance > circleRadius){
		discard;
	}
	
}