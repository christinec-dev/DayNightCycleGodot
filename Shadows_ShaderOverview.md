
# Common Shader Data Types
- `float`: A float represents a floating-point number, which is a number that has a decimal point. Floating-point numbers are used for most calculations within shaders where precision about fractional values is important.It's genereally used for defining scalar values like opacity, time, distances, and other measurements that require decimal precision.
- `vec2`: A vec2 is a 2-component vector data type. It contains two floating-point numbers. It's commonly used to represent coordinates in 2D space, texture coordinates, or any two-dimensional data.
- `vec3`: A vec3 is a 3-component vector. It consists of three floats. It's often used to represent 3D vectors like vertex positions, normals, and colors (RGB).
- `vec4:` A vec4 is a 4-component vector containing four floats. Typically used for color data (RGBA), where it includes red, green, blue, and alpha components. It’s also used for position data in 3D graphics, where the fourth component (w) can be used for homogeneous coordinates for matrix transformations.
- `sampler2D`: A sampler2D is a data type used to represent a 2D texture. Used for texture mapping. Shaders use sampler2D types to fetch texture data, which are then used for various effects like diffusing mapping, bump mapping, or simply texturing objects.
- `int`: An int represents an integer data type, a whole number without a decimal point. Used in shaders for indexing, loop counting, and other situations where a non-fractional number is required.
- `bool`: A bool represents a boolean, which can be either true or false. Used in shaders for conditional testing and flow control, such as enabling or disabling certain effects.
- `mat2`, `mat3`, `mat4`: These represent 2x2, 3x3, and 4x4 matrices, respectively. They are essential in computer graphics for transformations. They are used to perform rotations, scaling, translations, and other linear transformations in 2D and 3D space.

# Shadows Shader Overview
## Shader Context
- `shader_type canvas_item;` - Indicates that the shader is intended for 2D elements rendered on a canvas.
- `render_mode unshaded;` - Specifies that the shader does not rely on Godot's built-in lighting and shading system, meaning it will manually handle how pixels are shaded or colored.

## Uniforms Explained
- `shadow_color` : The color of the shadow. It has a default value of rgba(0.108, 0.108, 0.108, 0.9).
- `shadow_angle`: The angle at which the shadow is cast.
- `shadow_length`: How far the shadow stretches from its source, affecting how the shadow fades over distance.

## Fragment Function
This is where the actual rendering logic of the shader takes place, manipulating each pixel (fragment) covered by the material:
### Angle Calculation
```gdscript
   float shadow_angle_radius = shadow_angle * 3.1416 / 360.0; 
```
- `shadow_angle_radius` converts the shadow_angle from degrees to radians. Radians are used in trigonometric calculations within shaders. This conversion is necessary to use the angle in sine and cosine functions effectively.

### Direction Vector Calculation
```gdscript
  vec2 direction = vec2(sin(shadow_angle_radius), cos(shadow_angle_radius)); 
```
- `direction` calculates the direction vector based on the converted angle. This vector determines the direction in which the shadow ray will travel, simulating how light would cast a shadow in that specific direction.

### Shadow Position Initialization
```gdscript
  vec2 shadow_position = screen_uv_to_sdf(SCREEN_UV); 
```
- `shadow_position` stores the converted SDF coordinates, indicating where to start the shadow ray calculation.
- `screen_uv_to_sdf` helps to find the starting point for the shadow calculation, basing it on the current fragment's position but transformed into a domain suitable for SDF calculations.
- `SCREEN_UV` represents the UV coordinates of the current pixel/fragment on the screen.

### Light Travel Simulation via Ray-Marching
```gdscript
    float ray_distance_travelled = 0.0;
    while(ray_distance_travelled < shadow_length) {
        float distance = texture_sdf(shadow_position);
        ray_distance_travelled += distance;
        if (distance < 0.01) {
            break;
        }
        shadow_position += distance * direction;
    }
```
- `ray_distance_travelled` starts at 0.0 - which initializes our loop counter.
- `while loop` continues as long as the traveled distance is less than the maximum allowed shadow length (shadow_length).
- `distance = texture_sdf(shadow_position)` fetches the distance to the nearest obstacle.
- `ray_distance_travelled += distance` accumulates the distance traveled by the ray.
- If the distance is smaller than 0.01, the loop `breaks` indicating the ray has nearly or already hit an obstacle.
- `shadow_position += distance * direction` updates the shadows position along the calculated direction.


### Shadow Intensity Calculation
```gdscript
	float shadow_transparency = 1.0-min(1.0, ray_distance_travelled / shadow_length);
```
- `shadow_transparency ` calculates how transparent the shadow should be based on how far the light traveled compared to the maximum possible distance. This dtermines the visibility of the shadow; longer unobstructed distances generally mean lighter shadows.

### Shadow Edge Sharpness Adjustment
```gdscript
    shadow_transparency = ceil(shadow_transparency); 
```
- `ceil` applies the ceil function to the shadow transparency to create a hard edge for the shadow, making it either fully opaque or fully transparent with no gradient. Removing this line would allow for softer shadow edges.

### Final Color Assignment
```gdscript
  COLOR = vec4(shadow_color.rgb, shadow_transparency * shadow_color.a);
```
- `COLOR` multiplies the base shadow color's RGB values by the calculated transparency to set the shadow's final appearance. This integrates the calculated shadow transparency with the predefined color to determine how the shadow should appear on the screen.
