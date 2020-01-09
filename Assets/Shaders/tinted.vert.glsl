#version 450

in vec3 position;

uniform mat4 MVP_MATRIX;

void main() {
	gl_Position = MVP_MATRIX * vec4(position, 1.0);
}