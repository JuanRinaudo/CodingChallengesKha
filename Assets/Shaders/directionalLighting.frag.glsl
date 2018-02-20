#version 450

in vec3 fragmentPosition;
in vec4 fragmentColor;
in vec3 fragmentNormal;
out vec4 fragColor;

uniform vec4 LIGHT_DIRECTION;
uniform vec4 LIGHT_COLOR;
uniform vec4 AMBIENT_COLOR;

void main() {
	vec3 ambient = AMBIENT_COLOR.rgb;
	ambient.rgb *= AMBIENT_COLOR.a;

	float diff = max(dot(fragmentNormal, LIGHT_DIRECTION.xyz), 0.0);
	vec3 diffuse = diff * LIGHT_COLOR.rgb;
	diffuse.rgb *= LIGHT_COLOR.a;

	// vec3 lightDirection = normalize(LIGHT_POSITION.xyz - fragmentPosition.xyz); //For point lights
	
	// float specularStrength = 0.1; //For specular
	// vec3 viewDir = normalize(VIEW_POSITION - fragmentPosition);
	// vec3 reflectDir = reflect(-LIGHT_DIRECTION, fragmentNormal);
	// float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
	// vec3 specular = specularStrength * spec * LIGHT_COLOR;

	vec4 color = vec4((ambient + diffuse) * fragmentColor.rgb, fragmentColor.a);
	color.rgb *= color.a;
	fragColor = color;
}