#include "common\common.h"

#define	CLIP_DISTANCE 1.5f

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
float4 main(v2p_TLD4 I) : SV_Target
{
    float4 t_base = s_base.Sample(smp_base, I.Tex0) * I.Color;

    float2 tcProj = I.Tex1.xy / I.Tex1.w;
    float spaceDepth = gbuffer_depth(tcProj);

    if (spaceDepth < 0.01f)
        spaceDepth = 100000.0f; //  filter for skybox

    // clip pixels on hud
    clip(spaceDepth - CLIP_DISTANCE);

    return t_base;
}
