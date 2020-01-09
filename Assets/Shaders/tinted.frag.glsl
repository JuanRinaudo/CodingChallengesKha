#version 450

out vec4 fragColor;

uniform vec4 TINT_COLOR;

void main() {
	vec4 color = TINT_COLOR;
	color.rgb *= TINT_COLOR.a;
	fragColor = color;
}