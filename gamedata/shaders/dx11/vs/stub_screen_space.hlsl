#include "common\common.h"

//////////////////////////////////////////////////////////////////////////////////////////
// Vertex
p_screen main(v2p_screen I)
{
    p_screen O;

    // Transform to screen space (in d3d9 it was done automatically)
    O.hpos = I.HPos;

    O.tc0 = I.tc0;

    return O;
}