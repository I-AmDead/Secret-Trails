#include "common\common.h"
#include "common\screenspace\screenspace_fog.h"

struct VSInput
{
    float4 Nh : NORMAL;
    float4 T : TANGENT;
    float4 B : BINORMAL;
    int2 Tex0 : TEXCOORD0;
    float4 Color : COLOR0;
    float4 P : POSITION;
#ifdef USE_LM_HEMI
    int2 lmh : TEXCOORD1;
#endif
};

v2p_TL_FOG main(VSInput I)
{
    v2p_TL_FOG O;

    float3 N = unpack_normal(I.Nh);
    O.HPos = mul(m_VP, I.P); // xform, input in world coords
    O.HPos.xy = get_taa_jitter(O.HPos);

    O.Tex0 = unpack_tc_base(I.Tex0, I.T.w, I.B.w); // copy tc

    float3 L_rgb = I.Color.zyx; // precalculated RGB lighting
    float3 L_hemi = v_hemi(N) * I.Nh.w; // hemisphere
    float3 L_sun = v_sun(N) * I.Color.w; // sun
    float3 L_final = L_rgb + L_hemi + L_sun + L_ambient;

    O.Color = L_final;
    O.Fog = saturate(calc_fogging(I.P)); // fog, input in world coords
    O.Fog = SSFX_FOGGING(1.0 - O.Fog, I.P.y); // Add SSFX Fog

    return O;
}
