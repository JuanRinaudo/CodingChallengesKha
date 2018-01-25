#version 450

in vec3 position;
in vec3 normal;
in vec2 tex;
in vec4 color;

out vec4 fragmentColor;
out vec3 fragmentNormal;

uniform mat4 MVP_MATRIX;
uniform mat3 NORMAL_MATRIX;

void main() {
	gl_Position = MVP_MATRIX * vec4(position, 1.0);
	fragmentNormal = normalize(NORMAL_MATRIX * normal);
	fragmentColor = color;
}