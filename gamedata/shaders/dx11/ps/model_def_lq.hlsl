#include "common\common.h"

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
float4 main(v2p_TL_FOG I) : SV_Target
{
    float4 t_base = s_base.Sample(smp_base, I.Tex0);

    float3 light = I.Color.rgb;
    float3 final = light * t_base * 2;

    // Fogging
    final = lerp(fog_color, final, I.Fog);

    // out
    return float4(final.rgb, I.fog * I.fog * t_base.a);
}
