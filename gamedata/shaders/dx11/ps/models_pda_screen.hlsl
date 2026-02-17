#include "common\common.h"
#include "common\screenspace\screenspace_hud_raindrops.h"
#include "common\models_watch_effects.h"

uniform float4 m_affects;
uniform Texture2D s_vp2;

float4 problems_main(v2p_TLD2 I)
{
    I.Tex0.x = resize(I.Tex0.x, screen_res.y / screen_res.x, 0.5);
    I.Tex0.x = resize(I.Tex0.x, screen_res.x / screen_res.y, 0.5);

    float problems = frac(timers.z * 5 * (1 + 2 * m_affects.x));
    I.Tex0.x += (m_affects.x > 0.09 && I.Tex0.y > problems - 0.01 && I.Tex0.y < problems) ? sin((I.Tex0.y - problems) * 5 * m_affects.y) : 0;

    problems = cos((frac(timers.z * 2) - 0.5) * 3.1416) * 2 - 0.8;
    float AMPL = 0.13;
    I.Tex0.x -= (m_affects.x > 0.15 && I.Tex0.y > problems - AMPL && I.Tex0.y < problems + AMPL) ? cos(4.71 * (I.Tex0.y - problems) / AMPL) * sin(frac(timers.z) * 6.2831 * 90) * 0.02 * (AMPL - abs(I.Tex0.y - problems)) / AMPL : 0;

    I.Tex0.x += (m_affects.x > 0.38) ? (m_affects.y - 0.5) * 0.04 : 0;

    float4 t_vp2 = (m_affects.x < 0.27) ? s_vp2.Sample(smp_base, I.Tex0) : s_base.Sample(smp_base, I.Tex0);

    float noise = get_noise(I.Tex0 * timers.z) * m_affects.x * m_affects.x * 20;
    t_vp2.r += noise;
    t_vp2.g += noise;
    t_vp2.b += noise;

    t_vp2.rgb = (m_affects.x > 0.41) ? 0 : t_vp2.rgb;

    if (m_affects.a > 0 && m_affects.x >= 0.08)
        t_vp2.rgb += pda_loading(I.Tex0);

    float brightness_factor = 0.5;
    t_vp2.rgb *= brightness_factor;

    return float4(t_vp2.r, t_vp2.g, t_vp2.b, m_affects.z);
}

float4 main(v2p_TLD2 I) : SV_Target
{
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
        extra_col = saturate(Layer0.x + Layer1.x) * result.z * 0.25f;
    }

    float4 final_clr = problems_main(I);
    return final_clr + extra_col;
}
