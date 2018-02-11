#version 450

in vec2 texCoord;
out vec4 FragColor;

uniform sampler2D tex;
uniform int COLOR_QUANTIZATION;

void main() {
	vec4 texcolor = texture(tex, texCoord);
	FragColor = round(texcolor * COLOR_QUANTIZATION) / COLOR_QUANTIZATION;
}