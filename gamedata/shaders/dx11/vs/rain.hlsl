#include "common\shared\common.h"

struct VSInput
{
    float4 P : POSITIONT;
    float2 Tex0 : TEXCOORD0;
    float2 Tex1 : TEXCOORD1;
    float4 Color : COLOR;
};

struct VSOutput
{
    float2 Tex0 : TEXCOORD0;
    float2 Tex1 : TEXCOORD1;
    float4 Color : COLOR;
    float4 HPos : SV_Position;
};

//////////////////////////////////////////////////////////////////////////////////////////
// Vertex
VSOutput main(VSInput I)
{
    VSOutput O;

    O.HPos = I.P;
    O.Tex0 = I.Tex0;
    O.Tex1 = I.Tex1;
    O.Color = I.Color.bgra; //	swizzle vertex colour

    return O;
}