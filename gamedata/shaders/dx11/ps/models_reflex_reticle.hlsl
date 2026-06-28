/*
    =====================================================================
    Addon      : Parallax Reflex Sights
    Link       : https://www.moddb.com/mods/stalker-anomaly/addons/parallax-reflex-sights
    Authors    : LVutner, party_50
    Date       : 06.02.2024
    Last Edit  : 08.10.2025
    =====================================================================
*/

#include "common\common.h"

#define PARALLAX 10.0
#define SCALE 2.0

uniform float4 m_affects;
uniform float4 mark_number;
uniform float4 mark_color;
uniform float3 mark_offset;

struct PSInput
{
    float2 Tex0 : TEXCOORD0;
    float3 T : TANGENT0;
    float3 B : BINORMAL0;
    float3 N : NORMAL0;
    float3 P : POSITION0;
};

int mark_sides()
{
    int sides = 1;
    while (sides * sides < int(mark_number.y))
    {
        sides += 1;
    }

    return sides;
}

float2 mark_adjust(float2 pos)
{
    int sides = mark_sides();

    float d_x = int(mark_number.x) % sides;
    float d_y = int(mark_number.x) / sides;

    float p_x = clamp(d_x + pos.x, d_x, d_x + 1) / sides;
    float p_y = clamp(d_y + pos.y, d_y, d_y + 1) / sides;

    return float2(p_x, p_y);
}

float3x3 cotangent_frame(float3 N, float3 P, float2 uv)
{
    float3 dp1 = ddx(P);
    float3 dp2 = ddy(P);
    float2 duv1 = ddx(uv);
    float2 duv2 = ddy(uv);

    float3 dp2perp = cross(dp2, N);
    float3 dp1perp = cross(N, dp1);
    float3 T = dp2perp * duv1.x + dp1perp * duv2.x;
    float3 B = dp2perp * duv1.y + dp1perp * duv2.y;

    float invmax = rsqrt(max(dot(T, T), dot(B, B)));
    return float3x3(T * invmax, B * invmax, N);
}

float2 project(float2 tc, float2 tangent, float distance, float size)
{
    float2 parallax_tc = tc - tangent * distance;
    parallax_tc.x = (parallax_tc.x + (size - 1) / 2) / size;
    parallax_tc.y = (parallax_tc.y + (size - 1) / 2) / size;
    return parallax_tc + mark_offset.xy;
}

float4 main(PSInput I) : SV_Target
{
    float3x3 TBN = cotangent_frame(I.N, I.P, I.Tex0.xy);
    float3 V_tangent = normalize(float3(dot(-I.P, TBN[0]), dot(-I.P, TBN[1]), dot(-I.P, TBN[2])));

    float2 parallax_tc = project(I.Tex0, V_tangent.xy, PARALLAX, SCALE * mark_offset.z);

    if (mark_number.y > 0)
    {
        parallax_tc = mark_adjust(parallax_tc);
    }

    float4 mark_texture = s_base.Sample(smp_rtlinear, parallax_tc);

    mark_texture.rgb += mark_color.rgb;

    // Glitches when an outlier
    float mig = 1.0f - (m_affects.x * 2.f);

    float4 final = float4(mark_texture.rgb, random(timers.xz) > mig ? 0.f : mark_texture.a);

    return final;
}
