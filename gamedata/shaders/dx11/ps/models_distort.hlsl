#include "common\common.h"

Texture2D s_distort;

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
float4 main(v2p_TL_FOG I) : SV_Target
{
    float4 distort = s_distort.Sample(smp_linear, I.Tex0);
    float factor = distort.a * dot(I.Color.rgb, 0.33h);
    float4 result = float4(distort.rgb, factor);

    result.a *= I.Fog * I.Fog; // ForserX: Port Skyloader fog fix
    return result;
}