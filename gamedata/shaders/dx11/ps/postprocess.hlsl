#include "common\common.h"

Texture2D s_base1;
Texture2D s_base2;
Texture2D s_noise;

uniform float4 c_brightness;

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
float4 main(p_postpr I) : SV_Target
{
    float3 base1 = saturate(s_base1.Sample(smp_rtlinear, I.Tex0));
    float3 base2 = saturate(s_base2.Sample(smp_rtlinear, I.Tex1));
    float3 image = (base1 + base2) * 0.5;

    float gray = dot(image, I.Gray);
    image = lerp(gray, image, I.Gray.w);

    float4 t_noise = s_noise.Sample(smp_linear, I.Tex2);
    float3 noised = image * t_noise * 2;
    image = lerp(noised, image, I.Color.w);
    image = (image * I.Color + c_brightness) * 2;

    return float4(image, 1.0h);
}
