#include "common\common.h"
#include "common\sload.h"

#ifdef USE_AREF
float4 main(float2 Tex0 : TEXCOORD0) : SV_Target
#else
float4 main() : SV_Target
#endif
{
#ifdef USE_AREF
    float4 C = s_base.Sample(smp_linear, Tex0);
    hashed_alpha_test(Tex0.xy, C.a);
    return C;
#else
    return float4(0.f, 0.f, 0.f, 0.f);
#endif
}
