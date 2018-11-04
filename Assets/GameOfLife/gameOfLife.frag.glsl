#version 450

in vec4 fragmentColor;
in vec2 texCoord;
out vec4 fragColor;

uniform sampler2D TEXTURE;
uniform float DELTA_WIDTH;
uniform float DELTA_HEIGHT;

uniform int SOLITUDE;
uniform int OVERPOPULATION;
uniform int POPULATE;

void main() {
	int neighbors = 
		int(texture(TEXTURE, texCoord + vec2(-DELTA_WIDTH, -DELTA_HEIGHT)).r) +
		int(texture(TEXTURE, texCoord + vec2(-DELTA_WIDTH, 0)).r) +
		int(texture(TEXTURE, texCoord + vec2(-DELTA_WIDTH, DELTA_HEIGHT)).r) +
		int(texture(TEXTURE, texCoord + vec2(0, -DELTA_HEIGHT)).r) +
		int(texture(TEXTURE, texCoord + vec2(0, DELTA_HEIGHT)).r) +
		int(texture(TEXTURE, texCoord + vec2(DELTA_WIDTH, -DELTA_HEIGHT)).r) +
		int(texture(TEXTURE, texCoord + vec2(DELTA_WIDTH, 0)).r) +
		int(texture(TEXTURE, texCoord + vec2(DELTA_WIDTH, DELTA_HEIGHT)).r);

	vec4 color = texture(TEXTURE, texCoord);
	if(color.r > 0) {
		if(neighbors <= SOLITUDE || neighbors >= OVERPOPULATION) { 
			color = vec4(0, 0, 0, 1);
		}
	} else {
		if(neighbors == POPULATE) {
			color = vec4(1, 1, 1, 1);
		}
	}

	fragColor = color;
}