#include "common\common.h"
#include "common\sload.h"

f_deffer main(p_flat I)
{
    float4 D = tbase(I.tcdh);

#ifdef USE_AREF
    hashed_alpha_test(I.tcdh.xy, D.a);
#endif

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

    //O.Velocity = get_motion_vector(I.hpos_curr, I.hpos_old);

    return O;
}
