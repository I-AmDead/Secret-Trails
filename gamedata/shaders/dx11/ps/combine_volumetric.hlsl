#include "common\common.h"

Texture2D noise_tex;
Texture2D s_vollight1;
Texture2D s_vollight2;

float4 main(p_screen I) : SV_Target
{
    float4 color = s_vollight1.SampleLevel(smp_linear, I.tc0.xy, 0);
    color += s_vollight2.SampleLevel(smp_linear, I.tc0.xy, 0);

    // Read Depth
    float _depth = s_position.Sample(smp_nofilter, I.tc0.xy).z;

    // Noise TC
    float2 uv_noise = I.tc0.xy;
    uv_noise.x *= screen_res.x / screen_res.y;

    // Add noise to dither the result
    color = saturate(color - noise_tex.Sample(smp_linear, uv_noise * 2.5).xxxx * 0.01f);

    // Discard Sky.
    color *= _depth < 0.001 ? 1.0f : saturate(_depth * 1.5f);

    return color;
}