# Common Shader Data Types
- `float`: A float represents a floating-point number, which is a number that has a decimal point. Floating-point numbers are used for most calculations within shaders where precision about fractional values is important.It's genereally used for defining scalar values like opacity, time, distances, and other measurements that require decimal precision.
- `vec2`: A vec2 is a 2-component vector data type. It contains two floating-point numbers. It's commonly used to represent coordinates in 2D space, texture coordinates, or any two-dimensional data.
- `vec3`: A vec3 is a 3-component vector. It consists of three floats. It's often used to represent 3D vectors like vertex positions, normals, and colors (RGB).
- `vec4:` A vec4 is a 4-component vector containing four floats. Typically used for color data (RGBA), where it includes red, green, blue, and alpha components. It’s also used for position data in 3D graphics, where the fourth component (w) can be used for homogeneous coordinates for matrix transformations.
- `sampler2D`: A sampler2D is a data type used to represent a 2D texture. Used for texture mapping. Shaders use sampler2D types to fetch texture data, which are then used for various effects like diffusing mapping, bump mapping, or simply texturing objects.
- `int`: An int represents an integer data type, a whole number without a decimal point. Used in shaders for indexing, loop counting, and other situations where a non-fractional number is required.
- `bool`: A bool represents a boolean, which can be either true or false. Used in shaders for conditional testing and flow control, such as enabling or disabling certain effects.
- `mat2`, `mat3`, `mat4`: These represent 2x2, 3x3, and 4x4 matrices, respectively. They are essential in computer graphics for transformations. They are used to perform rotations, scaling, translations, and other linear transformations in 2D and 3D space.

# LightRays Shader Overview
## Shader Context
- `shader_type canvas_item;` - Indicates that the shader is intended for 2D elements rendered on a canvas.
- `render_mode unshaded;` - Specifies that the shader does not rely on Godot's built-in lighting and shading system, meaning it will manually handle how pixels are shaded or colored.

## Uniforms Explained
- `color`: Defines the base color of the light rays.
- `angle`: Sets the angle at which the rays are oriented on the screen.
- `position`: Determines the starting position of the rays relative to the UV coordinates.
- `starting_point`: Provides a random offset to the beginning of the light rays, adding variation.
- `movement_speed`: Affects the speed at which the rays move or animate.
- `ray_separation`: Controls how tightly packed or spread apart the rays are.
- `ray_spread_horizontal` and `ray_spread_vertical`: Define the spread of the rays across the screen both horizontally and vertically.
- `ray_1_density`, `ray_2_density`: Determine the frequency and granularity of two separate layers of rays.
- `ray_1_intensity`, `ray_2_intensity`: Control the brightness or visibility of each layer of rays.
- `SCREEN_TEXTURE`: Allows the shader to overlay or blend its output over the rest of the rendered scene.

## Functions
- `angle_rays`: Generates a 2x2 rotation matrix from an angle, used to rotate UV coordinates.
- `random` and `noise`: Produce pseudo-random values based on input coordinates; used here to generate a base pattern for the light rays.
  
## Fragment Function
This is where the actual rendering logic of the shader takes place, manipulating each pixel (fragment) covered by the material:
### UV Coordinate Transformation:
```gdscript
  vec2 ray_positioning = (angle_rays(angle) * (UV - position))  / ((UV.y + ray_seperation) - (UV.y * ray_seperation));
```
- `ray_positioning` coordinates are rotated by the specified angle and adjusted for position and seperation of the rays, allowing the light rays to appear angled and spread out as configured.
### Ray Animation:
```gdscript
  vec2 ray_1 = vec2(ray_positioning.x * ray_1_density + sin(TIME * 0.1 * movement_speed) * (ray_1_density * 0.2) + starting_point, 1.0);
	vec2 ray_2 = vec2(ray_positioning.x * ray_2_density + sin(TIME * 0.2 * movement_speed) * (ray_1_density * 0.2) + starting_point, 1.0);
```
- Two sets of rays (`ray_1` and `ray_2`) are animated over time. The `sin(TIME)` function creates a periodic oscillation, which, combined with `movement_speed`, `ray_1_density`, and `ray_2_density`, gives the rays a dynamic, flowing appearance.
### Bounding and Intensity Adjustment:
```gdscript
  // Ensure rays don't extend certain bounds
	float bounds = step(ray_spread_horizontal, ray_positioning.x) * step(ray_spread_horizontal, 1.0 - ray_positioning.x);
	ray_1 *= bounds;
	ray_2 *= bounds;
	// Ensure they don't exceed max brightness
	float rays;
	rays = clamp(noise(ray_1) * ray_1_intensity + (noise(ray_2) * ray_2_intensity), 0., 1.);
```
- `bounds` restricts the rays to specified horizontal limits, ensuring they do not render outside these bounds.
- The `noise` function outputs are weighted by their respective intensities and summed, then clamped between 0 and 1 to ensure the color values remain valid.
### Smoothing and Color Application:
```gdscript
	// Smoothen out rays
	rays *= smoothstep(0.0, ray_spread_vertical, (1.0 - UV.y));
	rays *= smoothstep(0.0 + ray_spread_horizontal, ray_spread_horizontal, ray_positioning.x);
	rays *= smoothstep(0.0 + ray_spread_horizontal, ray_spread_horizontal, 1.0 - ray_positioning.x);
	// Add color to the rays
	vec3 ray_color = vec3(rays) * color.rgb;
	COLOR = vec4(ray_color, rays * color.a);
```
- `smoothstep` functions are used to gradually reduce the intensity of the rays towards the edges (vertical and horizontal), which helps in creating a fading effect at the boundaries.
- The final `color` of each pixel is calculated by multiplying the rays value by the uniform color, integrating the light intensity with the base color.
