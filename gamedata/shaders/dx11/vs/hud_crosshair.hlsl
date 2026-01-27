#include "common\shared\common.h"

struct VSInput
{
    float4 P : POSITIONT;
    float4 Color : COLOR;
};

struct VSOutput
{
    float4 Color : COLOR;
    float4 P : SV_Position;
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

    O.Color = I.Color.bgra; //	swizzle vertex colour

    return O;
}