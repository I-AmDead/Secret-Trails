#include "common\common.h"
#include "common\skin.h"

struct VSOutput
{
    float4 HPos : SV_Position;
    float2 Tex0 : TEXCOORD0;
    float3 P : POSITION0;
    float3 T : TANGENT0;
    float3 B : BINORMAL0;
    float3 N : NORMAL0;
    float3 PV : POSITION1;
    float3 TV : TANGENT1;
    float3 BV : BINORMAL1;
    float3 NV : NORMAL1;
};

VSOutput _main(v_model I)
{
    VSOutput O;

    O.HPos = mul(m_WVP, I.P);
    O.HPos.xy = get_taa_jitter(O.HPos);

    O.Tex0 = I.Tex0.xy;

    O.P = mul(m_W, I.P).xyz;
    O.T = mul(m_W, I.T).xyz;
    O.B = mul(m_W, I.B).xyz;
    O.N = mul(m_W, I.N).xyz;

    O.PV = mul(m_WV, I.P).xyz;
    O.TV = mul(m_WV, I.T).xyz;
    O.BV = mul(m_WV, I.B).xyz;
    O.NV = mul(m_WV, I.N).xyz;

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
