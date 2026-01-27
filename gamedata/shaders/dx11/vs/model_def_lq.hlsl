#include "common\common.h"
#include "common\skin.h"
#include "common\screenspace\screenspace_fog.h"

v2p_TL_FOG _main(v_model I)
{
    v2p_TL_FOG O;

    float4 pos = I.P;
    float3 pos_w = mul(m_W, pos);
    float3 norm_w = normalize(mul(m_W, I.N));

    O.HPos = mul(m_WVP, pos); // xform, input in world coords
    O.HPos.xy = get_taa_jitter(O.HPos);

    O.Tex0 = I.Tex0.xy; // copy tc
    O.Color = calc_model_lq_lighting(norm_w);
    O.Fog = saturate(calc_fogging(float4(pos_w, 1))); // fog, input in world coords
    O.Fog = SSFX_FOGGING(1.0 - O.fog, pos.y); // Add SSFX Fog

    return O;
}

/////////////////////////////////////////////////////////////////////////
#ifdef SKIN_NONE
v2p_TL_FOG main(v_model I) { return _main(I); }
#endif

#ifdef SKIN_0
v2p_TL_FOG main(v_model_skinned_0 I) { return _main(skinning_0(I)); }
#endif

#ifdef SKIN_1
v2p_TL_FOG main(v_model_skinned_1 I) { return _main(skinning_1(I)); }
#endif

#ifdef SKIN_2
v2p_TL_FOG main(v_model_skinned_2 I) { return _main(skinning_2(I)); }
#endif

#ifdef SKIN_3
v2p_TL_FOG main(v_model_skinned_3 I) { return _main(skinning_3(I)); }
#endif

#ifdef SKIN_4
v2p_TL_FOG main(v_model_skinned_4 I) { return _main(skinning_4(I)); }
#endif