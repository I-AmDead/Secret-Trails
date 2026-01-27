#include "common\common.h"

#if defined(SM_4_1) || defined(SM_5)
#define SMAA_HLSL_4_1
#else
#define SMAA_HLSL_4
#endif

#define SMAA_RT_METRICS screen_res.zwxy

#define SMAA_PRESET_ULTRA
#define EDGE_DETECT_COLOR

#include "common\smaa.h"

float4 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    // RainbowZerg: offset calculation can be moved to VS or CPU...
    float4 offset[3];
    offset[0] = mad(SMAA_RT_METRICS.xyxy, float4(-1.0f, 0.0f, 0.0f, -1.0f), Tex0.xyxy);
    offset[1] = mad(SMAA_RT_METRICS.xyxy, float4(1.0f, 0.0f, 0.0f, 1.0f), Tex0.xyxy);
    offset[2] = mad(SMAA_RT_METRICS.xyxy, float4(-2.0f, 0.0f, 0.0f, -2.0f), Tex0.xyxy);

#if defined(EDGE_DETECT_COLOR)
    return float4(SMAAColorEdgeDetectionPS(Tex0, offset, s_image), 0.0f, 0.0f);
#else
    return float4(SMAALumaEdgeDetectionPS(Tex0, offset, s_image), 0.0f, 0.0f);
#endif
}
