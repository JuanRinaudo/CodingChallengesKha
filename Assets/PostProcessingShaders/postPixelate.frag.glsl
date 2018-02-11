#version 450

in vec2 texCoord;
out vec4 FragColor;

uniform sampler2D tex;
uniform vec2 CELL_SIZE;
uniform vec2 RENDER_SIZE;

void main() {
	vec4 texcolor = vec4(0.0);
	vec2 texSizeInverted = vec2(1.0, 1.0) / RENDER_SIZE;
	vec2 cellPosition = floor(texCoord * (RENDER_SIZE / CELL_SIZE)) / (RENDER_SIZE / CELL_SIZE);
	
	texcolor += texture(tex, vec2(cellPosition.x, cellPosition.y)) * 0.2;
	texcolor += texture(tex, vec2(cellPosition.x + CELL_SIZE.x * 0.5 * texSizeInverted.x, cellPosition.y + CELL_SIZE.y * 0.5 * texSizeInverted.y)) * 0.2;
	texcolor += texture(tex, vec2(cellPosition.x + CELL_SIZE.x * texSizeInverted.x, cellPosition.y)) * 0.2;
	texcolor += texture(tex, vec2(cellPosition.x, cellPosition.y + CELL_SIZE.y * texSizeInverted.y)) * 0.2;
	texcolor += texture(tex, vec2(cellPosition.x + CELL_SIZE.x * texSizeInverted.x, cellPosition.y + CELL_SIZE.y * texSizeInverted.y)) * 0.2;

	FragColor = texcolor;
}