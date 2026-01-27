#include "common\common.h"

// Pixel
float4 main(p_build I) : SV_Target
{
    float4 result = s_image.Sample(smp_rtlinear, I.Tex0);
    result += s_image.Sample(smp_rtlinear, I.Tex1);
    result += s_image.Sample(smp_rtlinear, I.Tex2);
    result += s_image.Sample(smp_rtlinear, I.Tex3);
    result *= 0.5;

    return result;
}
