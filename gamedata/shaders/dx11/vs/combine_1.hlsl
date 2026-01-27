#include "common\common_iostructs.h"

// Vertex
v2p_screen main(float4 P : POSITIONT)
{
    v2p_screen O;

    O.HPos = float4(P.x, -P.y, 0, 1);
    O.Tex0 = P.zw;

    return O;
}
