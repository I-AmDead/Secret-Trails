#include "common\common.h"
#include "common\skin.h"

v2p_TLD4 _main(v_model I)
{
    v2p_TLD4 O;

    O.HPos = mul(m_WVP, I.P);
    O.HPos.xy = get_taa_jitter(O.HPos);

    O.Tex0 = I.Tex0.xy;

    // calculate fade
    float3 dir_v = normalize(mul(m_WV, I.P));
    float3 norm_v = normalize(mul(m_WV, I.N));
    float fade = abs(dot(dir_v, norm_v));
    O.Color = fade;

    // HUD Rain drops - SSS Update 17
    // https://www.moddb.com/mods/stalker-anomaly/addons/screen-space-shaders/
    O.Tex1.xyz = mul(m_W, I.N); // Normal [ World Space ]

    return O;
}

/////////////////////////////////////////////////////////////////////////
#ifdef SKIN_NONE
v2p_TLD4 main(v_model I) { return _main(I); }
#endif

#ifdef SKIN_0
v2p_TLD4 main(v_model_skinned_0 I) { return _main(skinning_0(I)); }
#endif

#ifdef SKIN_1
v2p_TLD4 main(v_model_skinned_1 I) { return _main(skinning_1(I)); }
#endif

#ifdef SKIN_2
v2p_TLD4 main(v_model_skinned_2 I) { return _main(skinning_2(I)); }
#endif

#ifdef SKIN_3
v2p_TLD4 main(v_model_skinned_3 I) { return _main(skinning_3(I)); }
#endif

#ifdef SKIN_4
v2p_TLD4 main(v_model_skinned_4 I) { return _main(skinning_4(I)); }
#endif
