#version 450

in vec3 position;
in vec2 texuv;
in vec4 color;

out vec4 fragmentColor;
out vec2 texCoord;

uniform mat4 MV_MATRIX;
uniform mat4 PROJECTION;

void main() {
	gl_Position = PROJECTION * (MV_MATRIX * vec4(.0, .0, .0, 1.0) + vec4(position.xy, .0, .0));
	fragmentColor = color;
	texCoord = texuv;
}