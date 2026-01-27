#include "common\common.h"

Texture2D s_clouds0 : register(t0);
Texture2D s_clouds1 : register(t1);

// Pixel
float4 main(v2p_TLD2 I) : SV_Target
{
    float4 s0 = s_clouds0.Sample(smp_base, I.Tex0);
    float4 s1 = s_clouds1.Sample(smp_base, I.Tex1);
    float4 mix = I.Color * (s0 + s1);

    return mix;
}
