#include "common\common.h"

uniform float4 m_affects;

float4 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    float4 t_base = s_base.Sample(smp_base, Tex0);

    t_base.a = (Tex0.x < m_actor_params.z) ? 1 : 0;
    t_base.r += (0.5 < m_actor_params.z) ? 0 : 0.5;
    t_base.g -= (0.25 < m_actor_params.z) ? 0 : 0.5;

    t_base.rgb = (m_affects.x > 0.41) ? 0 : t_base.rgb;

    return float4(t_base.rgb, t_base.a);
}
