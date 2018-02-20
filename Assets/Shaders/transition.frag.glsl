#version 450

in vec4 fragmentColor;
in vec2 texCoord;
out vec4 fragColor;

uniform sampler2D TEXTURE;
uniform float TRANSITION;
uniform int TILES_X;
uniform int TILES_Y;

void main() {
	vec4 texColor = texture(TEXTURE, vec2(texCoord.x * TILES_X, texCoord.y * TILES_Y));
	vec4 color = vec4(fragmentColor.xyz, ceil(texColor.w - TRANSITION));
	color.rgb *= color.a;
	fragColor = color;
}