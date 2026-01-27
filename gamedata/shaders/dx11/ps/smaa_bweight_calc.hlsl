#include "common\common.h"

#if defined(SM_4_1) || defined(SM_5)
#define SMAA_HLSL_4_1
#else
#define SMAA_HLSL_4
#endif

#define SMAA_RT_METRICS screen_res.zwxy

#define SMAA_PRESET_ULTRA

#include "common\smaa.h"

Texture2D s_edgetex;
Texture2D s_areatex;
Texture2D s_searchtex;

float4 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    // RainbowZerg: offset calculation can be moved to VS or CPU...
    float2 pixcoord = Tex0 * SMAA_RT_METRICS.zw;
    float4 offset[3];

    // We will use these offsets for the searches later on (see @PSEUDO_GATHER4):
    offset[0] = mad(SMAA_RT_METRICS.xyxy, float4(-0.25f, -0.125f, 1.25f, -0.125f), Tex0.xyxy);
    offset[1] = mad(SMAA_RT_METRICS.xyxy, float4(-0.125f, -0.25f, -0.125f, 1.25f), Tex0.xyxy);

    // And these for the searches, they indicate the ends of the loops:
    offset[2] = mad(SMAA_RT_METRICS.xxyy, float4(-2.0f, 2.0f, -2.0f, 2.0f) * float(SMAA_MAX_SEARCH_STEPS), float4(offset[0].xz, offset[1].yw));

    return SMAABlendingWeightCalculationPS(Tex0, pixcoord, offset, s_edgetex, s_areatex, s_searchtex, 0.0f);
};
