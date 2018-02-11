#version 450

in vec2 texCoord;
out vec4 FragColor;

uniform sampler2D tex;

void main() {
	vec4 texcolor = texture(tex, texCoord);
	texcolor.rgb = vec3(texcolor.r + texcolor.g + texcolor.b) / 3.0;
	FragColor = vec4(texcolor.rgb, 1.0);
}