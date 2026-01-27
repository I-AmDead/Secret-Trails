#include "common\shared\common.h"
#include "common\common_iostructs.h"

p_screen_volume main(in float3 vertices : POSITION)
{
    p_screen_volume O;

    O.HPos = mul(m_WVP, float4(vertices, 1.0));
    O.Tex0 = O.HPos;

    return O;
}
