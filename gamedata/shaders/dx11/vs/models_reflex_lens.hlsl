#include "common\common.h"
#include "common\skin.h"

struct VSOutput
{
    float2 Tex0 : TEXCOORD0;
    float3 T : TEXCOORD1;
    float3 B : TEXCOORD2;
    float3 N : TEXCOORD3;
    float3 P : TEXCOORD4;
    float4 HPos : SV_Position;
};

VSOutput _main(v_model I)
{
    VSOutput O;

    O.HPos = mul(m_WVP, I.P);
    O.HPos.xy = get_taa_jitter(O.HPos);

    O.Tex0 = I.Tex0.xy;

    O.T = mul(m_W, I.T).xyz;
    O.B = mul(m_W, I.B).xyz;
    O.N = mul(m_W, I.N).xyz;
    O.P = mul(m_W, I.P).xyz;

    return O;
}

// Skinning
#ifdef SKIN_NONE
VSOutput main(v_model I) { return _main(I); }
#endif

#ifdef SKIN_0
VSOutput main(v_model_skinned_0 I) { return _main(skinning_0(I)); }
#endif

#ifdef SKIN_1
VSOutput main(v_model_skinned_1 I) { return _main(skinning_1(I)); }
#endif

#ifdef SKIN_2
VSOutput main(v_model_skinned_2 I) { return _main(skinning_2(I)); }
#endif

#ifdef SKIN_3
VSOutput main(v_model_skinned_3 I) { return _main(skinning_3(I)); }
#endif

#ifdef SKIN_4
VSOutput main(v_model_skinned_4 I) { return _main(skinning_4(I)); }
#endif
