#include "common\common.h"
#include "common\lmodel.h"

// Check Screen Space Shaders modules & addons
#include "common\screenspace\check_screenspace.h"

#ifdef SSFX_SSS
#include "common\screenspace\screenspace_shadows.h"
#endif

#include "common\shadow.h"

float3 main(p_screen_volume I) : SV_Target
{
    gbuffer_data gbd = gbuffer_load_data(I.Tex0.xy / I.Tex0.w, I.HPos);

    //	Emulate virtual offset
    gbd.P += gbd.N * 0.015f;

    float4 _P = float4(gbd.P, gbd.mtl);
    float4 _N = float4(gbd.N, gbd.hemi);
    float4 _C = float4(gbd.C, gbd.gloss);

    float3 light = plight_infinity(_P, _N, _C);

    float4 P4 = float4(_P.xyz, 1.0);
    float4 PS = mul(m_shadow, P4);
    float shadows = shadow(PS);

#ifdef SSFX_SSS
    shadows *= SSFX_ScreenSpaceShadows(_P, I.HPos);
#endif

#ifdef SSFX_ENHANCED_SHADERS // We have Enhanced Shaders installed
    float3 result = SRGBToLinear(shadows);
    result *= light * SRGBToLinear(Ldynamic_color.rgb);
    return result;
#else
    return Ldynamic_color * light * shadows;
#endif
}