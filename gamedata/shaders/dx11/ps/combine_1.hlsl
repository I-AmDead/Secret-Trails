#include "common\common.h"

// Check MODs
#include "common\screenspace\check_screenspace.h"

#ifdef SSFX_BEEFS_NVG
#include "common\night_vision.h"
#endif

#include "common\screenspace\screenspace_fog.h"

#include "common\lmodel.h"
#include "common\hmodel.h"

#ifdef SSAO_QUALITY
#ifdef USE_GTAO
#include "common\gtao.h"
#else
#include "ps\ssdo.hlsl"
#endif
#endif

float4 main(p_screen I) : SV_Target
{
    gbuffer_data gbd = gbuffer_load_data(I.Tex0, I.HPos);

    // Sample the buffers:
    float4 P = float4(gbd.P, gbd.mtl); // position.(mtl or sun)
    float4 N = float4(gbd.N, gbd.hemi); // normal.hemi
    float4 D = float4(gbd.C, gbd.gloss); // rgb.gloss
    float4 L = s_accumulator.Sample(smp_nofilter, I.Tex0); // diffuse.specular

#ifndef SSFX_NEWGLOSS
    if (abs(P.w - MAT_FLORA) <= 0.05)
    {
        // Reapply distance factor to fix overtly glossy plants in distance
        // Unfortunately some trees etc don't seem to use the same detail shader
        float fAtten = 1 - smoothstep(0, 50, P.z);
        D.a *= (fAtten * fAtten);
    }
#endif

    float3 occ = float3(1.0, 1.0, 1.0);

#ifdef SSAO_QUALITY
#ifdef USE_GTAO
    occ = calc_gtao(P, N, I.Tex0);
#else
    occ = calc_ssdo(P, N, I.Tex0, I.HPos);
#endif
    occ = compute_colored_ao(occ.x, D.xyz);
#endif

    L.rgb += L.a * SRGBToLinear(D.rgb); // illum in alpha

    // hemisphere
    float3 hdiffuse, hspecular;
    hmodel(hdiffuse, hspecular, P.w, N.w, D, P.xyz, N.xyz);

    // AO implementation
#ifdef SSAO_QUALITY
#ifdef SSFX_AO
    hdiffuse *= (1.0f - SRGBToLinear(1.0f - occ) * (1.0f - dot(hdiffuse.rgb, LUMINANCE_VECTOR)));
#else
    hdiffuse *= occ;
#endif
#endif

    float3 color = L.rgb + hdiffuse.rgb;
    color = LinearTosRGB(color); // gamma correct

#ifdef SSFX_BEEFS_NVG
    float lua_param_nvg_num_tubes = pnv_param_4.x; // 1, 2, 4, 1.1, or 1.2
    // NVG reduces gloss to 0 inside mask
    D.a *= (1.0 - compute_lens_mask(aspect_ratio_correction(I.Tex0), lua_param_nvg_num_tubes));
#endif

    // here should be distance fog
    float3 WorldP = mul(m_inv_V, float4(P.xyz, 1));
    float fog = SSFX_HEIGHT_FOG(P.xyz, WorldP.y, color);

    float skyblend = 0.0; // saturate(fog * fog);  // ??? 0.0 ?????? ??? ??? ?? ??????? ????????

    return float4(color, skyblend);
}
