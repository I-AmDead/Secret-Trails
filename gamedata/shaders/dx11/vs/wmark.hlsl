#include "common\common.h"
#include "common\shared\wmark.h"

v2p_TL_FOG main(v_static I)
{
    v2p_TL_FOG O;

    float3 N = unpack_normal(I.N);
    float4 P = wmark_shift(I.P, N);

    O.HPos = mul(m_VP, P);
    O.HPos.xy = get_taa_jitter(O.HPos);

    O.Tex0 = unpack_tc_base(I.Tex0, I.T.w, I.B.w);

    O.Color = 0;
    O.Fog = saturate(calc_fogging(I.P));

    return O;
}
