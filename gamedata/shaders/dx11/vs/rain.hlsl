#include "common\common.h"

struct VSInput
{
    float4 P : POSITIONT;
    float2 Tex0 : TEXCOORD0;
    float2 Tex1 : TEXCOORD1;
    float4 Color : COLOR;
};

//////////////////////////////////////////////////////////////////////////////////////////
// Vertex
v2p_TLD2 main(VSInput I)
{
    v2p_TLD2 O;

    O.HPos = I.P;
    O.Tex0 = I.Tex0;
    O.Tex1 = I.Tex1;
    O.Color = I.Color.bgra;

    return O;
}