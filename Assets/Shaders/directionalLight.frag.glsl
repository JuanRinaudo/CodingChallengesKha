#version 450

in vec4 fragmentColor;
in vec3 fragmentNormal;
out vec4 fragColor;

uniform vec3 LIGHT_POSITION;

void main() {
	fragColor = fragmentColor * clamp(1 - dot(fragmentNormal, LIGHT_POSITION), 0, 1);
}