#version 450

in vec3 position;
in vec2 texuv;
in vec4 color;

out vec4 fragmentColor;
out vec2 texCoord;

uniform mat4 MVP;

void main() {
	gl_Position = MVP * vec4(position, 1.0);
	fragmentColor = color;
	texCoord = texuv;
}