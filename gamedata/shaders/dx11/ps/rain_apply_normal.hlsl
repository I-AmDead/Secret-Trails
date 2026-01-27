#include "common\common.h"

Texture2D s_patched_normal;

float4 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    float3 _N = s_patched_normal.Sample(smp_nofilter, Tex0);
    return float4(gbuf_pack_normal(_N), 0, 0);
}
