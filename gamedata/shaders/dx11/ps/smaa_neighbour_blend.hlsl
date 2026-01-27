#include "common\common.h"

#if defined(SM_4_1) || defined(SM_5)
#define SMAA_HLSL_4_1
#else
#define SMAA_HLSL_4
#endif

#define SMAA_RT_METRICS screen_res.zwxy

#define SMAA_PRESET_ULTRA

#include "common\smaa.h"

Texture2D s_blendtex;

float4 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    // RainbowZerg: offset calculation can be moved to VS or CPU...
    float4 offset = mad(SMAA_RT_METRICS.xyxy, float4(1.0f, 0.0f, 0.0f, 1.0f), Tex0.xyxy);
    return SMAANeighborhoodBlendingPS(Tex0, offset, s_image, s_blendtex);
};
