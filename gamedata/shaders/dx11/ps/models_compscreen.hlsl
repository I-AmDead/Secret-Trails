#include "common\common.h"
#include "common\sload.h"

uniform float4 m_affects;

f_deffer main(p_flat I)
{
    // diffuse
    float3 D = tbase(I.tcdh); // IN:  rgb.a

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

    float noise = get_noise(I.tcdh * timers.z) * m_affects.x * m_affects.x * 30;
    D.r += noise;
    D.g += noise;
    D.b += noise;

    D.rgb = (m_affects.x > 0.41) ? 0 : D.rgb;

    float4 Ne = float4(normalize((float3)I.N.xyz), h);

    f_deffer O = pack_gbuffer(Ne, float4(I.position.xyz + Ne.xyz * def_virtualh / 2.h, ms), float4(D.rgb, def_gloss));

    O.Velocity = get_motion_vector(I.hpos_curr, I.hpos_old);

    return O;
}
