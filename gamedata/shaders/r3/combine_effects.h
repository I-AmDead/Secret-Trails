// Add more life to previous shader https://www.shadertoy.com/view/WllGRn
// Very similar to https://www.shadertoy.com/view/Wll3RS

// Force range [.1, .3]
#define FORCE .18
#define INIT_SPEED 80.
#define AMOUNT 10.

#define ANIMATION_SPEED 0.6
#define MOVEMENT_SPEED 0.5
#define MOVEMENT_DIRECTION float2(0.0, 1.0)

#define PARTICLE_SIZE 0.002
#define SPARK_COLOR float3(1.0, 0.35, 0.05) * 1.3

uniform float4 buzz_effect;
uniform float4 burn_effect;

float2 mod(float2 x, float y) { return x - y * floor(x / y); }

float random(float2 _st) { return frac(sin(dot(_st.xy, float2(12.9898, 78.233))) * 43758.5453123); }

float randoms(float x) { return frac(sin(x) * 10000.0); }

float noises(float2 p) { return randoms(p.x + p.y * 10000.0); }

float hash1_2(float2 x) { return frac(sin(dot(x, float2(52.127, 61.2871))) * 521.582); }

float2 hash2_2(float2 x) { return frac(sin(mul(x, float2x2(20.52, 24.1994, 70.291, 80.171))) * 492.194); }

// Simple interpolated noise
float2 noise2_2(float2 uv)
{
    // float2 f = frac(uv);
    float2 f = smoothstep(0.0, 1.0, frac(uv));

    float2 uv00 = floor(uv);
    float2 uv01 = uv00 + float2(0, 1);
    float2 uv10 = uv00 + float2(1, 0);
    float2 uv11 = uv00 + 1.0;
    float2 v00 = hash2_2(uv00);
    float2 v01 = hash2_2(uv01);
    float2 v10 = hash2_2(uv10);
    float2 v11 = hash2_2(uv11);

    float2 v0 = lerp(v00, v01, f.y);
    float2 v1 = lerp(v10, v11, f.y);
    float2 v = lerp(v0, v1, f.x);

    return v;
}

// Simple interpolated noise
float noise1_2(float2 uv)
{
    float2 f = frac(uv);
    // float2 f = smoothstep(0.0, 1.0, frac(uv));

    float2 uv00 = floor(uv);
    float2 uv01 = uv00 + float2(0, 1);
    float2 uv10 = uv00 + float2(1, 0);
    float2 uv11 = uv00 + 1.0;

    float v00 = hash1_2(uv00);
    float v01 = hash1_2(uv01);
    float v10 = hash1_2(uv10);
    float v11 = hash1_2(uv11);

    float v0 = lerp(v00, v01, f.y);
    float v1 = lerp(v10, v11, f.y);
    float v = lerp(v0, v1, f.x);

    return v;
}

float2 sw(float2 p) { return float2(floor(p.x), floor(p.y)); }
float2 se(float2 p) { return float2(ceil(p.x), floor(p.y)); }
float2 nw(float2 p) { return float2(floor(p.x), ceil(p.y)); }
float2 ne(float2 p) { return float2(ceil(p.x), ceil(p.y)); }

float smoothNoise(float2 p)
{
    float2 interp = smoothstep(0.0, 1.0, frac(p));
    float s = lerp(noises(sw(p)), noises(se(p)), interp.x);
    float n = lerp(noises(nw(p)), noises(ne(p)), interp.x);
    return lerp(s, n, interp.y);
}

float fractalNoise(float2 p)
{
    float n = 0.0;
    n += smoothNoise(p);
    n += smoothNoise(p * 2.0) / 2.0;
    n += smoothNoise(p * 4.0) / 4.0;
    n += smoothNoise(p * 8.0) / 8.0;
    n += smoothNoise(p * 16.0) / 16.0;
    n /= 1.0 + 1.0 / 2.0 + 1.0 / 4.0 + 1.0 / 8.0 + 1.0 / 16.0;
    return n;
}

float3 GasImage(float2 uv)
{
    float2 nuv = float2(uv.x, uv.y - timers.x / 4.0);
    uv *= float2(1.0, -1.0);

    float x = fractalNoise(nuv * 6.0);

    // РџР»Р°РІРЅС‹Р№ РїРµСЂРµС…РѕРґ РѕС‚ С€СѓРјР° Рє РїСЂРѕР·СЂР°С‡РЅРѕРјСѓ С†РІРµС‚Сѓ, РЅР°С‡РёРЅР°СЏ СЃ СЃРµСЂРµРґРёРЅС‹ СЌРєСЂР°РЅР°
    float transition = smoothstep(0.35, 0.0, abs(uv.y + 0.25));
    float3 noiseColor = float3(x, x, x) * buzz_effect.xyz;

    // РЈР±РёСЂР°РµРј textureColor, РЅРѕ РѕСЃС‚Р°РІР»СЏРµРј transition
    float3 final = noiseColor * transition;

    return final * buzz_effect.w;
}

float bubbles(float2 uv, float size, float speed, float timeOfst, float blur, float time)
{
    float2 ruv = mul(uv, size) + 0.05;
    float2 id = ceil(ruv) + speed;

    float t = (time + timeOfst) * speed;

    ruv.y -= t * (random(id.xx) * 0.5 + 0.5) * 0.1;
    float2 guv = frac(ruv) - 0.5;

    ruv = ceil(ruv);
    float g = length(guv);

    float v = random(ruv) * 0.5;
    v *= step(v, clamp(FORCE, 0.1, 0.3));

    float m = smoothstep(v, v - blur, g);

    v *= 0.85;
    m -= smoothstep(v, v - 0.1, g);

    g = length(guv - float2(v * 0.35, v * 0.35));
    float hlSize = v * 0.75;
    m += smoothstep(hlSize, 0.0, g) * 0.75;

    return m;
}

float3 BuzzEffect(float2 uv)
{
    uv = (uv - 0.5 * screen_res.xy) / screen_res.y;
    uv.y = 1.0 - uv.y;

    float m = 0.0;

    float sizeFactor = screen_res.y / 3.0;

    float fstep = 0.1 / AMOUNT;
    for (float i = -1.0; i <= 0.0; i += fstep)
    {
        float2 iuv = uv + float2(cos(uv.y * 2.0 + i * 20.0 + timers.x * 0.5) * 0.1, 0.0);
        float size = (i * 0.15 + 0.2) * sizeFactor + 10.0;
        float bubble = bubbles(iuv + float2(i * 0.1, 0.0), size, INIT_SPEED + i * 5.0, i * 10.0, 0.3 + i * 0.25, timers.x) * abs(i);

        // Fade out bubbles as they reach the center vertically
        float verticalFade = smoothstep(0.45, 0.0, uv.y - 0.15);
        float horizontalFade = smoothstep(0.95, 0.0, abs(uv.x));
        float verticalFade2 = smoothstep(0.75, 0.15, uv.y - 0.25);
        float horizontalFade2 = smoothstep(0.8, 1.25, abs(uv.x));

        m += bubble * verticalFade * horizontalFade * buzz_effect.w;
        m += bubble * verticalFade2 * horizontalFade2 * buzz_effect.w;
    }

    // Define a color palette for the bubbles
    float3 bubbleColor = buzz_effect.xyz;
    float3 gasimage = GasImage(uv);

    return mul(bubbleColor, m * 2.0) + gasimage;
}

float3 LightEffect(float2 uv)
{
    float2 adjustedUV = (uv - 0.5) * 3.5;
    float timeFactor = timers.x * 0.025;
    float3 outputColor = float3(0.0, 0.0, 0.0);
    float x;
    float centerRadius = 1.4; // Радиус, внутри которого эффект плавно обрезается
    float transitionWidth = 1.1; // Ширина переходной зоны

    // Проверка расстояния от центра экрана
    float distanceFromCenter = length(uv - float2(0.5, 0.5));
    float fadeFactor = smoothstep(centerRadius - transitionWidth, centerRadius, distanceFromCenter);

    for (float waveIndex = 0.0; waveIndex < 15.0; waveIndex += 1.0)
    {
        float2 waveVector = float2(cos(x = waveIndex * 15. - timeFactor), sin(x));
        float wave = sin(waveIndex * lerp(0.05, 0.5, sin(timeFactor) * 0.5) - timeFactor);
        float distance = length(adjustedUV - wave * waveVector);
        float3 color;
        for (int i = 0; i < 3; i++)
        {
            float z = waveIndex * 0.000009;
            float l = distance;
            float2 uv = adjustedUV;
            uv += waveVector / l * (sin(z) + 5.0) * abs(sin(l * 1.1 - z - z));
            color[i] = 0.0013 / length(mod(uv + float2(0.003 * float(i - 1), 0.003 * float(i - 1)), 1.1) - 0.5);
        }

        // Particle Color
        color *= float3(0.19, 0.19, 2.0);
        outputColor += float3(color / distance);
    }

    // Применяем плавное обрезание
    outputColor.rgb *= fadeFactor;

    return outputColor.rgb * 3.0;
}

float2 voronoiPointFromRoot(float2 root, float deg)
{
    float2 points = hash2_2(root) - 0.5;
    float s = sin(deg);
    float c = cos(deg);
    points = mul(mul(float2x2(c, -s, s, c), points), 0.66);
    points += root + 0.5;
    return points;
}

float degFromRootUV(float2 uv) { return timers.x * ANIMATION_SPEED * (hash1_2(uv) - 0.5) * 2.0; }

float3 fireParticles(float2 uv, float2 originalUV)
{
    float3 particles = float3(0.0, 0.0, 0.0);
    float2 rootUV = floor(uv);
    float deg = degFromRootUV(rootUV);
    float2 pointUV = voronoiPointFromRoot(rootUV, deg);
    float dist = 2.0;
    float distBloom = 0.0;

    float2 tempUV = uv + (noise2_2(uv * 2.0) - 0.5) * 0.1;
    tempUV += -(noise2_2(uv * 3.0 + timers.x) - 0.5) * 0.07;

    dist = length(tempUV - pointUV);
    distBloom = length(tempUV - pointUV);

    particles += (1.0 - smoothstep(PARTICLE_SIZE * 0.6, PARTICLE_SIZE * 3.0, dist)) * SPARK_COLOR;
    particles += pow((1.0 - smoothstep(0.0, PARTICLE_SIZE * 6.0, distBloom)) * 1.0, 3.0) * SPARK_COLOR;

    return particles;
}

float3 layeredParticles(float2 uv, float sizeMod, float alphaMod, int layers)
{
    float3 particles = float3(0.0, 0.0, 0.0);
    float size = 1.0;
    float alpha = 1.0;
    float2 offset = float2(0.0, 0.0);
    float2 noiseOffset;
    float2 bokehUV;

    for (int i = 0; i < layers; i++)
    {
        noiseOffset = (noise2_2(uv * size * 2.0 + 0.5) - 0.5) * 0.15;
        bokehUV = (uv * size + timers.x * MOVEMENT_DIRECTION * MOVEMENT_SPEED) + offset + noiseOffset;
        particles += fireParticles(bokehUV, uv) * alpha;
        offset += hash2_2(float2(alpha, alpha)) * 10.0;
        alpha *= alphaMod;
        size *= sizeMod;
    }

    return particles;
}

float3 BurnEffect(float2 uv)
{
    float verticalFade = smoothstep(0.0, 0.95, uv.y);

    uv *= 1.8;

    float3 particles = layeredParticles(uv, 1.0, 0.9, 7);
    float3 col = particles * verticalFade * burn_effect.w;
    col = smoothstep(0.1, 1.0, col);

    return col;
}