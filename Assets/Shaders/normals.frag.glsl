#version 450

in vec4 fragmentColor;
in vec3 fragmentNormal;

out vec4 fragColor;

void main() {
	vec4 color = vec4(abs(fragmentNormal), 1.0);
	color.rgb *= color.a;
	fragColor = color;
}