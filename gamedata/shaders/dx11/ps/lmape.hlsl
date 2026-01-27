#include "common\common.h"

struct PSInput
{
    float2 Tex0 : TEXCOORD0; // base
    float2 Tex1 : TEXCOORD1; // lmap
    float2 Tex2 : TEXCOORD2; // hemi
    float3 Tex3 : TEXCOORD3; // env
    float3 Color0 : COLOR0;
    float3 Color1 : COLOR1;
    float Fog : FOG;
};

// uniform samplerCUBE 	s_env;
TextureCube s_env; //	Environment for forward rendering

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
float4 main(PSInput I) : SV_Target
{
    float4 t_base = s_base.Sample(smp_base, I.Tex0);
    float4 t_lmap = s_lmap.Sample(smp_rtlinear, I.Tex1);
    float4 t_env = s_env.Sample(smp_rtlinear, I.Tex3);

    // lighting
    float3 l_base = t_lmap.rgb;
    float3 l_hemi = I.Color0 * p_hemi(I.Tex2);
    float3 l_sun = I.Color1 * t_lmap.a;
    float3 light = L_ambient + l_base + l_sun + l_hemi;

    // final-color
    float3 base = lerp(t_env, t_base, t_base.a);
    float3 final = light * base * 2;

    // Fogging
    final = lerp(fog_color, final, I.Fog);

    // out
    return float4(final.r, final.g, final.b, t_base.a * I.Fog * I.Fog);
}
