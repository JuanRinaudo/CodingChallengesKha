#version 450

in vec3 position;
in vec3 normal;
in vec2 texuv;
in vec4 color;

out vec3 fragmentPosition;
out vec4 fragmentColor;
out vec3 fragmentNormal;
out vec2 texCoord;

uniform mat4 MVP_MATRIX;
uniform mat4 MODEL_MATRIX;
uniform mat3 NORMAL_MATRIX;

void main() {
	gl_Position = MVP_MATRIX * vec4(position, 1.0);
	fragmentColor = color;
	fragmentPosition = vec3(MODEL_MATRIX * vec4(position, 1.0));
	fragmentNormal = normalize(NORMAL_MATRIX * normal);
	texCoord = texuv;
}