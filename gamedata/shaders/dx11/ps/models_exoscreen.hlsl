#include "common\common.h"

uniform float4 m_affects;

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
float4 main(p_TL I) : SV_Target
{
    float4 t_base = s_base.Sample(smp_base, I.Tex0);

    float noise = get_noise(I.Tex0 * timers.z) * m_affects.x * 2;
    t_base.r += noise;
    t_base.g += noise;
    t_base.b += noise;

    return float4(t_base.r, t_base.g, t_base.b, t_base.a * I.Color.a);
}
