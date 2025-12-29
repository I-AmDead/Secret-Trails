#include "common\common.h"

v2p_flat main(v_static I)
{
    I.Nh = unpack_D3DCOLOR(I.Nh);
    I.T = unpack_D3DCOLOR(I.T);
    I.B = unpack_D3DCOLOR(I.B);

    // Eye-space pos/normal
    v2p_flat O;
    float4 Pp = mul(m_WVP, I.P);
    O.hpos = Pp;
    O.hpos_curr = Pp;
    O.hpos_old = mul(m_WVP_old, I.P);
    O.N = mul((float3x3)m_WV, unpack_bx2(I.Nh));
    float3 Pe = mul(m_WV, I.P);

    float2 tc = unpack_tc_base(I.tc, I.T.w, I.B.w); // copy tc
    O.tcdh = float4(tc.xyyy);
    O.position = float4(Pe, I.Nh.w);
    O.hpos.xy = get_taa_jitter(O.hpos);

#ifdef USE_GRASS_WAVE
    O.tcdh.z = 1.f;
#endif

#ifdef USE_TDETAIL
    O.tcdbump = O.tcdh * dt_params; // dt tc
#endif

#ifdef USE_LM_HEMI
    O.lmh = unpack_tc_lmap(I.lmh);
#endif

    return O;
}
