#include "common\common.h"

#define DEPTH_EPSILON 0.1h

struct PSInput
{
    float2 Tex0 : TEXCOORD0;
    float4 Tex1 : TEXCOORD1;
    float4 Color : COLOR0;
    float Fog : FOG;
};

struct PSOutput
{
    float4 main : SV_Target0;
    float4 additional : SV_Target1;
};

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
PSOutput main(PSInput I) : SV_Target
{
    PSOutput O;

    float4 result = I.Color * s_base.Sample(smp_base, I.Tex0);

    float2 tcProj = I.Tex1.xy / I.Tex1.w;

    float depth = gbuffer_depth(tcProj);
    float spaceDepth = depth - I.Tex1.z - DEPTH_EPSILON;

    if (spaceDepth < -2 * DEPTH_EPSILON)
        spaceDepth = 100000.0h; //  Skybox doesn't draw into position buffer

    result.a *= Contrast(saturate(spaceDepth * 1.3h), 2);
    result.rgb *= Contrast(saturate(spaceDepth * 1.3h), 2);

    clip(result.a - (0.01f / 255.0f));
    result.a *= I.Fog * I.Fog; // ForserX: Port Skyloader fog fix

    O.main = result;
    O.additional = float4(0.0, result.a > 0.2 ? (result.r + result.g + result.b) / 3.0f : 0.0, 0.0, result.a > 0.2 ? 1.0 : 0.0);

    return O;
}