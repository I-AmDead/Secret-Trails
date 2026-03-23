#include "common\common.h"

float4 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    return s_base.Sample(smp_base, Tex0);
}
