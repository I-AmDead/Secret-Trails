#include "common\common.h"

struct PSOutput
{
    float4 main : SV_Target0;
    float4 additional : SV_Target1;
};

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
PSOutput main(v2p_TL_FOG I) : SV_Target
{
    PSOutput O;

    float4 result = I.Color * s_base.Sample(smp_base, I.Tex0);

    clip(result.a - (0.01f / 255.0f));
    result.a *= I.Fog * I.Fog; // ForserX: Port Skyloader fog fix

    O.main = result;
    O.additional = float4(0.0, result.a > 0.2 ? (result.r + result.g + result.b) / 3.0f : 0.0, 0.0, result.a > 0.2 ? 1.0 : 0.0);

    return O;
}