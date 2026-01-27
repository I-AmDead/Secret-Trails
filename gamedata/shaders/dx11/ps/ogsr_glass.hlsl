/**
 * @ Version: SCREEN SPACE SHADERS - UPDATE 23
 * @ Description: Glass Shader - PS
 * @ Modified time: 2025-05-28 20:32:33
 * @ Author: https://www.moddb.com/members/ascii1457
 * @ Mod: https://www.moddb.com/mods/stalker-anomaly/addons/screen-space-shaders
 */

#include "common\common.h"
#include "common\screenspace\settings_screenspace_GLASS.h"

struct PSInput
{
    float4 P : POSITION;
    float2 Tex0 : TEXCOORD0;
    float3 Tex1 : TEXCOORD1;
    float3 Tex2 : TEXCOORD2;
    float3 Tex3 : TEXCOORD3;
    float4 HPos : SV_Position;
    float Fog : FOG;
};

TextureCube s_env;
Texture2D s_glass;
Texture2D s_screen;

float4 main(PSInput I) : SV_Target
{
    float4 t_base = s_base.Sample(smp_base, I.Tex0);
    float4 t_env = s_env.Sample(smp_rtlinear, I.Tex1) * 0.5;

    float3 base = lerp(t_env, t_base, t_base.a);
    float3 final = 0;

    // Scale
    float2 tc_screen = I.HPos.xy / screen_res.xy;
    float pixelsize = (1.0f / screen_res.xy) * 2.0f;
    float3 screen = 0;

    float acc = saturate(s_accumulator.Sample(smp_nofilter, tc_screen).r * 2000);

    // Fresnel
    float fresnel = saturate(dot(reflect(I.Tex2, I.Tex3), I.Tex2));
    fresnel = pow(fresnel, 5);

    // Fake Triplanar
    float3 d1 = ddx(I.P);
    float3 d2 = ddy(I.P);

    // Recontruct normal
    float3 n = abs(normalize(cross(d1, d2)));

    // Major axis (in x; yz are following axis)
    int3 ma = (n.x > n.y && n.x > n.z) ? int3(0, 1, 2) : (n.y > n.z) ? int3(1, 2, 0) : int3(2, 0, 1);

    // Uvs
    float2 uvs = float2(I.P.xy[ma.y], I.P.xy[ma.z]);

    // Normal offset
    float2 tc_offset = s_glass.Sample(smp_base, uvs * SSFX_GLASS_BUMP_SCALE);
    tc_offset = (tc_offset.xy * 2 - 1) * max((SSFX_GLASS_REFRACTION + fresnel * 0.05) / I.HPos.w, (SSFX_GLASS_REFRACTION + fresnel * 0.05));

    tc_offset = clamp(tc_offset, -1.0f, 1.0f);

    // CA
    screen.r = s_screen.SampleLevel(smp_rtlinear, (tc_screen + pixelsize.xx) + tc_offset, 0).r;
    screen.g = s_screen.SampleLevel(smp_rtlinear, tc_screen + tc_offset, 0).g;
    screen.b = s_screen.SampleLevel(smp_rtlinear, (tc_screen - pixelsize.xx) + tc_offset, 0).b;

    // Add texture
    final = lerp(screen.rgb * saturate(base * 1.5f), screen.rgb, 1.0f - I.Fog);

    // Apply Fresnel
    final += fresnel.xxx * SSFX_GLASS_FRESNEL * float3(0.9f, 1.0f, 0.9f) * acc; // Tint

    // out
    return float4(final.r, final.g, final.b, t_base.a);
}
