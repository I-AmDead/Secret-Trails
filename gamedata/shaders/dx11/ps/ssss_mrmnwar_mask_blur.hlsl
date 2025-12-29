#include "common\common.h"
#include "common\Gauss.h" //gaussian blur

uniform Texture2D s_mask_blur; // smoothed mask
uniform Texture2D s_sunshafts;

float4 main(p_screen I) : SV_Target
{
    float4 outColor = Gauss_Horizontal(s_mask, I.tc0.xy, 6.f);
    outColor = Gauss_Vertical(s_mask, I.tc0.xy, 6.f);
    
    return outColor;
}