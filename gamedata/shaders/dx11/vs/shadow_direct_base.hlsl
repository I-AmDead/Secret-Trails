#include "common\common.h"

struct VSInput
{
#ifdef USE_AREF
    float4 T : TANGENT;
    float4 B : BINORMAL;
    int2 Tex0 : TEXCOORD0;
#endif
    float4 P : POSITION;
};

//////////////////////////////////////////////////////////////////////////////////////////
// Vertex
v2p_shadow_direct main(VSInput I)
{
    v2p_shadow_direct O;
    O.HPos = mul(m_WVP, I.P);

#ifdef USE_AREF
    O.Tex0 = unpack_tc_base(I.Tex0, I.T.w, I.B.w);
#endif

    return O;
}
