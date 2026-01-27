#include "common\common.h"
#include "common\skin.h"

//////////////////////////////////////////////////////////////////////////////////////////
// Vertex
v2p_shadow_direct _main(v_model I)
{
    v2p_shadow_direct O;
    O.HPos = mul(m_WVP, I.P);

#ifdef USE_AREF
    O.Tex0 = I.Tex0;
#endif

    return O;
}

/////////////////////////////////////////////////////////////////////////
#ifdef SKIN_NONE
v2p_shadow_direct main(v_model I) { return _main(I); }
#endif

#ifdef SKIN_0
v2p_shadow_direct main(v_model_skinned_0 I) { return _main(skinning_0(I)); }
#endif

#ifdef SKIN_1
v2p_shadow_direct main(v_model_skinned_1 I) { return _main(skinning_1(I)); }
#endif

#ifdef SKIN_2
v2p_shadow_direct main(v_model_skinned_2 I) { return _main(skinning_2(I)); }
#endif

#ifdef SKIN_3
v2p_shadow_direct main(v_model_skinned_3 I) { return _main(skinning_3(I)); }
#endif

#ifdef SKIN_4
v2p_shadow_direct main(v_model_skinned_4 I) { return _main(skinning_4(I)); }
#endif
