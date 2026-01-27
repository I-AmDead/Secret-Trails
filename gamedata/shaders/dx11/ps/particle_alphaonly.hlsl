#include "common\common.h"

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
float4 main(v2p_TL_FOG I) : SV_Target
{
    float result = I.Color.a * s_base.Sample(smp_base, I.Tex0).a;
    result *= I.Fog * I.Fog;
    return result;
}
