#include "common\common.h"

struct PSInput
{
    float2 Tex0 : TEXCOORD0;
    float4 Tex1 : TEXCOORD1;
    float4 Color : COLOR0;
    float Fog : FOG;
};

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
Texture2D s_distort;
float4 main(PSInput I) : SV_Target
{
    float4 distort = s_distort.Sample(smp_linear, I.Tex0);
    float factor = distort.a * dot(I.Color.rgb, 0.33h);
    float4 result = float4(distort.rgb, factor);

    result.a *= I.Fog * I.Fog; // ForserX: Port Skyloader fog fix
    return result;
}