#include "common\common.h"
#include "common\sload.h"
#include "common\screenspace\screenspace_hud_raindrops.h"

float2 rand2(float2 p) { return frac(float2(sin(p.x * 591.32 + p.y * 154.077), cos(p.x * 391.32 + p.y * 49.077))); }

float voronoi(float2 x)
{
    float2 p = floor(x);
    float2 f = frac(x);
    float minDistance = 1.0;

    for (int j = -1; j <= 1; j++)
    {
        for (int i = -1; i <= 1; i++)
        {
            float2 b = float2(i, j);
            float2 rand = .5 + .5 * sin(timers.x * 3.0 + 12.0 * rand2(p + b));
            float2 r = b - f + rand;
            minDistance = min(minDistance, length(r));
        }
    }
    return minDistance;
}

float4 electric_grid(float2 uv)
{
    float val = pow(voronoi(uv * 8.0) * 1.25, 7.0) * 2.0;
    float gridLineThickness = 2.0 / screen_res.y;
    float2 grid = step(fmod(uv, 0.1), float2(gridLineThickness, gridLineThickness));

    return float4(0.0, 0.0, val * (grid.x + grid.y), 1.0);
}

float3 MIX(float3 x, float3 y) { return abs(x - y); }

float CV(float3 c, float2 uv)
{
    float size = 640.0 * 0.003;
    float l = clamp(size * (length(c.xy - uv) - c.z), 0.0, 1.0);
    return 1.0 - l;
}

float4 electric_glitch(float2 uv)
{
    float4 color = float4(0, 0, 0, 1);
    for (int i = 0; i < 20; i += 1)
    {
        float3 c = float3(1.0, 1.0, 1.0);
        color.rgb = MIX(color.rgb, c * CV(float3((1.0 + sin(timers.x * 0.52 + (i - 1400.0) * 1.35)) * 0.5, (1.0 + sin(timers.x * 0.73 + (i - 1200.0) * 1.61)) * 0.5, 0.0), uv));
    }
    color.rgb = (1.0 - color.rgb) * 1.01;
    color.rgb = pow(color.rgb, float3(42.0, 32.0, 12.0));

    return color;
}

// Value Noise by Inigo Quilez - iq/2013
// https://www.shadertoy.com/view/lsf3WH
float noise2(float2 st)
{
    float2 i = floor(st);
    float2 f = frac(st);
    float2 u = f * f * (3.0 - 2.0 * f);

    return lerp(lerp(dot(rand2(i + float2(0.0, 0.0)), f - float2(0.0, 0.0)), dot(rand2(i + float2(1.0, 0.0)), f - float2(1.0, 0.0)), u.x),
                lerp(dot(rand2(i + float2(0.0, 1.0)), f - float2(0.0, 1.0)), dot(rand2(i + float2(1.0, 1.0)), f - float2(1.0, 1.0)), u.x), u.y);
}

// Value Noise by Inigo Quilez - iq/2013
// https://www.shadertoy.com/view/lsf3WH
float4 slime(float2 uv)
{
    float3 orange = float3(0.0, 0.45, 0.0);
    float3 yellow = float3(0.0, 1.0, 0.0);

    uv *= 2.0;

    uv.y += cos(timers.x / 10.0) * .1 + timers.x / 10.0;
    uv.x *= sin(timers.x * 1.0 + uv.y * 4.0) * .1 + .8;
    uv += noise2(uv * 6.25 + timers.x / 5.0);

    float col = smoothstep(0.01, 0.2, noise2(uv * 3.0)) + smoothstep(0.01, 0.2, noise2(uv * 6.0 + 0.5)) + smoothstep(0.01, 0.3, noise2(uv * 7.0 + 0.2));

    orange.rgb += .3 * sin(uv.y * 4.0 + timers.x / 1.0) * sin(uv.x * 5.0 + timers.x / 1.0);

    float color = smoothstep(0.0, 1.0, col);
    return float4(lerp(yellow, orange, float3(color, color, color)), 1.0);
}

float3 magmaFunc(float3 color, float2 uv, float detail, float power, float colorMul, float glowRate, bool animate, float noiseAmount)
{
    float3 rockColor = float3(0.0, 0.0, 0.0);
    float minDistance = 1.0;
    uv *= detail;

    float2 cell = floor(uv);
    float2 fractal = frac(uv);

    for (int i = -1; i <= 1; i++)
    {
        for (int j = -1; j <= 1; j++)
        {
            float2 cellDir = float2(float(i), float(j));
            float2 randPoint = rand2(cell + cellDir);
            randPoint += noise2(uv) * noiseAmount;
            randPoint = animate ? 0.5 + 0.5 * sin(timers.x * .35 + 6.2831 * randPoint) : randPoint;
            minDistance = min(minDistance, length(cellDir + randPoint - fractal));
        }
    }

    float powAdd = sin(uv.x * 2. + timers.x * glowRate) + sin(uv.y * 2. + timers.x * glowRate);
    float3 outColor = color * pow(minDistance, power + powAdd * .95) * colorMul;
    outColor = lerp(rockColor, outColor, minDistance);
    return outColor;
}

float4 slime2(float2 uv)
{
    uv.x += timers.x * 0.1;
    uv.y += timers.x * 0.1;
    float4 fragColor = float4(0.0, 0.0, 0.0, 1.0);
    fragColor.rgb += magmaFunc(float3(0.0, 1.5, 0.45), uv, 3., 2.5, 1.15, 1.5, false, 1.5);
    fragColor.rgb += magmaFunc(float3(0.0, 1.5, 0.4), uv, 6., 3., .4, 1., false, 0.);
    fragColor.rgb += magmaFunc(float3(0.0, 1.5, 0.4), uv, 8., 4., .2, 1.9, true, 0.5);
    return fragColor;
}

f_deffer main(p_bumped I)
{
    f_deffer O;

    surface_bumped S = sload(I);

#if WPN_ANOMALY_EFFECT == 1
    S.base.rgb += electric_grid(I.tcdh);
    S.base.rgb += electric_glitch(I.tcdh);
#else
    S.base.rgb += slime2(I.tcdh);
#endif

#ifdef USE_AREF
    hashed_alpha_test(I.tcdh.xy, S.base.a);
#endif

    // HUD Rain drops - SSS Update 17
    // https://www.moddb.com/mods/stalker-anomaly/addons/screen-space-shaders/

    float4 drops = 0; // xy = Normal | z = Overall str | w = reflection str

    if (ssfx_hud_drops_1.y > 0)
    {
        // Calc droplets
        drops.xyz = ssfx_hud_raindrops(s_hud_rain, I.RDrops.xyz, 1.0f);

        // Only apply to facing up surfaces [ World Y+ ]
        drops.xyz *= saturate(I.RDrops.w);

        // Intensity from script ( Cover + Rain intensity )
        drops.xyz *= ssfx_hud_drops_1.y;

        // Refraction
        I.tcdh.xy = I.tcdh.xy + drops.xy * ssfx_hud_drops_1.w;

        // Reflection adjustments
        drops.w = ssfx_hud_drops_1.z * dot(L_hemi_color, SSFX_HUD_LIGHTVECTOR);
        drops.w = max(drops.w, 3.0f);
    }

    // Add sampled normal and droplets
    float3 Ne = mul(float3x3(I.M1, I.M2, I.M3), S.normal + float3(drops.xy * drops.w, 1.0f));
    Ne = normalize(Ne);

    float ms = xmaterial;

    S.gloss += ssfx_gloss.w;
    S.gloss += (ssfx_hud_drops_1.y * ssfx_hud_drops_2.z) + drops.z * ssfx_hud_drops_2.w;

#ifdef USE_LM_HEMI
    float h = s_hemi.Sample(smp_rtlinear, I.lmh).a;
#else
    float h = I.position.w;
#endif

    O = pack_gbuffer(float4(Ne, h), float4(I.position.xyz + Ne * S.height * def_virtualh, ms), float4(S.base.rgb, S.gloss));

    O.Velocity = get_motion_vector(I.hpos_curr, I.hpos_old);

    return O;
}
