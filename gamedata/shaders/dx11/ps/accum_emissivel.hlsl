#include "common\common.h"

uniform float4 m_affects;

float4 main(p_flat I) : SV_Target
{
    // diffuse
    float3 D = s_base.Sample(smp_base, I.tcdh); // IN:  rgb.a
    D = SRGBToLinear(D);

    float brightness = 1.0 - m_affects.x - m_affects.x;
    float4 color = float4(D.rgb, 1.0);

    return color * brightness;
}