#include "common\common.h"

float3 main(float2 tc : TEXCOORD0) : SV_Target
{
    return s_generic.Sample(smp_nofilter, tc);
}