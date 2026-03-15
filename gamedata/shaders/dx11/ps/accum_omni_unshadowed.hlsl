#include "common\common.h"
#include "common\lmodel.h"

// Check Screen Space Shaders modules & addons
#include "common\screenspace\check_screenspace.h"

float3 main(p_screen_volume I) : SV_Target
{
    float2 tcProj = I.Tex0.xy / I.Tex0.w;

    gbuffer_data gbd = gbuffer_load_data(tcProj, I.HPos);

    float4 _P = float4(gbd.P, gbd.mtl);
    float4 _N = float4(gbd.N, gbd.hemi);
    float4 _C = float4(gbd.C, gbd.gloss);

    // FLORA FIXES & IMPROVEMENTS - SSS Update 14.2
    // Fix Flora ilumination ( Align normal to light )
    if (abs(_P.w - MAT_FLORA) <= 0.05)
    {
        _N.rgb = -normalize(_P - Ldynamic_pos.xyz);
        _C.w *= 0.3f;
    }

    float3 light = plight_local(_P, _N, _C);

#ifdef SSFX_ENHANCED_SHADERS
    return SRGBToLinear(Ldynamic_color.rgb) * light;
#else
    return Ldynamic_color * light;
#endif
}
