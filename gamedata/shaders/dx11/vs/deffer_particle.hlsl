#include "common\common.h"

struct VSOtput
{
    float4 Color : COLOR0;
    float2 Tex0 : TEXCOORD0;
    float4 Tex1 : TEXCOORD1;
    float3 Tex2 : TEXCOORD2;
    float4 HPos_curr : TEXCOORD3;
    float4 HPos_old : TEXCOORD4;
    float4 HPos : SV_Position;
};

VSOtput main(v_TL I)
{
    VSOtput O;

    float3 Pe = mul(m_WV, I.P);

    O.HPos = mul(m_WVP, I.P);
    O.HPos_curr = O.HPos;
    O.HPos_old = mul(m_WVP_old, I.P);
    O.HPos.xy = get_taa_jitter(O.HPos);

    O.Tex0 = I.Tex0;
    O.Tex1 = float4(Pe, .2h);
    O.Tex2 = normalize(eye_position - I.P);

    O.Color = I.Color;

    return O;
}
