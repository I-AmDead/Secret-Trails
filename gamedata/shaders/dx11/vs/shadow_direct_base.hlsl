#include "common\common.h"

//////////////////////////////////////////////////////////////////////////////////////////
// Vertex
v2p_shadow_direct main(v_static I)
{
    v2p_shadow_direct O;
    O.HPos = mul(m_WVP, I.P);

#ifdef USE_AREF
    O.Tex0 = unpack_tc_base(I.Tex0, I.T.w, I.B.w);
#endif

    return O;
}
