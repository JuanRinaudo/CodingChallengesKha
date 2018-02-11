#version 450

in vec2 texCoord;
out vec4 FragColor;

uniform sampler2D tex;
uniform float FXAA_SPAN_MAX;
uniform float FXAA_REDUCE_MIN;
uniform float FXAA_REDUCE_MUL;
uniform vec2 RENDER_SIZE;

vec4 FXAA() {
    vec4 color;
    mediump vec2 inverseVP = vec2(1.0 / RENDER_SIZE.x, 1.0 / RENDER_SIZE.y);
    vec3 rgbNW = texture(tex, texCoord + vec2(-1.0, -1.0) * inverseVP).xyz;
    vec3 rgbNE = texture(tex, texCoord + vec2(1.0, -1.0) * inverseVP).xyz;
    vec3 rgbSW = texture(tex, texCoord + vec2(-1.0, 1.0) * inverseVP).xyz;
    vec3 rgbSE = texture(tex, texCoord + vec2(1.0, 1.0) * inverseVP).xyz;
    vec4 texColor = texture(tex, texCoord);
    vec3 rgbM  = texColor.xyz;
    vec3 luma = vec3(0.299, 0.587, 0.114);
    float lumaNW = dot(rgbNW, luma);
    float lumaNE = dot(rgbNE, luma);
    float lumaSW = dot(rgbSW, luma);
    float lumaSE = dot(rgbSE, luma);
    float lumaM  = dot(rgbM,  luma);
    float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
    float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
    
    mediump vec2 dir;
    dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
    dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));
    
    float dirReduce = max((lumaNW + lumaNE + lumaSW + lumaSE) *
                          (0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);
    
    float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
    dir = min(vec2(FXAA_SPAN_MAX, FXAA_SPAN_MAX),
              max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),
              dir * rcpDirMin)) * inverseVP;
    
    vec3 rgbA = 0.5 * (
        texture(tex, gl_FragCoord.xy * inverseVP + dir * (1.0 / 3.0 - 0.5)).xyz +
        texture(tex, gl_FragCoord.xy * inverseVP + dir * (2.0 / 3.0 - 0.5)).xyz);
    vec3 rgbB = rgbA * 0.5 + 0.25 * (
        texture(tex, gl_FragCoord.xy * inverseVP + dir * -0.5).xyz +
        texture(tex, gl_FragCoord.xy * inverseVP + dir * 0.5).xyz);

    float lumaB = dot(rgbB, luma);
    if ((lumaB < lumaMin) || (lumaB > lumaMax))
        color = vec4(rgbA, texColor.a);
    else
        color = vec4(rgbB, texColor.a);
    return color;
}

void main() {
	FragColor = FXAA();
}
