#include "common\common.h"
#include "common\lmodel.h"
#include "common\shadow.h"

// Check Screen Space Shaders modules & addons
#include "common\screenspace\check_screenspace.h"

float4 m_lmap[2];

float3 main(p_screen_volume I) : SV_Target
{
    float2 tcProj = I.Tex0.xy / I.Tex0.w;

    gbuffer_data gbd = gbuffer_load_data(tcProj, I.HPos);

    gbd.P += gbd.N * 0.025f;

    float4 _P = float4(gbd.P, gbd.mtl);
    float4 _N = float4(gbd.N, gbd.hemi);
    float4 _C = float4(gbd.C, gbd.gloss);

    // FLORA FIXES & IMPROVEMENTS - SSS Update 14.2
    // Fix Flora ilumination ( Align normal to light )
#ifdef SSFX_FLORAFIX
    if (abs(_P.w - MAT_FLORA) <= 0.05)
    {
        _N.rgb = -normalize(_P - Ldynamic_pos.xyz);
        _C.w *= 0.3f;
    }
#endif

    // ----- light-model
    float3 light = plight_local(_P, _N, _C, Ldynamic_pos, Ldynamic_pos.w);

    // ----- shadow
    float4 P4 = float4(_P.xyz, 1);
    float4 PS = mul(m_shadow, P4);
    float s = 1.h;

#ifdef USE_SHADOW
    s = shadow(PS);
#endif

    // ----- lightmap
    float4 lightmap = 1.h;
#ifdef USE_LMAP
#ifdef USE_LMAPXFORM
    PS.xy = float2(dot(P4, m_lmap[0]), dot(P4, m_lmap[1]));
#endif

    //	Can use linear with mip point
    lightmap = s_lmap.SampleLevel(smp_rtlinear, PS.xy / PS.w, 0);
#endif

#ifdef SSFX_ENHANCED_SHADERS
    float3 result = SRGBToLinear(lightmap.rgb) * SRGBToLinear(s);
    result *= light * SRGBToLinear(Ldynamic_color.rgb);
    return result;
#else
    return Ldynamic_color * light * s * lightmap;
#endif
}
