#include "common\common.h"
#include "common\shared\waterconfig.h"

struct v2p
{
    float2 tbase : TEXCOORD0;
    float2 tdist0 : TEXCOORD1;
    float2 tdist1 : TEXCOORD2;
    float4 tctexgen : TEXCOORD3;
    float4 hpos : SV_Position;
};

Texture2D s_distort;

#define POWER 0.5
#define DEPTH_FALLOFF 5.0
#define DISTORT_POWER 0.5

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
float4 main(v2p I) : SV_Target
{
    float4 t_base = s_base.Sample(smp_base, I.tbase);

    float2 t_d0 = s_distort.Sample(smp_base, I.tdist0);
    float2 t_d1 = s_distort.Sample(smp_base, I.tdist1);
    float2 distort = (t_d0 + t_d1) * DISTORT_POWER; // average
    float2 zero = float2(0.5, 0.5);
    float2 faded = lerp(distort, zero, t_base.a);

    float alphaDistort;
    float2 PosTc = I.tctexgen.xy / I.tctexgen.z;
    float waterDepth = gbuffer_depth(PosTc) - I.tctexgen.z;

    alphaDistort = saturate(DEPTH_FALLOFF * waterDepth);
    faded = lerp(zero, faded, alphaDistort);

    float alpha = 0.5f;
    faded = faded * POWER - 0.5 * POWER + 0.5;

    return float4(faded, 0.f, alpha);
}
