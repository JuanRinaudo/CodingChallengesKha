#version 450

const int MAX_JOINTS = 50;//max joints allowed in a skeleton

in vec3 position;
in vec3 normal;
in vec2 texuv;
in vec4 color;
in vec4 jointIndex;
in vec4 jointWeight;

out vec4 fragmentColor;
out vec2 texCoord;

uniform mat4 JOINT_TRANSFORMS[MAX_JOINTS];
uniform mat4 MVP_MATRIX;

void main() {
	vec4 newVertex;
    vec4 newNormal;
    int index;
	
    index = int(jointIndex.x);
    newVertex = (JOINT_TRANSFORMS[index] * vec4(position, 1.0)) * jointWeight.x;
    newNormal = (JOINT_TRANSFORMS[index] * vec4(normal, 0.0)) * jointWeight.x;
    index = int(jointIndex.y);
    newVertex = (JOINT_TRANSFORMS[index] * vec4(position, 1.0)) * jointWeight.y + newVertex;
    newNormal = (JOINT_TRANSFORMS[index] * vec4(normal, 0.0)) * jointWeight.y + newNormal;
    index = int(jointIndex.z);
    newVertex = (JOINT_TRANSFORMS[index] * vec4(position, 1.0)) * jointWeight.z + newVertex;
    newNormal = (JOINT_TRANSFORMS[index] * vec4(normal, 0.0)) * jointWeight.z + newNormal;
    index = int(jointIndex.w);
    newVertex = (JOINT_TRANSFORMS[index] * vec4(position, 1.0)) * jointWeight.w + newVertex;
    newNormal = (JOINT_TRANSFORMS[index] * vec4(normal, 0.0)) * jointWeight.w + newNormal;

	gl_Position = MVP_MATRIX * vec4(newVertex.xyz, 1.0);
	fragmentColor = color;
	texCoord = texuv;
}