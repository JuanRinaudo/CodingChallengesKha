#version 450

in vec3 pos;

uniform mat4 MVP_MATRIX;

void main() {
    gl_Position = MVP_MATRIX * vec4(pos, 1.0);
}