#include "common\common.h"

Texture2D s_vollight1;
Texture2D s_vollight2;

float4 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    float4 color = s_vollight1.SampleLevel(smp_linear, Tex0.xy, 0);
    color += s_vollight2.SampleLevel(smp_linear, Tex0.xy, 0);

    // Read Depth
    float depth = gbuffer_depth(Tex0.xy);

    // Discard Sky.
    color *= depth < 0.001 ? 1.0f : saturate(depth * 1.5f);

    return color;
}