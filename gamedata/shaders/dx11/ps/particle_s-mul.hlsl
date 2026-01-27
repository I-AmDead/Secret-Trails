#include "common\common.h"

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
float4 main(p_TL I) : SV_Target
{
    float4 c = I.Color * s_base.Sample(smp_base, I.Tex0);
    return float4(c.xyz, 1);
}
