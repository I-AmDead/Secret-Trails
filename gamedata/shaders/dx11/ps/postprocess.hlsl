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

uniform float4 c_brightness;

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
float4 main(PSInput I) : SV_Target
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
