#include "common\common.h"

Texture2D s_distort;

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
float4 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    float2 distort = s_distort.Sample(smp_rtlinear, I.Tex0);
    float2 offset = (distort.xy - .5h) * def_distort;
    float3 image = s_base.Sample(smp_rtlinear, I.Tex0 + offset);

    return float4(image, 1);
}
