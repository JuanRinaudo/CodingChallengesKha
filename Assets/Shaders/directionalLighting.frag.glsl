#version 450

in vec4 fragmentColor;
in vec3 fragmentNormal;
out vec4 fragColor;

uniform vec4 LIGHT_DIRECTION;
uniform vec4 LIGHT_COLOR;
uniform vec4 AMBIENT_COLOR;

void main() {
	vec3 lightDir = normalize(LIGHT_DIRECTION).xyz;
	fragColor = max(fragmentColor * LIGHT_COLOR * dot(fragmentNormal, lightDir), AMBIENT_COLOR);
}