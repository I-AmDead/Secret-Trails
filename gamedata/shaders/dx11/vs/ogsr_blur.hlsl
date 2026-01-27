#include "common\common.h"

//////////////////////////////////////////////////////////////////////////////////////////
// Vertex
p_screen main(v2p_screen I)
{
    p_screen O;

    O.HPos.x = (I.HPos.x * screen_res.z * 2 - 1);
    O.HPos.y = -(I.HPos.y * screen_res.w * 2 - 1);
    O.HPos.zw = I.HPos.zw;

    O.Tex0 = I.Tex0;

    return O;
}