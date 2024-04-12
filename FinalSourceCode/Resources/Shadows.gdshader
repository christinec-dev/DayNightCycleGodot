shader_type canvas_item;
render_mode unshaded;

// uniform name and type: purpose = default value
uniform vec4 shadow_color : source_color = vec4(0.108, 0.108, 0.108, 0.9);
uniform float shadow_angle : hint_range(0,360) = 1.0; 
uniform float shadow_length : hint_range(0,1000) = 1.0;

void fragment() {
	float shadow_angle_radius = shadow_angle * 3.1416 / 360.0; 
    vec2 direction = vec2(sin(shadow_angle_radius), cos(shadow_angle_radius)); 
    vec2 shadow_position = screen_uv_to_sdf(SCREEN_UV); 
	// Light travel simulation
	float ray_distance_travelled = 0.0;
    while(ray_distance_travelled < shadow_length) {
        float distance = texture_sdf(shadow_position);
        ray_distance_travelled += distance;
        if (distance < 0.01) {
            break;
        }
        shadow_position += distance * direction;
    }
	// Shadow intensity
	float shadow_transparency = 1.0-min(1.0, ray_distance_travelled / shadow_length);
	// Sharpen shadow (remove if you want a blurry shadow)
    shadow_transparency = ceil(shadow_transparency); 
	// Shadow color
    COLOR = vec4(shadow_color.rgb, shadow_transparency * shadow_color.a);
}
