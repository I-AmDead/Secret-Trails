#include "common\common.h"
#include "common\shared\cloudconfig.h"

struct VSInput
{
    float4 P : POSITION;
    float4 Color0 : COLOR0;
    float4 Color1 : COLOR1;
};

v2p_TLD2 main(VSInput I)
{
    v2p_TLD2 O;

    O.HPos = mul(m_WVP, I.P);
    O.HPos.xy = get_taa_jitter(O.HPos);

    // generate tcs
    float2 d0 = I.Color0.xy * 2.0f - 1.0f;
    float2 d1 = I.Color0.wz * 2.0f - 1.0f;
    O.Tex0 = I.P.xz * CLOUD_TILE0 + d0 * timers.z * CLOUD_SPEED0;
    O.Tex1 = I.P.xz * CLOUD_TILE1 + d1 * timers.z * CLOUD_SPEED1;

    O.Color = I.Color1;
    O.Color.w *= pow(I.P.y, 25.0f);

    return O;
}
