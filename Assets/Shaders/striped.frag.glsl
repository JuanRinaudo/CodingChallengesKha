#version 450

in vec4 fragmentColor;
in vec2 texCoord;
out vec4 fragColor;

float rand(vec2 v2){
    return fract(sin(dot(v2.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec2 t = floor(texCoord * 10);
    vec4 color = (rand(t) * 0.5 + 0.5) * fragmentColor;
	color.rgb *= color.a;
	fragColor = color;
}