#include "common\common.h"
#include "common\ogsr_gasmask_common.h"
#include "common\screenspace\screenspace_common.h"

/*
    Gasmask blur shader
    Passes blurred result of previous shader (gasmask_drops) to next shader (gasmask_dudv)
    Added so the breath fog blurs raindrops correctly.

    Credits: yohjimane

    /////////////////
    OpenXRay Engine 2023
    /////////////////
*/

float3 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    float4 circle_tc_pos;
    circle_tc_pos.xy = Tex0; // texcoord
    circle_tc_pos.x -= 0.5;
    circle_tc_pos.x *= screen_res.x * screen_res.w;
    circle_tc_pos.x += 0.5;
    circle_tc_pos.zw = float2(0.5, 0.5); // position (center of the screen)
    circle_tc_pos.y -= 0.6; // push it down to bottom 1/3 of screen

    float distFromCenter = distance(circle_tc_pos.xy, float2(0.5, -0.1));

    return SSFX_Blur(Tex0, distFromCenter);
}
