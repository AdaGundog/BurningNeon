shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float line_thickness : hint_range(0, 10) = 2.0;
uniform float glow_intensity : hint_range(0, 20) = 5.0; // Increased range

void fragment() {
    vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
    float outline = 0.0;
    
    outline += texture(TEXTURE, UV + vec2(-size.x, 0)).a;
    outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
    outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
    outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
    outline = min(outline, 1.0); // Keep outline factor at 1.0 max

    vec4 color = texture(TEXTURE, UV);
    
    // Calculate the outline mask (where the outline is, but the sprite is NOT)
    float outline_mask = max(0.0, outline - color.a);
    
    // Create the glowing color for the outline
    vec3 glowing_rgb = line_color.rgb * glow_intensity;
    
    // Mix the original sprite (chalky) with the super-bright outline
    vec4 chalk_texture = vec4(line_color.rgb, color.a * 0.6);
    
    // We apply the intensity specifically to the RGB of the outline area
    vec3 final_rgb = mix(chalk_texture.rgb, glowing_rgb, outline_mask);
    float final_a = max(chalk_texture.a, outline_mask);

    COLOR = vec4(final_rgb, final_a);
}