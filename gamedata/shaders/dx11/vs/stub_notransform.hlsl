#include "common\common_iostructs.h"

//////////////////////////////////////////////////////////////////////////////////////////
// Vertex
v2p_TL main(v_TL I)
{
    v2p_TL O;

    O.HPos = I.P;
    O.Tex0 = I.Tex0;
    O.Color = I.Color.bgra; //	swizzle vertex colour

    return O;
}