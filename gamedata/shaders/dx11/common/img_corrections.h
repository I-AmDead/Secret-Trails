#ifndef IMG_CORRECTIONS_H
#define IMG_CORRECTIONS_H
#include "common\common.h"

float3 ACESFittedFinal(float3 x)
{
    const float a = 2.51f;
    const float b = 0.03f;
    const float c = 2.43f;
    const float d = 0.59f;
    const float e = 0.14f;
    return saturate((x * (a * x + b)) / (x * (c * x + d) + e));
}

float3 img_corrections(float3 img)
{
    // exposure
    img *= pp_img_corrections.x;

    // COLOR GRADING
    float fLum = dot(img.xyz, LUMINANCE_VECTOR);
    float3 cColor = lerp(0.0, pp_img_cg.xyz, saturate(fLum * 2.0));
    cColor = lerp(cColor, 1.0, saturate(fLum - 0.5) * 2.0);

    if (pp_img_cg.x > 0.0 || pp_img_cg.y > 0.0 || pp_img_cg.z > 0.0)
    {
        img.xyz = saturate(lerp(img.xyz, cColor.xyz, saturate(fLum * 0.15)));
    }

    // saturation
    float sat = pp_img_corrections.z;
    float luma = dot(img, LUMINANCE_VECTOR);
    img = lerp(luma.xxx, img, sat);

    // ACES HYBRID BLEND
    float3 aces = ACESFittedFinal(img);

    // Calculate mask: 0.0 for dark pixels, 1.0 for bright pixels
    float maxc = max(img.r, max(img.g, img.b));
    float w_aces = saturate((maxc - 0.7f) / 0.3f);

    // Blend da Dark areas stay Linear (with Color Grading), Bright areas get ACES
    img = lerp(img, aces, 0.6f * w_aces);

    // GAMMA CORRECTION
    float gamma = max(pp_img_corrections.y, 0.01f);
    float invGamma = 1.0f / gamma;

    img = pow(saturate(img), invGamma);

    return saturate(img);
}
#endif