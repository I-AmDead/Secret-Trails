#include "common\common.h"

float3 tonemap_high(float3 rgb, float scale)
{
    rgb = SRGBToLinear(rgb);
    rgb = rgb * scale;
    rgb = LinearTosRGB(rgb);

    return rgb / def_hdr;
}

uniform float4 b_params;

float4 main(p_build I) : SV_Target
{
    float scale = s_tonemap.Load(int3(0, 0, 0)).x;
    float3 result = tonemap_high(s_image.Sample(smp_rtlinear, I.Tex0), scale);
    result += tonemap_high(s_image.Sample(smp_rtlinear, I.Tex1), scale);
    result += tonemap_high(s_image.Sample(smp_rtlinear, I.Tex2), scale);
    result += tonemap_high(s_image.Sample(smp_rtlinear, I.Tex3), scale);
    result *= 0.5;

    float hi = dot(result, 1.h) - b_params.x; // assume def_hdr equal to 3.0

    return float4(result, hi);
}
