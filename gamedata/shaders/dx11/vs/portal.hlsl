#include "common\common.h"
#include "common\screenspace\screenspace_fog.h"

struct VSInput
{
    float4 HPos : POSITION; // (float,float,float,1)
    float4 Color : COLOR0; // (r,g,b,dir-occlusion)
};

struct VSOutput
{
    float4 Color : COLOR0;
    float Fog : FOG;
    float4 HPos : SV_Position;
};

VSOutput main(VSInput I)
{
    VSOutput O;

    O.HPos = mul(m_VP, I.HPos);
    O.HPos.xy = get_taa_jitter(O.HPos);

    float fog = saturate(calc_fogging(I.HPos));
    O.Fog = SSFX_FOGGING(1.0 - fog, I.HPos.y);

    O.Color.rgb = lerp(fog_color, I.Color, O.Fog * O.Fog);
    O.Color.a = O.Fog;

    return O;
}
