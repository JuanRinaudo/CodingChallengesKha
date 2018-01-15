#version 450

in vec3 position;
in vec2 tex;
in vec4 color;
in vec3 normal;

out vec4 fragmentColor;
out vec3 fragmentNormal;

uniform mat4 MVP;

void main() {
	gl_Position = MVP * vec4(position, 1.0);
	fragmentNormal = normal;
	fragmentColor = color;
}