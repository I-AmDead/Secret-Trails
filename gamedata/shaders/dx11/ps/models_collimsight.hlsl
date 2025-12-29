#include "common\common.h"

uniform float4 m_hud_params;
uniform float4 m_affects;

struct v2p
{
    float2 tc0 : TEXCOORD0; // base
    float4 c0 : COLOR0; // sun
};

float4 main(v2p I) : SV_Target
{
    float4 t_base = s_base.Sample(smp_base, I.tc0);

    // ??????????? ?????? ??? ???????
    float mig = 1.0f - (m_affects.x * 2.f);
    return float4(t_base.r, t_base.g, t_base.b, random(timers.xz) > mig ? 0.f : t_base.a * m_hud_params.x);
}
