///////////////////////////////////////////////////////////////////////////////////////////

// creates more light by a vector from the sky
#define SMALLSKY_TOP_VECTOR_POWER 0.75f // this vector intensity

// Break default bloom to soften the overall picture
#define BROKE_BLOOM_POWER 1.5f // breaking intensity

// Uncharted 2 tonemapping
#define UNCHARTED2TONEMAP_WHITEPT 1.35 // Linear White Point Value
#define UNCHARTED2TONEMAP_EXPOSURE 1.0 // Exposure

#define TONEMAP_SCALE_FACTOR float(2.0f / 3.0f)

///////////////////////////////////////////////////////////////////////////////////////////

float Luminance(float3 color) { return dot(color, LUMINANCE_VECTOR); }

///////////////////////////////////////////////////////////////////////////////////////////

float3 TonemapFunction(float3 x, float w)
{
    return tonemap_sRGB(x, w);
}

float3 TonemapFunctionGet(float3 c, float w)
{
    float3 tc = TonemapFunction(c, w);
    float l = Luminance(c);
    return lerp(c * TonemapFunction(l, w) / l, tc, tc);
}

void TonemapFunctionSky(out float4 low, out float4 high, float3 rgb, float scale)
{
    rgb *= scale;

    low = float4(rgb, 0);
    high = float4(rgb / def_hdr, 0);
}

///////////////////////////////////////////////////////////////////////////////////////////

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

///////////////////////////////////////////////////////////////////////////////////////////

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

///////////////////////////////////////////////////////////////////////////////////////////
