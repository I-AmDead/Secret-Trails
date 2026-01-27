#include "common\common.h"

struct VSInput
{
    float4 P : POSITION;
    float4 Color : COLOR0;
    float3 Tex0 : TEXCOORD0;
    float3 Tex1 : TEXCOORD1;
};

struct VSOutput
{
    float4 Color : COLOR0;
    float3 Tex0 : TEXCOORD0;
    float3 Tex1 : TEXCOORD1;
    float4 HPos_curr : HPOS_CURRENT;
    float4 HPos_old : HPOS_PREVIOUS;
    float4 HPos : SV_Position;
};

VSOutput main(VSInput I)
{
    VSOutput O;

    float4 tpos = mul(I.P, 2000);
    O.HPos = mul(m_WVP, tpos);
    O.HPos.z = O.HPos.w;
    O.HPos_curr = O.HPos;
    O.HPos_old = mul(m_WVP_old, tpos);
    O.HPos_old.z = O.HPos_old.w;
    O.HPos.xy = get_taa_jitter(O.HPos);

    O.Tex0.xyz = I.Tex0;
    O.Tex1.xyz = I.Tex1;

    float3 tint = I.Color.rgb * 1.5;

    O.Color = float4(tint, I.Color.a);

    return O;
}