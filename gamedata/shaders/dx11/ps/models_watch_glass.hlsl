#include "common\common.h"
#include "common\screenspace\screenspace_hud_raindrops.h"

Texture2D s_glass_distortion;

//////////////////////////////////////////////////////////////////////////////////////////
// Pixel
float4 main(v2p_TLD4 I) : SV_Target
{
    float4 diffuse_texture = s_glass_distortion.SampleLevel(smp_nofilter, I.Tex0, 0).wwww; // we wanna fetch alpha only

    float2 diffuse_tc = (diffuse_texture.xy * 2.0 - 1.0) * 0.05;
    float2 refr_tc = I.Tex0.xy + diffuse_tc;

    // HUD Rain drops - SSS Update 17
    // https://www.moddb.com/mods/stalker-anomaly/addons/screen-space-shaders/

    // float4 drops = 0; // xy = Normal | z = Overall str | w = reflection str //Simp: WTF???
    float extra_col = 0;
    if (ssfx_hud_drops_1.y > 0)
    {
        // Calc droplets
        float4 Layer0 = s_hud_rain.Sample(smp_base, (I.Tex0 + float2(0, -ssfx_hud_drops_1.x * 0.01f)) * float2(1.5f, 0.75f)); // Big drops
        float4 Layer1 = s_hud_rain.Sample(smp_base, I.Tex0 * float2(5.0f, 3.0f)); // Small drops [ Static ]

        // Process animation
        float3 result = ssfx_process_drops(Layer0, 0.1f, 0.2f) + ssfx_process_drops(Layer1, 0.2f, 1.0f);
        result.xy = clamp(result.xy, -1.0f, 1.0f);

        // Only apply to facing up surfaces [ World Y+ ]
        result.xyz *= saturate(I.Tex1.y);

        // Intensity from script ( Cover + Rain intensity )
        result.xyz *= ssfx_hud_drops_1.y;

        // Refraction
        I.Tex0.xy = I.Tex0.xy - result.xy * 0.4f;

        // Add a small amount of white.
        extra_col = saturate(Layer0.x + Layer1.x) * result.z * 0.4f;
    }

    float4 t_base = s_base.Sample(smp_base, I.Tex0);

    t_base.rgb += (diffuse_texture.w * 4.0) * t_base.rgb;

    return (t_base + extra_col) * I.Color;
}