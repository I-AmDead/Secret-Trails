#include "common\common.h"

struct VSOutput
{
    float4 Color : COLOR0;
    float4 P : SV_Position;
};

uniform float4 tfactor;

VSOutput main(float4 P : POSITION)
{
    VSOutput O;

    O.P = mul(m_WVP, P);
    O.Color = tfactor;

    return O;
}
