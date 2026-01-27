#include "common\common.h"

uniform float4x4 mVPTexgen;

//////////////////////////////////////////////////////////////////////////////////////////
// Vertex
v2p_TLD4 main(v_TL I)
{
    v2p_TLD4 O;

    O.HPos = mul(m_VP, I.P);

    O.Tex0 = I.Tex0;
    O.Tex1 = mul(mVPTexgen, I.P);
    O.Tex1.z = O.HPos.z;

    O.Color = I.Color.bgra;

    return O;
}