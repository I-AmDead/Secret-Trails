#include "common\common.h"
#include "common\ogse_functions.h"
#include "common\screenspace\screenspace_fog.h"

struct VSOutput
{
    float2 Tex0 : TEXCOORD0;
    float4 Tex1 : TEXCOORD1;
    float4 Tex2 : TEXCOORD2;
    float Fog : FOG;
    float4 HPos : SV_Position;
};

uniform float4x4 mVPTexgen;

VSOutput main(v_TL I)
{
    VSOutput O;

    O.HPos = mul(m_WVP, I.P); // xform, input in world coords
    O.HPos.xy = get_taa_jitter(O.HPos);

    O.Tex0.xy = I.Tex0; // copy tc
    O.Tex1 = proj_to_screen(O.HPos);
    O.Tex1.xy /= O.Tex1.w;

    float fog = saturate(calc_fogging(I.P)); // fog, input in world coords
    O.Fog = SSFX_FOGGING(1.0 - fog, I.P.y); // Add SSFX Fog

    O.Tex2 = mul(mVPTexgen, I.P);
    O.Tex2.z = O.HPos.z;

    return O;
}
