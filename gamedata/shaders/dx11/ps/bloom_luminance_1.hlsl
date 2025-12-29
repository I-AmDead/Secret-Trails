#include "common\common.h"

#define LUMINANCE_BASE 0.0001h

float luminance(float2 tc)
{
    float3 source = s_image.Sample(smp_rtlinear, tc);
    return dot(source, LUMINANCE_VECTOR * def_hdr);
}

float4 main(p_build I) : SV_Target { return float4(luminance(I.Tex0), luminance(I.Tex1), luminance(I.Tex2), luminance(I.Tex3)); }
