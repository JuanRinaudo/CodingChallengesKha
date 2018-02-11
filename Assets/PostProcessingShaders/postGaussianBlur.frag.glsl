#version 450

in vec2 texCoord;
out vec4 FragColor;

uniform sampler2D tex;
uniform int BLUR_SIZE;       
uniform float SIGMA;
uniform vec2 DIRECTION;
uniform vec2 RENDER_SIZE;
 
const float PI = 3.14159265;
 
void main() {
	vec3 incrementalGaussian;
	incrementalGaussian.x = 1.0 / (sqrt(2.0 * PI) * SIGMA);
	incrementalGaussian.y = exp(-0.5 / (SIGMA * SIGMA));
	incrementalGaussian.z = incrementalGaussian.y * incrementalGaussian.y;

	vec4 avgValue = vec4(0.0);
	float coefficientSum = 0.0;

	avgValue += texture(tex, texCoord) * incrementalGaussian.x;
	coefficientSum += incrementalGaussian.x;
	incrementalGaussian.xy *= incrementalGaussian.yz;

	vec2 texSizeInverted = vec2(1.0, 1.0) / RENDER_SIZE;
	for (float i = 1.0; i <= BLUR_SIZE; i++) { 
		avgValue += texture(tex, texCoord - i * texSizeInverted *
								DIRECTION) * incrementalGaussian.x;
		avgValue += texture(tex, texCoord + i * texSizeInverted *
								DIRECTION) * incrementalGaussian.x;         
		coefficientSum += 2.0 * incrementalGaussian.x;
		incrementalGaussian.xy *= incrementalGaussian.yz;
	}
	
	FragColor = avgValue / coefficientSum;
}