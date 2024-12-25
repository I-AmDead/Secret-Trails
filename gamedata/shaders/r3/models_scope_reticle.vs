#include "common.h"
#include "skin.h"

struct vf
{
    float4 hpos : SV_Position;
    float2 tc0 : TEXCOORD0;
    float3 v_pos : TEXCOORD1;
    float3 v_nrm : TEXCOORD2;
    float3 w_pos : TEXCOORD3;
    float3 w_nrm : TEXCOORD4;
    float3 v_dir : TEXCOORD5;
    float3 v_sun : TEXCOORD6;
};

vf _main(v_model I)
{
    vf O;

    O.hpos = mul(m_WVP, I.P);
    O.hpos.xy = get_taa_jitter(O.hpos);

    O.tc0 = I.tc.xy;

    O.v_pos = mul(m_WV, I.P).xyz;
    O.v_nrm = mul(m_WV, I.N).xyz;

    O.w_pos = mul(m_W, I.P).xyz;
    O.w_nrm = mul(m_W, I.N).xyz;

    O.v_dir = mul(m_V, normalize(O.w_pos - eye_position));
    O.v_sun = mul(m_V, L_sun_dir_w);

    return O;
}

/////////////////////////////////////////////////////////////////////////
#ifdef SKIN_NONE
vf main(v_model v) { return _main(v); }
#endif

#ifdef SKIN_0
vf main(v_model_skinned_0 v) { return _main(skinning_0(v)); }
#endif

#ifdef SKIN_1
vf main(v_model_skinned_1 v) { return _main(skinning_1(v)); }
#endif

#ifdef SKIN_2
vf main(v_model_skinned_2 v) { return _main(skinning_2(v)); }
#endif

#ifdef SKIN_3
vf main(v_model_skinned_3 v) { return _main(skinning_3(v)); }
#endif

#ifdef SKIN_4
vf main(v_model_skinned_4 v) { return _main(skinning_4(v)); }
#endif

FXVS;
