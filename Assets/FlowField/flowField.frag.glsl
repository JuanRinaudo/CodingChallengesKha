#version 450

in vec4 fragmentColor;
in vec2 texCoord;
out vec4 fragColor;

uniform sampler2D TEXTURE;
uniform sampler2D FLOW_TEXTURE;

uniform highp float DELTA_WIDTH;
uniform highp float DELTA_HEIGHT;

uniform highp float COLOR_MULTIPLY;
uniform highp float SPEED;

void main() {
    highp vec4 flowField = texture(TEXTURE, texCoord);
    highp vec4 targetColor = texture(FLOW_TEXTURE, texCoord + vec2((flowField.x - 0.5) * SPEED * DELTA_WIDTH, (flowField.y - 0.5) * SPEED * DELTA_HEIGHT));
    highp vec4 currentColor = texture(FLOW_TEXTURE, texCoord);
    highp vec4 color = currentColor * (1 - COLOR_MULTIPLY) + targetColor * COLOR_MULTIPLY;

	fragColor = color;
}