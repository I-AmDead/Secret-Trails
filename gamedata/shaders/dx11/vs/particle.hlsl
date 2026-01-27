#include "common\common.h"

struct VSOutput
{
    float2 Tex0 : TEXCOORD0;
    float4 Tex1 : TEXCOORD1;
    float4 Color : COLOR0;
    float Fog : FOG;
    float4 HPos : SV_Position;
};

uniform float4x4 mVPTexgen;

VSOutput main(v_TL I)
{
    VSOutput O;

    O.HPos = mul(m_WVP, I.P); // xform, input in world coords
    O.HPos.xy = get_taa_jitter(O.HPos);

    O.Tex0 = I.Tex0; // copy tc
    O.Color = unpack_D3DCOLOR(I.Color); // copy color

    O.Tex1 = mul(mVPTexgen, I.P);
    O.Tex1.z = O.HPos.z;

    O.Fog = saturate(calc_fogging(I.P)); // // ForserX (Port SkyLoader fog fix): fog, input in world coords

    return O;
}