#version 450

in vec4 fragmentColor;
in vec2 texCoord;
out vec4 fragColor;

uniform sampler2D TEXTURE;

void main() {
	vec4 texcolor = texture(TEXTURE, texCoord);
	fragColor = texcolor * fragmentColor;
}