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

#define OFFSET -0.003
#define PARALLAX 100.0
#define SCALE 9.0

uniform float4 m_affects;
uniform float4 mark_number;
uniform float4 mark_color;
uniform float4 m_hud_params;

struct vf
{
    float4 hpos : SV_Position;
    float2 tc0 : TEXCOORD0;
    float3 P : TEXCOORD1;
    float3 T : TEXCOORD3;
    float3 B : TEXCOORD4;
    float3 N : TEXCOORD5;
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

float4 main(vf I) : SV_Target
{
    float3x3 TBN = float3x3(I.T + OFFSET, I.B + OFFSET, I.N);
    float3 V_tangent = normalize(float3(dot(-I.P, TBN[0]), dot(-I.P, TBN[1]), dot(-I.P, TBN[2])));
    float2 parallax_tc = I.tc0 - V_tangent.xy * PARALLAX;

    parallax_tc = (parallax_tc + (SCALE - 1) / 2) / SCALE;

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
