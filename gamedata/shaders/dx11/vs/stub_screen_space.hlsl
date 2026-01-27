#include "common\common.h"

//////////////////////////////////////////////////////////////////////////////////////////
// Vertex
p_screen main(v2p_screen I)
{
    p_screen O;

    O.HPos = I.HPos;
    O.Tex0 = I.Tex0;

    return O;
}