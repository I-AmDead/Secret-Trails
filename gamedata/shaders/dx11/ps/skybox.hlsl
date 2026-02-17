#include "common\screenspace\check_screenspace.h"
#include "common\common.h"
#include "common\pbr_cubemap_check.h"

#ifdef SSFX_BEEFS_NVG
#include "common\night_vision.h"
#endif

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
    float4 Color : SV_Target0;
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

    O.Color = float4(sky, 0.0);

#ifdef SSFX_BEEFS_NVG
    float2 texturecoord = I.HPos.xy / screen_res.xy;
    float2 texturecoord_2 = I.HPos.xy / screen_res.xy;

    float lua_param_nvg_num_tubes = pnv_param_4.x; // 1, 2, 4, 1.1, or 1.2
    float lua_param_nvg_gain_current = pnv_param_2.y;
    float lua_param_vignette_current = pnv_param_2.z;

    if (pnv_param_1.z == 1.f &&
        ((compute_lens_mask(aspect_ratio_correction(texturecoord), lua_param_nvg_num_tubes) == 1.0f ||
          compute_lens_mask(aspect_ratio_correction(texturecoord_2), lua_param_nvg_num_tubes) == 1.0f))) //
    {
        O.Color.r = dot(O.Color.rgb * 5.0f, luma_conversion_coeff);

        O.Color.gb = 0.0f;

        O.Color *= lua_param_nvg_gain_current * sky_brightness_factor;

        O.Color = clamp(O.Color, 0.0, 1.0);

        float vignette = calc_vignette(lua_param_nvg_num_tubes, texturecoord, lua_param_vignette_current);
        float vignette_2 = calc_vignette(lua_param_nvg_num_tubes, texturecoord_2, lua_param_vignette_current);
        O.Color *= (vignette * vignette_2);
    }
#endif

    O.Velocity = get_motion_vector(I.HPos_curr, I.HPos_old);

    return O;
}
