#include "common\common.h"

p_screen main(v_TL I)
{
    p_screen O;

    O.Tex0 = I.Tex0;
    O.HPos = I.P / 10000;
    O.HPos.w = 1;
    O.HPos = mul(m_WVP, O.HPos);

    return O;
}
