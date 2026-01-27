#define USE_LM_HEMI
#include "common\common.h"

struct VSOutput
{
    float2 Tex0 : TEXCOORD0;
    float2 Tex1 : TEXCOORD1;
    float2 Tex2 : TEXCOORD2;
    float3 Tex3 : TEXCOORD3;
    float3 Color0 : COLOR0;
    float3 Color1 : COLOR1;
    float Fog : FOG;
    float4 HPos : SV_Position;
};

VSOutput main(v_static I)
{
    VSOutput O;

    float3 pos_w = I.P;
    float3 norm_w = normalize(unpack_normal(I.N));

    O.HPos = mul(m_VP, I.P);
    O.HPos.xy = get_taa_jitter(O.HPos);

    O.Tex0 = unpack_tc_base(I.Tex0, I.T.w, I.B.w);
    O.Tex1 = unpack_tc_lmap(I.Tex1);
    O.Tex2 = O.Tex1;
    O.Tex3 = calc_reflection(pos_w, norm_w);

    O.Color0 = v_hemi(norm_w);
    O.Color1 = v_sun(norm_w);

    O.Fog = saturate(calc_fogging(I.P));

    return O;
}
