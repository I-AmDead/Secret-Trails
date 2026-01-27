#include "common\common.h"
#include "common\screenspace\screenspace_dof.h"

float4 main(float2 Tex0 : TEXCOORD0) : SV_TARGET
{
    float depth = gbuffer_depth(Tex0);
    float3 img = s_image.Sample(smp_nofilter, Tex0).rgb;

    return float4(SSFX_DOF(Tex0, depth, img), 1.0);
}
