#include "common\common.h"
#include "common\Gauss.h" //gaussian blur

uniform Texture2D s_mask_blur; // smoothed mask
uniform Texture2D s_sunshafts;

float3 main(float2 Tex0 : TEXCOORD0) : SV_Target
{
    float3 outColor = Gauss_Horizontal(s_mask, Tex0.xy, 6.f);
    outColor = Gauss_Vertical(s_mask, Tex0.xy, 6.f);
    
    return outColor;
}