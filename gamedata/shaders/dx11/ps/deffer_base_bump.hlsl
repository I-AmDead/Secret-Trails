#include "common\common.h"
#include "common\sload.h"
#include "common\common_brdf.h"

// SSS Settings
#include "common\screenspace\settings_screenspace_FLORA.h"

f_deffer main(p_bumped I)
{
    surface_bumped S = sload(I);

#ifdef USE_AREF
    hashed_alpha_test(I.tcdh.xy, S.base.a);
#endif

    // Sample normal, rotate it by matrix, encode position
    float3 Ne = mul(float3x3(I.M1, I.M2, I.M3), S.normal);
    Ne = normalize(Ne);

    // hemi, sun, material
    float ms = xmaterial;

#ifdef USE_LM_HEMI
    float h = s_hemi.Sample(smp_rtlinear, I.lmh).a;
#else
    float h = I.position.w;
#endif

    f_deffer O = pack_gbuffer(float4(Ne, h), float4(I.position.xyz + Ne * S.height * def_virtualh, ms), float4(S.base.rgb, S.gloss));

    O.Velocity = get_motion_vector(I.hpos_curr, I.hpos_old);

    return O;
}
