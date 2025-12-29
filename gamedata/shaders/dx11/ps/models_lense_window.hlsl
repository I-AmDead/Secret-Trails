#include "common\common.h"
#include "common\sload.h"

uniform float4 m_hud_params;

f_deffer main(p_flat I)
{
    float4 D = tbase(I.tcdh);
    hashed_alpha_test(I.tcdh.xy, D.a - (m_hud_params.x > 0.9 ? 1.f : 0.f));

#ifdef USE_TDETAIL
    D.rgb = 2 * D.rgb * s_detail.Sample(smp_base, I.tcdbump).rgb;
#endif

    // hemi,sun,material
    float ms = xmaterial;

#ifdef USE_LM_HEMI
    float4 lm = s_hemi.Sample(smp_rtlinear, I.lmh);
    float h = get_hemi(lm);
#else
    float h = I.position.w;
#endif

    float4 Ne = float4(normalize((float3)I.N.xyz), h);
    f_deffer O = pack_gbuffer(Ne, float4(I.position.xyz + Ne.xyz * def_virtualh / 2.h, ms), float4(D.rgb, def_gloss));

    O.Velocity = get_motion_vector(I.hpos_curr, I.hpos_old);

    return O;
}