#include "common\common.h"

// Check Screen Space Shaders modules
#include "common\screenspace\check_screenspace.h"

#include "common\night_vision.h"

float4 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    float2 center = Tex0;
    float4 color = s_image.Load(int3(center.xy * screen_res.xy, 0), 0);
    float3 img = color.rgb;

    if (pnv_param_1.z == 1.f)
    {
        img = tonemap(img, 10.0f * pnv_param_2.w);

        // Turn split tonemapping data to YUV and discard UV
        img.r = dot(img.rgb, luma_conversion_coeff);
        img.r *= 4.0f;

        float4 diffuse = gbuffer_color(center);
        float4 L = s_accumulator.Sample(smp_nofilter, center); // diffuse.specular
        L.rgb += L.a * SRGBToLinear(diffuse.rgb); // illum in alpha

        // Turn s_accumulator data in to YUV and discard UV
        img.g = pow(dot(L.rgb, luma_conversion_coeff), 2.0f) * 1.3f;

        // Turn albedo into YUV and discard UV
        img.b = dot(diffuse.rgb, luma_conversion_coeff);

        img *= pnv_param_2.y;

        // APPLY VIGNETTE
        float vignette = calc_vignette(pnv_param_4.x, center, pnv_param_2.z + 0.02);

        img = clamp(img, 0.0, 1.0);

        img.rgb *= vignette;
    }
    else
    {
        float tm_scale = s_tonemap.Load(int3(0, 0, 0)).x;
        img = tonemap(img, tm_scale);
    }

    return float4(img, color.a);
}
