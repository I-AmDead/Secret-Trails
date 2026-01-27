#include "common\shared\common.h"

struct VSInput
{
    float4 P : POSITIONT;
    float4 Tex0 : TEXCOORD0;
    float4 Tex1 : TEXCOORD1;
    float4 Tex2 : TEXCOORD2;
    float4 Tex3 : TEXCOORD3;
    float4 Tex4 : TEXCOORD4;
    float4 Tex5 : TEXCOORD5;
    float4 Tex6 : TEXCOORD6;
    float4 Tex7 : TEXCOORD7;
};

struct VSOutput
{
    float4 Tex0 : TEXCOORD0;
    float4 Tex1 : TEXCOORD1;
    float4 Tex2 : TEXCOORD2;
    float4 Tex3 : TEXCOORD3;
    float4 Tex4 : TEXCOORD4;
    float4 Tex5 : TEXCOORD5;
    float4 Tex6 : TEXCOORD6;
    float4 Tex7 : TEXCOORD7;
    float4 HPos : SV_Position;
};

//////////////////////////////////////////////////////////////////////////////////////////
// Vertex
VSOutput main(VSInput I)
{
    VSOutput O;

    I.P.xy += 0.5f; //	Bugs with rasterizer??? Possible float-pixel shift.
    O.HPos.x = I.P.x * screen_res.z * 2 - 1;
    O.HPos.y = (I.P.y * screen_res.w * 2 - 1) * -1;
    O.HPos.zw = I.P.zw;

    O.Tex0 = I.Tex0;
    O.Tex1 = I.Tex1;
    O.Tex2 = I.Tex2;
    O.Tex3 = I.Tex3;
    O.Tex4 = I.Tex4;
    O.Tex5 = I.Tex5;
    O.Tex6 = I.Tex6;
    O.Tex7 = I.Tex7;

    return O;
}