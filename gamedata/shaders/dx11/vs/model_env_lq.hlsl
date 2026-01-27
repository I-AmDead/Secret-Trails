#include "common\common.h"
#include "common\skin.h"
#include "common\screenspace\screenspace_fog.h"

struct VSOutput
{
    float2 Tex0 : TEXCOORD0; // base
    float3 Tex1 : TEXCOORD1; // environment
    float3 Color : COLOR0; // color
    float Fog : FOG;
    float4 HPos : SV_Position;
};

VSOutput _main(v_model I)
{
    VSOutput O;

    float4 pos = I.P;
    float3 pos_w = mul(m_W, pos);
    float3 norm_w = normalize(mul(m_W, I.N));

    O.HPos = mul(m_WVP, pos);
    O.HPos.xy = get_taa_jitter(O.HPos);

    O.Tex0 = I.Tex0.xy; // copy tc
    O.Tex1 = calc_reflection(pos_w, norm_w);
    O.Color = calc_model_lq_lighting(float3(0, 1, 0)); // SSS 14.5 - Improve the illumination a little using a fake normal

    O.Fog = saturate(calc_fogging(float4(pos_w, 1))); // fog, input in world coords
    O.Fog = SSFX_FOGGING(1.0 - O.Fog, pos.y); // Add SSFX Fog

    return O;
}

/////////////////////////////////////////////////////////////////////////
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