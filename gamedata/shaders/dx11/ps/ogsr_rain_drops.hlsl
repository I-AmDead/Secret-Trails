#include "common\common.h"
#include "common\ogsr_gasmask_common.h"

// ???????????? ??????: https://github.com/ya7gisa0/Unity-Raindrops
// ??? OGSR Engine ?????????? KRodin (c) 2019
// Cleaned up code by LVutner

// x - ???? ??????? ?? 0 ?? 1. ?????????????? ? ??????. ??? ??????? ????? - ??? ??????? ??????. ??????????? ??????? ??????????/?????????? ???? ??????? ??? ?????/?????? ?? ?????????
// ? ?????. y - ????????????? ???????. ??? ?????? - ??? ????? "???? ??????????" ????? ?????. ???????????? ?????????? ???????? r2_rain_drops_intensity z - ???????? ???????? ??????.
// ??? ?????? - ??? ???????. ???????????? ?????????? ???????? r2_rain_drops_speed
uniform float4 rain_drops_params;

float2 mod289(float2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
float3 mod289(float3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
float4 mod289(float4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
float3 permute(float3 x) { return mod289(((x * 34.0) + 1.0) * x); }
float4 permute(float4 x) { return mod289(((x * 34.0) + 1.0) * x); }

// Raindrops settings
#define GM_DROPS_TURBSIZE 15.f // Turbulence power
#define GM_DROPS_TURBSHIFT float4(0.35, 1, 0, 1) // Turbulence offset
#define GM_DROPS_TURBTIME sin(0.1 / 3.f)
#define GM_DROPS_TURBCOF 0.33 // Turbulence intensity

Texture2D<float4> s_mask_wipe;
Texture2D s_noise; // Fixed noise texture

float snoise_2D(float2 uv)
{
    float t_noise = s_noise.Sample(smp_linear, uv);
    return float(t_noise);
}

float2 l_jh2(float2 f, float4 s, float l)
{
    float2 x = s.xy, V = s.zw;
    float y = snoise_2D(f * float2(GM_DROPS_TURBSIZE, GM_DROPS_TURBSIZE)) * 0.5;
    float4 r = float4(y, y, y, 1.0);
    r.xy = float2(r.x + r.z / 4.0, r.y + r.x / 2.0);
    r -= 1.5;
    r *= l;
    return saturate(f + (x + V) * r.xy);
}

float3 N13(float p)
{
    // from DAVE HOSKINS
    float3 p3 = frac(float3(p, p, p) * float3(.1031, .11369, .13787));
    p3 += dot(p3, p3.yzx + 19.19);
    return frac(float3((p3.x + p3.y) * p3.z, (p3.x + p3.z) * p3.y, (p3.y + p3.z) * p3.x));
}

float N(float t) { return frac(sin(t * 12345.564) * 7658.76); }

float Saw(float b, float t) { return smoothstep(0., b, t) * smoothstep(1., b, t); }

float2 DropLayer2(float2 uv, float t)
{
    float2 UV = uv;

    uv.y += t * .75;
    float2 a = float2(9., 2.);
    float2 grid = a * 2.;
    float2 id = floor(uv * grid);

    float colShift = N(id.x);
    uv.y += colShift;

    id = floor(uv * grid);
    float3 n = N13(id.x * 35.2 + id.y * 2376.1);
    float2 st = frac(uv * grid) - float2(.5, 0);

    float x = n.x - .5;

    float y = UV.y;
    float wiggle = sin(y + sin(y));
    x += wiggle * (.5 - abs(x)) * (n.z - .5);
    x *= .7;
    float ti = frac(t + n.z);
    y = (Saw(.85, ti) - .5) * .9 + .5;
    float2 p = float2(x, y);

    float d = length((st - p) * a.yx);

    float mainDrop = smoothstep(.5, .0, d);

    float r = sqrt(smoothstep(1., y, st.y));
    float cd = abs(st.x - x);
    float trail = smoothstep(.23 * r, .15 * r * r, cd);
    float trailFront = smoothstep(-.02, .02, st.y - y);
    trail *= trailFront * r * r;

    y = UV.y;
    float trail2 = smoothstep(.2 * r, .0, cd);
    float droplets = max(0., (sin(y * (1. - y) * 120.) - st.y)) * trail2 * trailFront * n.z;
    y = frac(y * 1.) + (st.y - .5);
    float dd = length(st - float2(x, y));
    droplets = smoothstep(.3, 0., dd);
    float m = mainDrop + droplets * r * trailFront;

    return float2(m, trail);
}

float StaticDrops(float2 uv, float t)
{
    uv *= 40.;

    float2 id = floor(uv);
    uv = frac(uv) - .5;
    float3 n = N13(id.x * 107.45 + id.y * 3543.654);
    float2 p = (n.xy - .5) * .7;
    float d = length(uv - p);

    float fade = Saw(.025, frac(t + n.z));
    float c = smoothstep(.2, 0., d) * frac(n.z * 10.) * fade;
    return c;
}

float2 Drops(float2 uv, float t, float l0, float l1, float l2)
{
    uv.y = 1. - uv.y; // KRodin: ?????????????? ????????, ? ?? ????? ?????????? ????? ?????? (??????????? OpenGL ?)
    uv *= 1.5;
    float s = StaticDrops(lerp(uv, l_jh2(uv, GM_DROPS_TURBSHIFT, GM_DROPS_TURBTIME), GM_DROPS_TURBCOF), t) * l0;
    float2 m1 = DropLayer2(lerp(uv, l_jh2(uv, GM_DROPS_TURBSHIFT, GM_DROPS_TURBTIME), GM_DROPS_TURBCOF), t) * l1;
    float2 m2 = DropLayer2(lerp(uv, l_jh2(uv, GM_DROPS_TURBSHIFT, GM_DROPS_TURBTIME), GM_DROPS_TURBCOF) * 1.75, t) * l2;

    float c = s + m1.x + m2.x;
    c = smoothstep(.3, 1., c);

    return float2(c, max(m1.y * l0, m2.y * l1));
}

float4 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    float rainAmount = rain_drops_params.x;
    float2 uv = Tex0;

    float T = rain_drops_params.z * (timers.x + rainAmount * 2.);

    float t = T * .2;

    float staticDrops = smoothstep(-.5, 4., rainAmount) * 8.;
    float layer1 = smoothstep(.25, .75, rainAmount);
    float layer2 = smoothstep(.0, .5, rainAmount);

    float2 c = Drops(uv, t, staticDrops, layer1, layer2);
    float2 e = float2(rain_drops_params.y, 0.);
    float cx = Drops(uv + e, t, staticDrops, layer1, layer2).x;
    float cy = Drops(uv + e.yx, t, staticDrops, layer1, layer2).x;
    float2 n = float2(cx - c.x, cy - c.x); // expensive normals

    // this is just a scrolling texture. 0.18 is an offset to compensate for anim length etc
    float2 uv_restart = uv + float2(raindrop_restart.x == 0.0 ? 0.0 : -0.18, 0.0) + float2(1.0 - raindrop_restart.x, 0.0);
    float4 fetched_tex = s_mask_wipe.SampleLevel(smp_rtlinear, uv_restart, 0);
    fetched_tex.xy = fetched_tex.xy * 2.0 - 1.0;
    fetched_tex.xy *= rainAmount * fetched_tex.z * fetched_tex.w;
    fetched_tex *= 1.0 - smoothstep(0.0, 1.0, uv.x - 0.45);
    n += fetched_tex.xy; // add smudges
    n *= 1.0 - raindrop_restart.x; // falloff allat

    float3 col = s_image.Sample(smp_nofilter, uv + n);

    return float4(col, 1.);
}
