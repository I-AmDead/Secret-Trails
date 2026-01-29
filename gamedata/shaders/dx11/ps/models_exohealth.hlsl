#include "common\common.h"

uniform float4 m_affects;

float4 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    float problems = cos((frac(timers.z * 4) - 0.5) * 3.1416) * 2 - 0.8;
    float AMPL = 0.3;
    Tex0.y -= (m_affects.x > 0.15 && Tex0.x > problems - AMPL && Tex0.x < problems + AMPL) ?
        cos(4.71 * (Tex0.x - problems) / AMPL) * sin(frac(timers.z) * 6.2831 * 90) * (m_affects.x / 10) * (AMPL - abs(Tex0.x - problems)) / AMPL :
        0;

    float4 t_base = s_base.Sample(smp_base, Tex0);

    float tmp = 1 - m_actor_params.y;
    tmp = clamp(tmp, 0, 0.5);
    t_base.r += tmp * t_base.a;

    tmp = 0.5 - abs(m_actor_params.y - 0.5);
    tmp = clamp(tmp, 0, 0.5);
    t_base.g += tmp * t_base.a;

    float noise = get_noise(Tex0 * timers.z) * m_affects.x * 2;
    t_base.r += noise;
    t_base.g += noise;
    t_base.b += noise;

    return float4(t_base.r, t_base.g, t_base.b, 1);
}
