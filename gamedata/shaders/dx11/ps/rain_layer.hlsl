#include "common\common.h"
#include "common\lmodel.h"
#include "common\shadow.h"

Texture2D s_water;

float4 main(v2p_TLD2 I) : SV_Target
{
    float3 view_space = gbuffer_view_space(I.Tex0, I.HPos);
    float4 _P = float4(view_space, 1.0);

    float4 PS = mul(m_shadow, _P);

    float s = shadow(PS);

    float2 tc1 = mul(m_sunmask, _P);
    tc1 /= 2;
    tc1 = frac(tc1);

    float4 water = s_water.SampleLevel(smp_linear, tc1, 0);
    water.xyz = (water.xzy - 0.5) * 2;
    water.xyz = mul(m_V, water.xyz);
    water *= s;

    return float4(water.xyz, s);
}
