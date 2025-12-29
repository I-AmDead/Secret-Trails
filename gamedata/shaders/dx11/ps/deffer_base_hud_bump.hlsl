#include "common\common.h"
#include "common\sload.h"
#include "common\screenspace\screenspace_hud_raindrops.h"

f_deffer main(p_bumped I)
{
    f_deffer O;

    surface_bumped S = sload(I);

#ifdef USE_AREF
    hashed_alpha_test(I.tcdh.xy, S.base.a);
#endif

    // HUD Rain drops - SSS Update 17
    // https://www.moddb.com/mods/stalker-anomaly/addons/screen-space-shaders/

    float4 drops = 0; // xy = Normal | z = Overall str | w = reflection str

    if (ssfx_hud_drops_1.y > 0)
    {
        // Calc droplets
        drops.xyz = ssfx_hud_raindrops(s_hud_rain, I.RDrops.xyz, 1.0f);

        // Only apply to facing up surfaces [ World Y+ ]
        drops.xyz *= saturate(I.RDrops.w);

        // Intensity from script ( Cover + Rain intensity )
        drops.xyz *= ssfx_hud_drops_1.y;

        // Refraction
        I.tcdh.xy = I.tcdh.xy + drops.xy * ssfx_hud_drops_1.w;

        // Reflection adjustments
        drops.w = ssfx_hud_drops_1.z * dot(L_hemi_color, SSFX_HUD_LIGHTVECTOR);
        drops.w = max(drops.w, 3.0f);
    }

    // Add sampled normal and droplets
    float3 Ne = mul(float3x3(I.M1, I.M2, I.M3), S.normal + float3(drops.xy * drops.w, 1.0f));
    Ne = normalize(Ne);

    // hemi,sun,material
    float ms = xmaterial;

    S.gloss += ssfx_gloss.w;
    S.gloss += (ssfx_hud_drops_1.y * ssfx_hud_drops_2.z) + drops.z * ssfx_hud_drops_2.w;

#ifdef USE_LM_HEMI
    float4 lm = s_hemi.Sample(smp_rtlinear, I.lmh);
    float h = get_hemi(lm);
#else
    float h = I.position.w;
#endif

    O = pack_gbuffer(float4(Ne, h), float4(I.position.xyz + Ne * S.height * def_virtualh, ms), float4(S.base.rgb, S.gloss));

    O.Velocity = get_motion_vector(I.hpos_curr, I.hpos_old);

    return O;
}
