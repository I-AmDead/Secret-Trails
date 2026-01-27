#include "common\common.h"

uniform float4 m_affects;

float4 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    float4 r = s_base.Sample(smp_base, Tex0);
    float mig = 1.0f - (m_affects.x * 2.f);

    return float4(r.r, r.g, r.b, random(timers.xz) > mig ? 0.f : r.a);
}
