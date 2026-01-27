#include "common\common.h"
#include "common\sload.h"

struct PSInput
{
    float4 Color : COLOR0;
    float2 Tex0 : TEXCOORD0;
    float4 Tex1 : TEXCOORD1;
    float3 Tex2 : TEXCOORD2;
    float4 HPos_curr : TEXCOORD3;
    float4 HPos_old : TEXCOORD4;
};

f_deffer main(PSInput I)
{
    float4 D = s_base.Sample(smp_base, I.Tex0);
    D *= I.Color;

    hashed_alpha_test(I.Tex0.xy, D.a);

    float4 Ne = float4(normalize((float3)I.Tex2.xyz), I.Tex1.w);

    f_deffer O = pack_gbuffer(Ne, float4(I.Tex1.xyz + Ne.xyz * def_virtualh / 2.h, xmaterial), float4(D.xyz, def_gloss));

    O.Velocity = get_motion_vector(I.HPos_curr, I.HPos_old);

    return O;
}
