//https://www.shadertoy.com/view/tdlyW2

// Параметры экранного эффекта
uniform float3 radiation_effect;

// Константы для радиационного эффекта
struct RadiationEffectConstants
{
    static const float Size = 40.f;
    static const float Power = 5.25f;
    static const float PowerNoise = 2.6f;
    static const float PowerInRadZone = 0.055f;
};

// Генерация случайного числа в диапазоне [0, 1) на основе входного числа
float random(float n) { return frac(cos(n) * 343.42f); }

// Генерация случайного числа в диапазоне [1.5, 2)
float random_range() { return 1.5f + frac(sin(dot(float2(37.2f, 42.5f), float2(13.5f, 17.7f))) * 0.5f + 0.5f); }

// Генерация случайного числа с использованием шума и смещения
float random_IGN(float2 position, float offset = 0.f) 
{
    const float3 magic = float3(61.11056f, 5.83715f, 5292.9189f);
    return frac(magic.z * frac(dot(position + offset, magic.xy)));
}

// Генерация зеленых точек на текстуре
float4 generate_green_points(float2 uv, float frequency, float amplitude, float spacing)
{
    // Изменение координаты uv
    uv.x = uv.x * (screen_res.x * screen_res.w) / (1.2f * random_range()) + timers.x * 0.14f;

    // Координаты в сетке с шагом spacing
    float2 gridUV = round(uv * spacing) / spacing;

    // Вычисление фактора для сглаживания
    float smoothingFactor = smoothstep(0.09f, 0.014f, distance(uv, gridUV) * spacing);

    // Получение значения шума
    float noiseValue = random_IGN(gridUV, random(timers.x) * 0.1f);

    // Возвращаемый цвет (зеленый цвет с учетом фактора сглаживания и значения шума)
    return float4(0.f, noiseValue, 0.f, smoothingFactor);
}

float3 rad_effect(float3 color, float2 tc)
{
    float fRadClamp = clamp(radiation_effect.x, 0.f, 10.f) * RadiationEffectConstants::Power;
    float fDistToRadZone = clamp(radiation_effect.y, 0.f, 20.f) * RadiationEffectConstants::PowerInRadZone;
    float3 radiation = float3(0.f, 0.f, 0.f);

    float factor;
    float2 center = float2(0.5, 0.5);
    float distFromCenter = length(tc.xy - center);
    float fade = smoothstep(0.2, 0.95, distFromCenter);
    float3 green_points;
		
    float4 (green_points, factor) = generate_green_points(tc.xy, 0.85f, 0.9f, RadiationEffectConstants::Size);

    radiation.rgb += (smoothstep(0.9f, 0.99f, (green_points)) * (RadiationEffectConstants::PowerNoise * (fRadClamp - fDistToRadZone) * fade * factor));

    // Output
    return radiation;
}