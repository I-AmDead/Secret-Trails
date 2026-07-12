// https://www.shadertoy.com/view/tdlyW2

uniform float3 radiation_effect;

struct RadiationEffectConstants
{
    static const float Spacing = 70.f;
    static const float Power = 4.0f;
};

float random(float n) { return frac(cos(n) * 343.42f); }

float random_range() { return 1.5f + frac(sin(dot(float2(37.2f, 42.5f), float2(13.5f, 17.7f))) * 0.5f + 0.5f); }

float random_IGN(float2 position, float offset = 0.f)
{
    const float3 magic = float3(61.11056f, 5.83715f, 5292.9189f);
    return frac(magic.z * frac(dot(position + offset, magic.xy)));
}

float2 generate_green_points(float2 uv, float spacing)
{
    uv /= random_range();

    float2 gridUV = round(uv * spacing) / spacing;

    float phase = random_IGN(gridUV, 0.0) * 6.2832;

    float speed = lerp(0.5, 1.5, radiation_effect.z) + random_IGN(gridUV, 1.0);
    float amp = lerp(0.03, 0.015, radiation_effect.z);

    float2 offset = float2(cos(phase + timers.x * speed * 1.2), sin(phase - timers.x * speed * 1.2)) * amp;
    float2 pointPos = gridUV + offset;

    float dist = distance(uv, pointPos);
    float smoothingFactor = smoothstep(0.09f, 0.014f, dist * spacing);

    float noiseValue = random_IGN(gridUV, random(timers.x * 0.5));

    return float2(noiseValue, smoothingFactor);
}

float3 rad_effect(float3 color, float2 tc)
{
    float fRadEffect = lerp(0, RadiationEffectConstants::Power, radiation_effect.z);

    float2 center = float2(0.5, 0.5);
    float distFromCenter = length(tc.xy - center);
    float fade = smoothstep(lerp(0.3, 0.05, radiation_effect.z), 1.0, distFromCenter);

    float2 green_points = generate_green_points(tc.xy, RadiationEffectConstants::Spacing);
    float3 radiation = smoothstep(0.8f, 0.95f, float3(0.f, green_points.x, 0.f)) * (fRadEffect * fade * green_points.y);

    return radiation;
}