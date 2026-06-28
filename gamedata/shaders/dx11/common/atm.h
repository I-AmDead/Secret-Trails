///////////////////////////////////////////////////////////////////////////////////////////

// add more blur for completed smallsky texture
#define SMALLSKY_BLUR_INTENSITY 1.0f // additional blur intensity

// creates more light by a vector from the sky
#define SMALLSKY_TOP_VECTOR_POWER 0.8f // this vector intensity

// Break default bloom to soften the overall picture
#define BROKE_BLOOM_POWER 1.5f // breaking intensity

// Uncharted 2 tonemapping
#define UNCHARTED2TONEMAP_WHITEPT 1.35 // Linear White Point Value
#define UNCHARTED2TONEMAP_EXPOSURE 1.0 // Exposure

#define __lum__ float3(0.2126f, 0.7152f, 0.0722f)

#define TONEMAP_SCALE_FACTOR float(2.0f / 3.0f)

float Luminance(float3 color) { return dot(color, __lum__); }

float3 TonemapFunction(float3 x)
{
    const float fWhiteIntensity = 11.2;
    const float fWhiteIntensitySQR = fWhiteIntensity * fWhiteIntensity;
    return (x * (1 + x / fWhiteIntensitySQR)) / (x + 1);
}

float3 TonemapFunctionGet(float3 c)
{
    float3 tc = TonemapFunction(c);
    float l = Luminance(c);
    return lerp(c * TonemapFunction(l) / l, tc, tc);
}

float3 InverseTonemapFunction(float3 x) { return exp(x) - 1.0f; }

float3 TonemapRobo(float3 c)
{
    float l = Luminance(c);
    return c / sqrt(1.0 + l * l);
}

float TonemapRobo(float c) { return c / sqrt(1.0 + c * c); }

float4 BrokeBloom(float4 c)
{
    c *= BROKE_BLOOM_POWER;
    c = float4(TonemapRobo(c.rgb), TonemapRobo(c.a));
    c /= BROKE_BLOOM_POWER;
    return c;
}

float3 Uncharted2ACES(float3 x)
{
    static const float A = 0.15f; // Shoulder strength
    static const float B = 0.50f; // Linear strength
    static const float C = 0.10f; // Linear angle
    static const float D = 0.20f; // Toe strength
    static const float E = 0.02f; // Toe numerator
    static const float F = 0.30f; // Toe denominator
    return ((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
}

float3 Uncharted2Tonemap(float3 c)
{
    c *= UNCHARTED2TONEMAP_EXPOSURE;
    float3 tc = Uncharted2ACES(c);
    float l = Luminance(c);
    c = lerp(c * Uncharted2ACES(l) / l, tc, tc);
    c /= Uncharted2ACES(UNCHARTED2TONEMAP_WHITEPT);

    return c;
}

#define Red 8.0 //[1.0 to 15.0]
#define Green 8.0 //[1.0 to 15.0]
#define Blue 8.0 //[1.0 to 15.0]
#define ColorGamma 2.5 //[0.1 to 2.5] Adjusts the colorfulness of the effect in a manner similar to Vibrance. 1.0 is neutral.
#define DPXSaturation 3.0 //[0.0 to 8.0] Adjust saturation of the effect. 1.0 is neutral.
#define RedC 0.36 //[0.60 to 0.20]
#define GreenC 0.36 //[0.60 to 0.20]
#define BlueC 0.36 //[0.60 to 0.20]
#define Blend 0.2 //[0.00 to 1.00] How strong the effect should be.

static const float3x3 RGB = float3x3(2.67147117265996, -1.26723605786241, -0.410995602172227, -1.02510702934664, 1.98409116241089, 0.0439502493584124, 0.0610009456429445, -0.223670750812863, 1.15902104167061);
static const float3x3 XYZ = float3x3(0.500303383543316, 0.338097573222739, 0.164589779545857, 0.257968894274758, 0.676195259144706, 0.0658358459823868, 0.0234517888692628, 0.1126992737203, 0.866839673124201);

#define Technicolor2_Red_Strength 0.4 //[0.05 to 1.0] Color Strength of Red channel. Higher means darker and more intense colors.
#define Technicolor2_Green_Strength 0.4 //[0.05 to 1.0] Color Strength of Green channel. Higher means darker and more intense colors.
#define Technicolor2_Blue_Strength 0.4 //[0.05 to 1.0] Color Strength of Blue channel. Higher means darker and more intense colors.
#define Technicolor2_Brightness 1.0 //[0.5 to 1.5] Brightness Adjustment, higher means brighter image.
#define Technicolor2_Strength 1.0 //[0.0 to 1.0] Strength of Technicolor effect. 0.0 means original image.
#define Technicolor2_Saturation 0.7

float3 TechnicolorATM(float3 colorInput)
{
    float3 Color_Strength = float3(Technicolor2_Red_Strength, Technicolor2_Green_Strength, Technicolor2_Blue_Strength);
    float3 source = saturate(colorInput.rgb);
    float3 temp = 1.0 - source;
    float3 target = temp.grg;
    float3 target2 = temp.bbr;
    float3 temp2 = source.rgb * target.rgb;
    temp2.rgb *= target2.rgb;

    temp.rgb = temp2.rgb * Color_Strength;
    temp2.rgb *= Technicolor2_Brightness;

    target.rgb = temp.grg;
    target2.rgb = temp.bbr;

    temp.rgb = source.rgb - target.rgb;
    temp.rgb += temp2.rgb;
    temp2.rgb = temp.rgb - target2.rgb;

    colorInput.rgb = lerp(source.rgb, temp2.rgb, Technicolor2_Strength);

    colorInput.rgb = lerp(dot(colorInput.rgb, 0.333), colorInput.rgb, Technicolor2_Saturation);

    return colorInput.rgb;
}

float3 DPX(float3 InputColor)
{
    float DPXContrast = 0.1;
    float DPXGamma = 1.0;
    float RedCurve = Red;
    float GreenCurve = Green;
    float BlueCurve = Blue;
    float3 RGB_Curve = float3(Red, Green, Blue);
    float3 RGB_C = float3(RedC, GreenC, BlueC);
    float3 B = InputColor.rgb;
    B = pow(abs(B), 1.0 / DPXGamma);
    B = B * (1.0 - DPXContrast) + (0.5 * DPXContrast);
    float3 Btemp = (1.0 / (1.0 + exp(RGB_Curve / 2.0)));
    B = ((1.0 / (1.0 + exp(-RGB_Curve * (B - RGB_C)))) / (-2.0 * Btemp + 1.0)) + (-Btemp / (-2.0 * Btemp + 1.0));
    float value = max(max(B.r, B.g), B.b);
    float3 color = B / value;
    color = pow(abs(color), 1.0 / ColorGamma);
    float3 c0 = color * value;
    c0 = mul(XYZ, c0);
    float luma = dot(c0, float3(0.30, 0.59, 0.11));
    c0 = (1.0 - DPXSaturation) * luma + DPXSaturation * c0;
    c0 = mul(RGB, c0);
    InputColor.rgb = lerp(InputColor.rgb, c0, Blend);

    return InputColor;
}

#define Curves_contrast 0.2 // [-1.0, 1.0] контраст, по умолчанию 0.0

float3 Curves(float3 colorInput)
{
    float3 color = colorInput.rgb;
    float3 lumCoeff = float3(0.2126, 0.7152, 0.0722);
    float Curves_contrast_blend = Curves_contrast;

    float luma = dot(lumCoeff, color);
    float3 chroma = color - luma;
    luma = ((luma - 0.5) / ((0.5 / (4.0 / 3.0)) + abs((luma - 0.5) * 1.25))) + 0.5;

    color = luma + chroma;
    colorInput.rgb = lerp(colorInput.rgb, color, Curves_contrast_blend);

    return colorInput;
}