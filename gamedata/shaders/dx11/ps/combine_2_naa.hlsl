#include "common\common.h"
#include "common\mblur.h"
#include "common\img_corrections.h"
#include "common\ogsr_radiation_effect.h"
#include "common\effects_flare.h"

// Check Screen Space Shaders modules
#include "common\screenspace\check_screenspace.h"

#include "common\night_vision.h"

#ifdef SSFX_DEBAND
#include "common\screenspace\screenspace_debanding.h"
#endif

#include "common\screenspace\screenspace_fog.h"
#include "common\screenspace\settings_screenspace_FOG.h"

uniform float4 m_flare_params;

Texture2D s_ssfx_bloom;
Texture2D s_flares;

float3 main(p_screen I) : SV_Target
{
    float2 center = I.Tex0;
    
    float3 view_space = gbuffer_view_space(center, I.HPos.xy);

    float3 img = s_image.Load(int3(center.xy * screen_res.xy, 0), 0);

    img = mblur(center, view_space, img.rgb);

    float4 bloom = s_ssfx_bloom.Sample(smp_rtlinear, center);

// Sky Debanding Implementation  - SCREEN SPACE SHADERS - UPDATE 12.5
#ifdef SSFX_DEBAND
    img = lerp(img, ssfx_debanding(img, center), view_space.z <= SKY_EPS);
#endif

    float fogresult = SSFX_CALC_FOG(view_space);
    fogresult *= fogresult;

// Fog Scattering -----------------------
#ifdef G_FOG_USE_SCATTERING
    // Blur sample
    float3 foggg = s_blur_2.Sample(smp_rtlinear, center);

    int disablefog = pnv_param_1.z > 0 ? 0.f : 1.f;

    // Blend
    img = lerp(img, max(img, foggg), smoothstep(0.2f, 0.8f, fogresult) * disablefog);
#endif

    if (pnv_param_1.z < 1.f)
    {
        float3 flares = s_flares.Sample(smp_rtlinear, center);
        img = blend_soft(img, bloom.xyz * bloom.w);
        img += generate_flare(center, m_flare_params.y);
        img += flares;
    }

    // Vanilla color grading ( Exposure, saturation and gamma )
    img = img_corrections(img);

    img += rad_effect(img.rgb, center);

    return img;
}
