#include "common\common.h"

struct PSInput
{
    float2 Tex0 : TEXCOORD0;
    float3 Tex1 : TEXCOORD1;
    float3 Color0 : COLOR0;
    float Fog : FOG;
};

TextureCube s_env;

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel

float4 main(PSInput I) : SV_Target
{
    float4 t_base = s_base.Sample(smp_base, I.Tex0);
    float4 t_env = s_env.Sample(smp_rtlinear, I.Tex1);

    float3 base = lerp(t_env, t_base, t_base.a);
    float3 light = I.Color0;
    float3 final = light * base * 2;

    // Fogging
    final = lerp(fog_color, final, I.Fog);

    // out
    return float4(final.r, final.g, final.b, t_base.a * I.Fog * I.Fog);
}
