#version 450

in vec4 fragmentColor;
in vec3 fragmentNormal;
in vec2 texCoord;
out vec4 fragColor;

uniform float CUTOFF_VALUE;
uniform sampler2D TEXTURE;

uniform vec4 LIGHT_DIRECTION;
uniform vec4 LIGHT_COLOR;
uniform vec4 AMBIENT_COLOR;

void main() {
	vec4 texcolor = texture(TEXTURE, texCoord);
	if(texcolor.x > CUTOFF_VALUE) {
		discard;
	}
	vec3 lightDirection = normalize(LIGHT_DIRECTION).xyz;
	vec4 color = max(fragmentColor * LIGHT_COLOR * dot(fragmentNormal, lightDirection), AMBIENT_COLOR);
	color.rgb *= color.a;
	fragColor = color;
}