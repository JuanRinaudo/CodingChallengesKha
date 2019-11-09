#version 450

in vec4 fragmentColor;
in vec2 texCoord;
out vec4 fragColor;

uniform sampler2D IMAGE;
uniform sampler2D NEXT_IMAGE;
uniform float TIME;

void main() {
	vec4 texcolor = texture(IMAGE, texCoord);
	vec4 color = texcolor * fragmentColor;
	color.rgb *= color.a;
	fragColor = color;
}