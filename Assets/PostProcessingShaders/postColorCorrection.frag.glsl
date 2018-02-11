#version 450

in vec2 texCoord;
out vec4 FragColor;

uniform sampler2D tex;
uniform float RED;
uniform float GREEN;
uniform float BLUE;
uniform float CONTRAST;
uniform float BRIGHTNESS;
uniform float TEMPERATURE;
uniform float TINT;
uniform float GAMMA;
uniform float HUE;
uniform float SATURATION;
uniform float LUMINATION;

vec4 rgbToHsl(vec4 col)
{
    float maxComponent = max(col.r, max(col.g,col.b));
    float minComponent = min(col.r, min(col.g,col.b));
    float dif = maxComponent - minComponent;
    float add = maxComponent + minComponent;
    vec4 outColor = vec4(0.0, 0.0, 0.0, col.a);
    
    if (minComponent == maxComponent) {
        outColor.r = 0.0;
    } else if (col.r == maxComponent) {
        outColor.r = mod(((60.0 * (col.g - col.b) / dif) + 360.0), 360.0);
    } else if (col.g == maxComponent) {
        outColor.r = (60.0 * (col.b - col.r) / dif) + 120.0;
    } else {
        outColor.r = (60.0 * (col.r - col.g) / dif) + 240.0;
    }

    outColor.b = 0.5 * add;
    
    if (outColor.b == 0.0) {
        outColor.g = 0.0;
    } else if (outColor.b <= 0.5) {
        outColor.g = dif / add;
    } else {
        outColor.g = dif / (2.0 - add);
    }
    
    outColor.r /= 360.0;
    
    return outColor;
}

float hueToRgb(float p, float q, float h)
{
    if (h < 0.0) {
        h += 1.0;
    } else if (h > 1.0) {
        h -= 1.0;
    }

    if ((h * 6.0) < 1.0) {
        return p + (q - p) * h * 6.0;
    } else if ((h * 2.0) < 1.0) {
        return q;
    } else if ((h * 3.0) < 2.0) {
        return p + (q - p) * ((2.0 / 3.0) - h) * 6.0;
    } else {
        return p;
    }
}

vec4 hslToRgb(vec4 col)
{
    vec4 outColor = vec4(0.0, 0.0, 0.0, col.a);
    float p, q, tr, tg, tb;
    if (col.b <= 0.5) {
        q = col.b * (1.0 + col.g);
    } else {
        q = col.b + col.g - (col.b * col.g);
    }

    p = 2.0 * col.b - q;
    tr = col.r + (1.0 / 3.0);
    tg = col.r;
    tb = col.r - (1.0 / 3.0);

    outColor.r = hueToRgb(p, q, tr);
    outColor.g = hueToRgb(p, q, tg);
    outColor.b = hueToRgb(p, q, tb);

    return outColor;
}

void main() {
	vec4 texcolor = texture(tex, texCoord);

    vec4 hsl = rgbToHsl(texcolor);
    hsl.x = mod(hsl.x + HUE, 1.0);
    hsl.y = clamp(hsl.y + SATURATION, 0.0, 1.0);
    hsl.z = clamp(hsl.z + LUMINATION, 0.0, 1.0);

	texcolor = hslToRgb(hsl);

	texcolor = (texcolor - 0.5) * CONTRAST + 0.5 + BRIGHTNESS;	
	texcolor = vec4(pow(abs(texcolor.r), GAMMA), pow(abs(texcolor.g), GAMMA), pow(abs(texcolor.b), GAMMA), 1.0);
	
	texcolor.r = texcolor.r * RED - TEMPERATURE;
	texcolor.g = texcolor.g * GREEN + TINT;
	texcolor.b = texcolor.b * BLUE + TEMPERATURE;

	FragColor = texcolor;
}