#include "common\common.h"

v2p_TL main(v_static I)
{
    v2p_TL O;

    O.HPos = mul(m_WVP, I.P); // xform, input in world coords
    O.HPos.xy = get_taa_jitter(O.HPos);

    O.Tex0 = unpack_tc_base(I.Tex0, I.T.w, I.B.w); // copy tc

    // calculate fade
    float3 dir_v = normalize(mul(m_WV, I.P));
    float3 norm_v = normalize(mul(m_WV, unpack_normal(I.N).zyx));
    float fade = abs(dot(dir_v, norm_v));
    O.Color = fade;

    return O;
}
