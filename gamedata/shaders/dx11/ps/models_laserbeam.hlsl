#include "common\common.h"

uniform float4 laser_params;
uniform float4 m_affects;

float4 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    float4 t_base = s_base.Sample(smp_base, Tex0);
    t_base.rgb = t_base.rgb * 0.9;

    float mig = 1.0f - (m_affects.x * 2.f);

    float noise = get_noise(Tex0 * timers.z) * 0.25 * 0.25 * 15;
    t_base.r += noise;
    t_base.g += noise;
    t_base.b += noise;

    return float4(t_base.r, t_base.g, t_base.b, laser_params.x > 0.f ? (random(timers.xz) > mig ? 0.f : t_base.a) : 0.f);
}
