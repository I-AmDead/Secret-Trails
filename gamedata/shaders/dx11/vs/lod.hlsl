#include "common\common.h"

struct VSInput
{
    float3 P0 : POSITION0;
    float3 P1 : POSITION1;
    float2 Tex0 : TEXCOORD0;
    float2 Tex1 : TEXCOORD1;
    float4 Tex3 : TEXCOORD2;
    float4 Tex4 : TEXCOORD3;
    float4 Color : COLOR0;
};

struct VSOutput
{
    float3 P : TEXCOORD0;
    float2 Tex0 : TEXCOORD1;
    float2 Tex1 : TEXCOORD2;
    float4 HPos_curr : TEXCOORD3;
    float4 HPos_old : TEXCOORD4;
    float4 Color : COLOR1;
    float4 HPos : SV_Position;
};

#define L_SCALE (2.0h * 1.55h)

VSOutput main(VSInput I)
{
    VSOutput O;

    I.Color.xyz = I.Color.zyx;
    I.Tex3.xyz = I.Tex3.zyx;
    I.Tex4.xyz = I.Tex4.zyx;

    // lerp pos
    float factor = I.Color.w;
    float4 pos = float4(lerp(I.P0, I.P1, factor), 1);

    float h = lerp(I.Tex3.w, I.Tex4.w, factor) * L_SCALE;

    O.HPos = mul(m_VP, pos); // xform, input in world coords
    O.HPos_curr = O.HPos;
    O.HPos_old = mul(m_VP_old, pos);
    O.P = mul(m_V, pos);
    O.HPos.xy = get_taa_jitter(O.HPos);

    // replicate TCs
    O.Tex0 = I.Tex0;
    O.Tex1 = I.Tex1;

    // calc normal & lighting
    O.Color = float4(h, h, I.Color.z, factor);

    return O;
}
