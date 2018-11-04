#version 450

in vec4 fragmentColor;
in vec2 texCoord;
out vec4 fragColor;

uniform sampler2D TEXTURE;
uniform lowp float DELTA_WIDTH;
uniform lowp float DELTA_HEIGHT;

uniform int SOLITUDE;
uniform int OVERPOPULATION;
uniform int POPULATE;

void main() {
	int neighbors = int(
		(texture(TEXTURE, texCoord + vec2(-DELTA_WIDTH, -DELTA_HEIGHT)) +
		texture(TEXTURE, texCoord + vec2(-DELTA_WIDTH, 0)) +
		texture(TEXTURE, texCoord + vec2(-DELTA_WIDTH, DELTA_HEIGHT)) +
		texture(TEXTURE, texCoord + vec2(0, -DELTA_HEIGHT)) +
		texture(TEXTURE, texCoord + vec2(0, DELTA_HEIGHT)) +
		texture(TEXTURE, texCoord + vec2(DELTA_WIDTH, -DELTA_HEIGHT)) +
		texture(TEXTURE, texCoord + vec2(DELTA_WIDTH, 0)) +
		texture(TEXTURE, texCoord + vec2(DELTA_WIDTH, DELTA_HEIGHT))).r
	);

	lowp vec4 color = texture(TEXTURE, texCoord);
	lowp float life = color.r;
	lowp float solitude = float(life > 0 && neighbors <= SOLITUDE);
	lowp float overpulated = float(life > 0 && neighbors >= OVERPOPULATION);
	lowp float populate = float(life == 0 && neighbors == POPULATE);
	life = clamp(life - solitude - overpulated + populate, 0, 1);

	fragColor = vec4(life, life, life, 1.0);
}