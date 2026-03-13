#include "common\screenspace\screenspace_common.h"

// Check Addons
#include "common\screenspace\check_screenspace.h"

#include "common\night_vision.h"

float4 blur_params;

float3 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    if (pnv_param_1.z == 1.f && compute_lens_mask(aspect_ratio_correction(Tex0), pnv_param_4.x) == 1.0f) // if NVGs are enabled 
    {
        float3 image;

        if (blur_params.z == (screen_res.x / 2.0f)) // half-res fixed DOF blur pass 2
        {
            float divisor = 0.0f;
            float r = 1.0f;
            float scale = blur_params.x == 0 ? 0.3f : 0.05f;
            float weight = 1.0f;
            float3 total = 0.0f;
            float2x2 G = rot(2.399996);

            scale *= (IGN_calc(Tex0 / 2.0 * screen_res.xy));
            float2 offset = float2(scale, scale);

            if (blur_params.x == 0)
            {
                image = s_image.Sample(smp_rtlinear, Tex0).rgb;
                float center_depth = image.b;

                for (int i = 0; i < 24; ++i)
                {
                    r += 1.0f / r;
                    offset = mul(offset, G);
                    float falloff = saturate((1.2f * center_depth) - log(center_depth * 6.4f) - (0.4f * pow(center_depth, 2.3f)));
                    float3 color = s_image.SampleLevel(smp_rtlinear, Tex0 + (offset * (falloff) * (r - 1.02f) * 1.0f / screen_res.xy), 0).rgb;
                    float weight = 1.0f;
                    total += color * weight;
                    divisor += weight;
                }

                image = max((total.rgb / divisor), 0);
            }

            if (blur_params.x == 1)
            {
                image = float3(s_image.Sample(smp_rtlinear, Tex0).rg, saturate(s_position.Load(int3((Tex0) * screen_res.xy, 0), 0).z / farthest_depth));

                if (image.b == 0.0f)
                {
                    image.b = 1.0f;
                }

                float total_depth = image.b;
                float divisor_depth = 1.0f;

                for (int i = 0; i < 16; ++i)
                {
                    r += 1.0f / r;
                    offset = mul(offset, G);
                    float3 color = s_image.SampleLevel(smp_rtlinear, Tex0 + (offset * (r - 1.0f) * 1.0f / screen_res.xy), 0).rgb;
                    color.b = saturate(s_position.Load(int3((Tex0 * screen_res.xy) + (offset * (r - 1.0f)), 0), 0).z / (farthest_depth));

                    if (color.b == 0.0f)
                    {
                        color.b = 1.0f;
                    }

                    float weight = 1.0f;
                    total.rg += color.rg * weight;
                    divisor += weight;

                    if (color.b <= image.b - 0.04)
                    {
                        total_depth += color.b;
                        divisor_depth += weight;
                    }
                }

                image = float3(max((total.rg / divisor), 0), max((total_depth / divisor_depth), 0));
            }

            float vignette = calc_vignette(pnv_param_4.x, Tex0, pnv_param_2.z);
            image = clamp(image, 0.0, 1.0);
            image *= vignette;

            return image;
        }

        if (blur_params.z == (screen_res.x / 4))
        {
            float Pi = 6.28318530718;
            float light_avgs = 0.0f;
            float3 color = 0.0f;
            float3 color_average = s_image.Sample(smp_rtlinear, Tex0).rgb;

            float blur_directions = blur_params.x == 0 ? 16.0 : 12.0;
            float blur_quality = blur_params.x == 0 ? 4.0 : 6.0;
            float blur_radius = blur_params.x == 0 ? 4 : 1.5;

            for (float i = 1.0; i <= blur_quality; i++)
            {
                for (float d = 0.0; d < Pi; d += Pi / blur_directions)
                {
                    color = s_image.SampleLevel(smp_rtlinear, Tex0 + (float2(cos(d), sin(d)) * blur_radius * i / screen_res.xy), 0).rgb;

                    if (blur_params.x == 1)
                    {
                        float general_threshold = 0.05f;
                        float light_thresh = pnv_param_4.y;

                        color.rb *= color.rb;
                        color.rb = saturate((color.rb - general_threshold) / (1.0f - general_threshold));
                        color.g = saturate((color.g - light_thresh) / (1.0f - light_thresh));
                    }

                    if (color.g > 0.0f)
                    {
                        color.g *= blur_params.x == 0 ? 4.0f : 8.0f;
                        light_avgs += 1.0f;
                    }
                    else
                    {
                        light_avgs += 0.1 * i;
                    }

                    if (blur_params.x == 1)
                    {
                        color.rb = sqrt(color.rb);
                    }

                    color_average += color;
                }
            }

            image.rb = color_average.rb / (blur_directions * blur_quality);
            image.g = color_average.g / light_avgs;

            return image;
        }

        if (blur_params.z == (screen_res.x / 8))
        {
            float Pi = 6.28318530718;
            float light_avgs = 0.0f;
            float3 color = 0.0f;
            float3 color_average = s_image.Sample(smp_rtlinear, Tex0).rgb;

            float blur_radius = blur_params.x == 0 ? 4 : 1;
            float blur_directions = blur_params.x == 0 ? 16.0 : 12.0;
            float blur_quality = 4.0;

            for (float i = 1.0; i <= blur_quality; i++)
            {
                for (float d = 0.0; d < Pi; d += Pi / blur_directions)
                {
                    color = s_image.SampleLevel(smp_rtlinear, Tex0 + (float2(cos(d), sin(d)) * blur_radius * i / screen_res.xy), 0).rgb;

                    if (blur_params.x == 1)
                    {
                        float general_threshold = 0.05f;
                        float light_thresh = pnv_param_4.y;
                        color.rb *= color.rb;
                        color.rb = saturate((color.rb - general_threshold) / (1.0f - general_threshold));
                        color.g = saturate((color.g - light_thresh) / (1.0f - light_thresh));
                    }

                    if (color.g > 0.0f)
                    {
                        color.g *= blur_params.x == 0 ? 4.0f : 8.0f;
                        light_avgs += 1.0f;
                    }
                    else
                    {
                        light_avgs += 0.1 * i;
                    }

                    if (blur_params.x == 1)
                    {
                        color.rb = sqrt(color.rb);
                    }
            
                    color_average += color;
                }
            }

            image.rb = color_average.rb / (blur_directions * blur_quality);
            image.g = color_average.g / light_avgs;

            return image;
        }
    }

    // OTHERWISE, DO NORMAL BLUR
    return SSFX_Blur(Tex0, 0.25f);
}