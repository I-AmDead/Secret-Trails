#include "common\common.h"
#include "common\sload.h"
#include "common\models_watch_effects.h"
#include "common\screenspace\screenspace_hud_raindrops.h"

uniform float4 m_affects;

f_deffer main(p_flat I)
{
    float problems = frac(timers.z * 5 * (1 + 2 * m_affects.x)) * 2;
    I.tcdh.x += (m_affects.x > 0.09 && I.tcdh.y > problems - 0.01 && I.tcdh.y < problems) ? sin((I.tcdh.y - problems) * 5 * m_affects.y * 2) : 0;

    problems = cos((frac(timers.z * 2) - 0.5) * 3.1416) * 2 - 0.8;
    float AMPL = 0.13;
    I.tcdh.x -= (m_affects.x > 0.15 && I.tcdh.y > problems - AMPL && I.tcdh.y < problems + AMPL) ?
        (cos(4.71 * (I.tcdh.y - problems) / AMPL) * sin(frac(timers.z) * 6.2831 * 90) * 0.02 * (AMPL - abs(I.tcdh.y - problems)) / AMPL) :
        0;

    I.tcdh.x += (m_affects.x > 0.38) ? (m_affects.y - 0.5) * 0.04 : 0;

    // diffuse
    float3 D = tbase(I.tcdh); // IN:  rgb.a

    if (m_affects.x > 0.41)
    {
        D += glitch_cube(I.tcdh);
        // D = 0.1f;
    }
    else
    {
        if (m_affects.a == 0)
        {
            D += NixieTime(I.tcdh);
        }
    }

    if (m_affects.a > 0 && m_affects.x >= 0.08)
        D += watch_loading(I.tcdh);

    float noise = (m_affects.x < 0.41 && m_affects.x > 0.0) ? get_noise(I.tcdh * timers.z) * m_affects.x * m_affects.x * 20 : 0.0;

    D.x += noise;
    D.y += noise;
    D.z += noise;

#ifdef USE_TDETAIL
    D.rgb = 2 * D.rgb * s_detail.Sample(smp_base, I.tcdbump).rgb;
#endif

    // hemi,sun,material
    float ms = xmaterial;

#ifdef USE_LM_HEMI
    float h = s_hemi.Sample(smp_rtlinear, I.lmh).a;
#else
    float h = I.position.w;
#endif

    float4 Ne = float4(normalize((float3)I.N.xyz), h);
    f_deffer O = pack_gbuffer(Ne, float4(I.position.xyz + Ne.xyz * def_virtualh / 2.h, ms), float4(D.rgb, def_gloss));

    O.Velocity = get_motion_vector(I.hpos_curr, I.hpos_old);

    return O;
}
