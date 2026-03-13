#include "common\common.h"

float3 main(float4 tc : TEXCOORD0) : SV_Target
{
    tc.xy /= tc.w;
    return s_generic.Sample(smp_nofilter, tc);
}