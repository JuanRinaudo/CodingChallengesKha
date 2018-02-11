#version 450

in vec2 texCoord;
out vec4 FragColor;

uniform sampler2D tex;
uniform int BLUR_VALUE;
uniform vec2 RENDER_SIZE;

void main() {
	vec4 texcolor = vec4(0.0);
	vec2 textureSizeInv = vec2(1.0, 1.0) / RENDER_SIZE;
	vec2 delta = vec2(BLUR_VALUE / 2.0, BLUR_VALUE / 2.0) * textureSizeInv;
	for(int i = 0; i < BLUR_VALUE; i++) {
		for(int j = 0; j < BLUR_VALUE; j++) {
			texcolor += texture(tex, texCoord + vec2(i, j) * textureSizeInv - delta);
		}
	}
	texcolor /= BLUR_VALUE * BLUR_VALUE;
	FragColor = texcolor;
}