#include "common\common.h"

Texture2D s_distort;

float4 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    float4 distort = s_distort.SampleLevel(smp_nofilter, Tex0, 0);
    float2 offset = distort.xy - (127.0f / 255.0f);
    float2 center = Tex0 + offset * def_distort;

    float depth = gbuffer_depth(Tex0);
    float depth_x = gbuffer_depth(center);

    center = depth_x < depth ? Tex0 : center;

    return s_image.SampleLevel(smp_nofilter, center, 0);
}
