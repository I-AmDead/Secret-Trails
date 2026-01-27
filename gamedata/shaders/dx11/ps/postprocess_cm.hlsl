#include "common\common.h"

struct PSInput
{
    float2 Tex0 : TEXCOORD0;
    float2 Tex1 : TEXCOORD1;
    float2 Tex2 : TEXCOORD2;
    float4 Color : COLOR0;
    float4 Gray : COLOR1;
};

Texture2D s_base1;
Texture2D s_base2;
Texture2D s_noise;
Texture2D s_grad0;
Texture2D s_grad1;

uniform float4 c_brightness;
uniform float4 c_colormap;

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
float4 main(PSInput I) : SV_Target
{
    float3 base1 = saturate(s_base1.Sample(smp_rtlinear, I.Tex0));
    float3 base2 = saturate(s_base2.Sample(smp_rtlinear, I.Tex1));
    float3 image_o = (base1 + base2) * 0.5;

    float grad_i = dot(image_o, (0.3333h).xxx);

    float3 image0 = s_grad0.Sample(smp_rtlinear, float2(grad_i, 0.5));
    float3 image1 = s_grad1.Sample(smp_rtlinear, float2(grad_i, 0.5));
    float3 image = lerp(image0, image1, c_colormap.y);
    image = lerp(image_o, image, c_colormap.x);

    float gray = dot(image, I.Gray);
    image = lerp(gray, image, I.Gray.w);

    float4 t_noise = s_noise.Sample(smp_linear, I.Tex2);
    float3 noised = image * t_noise * 2;
    image = lerp(noised, image, I.Color.w);
    image = (image * I.Color + c_brightness) * 2;

    return float4(image, 1.0h);
}
