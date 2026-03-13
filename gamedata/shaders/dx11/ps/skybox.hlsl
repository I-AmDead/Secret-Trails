#include "common\screenspace\check_screenspace.h"
#include "common\common.h"
#include "common\pbr_cubemap_check.h"

#include "common\night_vision.h"

struct PSInput
{
    float4 Color : COLOR0; // rgb tint
    float3 Tex0 : TEXCOORD0;
    float3 Tex1 : TEXCOORD1;
    float4 HPos_curr : HPOS_CURRENT;
    float4 HPos_old : HPOS_PREVIOUS;
    float4 HPos : SV_Position;
};

struct PSOutput
{
    float3 Color : SV_Target0;
    float2 Velocity : SV_Target1;
};

TextureCube s_sky0 : register(t0);
TextureCube s_sky1 : register(t1);

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
PSOutput main(PSInput I)
{
    float3 s0 = s_sky0.Sample(smp_rtlinear, I.Tex0);
    float3 s1 = s_sky1.Sample(smp_rtlinear, I.Tex1);

    float3 sky = lerp(s0, s1, I.Color.w);

    sky *= I.Color.rgb;

    // final tone-mapping
    PSOutput O;

    tonemap(sky, 1);

    O.Color = sky;

    if (pnv_param_1.z == 1.f && compute_lens_mask(aspect_ratio_correction(I.HPos.xy / screen_res.xy), pnv_param_4.x) == 1.0f)
    {
        O.Color.r = dot(O.Color.rgb * 5.0f, luma_conversion_coeff);

        O.Color.gb = 0.0f;

        O.Color *= pnv_param_2.y * sky_brightness_factor;

        O.Color = clamp(O.Color, 0.0, 1.0);

        O.Color *= calc_vignette(pnv_param_4.x, I.HPos.xy / screen_res.xy, pnv_param_2.z);
    }

    O.Velocity = get_motion_vector(I.HPos_curr, I.HPos_old);

    return O;
}
