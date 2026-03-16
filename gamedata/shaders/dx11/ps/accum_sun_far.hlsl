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

    // Far Shadows
    float shadows = shadow(PS);

    // Fade UV
    float2 FadeUV = PS.xy / PS.w;

    // Fade calc
    float4 fade = smoothstep(0.f, 0.1f, float4(FadeUV.x, 1.f - FadeUV.x, FadeUV.y, 1.f - FadeUV.y));
    float f = fade.x * fade.y * fade.z * fade.w;
    shadows += (1.f - shadows) * (1.f - f);

#ifdef SSFX_SSS
    shadows *= SSFX_ScreenSpaceShadows_Far(_P, I.HPos);
#endif

#ifdef SSFX_ENHANCED_SHADERS
    float3 result = SRGBToLinear(shadows);
    result *= light * SRGBToLinear(Ldynamic_color.rgb);

    return result;
#else
    return Ldynamic_color * light * shadows;
#endif
}