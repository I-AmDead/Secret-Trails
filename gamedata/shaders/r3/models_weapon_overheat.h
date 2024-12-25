uniform float4 L_glowing;

float ra(float2 n) { return frac(sin(dot(n.xy, float2(12.9898, 78.233))) * 43758.5453); }

float4 overheat(float2 uv)
{
    // Normalized pixel coordinates (from -1 to 1)
    // float2 uv = fragCoord / iResolution.xy * 2.0 - 1.0;
    // uv.y *= iResolution.y / iResolution.x;

    // Colours warm as pupils dilate
    float3 col = lerp(float3(1.0, 0.50, 0.0), float3(1.0, 0.40, 0.0) * 0.4,
                      // min(timers.z*0.1, 1.0)
                      smoothstep(0.0, 10.0, timers.z));

    // Brighter in the middle
    float r = length(uv);
    col -= r * r * 0.25;

    col = clamp(col, 0.0, 1.0);
    float heartbeat = fmod(timers.z * 1.3, 1.0) * smoothstep(10.0, 20.0, timers.z);
    col -= heartbeat * 0.01;
    // clamp((timers.z - 10.0) * 0.02, 0.0, 0.02);

    float raa = ra(uv + frac(timers.z));
    col *= float3(raa, raa, raa) * 0.05 + 0.95;

    float plasmasfade = smoothstep(10.0, 30.0, timers.z) * heartbeat;

    float t = timers.z * 0.55;
    float2 p = float2(sin(uv.x + t + sin(uv.y + t)), sin(uv.y + t + sin(uv.x + t)));
    p = float2(sin(p.x + t + sin(uv.y + t)), sin(p.y + t + sin(uv.x + t)));

    float x = sin(p.x);
    x = smoothstep(0.0, 0.1, abs(x)) * 0.125;
    // col.r += x;
    p *= 40.25;
    t *= 0.34;
    p = float2(sin(p.y + t * 0.55 + sin(uv.x + t * 0.34)), sin(p.x + t * 0.34 + sin(uv.y + t * 0.55)));

    x = sin(p.x) + sin(p.y);
    x = (1.0 - smoothstep(0.0, 0.201, abs(x))) * 0.0125 * (sin(timers.z * 0.55 * max(p.x, p.y)) * 0.5 + 0.5) * plasmasfade;
    col.r += x;

    t *= 0.55;
    p = float2(sin(uv.x + t / 0.55 + sin(uv.y + t / 0.34)), sin(uv.y + t / 0.34 + sin(uv.x + t / 0.55)));
    p = float2(sin(p.x + t + sin(uv.y + t)), sin(p.y + t + sin(uv.x + t)));

    p *= 37.25;
    // p *= 0.753958;
    p = float2(sin(p.y + t * 0.34 + sin(uv.y + t * 0.55)), sin(p.x + t * 0.55 + sin(uv.x + t * 0.34)));

    x = sin(p.x) + sin(p.y);
    x = smoothstep(0.0, 0.201, abs(x)) * 0.0125 * (sin(timers.z * 0.34 * max(p.y, p.x)) * 0.5 + 0.5) * plasmasfade;
    col.g -= x;

    return float4(col, 1.0);
}

// Created by Alex Kluchikov

float2 rot(float2 p, float a)
{
    float c = cos(a * 15.83);
    float s = sin(a * 15.83);
    p = mul(p, float2x2(c, -s, s, c));
    return p;
}

float4 overheat1(float2 uv)
{
    uv = float2(0.125, 0.75) + (uv - float2(0.125, 0.75)) * 0.015;
    float T = timers.z;

    float3 c = normalize(
        0.75 -
        0.25 * float3(sin(length(uv - float2(0.1, 0)) * 132.0 + T * 3.3), sin(length(uv - float2(0.9, 0)) * 136.0 - T * 2.5), sin(length(uv - float2(0.5, 1)) * 129.0 + T * 4.1)));

    float3 c0 = float3(0, 0, 0);
    float w0 = 0.0;
    float N = 80.0;
    float wb = 0.012;
    for (float i = 0.0; i < N; i++)
    {
        float wt = (i * i / N / N - 0.2) * 0.3;
        float wp = 0.5 + (i + 1.0) * (i + 1.5) * 0.001;
        c.zx = rot(c.zx, 1.6 + T * 0.65 * wt + (uv.x + 0.7) * 23.0 * wp);
        c.xy = rot(c.xy, c.z * c.x * wb + 1.7 + T * wt + (uv.y + 1.1) * 15.0 * wp);
        float w = (1.5 - i / N);
        c0 += c * sqrt(w);
        w0 += sqrt(w);
    }
    c0 = c0 / w0 * 3.0 + 0.5;

    return float4(sqrt(c0.r) * 1.2, c0.r * c0.r * 0.9, c0.r * c0.r * c0.r * 0.4, 1.0);
}