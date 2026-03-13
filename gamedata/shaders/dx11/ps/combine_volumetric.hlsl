#include "common\common.h"

Texture2D s_vollight1;
Texture2D s_vollight2;

float3 main(p_screen I) : SV_Target
{
    // Initialize accumulator
    float3 color = 0.0f;
    
    // 4x4 box filter (16 taps)
    for (int j = -2; j < 2; j++)
    {
        for (int i = -2; i < 2; i++)
        {
            // Sample using texture coordinates with offset
            float2 offset = I.HPos.xy + int2(i, j);
            color += s_vollight1[offset];
            color += s_vollight2[offset];
        }
    }
    
    // Normalize by number of samples (16 taps)
    color *= 0.0625;

    return color;
}