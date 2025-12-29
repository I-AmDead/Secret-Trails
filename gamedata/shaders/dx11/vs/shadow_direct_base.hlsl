#include "common\common.h"

struct v_shadow
{
#ifdef USE_AREF
    float4 Nh : NORMAL; // (nx,ny,nz,hemi occlusion)
    float4 T : TANGENT; // tangent
    float4 B : BINORMAL; // binormal
    int2 tc : TEXCOORD0; // (u,v)
#endif
    float4 P : POSITION; // (float,float,float,1)
};

//////////////////////////////////////////////////////////////////////////////////////////
// Vertex
v2p_shadow_direct main(v_shadow I)
{
    v2p_shadow_direct O;
    O.hpos = mul(m_WVP, I.P);
#ifdef USE_AREF
    O.tc0 = unpack_tc_base(I.tc, I.T.w, I.B.w); // copy tc
#endif
    return O;
}
