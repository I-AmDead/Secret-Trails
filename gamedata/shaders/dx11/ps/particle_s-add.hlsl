#include "common\common.h"

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
float4 main(p_TL I) : SV_Target
{
    float4 c = I.Color * s_base.Sample(smp_base, I.Tex0);
    float3 r = float3(1, 1, 1) - c.xyz - c.xyz * c.xyz;
    return float4(r, 1);
}
