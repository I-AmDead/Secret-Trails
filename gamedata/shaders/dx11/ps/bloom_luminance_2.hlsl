#include "common\common.h"

float sample(float2 tc)
{
    float4 data = s_image.Sample(smp_rtlinear, tc);
    return dot(data, 1.h / 4.h);
}

float4 main(p_filter I) : SV_Target
{
    float2 coords[8] = {I.Tex0.xy, I.Tex1.xy, I.Tex2.xy, I.Tex3.xy, I.Tex4.xy, I.Tex5.xy, I.Tex6.xy, I.Tex7.xy};

    float2 coords_wz[8] = {I.Tex0.wz, I.Tex1.wz, I.Tex2.wz, I.Tex3.wz, I.Tex4.wz, I.Tex5.wz, I.Tex6.wz, I.Tex7.wz};

    // perform accumulation
    float4 final;
    for (int i = 0; i < 4; i++)
    {
        final.x += sample(coords[i]);
        final.y += sample(coords[i + 4]);
        final.z += sample(coords_wz[i]);
        final.w += sample(coords_wz[i + 4]);
    }

    return final * 0.25h;
}
