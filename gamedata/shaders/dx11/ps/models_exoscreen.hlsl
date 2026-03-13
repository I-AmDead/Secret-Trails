#include "common\common.h"

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
float4 main(p_TL I) : SV_Target
{
    float4 t_base = s_base.Sample(smp_base, I.Tex0);

    return float4(t_base.rgb, t_base.a * I.Color.a);
}
