shader_type canvas_item;
uniform sampler2D emissionTexture;
uniform vec4 glowColor : hint_color = vec4(1.0);

void fragment ()
{
	vec4 currentColor = texture(TEXTURE,UV);
	vec4 emissionColor = texture(emissionTexture,UV);
	if (emissionColor.a > 0f)
	{
		COLOR = (emissionColor + glowColor);
	}
	else
	{
		COLOR = currentColor;
	}
}