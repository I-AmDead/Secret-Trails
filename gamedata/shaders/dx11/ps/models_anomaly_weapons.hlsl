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

float3 slime(float2 uv)
{
    uv.x += timers.x * 0.1;
    uv.y += timers.x * 0.1;
    float3 fragColor = float3(0.0, 0.0, 0.0);
    fragColor += magmaFunc(float3(0.0, 1.5, 0.4), uv, 8.0, 4.0, 0.2, 1.9, true, 0.5);
    return fragColor;
}

f_deffer main(p_bumped I)
{
    f_deffer O;

    surface_bumped S = sload(I);

#if WPN_ANOMALY_EFFECT == 1
    S.base.rgb += electric_grid(I.tcdh);
    S.base.rgb += electric_grid(I.tcdh * 5.f);
    S.base.rgb += electric_grid(I.tcdh * 10.f);
#else
    S.base.rgb += slime(I.tcdh * 2.f);
    S.base.rgb += slime(I.tcdh * 5.f);
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
