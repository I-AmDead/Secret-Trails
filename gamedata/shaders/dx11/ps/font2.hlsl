#include "common\common.h"

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
float4 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    float4 r = s_base.Sample(smp_base, Tex0);

    r.w = 1 - r.w;

    return r;
}