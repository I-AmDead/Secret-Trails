#include "common\shared\common.h"

struct VSInput
{
    float4 P : POSITIONT;
    float2 Tex0 : TEXCOORD0;
    float2 Tex1 : TEXCOORD1;
    float2 Tex2 : TEXCOORD2;
    float4 Color : COLOR0;
    float4 Gray : COLOR1;
};

struct VSOutput
{
    float2 Tex0 : TEXCOORD0;
    float2 Tex1 : TEXCOORD1;
    float2 Tex2 : TEXCOORD2;
    float4 Color : COLOR0;
    float4 Gray : COLOR1;
    float4 HPos : SV_Position;
};

//////////////////////////////////////////////////////////////////////////////////////////
// Vertex
VSOutput main(VSInput I)
{
    VSOutput O;

    I.P.xy += 0.5f;
    O.HPos.x = I.P.x * screen_res.z * 2 - 1;
    O.HPos.y = (I.P.y * screen_res.w * 2 - 1) * -1;
    O.HPos.zw = I.P.zw;

    O.Tex0 = I.Tex0;
    O.Tex1 = I.Tex1;
    O.Tex2 = I.Tex2;

    O.Color = I.Color.bgra;
    O.Gray = I.Gray.bgra;

    return O;
}