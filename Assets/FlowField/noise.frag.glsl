#version 450

in vec4 fragmentColor;
in vec2 texCoord;
out vec4 fragColor;

uniform highp float TIME;

uniform highp float DELTA_WIDTH;
uniform highp float DELTA_HEIGHT;

#define M_PI 3.14159265358979323846

float rand(vec2 co){return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);}
float rand (vec2 co, float l) {return rand(vec2(rand(co), l));}
float rand (vec2 co, float l, float t) {return rand(vec2(rand(co, l), t));}

float perlin(vec2 p, float dim, float time) {
	vec2 pos = floor(p * dim);
	vec2 posx = pos + vec2(1.0, 0.0);
	vec2 posy = pos + vec2(0.0, 1.0);
	vec2 posxy = pos + vec2(1.0);
	
	float c = rand(pos, dim, time);
	float cx = rand(posx, dim, time);
	float cy = rand(posy, dim, time);
	float cxy = rand(posxy, dim, time);
	
	vec2 d = fract(p * dim);
	d = -0.5 * cos(d * M_PI) + 0.5;
	
	float ccx = mix(c, cx, d.x);
	float cycxy = mix(cy, cxy, d.x);
	float center = mix(ccx, cycxy, d.y);
	
	return center;
}

void main() {
	fragColor = vec4(
		perlin(vec2(texCoord.x, texCoord.y) * (1 / DELTA_WIDTH), 1, TIME),
		perlin(vec2(texCoord.y, texCoord.x) * (1 / DELTA_HEIGHT), 1, TIME), 0.0, 1.0
	);
}