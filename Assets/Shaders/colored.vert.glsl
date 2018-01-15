#version 450

in vec3 position;
in vec2 tex;
in vec4 color;

out vec4 fragmentColor;

uniform mat4 MVP;

void main() {
	gl_Position = MVP * vec4(position, 1.0);
	fragmentColor = color;
}