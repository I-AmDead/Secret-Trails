#include "common\common.h"

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
float4 main(v2p_TL_FOG I) : SV_Target
{
    float4 t_base = s_base.Sample(smp_base, I.Tex0);
    float3 final = t_base * I.Color * 2;

    // Fogging
    final = lerp(fog_color, final, I.Fog);

    // out
    return float4(final, t_base.a * I.Fog * I.Fog);
}
