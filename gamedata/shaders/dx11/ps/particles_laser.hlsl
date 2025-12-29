#include "common\common.h"

uniform float4 m_affects;

struct v2p
{
    float2 tc0 : TEXCOORD0;
    float4 c : COLOR0;
    float4 tctexgen : TEXCOORD1;
    float fog : FOG; // fog
    float4 hpos : SV_Position;
};

struct p_particle_out
{
    float4 main : SV_Target0;
    float4 additional : SV_Target1;
};

// Must be less than view near
#define DEPTH_EPSILON 0.1h

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
p_particle_out main(v2p I) : SV_Target
{
    p_particle_out O;

    float4 result = I.c * s_base.Sample(smp_base, I.tc0);
    result.rgb = result.rgb * 0.9;

    // ??????? ?????? ??? ???????
    float mig = 1.0f - (m_affects.x * 2.f);
    result.a = random(timers.xz) > mig ? 0.f : result.a;

    float2 tcProj = I.tctexgen.xy / I.tctexgen.w;
    float3 depth = gbuffer_depth(tcProj);
    float spaceDepth = depth.z - I.tctexgen.z - DEPTH_EPSILON;

    if (spaceDepth < -2 * DEPTH_EPSILON)
        spaceDepth = 100000.0h; //  Skybox doesn't draw into position buffer

    result.a *= Contrast(saturate(spaceDepth * 1.3h), 2);
    result.rgb *= Contrast(saturate(spaceDepth * 1.3h), 2);

    clip(result.a - (0.01f / 255.0f));
    result.a *= I.fog * I.fog; // ForserX: Port Skyloader fog fix

    O.main = result;

    O.main = result;
    O.additional = float4(0.0, result.a > 0.2 ? (result.r + result.g + result.b) / 3.0f : 0.0, 0.0, result.a > 0.2 ? 1.0 : 0.0);

    return O;
}