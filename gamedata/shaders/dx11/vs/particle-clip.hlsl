#include "common\common.h"

v2p_TL main(v_TL I)
{
    v2p_TL O;

    O.HPos = mul(m_WVP, I.P); // xform, input in world coords
    O.HPos.z = abs(O.HPos.z);
    O.HPos.w = abs(O.HPos.w);
    O.HPos.xy = get_taa_jitter(O.HPos);

    O.Tex0 = I.Tex0;
    O.Color = I.Color;

    return O;
}
